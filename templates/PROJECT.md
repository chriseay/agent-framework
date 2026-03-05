# Project Notes

## Document Ownership

Project-specific rules and lessons live here. Update `PROJECT.md` at phase close-out if new constraints or lessons are discovered.

## 1) Project Overview

[1–3 sentences describing what the project is and who it's for.]

## 2) Repository Layout

- `[folder]/` [description]
- `[folder]/` [description]

## 3) Tech Stack

[List primary languages, frameworks, and infrastructure. Use "TBD" for undecided items and note any assumptions.]

## 4) Coding Style & Naming Conventions

- [Indentation, formatting, naming patterns]
- [File naming conventions]
- [If a formatter/linter is used, name it here]

## 5) Domain & Product Constraints

[Key product rules, business logic constraints, or domain-specific requirements that affect implementation decisions.]

## 6) Data & Storage

[Database, persistence layer, data model approach. Note migration strategies if applicable. Use "N/A" if not applicable.]

## 7) Runtime/Environment

[Target platforms, OS versions, build tools, simulators/emulators, environment setup notes.]

## 8) Security & Privacy

[Authentication, authorisation, data protection, privacy requirements. Use "N/A" if not applicable.]

## 9) Testing & Verification

[Testing strategy, test naming conventions, what gets tested, how to run tests. Note any features that require on-device or manual verification.]

## 10) Deployment/Delivery

[How to build, run, and deploy. CI/CD if applicable. Use "N/A" if not applicable.]

## 11) Observability & Performance

[Logging, monitoring, performance requirements or benchmarks. Use "N/A" if not applicable.]

## 12) Model Routing (Optional)

This section is optional. The framework ships sensible defaults — only add overrides if you want to change which model tier is used for specific phases.

### Phase-to-Tier Overrides

| Phase | Default Tier | Your Override |
|-------|-------------|---------------|
| /discuss | light | |
| /research | standard | |
| /plan | heavy | |
| /implement | heavy | |
| /test | standard | |
| /close-out | standard | |
| /status | light | |
| /help | light | |
| /new-project | light | |
| /onboard | heavy | |
| /retro | standard | |

Leave "Your Override" blank to use defaults. Supported tiers: `light`, `standard`, `heavy`, `codex`.

### Preferences

- auto-routing: no (set to `yes` to skip confirmation and use recommended tiers automatically)

### Model Update Cadence

Review the model tier mapping when Anthropic announces a new model family. The framework's `CLAUDE.md` contains the current tier table — compare it against the [Anthropic model overview](https://docs.anthropic.com/en/docs/about-claude/models) and update if needed.

- **Review trigger**: New model family released by Anthropic (e.g., Claude 5.x)
- **Responsible**: [Your name or team — fill in during project setup]
- **Last reviewed**: [Date — fill in when you check]

### Extended Thinking & Effort Levels

Sonnet 4.6 with adaptive thinking and `effort: "high"` can match Opus performance on many complex tasks at lower cost. Consider using this combination instead of upgrading to Opus for cost-sensitive projects.

- Only Opus supports `effort: "max"` (unconstrained reasoning depth).
- Haiku 4.5 does not support adaptive thinking.
- In Claude Code, use the `opusplan` model alias to automatically use Opus during planning and Sonnet during execution.

For details, see Anthropic's [extended thinking documentation](https://docs.anthropic.com/en/docs/build-with-claude/extended-thinking).

## 13) Recent Lessons (Project-Specific)

[Add entries at phase close-out when new constraints or patterns are discovered. Each entry should be actionable — not just "X was hard" but "when doing X, do Y because Z."]

**Keep this section lean** — hold only the last 1–2 phases of lessons here (the "active window"). When this section exceeds ~10 entries, archive older lessons to `project/lessons-archive.md` (see Section 14) and add it to the Subdocuments registry. This keeps session-start context focused on recent, relevant lessons.

## 14) Subdocuments

This section is optional. Use it when PROJECT.md grows too large to be useful — typically when any section exceeds ~50 lines or the total file exceeds ~200 lines.

**How it works**: List extracted files in the registry below. The agent reads this table at session start and loads subdocuments whose "Load when" condition matches the current phase. Subdocuments live in a `project/` directory alongside PROJECT.md.

**Content categories** (use these to decide what to extract):
- **Core** — always needed: overview, tech stack, domain constraints, recent lessons, model routing. Keep in PROJECT.md.
- **Reference** — phase-specific: API guides, deployment procedures, test tooling setup, security guardrails. Extract to `project/<name>.md`.
- **Archive** — historical: lessons from older phases, per-phase addenda from completed work. Extract to `project/lessons-archive.md`.

**Extraction triggers** (prompts to consider splitting, not automatic):
- Section 13 (Recent Lessons) exceeds ~10 entries → archive older lessons to `project/lessons-archive.md`
- Any non-core section exceeds ~50 lines → extract to `project/<section-name>.md`
- Total PROJECT.md exceeds ~200 lines → review all sections and extract reference/archive content

**Registry** (add a row for each extracted file):

| File | Contents | Load when |
|------|----------|-----------|
| *(empty — add rows here as you extract content)* | | |

**Example rows** (delete before use):

| File | Contents | Load when |
|------|----------|-----------|
| `project/lessons-archive.md` | Lessons from phases 1–N | Phase involves a problem that might recur from those phases |
| `project/deployment.md` | CI/CD pipeline, SSH guardrails, deploy steps | Phase involves deployment |
| `project/api.md` | REST API endpoints, auth tokens, curl examples | Phase involves API calls or integration work |
| `project/testing.md` | Test framework setup, device setup, tooling guides | Phase involves testing |

**Archive growth**: when `project/lessons-archive.md` itself grows large, add a second archive file (e.g., `project/lessons-archive-v2.md`) as a new registry row. No special mechanism required — the same pattern applies recursively.
