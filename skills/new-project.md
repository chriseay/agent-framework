# /new-project

Set up a new project from scratch. Creates PROJECT.md, ROADMAP.md, and README.md.

Model tier: light

## Trigger

Run when `.workflow/state.md` shows "Next Command: /new-project" or when the user explicitly requests project setup.

## On Start

1. Note the model tier for this command: `light`. Include it in the status block.
   **Model check**: This phase runs at light tier — recommended model: Haiku.
   Detect the current model from the system prompt ("You are powered by the model named…").
   If the current model does not match this tier:
   - State the mismatch clearly (e.g., "This phase needs Haiku; you're currently on Sonnet.").
   - Use `AskUserQuestion` with options: "Switched — ready to continue" / "Continue on [current model] anyway."
   Wait for the user's response before proceeding.

## Process

1. **Discuss**: Use `AskUserQuestion` to gather minimum viable info for each document. One question at a time. If the user is unsure, propose defaults and mark as assumptions. Ask:
   - What the project is and who it's for
   - Tech stack (or propose one)
   - Key features / phases of work
   - Preferred language and regional conventions (default: New Zealand English)
   - Whether phases should be grouped into **milestones** (e.g., "MVP", "Beta"). Milestones are optional but enable structured retrospectives.
   - Whether planning artifacts should be tracked in git (default: yes). If no, `planning/` will be added to `.gitignore`.
   - Whether `.workflow/state.md` should be tracked in git (default: no). Explain: "Workflow state tracks your current phase and step. Tracking it in git lets collaborators see where you are; ignoring it keeps your git history cleaner. Most solo projects leave it untracked." If no (default), `.workflow/` will be added to `.gitignore`.

2. **Research**: Review any existing files or context. List unknowns and risks.

3. **Plan**: Present a short outline for each document with assumptions called out.

4. **Verify**: Use `AskUserQuestion` to confirm outlines before writing.

## Document Creation

**Creation order** (strict): `PROJECT.md` → `ROADMAP.md` → `README.md`.

Before writing each document, output:
> **About to**: write `[document name]` (e.g., `PROJECT.md`, `ROADMAP.md`, `README.md`)
> **Why**: creating the required project documentation for this new project
> **Affects**: the target project directory (new file will be created)

Then provide the document outline and get explicit approval via `AskUserQuestion`.

### PROJECT.md Required Sections
- Project Overview
- Repository Layout
- Tech Stack (or "TBD" + assumption)
- Coding Style & Naming Conventions
- Domain & Product Constraints
- Data & Storage (or "N/A")
- Runtime/Environment
- Security & Privacy (or "N/A")
- Testing & Verification
- Deployment/Delivery (or "N/A")
- Observability & Performance (or "N/A")
- Lessons Learned (empty until populated)
- Phase Addenda (if roadmap-driven; else "N/A")

### ROADMAP.md Required Sections
- Milestone groupings (optional — phases grouped under named goals with success criteria)
- Phase list with deliverables
- Verification expectations per phase
- Status for each phase
- Deferred Phases and Deferred Verifications sections

### README.md Required Sections
- Project description
- Goals
- Status
- How to run/build/test (or "TBD")

## On Completion

If the user opted out of tracking planning artifacts:
> **About to**: append `planning/` to the project's `.gitignore`
> **Why**: user chose not to track planning artifacts in git
> **Affects**: `.gitignore` (new entry; checked for duplicates first)

Use `AskUserQuestion` with question "Append `planning/` to `.gitignore`?" and options: "Yes, append it" / "Skip — I'll manage this manually". Then append `planning/` to the project's `.gitignore` (check for existing entry first to avoid duplicates).

If the user opted out of state tracking (default):
> **About to**: append `.workflow/` to the project's `.gitignore`
> **Why**: user chose not to track workflow state in git (default behaviour)
> **Affects**: `.gitignore` (new entry; checked for duplicates first)

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

Tell the user:

**Project setup complete.** PROJECT.md, ROADMAP.md, and .workflow/state.md created.

Next → type `/discuss` to start **Phase 0: [name]**.
