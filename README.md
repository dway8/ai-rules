# ai-rules

Personal Claude Code commands for planning, implementing, reviewing, and shipping changes.

Symlink the contents of `commands/` into `~/.claude/commands/` (Claude Code) and/or `~/.cursor/commands/` (Cursor) to make them available globally.

On macOS, from the repo root:

```bash
# Claude Code
mkdir -p ~/.claude/commands
ln -s "$(pwd)/commands"/*.md ~/.claude/commands/

# Cursor
mkdir -p ~/.cursor/commands
ln -s "$(pwd)/commands"/*.md ~/.cursor/commands/
```

This links each command file individually, so existing commands in either directory are left alone. Pulling new versions from this repo updates them in place.

## The standard flow

```
draft plan in plan mode
        │
        ▼
   /plan-review     →  saves plan to .claude/plans/<name>.md
        │
        ▼
      /clear        (fresh context — recommended)
        │
        ▼
/implement <plan>   →  pre-flight, branch, step-by-step commits
        │
        ▼
   /ship-loop       (auto-invoked by /implement)
        │
        ├─ /self-review
        ├─ /pr               →  opens draft PR
        └─ /review-loop      →  iterates until clean, then handles CI
```

Outside this flow: **`/address-pr-comments <PR>`** (originally from [https://github.com/timgent/claude-code-config](https://github.com/timgent/claude-code-config/blob/main/commands/address-pr-comments.md)) — used sporadically when reviewers leave comments.

## Commands

| Command                            | Model  | What it does                                                                 |
| ---------------------------------- | ------ | ---------------------------------------------------------------------------- |
| `/plan-review`                     | opus   | Critiques and refines a plan, saves it to `.claude/plans/`                   |
| `/implement <plan>`                | sonnet | Pre-flight, branches, executes the plan with one commit per step             |
| `/ship-loop`                       | sonnet | Orchestrator: `/self-review` → `/pr` → `/review-loop`                        |
| `/self-review`                     | sonnet | Strict pre-commit review of the current diff (lint, hygiene, correctness)    |
| `/pr`                              | sonnet | Opens a draft PR; pulls Linear + Figma context; Conventional Commits title   |
| `/review-loop`                     | sonnet | Up to 5 iterations of fresh-context review and fix, then handles CI          |
| `/review-pr`                       | opus   | Deep PR reviewer invoked by `/review-loop` via fresh context                 |
| `/address-pr-comments <PR>`        | —      | Atomic per-comment fixes for unresolved review threads                       |

See the individual files in `commands/` for the full prompt of each.

## Loops at a glance

| Loop          | Where                  | Cap          | Purpose                              |
| ------------- | ---------------------- | ------------ | ------------------------------------ |
| Self-critique | inside `/plan-review`  | 3 iterations | tighten the plan before saving       |
| Review / fix  | inside `/review-loop`  | 5 iterations | drive blocking issues to zero        |
| CI fix        | inside `/review-loop`  | 2 attempts   | bounded retry for green CI           |

## Conventions

- Plans live in `.claude/plans/<name>.md` at the repo root.
- Branch names come from the Linear ticket's suggested `branchName` when a ticket is referenced.
- Fresh context (`claude --print`) is used for plan and PR reviews to avoid echo-chamber bias.
- **Multiverse work repos** (origin URL contains `multiverse-io`) stay as draft after CI passes — the user reviews them manually so the Linear ticket doesn't auto-move to "Ready for review".
- Conventional Commits for PR titles; no ticket IDs in title or body.
