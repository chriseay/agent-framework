# /discuss

Clarify requirements for the current phase before any other work.

Model tier: light

## On Start

1. Read `.workflow/state.md` to identify the current phase.
2. Note the model tier for this phase: `light`. Include it in the status block.
3. Read `ROADMAP.md` to get the phase deliverables.
4. Read any existing `planning/phase-XX/CONTEXT.md` (if resuming).
5. Run the **Roadmap Review** (see section below).
6. Present the phase goal to the user.
7. **Check for unsynced phases** (if `gh` CLI is available):
   - Scan `planning/phase-*/CONTEXT.md` files for `## Sync Status` sections containing "not created".
   - If any are found and `gh` is available, use `AskUserQuestion` to offer creating the missing issues now (run the Sync flow for each).
   - If any are found and `gh` is NOT available, show a prominent warning: "GitHub sync is behind: N phase(s) have no matching issue. Run `gh auth login` to authenticate, then the next /discuss will catch up."
8. **Surface GitHub issues** (if `gh` CLI is available):
   - Run `gh issue list --limit 10` and show a summary of open issues to the user.
   - If there are open issues, use `AskUserQuestion` to ask whether any should be linked to this phase.
   - If the user selects issues to link, record them in the `## Linked Issues` section of CONTEXT.md (format: `- #<number> — <title>`).
   - If `gh` is not available, skip this step silently.

## Roadmap Review

Before diving into phase requirements, review the roadmap with the user to capture new scope.

1. **Present a compact summary** of `ROADMAP.md`:
   - Current milestone name and success criteria (one line)
   - Each phase: number, name, and status (one line per phase)
   - Deferred phases: count and brief labels (or "none")
   - Deferred verifications: count and brief labels (or "none")

   Example format:
   ```
   Milestone: v1.2 — Workflow Refinement
     Phase 3: Consolidate Skill/Plugin Files — Complete
     Phase 4: Roadmap Scoping in /discuss — Not started
   Deferred phases: 1 item (API rate limiting)
   Deferred verifications: 1 item (load test under concurrency)
   ```

2. **Gate question**: Use `AskUserQuestion` to ask: "Any roadmap changes — new items to add, or deferred items to address?" with options:
   - "No changes" — skip to the next On Start step.
   - "Yes, I have changes" — continue with the review flow below.

3. **If the user has changes**, run this flow:

   a. **Deferred Verifications**: List each deferred verification by name. For each, use `AskUserQuestion` to ask:
      - "Satisfied — remove" — the verification has been met; delete it from the list.
      - "Not yet — keep deferred" — leave it in Deferred Verifications.
      - "Convert to deferred phase" — move it to the Deferred Phases section (it needs dedicated work).

   b. **Deferred Phases**: List each deferred phase by name. For each, use `AskUserQuestion` to ask:
      - "Promote to numbered phase" — add it as a new phase in the roadmap (use existing placement logic). After adding the phase to the roadmap, run the **GitHub Phase Sync** flow for the new phase.
      - "Keep deferred" — leave it in Deferred Phases.

   c. **New items**: Ask the user what they'd like to add. For each new item:
      - Ask clarifying questions (one at a time) to define scope, deliverable, and verification criteria.
      - Recommend placement using `AskUserQuestion`:
        - **New phase** — recommend where it fits best (between existing phases, at the end of the current milestone, or in a future milestone). If inserting between existing phases, renumber subsequent phases.
        - **Deferred phase** — if the item needs its own phase cycle but isn't urgent or well-defined enough yet.
        - **Deferred verification** — if the item is a check or test to perform later.
        - **Fold into existing phase** — if it naturally extends an existing phase's scope.
      - The agent should propose a category (phase or verification) based on context. The user confirms or overrides.
      - After the user confirms, update `ROADMAP.md` immediately using the Edit tool. If the item was placed as a new phase, run the **GitHub Phase Sync** flow for it.

   d. **Repeat** until the user says they have no more changes.

4. After the review (or skip), continue with On Start step 6.

## GitHub Phase Sync

When a new phase is added to the roadmap (via step 3b promote or step 3c new phase), sync it to GitHub if `gh` CLI is available.

### Sync flow (per new phase)

1. **Check `gh` availability**: Run `command -v gh` and `gh auth status`. If unavailable, record `- GitHub Issue: not created (gh unavailable)` in the new phase's `planning/phase-XX/CONTEXT.md` (create the directory and a minimal CONTEXT.md if needed). Then skip remaining sync steps.

2. **Ensure `phase` label exists**: Run `gh label create phase --force` (idempotent — safe to run every time).

3. **Find or create the GitHub Milestone**:
   - Identify the ROADMAP milestone the phase belongs to (e.g., `v1.3 — Smarter Routing & Tracking`).
   - Check if it exists: `gh api repos/:owner/:repo/milestones --field state=all | jq -r --arg t "TITLE" '.[] | select(.title == $t) | .number'`
   - If not found, create it: `gh api repos/:owner/:repo/milestones -X POST -f title="TITLE"`
   - Note the milestone number from the response.

4. **Check for duplicate issue**: `gh issue list --state all --json number,title | jq --arg t "Phase N: Name" '.[] | select(.title == $t) | .number'`
   - If an issue already exists, record it in Sync Status and skip creation.

5. **Propose issue creation** via `AskUserQuestion`: Show the title, body preview, milestone, and label. Wait for approval.

6. **Create the issue**:
   ```
   gh issue create --title "Phase N: Name" --body "BODY" --milestone "MILESTONE_TITLE" --label phase
   ```
   The body should contain the phase deliverables and verification criteria from ROADMAP.md.

7. **Record in Sync Status**: Create `planning/phase-XX/` directory if needed. Write or update CONTEXT.md with:
   ```
   ## Sync Status
   - GitHub Issue: #NUMBER
   - GitHub Milestone: MILESTONE_TITLE
   ```

## Process

- Use `AskUserQuestion` to ask **one question at a time** until there are no grey areas.
- If the user is unsure about something, propose a sensible default and mark it as an assumption.
- Cover: scope, constraints, edge cases, verification expectations, anything ambiguous in the roadmap description.

## Artifact

Create `planning/phase-XX/CONTEXT.md` with:
- **Phase**: Name and number
- **Requirements (Confirmed)**: What was agreed
- **Constraints**: Technical or process limitations
- **Risks / Unknowns**: Carried from discussion
- **Open Questions**: Must be empty before moving on

Show the user the CONTEXT.md summary and use `AskUserQuestion` to confirm it's accurate.

## On Completion

Update `.workflow/state.md`:
```
- Step: discuss (complete)
- Next Command: /research
```

Tell the user:
> Discuss complete. CONTEXT.md created.
> Next: type `/research` to investigate the codebase and constraints.
