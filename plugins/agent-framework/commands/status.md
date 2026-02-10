---
description: Show current position and next command
allowed-tools: [Read, Glob, Grep, Bash]
---

# /status

Show the current workflow position and next command. Can be run at any time.

## Process

1. Read `.workflow/state.md`.
2. If mid-phase, read `planning/phase-XX/PLAN.md` for the Current Step marker.
3. Read `ROADMAP.md` for overall progress.

4. **Show GitHub issue counts** (if `gh` CLI is available):
   - Run `gh issue list --state open --json number --jq 'length'` to get the open issue count.
   - If `planning/phase-XX/CONTEXT.md` exists and has a `## Linked Issues` section, count the linked issues.
   - If `gh` is not available, skip this step silently.

## Output

Present to the user:

```
Phase:       [number] — [name]
Step:        [current workflow step]
Plan step:   [N of M] (if implementing)
Milestone:   [name] (if defined)
Issues:      [N open] ([M linked to phase]) (if gh available)
Next:        type `/[command]` to continue
```

Then show a brief progress summary:
- Phases complete: [N of total]
- Current phase deliverable: [from ROADMAP.md]
- Deferred items: [count, if any]
