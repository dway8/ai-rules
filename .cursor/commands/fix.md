---
name: Fix
description: Apply a targeted fix after manual testing, then run focused validation and a lightweight review of the patch.
model: sonnet
---

Fix a bug or issue described by the user, then validate the patch without rerunning the full PR review by default.

The user's description of the problem: $ARGUMENTS

## Step 1: Understand and fix
Read the user's description of the problem.
Investigate the codebase enough to understand the likely root cause.
Fix the issue cleanly rather than patching symptoms when possible.

## Step 2: Run focused validation
Run the smallest relevant validation for the changed area:
- formatting / linting for the affected project
- targeted typecheck/build checks where relevant
- targeted tests where available
- broader tests only if the scope or risk justifies it

## Step 3: Lightweight self-review
Review the patch you just made:
- check for obvious regressions
- check imports and call sites
- check typing, edge cases, and debug leftovers
- check whether the fix matches the reported issue

If you find issues, fix them before proceeding.

## Step 4: Commit and push
Stage the relevant files only.
Commit with a descriptive message such as:
`fix: address issue found in manual testing`
Push the changes.

## Step 5: Escalate only if needed
Only run `/review-loop` if the fix touches a high-risk area such as:
- auth / permissions
- security-sensitive code
- persistence / migrations / data integrity
- shared core abstractions
- larger-than-expected refactors

Otherwise, stop after reporting what was fixed and what validation was run.

## Important rules
- Do NOT rerun the full PR review loop by default for a small targeted fix.
- Validate the changed area properly before pushing.
- If the fix turns out not to be small, escalate to the full review loop.
