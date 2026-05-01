---
name: plan-review
description: Critique and strengthen a plan before implementation. Use when the user runs `/plan-review` or asks to "review my plan", "tighten the plan", "save and harden this plan", or finishes drafting a plan in plan mode.
user-invocable: true
---

Review and refine the plan that was just written in this conversation. Do the following steps sequentially. After each step, report what you did.

## Step 1: Self-critique (up to 3 iterations)

Re-read the plan and critique it yourself. On each iteration, check for:

- **Completeness**: missing steps, edge cases, or hidden dependencies
- **Correctness**: technical flaws or wrong assumptions about the codebase
- **Clarity**: whether a fresh session could implement it without guessing
- **Scope**: too broad, too narrow, or missing explicit out-of-scope items
- **Order of operations**: whether the steps are sequenced correctly

If you find issues, fix them directly in the plan.
If an iteration produces no meaningful changes, stop early.

## Step 2: Explore the codebase

Verify the plan against the actual codebase:

- Confirm that referenced files, functions, and interfaces really exist
- Confirm that the planned approach matches real project patterns
- Look for existing utilities or abstractions the implementation should reuse

Update the plan if any assumptions are wrong.

## Step 3: Save the plan as a draft

Write the current plan to `.claude/plans/<descriptive-name>.md` at the root of the repo.
Create the directory if needed.
Include the original goal at the top of the file.

This file is the source of truth for the remaining steps — subsequent edits update it in place.

## Step 4: External review (fresh context)

Run a fresh-context critical review of the plan:

```
claude --print "Read this plan in isolation and review it as a staff engineer. Focus on: architectural fit, technical feasibility, missing edge cases, wrong assumptions, unclear steps, and scope issues. Return your feedback in three sections: Blocking issues, Non-blocking issues, Suggested plan edits. Here is the plan: $(cat .claude/plans/<descriptive-name>.md)"
```

## Step 5: Address external feedback

Fix all valid feedback by editing the plan file in place.
If you reject any feedback, explain why briefly in your report.

## Step 6: Final go/no-go check

Run:

```
claude --print "Give a final go/no-go assessment for this implementation plan. Only flag issues that would cause the implementation to fail or go significantly wrong. Return either GO or NO-GO, followed by any critical issues. Here is the plan: $(cat .claude/plans/<descriptive-name>.md)"
```

If it comes back clean, declare the plan READY.
If critical issues remain, fix them in the plan file or report them clearly.

## Step 7: Hand off

Tell the user the exact filename to pass into `/implement`.
Recommend they run `/clear` before `/implement` — the plan file is the contract, and a fresh context catches any gaps in what the plan actually specifies.

## Important rules

- Steps 1 and 2 must be done by the current session.
- Steps 4 and 6 must use `claude --print` for a fresh context.
- Do NOT soften the plan to avoid criticism.
- Solve hard problems when possible instead of deleting scope.
