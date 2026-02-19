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
3. **Tier Review** (mandatory): After drafting all steps, add a `## Tier Review` section to PLAN.md — a table listing each step, its assigned tier, and a one-line justification for the tier choice. Include this review in the plan summary presented to the user. If every step has the same tier, explain why differentiation wasn't possible.

## Tier Assignment Guide

Assign tiers to plan steps based on what the step involves. The phase's default tier (from the skill file's `Model tier:` annotation) applies to unannotated steps.

| Tier | Use when the step involves... |
|------|-------------------------------|
| heavy | Multi-file code changes, architectural decisions, complex reasoning, debugging |
| standard | Single-file edits with moderate logic, test writing, investigation, summarisation |
| light | Doc updates, README changes, config tweaks, simple lookups, formatting |
| codex | Mechanical transforms (rename, reformat, move code) — if Codex CLI available |

### Examples

| Example step | Tier | Why |
|---|---|---|
| Update README status section | light | Single file, prescribed content, no reasoning needed |
| Add a separator rule to CLAUDE.md | light | Appending a single line to an existing section |
| Run a script and review its output | standard | Moderate investigation, no architectural decisions |
| Write tests for an existing module | standard | Single-concern work following established patterns |
| Redesign the authentication middleware | heavy | Multi-file changes, architectural decisions, complex reasoning |
| Design new instructional language for a skill file | heavy | Requires careful wording that shapes future agent behaviour |
| Rename `oldFunc` to `newFunc` across the codebase | codex | Mechanical find-and-replace, no reasoning needed |
| Reformat a file to match a style guide | codex | Mechanical transform, deterministic output |

**Actively evaluate each step.** If the step is a single-file edit following a prescribed spec, route it down to a lighter tier. Only leave a step unannotated (inheriting the phase default) if it genuinely requires the phase-level model's reasoning. Defaulting everything to the phase tier wastes tokens and defeats the purpose of per-step routing.

## Subphase Check

After completing the Tier Review, assess whether the plan warrants splitting into subphases before presenting it to the user.

**When to propose a split**: Use your judgement. A useful heuristic is more than ~8 steps, or steps that span multiple large subsystems with independent test points where incremental delivery adds value. The heuristic is a guide — don't split a plan of 9 trivial steps just because the count exceeds 8.

**If a split is warranted**:

1. Use `AskUserQuestion` to propose the split. Include:
   - Total step count and why it warrants splitting
   - Suggested number of subphases and how you'd divide the steps (e.g., "Subphase 1: steps 1–5, Subphase 2: steps 6–10")
2. **If the user approves**:
   - Create `planning/phase-XX/sub-1/`, `sub-2/`, … directories.
   - Write a `PLAN.md` inside each, covering only that subphase's steps. Each sub-N/PLAN.md uses the standard PLAN.md format (References, Steps with Current Step marker, Constraints & Risks, Verification, Assumptions, Tier Review).
   - Do **not** create a main `planning/phase-XX/PLAN.md` — the sub-N/PLAN.md files are the plan.
   - Update `.workflow/state.md`: add `- **Subphase**: 1 of N` (where N = total number of subphases).
   - **Research Note flag**: If you judge that a specific subphase will need targeted research before implementation (e.g., it touches an unfamiliar module or introduces a significant unknown), add a `## Research Note` section at the top of that sub-N/PLAN.md specifying what needs investigation.
3. **If the user rejects the split**: proceed with the main `planning/phase-XX/PLAN.md` as created. Leave the Subphase field absent from state.md.

**If a split is not warranted**: proceed directly to Verify with the main PLAN.md. No subphase machinery is needed.

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

**Plan approved.** PLAN.md created with [N] steps.

Next → type `/implement` to start building on a feature branch.
