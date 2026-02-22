---
name: Self-Review (Staff Level)
description: rigorously critiques the current file/selection for logic, security, and hygiene before committing.
---

# Pre-Commit Code Review

Act as a **Principal Engineer**. I am about to commit this code. Your job is to stop me from pushing anything embarrassing, insecure, or broken.

## Phase 1: The "Hygiene" Pass (Self-Correction)

**Goal:** Catch the "lazy" mistakes I missed.

1.  **Auto-Format:**
    - Check `package.json` for a `format` or `lint:fix` script.
    - Run it via `npm run <script>` to ensure the code style matches the repo.
    - **Do not** use `npx` commands that might conflict with local dev dependencies.
2.  **Leftovers:** Scan for `console.log`, `print()`, commented-out blocks, or `TODO` comments that should be resolved now.
3.  **Naming:** Are variables named `data`, `item`, or `temp`? **Flag them.** They must be descriptive (e.g., `userProfile`, `activeItem`).
4.  **Formatting:** Does this match the project's likely style (indentation, semi-colons)?
5.  **Types:** Am I using `any` (TS) or unstructured dictionaries (Python) where I should use a defined type/interface?

## Phase 2: The "Shield" Pass (Security & Performance)

**Goal:** Ensure I am not introducing vulnerabilities.

1.  **Security:**
    - **Input:** Am I passing raw user input to a DB or DOM?
    - **Secrets:** Did I hardcode an API key or token?
    - **Authorization:** Did I forget to check `if (!user.isAdmin)`?
2.  **Performance:**
    - **Loops:** Am I doing database queries or expensive computations inside a loop? (O(n^2)).
    - **Memoization:** Should this value be cached/memoized?

## Phase 3: The "Agent" Pass (Impact Analysis)

**Goal:** Ensure I didn't break the rest of the app.

1.  **Context Check:** If I changed a function signature, search the codebase: **Did I update the callers?**
2.  **Import Check:** Check my imports. Do the files I'm importing actually export what I think they do?

## Phase 4: The Report

Output a strict report. **If the code is good, just say "✅ LGTM" and list 1 highlight.**

**If issues exist:**

- **🚨 Blocking:** (Security, Bugs, Broken Imports)
- **🧹 Hygiene:** (Naming, Comments, Logs)
- **💡 Refactor:** (Performance, Readability suggestions)
