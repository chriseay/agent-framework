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

For subtasks that don't require the current session's model, consider dispatching to a lighter model:

**Codex dispatch** — for simple, mechanical subtasks (adding docstrings, renaming variables, formatting files, moving code):

```bash
bash codex-dispatch.sh "task description"
```

Codex runs in a sandbox and returns the result. Always review the output before continuing. Do not dispatch tasks that require complex reasoning or multi-file coordination.

**Lighter Claude subagents** — when the current session runs a heavier model than a subtask needs, dispatch via the Task tool with an explicit `model` parameter:

```
Task tool → model: haiku (for simple lookups, formatting)
Task tool → model: sonnet (for moderate reasoning, test interpretation)
```

Always set the `model` parameter explicitly — do not rely on model inheritance (known bug #5456). Only dispatch self-contained subtasks that don't require the full session context.

## Implementation Rules

- Follow the plan steps in order.
- After completing each step, **update the Current Step marker** in PLAN.md.
- If deviation is needed, explain why and use `AskUserQuestion` to get approval.
- If a new requirement is discovered, **do not add it to the current phase**. Record it in the Deferred Actions section of `ROADMAP.md`.

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
> Implementation complete. All [N] plan steps finished.
> Next: type `/test` to verify the implementation.
