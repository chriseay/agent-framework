# AGENTS.md

This file is automatically loaded at the start of every Codex CLI session. Detailed step-by-step rules are in the `skills/` directory — read the relevant skill file before executing any phase.

## Session Start

**On every new session**, immediately:
1. Read `.workflow/state.md`
2. Read `PROJECT.md` and `ROADMAP.md` (if they exist)
3. If mid-phase, read the relevant `planning/phase-XX/` artifacts
4. Present this status block to the user:

```
Phase: [number] — [name]
Step:  [current workflow step]
Model: [tier] ([model name])
Next:  [next phase command to run]
```

5. Ask the user to confirm the status is accurate before proceeding.

If `.workflow/state.md` says the next command is `/new-project`, check whether the project already has code:
- **No existing code**: Tell the user: "No project set up yet. Ask me to run /new-project to get started."
- **Existing codebase**: Tell the user: "Existing code detected but no project docs. Ask me to run /onboard to scan the codebase and set up the workflow."

## Core Rules

These are always active regardless of which workflow step you're in.

### Workflow

```
/discuss → /research → /plan → /implement → /test → /close-out
```

Do not skip steps. When the user asks to run a phase, read the corresponding file from `skills/` first:
- `/discuss` → read `skills/discuss.md`
- `/research` → read `skills/research.md`
- `/plan` → read `skills/plan.md`
- `/implement` → read `skills/implement.md`
- `/test` → read `skills/test.md`
- `/close-out` → read `skills/close-out.md`

Other commands: `/new-project` → `skills/new-project.md`, `/onboard` → `skills/onboard.md`, `/retro` → `skills/retro.md`, `/status` → `skills/status.md`, `/help` → `skills/help.md`, `/issues` → `skills/issues.md`.

### Always Apply

- Ask the user **one question at a time** — never batch questions.
- Never add scope during implementation — defer new requirements to `ROADMAP.md`.
- Try **one fix** then escalate — never brute-force through repeated failures.
- When in doubt, **ask the user**.

### Approval Gates

These actions **always require explicit user approval**: commits, pushes, merges, branch creation/deletion, builds/tests, edits to `AGENTS.md`, phase transitions, destructive actions. Reading files does not require approval.

Before requesting approval, show a brief summary of what will happen and why.

### Git Safety

These commands are **never allowed** without explicit user approval: `git push --force`, `git reset --hard`, `git rebase`, `git branch -D`, `git checkout .`, `git restore .`, `git clean -f`.

### Conflict Resolution

Process rules in `AGENTS.md` take precedence over `PROJECT.md`. Project-specific technical rules in `PROJECT.md` override general guidance. If unclear, stop and ask.

### Model Routing

The framework uses **model tiers** to route phases to appropriately-sized models:

| Tier | Claude Model | Codex Model | Purpose |
|------|-------------|-------------|---------|
| heavy | Opus | gpt-5.3-codex | Architecture, code generation, complex reasoning |
| standard | Sonnet | gpt-5-codex-mini | Investigation, testing, summarisation |
| light | Haiku | gpt-5-codex-mini | Conversational Q&A, simple lookups |
| codex | — | gpt-5.3-codex | Mechanical subtasks (via `codex-dispatch.sh`) |

Each skill file declares its tier in its On Start section. The agent resolves the tier as follows:

1. **Detect current model**: In Codex CLI, the model is set via `~/.codex/config.toml` or the `-m` flag. Note which model is active.
2. **Look up phase tier**: Read the skill file's `Model tier:` annotation.
3. **Check for overrides**: If `PROJECT.md` has a "Model Routing" section, use those overrides instead of defaults.
4. **Show in status block**: Display the tier and model name in the `Model:` line.

**Confirmation mode** (default): Show the tier in the status block as a brief inline note. The user can override by requesting a different tier.

If `PROJECT.md` sets `auto-routing: yes`, skip confirmation and proceed with the recommended tier automatically.

## Documents

| Document | Purpose |
|----------|---------|
| `AGENTS.md` | Core rules, always loaded |
| `PROJECT.md` | Project-specific constraints, tech stack, lessons learned |
| `ROADMAP.md` | Phases, deliverables, status, deferred actions |
| `planning/phase-XX/` | Per-phase artifacts (CONTEXT, RESEARCH, PLAN, POSTMORTEM) |
| `.workflow/state.md` | Current position in the workflow (auto-updated by commands) |
| `skills/` | Detailed rules for each workflow command |

## Language

Use New Zealand English by default. Users may override during project setup or at any time.
