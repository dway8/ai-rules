---
name: plan-review
description: Critique and strengthen a plan before implementation. Use when the user runs `/flow:plan-review` or asks to "review my plan", "tighten the plan", "save and harden this plan", or finishes drafting a plan in plan mode.
user-invocable: true
model: opus
---

Review and refine the plan that was just written in this conversation. Do the following steps sequentially. After each step, report what you did.

## Step 1: Prepare the workspace

This skill needs to edit the plan repeatedly and run shell commands that read it from a relative path. Plan mode blocks writes, and Claude Code's native plan mode saves plans under `~/.claude/plans/` with an auto-generated filename (often gibberish like `on-an-event-page-mutable-reddy.md`). Resolve both before doing any review work:

1. **Bail out if in plan mode.** If you are currently in plan mode, STOP and tell the user: *"This skill needs to write files and run shell commands, which plan mode blocks. Please exit plan mode (Shift+Tab) and re-run `/flow:plan-review`."* Do NOT call `ExitPlanMode` yourself — that tool is for "approve this plan and start implementing," and users running `/flow:plan-review` typically reject it (they're reviewing precisely because they don't want to implement yet). Let the user exit manually.
2. **Choose a meaningful kebab-case filename** that describes what the plan does (e.g. `migrate-auth-middleware.md`, `add-event-page-mutations.md`). Do NOT reuse the auto-generated name from `~/.claude/plans/` if it's gibberish — rename it.
3. **Copy the plan into the repo at `<repo-root>/.claude/plans/<filename>.md`:**
   - If a plan file exists at `~/.claude/plans/<auto-name>.md` from this conversation, `cp` it to the repo path under your chosen filename (creating `.claude/plans/` if needed). Use `cp`, not `mv` — Claude Code's sandbox typically blocks writes outside the working directory, so deleting the original will fail. The stale copy in `~/.claude/plans/` is harmless (Claude Code overwrites it next time).
   - Otherwise, write the plan from this conversation to that path. Include the original goal at the top of the file.
4. From here on, the repo path is the single source of truth. All edits in later steps target it directly.

## Step 2: Self-critique (up to 3 iterations)

Re-read the plan file and critique it yourself. On each iteration, check for:

- **Completeness**: missing steps, edge cases, or hidden dependencies
- **Correctness**: technical flaws or wrong assumptions about the codebase
- **Clarity**: whether a fresh session could implement it without guessing
- **Scope**: too broad, too narrow, or missing explicit out-of-scope items
- **Order of operations**: whether the steps are sequenced correctly

If you find issues, fix them directly in the plan file.
If an iteration produces no meaningful changes, stop early.

## Step 3: Explore the codebase

Verify the plan against the actual codebase:

- Confirm that referenced files, functions, and interfaces really exist
- Confirm that the planned approach matches real project patterns
- Look for existing utilities or abstractions the implementation should reuse

Update the plan file if any assumptions are wrong.

## Step 4: External review (fresh context)

Run a fresh-context critical review of the plan:

```
claude --print "Read this plan in isolation and review it as a staff engineer. Focus on: architectural fit, technical feasibility, missing edge cases, wrong assumptions, unclear steps, and scope issues. Return your feedback in three sections: Blocking issues, Non-blocking issues, Suggested plan edits. Here is the plan: $(cat .claude/plans/<filename>.md)"
```

## Step 5: Address external feedback

Fix all valid feedback by editing the plan file in place.
If you reject any feedback, explain why briefly in your report.

## Step 6: Final go/no-go check

Run:

```
claude --print "Give a final go/no-go assessment for this implementation plan. Only flag issues that would cause the implementation to fail or go significantly wrong. Return either GO or NO-GO, followed by any critical issues. Here is the plan: $(cat .claude/plans/<filename>.md)"
```

If it comes back clean, declare the plan READY.
If critical issues remain, fix them in the plan file or report them clearly.

## Step 7: Hand off

Tell the user the exact filename to pass into `/flow:implement`.
Recommend they run `/clear` before `/flow:implement` — the plan file is the contract, and a fresh context catches any gaps in what the plan actually specifies.

## Important rules

- Steps 2 and 3 must be done by the current session.
- Steps 4 and 6 must use `claude --print` for a fresh context.
- Do NOT soften the plan to avoid criticism.
- Solve hard problems when possible instead of deleting scope.
