---
description: Write postmortem, propose lessons, commit, merge
allowed-tools: [Read, Glob, Grep]
---

# /close-out

Complete the phase, create the postmortem, and prepare for the next phase.

## On Start

1. Read `.workflow/state.md` to identify the current phase.
2. Read `planning/phase-XX/CONTEXT.md`, `PLAN.md`, and any test results from the session.

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
6. **Propose commit, push, and merge** for explicit approval. Use `AskUserQuestion` for each.
   - Merge messages: one headline + 2-4 bullet points.
7. **Propose feature branch deletion** (local + remote) after merge.
8. **Record process notes** in POSTMORTEM.md — any friction or gaps. Do not propose CLAUDE.md changes here; save that for `/retro`.
9. **Confirm** docs contain enough context for the next session.

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
