# /status

Show the current workflow position and next command. Can be run at any time.

## Process

1. Read `.workflow/state.md`.
2. If mid-phase, read `planning/phase-XX/PLAN.md` for the Current Step marker.
3. Read `ROADMAP.md` for overall progress.

## Output

Present to the user:

```
Phase:       [number] — [name]
Step:        [current workflow step]
Plan step:   [N of M] (if implementing)
Milestone:   [name] (if defined)
Next:        type `/[command]` to continue
```

Then show a brief progress summary:
- Phases complete: [N of total]
- Current phase deliverable: [from ROADMAP.md]
- Deferred items: [count, if any]
