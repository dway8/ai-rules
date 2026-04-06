---
name: Feedback Loop
description: Run the lightweight post-implementation sequence: self-review, PR creation, then review loop.
model: sonnet
---

Do the following sequentially. After each step, report what you did.

## Step 1: Self-review
Run `/self-review` and fix any blocking issues found before proceeding.

## Step 2: Create the PR
Run `/pr` to create the draft pull request.

## Step 3: Review loop
Run `/review-loop` to iteratively review and fix the PR until it is ready.

## Important rules
- This command is an orchestrator. Keep progress updates concise.
- Do not duplicate heavy validation if a previous step already completed it successfully.
