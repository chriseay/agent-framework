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

## 13) Lessons Learned (Project-Specific)

[Empty until populated. Add entries at phase close-out when new constraints or patterns are discovered. Each entry should be actionable — not just "X was hard" but "when doing X, do Y because Z."]

## 14) Phase Addenda (Roadmap-Specific)

[Per-phase technical notes that apply across the project. Use "N/A" if not roadmap-driven.]
