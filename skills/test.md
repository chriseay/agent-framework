# /test

Verify the implementation works before proposing commits.

Model tier: standard

## On Start

1. Read `.workflow/state.md` to identify the current phase.
2. Note the model tier for this phase: `standard`. Include it in the status block.
3. Read `planning/phase-XX/PLAN.md` for the verification steps defined in the plan.

## Process

1. **Automated verification**: Propose running builds/tests. Requires user approval each time.
2. **Manual verification**: Use `AskUserQuestion` to ask the user to perform checks that require local environment access (simulators, devices, browser). Be specific about what to do and what to expect.
3. **Collect results**: Record what passed and what failed.
4. If tests fail, follow the Recovery rules from `/implement` — one fix attempt, then escalate.

## Rules

- Do not propose commits or lessons learned until verification is complete.
- If manual checks are deferred (e.g., device-only features), record the deferral in `ROADMAP.md` Deferred Actions with the follow-up phase.

## On Completion

Update `.workflow/state.md`:
```
- Step: test (complete)
- Next Command: /close-out
```

Tell the user:
> Verification complete. [Summary of results — what passed, what's deferred.]
> Next: type `/close-out` to wrap up the phase.
