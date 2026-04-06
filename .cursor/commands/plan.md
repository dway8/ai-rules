---
name: Plan
description: Explore the codebase, ask the right questions, and produce a concrete implementation plan.
model: opus
---

Create an implementation plan for the feature described by the user.

The user's description: $ARGUMENTS

## Step 1: Explore the codebase
Before asking questions or writing the plan, explore the parts of the codebase relevant to this feature. Understand:
- The existing architecture and patterns used in the project
- How similar features have been implemented before
- What files, modules, and interfaces will be involved
- What tests exist and how they're structured

Be concrete. Use actual files, functions, and interfaces from the codebase rather than assumptions.

## Step 2: Clarify
Based on your exploration, ask only the questions that are genuinely needed to produce a correct plan.

Separate them into:

### Clarifications
Ask only about decisions that are ambiguous or materially affect the implementation:
- Scope
- Edge-case behavior
- Constraints
- Major design choices where multiple valid approaches exist

When possible, make a reasonable default assumption instead of asking. Keep assumptions explicit.

### Suggestions
Offer concise proactive suggestions the user may not have considered:
- UX implications
- Empty/error/loading states
- Accessibility or consistency concerns
- Interactions with adjacent features

For each suggestion, explain in one sentence why it matters.

Ask everything at once rather than one at a time.

## Step 3: Write the plan
Once you have enough information, write a detailed implementation plan with:

- **Goal**: one sentence summary of what this feature does
- **Assumptions**: any defaults you are relying on
- **Steps**: numbered, ordered steps
- **Edge cases**: list the important edge cases and how each one is handled
- **Testing**: what tests should be added or changed

Keep the plan concrete:
- Reference actual files, functions, modules, and interfaces
- Make each step small enough that it could be implemented in a logical commit
- Avoid vague instructions like "update the backend"

## Step 4: User confirmation
Present the plan to the user and ask if they want any changes before implementation.

## Important rules
- Do NOT skip codebase exploration.
- Do NOT start writing code.
- Ask questions before writing the plan only when they are truly needed.
- Prefer explicit assumptions over excessive questioning.
