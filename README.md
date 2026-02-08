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

This registers the marketplace and installs all 11 workflow commands as Claude Code slash commands (`/discuss`, `/research`, `/plan`, etc.).

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
| `/help` | Show available commands and contextual suggestion |

## How It Works

**CLAUDE.md** (70 lines) is auto-loaded every session with core rules: approval gates, git safety, and the workflow sequence.

**Commands** (installed as a Claude Code plugin) contain the detailed rules for each workflow step. They're only loaded when you invoke the command — the agent isn't trying to hold 400 lines of rules in its head at once.

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

## Requirements

- [Claude Code](https://claude.ai/claude-code) (Anthropic's CLI for Claude)
