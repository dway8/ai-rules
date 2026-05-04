---
name: pr
description: Creates a Draft PR with safety checks, smart staging, and context-aware PR content. Use when the user runs `/flow:pr` or asks to "open a PR", "create a draft PR", or "push this and open a PR".
user-invocable: true
---

# Pull Request Creation Agent

You are an expert engineering workflow agent. Follow these steps sequentially and strictly.

## Step 1: Context recovery

Retrieve ticket and design context for the PR body.

1. Look for a Linear ticket reference in the current branch name, recent commit messages, or the conversation. Branch names often contain it (e.g. `dim-1234-fix-foo`).
2. If a Linear ticket is found, use the Linear MCP (`mcp__claude_ai_Linear__get_issue`) to fetch the ticket. Read the description and attachments for any Figma URL.
3. If a Figma URL is found, use the Figma MCP (`mcp__plugin_figma_figma__get_design_context` or `mcp__plugin_figma_figma__get_metadata`) to pull design context useful for the PR body.

Keep the design link ready for Step 4. Do not block PR creation on missing design context — note its absence and continue.

## Step 2: Safety shield and git state

1. Run `git status`
2. Abort immediately if you see suspicious sensitive files such as:
   - `.env*`
   - `*.pem`
   - `*.key`
   - `id_rsa*`
   - `*credentials*`
   - `*secret*`

If found, stop and warn the user.

3. Smart staging:

   - if files are already staged, respect that
   - otherwise, stage only the files relevant to the current change
   - do not use `git add .` or `git add -A` blindly
   - exclude junk files such as `.DS_Store`, logs, temp files

4. Branch handling:
   - run `git branch --show-current`
   - if on `main` or `master`, stop and ask for a branch name
   - otherwise continue

## Step 3: Commit and push state sanity

Check whether the current change set is ready to be turned into a PR:

- confirm there are committed changes for the work
- if the branch is not pushed yet, push it

Do not rerun a full local CI suite here unless no prior validation has been performed.

## Step 4: Generate title and body

### Title

- Use Conventional Commits style: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`, etc.
- Describe the overall change, not the most recent commit. Look at all commits between this branch and `main` and synthesize a single high-level summary.
- Keep under 70 characters.
- Do NOT include ticket IDs in the title.

### Body

Priority 1: repo PR template

Priority 2: fallback template:

```markdown
## What does this PR do?

[Summary]

## Context and implementation details

[Details]

## How to test

- [Manual test steps]
```

Rules:

- Summary must be 1–2 sentences max
- If a design link was found, append `Design: [link]` in the context section
- Do NOT include ticket IDs anywhere in the body

## Step 5: Create the PR

Run immediately:

```bash
gh pr create --draft --title "<Generated Title>" --body "<Generated Body>"
```

Do not add assignees or labels.
