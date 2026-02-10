# /issues

List, view, create, edit, close, reopen, and comment on GitHub issues.

Model tier: light

## On Start

1. Read `.workflow/state.md` to identify the current phase.
2. Note the model tier for this command: `light`. Include it in the status block.
3. Check that `gh` CLI is available:
   - Run `command -v gh`. If missing, tell the user: "GitHub CLI (`gh`) is not installed. Install it from https://cli.github.com/ and run `gh auth login`." Then stop.
   - Run `gh auth status`. If not authenticated, tell the user: "GitHub CLI is not authenticated. Run `gh auth login` to set up access." Then stop.
4. Ensure framework labels exist. For each of `bug`, `feature`, `chore`, `deferred`:
   - Run `gh label create <name> --force`. If it fails (permission error), warn the user: "Could not create label `<name>` — you may not have write access to this repo. Continuing without label enforcement." Do not stop.

## Operations

Use `AskUserQuestion` to determine which operation the user wants, then follow the relevant section below. All mutation operations (create, edit, close, reopen, comment) require explicit user approval before executing.

### List

Show open issues by default:
```
gh issue list --limit 10
```

Offer filters via `AskUserQuestion`:
- By state: `--state open|closed|all`
- By label: `--label <name>`

### View

```
gh issue view <number>
```

Use `AskUserQuestion` to ask for the issue number if not provided.

### Create

Use `AskUserQuestion` to gather:
1. **Title**: Short summary
2. **Body**: Detailed description (optional)
3. **Label**: One of `bug`, `feature`, `chore`, `deferred`

Then show a preview and use `AskUserQuestion` to confirm before running:
```
gh issue create --title "..." --body "..." --label "..."
```

### Edit

Use `AskUserQuestion` to ask for the issue number and what to change (title, body, labels). Then show a preview and confirm before running:
```
gh issue edit <number> --title "..." --body "..." --add-label "..."
```

### Close

Use `AskUserQuestion` to confirm before running:
```
gh issue close <number>
```

### Reopen

Use `AskUserQuestion` to confirm before running:
```
gh issue reopen <number>
```

### Comment

Use `AskUserQuestion` to gather the comment text, then confirm before running:
```
gh issue comment <number> --body "..."
```

## On Completion

Tell the user the operation result. No state file updates — `/issues` is stateless.
