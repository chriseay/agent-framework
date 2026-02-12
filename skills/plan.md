# /plan

Create an implementation plan that builds on the discuss and research findings. Includes an automatic verification check before asking the user to approve.

Model tier: heavy

## On Start

1. Read `.workflow/state.md` to identify the current phase.
2. Note the model tier for this phase: `heavy`. Include it in the status block.
3. Read `planning/phase-XX/CONTEXT.md` and `planning/phase-XX/RESEARCH.md`.
4. Read `ROADMAP.md` for the phase deliverables.

## Process

1. Create `planning/phase-XX/PLAN.md` that:
   - References the roadmap phase and CONTEXT.md requirements.
   - Breaks work into concrete, ordered steps.
   - Incorporates relevant findings from RESEARCH.md.
   - Calls out constraints and risks identified during research.
   - Includes verification steps (build, test, manual checks).
   - Includes a `Current Step: 0` marker at the top of the Steps section.
   - **Assigns a model tier to each step** based on complexity. Include the tier inline in the step heading: `### Step N: Description (Tier: heavy/standard/light/codex)`. Steps that match the phase's default tier may omit the annotation — only annotate steps that should route to a different model. See the **Tier Assignment Guide** below for heuristics.
2. If the plan is complex, use `EnterPlanMode` for structured exploration before writing PLAN.md.

## Tier Assignment Guide

Assign tiers to plan steps based on what the step involves. The phase's default tier (from the skill file's `Model tier:` annotation) applies to unannotated steps.

| Tier | Use when the step involves... |
|------|-------------------------------|
| heavy | Multi-file code changes, architectural decisions, complex reasoning, debugging |
| standard | Single-file edits with moderate logic, test writing, investigation, summarisation |
| light | Doc updates, README changes, config tweaks, simple lookups, formatting |
| codex | Mechanical transforms (rename, reformat, move code) — if Codex CLI available |

When in doubt, leave the step unannotated (it inherits the phase default). Prefer routing down only when you're confident the step is self-contained and doesn't need the heavier model's reasoning.

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

> **Plan approved.** PLAN.md created with [N] steps.
>
> Next → type `/implement` to start building on a feature branch.
