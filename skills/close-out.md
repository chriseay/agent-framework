# /close-out

Complete the phase, create the postmortem, and prepare for the next phase.

Model tier: standard

## On Start

1. Read `.workflow/state.md` to identify the current phase.
2. Note the model tier for this phase: `standard`. Include it in the status block.
3. Read `planning/phase-XX/CONTEXT.md`, `PLAN.md`, and any test results from the session.

## Process

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

Identify the next phase from `ROADMAP.md`. Update `.workflow/state.md`:
```
- Phase: [next phase number]
- Phase Name: [next phase name]
- Step: not started
- Implementation Step: —
- Research Tier: —
- Next Command: /discuss
```

If this was the last phase in a milestone, set:
```
- Next Command: /retro
```

Tell the user:
> Phase [N] complete and merged.
> Next: type `/discuss` to start **Phase [N+1]: [name]**.

Or if milestone boundary:
> Phase [N] complete. This finishes the **[milestone name]** milestone.
> Next: type `/retro` to run a milestone retrospective before starting the next milestone.
