# Getting Started with Agent Framework

Welcome! This tutorial walks you through building a real project — a bookmark manager CLI — using Agent Framework. By the end, you'll understand how structured AI coding sessions work and how to use them for your own projects.

## Who This Is For

You're probably a developer (or technically minded) who's heard about AI coding tools but hasn't used them seriously yet. Maybe you've tried autocomplete tools or chatted with AI about code, but you haven't experienced a full workflow where the AI helps you design, build, and ship a feature from start to finish.

That's what we'll do here.

## What You'll Build

A Node.js CLI that lets you save, list, and delete bookmarks. Simple enough to finish in one session, real enough to show how the framework handles the full cycle.

## The Workflow Overview

Here's the path we'll follow:

```
/new-project → /discuss → /research → /plan → /implement → /test → /close-out
```

Each command is a phase in the workflow. You don't skip steps — the framework guides you through each one, asking questions, creating documents, and building incrementally.

One thing to know upfront: **you're not expected to have all the answers.** When the agent asks you a question, you can always say "I'm not sure — what would you recommend?" and it'll propose a sensible default. You can also push back on anything ("actually, I'd prefer X") or ask for clarification ("what does that mean?"). It's a conversation, not a quiz.

Let's get started.

---

## Before You Start

The framework handles the workflow, but a few things need to be set up outside of it:

- **Git** — Your project needs to be a git repository. The framework creates branches, commits, and merges on your behalf (with your approval). If you haven't used git before, you'll want to get comfortable with the basics first.
- **Claude Code** — Anthropic's CLI for Claude. This is the AI agent that does the work. [Install it here](https://claude.ai/claude-code).
- **GitHub CLI** (optional but recommended) — If you want the framework to push code to a remote repository, create pull requests, and automatically track phases as GitHub Issues and Milestones, install the [GitHub CLI](https://cli.github.com/) and run `gh auth login`. Without it, the workflow still works locally — you just won't get remote version control or issue tracking integration.
- **Your project's runtime** — Whatever you're building with (Node.js, Python, etc.) needs to be installed. The agent will run commands like `npm install` or `pip install` during implementation, so the tools need to be there.

## Installation

Check the [README.md](README.md) for the bootstrap command — it's a one-liner that installs the framework and sets everything up.

Once installed, open Claude Code in your project directory:

```bash
mkdir bookmark-manager
cd bookmark-manager
git init
claude
```

You'll see the framework load and present a status message. If this is a brand new project, it'll say:

> No project set up yet. Type `/new-project` to get started.

Perfect. Let's do that.

---

## Setting Up Your Project (`/new-project`)

Type `/new-project` and press enter.

The agent will ask you a series of questions — **one at a time** (this is deliberate; the framework never batches questions). Here's what the conversation looks like:

**Agent:**
> What is this project? Describe what you're building in 1-2 sentences.

**You:**
> A command-line tool for managing bookmarks. Users can add, list, and delete URLs with optional tags.

**Agent:**
> What's your tech stack? (e.g., "Node.js + SQLite", "Python + FastAPI", "React + Tailwind")

**You:**
> Node.js

**Agent:**
> What should Phase 0 deliver? (This is your first milestone — typically core functionality or foundation setup.)

**You:**
> Core CLI — add, list, and delete bookmarks

The agent processes your answers and creates three files:

- **PROJECT.md** — Your tech stack, constraints, and lessons learned (grows over time)
- **ROADMAP.md** — All your phases, what's done, what's next, what's deferred
- **.workflow/state.md** — Where you are in the workflow (auto-updated by each command)

Then you'll see this status block:

```
Phase: 0 — Core CLI
Step:  new-project
Model: light (Haiku)
Next:  type `/discuss` to start Phase 0: Core CLI
```

The **Model** line shows which AI model is handling this step. The framework picks the right size automatically — lightweight models (Haiku) for simple conversations, mid-range models (Sonnet) for investigation and testing, and heavyweight models (Opus) for writing code and making architectural decisions. You don't need to think about this; it's just there so you can see what's happening under the hood.

And a transition message:

> **Project setup complete.** PROJECT.md, ROADMAP.md, and .workflow/state.md created. Next → type `/discuss` to start **Phase 0: Core CLI**.

**What just happened?**

You've defined your project's scope and broken it into phases. The framework now has context about what you're building and what "done" looks like for this phase. Everything from here on will reference these documents.

---

## Clarifying Requirements (`/discuss`)

Type `/discuss`.

The agent reads your roadmap and asks questions to flesh out the requirements. It's trying to understand **what** you want (not how to build it yet — that comes later).

**Agent:**
> You've defined Phase 0 as "Core CLI — add, list, and delete bookmarks". Let's clarify the requirements.
>
> Should bookmarks be stored persistently, or is this session-only?

**You:**
> Persistent. Use a JSON file in the user's home directory.

**Agent:**
> Should the CLI support tags or categories, or just URLs?

**You:**
> Let's support optional tags. When listing, show the URL and tags.

**Agent:**
> How should deletion work? By URL, by index, or something else?

**You:**
> By index — show a numbered list, then let the user delete by number.

Notice that you don't have to know the "right" answer to every question. If you're unsure about storage format, deletion strategy, or anything else, you can say "what do you recommend?" and the agent will suggest an approach. You can also say "let's keep it simple for now" and defer decisions to a later phase.

The agent captures all of this in `planning/phase-00/CONTEXT.md` — a structured summary of your requirements. It'll reference this later during planning and implementation.

When the conversation winds down, you'll see:

```
Phase: 0 — Core CLI
Step:  discuss
Model: light (Haiku)
Next:  type `/research` to investigate codebase and constraints
```

> **Discuss complete.** CONTEXT.md created for Phase 0. Next → type `/research` to investigate codebase and constraints.

**What just happened?**

You've documented the "what" — the requirements are now written down and agreed upon. The agent won't invent features or make assumptions during implementation; it'll build exactly what's in CONTEXT.md.

---

## Investigating Constraints (`/research`)

Type `/research`.

The agent asks you to choose a research tier:

**Agent:**
> Research mode — choose your tier:
>
> - **light**: Quick check (Haiku) — best for simple projects or when you know there are no tricky constraints
> - **standard**: Balanced investigation (Sonnet) — good default for most projects
> - **deep**: Thorough analysis (Opus) — use for complex codebases or unfamiliar tech
>
> Which tier?

**You:**
> standard

**Agent:**
> Investigating codebase and constraints...

The agent scans your project directory (currently empty except for the planning docs), checks for existing package.json or dependencies, and researches any relevant technical constraints (e.g., "How should we structure a Node.js CLI?").

It writes findings to `planning/phase-00/RESEARCH.md`. Here's an excerpt:

```markdown
## Technical Findings

- Project is greenfield (no existing code)
- Node.js CLI best practices:
  - Use `commander` or `yargs` for argument parsing
  - Store config in `~/.bookmark-manager/bookmarks.json`
  - Entry point: `bin/bookmark.js` with shebang
- No external API dependencies for core functionality
- JSON storage is sufficient for Phase 0 scope

## Constraints

- Must handle missing file gracefully (first run)
- Should validate URLs before storing
- Index-based deletion requires stable ordering
```

Then:

```
Phase: 0 — Core CLI
Step:  research
Model: standard (Sonnet)
Next:  type `/plan` to create the implementation plan
```

> **Research complete** (standard). RESEARCH.md created. Next → type `/plan` to create the implementation plan.

**What just happened?**

The agent investigated **how** to build what you've described. It looked for gotchas, best practices, and technical constraints. This research informs the plan you're about to create.

---

## Creating the Plan (`/plan`)

Type `/plan`.

The agent drafts a step-by-step implementation plan based on CONTEXT.md and RESEARCH.md. It shows you the plan and asks for approval:

**Agent:**
> Here's the implementation plan for Phase 0:
>
> ```markdown
> ## Step 1: Project setup and CLI scaffold
> - Initialise package.json
> - Install `commander` for argument parsing
> - Create `bin/bookmark.js` with shebang
> - Set up basic command structure (add/list/delete)
> - Add npm link support for local testing
>
> **Model tier:** standard
>
> ## Step 2: Add and list functionality
> - Implement storage module (read/write JSON to ~/.bookmark-manager/)
> - Add `bookmark add <url> [tags...]` command
> - Add `bookmark list` command with formatted output
> - Handle first-run case (create directory/file)
>
> **Model tier:** standard
>
> ## Step 3: Delete functionality and validation
> - Implement `bookmark delete <index>` command
> - Add URL validation for add command
> - Add error handling for invalid indices
> - Update README with usage examples
>
> **Model tier:** standard
> ```
>
> Approve this plan?

**You:**
> Yes

The agent writes this to `planning/phase-00/PLAN.md` and updates the workflow state.

```
Phase: 0 — Core CLI
Step:  plan
Model: heavy (Opus)
Next:  type `/implement` to start building on a feature branch
```

> **Plan approved.** PLAN.md created with 3 steps. Next → type `/implement` to start building on a feature branch.

**What if you don't approve?**

You're never locked in. If the plan doesn't look right, you can say "I'd like to change Step 2" or "can we split this into smaller steps?" and the agent will revise it. The same goes for commit messages, branch names, and merge decisions later — saying "no" doesn't break anything, it just opens a conversation about what you'd prefer instead.

**What just happened?**

You've agreed on the exact steps to build this phase. Notice the **tier annotations** on each step — the framework routes heavy architectural work to Opus, routine implementation to Sonnet, and simple lookups to Haiku. For this plan, everything's `standard` because it's straightforward Node.js code — no step needs Opus-level reasoning.

---

## Building It (`/implement`)

Type `/implement`.

The agent asks for approval to create a feature branch:

**Agent:**
> Ready to implement. I'll create a feature branch `feat/phase-0-core-cli` and work through the 3 plan steps.
>
> Approve branch creation and start implementation?

**You:**
> Yes

The agent creates the branch and starts executing Step 1. You'll see output like:

**Agent:**
> **Step 1/3:** Project setup and CLI scaffold
>
> Creating package.json...
> Installing commander...
> Writing bin/bookmark.js...
> Configuring npm link...
>
> Files created:
> - `/Users/you/bookmark-manager/package.json`
> - `/Users/you/bookmark-manager/bin/bookmark.js`
> - `/Users/you/bookmark-manager/lib/storage.js`
>
> Ready to commit. Proposed message:
> ```
> feat(phase-0): initialise CLI scaffold with commander
>
> - Set up package.json with bin entry
> - Add basic command structure (add/list/delete)
> - Configure npm link for local testing
> ```
>
> Approve commit?

**You:**
> Yes

The agent commits and moves to Step 2, then Step 3. Each step follows the same pattern: build → show changes → ask for commit approval.

After all steps complete:

```
Phase: 0 — Core CLI
Step:  implement
Model: heavy (Opus)
Next:  type `/test` to verify the changes
```

> **Implementation complete.** All 3 plan steps finished. Next → type `/test` to verify the changes.

**What just happened?**

The agent executed the plan, step by step, committing as it went. You approved each commit, so you saw exactly what changed. The code is on a feature branch — your main branch is still clean.

---

## Verifying (`/test`)

Type `/test`.

The agent runs any automated tests (if you'd written them) and then asks you to manually verify the core functionality:

**Agent:**
> Running tests...
>
> No test suite found (expected for Phase 0). Proceeding to manual verification.
>
> **Manual verification checklist:**
>
> 1. Run `npm link` to install the CLI locally
> 2. Run `bookmark add https://example.com coding tools` — verify it saves
> 3. Run `bookmark list` — verify the URL and tags appear
> 4. Run `bookmark delete 1` — verify it removes the bookmark
> 5. Run `bookmark list` again — verify the list is empty
>
> Please test and confirm the results.

**You:**
> All tests pass. The CLI works as expected.

**Agent:**
> Verification complete. Recording results...

```
Phase: 0 — Core CLI
Step:  test
Model: standard (Sonnet)
Next:  type `/close-out` to wrap up the phase
```

> **Verification complete.** Manual verification passed. Next → type `/close-out` to wrap up the phase.

**What just happened?**

The agent made sure the implementation actually works. For early phases, this is often manual (you test it yourself). Later phases might include automated tests, build checks, or deployment verification.

---

## Wrapping Up (`/close-out`)

Type `/close-out`.

The agent writes a postmortem in `planning/phase-00/POSTMORTEM.md`, summarising what went well, what didn't, and lessons learned. Then it asks for approval to commit, push, and merge:

**Agent:**
> **Phase 0 Postmortem Summary:**
>
> **What went well:**
> - Clean separation between CLI logic and storage layer
> - commander made argument parsing straightforward
> - JSON storage sufficient for current scope
>
> **What could improve:**
> - No tests yet (defer to Phase 1?)
> - URL validation is basic (just checks for http/https)
>
> **Lessons learned:**
> - Creating ~/.bookmark-manager/ directory on first run prevents errors
> - Index-based deletion is intuitive but requires stable array ordering
>
> **Deferred:**
> - Advanced features: search, export, tag filtering
> - Migration to SQLite (if bookmark count grows)
>
> ---
>
> Ready to finalise:
> 1. Commit POSTMORTEM.md
> 2. Push feature branch
> 3. Merge to main
> 4. Update ROADMAP.md and PROJECT.md
>
> Approve?

**You:**
> Yes

The agent executes the steps, merges the branch, and updates the roadmap to mark Phase 0 as complete.

```
Phase: 1 — (pending)
Step:  close-out
Model: standard (Sonnet)
Next:  type `/discuss` to start Phase 1
```

> **Phase 0 complete** and merged. Next → type `/discuss` to start **Phase 1: (pending)**.

**What just happened?**

You've shipped Phase 0. The code is on main, the lessons learned are documented, and the roadmap is updated. If you start Phase 1 (maybe adding search or tags filtering), the agent will reference the postmortem and avoid repeating mistakes.

---

## What's Next

You've just completed a full workflow cycle. Here's what you should know:

**Session breaks:** You can close Claude Code at any time. When you re-open it, the framework reads `.workflow/state.md` and tells you exactly where you left off. Type `/status` if you forget.

**Milestones:** As you complete phases, the roadmap grows. You can run `/retro` at any time to reflect on progress across multiple phases.

**Real projects:** This tutorial used a simple CLI, but the workflow scales. Planning a web app? The research phase investigates your framework's best practices. Building an API? The plan includes database migrations, endpoint design, and testing strategy. The structure stays the same; the depth adapts.

**Going deeper:** This tutorial showed the experience of using the framework. For reference material — what each command does under the hood, how to customise behaviour, advanced features — check out [FRAMEWORK-GUIDE.md](FRAMEWORK-GUIDE.md).

---

## You're Ready

That's it. You've seen the full cycle: clarify → investigate → plan → build → verify → ship.

The framework keeps you organised, the agent keeps you moving, and the documents keep context alive across sessions. It's a different way of working with AI — less "help me with this snippet" and more "let's build this thing together".

Type `/new-project` and start building.
