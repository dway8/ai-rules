# ai-rules

Plan-driven engineering workflow for Claude Code, packaged as a plugin (`flow`): plan → implement → review → ship.

Each skill is a self-contained procedure under `skills/<name>/SKILL.md`. Some skills (like `review-pr`) fan out to specialized agents in `agents/<name>.md` that run in parallel. The plugin also bundles a hook that injects worktree guidance into `/flow:implement`.

## Install

Clone this repo, then load it as a Claude Code plugin. Two options:

**One-shot for the current session:**

```bash
claude --plugin-dir /path/to/ai-rules
```

**Persistent: register as a local marketplace, then install once.**

```bash
# inside any Claude Code session
/plugin marketplace add /path/to/ai-rules
/plugin install flow
```

After installing, all skills are namespaced under `/flow:` — e.g. `/flow:plan-review`, `/flow:self-review`. Run `/flow` in the slash menu to see the full list.

> **Migrating from the old symlink setup?** Remove the old per-file symlinks before enabling the plugin to avoid duplicate slash entries:
>
> ```bash
> rm ~/.claude/commands/{address-pr-comments,implement,plan-review,pr,review-loop,review-pr,self-review,ship-loop}.md 2>/dev/null
> rm ~/.claude/skills/{address-pr-comments,implement,plan-review,pr,review-loop,review-pr,self-review,ship-loop} 2>/dev/null
> rm ~/.claude/agents/{correctness-reviewer,maintainability-reviewer,security-reviewer}.md 2>/dev/null
> ```
>
> Also remove the equivalent `UserPromptSubmit` worktree hook from `~/.claude/settings.json` if you added it — the plugin ships its own copy.

## The standard flow

```
draft plan in plan mode
        │
        ▼
   /flow:plan-review     →  saves plan to .claude/plans/<name>.md
        │
        ▼
      /clear             (fresh context — recommended)
        │
        ▼
/flow:implement <plan>   →  pre-flight, branch, step-by-step commits
        │
        ▼
   /flow:ship-loop       (auto-invoked by /flow:implement)
        │
        ├─ /flow:self-review
        ├─ /flow:pr               →  opens draft PR
        └─ /flow:review-loop      →  iterates until clean, then handles CI
```

Outside this flow: **`/flow:address-pr-comments <PR>`** (originally adapted from [https://github.com/timgent/claude-code-config](https://github.com/timgent/claude-code-config/blob/main/commands/address-pr-comments.md)) — used sporadically when reviewers leave comments.

## Commands

| Command                            | Model  | What it does                                                                 |
| ---------------------------------- | ------ | ---------------------------------------------------------------------------- |
| `/flow:plan-review`                | opus   | Critiques and refines a plan, saves it to `.claude/plans/`                   |
| `/flow:implement <plan>`           | sonnet | Pre-flight, branches, executes the plan with one commit per step             |
| `/flow:ship-loop`                  | sonnet | Orchestrator: `/flow:self-review` → `/flow:pr` → `/flow:review-loop`         |
| `/flow:self-review`                | sonnet | Strict pre-commit review of the current diff (lint, hygiene, correctness)    |
| `/flow:pr`                         | sonnet | Opens a draft PR; pulls Linear + Figma context; Conventional Commits title   |
| `/flow:review-loop`                | sonnet | Up to 5 iterations of fresh-context review and fix, then handles CI          |
| `/flow:review-pr`                  | opus   | Deep PR reviewer invoked by `/flow:review-loop` via fresh context            |
| `/flow:address-pr-comments <PR>`   | —      | Atomic per-comment fixes for unresolved review threads                       |

The `Model` column is enforced by `model:` frontmatter on each skill — invoking the command switches the model for that turn and reverts to the session model on the next prompt.

See the individual files in `skills/<name>/SKILL.md` for the full prompt of each.

## Loops at a glance

| Loop          | Where                       | Cap          | Purpose                              |
| ------------- | --------------------------- | ------------ | ------------------------------------ |
| Self-critique | inside `/flow:plan-review`  | 3 iterations | tighten the plan before saving       |
| Review / fix  | inside `/flow:review-loop`  | 5 iterations | drive blocking issues to zero        |
| CI fix        | inside `/flow:review-loop`  | 2 attempts   | bounded retry for green CI           |

## Status line

`scripts/statusline.sh` is a two-line Claude Code status line: project + branch + model on top, context-usage bar + elapsed session time + lines added/removed (only when non-zero) underneath.

![status line example](scripts/statusline-example.png)

The status line is **not** part of the plugin — Claude Code's plugin `settings.json` doesn't accept a `statusLine` key. Wire it up manually instead:

```bash
ln -s "$(pwd)/scripts/statusline.sh" ~/.claude/statusline-command.sh
```

```json
"statusLine": {
  "type": "command",
  "command": "bash ~/.claude/statusline-command.sh"
}
```

## Conventions

- Plans live in `.claude/plans/<name>.md` at the repo root.
- Branch names come from the Linear ticket's suggested `branchName` when a ticket is referenced.
- Fresh context (`claude --print`) is used for plan and PR reviews to avoid echo-chamber bias.
- **Multiverse work repos** (origin URL contains `multiverse-io`) stay as draft after CI passes — the user reviews them manually so the Linear ticket doesn't auto-move to "Ready for review".
- Conventional Commits for PR titles; no ticket IDs in title or body.
