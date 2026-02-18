# /implement

Execute the approved plan. This command handles branching, implementation, and the Current Step marker.

Model tier: heavy

## On Start

1. Read `.workflow/state.md` to identify the current phase and implementation step.
2. Note the model tier for this phase: `heavy`. Include it in the status block.
3. Read `planning/phase-XX/PLAN.md` — check the Current Step marker to determine where to resume.
4. If no feature branch exists yet, propose a branch name via `AskUserQuestion` and create it after approval.

## Git Rules

- Always work on a feature branch.
- Commits should be **atomic** (one concern per commit) with **Conventional Commit** messages: `feat(search): add room filter`, `docs(readme): update status`, `fix(auth): handle expired token`.
- Split changes by concern — feature, config, docs, tests — into separate commits.
- If a phase is delivered in a single commit, briefly state why splitting wasn't warranted.
- For complex changes, use verbose messages: summary line + bullet points.
- Use `AskUserQuestion` to confirm commit messages before each commit.
- Pushes require explicit approval. Propose the target branch first.
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
- If deviation is needed, explain why and use `AskUserQuestion` to get approval.
- If a new requirement is discovered, **do not add it to the current phase**. Record it in `ROADMAP.md` under the appropriate section — `## Deferred Phases` (if it needs its own phase cycle) or `## Deferred Verifications` (if it's a check to perform later). Propose a category based on context and use `AskUserQuestion` to confirm.

## Recovery

If something goes wrong:

- **Try one fix** for clear errors (missing import, typo, obvious logic error).
- If the fix doesn't work, **stop and escalate** via `AskUserQuestion` with: what you attempted, the error, suspected root cause, and proposed options.
- **Never** retry the same approach or suppress errors.

Scenario-specific:
- **Build failure**: Fix the root cause, not symptoms. Escalate if unclear.
- **Test failure**: Distinguish real bugs from flaky tests. Never silently modify tests.
- **Bad commit**: Propose a revert commit. Never force-push/amend/rebase without approval.
- **Branch in bad state**: Propose options (stash, find last good commit, cleanup plan).
- **Schema corruption**: Propose store reset with approval. Record as lesson learned.
- **Wrong approach**: Stop immediately. Propose returning to `/plan` with a revised approach.
- **Merge conflicts**: Resolve carefully, show resolution before committing. Escalate if extensive.

## On Completion

1. Push the feature branch to origin. Use `AskUserQuestion` to confirm the push target before pushing.
2. Update `.workflow/state.md`:
```
- Step: implement (complete)
- Implementation Step: [final step number]
- Next Command: /test
```
3. Tell the user:

**Implementation complete.** All [N] plan steps finished.

Next → type `/test` to verify the changes.
