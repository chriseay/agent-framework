# AGENTS.md

This file is automatically loaded at the start of every Codex CLI session. Detailed step-by-step rules are in the `skills/` directory — read the relevant skill file before executing any phase.

## Session Start

**On every new session**, immediately:
1. Read `.workflow/state.md`
2. Read `PROJECT.md` and `ROADMAP.md` (if they exist). If `PROJECT.md` has a `## Subdocuments` section, read each listed subdocument whose "Load when" condition says "Always" or clearly matches the current phase context (e.g., the phase involves deployment, API calls, or testing). Skip subdocuments whose condition does not apply to the current phase.
3. If mid-phase, read the relevant `planning/phase-XX/` artifacts
4. Present this status block to the user:

```
Phase:    [number] — [name]
Step:     [current workflow step]
Subphase: N of M (only if in a subphase cycle)
Model:    [model name]
Next:     [next phase command to run]
```

Omit the `Subphase` line entirely when not in a subphase cycle.

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
- **Before marking any step complete**, re-read the current skill file's On Completion section and verify every action has been performed.
- In research findings, **prefer the agent's full capability** over conservative defaults. Only restrict when there is a concrete risk.
- Output a `---` separator before asking the user a question, to prevent the input widget from covering the last line of output.

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
| heavy | Opus | o4-mini | Architecture, code generation, complex reasoning |
| standard | Sonnet | o4-mini | Investigation, testing, summarisation |
| light | Haiku | o4-mini | Conversational Q&A, simple lookups |
| codex | — | o4-mini | Mechanical subtasks (via `codex-dispatch.sh`) |

The Codex Model column above is a point-in-time reference — current as of the last update to this table, and unverified against OpenAI's current Codex CLI model lineup as of this edit. Verify against OpenAI's Codex CLI documentation before assuming it's still accurate; all four rows currently list the same model, which may reflect Codex CLI not differentiating by tier the way Claude does, or may reflect this table having gone stale — check rather than assume either way.

Each skill file declares its tier in its On Start section. The agent resolves the tier as follows:

1. **Detect current model**: In Codex CLI, the model is set via `~/.codex/config.toml` or the `-m` flag. Note which model is active.
2. **Look up phase tier**: Read the skill file's `Model tier:` annotation — still needed for per-step dispatch (Model-Aware Dispatch in `skills/implement.md`) to reference.
3. **Check for overrides**: If `PROJECT.md` has a "Model Routing" section, use those overrides instead of defaults.
4. **Show in status block**: Display just the model name in the `Model:` line — no session-level tier-match prompt.

**No Advisor Guidance in this file**: Claude Code sessions use a tool called `advisor` (see `CLAUDE.md`'s Advisor Guidance section) to consult a stronger reviewer at named checkpoints instead of switching the whole session to a heavier model. That tool is Claude Code-specific and isn't part of Codex CLI's toolset, so this file has no equivalent section — if a step's tier genuinely doesn't fit the work, use `-m` or `~/.codex/config.toml` to change the active model directly.

## Documents

| Document | Purpose |
|----------|---------|
| `AGENTS.md` | Core rules, always loaded |
| `PROJECT.md` | Project-specific constraints, tech stack, lessons learned |
| `project/` | Optional subdocuments extracted from PROJECT.md (lessons archive, reference guides) — listed in PROJECT.md's Subdocuments section |
| `ROADMAP.md` | Phases, deliverables, status, deferred phases/verifications |
| `planning/phase-XX/` | Per-phase artifacts (CONTEXT, RESEARCH, PLAN, POSTMORTEM) |
| `.workflow/state.md` | Current position in the workflow (auto-updated by commands) |
| `skills/` | Detailed rules for each workflow command |

## Language

Use New Zealand English by default. Users may override during project setup or at any time.
