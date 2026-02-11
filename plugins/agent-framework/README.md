# Agent Framework Plugin

A structured collaboration system for humans and AI coding agents, driven by slash commands.

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

## Installation

```bash
claude plugin marketplace add chriseay/agent-framework
claude plugin install agent-framework
```

## Usage

After installing the plugin, run `bootstrap.sh /path/to/project` to copy framework files (CLAUDE.md, skills, templates, etc.) into your project directory. Then open Claude Code and type `/new-project` or `/onboard` to get started.

See the [main README](../../README.md) for full documentation.
