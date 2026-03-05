# /pause

Pause the current phase and switch to another phase. Saves all current state so it can be resumed later via `/resume`.

Model tier: light

## On Start

1. Read `.workflow/state.md` to identify the active phase.
2. If there is no active phase (Step: not started, no Phase set), tell the user: "No active phase to pause." and stop.
3. If the active phase step is `not started`, warn the user: "Phase N hasn't started yet — nothing to pause. Did you mean a different phase?" and use `AskUserQuestion` to confirm or cancel.

## Process

### 1. Summarise what's being paused

Show the user a brief summary of the active phase state:

```
Pausing: Phase N — [Name]
Step:    [current step]
Plan step: [implementation step] (if implement step is set)
Model tier: [detected tier]
```

**Detecting model tier**: Read the system prompt ("You are powered by the model named…") and map to tier:
- Opus → heavy
- Sonnet → standard
- Haiku → light

### 2. Choose the target phase

Use `AskUserQuestion` to ask: "Which phase do you want to switch to?"

To build the option list:
- Read `ROADMAP.md` and find all phases with status `Not started` or in-progress (not `Complete`) other than the current phase.
- Present up to 4 options as numbered phases. If more than 4 incomplete phases exist, list the next 3 numerically after the current phase, plus an "Other — I'll specify" option.
- If no other incomplete phases exist, tell the user: "No other incomplete phases found. You can still pause, but there's nothing to switch to — you'll resume this phase next session." Confirm with `AskUserQuestion` (options: "Pause anyway" / "Cancel").

### 3. Interactive blocking check

Before switching, run a brief blocking assessment:

Output:
> **Blocking check**: Does Phase [target] depend on incomplete work from Phase [current]?

Ask one question via `AskUserQuestion`:
- "Does the target phase need anything from Phase [current] that isn't done yet?" Options:
  - "No — they're independent" — proceed.
  - "Yes — there's a dependency" — warn: "Switching may cause problems later. Proceed anyway, or choose a different target phase?" Options: "Proceed anyway" / "Choose a different phase" (return to step 2) / "Cancel".

Use your judgement to help assess: if the current phase name suggests foundational work (e.g., "State Tracking", "Data Model") and the target phase name suggests building on it (e.g., "API Integration", "UI Layer"), surface a dependency concern proactively before the user answers.

### 4. Save pause state and switch active phase

**About to**: save pause state for Phase [N] and switch active phase to Phase [M]
**Why**: user confirmed the phase switch; no blocking issues
**Affects**: `.workflow/state.md` (paused phases section added; active phase fields updated)

Use `AskUserQuestion` to confirm (options: "Confirm pause and switch" / "Cancel").

After confirmation:

**Write the paused entry** — append to `.workflow/state.md`:

If the file does not yet have a `## Paused Phases` section, add it after the last active-phase field and before any existing trailing content. Format:

```markdown
## Paused Phases

### Phase N — [Name]
- Step: [step]
- Implementation Step: [N or —]
- Research Tier: [tier or —]
- Model Tier: [heavy/standard/light]
- Subphase: [N of M or —]
- Paused: [YYYY-MM-DD]
```

If `## Paused Phases` already exists, append a new `### Phase N` block inside it.

**Update the active phase fields** in `.workflow/state.md`:

```
- **Phase**: [target phase number]
- **Phase Name**: [target phase name]
- **Step**: not started
- **Implementation Step**: —
- **Research Tier**: —
- **Next Command**: /discuss
```

Remove the `Subphase` field entirely if switching to a new phase (it only applies to the active phase).

### 5. Confirm to the user

Tell the user:

**Phase [N] paused.** Switched to Phase [M]: [name].

Type `/discuss` to begin Phase [M], or `/resume` at any time to come back to Phase [N].
