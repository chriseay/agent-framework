---
description: Scan an existing codebase and set up the workflow
allowed-tools: [Read, Glob, Grep]
---

# /onboard

Bring an existing codebase into the structured workflow. Scans the codebase first, then asks the user to confirm and fill gaps.

## When to Use

Use `/onboard` instead of `/new-project` when the project already has code, dependencies, and possibly some documentation.

## Phase 1: Scan

Run parallel `Explore` subagents (via `Task` tool) to map the codebase. Each agent focuses on one area:

**Agent 1 — Tech & Dependencies**: Languages, frameworks, libraries. Package managers and dependency files. Build tools and configuration.

**Agent 2 — Architecture & Structure**: Directory layout and organisation patterns. Key modules, entry points, and how they connect. Data models and persistence layer. API endpoints or external integrations.

**Agent 3 — Docs & Config**: Existing README, docs/, wiki, or inline documentation. CI/CD configuration. Environment setup (Docker, .env files, scripts). Deployment configuration.

**Agent 4 — Quality & Issues**: Test files, coverage configuration, test patterns. TODOs, FIXMEs, and HACKs in the code (scan with `Grep`). Linter/formatter configuration. Known debt indicators (commented-out code, skip annotations, suppressed warnings).

## Phase 2: Present Findings

Compile the scan results into a structured summary and present to the user:

```
## Codebase Scan — [project name or directory]

### Tech Stack
- [Language, framework, key dependencies]

### Architecture
- [Directory structure summary]
- [Key modules and their relationships]

### Existing Documentation
- [What docs exist and what they cover]

### Test Coverage
- [Test files found, frameworks used]

### Issues Found
- [N] TODOs/FIXMEs across [N] files
- [Key themes]

### Gaps / Unknowns
- [Things the scan couldn't determine]
```

Use `AskUserQuestion` to ask: "Does this look accurate? Anything to correct or add?"

## Phase 3: Fill Gaps

Use `AskUserQuestion` — one question at a time — to fill in what the scan couldn't determine:
- Project goals and current priorities
- What's working well vs. what's broken or painful
- Deployment/delivery process (if not in config)
- Security and privacy requirements (if not documented)
- Any known constraints or gotchas learned the hard way
- Preferred language and regional conventions (default: New Zealand English)
- Whether phases should be grouped into milestones

**Only ask about things the scan didn't already answer.**

## Phase 4: Generate Documents

**Creation order** (strict): `PROJECT.md` → `ROADMAP.md` → `README.md`.

- **PROJECT.md**: Pre-populate from scan + answers. Present outline, get approval.
- **ROADMAP.md**: Build from priorities + scanned issues (TODOs/FIXMEs). Present phase structure, get approval.
- **README.md**: If exists, propose updates. If not, create from template. Get approval.

## Phase 5: Initialize State

Create `planning/` directory if it doesn't exist.

Update `.workflow/state.md`:
```
- Phase: 0
- Phase Name: [first phase from ROADMAP.md]
- Step: not started
- Implementation Step: —
- Research Tier: —
- Next Command: /discuss
```

## On Completion

Tell the user:
> Onboarding complete.
> - PROJECT.md: created with [N] sections populated from scan
> - ROADMAP.md: [N] phases across [N] milestones
> - README.md: [created / updated]
> - [N] TODOs/FIXMEs captured in roadmap
>
> Next: type `/discuss` to start **Phase 0: [name]**.
