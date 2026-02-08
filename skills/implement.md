# /implement

Execute the approved plan. This command handles branching, implementation, and the Current Step marker.

## On Start

1. Read `.workflow/state.md` to identify the current phase and implementation step.
2. Read `planning/phase-XX/PLAN.md` — check the Current Step marker to determine where to resume.
3. If no feature branch exists yet, propose a branch name via `AskUserQuestion` and create it after approval.

## Git Rules

- Always work on a feature branch.
- Commits should be **atomic** (one concern per commit) with **Conventional Commit** messages: `feat(search): add room filter`, `docs(readme): update status`, `fix(auth): handle expired token`.
- Split changes by concern — feature, config, docs, tests — into separate commits.
- If a phase is delivered in a single commit, briefly state why splitting wasn't warranted.
- For complex changes, use verbose messages: summary line + bullet points.
- Use `AskUserQuestion` to confirm commit messages before each commit.
- Pushes require explicit approval. Propose the target branch first.
- All source-control actions involving local and remote state must be performed together once approved.

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

Update `.workflow/state.md`:
```
- Step: implement (complete)
- Implementation Step: [final step number]
- Next Command: /test
```

Tell the user:
> Implementation complete. All [N] plan steps finished.
> Next: type `/test` to verify the implementation.
