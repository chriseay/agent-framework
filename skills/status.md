# /status

Show the current workflow position and next command. Can be run at any time.

Model tier: light

## Process

1. Read `.workflow/state.md`.
2. If mid-phase, read `planning/phase-XX/PLAN.md` for the Current Step marker.
3. Read `ROADMAP.md` for overall progress.
4. Read the skill file for the current/next phase to determine the model tier. If `PROJECT.md` has a "Model Routing" section, check for overrides.

5. **Show GitHub issue counts** (if `gh` CLI is available):
   - Run `gh issue list --state open --json number --jq 'length'` to get the open issue count.
   - If `planning/phase-XX/CONTEXT.md` exists and has a `## Linked Issues` section, count the linked issues.
   - If `gh` is not available, skip this step silently.

## Output

Present to the user:

```
Phase:       [number] — [name]
Step:        [current workflow step]
Model:       [tier] ([model name])
Plan step:   [N of M] (if implementing)
Subphase:    [N of M] (if in a subphase cycle)
Milestone:   [name] (if defined)
Issues:      [N open] ([M linked to phase]) (if gh available)
Next:        type `/[command]` to continue
```

Only show the `Subphase` line when the **Subphase** field is set in `.workflow/state.md`. Omit it entirely otherwise.

Then show a brief progress summary:
- Phases complete: [N of total]
- Current phase deliverable: [from ROADMAP.md]
- Deferred phases: [count, if any]
- Deferred verifications: [count, if any]
