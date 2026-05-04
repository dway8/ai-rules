---
name: review-loop
description: Iteratively review and fix the PR with fresh-context reviewers, verify CI is green, then mark ready. Use when the user runs `/flow:review-loop` or asks to "drive this PR to ready", "review and fix until clean", or "loop until CI green".
user-invocable: true
---

Run up to 5 iterations of the following cycle.

## 1. Review (fresh context)

Run a deep review with fresh context:

- `claude --print "/flow:review-pr"`

Collect the output.

## 2. Evaluate

Classify every finding as:

- **Blocking**: bugs, security issues, incorrect behavior, real regressions, missing critical edge cases
- **Non-blocking**: style nits, readability issues, minor refactors, optional improvements

For every non-blocking item, explicitly decide whether it should be:

- **Fixed now**
- **Deferred**

Default to fixing non-blocking issues unless:

- the change is purely stylistic and would create unnecessary churn
- the suggestion is subjective or low-confidence
- the fix would expand scope disproportionately

If there are no blocking issues:

- fix any remaining non-blocking issues marked **Fixed now**
- run a final sanity pass with the built-in reviewer: `claude --print "/review"` — apply the same triage (fix blocking; fix non-blocking marked Fixed now)
- run `/flow:self-review`
- commit and push if needed
- proceed to step 7 (CI verification)

## 3. Fix

Fix all blocking issues.

Also fix all non-blocking issues marked **Fixed now**.

For any non-blocking issue you defer, briefly explain why before proceeding.
Do not silently ignore non-blocking feedback.

Do not delegate the fixes to a fresh context.

## 4. Self-review before commit

Run `/flow:self-review`.
If it finds blocking issues, fix them before continuing.

## 5. Commit and push

Stage the relevant changes, commit with:
`fix: address review feedback (iteration N)`
Then push.

## 6. Repeat

Repeat from step 1 until:

- there are no blocking issues, or
- 5 iterations have been completed

## 7. CI verification

Once review iterations have settled with no blocking issues:

1. Wait for CI to finish: `gh pr checks --watch`.
2. Detect whether this is a Multiverse work repo: run `git remote get-url origin` and check whether the URL contains `multiverse-io` (case-insensitive). If it does, the PR must NOT be marked ready — the user reviews these manually so the linked Linear ticket does not move to "Ready for review" prematurely.
3. If all checks pass:
   - **Multiverse repo**: leave the PR as draft, surface the green CI status to the user, and tell them it is ready for their manual review. Stop.
   - **Any other repo**: mark the PR ready with `gh pr ready` and stop.
4. If checks fail:
   - inspect the failing job's logs (`gh run view <run-id> --log-failed`)
   - if the failure looks fixable in code (lint, type, test), fix it, run `/flow:self-review`, commit, push, then re-watch checks
   - cap at 2 fix attempts. If checks are still failing after 2 attempts, stop and surface the failures to the user — do NOT mark the PR ready
   - if the failure is infrastructural (flake, secrets, runner issues), do not attempt fixes — surface to the user

## Important rules

- Reviewer must use `claude --print` for fresh context.
- Do not relabel blocking issues as non-blocking just to finish faster.
- Do not silently ignore non-blocking feedback.
- Non-blocking issues alone should not force another iteration.
- If blocking issues remain after 5 iterations, stop and summarize what remains unresolved.
- Never mark the PR ready while CI is failing.
- Never mark a Multiverse repo PR ready — leave it as draft for manual review.
