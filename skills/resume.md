# /resume

Resume a previously paused phase. Restores all saved state and returns you to exactly where you left off.

Model tier: light

## On Start

1. Read `.workflow/state.md`.
2. Check for a `## Paused Phases` section.
3. If no `## Paused Phases` section exists, or it is empty: tell the user "No paused phases found." and stop.

## Process

### 1. Select the phase to resume

**If one paused phase**: offer to resume it directly — show a brief one-line summary (Phase N — [Name], paused [date]) and confirm with `AskUserQuestion` (options: "Resume" / "Cancel").

**If multiple paused phases**: present a numbered list and use `AskUserQuestion` to let the user choose. Format each option as: "Phase N — [Name] (paused [date], step: [step])".

### 2. Show the resume summary card

Once a phase is selected, show:

```
Resuming: Phase N — [Name]
Step:          [step]
Plan Step:     [implementation step] of [total — read from PLAN.md if available] — [step name if available]
Model Tier:    [heavy/standard/light] ([model name] recommended)
Subphase:      [N of M] (omit this line if —)
Paused:        [date]
```

**Reading plan step total**: If step is `implement` and implementation step is set:
- Read `planning/phase-N/PLAN.md` (or `planning/phase-N/sub-X/PLAN.md` if a subphase was set).
- Find the step heading matching the implementation step number to get the step name.
- Count total steps for the "of [total]" part.
- If the Current Step marker in PLAN.md does not match the saved Implementation Step, warn: "Note: PLAN.md Current Step marker shows Step [X], but saved state says Step [Y]. The plan may have been updated while paused."

**Model tier mapping** (for the recommended model display):
- heavy → Opus (`claude-opus-4-6`)
- standard → Sonnet (`claude-sonnet-4-6`)
- light → Haiku (`claude-haiku-4-5-20251001`)

### 3. Model-check

If the model tier from the paused state differs from the currently active model (detected from system prompt injection "You are powered by the model named…"):

State the mismatch clearly:
> "Phase [N] was paused on [tier] tier ([model name]). You're currently on [current model]."

Tell the user how to switch:
> "To switch: type `/model [model-alias]` in Claude Code (conversation history is preserved)."

Then use `AskUserQuestion` with options: "Switched — ready to continue" / "Continue on [current model] anyway."

Wait for the user's response before proceeding.

### 4. Ask where to resume

Use `AskUserQuestion`:

**If step is `implement`** (implementation step is set):
- Default option: "Step [N] (default)" — resume at the exact saved step.
- "Show full plan first" — read and display the PLAN.md steps, then ask again.
- "Choose a different step" — use `AskUserQuestion` with a list of plan step numbers and names.

**If step is any other workflow step** (discuss, research, plan, test, close-out):
- Tell the user: "Resuming at the [step] step — type `/[step-command]` after state is restored."
- No step selection needed.

### 5. Restore state

**About to**: restore Phase [N] as the active phase
**Why**: user confirmed resume
**Affects**: `.workflow/state.md` (active phase fields restored; paused entry removed)

Use `AskUserQuestion` to confirm (options: "Confirm resume" / "Cancel").

After confirmation, update `.workflow/state.md`:

**Active phase fields** — restore from the paused entry:
```
- **Phase**: [N]
- **Phase Name**: [Name]
- **Step**: [step]
- **Implementation Step**: [N or —]
- **Research Tier**: [tier or —]
- **Next Command**: /[appropriate-command]
```

**Subphase field** — restore if the paused entry had a Subphase value other than `—`. If `—`, omit the Subphase field entirely from state.md.

**Next Command mapping**:
- `discuss (complete)` → `/research`
- `research (complete)` → `/plan`
- `plan (approved)` → `/implement`
- `implement` → `/implement`
- `test` → `/test`
- `close-out` → `/close-out`
- `not started` → `/discuss`

**Remove the paused entry**: Delete the `### Phase N — [Name]` block and all its fields from the `## Paused Phases` section. If the section is now empty (no remaining `###` blocks), remove the entire `## Paused Phases` section from the file.

### 6. Confirm to the user

Tell the user:

**Phase [N] resumed** at [step].

Type `/[next-command]` to continue.
