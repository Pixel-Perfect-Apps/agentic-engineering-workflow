# Changelog

All notable changes to this plugin will be documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [SemVer](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] — 2026-05-15

### Changed (bootstrap behavior — major UX revision)
- **Bootstrap is now inspection-first and consent-based.** No more invasive tracker writes during setup. The bootstrap inspects the workspace + tracker read-only, makes educated guesses, and asks the user before any write.
- **Workflow installation-state detection.** Before doing anything, the bootstrap checks for signatures that another collaborator already ran it (AGENTS.md "Tracker destinations" section, canonical labels in tracker, bootstrap ADR). Classifies as FRESH / PARTIAL / INSTALLED.
- **Four scope modes** for PARTIAL/INSTALLED workspaces:
  - LOCAL SYNC (default for new team members) — only writes per-machine memory files. Zero shared writes.
  - COMPLETE-PARTIAL — finish a half-done install. Only writes what's missing.
  - TEAM UPDATE — intentional team config changes. AGENTS.md changes go through a branch + PR; per-change confirmation for tracker writes.
  - RE-INSTALL — destructive override. Requires explicit confirmation.
- **`/defect` destination is now inspected before creation.** The bootstrap detects existing options (Linear built-in Triage, dedicated "Bugs" project, label-based bug tracking) and proposes mapping `/defect` to those instead of forcing a new "Bug Triage" project. User picks.
- **`/idea` destination same treatment.** Common existing destinations ("Backlog", "Icebox", "Ideas", "Parking Lot", "Future Enhancements") are detected and proposed first.
- **Planning cadence is now opt-in.** Bootstrap no longer auto-creates an "M0 / Current Sprint" document. Instead, it detects existing cadence (active sprints/cycles/milestones) and asks whether to continue, adopt 10-day phases, or skip planning artifacts entirely.
- **Docs storage location is asked, not assumed.** Detects existing `docs/`, dedicated docs repos, GitHub Wikis, and tracker documents in use. Proposes options including in-repo, dedicated docs repo, tracker-attached, or skip-ADRs. Recommends in-repo for ADRs (version-controlled, PR-reviewable).
- **Label taxonomy writes are opt-in.** Bootstrap shows the diff (which labels would be added) before writing.
- **`/defect` and `/idea` skills now read destinations from AGENTS.md at runtime** instead of having hardcoded project IDs. New "Tracker destinations" section in the AGENTS.md template is the canonical config + workflow-installed signature.

### Added
- AGENTS.md template now includes "Tracker destinations" + "Docs location" sections — the canonical config + workflow-installed signature that future bootstrap runs detect.
- Spec §A introspection now also reads tracker state, docs storage signals, and workflow installation state.
- Spec §B questions extended with bug destination (Q9), idea destination (Q10), planning cadence (Q11), label taxonomy diff (Q12), and docs storage (Q15).

### Notes
- This is a meaningful behavior change to the bootstrap. Existing workspaces that ran the v0.1.x bootstrap aren't broken — but the new bootstrap will detect them as PARTIAL or INSTALLED and offer non-destructive sync. To get the new AGENTS.md sections, re-run the bootstrap in TEAM UPDATE mode.

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

[Unreleased]: https://github.com/Pixel-Perfect-Apps/agentic-engineering-workflow/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/Pixel-Perfect-Apps/agentic-engineering-workflow/releases/tag/v0.2.0
[0.1.1]: https://github.com/Pixel-Perfect-Apps/agentic-engineering-workflow/releases/tag/v0.1.1
[0.1.0]: https://github.com/Pixel-Perfect-Apps/agentic-engineering-workflow/releases/tag/v0.1.0
