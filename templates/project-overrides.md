# Project Overrides

<!--
  This file is auto-loaded by Claude Code at every session start.
  Use it for project-specific Claude behaviour — things that go beyond the Agent Framework defaults.

  This file is project-owned. Running bootstrap.sh to upgrade Agent Framework will NEVER overwrite it.

  Do not edit these framework-owned files for project customisations:
    - CLAUDE.md          (framework core rules)
    - skills/            (workflow commands)
    - .claude/agents/    (framework sub-agents)

  Put all project-specific Claude instructions here instead.
-->

## Language & Style

<!--
  Language, tone, and formatting preferences for this project.

  Examples:
    - Use Australian English (not American).
    - Prefer explicit variable names over abbreviations.
    - Use 2-space indentation for all files.
-->

## Tech Stack Context

<!--
  Always-relevant facts about this project's tech stack that Claude should know.
  These supplement (not replace) the tech stack recorded in PROJECT.md.

  Examples:
    - This project targets Python 3.12. Do not suggest walrus operators or match statements as new features.
    - The API client lives in src/client/ — always import from there, never instantiate directly.
    - We use Tailwind CSS v4 beta; class names may differ from stable Tailwind docs.
-->

## Behaviour Overrides

<!--
  Project-specific deviations from Agent Framework defaults.

  Examples:
    - This is a solo project. Skip approval gates for commits on the feature branch.
    - Always run `make test` before suggesting a PR.
    - Never add docstrings to functions — the codebase uses inline comments only.
-->

## Model Routing Preferences

<!--
  Plain-text routing notes for this project's phases.
  For structured per-phase tier overrides, use the Model Routing section in PROJECT.md instead.

  Examples:
    - Phases in this project are small. Use standard (Sonnet) for /plan even though the default is heavy.
    - Research phases often involve unfamiliar APIs — prefer staying on Opus.
-->

## Custom Agent Guidance

<!--
  Notes about bespoke sub-agents in .claude/agents/ that Claude should know about.
  List agent names, what they do, and when to prefer them over built-in tools.

  Examples:
    - my-db-agent.md handles all database schema queries — use it instead of direct grep for schema questions.
    - scraper.md wraps the project's Playwright setup — prefer it for any web scraping tasks.
-->
