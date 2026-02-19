# /close-out

Complete the phase, create the postmortem, and prepare for the next phase.

Model tier: standard

## On Start

1. Read `.workflow/state.md` to identify the current phase.
2. Note the model tier for this phase: `standard`. Include it in the status block.
3. Read `planning/phase-XX/CONTEXT.md` and any test results from the session.
   - Read the **Subphase** field from `.workflow/state.md`.
   - If the field is **absent**: read `planning/phase-XX/PLAN.md` (standard behaviour).
   - If set and this is the **final subphase** (Subphase: N of N): read all `planning/phase-XX/sub-N/PLAN.md` and `planning/phase-XX/sub-N/POSTMORTEM.md` files to build a complete picture for the main POSTMORTEM.md.
   - If set and **not the final subphase**: read only `planning/phase-XX/sub-N/PLAN.md` for the current subphase. Lightweight close-out applies — see Process step 0.

## Process

0. **Subphase check** — run this before anything else:
   - Read the **Subphase** field from `.workflow/state.md`.
   - If the field is **absent** or this is the **final subphase** (Subphase: N of N): proceed with the full close-out sequence (steps 1–12 below).
   - If this is a **mid-subphase close-out** (Subphase: N of M where N < M): run the **Lightweight Close-Out** path below and stop — do not continue to steps 1–12.

### Lightweight Close-Out (mid-subphase only)

1. Summarise what subphase N delivered.
2. Write `planning/phase-XX/sub-N/POSTMORTEM.md` with three sections only:
   - **Summary**: what was delivered in this subphase
   - **Issues Encountered**: problems hit and how they were resolved
   - **Decisions and Rationale**: key choices made and why
3. Propose a commit to the user. Use `AskUserQuestion` to confirm the commit message before committing. Use Conventional Commit format: `feat(phase-XX): subphase N of M — [brief description]`
4. Update `.workflow/state.md`:
   ```
   - Subphase: [N+1] of M
   - Step: implement (not started)
   - Implementation Step: —
   - Next Command: /implement
   ```
5. Tell the user: **Subphase N of M complete.** Type `/implement` to continue with subphase N+1.

---

1. **Summarise** what changed and why.
2. **List verification** performed (automated + manual).
3. **Create** `planning/phase-XX/POSTMORTEM.md` with:
   - **Summary**: What was delivered
   - **Issues Encountered**: Problems hit and how they were resolved
   - **Decisions and Rationale**: Key choices made and why
   - **Verification**: What was tested and results
   - **Deferred Items**: What was pushed to later phases
   - **Close-Out Summary**: Final state of the work
   - **Process Notes**: Friction, gaps, or observations about the workflow (consumed by `/retro`)

   If the phase used subphases, begin by reading all `sub-N/PLAN.md` and `sub-N/POSTMORTEM.md` files. Synthesise them into the main POSTMORTEM.md — the main POSTMORTEM covers the full phase, not just the final subphase.
4. **Propose lessons learned**: Review both `CLAUDE.md` and `PROJECT.md` to avoid duplication. Use `AskUserQuestion` to confirm additions before writing.
5. **Update** `ROADMAP.md` status for the completed phase.
6. **Documentation refresh**:
   a. **Discover documentation files**: Scan for common patterns — `README.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`, `FRAMEWORK-GUIDE.md`, `PROJECT.md`, `CHANGELOG.md` in the repo root, and `docs/*.md` or `doc/*.md` directories. Exclude framework internals: `CLAUDE.md`, `AGENTS.md`, `skills/*.md`, `templates/*.md`, `planning/**/*.md`.
   b. If no documentation files are found, use `AskUserQuestion` to ask the user if there are docs the agent is missing.
   c. **Compare against phase changes**: For each discovered doc, read it and check whether the phase's deliverables introduce new features, change existing behaviour, or make any content stale.
   d. **Propose updates** via `AskUserQuestion` — additions for new features, updates for changed behaviour (including the README Status section), and removals for stale content. Confirm each proposed change before applying.
   e. If no updates are needed for any doc, confirm this to the user: "Documentation reviewed — no updates needed."
7. **Close GitHub issues** (if `gh` CLI is available):
   a. **Close the phase issue**:
      - Read `planning/phase-XX/CONTEXT.md` for the `## Sync Status` section.
      - If a GitHub Issue number is recorded:
        - Get the merge commit hash(es) from the current branch.
        - Post a summary comment: what was delivered + commit hash(es).
        - Use `AskUserQuestion` to confirm, then close via `gh issue close <number>`.
      - If Sync Status says "not created":
        - Create the issue (using the Sync flow from /discuss), post the summary comment, and immediately close it.
      - If no Sync Status section exists, search by title: `gh issue list --state all --search "Phase N in:title" --json number,title`
        - If found, comment and close. If not found, skip (pre-Phase 7 phase).
      - If `gh` is not available, record `- GitHub Issue: not closed (gh unavailable)` in Sync Status.
   b. **Close linked issues**: (existing behaviour)
      - Read `planning/phase-XX/CONTEXT.md` for the `## Linked Issues` section.
      - If linked issues exist, for each one: show the issue number, title, and current status. Use `AskUserQuestion` to ask whether to close it.
      - Close approved issues via `gh issue close <number>`.
8. **Check milestone completion** (if `gh` CLI is available and a phase issue was closed):
   - Read the milestone title from Sync Status.
   - Check if all issues are closed: `gh issue list --milestone "TITLE" --state open --json number | jq 'length'`
   - If the count is 0, use `AskUserQuestion` to propose closing the milestone.
   - If approved: find the milestone number via `gh api repos/:owner/:repo/milestones --method GET -F state=all | jq ...` and close it via `gh api repos/:owner/:repo/milestones/N -X PATCH -f state="closed"`.
9. **Propose commit, push, and merge** for explicit approval. Use `AskUserQuestion` for each.
   - Merge messages: one headline + 2–4 bullet points.
10. **Propose feature branch deletion** (local + remote) after merge.
11. **Record process notes** in POSTMORTEM.md — any friction or gaps. Do not propose CLAUDE.md changes here; save that for `/retro`.
12. **Confirm** planning artifacts (CONTEXT.md, PLAN.md, POSTMORTEM.md) contain enough context for the next session.

## On Completion

### 1. Detect milestone boundary

Read `ROADMAP.md` and find the milestone heading that contains the current phase. Check whether any subsequent phase under that same milestone heading has a status other than "Complete". If every remaining phase is complete (or there are no subsequent phases), this is a **milestone boundary**.

### 2. Route based on boundary

**If NOT a milestone boundary** (more phases remain in this milestone):

Identify the next incomplete phase. Update `.workflow/state.md`:
```
- Phase: [next phase number]
- Phase Name: [next phase name]
- Step: not started
- Implementation Step: —
- Research Tier: —
- Next Command: /discuss
```

If the completed phase used subphases, omit the `Subphase` field from state.md entirely (do not write `Subphase: —`).

Tell the user:

**Phase [N] complete** and merged.

Next → type `/discuss` to start **Phase [N+1]: [name]**.

**If a milestone boundary:**

Tell the user:

**Phase [N] complete.** This finishes the **[milestone name]** milestone.

Then use `AskUserQuestion` with three options:

1. **Add more phases to this milestone** — run the inline flow below, then set Next Command to `/discuss`.
2. **Run /retro** — set Next Command to `/retro`. Update state.md with the next milestone's first phase number/name (or keep current if no next milestone exists).
3. **Skip retro, continue to /discuss** — identify the next milestone's first phase. Update state.md to point to it with Next Command `/discuss`.

### 3. Inline "add phases" flow (milestone boundary only)

When the user chooses "Add more phases to this milestone":

1. Use `AskUserQuestion` to get the new phase **name**.
2. Use `AskUserQuestion` to get a one-line **scope and deliverable**.
3. Append the new phase to `ROADMAP.md` under the current milestone heading, with status "Not started" and the next available phase number.
4. Run the **GitHub Phase Sync** flow from `skills/discuss.md` (label, milestone, issue creation).
5. Use `AskUserQuestion`: "Add another phase, or done?"
   - If "Add another" → repeat from step 1.
   - If "Done" → continue below.
6. Update `.workflow/state.md` to point to the **first newly added phase**:
   ```
   - Phase: [new phase number]
   - Phase Name: [new phase name]
   - Step: not started
   - Implementation Step: —
   - Research Tier: —
   - Next Command: /discuss
   ```
   If the completed phase used subphases, omit the `Subphase` field from state.md entirely.

Tell the user:

**[count] phase(s) added** to the **[milestone name]** milestone.

Next → type `/discuss` to start **Phase [N]: [name]**.
