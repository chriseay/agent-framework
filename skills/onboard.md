# /onboard

Bring an existing codebase into the structured workflow. Scans the codebase first, then asks the user to confirm and fill gaps — instead of starting from scratch.

Model tier: heavy

## When to Use

Use `/onboard` instead of `/new-project` when:
- The project already has code, dependencies, and possibly some documentation
- The user wants to start using the structured workflow on an existing codebase
- There's no `PROJECT.md` or `ROADMAP.md` yet (or they're outdated/incomplete)

## Phase 1: Scan

Run parallel `Explore` subagents (via `Task` tool) to map the codebase. Each agent focuses on one area:

**Agent 1 — Tech & Dependencies**:
- Languages, frameworks, libraries
- Package managers and dependency files (package.json, Podfile, requirements.txt, etc.)
- Build tools and configuration

**Agent 2 — Architecture & Structure**:
- Directory layout and organization patterns
- Key modules, entry points, and how they connect
- Data models and persistence layer
- API endpoints or external integrations

**Agent 3 — Docs & Config**:
- Existing README, docs/, wiki, or inline documentation
- CI/CD configuration
- Environment setup (Docker, .env files, scripts)
- Deployment configuration

**Agent 4 — Quality & Issues**:
- Test files, coverage configuration, test patterns
- TODOs, FIXMEs, and HACKs in the code (scan with `Grep`)
- Linter/formatter configuration
- Known debt indicators (commented-out code, skip annotations, suppressed warnings)

## Phase 2: Present Findings

Compile the scan results into a structured summary and present to the user:

```
## Codebase Scan — [project name or directory]

### Tech Stack
- [Language, framework, key dependencies]

### Architecture
- [Directory structure summary]
- [Key modules and their relationships]
- [Data model / persistence approach]

### Existing Documentation
- [What docs exist and what they cover]

### Test Coverage
- [Test files found, frameworks used, estimated coverage]

### Issues Found
- [N] TODOs/FIXMEs across [N] files
- [Key themes — e.g., "5 TODOs about error handling", "3 FIXMEs in auth module"]

### Gaps / Unknowns
- [Things the scan couldn't determine — deployment process, security requirements, etc.]
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

**Only ask about things the scan didn't already answer.** If the README already describes the goals, don't re-ask.

## Phase 4: Generate Documents

**Creation order** (strict): `PROJECT.md` → `ROADMAP.md` → `README.md`.

### PROJECT.md
Pre-populate from scan results + gap-filling answers. Use the template from `templates/PROJECT.md` but fill in discovered values instead of placeholders. Present outline to user and get approval before writing.

### ROADMAP.md
Build from the user's priorities + scanned issues:
1. Present the TODOs/FIXMEs/issues found during scan.
2. Use `AskUserQuestion` to ask which ones to include in the roadmap and what new work to add.
3. Propose a phase structure grouping related work together.
4. Ask about milestone groupings if the user opted in.
5. Get approval before writing.

### README.md
- If a README already exists, propose updates to add missing sections (status, build instructions, etc.) rather than replacing it.
- If no README exists, create from `templates/README.md` pre-populated with scan results.
- Get approval before writing or modifying.

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
