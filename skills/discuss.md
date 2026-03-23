# /discuss

Clarify requirements for the current phase before any other work.

Model tier: light

## On Start

1. Read `.workflow/state.md` to identify the current phase.
2. Note the model tier for this phase: `light`. Include it in the status block.
   **Model check**: This phase runs at light tier — recommended model: Haiku.
   Detect the current model from the system prompt ("You are powered by the model named…").
   If the current model does not match this tier:
   - State the mismatch clearly (e.g., "This phase needs Haiku; you're currently on Sonnet.").
   - Tell the user how to switch: "To switch, type `/model haiku` in Claude Code (conversation history is preserved)."
   - Use `AskUserQuestion` with options: "Switched — ready to continue" / "Continue on [current model] anyway."
   Wait for the user's response before proceeding to the next On Start step.
3. **Check for paused phases** (before anything else after model check):
   - Check `.workflow/state.md` for a `## Paused Phases` section.
   - If paused phases exist, list them: "You have [N] paused phase(s): Phase X — [Name] (paused [date], step: [step]), ..."
   - Use `AskUserQuestion`: "Resume a paused phase, or continue with Phase [M] (current)?"
     - Options: each paused phase as "Resume Phase N — [Name]", plus "Continue with Phase [M] (current)"
   - If the user selects a paused phase: read `skills/resume.md` and execute the resume flow for that phase. After resume completes, the session is now working on the resumed phase — present its phase goal and continue /discuss for that phase.
   - If the user continues: proceed normally with steps 5–10 below.
4. **Check for CI failures on the default branch** (if `gh` CLI is available):
   - Run `command -v gh` and `gh auth status`. If either fails, show: "CI check skipped — run `gh auth login` to enable CI surfacing." Then continue to step 5.
   - Run: `DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')`
   - Run:
     ```
     gh run list --branch "$DEFAULT_BRANCH" --limit 50 \
       --json workflowName,conclusion,url,databaseId \
       --jq '[.[] | select(.conclusion == "failure" or .conclusion == "timed_out")]
              | group_by(.workflowName)
              | map(sort_by(.databaseId) | reverse | .[0])'
     ```
   - If the result is an empty array (no failures, or no workflows): proceed silently to step 5.
   - If failures are found: display a warning banner:
     ```
     ⚠ CI FAILURES on [DEFAULT_BRANCH]:
     - [WorkflowName]: [url]
     - [WorkflowName]: [url]
     ```
     Then use `AskUserQuestion` to require acknowledgement before continuing:
     - "Acknowledged — continue with /discuss"
5. Read `ROADMAP.md` to get the phase deliverables.
6. Read any existing `planning/phase-XX/CONTEXT.md` (if resuming).
7. Run the **Roadmap Review** (see section below).
8. Present the phase goal to the user.
9. **Check for unsynced phases** (if `gh` CLI is available):
   - Scan `planning/phase-*/CONTEXT.md` files for `## Sync Status` sections containing "not created".
   - If any are found and `gh` is available, use `AskUserQuestion` to offer creating the missing issues now (run the Sync flow for each).
   - If any are found and `gh` is NOT available, show a prominent warning: "GitHub sync is behind: N phase(s) have no matching issue. Run `gh auth login` to authenticate, then the next /discuss will catch up."
10. **Surface GitHub issues** (if `gh` CLI is available):
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
        - **New phase** — recommend where it fits best (between existing phases, at the end of the current milestone, or in a future milestone). If inserting between existing phases, run the **Phase Renumbering** procedure (see below).
        - **Deferred phase** — if the item needs its own phase cycle but isn't urgent or well-defined enough yet.
        - **Deferred verification** — if the item is a check or test to perform later.
        - **Fold into existing phase** — if it naturally extends an existing phase's scope.
      - The agent should propose a category (phase or verification) based on context. The user confirms or overrides.
      - After the user confirms, before updating ROADMAP.md, output:
        **About to**: update `ROADMAP.md` with the new roadmap item
        **Why**: user confirmed the item and its placement
        **Affects**: `ROADMAP.md`

        Then update `ROADMAP.md` immediately using the Edit tool. If the item was placed as a new phase, run the **GitHub Phase Sync** flow for it.

   d. **Repeat** until the user says they have no more changes.

4. After the review (or skip), continue with On Start step 6.

## GitHub Phase Sync

When a new phase is added to the roadmap (via step 3b promote or step 3c new phase), sync it to GitHub if `gh` CLI is available.

### Sync flow (per new phase)

1. **Check `gh` availability**: Run `command -v gh` and `gh auth status`. If unavailable, record `- GitHub Issue: not created (gh unavailable)` in the new phase's `planning/phase-XX/CONTEXT.md` (create the directory and a minimal CONTEXT.md if needed). Then skip remaining sync steps.

2. **Ensure `phase` label exists**: Run `gh label create phase --force` (idempotent — safe to run every time).

3. **Find or create the GitHub Milestone**:
   - Identify the ROADMAP milestone the phase belongs to (e.g., `v1.3 — Smarter Routing & Tracking`).
   - Check if it exists: `gh api repos/:owner/:repo/milestones --method GET -F state=all | jq -r --arg t "TITLE" '.[] | select(.title == $t) | .number'`
   - If not found, create it: `gh api repos/:owner/:repo/milestones -X POST -f title="TITLE"`
   - Note the milestone number from the response.

4. **Check for duplicate issue**: `gh issue list --state all --json number,title | jq --arg t "Phase N: Name" '.[] | select(.title == $t) | .number'`
   - If an issue already exists, record it in Sync Status and skip creation.

5. **Propose issue creation**: Output:
   **About to**: create a GitHub issue for the new phase
   **Why**: syncing the new phase to GitHub Issues for tracking
   **Affects**: GitHub Issues, the phase's `planning/phase-XX/CONTEXT.md`

   Then use `AskUserQuestion`: Show the title, body preview, milestone, and label. Wait for approval.

6. **Create the issue**:
   ```
   gh issue create --title "Phase N: Name" --body "BODY" --milestone "MILESTONE_TITLE" --label phase
   ```
   The body should contain the phase deliverables and verification criteria from ROADMAP.md.

7. **Record in Sync Status**: Output:
   **About to**: write the GitHub issue number to `planning/phase-XX/CONTEXT.md`
   **Why**: recording the sync so future sessions can find and close the issue
   **Affects**: `planning/phase-XX/CONTEXT.md`

   Create `planning/phase-XX/` directory if needed. Write or update CONTEXT.md with:
   ```
   ## Sync Status
   - GitHub Issue: #NUMBER
   - GitHub Milestone: MILESTONE_TITLE
   ```

## Phase Renumbering

When a new phase is inserted _between_ two existing phases during Roadmap Review (step 3c), renumber all subsequent not-started and in-progress phases by +1. Completed phases keep their original numbers to preserve history.

**Trigger**: User confirms placement of a new phase between existing Phase N and Phase N+1. (Appending after the last phase never triggers renumbering — there is nothing to shift.)

### Renumbering procedure

1. **Identify affected phases**: Scan ROADMAP.md for all phases with numbers greater than N. For each, note:
   - Current number, name, and status (read the `Status:` line — Complete vs. anything else)
   - Whether `planning/phase-XX/` directory exists (presence = in-progress; absence = not-started)
   - GitHub issue number from that phase's `planning/phase-XX/CONTEXT.md` Sync Status section (if present)
   - **Skip** any phase whose Status is Complete.

2. **Build the rename map**: For each affected phase (ascending order), record old-number → old-number + 1. Note whether each is in-progress (has planning/ dir) or not-started (no dir).

3. **Approval gate**: Output:
   **About to**: renumber [N] phase(s) to accommodate the insertion
   **Why**: a new phase was inserted at position [N+1]; all subsequent not-started and in-progress phases must shift up by 1
   **Affects**: ROADMAP.md phase headings, `.workflow/state.md` (if the current phase is in the affected range), `planning/phase-XX/` directories (in-progress phases only), GitHub issue titles (open issues only)

   Show the rename map, for example:
   ```
   Phase 13 → Phase 14  (not-started)
   Phase 14 → Phase 15  (in-progress — will rename planning/phase-14/ → planning/phase-15/)
   Phase 15 → Phase 16  (not-started)
   ```

   Use `AskUserQuestion` with options: "Confirm renumbering" / "Cancel — do not renumber".
   - If the user cancels: note that the inserted phase was added to ROADMAP.md but no renumbering was performed. Continue Roadmap Review normally.

4. **Execute in order** (after user confirms):

   **a. Update ROADMAP.md headings**: Process affected phases in _descending_ number order (highest first) to prevent edit collisions. For each, change `### Phase X: Name` to `### Phase X+1: Name`. Edit only the `###` heading lines — do not alter body prose.

   **b. Update `.workflow/state.md`**: Check the current `Phase:` number. If it is within the affected range, increment the `Phase:` field by 1. The `Phase Name:` field does not change.

   **c. Rename `planning/` directories**: Process in-progress phases in _descending_ number order to prevent collision. For each, output:
   **About to**: rename `planning/phase-XX/` to `planning/phase-YY/`
   **Why**: phase number changed from XX to YY during renumbering
   **Affects**: `planning/phase-XX/` (directory rename only — content is preserved)

   Then execute: `mv "planning/phase-XX" "planning/phase-YY"` (using the full path).

   **d. Update artifact headers**: For each renamed directory, update the `# Phase N: Name` header line in `CONTEXT.md`, and in `RESEARCH.md` and `PLAN.md` if they exist. Change only the phase number in the header; leave Sync Status, Linked Issues, and all other content unchanged.

   **e. Update GitHub issue titles**: For each affected phase (not-started or in-progress) that has a GitHub issue number recorded in its CONTEXT.md Sync Status:
   - Check `gh` CLI availability: `command -v gh`. If unavailable, skip all GitHub updates and warn the user.
   - Run: `gh issue edit <issue_number> --title "Phase N+1: Name"`
   - Wait 1 second between edits to respect GitHub's secondary rate limit.
   - If no issue number is found in CONTEXT.md (sync was never run), skip that phase and note it in the completion summary.

5. **Confirm completion**: List all changes made. Note any skipped steps (e.g., phases with no GitHub issue, gh CLI unavailable).

**Constraint**: This procedure handles one insertion at a time. If the user inserts two phases during the same Roadmap Review, run the renumbering procedure once per insertion, sequentially — each with its own approval gate.

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

**Discuss complete.** CONTEXT.md created for Phase [N].

Next → type `/research` to investigate codebase and constraints.
