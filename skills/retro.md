# /retro

Run a framework retrospective — review the workflow itself, not just the project.

Model tier: standard

## When to Use

- At milestone completion (prompted by `/close-out`)
- On user request at any natural stopping point
- If no milestones are defined, suggest after every 3–5 phases via `AskUserQuestion`

## On Start

1. Read `.workflow/state.md` to identify the current milestone and phase.
2. Note the model tier for this phase: `standard`. Include it in the status block.
   Session-level model choice is your own — no confirmation prompt; call `advisor` per CLAUDE.md's Advisor Guidance if model fit is in doubt.

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
4. **Present proposals**: For each proposed change, output:
   **About to**: write changes to `CLAUDE.md` and/or `PROJECT.md`
   **Why**: applying the framework improvements identified in this retrospective
   **Affects**: `CLAUDE.md` (process rules), `PROJECT.md` (project-specific lessons)

   Then present via `AskUserQuestion` — clearly separating CLAUDE.md changes from PROJECT.md changes. Get approval before writing.
5. Before finalizing RETROSPECTIVE.md, call `advisor` per CLAUDE.md's Advisor Guidance — this is a floor, not the only point it may be called.
6. **Create** `planning/milestone-[name]/RETROSPECTIVE.md` with:
   - Phases Reviewed
   - What Worked
   - What Didn't Work
   - What Was Missing
   - Changes Made (CLAUDE.md / PROJECT.md / Removed or Simplified)
7. **Propose commit and push**: Output:
   **About to**: commit and push the retrospective changes
   **Why**: finalising the retrospective and recording it in the repo
   **Affects**: `RETROSPECTIVE.md`, `CLAUDE.md`, `PROJECT.md`, feature branch, remote origin

   Then propose for explicit approval. Use `AskUserQuestion` for each.
   - Commit message: `docs(retro): milestone [name] retrospective`
   - Include all files changed during the retro (RETROSPECTIVE.md, CLAUDE.md, PROJECT.md, any removed/modified files).

## On Completion

Update `.workflow/state.md` to point to the next milestone's first phase:
```
- Phase: [next phase number]
- Phase Name: [next phase name]
- Step: not started
- Next Command: /discuss
```

Tell the user:

**Retrospective complete.** RETROSPECTIVE.md created.

Next → type `/discuss` to start **Phase [N]: [name]**.
