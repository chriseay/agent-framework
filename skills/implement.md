# /implement

Execute the approved plan. This command handles branching, implementation, and the Current Step marker.

Model tier: heavy

## On Start

1. Read `.workflow/state.md` to identify the current phase and implementation step.
2. Note the model tier for this phase: `heavy`. Include it in the status block.
   **Model check**: This phase runs at heavy tier — recommended model: Opus.
   Detect the current model from the system prompt ("You are powered by the model named…").
   If the current model does not match this tier:
   - State the mismatch clearly (e.g., "This phase needs Opus; you're currently on Sonnet.").
   - Tell the user how to switch: "To switch, type `/model opus` in Claude Code (conversation history is preserved)."
   - Use `AskUserQuestion` with options: "Switched — ready to continue" / "Continue on [current model] anyway."
   Wait for the user's response before proceeding to the next On Start step.
3. PLAN.md path resolution:
   - Read the **Subphase** field from `.workflow/state.md`.
   - If the field is set (e.g., `Subphase: 2 of 3`): resolve the plan path as `planning/phase-XX/sub-N/PLAN.md` where N is the current subphase number (e.g., `sub-2/PLAN.md`).
   - If the field is absent: resolve the path as `planning/phase-XX/PLAN.md` (standard behaviour — no change).
   - Read the resolved PLAN.md and check the Current Step marker to determine where to resume.
4. Research Note check:
   - Scan the resolved PLAN.md for a `## Research Note` section.
   - If present: surface the recommendation via `AskUserQuestion` — "This subphase has a research note: [topic]. Run targeted research before implementing?" Options: "Yes, investigate first" / "No, proceed".
   - If the user approves: perform targeted investigation using Grep/Glob/Read as needed, then record findings in `planning/phase-XX/sub-N/RESEARCH.md` before continuing.
5. If no feature branch exists yet, output:
   **About to**: create a new feature branch
   **Why**: all implementation work must happen on a feature branch, not on main
   **Affects**: local git repo (new branch from HEAD)

   Then propose a branch name via `AskUserQuestion` and create it after approval.

## Git Rules

- Always work on a feature branch.
- Commits should be **atomic** (one concern per commit) with **Conventional Commit** messages: `feat(search): add room filter`, `docs(readme): update status`, `fix(auth): handle expired token`.
- Split changes by concern — feature, config, docs, tests — into separate commits.
- If a phase is delivered in a single commit, briefly state why splitting wasn't warranted.
- For complex changes, use verbose messages: summary line + bullet points.
- Before each commit, output:
  **About to**: commit [N file(s)] — [brief description of what's changing]
  **Why**: [one-sentence reason — e.g., "completing Step N: [step name]"]
  **Affects**: [list of files being committed]

  Then use `AskUserQuestion` to confirm the commit message before committing.
- Before each push, output:
  **About to**: push branch `[branch-name]` to `origin/[branch-name]`
  **Why**: [one-sentence reason — e.g., "making changes available for review / CI"]
  **Affects**: remote origin; branch will be visible to collaborators

  Then propose the target branch. Pushes require explicit approval.
- All source-control actions involving local and remote state must be performed together once approved.

## Model-Aware Dispatch

Plan steps may include a tier annotation in the heading: `### Step N: Description (Tier: heavy/standard/light/codex)`. Steps without an annotation inherit the phase's default tier.

### Dispatch checkpoint (mandatory)

**Before executing each step**, output a dispatch checkpoint:

```
Step N: [description]
Tier: [annotated tier] | Current model: [model] | Action: [local / dispatch to Haiku / dispatch to Sonnet / codex-dispatch]
```

This makes the routing decision visible. Do not skip this checkpoint — if the step's tier differs from the current model, you **must** dispatch. Executing a lighter-tier step locally on a heavier model is a visible deviation that wastes tokens.

### Per-step dispatch

After the checkpoint:

1. **If the tier matches the current model** (or the step has no annotation), execute the step normally.
2. **If the tier is lighter** (`standard`, `light`), dispatch to a subagent:
   - Use the `Task` tool with `subagent_type: general-purpose` and the `model` parameter set explicitly (`haiku` for light, `sonnet` for standard). Never rely on model inheritance.
   - The prompt must be **self-contained**: include the full step description, relevant file paths, the content of any files the subagent needs to read or edit, and success criteria. The subagent does not have session context.
3. **If the tier is `codex`**, use Codex dispatch (see below). Do not execute codex-tier steps locally.
4. **Wait for the subagent's Task result to return fully before reviewing or continuing.** Do not advance to the next step until the dispatched Task has completed. Then review the output — if it looks wrong or incomplete, escalate via `AskUserQuestion`.
5. **Graceful degradation**: If dispatch fails (model parameter error, subagent crash), log the failure and execute the step locally. Do not crash the workflow.

### Intuition-based tier override

During any step, if you detect any of the following signals, stop and recommend a model change before continuing:
- The step's actual scope is significantly larger than the plan annotation assumed (e.g., plan said "edit 2 files", discovery reveals 8+).
- The step requires multi-system architectural decisions not anticipated at plan time.
- A code generation step is producing interdependent changes where one error could cascade.
- The step turns out to be clearly mechanical and repetitive (rename, reformat, status update) but is annotated at `standard` or `heavy`.

When triggered: output a one-line justification (e.g., "This step involves 12 files — Opus recommended.") and use `AskUserQuestion` with options: "Switch to [recommended model] — ready to continue" / "Continue on current model."

### Codex dispatch

Steps annotated `(Tier: codex)` **must** be dispatched to Codex CLI. Do not execute them locally.

```bash
bash codex-dispatch.sh "task description" --dir /path/to/project
```

Codex runs in a sandbox and returns the result. Always review the output before continuing. Only use Codex for mechanical, self-contained tasks — not complex reasoning or multi-file coordination.

### Dispatch summary

At the end of implementation (before On Completion), output a dispatch summary:

```
Dispatch report: N local, M dispatched (X to Haiku, Y to Sonnet, Z to Codex)
```

## Implementation Rules

- Follow the plan steps in order.
- After completing each step, **update the Current Step marker** in PLAN.md.
- If deviation is needed, output:
  **About to**: deviate from the approved plan
  **Why**: [explain what was discovered and why the plan step cannot be followed as written]
  **Affects**: [which plan steps are affected; what alternative approach is proposed]

  Then use `AskUserQuestion` to get approval before proceeding with the deviation.
- If a new requirement is discovered, **do not add it to the current phase**. Output:
  **About to**: defer a new requirement to ROADMAP.md
  **Why**: new scope discovered during implementation; adding it now would break the approved plan
  **Affects**: `ROADMAP.md` (Deferred Phases or Deferred Verifications section)

  Then record it in `ROADMAP.md` under the appropriate section — `## Deferred Phases` (if it needs its own phase cycle) or `## Deferred Verifications` (if it's a check to perform later). Propose a category based on context and use `AskUserQuestion` to confirm.

## Recovery

If something goes wrong:

- **Try one fix** for clear errors (missing import, typo, obvious logic error).
- If the fix doesn't work, output:
  **About to**: escalate a failure that could not be resolved with one fix attempt
  **Why**: [one-sentence summary of the error and what was tried]
  **Affects**: current plan step; may require returning to `/plan` or a different approach

  Then **stop and escalate** via `AskUserQuestion` with: what you attempted, the error, suspected root cause, and proposed options.
- **Never** retry the same approach or suppress errors.

Scenario-specific:
- **Build failure**: Fix the root cause, not symptoms. Escalate if unclear.
- **Test failure**: Distinguish real bugs from flaky tests. Never silently modify tests.
- **Bad commit**: Output:
  **About to**: propose a revert commit to undo a bad commit
  **Why**: [describe what is wrong with the commit]
  **Affects**: git history on the feature branch; never force-push/amend/rebase without approval

  Then propose the revert via `AskUserQuestion`. Never force-push/amend/rebase without approval.
- **Branch in bad state**: Propose options (stash, find last good commit, cleanup plan).
- **Schema corruption**: Propose store reset with approval. Record as lesson learned.
- **Wrong approach**: Stop immediately. Propose returning to `/plan` with a revised approach.
- **Merge conflicts**: Resolve carefully, show resolution before committing. Escalate if extensive.

## On Completion

1. Output:
   **About to**: push feature branch `[branch-name]` to `origin/[branch-name]`
   **Why**: implementation is complete; pushing for review and handoff to `/test`
   **Affects**: remote origin; branch will be visible to collaborators

   Then use `AskUserQuestion` to confirm the push target before pushing.
2. Update `.workflow/state.md`:
```
- Step: implement (complete)
- Implementation Step: [final step number]
- Next Command: /test
```
3. Tell the user:

**Implementation complete.** All [N] plan steps finished.

Next → type `/test` to verify the changes.
