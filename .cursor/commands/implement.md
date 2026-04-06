---
name: Implement
description: Execute an approved plan step by step, with small commits and targeted validation.
model: sonnet
---

Read the plan from the file specified by the user: `$ARGUMENTS`. If no argument was provided, look for `.md` files in `.claude/plans/` and ask the user which one to use if there are multiple.

Do the following sequentially. After each step, report what you did.

## Step 1: Read and understand the plan
Read `$ARGUMENTS`. Before writing code, summarize:
- The goal
- The implementation steps you will follow
- Dependencies between steps
- Any assumptions or risks worth tracking

If the plan is ambiguous or clearly wrong based on the codebase, stop and ask the user before proceeding.

## Step 2: Implement step by step
Follow the plan in order.

For each step:
1. Implement the changes described
2. Run the smallest relevant validation you can:
   - targeted lint/typecheck/test when possible
   - broader checks only when necessary
3. Commit with a descriptive message referencing the step
   - example: `feat: step 2 — add user validation endpoint`

Do NOT batch the whole plan into one big commit.

## Step 3: Final verification
Once all steps are complete:
- Run the appropriate broader validation for the changed areas
- Run the main test suite if appropriate for the repo and scope of the change
- Sanity-check that the implementation still matches the plan
- Fix any issues found

## Step 4: Launch feedback loop
Run `/feedback-loop`.

## Important rules
- Follow the plan.
- If you think the plan is wrong, stop and ask rather than silently deviating.
- Prefer targeted checks during implementation over rerunning the entire repo after every small step.
- If the context window gets too large:
  - commit all current work
  - write progress to `.claude/plans/.progress`
  - tell the user to clear context and rerun `/implement` with the same plan
