---
name: Plan Review
description: Critique and strengthen a plan before implementation.
model: opus
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

## Step 3: External review (fresh context)
Run a fresh-context critical review of the plan with:

`claude --print "Read this plan in isolation and review it as a staff engineer. Focus on: architectural fit, technical feasibility, missing edge cases, wrong assumptions, unclear steps, and scope issues. Return your feedback in three sections: Blocking issues, Non-blocking issues, Suggested plan edits. Here is the plan: $(cat <plan_file_or_location>)"`

If the plan is only in the conversation, copy it into the command.

## Step 4: Address external feedback
Fix all valid feedback.
If you reject any feedback, explain why briefly in your report.

## Step 5: Final go/no-go check
Run:

`claude --print "Give a final go/no-go assessment for this implementation plan. Only flag issues that would cause the implementation to fail or go significantly wrong. Return either GO or NO-GO, followed by any critical issues. Here is the plan: <plan>"`

If it comes back clean, declare the plan READY.
If critical issues remain, report them clearly.

## Step 6: Save the plan
Write the final version of the plan to `.claude/plans/` at the root of the repo with a descriptive filename.
Create the directory if needed.
Include the original goal at the top of the file.
Tell the user the exact filename to pass into `/implement`.

## Important rules
- Steps 1 and 2 must be done by the current session.
- Steps 3 and 5 must use `claude --print` for a fresh context.
- Do NOT soften the plan to avoid criticism.
- Solve hard problems when possible instead of deleting scope.
