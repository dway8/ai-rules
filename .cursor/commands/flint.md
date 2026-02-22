---
name: Logic Linter
description: Scans for common AI hallucinations and logical "smells".
---

# Logic Check Protocol

Review the last set of changes for these specific "AI smells":

1.  **The "Happy Path" Bias:** Did we handle the `null`, `undefined`, or `error` states?
2.  **The "Import Hallucination":** Are we importing functions that _don't actually exist_ or are named slightly differently? (Check actual file exports).
3.  **The "Silent Fail":** Are we catching errors but just logging them (`console.log`) instead of throwing or handling them?
4.  **The "Type Lie":** Did we use `as any` or `!` just to make TypeScript shut up?

**Output:**

- List any violations found.
- If clean, reply with "✨ Clean".
