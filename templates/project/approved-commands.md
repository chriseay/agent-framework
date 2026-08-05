# Approved Commands

<!-- Project-owned subdocument (unlike bash-permission-rules.md, this one is yours to customize). Fill in the [placeholder] rows with your project's actual domain-specific commands — the tier structure itself is the reusable part; the examples need to reflect what this project actually does. -->

A three-tier model for which commands an agent can run without stopping to ask, which need approval, and which are never allowed without explicit instruction. This exists to reduce unnecessary approval-prompt friction on genuinely safe actions while keeping a hard stop on genuinely risky ones — see `CLAUDE.md`'s own Approval Gates and Git Safety sections for the framework-wide baseline this extends.

## Tier 1: No approval needed

Read-only or trivially reversible. Safe to run without asking.

- `git status`, `git log`, `git diff`, `git branch` (listing, not creating/deleting)
- File reads (`Read`, `Grep`, `Glob`) — never require approval regardless of what they touch
- `curl`/API calls that are read-only (GET requests, no side effects)
- [Project-specific read-only commands — e.g. a status-check script, a linter run in check-only mode]

## Tier 2: Approval required

State-changing but not destructive. Confirm via `AskUserQuestion` with the About to/Why/Affects format before running.

- `git commit`, `git push` (non-force), `git merge`
- Editing configuration or infrastructure files
- `curl`/API calls with side effects (POST, PUT, PATCH, DELETE against a live system)
- [Project-specific state-changing commands — e.g. deploying to staging, writing to a live database, SSH to a remote host]

## Tier 3: Never without explicit instruction

Destructive or hard to reverse. Do not run these based on inferred intent, even with a Tier 2 approval already granted for a related action — each one needs its own explicit ask.

- `git push --force`, `git reset --hard`, `git rebase`, `git branch -D`, `git checkout .`, `git restore .`, `git clean -f`
- `rm -rf`
- Direct edits to `CLAUDE.md` without going through the normal review flow
- [Project-specific destructive commands — e.g. direct production config edits, dropping a database table, force-pushing to a shared branch]
