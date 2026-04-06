---
name: Review Loop
description: Run iterative PR review using fresh-context reviewers, fix issues, and stop when no blocking issues remain.
model: sonnet
---

Run up to 5 iterations of the following cycle:

## 1. Review (fresh context, both reviewers in parallel)
Run BOTH of these in parallel:
- `claude --print "/review"`
- `claude --print "/review-pr"`

Collect both outputs.

## 2. Evaluate
Analyze both outputs together and classify every finding as:
- **Blocking**: bugs, security issues, incorrect behavior, real regressions, missing critical edge cases
- **Non-blocking**: style nits, readability issues, minor refactors, optional improvements

For every non-blocking item, explicitly decide whether it should be:
- **Fixed now**
- **Deferred**

Default to fixing non-blocking issues unless:
- the change is purely stylistic and would create unnecessary churn
- the suggestion is subjective or low-confidence
- the fix would expand scope disproportionately

If there are no blocking issues across both reviews:
- fix any remaining non-blocking issues marked **Fixed now**
- run `/self-review`
- commit and push if needed
- mark the PR ready with `gh pr ready`
- stop

## 3. Fix
Fix all blocking issues.

Also fix all non-blocking issues marked **Fixed now**.

For any non-blocking issue you defer, briefly explain why before proceeding.
Do not silently ignore non-blocking feedback.

Do not delegate the fixes to a fresh context.

## 4. Self-review before commit
Run `/self-review`.
If it finds blocking issues, fix them before continuing.

## 5. Commit and push
Stage the relevant changes, commit with:
`fix: address review feedback (iteration N)`
Then push.

## 6. Repeat
Repeat from step 1 until:
- there are no blocking issues, or
- 5 iterations have been completed

## Important rules
- Reviewers must use `claude --print` for fresh context.
- Do not relabel blocking issues as non-blocking just to finish faster.
- Do not silently ignore non-blocking feedback.
- Non-blocking issues alone should not force another iteration.
- If blocking issues remain after 5 iterations, stop and summarize what remains unresolved.
