# /test

Verify the implementation works before proposing commits.

Model tier: standard

## On Start

1. Read `.workflow/state.md` to identify the current phase.
2. Note the model tier for this phase: `standard`. Include it in the status block.
   **Model check**: This phase runs at standard tier — recommended model: Sonnet.
   Detect the current model from the system prompt ("You are powered by the model named…").
   If the current model does not match this tier:
   - State the mismatch clearly (e.g., "This phase needs Sonnet; you're currently on Opus.").
   - Tell the user how to switch: "To switch, type `/model sonnet` in Claude Code (conversation history is preserved)."
   - Use `AskUserQuestion` with options: "Switched — ready to continue" / "Continue on [current model] anyway."
   Wait for the user's response before proceeding to the next On Start step.
3. Read `planning/phase-XX/PLAN.md` for the verification steps defined in the plan.

## Process

1. **Automated verification**: Output:
   **About to**: run automated builds/tests
   **Why**: verifying the phase's implementation meets the plan's verification criteria
   **Affects**: local build environment; may produce output, artefacts, or failures

   Then propose running builds/tests. Requires user approval each time.
2. **Manual verification**: Output:
   **About to**: request manual verification steps from the user
   **Why**: some checks require local environment access (simulators, devices, browser) the agent cannot perform
   **Affects**: user's local environment; results will determine whether the phase passes verification

   Use `AskUserQuestion` to ask the user to perform checks that require local environment access (simulators, devices, browser). Be specific about what to do and what to expect.
3. **Collect results**: Record what passed and what failed.
4. If tests fail, output:
   **About to**: attempt one fix for the test failure, then escalate if it doesn't work
   **Why**: following the Recovery rule — one fix attempt before escalating to user
   **Affects**: source files related to the failing test

   Then follow the Recovery rules from `/implement` — one fix attempt, then escalate.

## Rules

- Do not propose commits or lessons learned until verification is complete.
- If manual checks are deferred (e.g., device-only features), record the deferral in `ROADMAP.md` under `## Deferred Verifications`. Note the originating phase.

## On Completion

Update `.workflow/state.md`:
```
- Step: test (complete)
- Next Command: /close-out
```

Tell the user:

**Verification complete.** [Summary of results — what passed, what's deferred.]

Next → type `/close-out` to wrap up the phase.
