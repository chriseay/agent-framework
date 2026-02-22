# /onboard

Bring an existing codebase into the structured workflow. Scans the codebase first, then asks the user to confirm and fill gaps — instead of starting from scratch.

Model tier: heavy

## When to Use

Use `/onboard` instead of `/new-project` when:
- The project already has code, dependencies, and possibly some documentation
- The user wants to start using the structured workflow on an existing codebase
- There's no `PROJECT.md` or `ROADMAP.md` yet (or they're outdated/incomplete)

## On Start

1. Note the model tier for this command: `heavy`. Include it in the status block.
   **Model check**: This phase runs at heavy tier — recommended model: Opus.
   Detect the current model from the system prompt ("You are powered by the model named…").
   If the current model does not match this tier:
   - State the mismatch clearly (e.g., "This phase needs Opus; you're currently on Sonnet.").
   - Tell the user how to switch: "To switch, type `/model opus` in Claude Code (conversation history is preserved)."
   - Use `AskUserQuestion` with options: "Switched — ready to continue" / "Continue on [current model] anyway."
   Wait for the user's response before proceeding.

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

**Wait for all four subagent results to return before proceeding to Phase 2.** Do not compile findings or present results until every dispatched Task has completed.

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

Output:
**About to**: present the codebase scan results for user review
**Why**: verifying scan accuracy before generating project documents from it
**Affects**: nothing yet — this is a review step before any writes

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
- Whether planning artifacts should be tracked in git (default: yes). If no, `planning/` will be added to `.gitignore`.
- Whether `.workflow/state.md` should be tracked in git (default: no). Explain: "Workflow state tracks your current phase and step. Tracking it in git lets collaborators see where you are; ignoring it keeps your git history cleaner. Most solo projects leave it untracked." If no (default), `.workflow/` will be added to `.gitignore`.

**Only ask about things the scan didn't already answer.** If the README already describes the goals, don't re-ask.

## Phase 4: Generate Documents

**Creation order** (strict): `PROJECT.md` → `ROADMAP.md` → `README.md`.

### PROJECT.md
Pre-populate from scan results + gap-filling answers. Use the template from `templates/PROJECT.md` but fill in discovered values instead of placeholders.

Output:
**About to**: write `PROJECT.md` from the codebase scan and gap-filling answers
**Why**: creating the primary project constraints document for the workflow
**Affects**: project root (new file `PROJECT.md`)

Present outline to user and get approval via `AskUserQuestion` before writing.

### ROADMAP.md
Build from the user's priorities + scanned issues:
1. Present the TODOs/FIXMEs/issues found during scan.
2. Use `AskUserQuestion` to ask which ones to include in the roadmap and what new work to add.
3. Propose a phase structure grouping related work together.
4. Ask about milestone groupings if the user opted in.
5. Output:
   **About to**: write `ROADMAP.md` with the phase structure agreed above
   **Why**: creating the roadmap that drives the entire workflow
   **Affects**: project root (new file `ROADMAP.md`)

   Then get approval via `AskUserQuestion` before writing.

### README.md
- If a README already exists, propose updates to add missing sections (status, build instructions, etc.) rather than replacing it.
- If no README exists, create from `templates/README.md` pre-populated with scan results.

Output:
**About to**: [write or update] `README.md`
**Why**: ensuring the README reflects the current project state and setup instructions
**Affects**: `README.md` ([new file / existing file will be modified])

Get approval via `AskUserQuestion` before writing or modifying.

## Phase 5: Initialize State

Create `planning/` directory if it doesn't exist.

If the user opted out of tracking planning artifacts:

**About to**: append `planning/` to the project's `.gitignore`
**Why**: user chose not to track planning artifacts in git
**Affects**: `.gitignore` (new entry; checked for duplicates first)

Use `AskUserQuestion` with question "Append `planning/` to `.gitignore`?" and options: "Yes, append it" / "Skip — I'll manage this manually". Then append `planning/` to the project's `.gitignore` (check for existing entry first to avoid duplicates).

If the user opted out of state tracking (default):

**About to**: append `.workflow/` to the project's `.gitignore`
**Why**: user chose not to track workflow state in git (default behaviour)
**Affects**: `.gitignore` (new entry; checked for duplicates first)

Use `AskUserQuestion` with question "Append `.workflow/` to `.gitignore`?" and options: "Yes, append it" / "Skip — I'll manage this manually". Then append `.workflow/` to the project's `.gitignore` (check for existing entry first to avoid duplicates). If the user opted in to state tracking, remove `.workflow/` from `.gitignore` if it was previously added by bootstrap.

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

**Onboarding complete.** PROJECT.md, ROADMAP.md, and .workflow/state.md created.

Next → type `/discuss` to start **Phase 0: [name]**.
