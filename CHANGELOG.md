# Changelog

All notable changes to this plugin will be documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [SemVer](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] — 2026-05-15

### Added
- README status badges — release version (from latest tag), MIT license, "Claude Code Plugin", and "Agent-agnostic" — for quick at-a-glance signaling on the repo's GitHub landing page and any rendered preview.

## [0.1.0] — 2026-05-15

Initial public release.

### Added
- **`bootstrap` skill** — scaffolds an agent-driven team workflow into any workspace. Walks the file tree, classifies the project as GREENFIELD / EXISTING-COMPATIBLE / EXISTING-DIVERGENT / AMBIGUOUS, asks a single batched round of clarifying questions, then writes `AGENTS.md`, `CLAUDE.md` shim, per-module AGENTS.md stubs, an ADR placeholder, memory bootstrap files, and `.gitignore` entries.
- **Agent-agnostic by design** — works with Claude Code (one-command plugin install) and Codex / other agents (manual install via `.agents/skills/` or drop-in spec doc).
- **`/defect` skill** — fire-and-forget bug capture. Infers platform, build, repro steps, severity, root-cause hypothesis, and likely-culprit files from a one-liner. Files an unassigned ticket to a "Bug Triage" project in the tracker.
- **`/idea` skill** — parking-lot idea capture. Infers cross-repo work needed to ship the idea, drafts a mini-spec (Why / Proposed shape / Work inferred / Open questions / Size / Trigger to revisit), files it as a Low-priority backlog ticket.
- **Full workflow spec** at `plugins/agentic-engineering-workflow/skills/bootstrap/references/team-process-spec.md` — sprint phases, CTO/CPO/CDO review triad, ADR system, contract-lock discipline, PR hygiene, working agreements, common pitfalls. Readable standalone for users who don't want to install the plugin.
- **Tracker-agnostic by design** — Linear, GitHub Issues, Jira, Notion all supported via runtime MCP detection.
- **Stack-agnostic by design** — templates adapt to whatever the workspace's file tree reveals.

### Notes
- Plugin uses SemVer; this is a 0.x release so breaking changes may land in any minor version until 1.0.
- `version` is now pinned, so `/plugin update` will pick up future releases. Commits between releases won't auto-deploy to installed instances.

[Unreleased]: https://github.com/Pixel-Perfect-Apps/agentic-engineering-workflow/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/Pixel-Perfect-Apps/agentic-engineering-workflow/releases/tag/v0.1.1
[0.1.0]: https://github.com/Pixel-Perfect-Apps/agentic-engineering-workflow/releases/tag/v0.1.0
