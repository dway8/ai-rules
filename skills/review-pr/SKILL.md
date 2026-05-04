---
name: review-pr
description: Performs a deep review of the current branch diff via three specialized reviewers running in parallel — security, correctness, maintainability. Use when the user runs `/flow:review-pr` or asks to "do a staff-level review", "review this PR thoroughly", or "check the diff for blocking issues".
user-invocable: true
model: opus
---

# /flow:review-pr — multi-reviewer fan-out

Review the diff between `main` (or `master`) and the current `HEAD` by launching three specialized reviewers in parallel, then consolidate their reports.

## Step 1: Pre-checks

- Run `git rev-parse --verify main 2>/dev/null || git rev-parse --verify master` to detect the base branch.
- Run `git diff <base>...HEAD --stat` to confirm a diff exists. If empty, abort with a one-line note: `No changes to review against <base>.`

## Step 2: Fan out (single message, three parallel Agent calls)

Issue all three Agent tool calls in ONE message so they run in parallel:

- subagent_type: `security-reviewer`,        prompt: `Review the diff between <base> and the current HEAD.`
- subagent_type: `correctness-reviewer`,     prompt: `Review the diff between <base> and the current HEAD.`
- subagent_type: `maintainability-reviewer`, prompt: `Review the diff between <base> and the current HEAD.`

The agents are tool-restricted to read-only access; they cannot modify files.

## Step 3: Consolidate

Synthesize the three reports into the unified output below.

- Omit any section with no findings — do not pad with "N/A" or "none".
- Always include the Quality Dashboard, Severity Counts, and Verdict.
- Do not relabel Blocking findings as Non-blocking, and vice versa, when consolidating.
- Do not relax the ≥80 confidence threshold during consolidation.

### 🛡️ Security & Safety

[Blocking and Non-blocking cards from `security-reviewer`]

### 🐛 Correctness & Contracts

[Blocking and Non-blocking cards from `correctness-reviewer`]

### 🧶 Maintainability & Architecture

[Blocking and Non-blocking cards from `maintainability-reviewer`]

### 📊 Quality Dashboard

- **Complexity**: High / Medium / Low — from `maintainability-reviewer`
- **Architectural fit**: Good / Questionable / Poor — from `maintainability-reviewer`
- **Shared source of truth**: Good / At risk / Missing — from `correctness-reviewer`
- **Tests**: Present / Missing / Inadequate — from `maintainability-reviewer`

### 📋 Severity Counts

| Severity     | Count | Status     |
|--------------|-------|------------|
| Blocking     | N     | block / ok |
| Non-blocking | M     | note       |

### 💡 Verdict

- **Decision:** Approve / Block / Discuss
- **One-line summary:** ...

## Important rules

- Reviewers must run in parallel — issue all three Agent calls in a single message, not sequentially.
- The orchestrator must not edit code; this is a read-only review.
- Confidence threshold ≥80 is enforced inside each agent — do not relax it during consolidation.
- Omit empty sections in the consolidated output.
