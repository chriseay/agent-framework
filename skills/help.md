# /help

Show available commands, the workflow, and suggest what to do based on current state.

## Process

1. Read `.workflow/state.md` for current position.
2. Present the command reference and current status.

## Output

Present to the user:

```
## Agent Framework — Commands

Setup:
  /new-project     Set up a new project from scratch
  /onboard         Scan an existing codebase and set up the workflow

Workflow (run in order for each phase):
  /discuss          Clarify requirements (one question at a time)
  /research         Investigate codebase and constraints
  /plan             Create and verify an implementation plan
  /implement        Execute the plan on a feature branch
  /test             Run automated and manual verification
  /close-out        Write postmortem, commit, merge

Other:
  /status           Show current position and next command
  /retro            Milestone retrospective
  /help             This message
```

Then check `.workflow/state.md` and add a contextual suggestion:

- If next command is `/new-project`: "You haven't set up a project yet. Start with `/new-project` (new code) or `/onboard` (existing codebase)."
- If next command is `/discuss`: "Ready to start **Phase [N]: [name]**. Type `/discuss` to begin."
- If mid-workflow: "You're in **Phase [N]**, currently at the **[step]** step. Type `/[next command]` to continue."
- If next command is `/retro`: "You've completed a milestone. Type `/retro` to review the process before starting the next one."
