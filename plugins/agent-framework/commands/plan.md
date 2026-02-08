---
description: Create and verify an implementation plan
allowed-tools: [Read, Glob, Grep]
---

# /plan

Create an implementation plan that builds on the discuss and research findings. Includes an automatic verification check before asking the user to approve.

## On Start

1. Read `.workflow/state.md` to identify the current phase.
2. Read `planning/phase-XX/CONTEXT.md` and `planning/phase-XX/RESEARCH.md`.
3. Read `ROADMAP.md` for the phase deliverables.

## Process

1. Create `planning/phase-XX/PLAN.md` that:
   - References the roadmap phase and CONTEXT.md requirements.
   - Breaks work into concrete, ordered steps.
   - Incorporates relevant findings from RESEARCH.md.
   - Calls out constraints and risks identified during research.
   - Includes verification steps (build, test, manual checks).
   - Includes a `Current Step: 0` marker at the top of the Steps section.
2. If the plan is complex, use `EnterPlanMode` for structured exploration before writing PLAN.md.

## Verify (Automatic)

Before presenting the plan to the user, run this check:
- Confirm the plan does not contradict `CLAUDE.md`, `ROADMAP.md`, or `CONTEXT.md`.
- Confirm no steps are impossible or unsupported based on `RESEARCH.md`.
- Call out potential bugs, infeasible steps, or unaddressed risks.

If verification fails, revise the plan before presenting it.

## Present to User

Present the plan summary **inline** — key steps + verification approach. Do not ask the user to open the file.

Use `AskUserQuestion` to ask the user to approve, request changes, or reject.

## On Completion

Update `.workflow/state.md`:
```
- Step: plan (approved)
- Next Command: /implement
```

Tell the user:
> Plan approved.
> Next: type `/implement` to start building on a feature branch.
