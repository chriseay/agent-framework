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
| `/pause` | Pause the current phase and switch to another |
| `/resume` | Resume a previously paused phase |
| `/issues` | List, create, and manage GitHub issues |

### State Tracking

`.workflow/state.md` tracks your exact position:
- Current phase and name
- Current workflow step
- Current subphase (N of M) — only when the phase is split into subphases
- Implementation progress (which plan step)
- Paused phases — a `## Paused Phases` section listing any phases paused via `/pause`
- The next command to run

Every command updates this file. When you open a new session, the agent reads it and immediately shows you where you are and what to do next.

By default, `.workflow/` is gitignored so state changes don't clutter your commit history. During `/new-project` or `/onboard`, you can opt in to tracking — useful if you want collaborators to see the current workflow position.

### Subphases

Some phases are too complex to deliver in a single `/implement` run. When `/plan` produces more steps than can be completed in one cycle, the agent will propose splitting the phase into subphases.

Subphases share a single `/discuss` and `/research` cycle. Each subphase then runs its own `/implement` → `/test` → `/close-out` cycle. Mid-phase close-outs are lightweight (commit + brief notes). The final subphase runs the full close-out sequence.

`.workflow/state.md` gains a `Subphase: N of M` line that shows your position within the cycle. Type `/status` to see it at any time.

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
- `PLAN.md` (or `sub-N/PLAN.md` if using subphases) has a Current Step marker showing implementation progress
- All artifacts (CONTEXT, RESEARCH, PLAN) are saved as you go

Next session, the agent reads the state and picks up exactly where you left off.

## Documents

| Document | Purpose | You Edit It? |
|----------|---------|-------------|
| `CLAUDE.md` | Core rules, always loaded | Rarely — process changes only |
| `.claude/rules/project-overrides.md` | Project-specific Claude behaviour (style, conventions, behaviour instructions) — auto-loaded every session | Yes — fill in your project's conventions |
| `PROJECT.md` | Project knowledge: tech stack, decisions, lessons learned | Agent proposes, you approve |
| `project/` | Optional subdocuments extracted from PROJECT.md (lessons archive, reference guides) | Agent loads on demand; you create when PROJECT.md gets large |
| `ROADMAP.md` | Phases and status | Agent updates at close-out |
| `planning/phase-XX/` | Per-phase artifacts | Agent creates these |
| `.workflow/state.md` | Current position | Never — auto-updated |
| `skills/` | Rules for each command | Never — framework files |
| `templates/` | Starting points for artifacts | Never — used by skills |

## Customising

Agent Framework separates framework-owned files (updated by `bootstrap.sh` on upgrade) from project-owned files (never touched on upgrade).

**Framework-owned** — updated by `bootstrap.sh`: `CLAUDE.md`, `AGENTS.md`, `skills/`, `templates/`, `.claude/agents/` (framework agents only)

`.framework-base/` is also managed automatically by `bootstrap.sh` — it stores the last version _actually installed_ for each framework file, used as the merge base on subsequent upgrades. It is gitignored; you do not need to edit or commit it.

**Project-owned** — never overwritten: `.claude/rules/project-overrides.md`, `.workflow/state.md`, `PROJECT.md`, `ROADMAP.md`, `planning/`

### Where to put project customisations

**Project-specific Claude instructions** (style, conventions, tech context, behaviour):
→ `.claude/rules/project-overrides.md`
Created automatically by `bootstrap.sh` on fresh install. Auto-loaded by Claude Code at every session start — no approval dialog. Add any conventions or context you want Claude to follow throughout your project.

**Project knowledge** (tech stack, decisions, constraints, lessons):
→ `PROJECT.md`
Loaded at session start. Keep it focused on facts and context about what you're building — not Claude behaviour instructions (those go in `project-overrides.md`).

**Bespoke sub-agents**:
→ `.claude/agents/your-agent-name.md`
Use a unique filename that doesn't match framework agents (`doc-reviewer`, `explore-codebase`, `implement-step`, `test-runner`). Your agents are safe on upgrade.

### Migrating existing edits

If you have edits already in `CLAUDE.md` or skill files:
1. Copy your additions into `.claude/rules/project-overrides.md`
2. Re-run `bootstrap.sh` — it 3-way merges each framework file, preserving your edits and applying new framework content automatically. If changes overlap, conflict markers are written into the file for you to resolve. If `.framework-base/` is out of sync with no valid common ancestor, the framework version is applied directly and a `Files updated from stale base` summary is printed — re-apply your edits to those files.
3. Your additions in `project-overrides.md` are safe; the merged framework files will include both your edits and the latest framework content

## When PROJECT.md Gets Large

PROJECT.md is loaded at every session start. As a project matures, it can accumulate content that makes the file unwieldy and fills the agent's context with irrelevant material.

**Three content categories** help you decide what to keep vs. extract:

| Category | Description | Where it lives |
|----------|-------------|----------------|
| **Core** | Always needed: overview, tech stack, domain constraints, recent lessons, model routing | PROJECT.md (keep lean) |
| **Reference** | Phase-specific guides: API docs, deployment procedures, test tooling, security guardrails | `project/<name>.md` (load on demand) |
| **Archive** | Historical records: lessons from older phases, per-phase addenda | `project/lessons-archive.md` (load rarely) |

### The Subdocuments Registry

When you extract content, list it in Section 14 (Subdocuments) of PROJECT.md:

```markdown
## 14) Subdocuments

| File | Contents | Load when |
|------|----------|-----------|
| `project/lessons-archive.md` | Lessons from phases 1–10 | Phase involves a recurring problem from those phases |
| `project/deployment.md` | CI/CD, SSH guardrails, deploy steps | Phase involves deployment |
| `project/api.md` | REST API endpoints, auth tokens | Phase involves API calls |
```

The agent reads this table at session start and loads subdocuments whose "Load when" condition matches the current phase. Subdocuments live in a `project/` directory alongside PROJECT.md.

### Extraction triggers

These are prompts to consider splitting — not automatic rules:

- Section 13 (Recent Lessons) exceeds ~10 entries → **compress first** (see below), then archive if still too large
- Any non-core section exceeds ~50 lines → extract to `project/<section-name>.md`
- Total PROJECT.md exceeds ~200 lines → review all sections and extract reference/archive content

The agent surfaces these suggestions during `/close-out`. You decide when to act.

### Lessons write-target rule

New lessons are always written to PROJECT.md's Section 13 (Recent Lessons) in **[PhN] format**: a single actionable sentence tagged with the phase number (e.g., `[Ph22]`). The tag lets the agent look up full context in `planning/phase-NN/POSTMORTEM.md` on demand.

**Format**: `- **Descriptive title** [PhN]: When doing X, do Y because Z.`

The section should open with a header note:
```
> Full detail for any lesson: planning/phase-NN/POSTMORTEM.md
```

**When the section gets long**: compress multi-line entries to single sentences with [PhN] tags first — this typically reduces a 150-line section to ~40 lines without losing any information. If the section is still too large after compression, move older entries to `project/lessons-archive.md` and add it to the registry.

If the archive itself grows large, add a second file (`project/lessons-archive-v2.md`) as a new registry row. The same pattern applies recursively.

### Backward compatibility

Projects without a Subdocuments section continue to work unchanged. The pattern is opt-in.

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
| light | Conversational Q&A, simple lookups (`/discuss`, `/status`, `/pause`, `/resume`, `/issues`) |
| codex | Mechanical subtasks dispatched via `codex-dispatch.sh` |

The agent shows the recommended tier in the status block. You can override to a different tier if needed, or set `auto-routing: yes` in `PROJECT.md` to skip confirmation.

Within a phase, `/plan` annotates individual steps with model tiers, and `/implement` dispatches each step to the annotated tier. See [README.md](README.md#model-routing) for the full tier-to-phase mapping and override options.

## GitHub Integration

Requires the [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated (`gh auth login`).

Phases sync automatically to GitHub Issues and Milestones:

- `/discuss` creates a GitHub Issue (and Milestone if needed) for each new phase added to the roadmap.
- `/close-out` closes the corresponding GitHub Issue when a phase completes.

Use `/issues` to list, create, and manage issues outside the normal workflow.

When the `gh` CLI is available, `/discuss` automatically checks for CI failures on the default branch before the Roadmap Review and displays a warning banner if any are found, requiring acknowledgement before continuing. `/issues` surfaces recent CI failures (most recent run per workflow, across all branches) on load and provides a "CI Runs" operation to re-surface them on demand.

### Phase Renumbering

When you insert a new phase _between_ two existing phases during `/discuss`, the agent automatically renumbers all subsequent not-started and in-progress phases to keep the sequence contiguous.

What gets updated:
- ROADMAP.md phase headings
- `planning/phase-XX/` directory names (in-progress phases only)
- GitHub issue titles (updated in-place — issue numbers and state are unchanged)

What does **not** change:
- Completed phases — their artifacts and closed issues keep their original numbers to preserve history
- Issue numbers, milestones, or any other GitHub metadata

How it works: the agent builds a rename map (e.g., Phase 13→14, Phase 14→15), shows it to you as an approval gate, and executes all updates atomically after you confirm. The procedure runs once per insertion — if you add two phases in one session, you'll see two sequential approval gates.

## File Structure

```
your-project/
├── CLAUDE.md                    (core rules)
├── PROJECT.md                   (created by /new-project)
├── ROADMAP.md                   (created by /new-project)
├── README.md                    (created by /new-project)
├── .claude/
│   ├── agents/                  (framework sub-agents + your bespoke agents)
│   └── rules/
│       └── project-overrides.md (project-specific Claude behaviour — edit this)
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
│   ├── project-overrides.md     (boilerplate for .claude/rules/project-overrides.md)
│   └── planning/
│       ├── CONTEXT.md
│       ├── RESEARCH-light.md
│       ├── RESEARCH-standard.md
│       ├── RESEARCH-deep.md
│       ├── PLAN.md
│       ├── POSTMORTEM.md
│       └── RETROSPECTIVE.md
├── .framework-base/             (last installed versions — gitignored, managed by bootstrap.sh)
└── planning/
    ├── phase-00/
    ├── phase-01/
    └── milestone-mvp/
```
