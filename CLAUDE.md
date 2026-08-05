# CLAUDE.md

This file is automatically loaded at the start of every session. Detailed step-by-step rules are in the `skills/` directory and loaded by each workflow command.

## Session Start

**On every new session**, immediately:
1. Read `.workflow/state.md`
2. Read `PROJECT.md` and `ROADMAP.md` (if they exist). If `PROJECT.md` has a `## Subdocuments` section, read each listed subdocument whose "Load when" condition says "Always" or clearly matches the current phase context (e.g., the phase involves deployment, API calls, or testing). Skip subdocuments whose condition does not apply to the current phase.
3. If mid-phase, read the relevant `planning/phase-XX/` artifacts
4. Check for a `## Paused Phases` section in `.workflow/state.md`. If any paused entries exist, include a `Paused:` line in the status block.
5. Present this status block to the user:

```
Phase:    [number] — [name]
Step:     [current workflow step]
Subphase: N of M (only if in a subphase cycle)
Paused:   [N phase(s) — Phase X: Name, ...] (only if paused phases exist)
Model:    [tier] ([model name])
Next:     type `/[next command]` to continue
```

Omit the `Subphase` line entirely when not in a subphase cycle.
Omit the `Paused` line entirely when no phases are paused.

6. Use `AskUserQuestion` to confirm the status is accurate before proceeding.

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

**Abbreviated cycles**: Some phases skip steps (e.g. research-only phases skip `/plan`, `/implement`, `/test`). When steps are skipped, manually update `state.md` after each completed step to avoid session-break drift. Write the `Next Command` as the actual next step in the abbreviated sequence, not the next step in the full cycle.

**Hotfix path**: An optional, tightly-scoped bypass of the full cycle for changes that meet **every** one of these objective criteria — not a judgment call:
- Fixes a single, already-fully-specified defect (known root cause, file, and fix — e.g. a deferred verification or a bug reported with exact reproduction steps), or applies content that was already fully decided elsewhere and only needs mechanical application.
- Touches no more than 2 files.
- Introduces no new files, no new entities, no new user-facing behaviour, and requires no design decisions.
- Is fully reversible with a single revert commit.

If a change meets all four, skip straight to `/implement`. Before doing so, output an About to/Why/Affects block that states explicitly how the change satisfies each of the four criteria, then use `AskUserQuestion` to get explicit approval — "Yes, treat as hotfix" / "No, run the full cycle". Never self-assess and proceed silently; if any criterion is even arguable, run the full cycle instead.

On approval: implement the change, then commit and push as normal (each still requires its own approval per Git Rules). Log the hotfix in `ROADMAP.md`'s `## Hotfix Log` section — date, one-sentence description, commit hash. Hotfixes are out-of-band from phase numbering; don't update `.workflow/state.md`'s phase tracking for one.

### Always Apply

- Use `AskUserQuestion` to ask **one question at a time** — never batch questions.
- Once the user responds to an `AskUserQuestion`, proceed immediately to the next step — don't wait for a separate follow-up message to confirm the answer was understood.
- Never add scope during implementation — defer new requirements to `ROADMAP.md`.
- Try **one fix** then escalate — never brute-force through repeated failures.
- When in doubt, **ask the user** via `AskUserQuestion`.
- **Before marking any step complete**, re-read the current skill file's On Completion section and verify every action has been performed.
- In research findings, **prefer the agent's full capability** over conservative defaults. Only restrict when there is a concrete risk.
- Output a `---` separator before calling `AskUserQuestion` to prevent the widget from covering the last line of output.

### Approval Gates

These actions **always require explicit user approval**: commits, pushes, merges, branch creation/deletion, builds/tests, edits to `CLAUDE.md`, phase transitions, destructive actions. Reading files does not require approval.

Before requesting approval, show a brief summary of what will happen and why. Always request approval via `AskUserQuestion` using the About to/Why/Affects format — never collect approval through inline text. If `project/bash-permission-rules.md` exists in this project, read and follow it — it documents which Bash command shapes trigger Claude Code's permission checker and how to restructure them to avoid unnecessary approval prompts.

### Git Safety

These commands are **never allowed** without explicit user approval: `git push --force`, `git reset --hard`, `git rebase`, `git branch -D`, `git checkout .`, `git restore .`, `git clean -f`.

### Conflict Resolution

Process rules in `CLAUDE.md` take precedence over `PROJECT.md`. Project-specific technical rules in `PROJECT.md` override general guidance. If unclear, stop and ask.

### Model Routing

The framework uses **model tiers** to route phases to appropriately-sized models:

| Tier | Claude Model | Model ID | Purpose |
|------|-------------|----------|---------|
| heavy | Opus 5 | `claude-opus-5` | Architecture, code generation, complex reasoning |
| standard | Sonnet 5 | `claude-sonnet-5` | Investigation, testing, summarisation |
| light | Haiku 4.5 | `claude-haiku-4-5-20251001` | Conversational Q&A, simple lookups |
| codex | Codex CLI | — | Mechanical subtasks (via `codex-dispatch.sh`) |
| claude | Claude Code CLI | `claude-haiku-4-5-20251001` | Mechanical subtasks dispatched headlessly via `claude-dispatch.sh` (Claude alternative to codex-dispatch.sh; no Codex required) |

**`opusplan` alias**: Claude Code offers an `opusplan` model alias that uses Opus during planning and Sonnet during execution. This matches the framework's heavy/standard tier intent and may be a convenient default for users on Max or Team plans.

**Adaptive thinking**: Sonnet 5 with adaptive thinking (`effort: "high"`) can match Opus 5 performance on many complex tasks at lower cost. Consider this as an alternative to Opus 5 for cost-sensitive projects. Only Opus 5 supports `effort: "max"` for unconstrained reasoning depth. Haiku 4.5 does not support adaptive thinking.

Each skill file declares its tier in its On Start section. The agent resolves the tier as follows:

1. **Detect current model**: Read the system prompt injection ("You are powered by the model named...") to identify the active model.
2. **Detect Codex availability**: Check if Codex CLI is installed (`command -v codex`).
3. **Look up phase tier**: Read the skill file's `Model tier:` annotation.
4. **Check for overrides**: If `PROJECT.md` has a "Model Routing" section, use those overrides instead of defaults.
5. **Show in status block**: Display the tier and model name in the `Model:` line.

**Confirmation mode** (default): Show the tier in the status block as a brief inline note. The user can override by requesting a different tier.

If `PROJECT.md` sets `auto-routing: yes`, skip confirmation and proceed with the recommended tier automatically.

When dispatching to a lighter model via the Task tool, always set the `model` parameter explicitly (e.g. `model: claude-haiku-4-5-20251001`). Do not rely on model inheritance.

**Haiku dispatch scope**: Haiku is appropriate for mechanical steps only — file writes, package installs, directory creation, simple lookups, formatting. It is not appropriate for interpreting raw command or infrastructure output, where subtle field semantics require judgment (e.g. parsing `systemctl status`, `df`, or other tool output for meaning, not just presence) — handle those at the dispatching step's own tier instead.

### Updating Model Tiers

When Anthropic releases a new model family, review and update the tier mapping:

1. **Check**: Compare the tier table above against Anthropic's [model overview page](https://docs.anthropic.com/en/docs/about-claude/models). Note any new model IDs, deprecated models, or capability changes.
2. **Update**: If the mapping is stale, update the tier table (model names and IDs) and the model-check blocks in all 10 skill files (`skills/*.md`). Each skill file has an On Start model-check block that references a specific model name and `/model` alias.
3. **Propagate**: Re-run `bootstrap.sh` on active projects to copy the updated `CLAUDE.md` and skill files.

If your `PROJECT.md` doesn't have a Model Routing section, see `templates/PROJECT.md` for a template that includes per-project tier overrides and update cadence settings.

## Documents

| Document | Purpose |
|----------|---------|
| `CLAUDE.md` | Core rules, always loaded |
| `PROJECT.md` | Project-specific constraints, tech stack, lessons learned |
| `project/` | Optional subdocuments extracted from PROJECT.md (lessons archive, reference guides) — listed in PROJECT.md's Subdocuments section |
| `ROADMAP.md` | Phases, deliverables, status, deferred phases/verifications |
| `planning/phase-XX/` | Per-phase artifacts (CONTEXT, RESEARCH, PLAN, POSTMORTEM) |
| `.workflow/state.md` | Current position in the workflow (auto-updated by commands) |
| `skills/` | Detailed rules for each workflow command |

## Language

Use New Zealand English by default. Users may override during project setup or at any time.
