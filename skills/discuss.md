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
7. **Surface GitHub issues** (if `gh` CLI is available):
   - Run `gh issue list --limit 10` and show a summary of open issues to the user.
   - If there are open issues, use `AskUserQuestion` to ask whether any should be linked to this phase.
   - If the user selects issues to link, record them in the `## Linked Issues` section of CONTEXT.md (format: `- #<number> — <title>`).
   - If `gh` is not available, skip this step silently.

## Roadmap Review

Before diving into phase requirements, review the roadmap with the user to capture new scope.

1. **Present a compact summary** of `ROADMAP.md`:
   - Current milestone name and success criteria (one line)
   - Each phase: number, name, and status (one line per phase)
   - Deferred actions: count and brief labels

   Example format:
   ```
   Milestone: v1.2 — Workflow Refinement
     Phase 3: Consolidate Skill/Plugin Files — Complete
     Phase 4: Roadmap Scoping in /discuss — Not started
   Deferred: 2 items (per-task routing, post-merge smoke test)
   ```

2. **Gate question**: Use `AskUserQuestion` to ask: "Any roadmap changes — new items to add, or deferred items to promote?" with options:
   - "No changes" — skip to the next On Start step.
   - "Yes, I have changes" — continue with the review flow below.

3. **If the user has changes**, run this flow:

   a. **Deferred actions**: List each deferred item by name. For each, use `AskUserQuestion` to ask whether it should be promoted to a phase or left deferred.

   b. **New items**: Ask the user what they'd like to add. For each new item:
      - Ask clarifying questions (one at a time) to define scope, deliverable, and verification criteria.
      - Recommend placement using `AskUserQuestion`:
        - **New phase** — recommend where it fits best (between existing phases, at the end of the current milestone, or in a future milestone). If inserting between existing phases, renumber subsequent phases.
        - **Deferred action** — if the item isn't urgent or well-defined enough for a phase yet.
        - **Fold into existing phase** — if it naturally extends an existing phase's scope.
      - After the user confirms, update `ROADMAP.md` immediately using the Edit tool.

   c. **Repeat** until the user says they have no more changes.

4. After the review (or skip), continue with On Start step 6.

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
