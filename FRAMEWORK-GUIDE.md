# Framework Guide

A structured collaboration system for humans and AI coding agents, driven by slash commands.

New to the framework? Start with the [tutorial](TUTORIAL.md) — it walks you through a complete project from start to finish.

## Quick Start

1. Copy `CLAUDE.md`, `.workflow/`, `skills/`, `templates/`, and `.gitignore` into your project root.
2. Start Claude Code.
3. The agent reads `.workflow/state.md` and tells you what to do:
   - **New project (no code yet)**: "Type `/new-project` to get started."
   - **Existing codebase**: "Type `/onboard` to scan the codebase and set up the workflow."
4. Follow the prompts — each command tells you the next one.

## How It Works

The workflow is driven by **commands**. Each command loads its own rules, does the work, updates the state file, and tells you what to type next.

```
/new-project → /discuss → /research → /plan → /implement → /test → /close-out
```

You can type `/status` at any time to see where you are.

### The Commands

| Command | What It Does |
|---------|-------------|
| `/new-project` | Set up a new project from scratch through guided questions |
| `/onboard` | Scan an existing codebase and set up the workflow around it |
| `/discuss` | Review the roadmap, then clarify requirements for the current phase |
| `/research` | Investigate codebase and constraints (light / standard / deep) |
| `/plan` | Create and verify an implementation plan |
| `/implement` | Execute the plan on a feature branch |
| `/test` | Run automated and manual verification |
| `/close-out` | Write postmortem, propose lessons, commit, merge |
| `/retro` | Milestone retrospective — review and improve the process |
| `/status` | Show current position and next command |
| `/issues` | List, create, and manage GitHub issues |

### State Tracking

`.workflow/state.md` tracks your exact position:
- Current phase and name
- Current workflow step
- Implementation progress (which plan step)
- The next command to run

Every command updates this file. When you open a new session, the agent reads it and immediately shows you where you are and what to do next.

By default, `.workflow/` is gitignored so state changes don't clutter your commit history. During `/new-project` or `/onboard`, you can opt in to tracking — useful if you want collaborators to see the current workflow position.

## What the User Does

You don't need to read CLAUDE.md or memorise rules. Just follow the commands:

1. **Answer questions** — during `/discuss` and `/research`, the agent asks you things one at a time
2. **Approve plans** — during `/plan`, review the summary and approve or request changes
3. **Approve git actions** — the agent always asks before committing, pushing, merging, or creating branches
4. **Run manual checks** — during `/test`, the agent tells you what to verify locally
5. **Approve lessons learned** — during `/close-out`, confirm what gets added to PROJECT.md
6. **Type the next command** — each step tells you what to type next

## Session Breaks

If you close the terminal mid-phase, nothing is lost:
- `.workflow/state.md` tracks your position
- `PLAN.md` has a Current Step marker showing implementation progress
- All artifacts (CONTEXT, RESEARCH, PLAN) are saved as you go

Next session, the agent reads the state and picks up exactly where you left off.

## Documents

| Document | Purpose | You Edit It? |
|----------|---------|-------------|
| `CLAUDE.md` | Core rules, always loaded | Rarely — process changes only |
| `PROJECT.md` | Your project's constraints and lessons | Agent proposes, you approve |
| `ROADMAP.md` | Phases and status | Agent updates at close-out |
| `planning/phase-XX/` | Per-phase artifacts | Agent creates these |
| `.workflow/state.md` | Current position | Never — auto-updated |
| `skills/` | Rules for each command | Never — framework files |
| `templates/` | Starting points for artifacts | Never — used by skills |

## Milestones

Milestones group phases into meaningful goals (e.g., "MVP", "Beta"). They're optional but useful:
- The agent asks about milestones during `/new-project`
- `/close-out` detects milestone boundaries and suggests `/retro`
- `/retro` reviews the process and proposes improvements

If you don't use milestones, the agent suggests a retrospective every 3–5 phases.

## Approval Gates

The agent always pauses and asks before:
- Commits, pushes, merges, branch creation/deletion
- Running builds or tests
- Editing CLAUDE.md
- Moving to the next phase
- Any destructive action (deleting files, resetting state)

Reading files never requires approval.

## Common Pitfalls

**Skipping `/research`**: Plans built without codebase understanding fail during implementation. Even Light research catches issues.

**Adding scope during `/implement`**: New requirements get deferred to ROADMAP.md, not added to the current phase. Deferrals come in two flavours:
- **Deferred Phases** need their own full `/discuss` → `/close-out` cycle.
- **Deferred Verifications** are checks postponed from earlier phases — they get reviewed during `/discuss` and ticked off when satisfied.

**Ignoring the verification in `/plan`**: The plan is checked against your docs before you approve it. If something contradicts CONTEXT.md or RESEARCH.md, it gets flagged.

**Stale documents**: The agent updates docs during `/close-out`. If you skip close-out, the next session starts with outdated context.

## Using with Codex CLI

The framework optionally supports [Codex CLI](https://developers.openai.com/codex/cli/) as an alternative backend:

- **Native workflow**: Run `codex` in your project directory. Codex loads `AGENTS.md` and follows the same workflow — status block, approval gates, skill files, and state tracking.
- **Dispatch from Claude Code**: During `/implement`, dispatch mechanical subtasks (renaming, formatting, adding docs) to Codex via `codex-dispatch.sh`.

Setup copies both `CLAUDE.md` and `AGENTS.md` into your project. Codex is optional — the framework works fine with Claude Code alone. See [README.md](README.md#using-with-codex-cli) for full details.

## Model Routing

Each workflow phase has a recommended **model tier** to balance cost and capability:

| Tier | Purpose |
|------|---------|
| heavy | Architecture, code generation, complex reasoning (`/plan`, `/implement`) |
| standard | Investigation, testing, summarisation (`/research`, `/test`, `/close-out`) |
| light | Conversational Q&A, simple lookups (`/discuss`, `/status`, `/issues`) |
| codex | Mechanical subtasks dispatched via `codex-dispatch.sh` |

The agent shows the recommended tier in the status block. You can override to a different tier if needed, or set `auto-routing: yes` in `PROJECT.md` to skip confirmation.

Within a phase, `/plan` annotates individual steps with model tiers, and `/implement` dispatches each step to the annotated tier. See [README.md](README.md#model-routing) for the full tier-to-phase mapping and override options.

## GitHub Integration

Requires the [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated (`gh auth login`).

Phases sync automatically to GitHub Issues and Milestones:

- `/discuss` creates a GitHub Issue (and Milestone if needed) for each new phase added to the roadmap.
- `/close-out` closes the corresponding GitHub Issue when a phase completes.

Use `/issues` to list, create, and manage issues outside the normal workflow.

## File Structure

```
your-project/
├── CLAUDE.md                    (core rules)
├── PROJECT.md                   (created by /new-project)
├── ROADMAP.md                   (created by /new-project)
├── README.md                    (created by /new-project)
├── .workflow/
│   └── state.md                 (auto-updated position tracker)
├── skills/
│   ├── new-project.md
│   ├── onboard.md
│   ├── discuss.md
│   ├── research.md
│   ├── plan.md
│   ├── implement.md
│   ├── test.md
│   ├── close-out.md
│   ├── retro.md
│   ├── status.md
│   ├── help.md
│   └── issues.md
├── templates/
│   ├── PROJECT.md
│   ├── ROADMAP.md
│   ├── README.md
│   ├── gitignore.template
│   └── planning/
│       ├── CONTEXT.md
│       ├── RESEARCH-light.md
│       ├── RESEARCH-standard.md
│       ├── RESEARCH-deep.md
│       ├── PLAN.md
│       ├── POSTMORTEM.md
│       └── RETROSPECTIVE.md
└── planning/
    ├── phase-00/
    ├── phase-01/
    └── milestone-mvp/
```
