---
name: self-review
description: Review the current diff for correctness, safety, and obvious hygiene issues before committing. Use when the user runs `/flow:self-review` or asks to "check this before commit", "do a quick pre-commit review", or "lint and sanity check the diff".
user-invocable: true
---

Act as a strict senior engineer reviewing the current changes before commit.

## Step 1: Repo-native checks

Use the repo's own scripts where available.

- Check `package.json` files relevant to the changed code
- Run the appropriate format and/or lint scripts for the affected project(s)
- Run targeted typecheck or build validation where relevant
- Use the repo scripts over ad hoc formatting/linting commands

Do not run the full world unless the repo structure or change scope makes that necessary.

## Step 2: Hygiene pass

Check for:

- `console.log`, debug prints, commented-out code, stale TODOs
- obviously poor variable names like `data`, `item`, `temp` where clearer names are warranted
- broken or unused imports introduced by the change

## Step 3: Correctness and impact pass

Check for:

- changed function signatures without updated callers
- missing edge-case handling
- unsafe casts / loose typing
- obvious security mistakes
- obvious performance footguns introduced by the diff

## Step 4: Report

If the diff looks good, say:

`✅ LGTM`

If issues exist, report them under:

- **🚨 Blocking**
- **🧹 Hygiene**
- **💡 Refactor**
