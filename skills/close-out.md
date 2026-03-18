# /close-out

Complete the phase, create the postmortem, and prepare for the next phase.

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
3. Read `planning/phase-XX/CONTEXT.md` and any test results from the session.
   - Read the **Subphase** field from `.workflow/state.md`.
   - If the field is **absent**: read `planning/phase-XX/PLAN.md` (standard behaviour).
   - If set and this is the **final subphase** (Subphase: N of N): read all `planning/phase-XX/sub-N/PLAN.md` and `planning/phase-XX/sub-N/POSTMORTEM.md` files to build a complete picture for the main POSTMORTEM.md.
   - If set and **not the final subphase**: read only `planning/phase-XX/sub-N/PLAN.md` for the current subphase. Lightweight close-out applies — see Process step 0.

## Process

0. **Subphase check** — run this before anything else:
   - Read the **Subphase** field from `.workflow/state.md`.
   - If the field is **absent** or this is the **final subphase** (Subphase: N of N): proceed with the full close-out sequence (steps 1–12 below).
   - If this is a **mid-subphase close-out** (Subphase: N of M where N < M): run the **Lightweight Close-Out** path below and stop — do not continue to steps 1–12.

### Lightweight Close-Out (mid-subphase only)

1. Summarise what subphase N delivered.
2. Write `planning/phase-XX/sub-N/POSTMORTEM.md` with three sections only:
   - **Summary**: what was delivered in this subphase
   - **Issues Encountered**: problems hit and how they were resolved
   - **Decisions and Rationale**: key choices made and why
3. Output:
   **About to**: commit the subphase N of M deliverables
   **Why**: closing out this subphase so the next one can begin
   **Affects**: feature branch (new commit); `planning/phase-XX/sub-N/POSTMORTEM.md`

   Then propose a commit to the user. Use `AskUserQuestion` to confirm the commit message before committing. Use Conventional Commit format: `feat(phase-XX): subphase N of M — [brief description]`
4. Update `.workflow/state.md`:
   ```
   - Subphase: [N+1] of M
   - Step: implement (not started)
   - Implementation Step: —
   - Next Command: /implement
   ```
5. Tell the user: **Subphase N of M complete.** Type `/implement` to continue with subphase N+1.

---

1. **Summarise** what changed and why.
2. **List verification** performed (automated + manual).
3. **Create** `planning/phase-XX/POSTMORTEM.md` with:
   - **Summary**: What was delivered
   - **Issues Encountered**: Problems hit and how they were resolved
   - **Decisions and Rationale**: Key choices made and why
   - **Verification**: What was tested and results
   - **Deferred Items**: What was pushed to later phases
   - **Close-Out Summary**: Final state of the work
   - **Process Notes**: Friction, gaps, or observations about the workflow (consumed by `/retro`)

   If the phase used subphases, begin by reading all `sub-N/PLAN.md` and `sub-N/POSTMORTEM.md` files. Synthesise them into the main POSTMORTEM.md — the main POSTMORTEM covers the full phase, not just the final subphase.
4. **Propose lessons learned**: Review both `CLAUDE.md` and `PROJECT.md` to avoid duplication. For each proposed addition, output:
   **About to**: write a new lesson learned to `PROJECT.md`
   **Why**: [one-sentence reason — e.g., "this pattern recurred and should be recorded"]
   **Affects**: `PROJECT.md` (Recent Lessons section)

   Then use `AskUserQuestion` to confirm each addition before writing.

   **Lesson format**: Each lesson must be a single sentence in actionable form — "when doing X, do Y because Z." Tag it with the current phase number in brackets: `[PhN]` (e.g., `[Ph22]`). This tag lets the agent look up full context in `planning/phase-NN/POSTMORTEM.md` on demand without loading the postmortem into every session.

   Example: `- **Descriptive title** [Ph22]: When compressing lessons, strip to a single actionable sentence and tag with [PhN] so postmortems are findable on demand.`

   **Header note**: After writing the first lesson of a phase, confirm that PROJECT.md's Recent Lessons section has this header note (add it if absent):
   `> Full detail for any lesson: planning/phase-NN/POSTMORTEM.md`

   **Write-target rule**: Always write new lessons to PROJECT.md's Section 13 (Recent Lessons). Do not write directly to any `project/lessons-archive.md` subdocument — that file is an archive of older lessons and is managed separately. If PROJECT.md still uses the old heading "Lessons Learned", write there as before; the write-target rule and [PhN] format apply regardless of the heading name.

4a. **PROJECT.md size check**: After writing lessons, count the lines in PROJECT.md (use `wc -l` or Read and count). If any of the following thresholds are met, surface a suggestion to the user via `AskUserQuestion`:
   - Total lines exceed ~200
   - Section 13 (Recent Lessons or Lessons Learned) exceeds ~10 entries

   **Compression first**: Before suggesting archiving, check whether existing lessons are already in single-sentence [PhN] format. If any lessons are multi-line, recommend compressing them first — strip each to its single actionable insight and add a [PhN] tag. Compression keeps all lessons in session-start context (no discoverability problem) and typically reduces a 150-line section to ~40 lines.

   Suggested message (compression): "PROJECT.md is getting long ([N] lines / [M] lessons). I can compress the lessons to single sentences with [PhN] tags — this usually cuts the section by 60–70% while keeping everything in context. Alternatively, I can archive older entries to `project/lessons-archive.md`."

   Options: "Compress lessons inline" / "Archive older lessons" / "Not yet — I'll do it later".

   If the user chooses **compression**: strip each multi-line lesson to a single actionable sentence and add its [PhN] tag. Ensure the header note is present. Commit as a separate commit.

   If the user chooses **archive**: move lessons older than the last 3 from Section 13 into `project/lessons-archive.md` (create from `templates/project/lessons-archive.md` if it doesn't exist), keeping the last 3 inline. Add or update the Subdocuments registry in Section 14 with a row for the archive file. Then commit the archiving as a separate commit from the phase close-out.

   If the user declines or thresholds are not met, continue without action.
5. **Update** `ROADMAP.md` status for the completed phase.
6. **Documentation refresh**:
   a. **Discover documentation files**: Scan for common patterns — `README.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`, `FRAMEWORK-GUIDE.md`, `PROJECT.md`, `CHANGELOG.md` in the repo root, and `docs/*.md` or `doc/*.md` directories. Exclude framework internals: `CLAUDE.md`, `AGENTS.md`, `skills/*.md`, `templates/*.md`, `planning/**/*.md`.
   b. If no documentation files are found, use `AskUserQuestion` to ask the user if there are docs the agent is missing.
   c. **Build a change summary**: Before dispatching, compile a concise list of what the phase delivered — what was added (new features, new files), what was changed (behaviour updates), and what was removed (deleted files or deprecated behaviour). This is the context the doc-reviewer needs.
   d. **Dispatch to `doc-reviewer`**: Use the Agent tool with `subagent_type: doc-reviewer`. The prompt must include:
      - The change summary from step c
      - The list of discovered doc file paths
   e. **Wait for the agent's proposals to return** before proceeding.
   f. For each proposed change the agent returns, output:
      **About to**: update `[doc filename]`
      **Why**: [one-sentence reason from the agent's proposal]
      **Affects**: `[doc filename]`

      Then use `AskUserQuestion` to confirm before applying each change.
   g. If the agent reports no changes needed for any doc, confirm this to the user: "Documentation reviewed — no updates needed."
7. **Close GitHub issues** (if `gh` CLI is available):
   a. **Close the phase issue**:
      - Read `planning/phase-XX/CONTEXT.md` for the `## Sync Status` section.
      - If a GitHub Issue number is recorded:
        - Get the merge commit hash(es) from the current branch.
        - Post a summary comment: what was delivered + commit hash(es).
        - Output:
          **About to**: close GitHub issue #[number] — Phase [N]: [name]
          **Why**: the phase is complete; closing the tracking issue
          **Affects**: GitHub Issues (issue will be marked closed)

          Then use `AskUserQuestion` to confirm, then close via `gh issue close <number>`.
      - If Sync Status says "not created":
        - Create the issue (using the Sync flow from /discuss), post the summary comment, and immediately close it.
      - If no Sync Status section exists, search by title: `gh issue list --state all --search "Phase N in:title" --json number,title`
        - If found, comment and close. If not found, skip (pre-Phase 7 phase).
      - If `gh` is not available, record `- GitHub Issue: not closed (gh unavailable)` in Sync Status.
   b. **Close linked issues**: (existing behaviour)
      - Read `planning/phase-XX/CONTEXT.md` for the `## Linked Issues` section.
      - If linked issues exist, for each one: show the issue number, title, and current status. Use `AskUserQuestion` to ask whether to close it.
      - For each linked issue to close, output:
        **About to**: close linked GitHub issue #[number] — [title]
        **Why**: this issue was resolved as part of Phase [N]
        **Affects**: GitHub Issues (issue will be marked closed)

        Then close approved issues via `gh issue close <number>`.
8. **Check milestone completion** (if `gh` CLI is available and a phase issue was closed):
   - Read the milestone title from Sync Status.
   - Check if all issues are closed: `gh issue list --milestone "TITLE" --state open --json number | jq 'length'`
   - If the count is 0, output:
     **About to**: close the GitHub Milestone "[milestone name]"
     **Why**: all issues in this milestone are now closed
     **Affects**: GitHub Milestones (milestone will be marked closed)

     Then use `AskUserQuestion` to propose closing the milestone.
   - If approved: find the milestone number via `gh api repos/:owner/:repo/milestones --method GET -F state=all | jq ...` and close it via `gh api repos/:owner/:repo/milestones/N -X PATCH -f state="closed"`.
9. **Propose commit, push, and merge**: For each action, output the appropriate summary before the `AskUserQuestion` call:

   **Commit**:
   **About to**: commit the phase close-out changes (POSTMORTEM.md, ROADMAP.md, docs)
   **Why**: finalising and recording the phase deliverables
   **Affects**: feature branch (new commit)

   **Push**:
   **About to**: push `[branch-name]` to `origin/[branch-name]`
   **Why**: making the phase changes available for merge
   **Affects**: remote origin

   **Merge**:
   **About to**: merge `[branch-name]` into `main`
   **Why**: delivering Phase [N] changes to the main branch
   **Affects**: `main` branch; feature branch (will be deletable after merge)

   Then propose commit, push, and merge for explicit approval. Use `AskUserQuestion` for each.
   - Merge messages: one headline + 2–4 bullet points.
10. **Propose feature branch deletion**: Output:
    **About to**: delete feature branch `[branch-name]` (local and remote)
    **Why**: branch has been merged; deleting to keep the repo clean
    **Affects**: local git repo and remote origin (branch will be removed from both)

    Then propose feature branch deletion (local + remote) after merge. Use `AskUserQuestion` to confirm.
11. **Record process notes** in POSTMORTEM.md — any friction or gaps. Do not propose CLAUDE.md changes here; save that for `/retro`.
12. **Confirm** planning artifacts (CONTEXT.md, PLAN.md, POSTMORTEM.md) contain enough context for the next session.

## On Completion

### 1. Detect milestone boundary

Read `ROADMAP.md` and find the milestone heading that contains the current phase. Check whether any subsequent phase under that same milestone heading has a status other than "Complete". If every remaining phase is complete (or there are no subsequent phases), this is a **milestone boundary**.

### 2. Route based on boundary

**If NOT a milestone boundary** (more phases remain in this milestone):

Identify the next incomplete phase. Update `.workflow/state.md`:
```
- Phase: [next phase number]
- Phase Name: [next phase name]
- Step: not started
- Implementation Step: —
- Research Tier: —
- Next Command: /discuss
```

If the completed phase used subphases, omit the `Subphase` field from state.md entirely (do not write `Subphase: —`).

Tell the user:

**Phase [N] complete** and merged.

Next → type `/discuss` to start **Phase [N+1]: [name]**.

**If a milestone boundary:**

Tell the user:

**Phase [N] complete.** This finishes the **[milestone name]** milestone.

Then use `AskUserQuestion` with three options:

1. **Add more phases to this milestone** — run the inline flow below, then set Next Command to `/discuss`.
2. **Run /retro** — set Next Command to `/retro`. Update state.md with the next milestone's first phase number/name (or keep current if no next milestone exists).
3. **Skip retro, continue to /discuss** — identify the next milestone's first phase. Update state.md to point to it with Next Command `/discuss`.

### 3. Inline "add phases" flow (milestone boundary only)

When the user chooses "Add more phases to this milestone":

1. Use `AskUserQuestion` to get the new phase **name**.
2. Use `AskUserQuestion` to get a one-line **scope and deliverable**.
3. Output:
   **About to**: append a new phase to `ROADMAP.md`
   **Why**: user confirmed the phase name and scope
   **Affects**: `ROADMAP.md` (new phase entry under current milestone)

   Then append the new phase to `ROADMAP.md` under the current milestone heading, with status "Not started" and the next available phase number.
4. Run the **GitHub Phase Sync** flow from `skills/discuss.md` (label, milestone, issue creation).
5. Use `AskUserQuestion`: "Add another phase, or done?"
   - If "Add another" → repeat from step 1.
   - If "Done" → continue below.
6. Update `.workflow/state.md` to point to the **first newly added phase**:
   ```
   - Phase: [new phase number]
   - Phase Name: [new phase name]
   - Step: not started
   - Implementation Step: —
   - Research Tier: —
   - Next Command: /discuss
   ```
   If the completed phase used subphases, omit the `Subphase` field from state.md entirely.

Tell the user:

**[count] phase(s) added** to the **[milestone name]** milestone.

Next → type `/discuss` to start **Phase [N]: [name]**.
