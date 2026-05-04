---
name: implement
description: Execute an approved plan step by step, with small commits and targeted validation. Use when the user runs `/flow:implement <plan>` or asks to "execute the plan", "implement the plan in .claude/plans/...", or "start working on this plan".
user-invocable: true
---

Read the plan from the file specified by the user: `$ARGUMENTS`. If no argument was provided, look for `.md` files in `.claude/plans/` and ask the user which one to use if there are multiple.

Do the following sequentially. After each step, report what you did.

## Step 1: Read and understand the plan

Read `$ARGUMENTS`.
If the plan is ambiguous or clearly wrong based on the codebase, stop and ask the user before proceeding.

## Step 2: Pre-flight checks

Before making any changes:

1. Run `git status`. The working tree must be clean — no uncommitted or unstaged changes. If it isn't, stop and ask the user how to proceed.
2. Run `git branch --show-current`. If on `main` or `master`, create a feature branch:
   - Look for a Linear ticket reference in the plan file or the conversation.
   - If a Linear ticket is found, fetch it with the Linear MCP (`mcp__claude_ai_Linear__get_issue`) and use the `branchName` field from the response as the branch name — this matches the branch name suggested in the Linear UI.
   - If no Linear ticket is found, derive a descriptive branch name from the plan.
   - Switch to the new branch before continuing.

## Step 3: Implement step by step

Follow the plan in order.

For each step:

1. Implement the changes described
2. Run the smallest relevant validation you can:
   - targeted lint/typecheck/test when possible
   - broader checks only when necessary
3. Commit with a descriptive message referencing the step
   - example: `feat: step 2 — add user validation endpoint`

Do NOT batch the whole plan into one big commit.

## Step 4: Final verification

Once all steps are complete:

- Run the appropriate broader validation for the changed areas
- Run the main test suite if appropriate for the repo and scope of the change
- Sanity-check that the implementation still matches the plan
- Fix any issues found

## Step 5: Launch ship loop

Run `/flow:ship-loop`.

## Important rules

- Follow the plan.
- If you think the plan is wrong, stop and ask rather than silently deviating.
- Prefer targeted checks during implementation over rerunning the entire repo after every small step.
