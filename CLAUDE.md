# CLAUDE.md

This file is automatically loaded at the start of every session. Detailed step-by-step rules are in the `skills/` directory and loaded by each workflow command.

## Session Start

**On every new session**, immediately:
1. Read `.workflow/state.md`
2. Read `PROJECT.md` and `ROADMAP.md` (if they exist)
3. If mid-phase, read the relevant `planning/phase-XX/` artifacts
4. Present this status block to the user:

```
Phase:    [number] — [name]
Step:     [current workflow step]
Subphase: N of M (only if in a subphase cycle)
Model:    [tier] ([model name])
Next:     type `/[next command]` to continue
```

Omit the `Subphase` line entirely when not in a subphase cycle.

5. Use `AskUserQuestion` to confirm the status is accurate before proceeding.

If `.workflow/state.md` says the next command is `/new-project`, check whether the project already has code:
- **No existing code**: Tell the user: "No project set up yet. Type `/new-project` to get started."
- **Existing codebase**: Tell the user: "Existing code detected but no project docs. Type `/onboard` to scan the codebase and set up the workflow."

## Core Rules

These are always active regardless of which workflow step you're in.

### Workflow

```
/discuss → /research → /plan → /implement → /test → /close-out
```

Do not skip steps. Each command loads its own rules from `skills/`.

### Always Apply

- Use `AskUserQuestion` to ask **one question at a time** — never batch questions.
- Never add scope during implementation — defer new requirements to `ROADMAP.md`.
- Try **one fix** then escalate — never brute-force through repeated failures.
- When in doubt, **ask the user** via `AskUserQuestion`.
- **Before marking any step complete**, re-read the current skill file's On Completion section and verify every action has been performed.
- In research findings, **prefer the agent's full capability** over conservative defaults. Only restrict when there is a concrete risk.
- Output a `---` separator before calling `AskUserQuestion` to prevent the widget from covering the last line of output.

### Approval Gates

These actions **always require explicit user approval**: commits, pushes, merges, branch creation/deletion, builds/tests, edits to `CLAUDE.md`, phase transitions, destructive actions. Reading files does not require approval.

Before requesting approval, show a brief summary of what will happen and why.

### Git Safety

These commands are **never allowed** without explicit user approval: `git push --force`, `git reset --hard`, `git rebase`, `git branch -D`, `git checkout .`, `git restore .`, `git clean -f`.

### Conflict Resolution

Process rules in `CLAUDE.md` take precedence over `PROJECT.md`. Project-specific technical rules in `PROJECT.md` override general guidance. If unclear, stop and ask.

### Model Routing

The framework uses **model tiers** to route phases to appropriately-sized models:

| Tier | Claude Model | Purpose |
|------|-------------|---------|
| heavy | Opus | Architecture, code generation, complex reasoning |
| standard | Sonnet | Investigation, testing, summarisation |
| light | Haiku | Conversational Q&A, simple lookups |
| codex | Codex CLI | Mechanical subtasks (via `codex-dispatch.sh`) |

Each skill file declares its tier in its On Start section. The agent resolves the tier as follows:

1. **Detect current model**: Read the system prompt injection ("You are powered by the model named...") to identify the active model.
2. **Detect Codex availability**: Check if Codex CLI is installed (`command -v codex`).
3. **Look up phase tier**: Read the skill file's `Model tier:` annotation.
4. **Check for overrides**: If `PROJECT.md` has a "Model Routing" section, use those overrides instead of defaults.
5. **Show in status block**: Display the tier and model name in the `Model:` line.

**Confirmation mode** (default): Show the tier in the status block as a brief inline note. The user can override by requesting a different tier.

If `PROJECT.md` sets `auto-routing: yes`, skip confirmation and proceed with the recommended tier automatically.

When dispatching to a lighter model via the Task tool, always set the `model` parameter explicitly (e.g. `model: haiku`). Do not rely on model inheritance.

## Documents

| Document | Purpose |
|----------|---------|
| `CLAUDE.md` | Core rules, always loaded |
| `PROJECT.md` | Project-specific constraints, tech stack, lessons learned |
| `ROADMAP.md` | Phases, deliverables, status, deferred phases/verifications |
| `planning/phase-XX/` | Per-phase artifacts (CONTEXT, RESEARCH, PLAN, POSTMORTEM) |
| `.workflow/state.md` | Current position in the workflow (auto-updated by commands) |
| `skills/` | Detailed rules for each workflow command |

## Language

Use New Zealand English by default. Users may override during project setup or at any time.
