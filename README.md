# Agent Framework

A structured collaboration system for humans and AI coding agents. Gives you control over the process without micromanaging every step.

## What It Does

Agent Framework adds a repeatable workflow to your AI coding sessions:

```
/discuss → /research → /plan → /implement → /test → /close-out
```

Each command loads the right rules, does the work, and tells you what to type next. You approve the important decisions (commits, plans, architectural choices) while the agent handles the process.

**The problem it solves**: Without structure, AI coding sessions produce inconsistent results — agents skip research, make assumptions, lose context between sessions, and don't learn from mistakes. This framework fixes that.

## Installation

### Quick start

```bash
curl -sL https://raw.githubusercontent.com/chriseay/agent-framework/main/bootstrap.sh | bash -s -- /path/to/your/project
```

This clones the framework to `~/.agent-framework`, registers the Claude Code plugin, and copies framework files (`CLAUDE.md`, `.workflow/`, `skills/`, `templates/`, `.gitignore`, `.claude/agents/`, `claude-dispatch.sh`) into your project. It detects whether you have existing code and tells you which command to run:

- **New project (no code yet)**: Open in Claude Code, type `/new-project`
- **Existing codebase**: Open in Claude Code, type `/onboard`

Requires `git` and the [Claude Code CLI](https://claude.ai/claude-code).

### Manual installation (alternative)

If you prefer to install the plugin manually:

```bash
git clone https://github.com/chriseay/agent-framework.git ~/.agent-framework
claude plugin marketplace add chriseay/agent-framework
claude plugin install agent-framework@agent-framework
```

Then copy the framework files into your project by running `~/.agent-framework/bootstrap.sh /path/to/your/project`.

## What a Session Looks Like

When you open Claude Code, the agent immediately tells you where you are:

```
Phase: 3 — Capture and Attachments
Step:  implement (step 4 of 6)
Model: heavy (Opus)
Next:  type /implement to continue
```

You type the command, the agent does the work, and when it's done:

```
Implementation complete. All 6 plan steps finished.
Next → type /test to verify the changes.
```

Every step tells you the next one. Type `/status` at any time to check your position. Type `/help` to see all commands.

## Commands

| Command | What It Does |
|---------|-------------|
| `/new-project` | Set up a new project from scratch through guided questions |
| `/onboard` | Scan an existing codebase and set up the workflow |
| `/discuss` | Clarify requirements for the current phase |
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
| `/help` | Show available commands and contextual suggestion |

## How It Works

**CLAUDE.md** is auto-loaded every session with core rules: approval gates, git safety, and the workflow sequence.

**Commands** (installed as a Claude Code plugin) contain the detailed rules for each workflow step. They're only loaded when you invoke the command — the agent isn't trying to hold all the rules in its head at once.

**State** (`.workflow/state.md`) tracks your exact position. Every command updates it. New sessions read it immediately so the agent knows where you left off — even after abrupt exits.

**Templates** (`templates/` directory) ensure consistent artifact quality. The agent generates CONTEXT.md, RESEARCH.md, PLAN.md, and POSTMORTEM.md from templates instead of improvising structure each time.

## What You Control

The agent always pauses and asks before:
- Commits, pushes, merges, branch creation
- Running builds or tests
- Moving to the next phase
- Any destructive action

You approve plans before implementation starts. You approve lessons learned before they're recorded. You approve every commit message. Reading files never requires approval.

## Session Breaks

Close the terminal whenever you want. Nothing is lost:
- `.workflow/state.md` tracks your position
- `PLAN.md` (or `sub-N/PLAN.md` if using subphases) has a Current Step marker showing implementation progress
- All artifacts are saved as you go

Next session picks up exactly where you left off.

## Using with Codex CLI

Agent Framework works with [Codex CLI](https://developers.openai.com/codex/cli/) in two modes:

### Native workflow

Run `codex` in your project directory. Codex loads `AGENTS.md` (the Codex equivalent of `CLAUDE.md`) and follows the same workflow — status block, approval gates, skill files, and state tracking. Ask Codex to run any workflow command by name (e.g. "run /discuss").

### Dispatch from Claude Code

During `/implement`, you can dispatch simple subtasks to Codex:

```bash
bash codex-dispatch.sh "add docstrings to src/utils.js"
bash codex-dispatch.sh "rename all instances of oldName to newName in lib/" --model gpt-5.3-codex
```

Codex runs in a sandbox and returns the result. Best for mechanical tasks — renaming, formatting, adding documentation. Don't dispatch tasks that need complex reasoning or multi-file coordination.

> **Note**: `codex-dispatch.sh` warns if Codex v0.115.0 is detected (approval-mode regression) and applies a 120-second timeout to prevent silent stalls.

### Dispatch without Codex

If you don't have Codex CLI, use `claude-dispatch.sh` instead — it dispatches tasks headlessly to the Claude Code CLI:

```bash
bash claude-dispatch.sh "add docstrings to src/utils.js"
bash claude-dispatch.sh "rename all instances of oldName to newName in lib/" --model claude-sonnet-4-6
```

Setup copies both `CLAUDE.md` and `AGENTS.md` into your project. Codex CLI is optional — the framework works fine with Claude Code alone.

## Model Routing

Each workflow phase has a recommended **model tier** to balance cost and capability:

| Tier | Claude Model | Model ID | When Used |
|------|-------------|----------|-----------|
| heavy | Opus 4.6 | `claude-opus-4-6` | `/plan`, `/implement`, `/onboard` — architecture and code generation |
| standard | Sonnet 4.6 | `claude-sonnet-4-6` | `/research`, `/test`, `/close-out`, `/retro` — investigation and summarisation |
| light | Haiku 4.5 | `claude-haiku-4-5-20251001` | `/discuss`, `/status`, `/pause`, `/resume`, `/issues`, `/help`, `/new-project` — conversational and lookups |
| codex | Codex CLI | — | Mechanical subtasks dispatched during `/implement` |
| claude | Claude Code CLI | `claude-haiku-4-5-20251001` | Mechanical subtasks dispatched headlessly via `claude-dispatch.sh` (no Codex required) |

The agent shows the recommended tier in the status block at the start of each phase. By default it asks for confirmation — you can override to a different tier if needed.

To skip confirmation and use recommended tiers automatically, add this to the Model Routing section of your `PROJECT.md`:

```
- auto-routing: yes
```

To override the default tier for a specific phase, fill in the "Your Override" column in the Model Routing table in `PROJECT.md`.

Within a phase, `/plan` annotates individual steps with model tiers, and `/implement` dispatches each step to the annotated tier — so a single phase can use multiple models.

## GitHub Integration

Requires the [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated (`gh auth login`).

Phases sync automatically to GitHub Issues and Milestones. When `/discuss` adds a new phase to the roadmap, it creates a corresponding GitHub Issue (and Milestone if needed). When `/close-out` completes a phase, it closes the issue. Use `/issues` to manage issues outside the normal workflow.

When the `gh` CLI is available, `/discuss` automatically checks for CI failures on the default branch before the Roadmap Review and displays a warning banner if any are found, requiring acknowledgement before continuing. `/issues` surfaces recent CI failures (most recent run per workflow, across all branches) on load and provides a "CI Runs" operation to re-surface them on demand.

## Documentation

- **[TUTORIAL.md](TUTORIAL.md)** — Step-by-step walkthrough for first-time users
- **[FRAMEWORK-GUIDE.md](FRAMEWORK-GUIDE.md)** — Detailed guide for new users
- **[skills/](skills/)** — Individual command documentation (human-readable)
- **[templates/](templates/)** — Artifact templates

## Updating

Run the same install command again — it pulls the latest version and updates framework files:

```bash
curl -sL https://raw.githubusercontent.com/chriseay/agent-framework/main/bootstrap.sh | bash -s -- /path/to/your/project
```

The script performs a **3-way merge** for each framework file. Your local edits are preserved and new framework content is applied on top. A `.framework-base/` directory (gitignored) is created in your project to store the last version _actually installed_ for each file, which serves as the merge base on subsequent upgrades.

If `.framework-base/` has fallen out of sync (e.g., a file was skipped in a previous upgrade), the script detects this before merging:
- **No user edits in the project file**: the base is reset automatically and the merge proceeds normally.
- **User edits present with no valid common ancestor**: the framework version is applied directly and a `Files updated from stale base` summary is printed at the end — re-apply your local additions to those files and move them into `.claude/rules/project-overrides.md`.

After running, the script reports:
- `Merged: <file>` — local and framework changes were combined cleanly
- `CONFLICT: <file>` — overlapping changes could not be auto-resolved; standard conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) are written into the file for you to resolve manually
- `Updated (stale base — N edit(s) need re-checking): <file>` — framework applied; review your local edits

Project-owned files (`.claude/rules/`, `.workflow/state.md`) are never touched on upgrade.

## Customising

Agent Framework has a clean separation between framework-owned and project-owned files.

### Framework-owned (updated by bootstrap.sh)

| File/Directory | Purpose |
|---|---|
| `CLAUDE.md` | Core workflow rules — auto-loaded by Claude Code |
| `AGENTS.md` | Core workflow rules — auto-loaded by Codex CLI |
| `skills/` | Workflow command definitions |
| `.claude/agents/` | Framework sub-agents (doc-reviewer, test-runner, etc.) |
| `claude-dispatch.sh` | Headless dispatch script |
| `templates/` | Artifact scaffolding |

Don't edit these directly — changes will be overwritten on the next `bootstrap.sh` run.

### Project-owned (never touched by bootstrap.sh)

| File/Directory | Purpose |
|---|---|
| `.claude/rules/project-overrides.md` | Project-specific Claude behaviour — auto-loaded every session |
| `.claude/agents/your-agent.md` | Bespoke sub-agents (use unique names not matching framework agents) |
| `PROJECT.md` | Project knowledge: tech stack, decisions, lessons learned |
| `ROADMAP.md` | Phase plan and roadmap |
| `.workflow/state.md` | Current workflow position |
| `planning/` | Phase artifacts (context, research, plans, postmortems) |

### Where to put project customisations

**Project-specific Claude instructions** (style, conventions, tech context, behaviour):
→ `.claude/rules/project-overrides.md`
This file is created automatically by `bootstrap.sh` and auto-loaded by Claude Code at every session start. Fill in any conventions or context you want Claude to follow throughout your project.

**Bespoke sub-agents** (custom agent definitions for your project):
→ `.claude/agents/your-agent-name.md`
Use a unique filename that doesn't match framework agents (`doc-reviewer`, `explore-codebase`, `implement-step`, `test-runner`). Your agents are never overwritten.

**Project facts** (tech stack, architecture, lessons learned):
→ `PROJECT.md` — the knowledge document Claude reads for context.

### Migrating existing CLAUDE.md edits

If you have a project with edits already in `CLAUDE.md` or skill files:

1. Copy your additions into `.claude/rules/project-overrides.md`
2. Re-run `bootstrap.sh` — it will 3-way merge each framework file, preserving your local changes and applying new framework content automatically
3. Your additions in `project-overrides.md` are safe; the merged framework files will include both your edits and the latest framework content

## Status

In progress — **v1.5 — Sub-Agents & Housekeeping**:
- Phase 15: State Tracking Configuration (complete)
- Phase 16: Framework Polish (complete)
- Phase 17: Subphases (complete)
- Phase 18: Model Change Instructions (complete)
- Phase 19: Model Updates Process (complete)
- Phase 20: PROJECT.md Structure Refactoring (complete)
- Phase 21: Phase Pause/Resume (complete)
- Phase 22: PROJECT.md Lessons Compression (complete)
- Phase 23: Phase Numbering System (complete)
- Phase 24: Sub-Agent & Agent Team Research (complete)
- Phase 25: Sub-Agent Implementation (complete)
- Phase 26: Framework Update Safety (complete)
- Phase 27: CI Failure Surfacing (complete)
- Phase 28: 3-Way Merge Upgrades (complete)
- Phase 29: Plugin Cache Refresh on Upgrade (complete)
- Phase 30: Bootstrap Safe-Copy Fixes (complete)

Previously completed — **v1.4 — Polish & Onboarding**:
- Phase 8: Documentation Refresh Process (complete)
- Phase 9: Documentation Backfill (complete)
- Phase 10: .gitignore Template & Setup (complete)
- Phase 11: Install Process Simplification (complete)
- Phase 12: Command Transition UX (complete)
- Phase 13: Per-Task Tier Annotations (complete)
- Phase 14: New User Tutorial (complete)

Previously completed — **v1.3 — Smarter Routing & Tracking**:
- Phase 5: Per-Task Model Routing (complete)
- Phase 6: Deferred Item Categories (complete)
- Phase 7: Phase-to-GitHub Sync (complete)

Previously completed — **v1.2 — Workflow Refinement**:
- Phase 3: Consolidate Skill/Plugin Files (complete)
- Phase 4: Roadmap Scoping in /discuss (complete)

Previously completed — **v1.1 — Integrations & Efficiency**:
- Phase 0: Codex Integration (complete)
- Phase 1: Lighter Model Routing (complete)
- Phase 2: GitHub Issues Integration (complete)

## Requirements

- [Claude Code](https://claude.ai/claude-code) (Anthropic's CLI for Claude)
- [Codex CLI](https://developers.openai.com/codex/cli/) (optional — for dispatch and native Codex workflow)
