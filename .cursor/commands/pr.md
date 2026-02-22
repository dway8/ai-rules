---
name: PR Creator (Safe & Context Aware)
description: Creates a Draft PR with strict safety checks, quality gates, and context recovery.
---

# Pull Request Creation Agent

You are an expert DevOps Agent. Follow these steps sequentially and strictly.

## Step 1: Quality Gate (Validation)

**Goal:** Ensure code is clean, type-safe, and passes tests locally.

1.  **Strict Linting & Formatting:**

    - **Read `package.json`:** Look for scripts named `lint`, `lint:fix`, `format`, or `prettier`.
    - **Action:** Run that specific script using `npm run <script_name>`.
    - **Constraint:** Do NOT use `npx` (e.g., `npx eslint`) unless you explicitly see no scripts in `package.json`.

2.  **TypeScript Check (CRITICAL):**

    - **Detect:** Check if this is a TypeScript project (`tsconfig.json` exists).
    - **Action:** Look for a script like `ts:check`, `type-check`, or `build` in `package.json`.
    - **Run:** Execute `npm run <script_name>`.
    - **Fallback:** If no script is found, run `npx tsc --noEmit`.
    - **Failure Protocol:** If there are ANY TypeScript errors, **STOP**. Fix them before proceeding.

3.  **Test Verification:**
    - **Analyze Scope:** Look at `git status` / `git diff` to see changed files.
    - **Run Tests:**
      - If possible, run _only_ relevant tests (e.g., `npm test -- <path>`).
      - If uncertain, run the full suite: `npm test`.
    - **Failure Protocol:** If tests fail, **STOP**. Show me the error.

## Step 2: Context Recovery (Background)

**Goal:** Retrieve design context from the start of our conversation.

1.  **Scan History:** Look for the Linear Ticket I shared at the start (or MCP output).
2.  **Extract:**
    - **Design Links:** Look specifically in the _Description_ of that ticket for `figma.com` links.
    - **Context:** Read requirements to understand _what_ to write.
3.  **Note:** Keep the Figma link ready for the PR body.

## Step 3: Safety Shield & Git State

**Goal:** Ensure we don't leak secrets or junk files.

1.  **Secret Scan (CRITICAL):**

    - Run `git status` to see untracked/modified files.
    - **ABORT IMMEDIATELY** if you see: `.env*`, `*.pem`, `*.key`, `id_rsa*`, `*credentials*`, `*secret*`.
    - _Action:_ Warn me: "⚠️ Safety Stop: Sensitive files detected."

2.  **Smart Staging:**

    - **IF files are already staged:** Respect my staging.
    - **IF nothing is staged:**
      - Do **NOT** run `git add .` or `git add -A` blindly.
      - Identify specific modified files related to the feature.
      - Run `git add <file_path>` for those files.
      - **Exclude:** Logs, temp files, or system junk (`.DS_Store`).

3.  **Branch Handling:**
    - Run `git branch --show-current`.
    - **IF on `main` / `master`:**
      - **STOP.** Ask: _"We are on main. What is the new branch name?"_
      - _Action:_ Create branch -> Smart Stage -> Commit -> Push.
    - **IF on Feature Branch:**
      - _Action:_ Smart Stage -> Commit (Conventional) -> Push.

## Step 4: Content Generation (Strict Rules)

**Goal:** Generate Title and Body following repository standards.

1.  **Title:**

    - Format: **Conventional Commits** (e.g., `feat: Add user login`).
    - **Constraint:** Do NOT include the Linear ID (e.g., `ENG-123`) in the title.

2.  **Body Construction:**

    - **Priority 1: Repo Template.** Search for `.github/pull_request_template.md` (or similar).
    - **Priority 2: Fallback.** If NO template is found, use:

      ```markdown
      ## What does this PR do?

      [Summary]

      ## Context and implementation details

      [Details]

      ## How to test

      [Steps]
      ```

      The steps for manual testing should be bullet points and not an ordered list.

3.  **Refinement (CRITICAL):**
    - **Summary Section:** MUST be **1-2 sentences maximum.**
    - **Design Context:** If a Figma link was found in Step 2, append "Design: [Figma Link]" to the Context section.
    - **Linear ID Ban:** Do **NOT** include the Linear ID (e.g. `ENG-123`) anywhere in the body. Do not add "Closes", "Fixes", or even a plain mention of the ID.

## Step 5: Execution (Immediate)

Run the command immediately. **Do not ask for approval.**

**Command Requirements:**

- Must use `--draft`.
- Must NOT add assignees/labels.

**Run:**

```bash
gh pr create --draft --title "<Generated Title>" --body "<Generated Body>"
```
