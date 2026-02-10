# /discuss

Clarify requirements for the current phase before any other work.

Model tier: light

## On Start

1. Read `.workflow/state.md` to identify the current phase.
2. Note the model tier for this phase: `light`. Include it in the status block.
3. Read `ROADMAP.md` to get the phase deliverables.
4. Read any existing `planning/phase-XX/CONTEXT.md` (if resuming).
5. Present the phase goal to the user.
6. **Surface GitHub issues** (if `gh` CLI is available):
   - Run `gh issue list --limit 10` and show a summary of open issues to the user.
   - If there are open issues, use `AskUserQuestion` to ask whether any should be linked to this phase.
   - If the user selects issues to link, record them in the `## Linked Issues` section of CONTEXT.md (format: `- #<number> — <title>`).
   - If `gh` is not available, skip this step silently.

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
