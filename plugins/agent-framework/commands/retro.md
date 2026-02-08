---
description: Milestone retrospective — review and improve the process
allowed-tools: [Read, Glob, Grep]
---

# /retro

Run a framework retrospective — review the workflow itself, not just the project.

## When to Use

- At milestone completion (prompted by `/close-out`)
- On user request at any natural stopping point
- If no milestones are defined, suggest after every 3-5 phases via `AskUserQuestion`

## Process

1. **Gather inputs**: Read all POSTMORTEM.md files from the milestone's phases. Focus on the **Process Notes** subsections.
2. **Evaluate the framework**:
   - Which CLAUDE.md rules actively helped?
   - Which rules were ignored, bypassed, or caused friction?
   - What situations came up that the framework didn't cover?
   - Were approval gates too strict, too loose, or well-calibrated?
   - Did the research depth tiers match phase complexity?
   - Did handoffs work smoothly across sessions?
3. **Categorise proposed changes**:
   - **Process changes** → update `CLAUDE.md`
   - **Project-specific lessons** → update `PROJECT.md`
   - **Remove or simplify** → rules that added friction without value
4. **Present proposals** via `AskUserQuestion` — clearly separating CLAUDE.md changes from PROJECT.md changes. Get approval before writing.
5. **Create** `planning/milestone-[name]/RETROSPECTIVE.md` with:
   - Phases Reviewed
   - What Worked
   - What Didn't Work
   - What Was Missing
   - Changes Made (CLAUDE.md / PROJECT.md / Removed or Simplified)

## On Completion

Update `.workflow/state.md` to point to the next milestone's first phase:
```
- Phase: [next phase number]
- Phase Name: [next phase name]
- Step: not started
- Next Command: /discuss
```

Tell the user:
> Retrospective complete. RETROSPECTIVE.md created.
> Next: type `/discuss` to start **Phase [N]: [name]**.
