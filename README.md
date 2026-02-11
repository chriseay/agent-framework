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

### 1. Clone the repo

```bash
git clone https://github.com/chriseay/agent-framework.git
```

### 2. Install the plugin

```bash
cd agent-framework
./install.sh
```

This registers the marketplace and installs the workflow commands as Claude Code slash commands (`/discuss`, `/research`, `/plan`, etc.).

### 3. Set up your project

```bash
./setup.sh /path/to/your/project
cd /path/to/your/project
```

The setup script copies `CLAUDE.md`, `.workflow/`, `skills/`, and `templates/` into your project directory. It detects whether you have existing code and tells you which command to run:

- **New project (no code yet)**: Open in Claude Code, type `/new-project`
- **Existing codebase**: Open in Claude Code, type `/onboard`

### Manual installation (alternative)

If you prefer to install manually instead of using the script:

```bash
claude plugin marketplace add chriseay/agent-framework
claude plugin install agent-framework@agent-framework
```

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
Next: type /test to verify the implementation.
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
- `PLAN.md` has a Current Step marker showing implementation progress
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

Setup copies both `CLAUDE.md` and `AGENTS.md` into your project. Codex CLI is optional — the framework works fine with Claude Code alone.

## Model Routing

Each workflow phase has a recommended **model tier** to balance cost and capability:

| Tier | Claude Model | When Used |
|------|-------------|-----------|
| heavy | Opus | `/plan`, `/implement`, `/onboard` — architecture and code generation |
| standard | Sonnet | `/research`, `/test`, `/close-out`, `/retro` — investigation and summarisation |
| light | Haiku | `/discuss`, `/status`, `/issues`, `/help`, `/new-project` — conversational and lookups |
| codex | Codex CLI | Mechanical subtasks dispatched during `/implement` |

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

## Documentation

- **[FRAMEWORK-GUIDE.md](FRAMEWORK-GUIDE.md)** — Detailed guide for new users
- **[skills/](skills/)** — Individual command documentation (human-readable)
- **[templates/](templates/)** — Artifact templates

## Updating

To update the framework:

```bash
cd agent-framework
git pull
claude plugin update agent-framework@agent-framework
./setup.sh /path/to/your/project   # re-copies framework files
```

## Status

Currently working on **v1.4 — Polish & Onboarding**:
- Phase 8: Documentation Refresh Process (complete)
- Phase 9: Documentation Backfill (not started)
- Phase 10: .gitignore Template & Setup (not started)
- Phase 11: Install Process Simplification (not started)

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
