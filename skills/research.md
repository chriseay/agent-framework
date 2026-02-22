# /research

Investigate the codebase, constraints, and risks before planning.

Model tier: standard

## On Start

1. Read `.workflow/state.md` to identify the current phase.
2. Note the model tier for this phase: `standard`. Include it in the status block.
   **Model check**: This phase runs at standard tier — recommended model: Sonnet.
   Detect the current model from the system prompt ("You are powered by the model named…").
   If the current model does not match this tier:
   - State the mismatch clearly (e.g., "This phase needs Sonnet; you're currently on Opus.").
   - Use `AskUserQuestion` with options: "Switched — ready to continue" / "Continue on [current model] anyway."
   Wait for the user's response before proceeding to the next On Start step.
3. Read `planning/phase-XX/CONTEXT.md` to understand the requirements.
4. Propose a research depth tier and get user confirmation.

## Research Depth Tiers

| Tier | When to Use | Scope |
|------|-------------|-------|
| **Light** | Simple phases with minimal unknowns (UI tweaks, doc updates, small features with clear requirements) | Quick codebase scan of directly affected files. No online research. Brief risk check. |
| **Standard** | Most phases — moderate complexity, some integration points | Codebase review of affected files and integration points. Data flow and state implications. Basic online search for constraints or risks. Suggested solutions. |
| **Deep** | Complex or risky phases (migrations, new infrastructure, unfamiliar technology, persistence changes, multiple platform-dependent unknowns, features with significant hardware/environment variability) | Full codebase review including indirect dependencies. Detailed integration point mapping. Thorough online research with cited sources. Risk matrix with mitigations. Feasibility assessment or prototype recommendation if warranted. |

Output:
> **About to**: confirm the research depth tier before beginning investigation
> **Why**: the depth tier determines scope, time, and resources for this phase's research
> **Affects**: the research process and RESEARCH.md deliverable

Use `AskUserQuestion` to propose a tier with a brief rationale and get confirmation.

## Process

1. Execute research according to the tier scope:
   - Use `Grep` and `Glob` for targeted codebase searches.
   - Use `Explore` subagents (via `Task` tool) for broader investigation.
   - **Wait for all subagent results to return before proceeding.** Do not write RESEARCH.md or advance to the next step until every dispatched Task has completed and its output has been incorporated.
   - For Standard and Deep tiers, include online research.
2. **Escalation rule**: If Standard research surfaces significant unknowns, platform-dependent risks, or unfamiliar technology, output:
   > **About to**: upgrade research depth from Standard to Deep
   > **Why**: [one-sentence explanation of what was found that warrants deeper investigation]
   > **Affects**: research scope, time, and RESEARCH.md depth

   Then propose upgrading to Deep via `AskUserQuestion` before continuing.
3. **Intuition-based tier override**: At any point during research, if you detect any of the following signals, stop and recommend a model change before continuing:
   - The scan returns significantly more files or complexity than the phase annotation assumed.
   - The research surfaces unfamiliar technology or cross-system integration points not visible at the start.
   - The task turns out to be clearly mechanical (e.g., a simple status lookup) and the annotated tier feels excessive.
   When triggered: output a one-line justification (e.g., "This research turned out to involve 3 unfamiliar subsystems — Opus recommended.") and use `AskUserQuestion` with options: "Switch to [recommended model] — ready to continue" / "Continue on current model."
4. After research, use `AskUserQuestion` for any remaining clarifying questions — one at a time.

## Artifact

Create `planning/phase-XX/RESEARCH.md` with tier-appropriate sections:

**Light**:
- Scope Reminder
- Codebase Review
- Risks / Unknowns

**Standard**:
- Scope Reminder
- Codebase Review
- Data Flow / State Implications
- Online Research
- Risks / Unknowns To Carry Into Planning
- Suggested Solutions / Adjustments

**Deep**:
- Scope Reminder
- Codebase Review
- Data Flow / State Implications
- Online Research
- Risk Matrix (likelihood, impact, mitigation)
- Suggested Solutions / Adjustments
- Feasibility Assessment
- Sources Consulted

## On Completion

Update `.workflow/state.md`:
```
- Step: research (complete)
- Research Tier: [light/standard/deep]
- Next Command: /plan
```

Tell the user:

**Research complete** ([tier]). RESEARCH.md created.

Key findings:
- [bullet 1]
- [bullet 2]

Next → type `/plan` to create the implementation plan.
