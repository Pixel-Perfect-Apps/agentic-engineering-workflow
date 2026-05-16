# Migrations

This directory holds **migration manifests** that the setup reads when upgrading an existing installation to a newer plugin version.

## Why migrations exist

Once a workspace has the workflow installed (AGENTS.md with "Tracker destinations", tracker projects + labels configured, ADR placed, etc.), users shouldn't have to re-install from scratch when a new plugin version ships. Instead, the setup reads the migration files between the installed version and the current version, walks the user through each change, and applies only what they confirm.

The result: installations can be kept current iteratively. A team that installed v0.3.0 a year ago can upgrade through v0.4.0 → v0.5.0 → v0.6.0 in one setup invocation, with each version's changes proposed and confirmed individually.

## How the setup finds and uses migrations

1. **Setup detects install state** during §A introspection. If state is INSTALLED, it reads the "Workflow version" entry from `AGENTS.md` → "Tracker destinations" section.
2. **Setup reads the current plugin version** from its own `plugin.json`.
3. **If installed < current**, the setup offers UPGRADE mode in §B Q1.
4. **In UPGRADE mode**, the setup finds every `vX.Y.Z.md` in this directory whose `from` ≤ installed version and `to` ≤ current version. It applies them in version order (low → high).
5. **For each migration**, the setup presents the summary, then walks each change with the user. Confirmed changes are applied; skipped changes are left alone.
6. **After all migrations**, the setup updates the "Workflow version" in `AGENTS.md` to the new current version.

## Migration file format

Filename: `vX.Y.Z.md` (the version this migration upgrades TO).

```markdown
---
from: <previous-version>
to: <this-version>
date: YYYY-MM-DD
---

# Migration vX.Y.Z

## Summary

<1-3 sentences describing what this migration does at a high level.>

## Changes

### <change-type>: <short title>
**Scope:** local | team-wide | plugin-internal
**Automatable:** yes | partial | no (human judgment required)
**Action:** <what to do, concretely>
<optional code blocks, templates, before/after examples>
```

### Change types

Each change has a `<change-type>` from this list:

| Change type | What it does |
|---|---|
| `file-add` | Add a new file at a path |
| `file-modify` | Modify content in an existing file (specify diff or before/after) |
| `file-remove` | Remove a file |
| `agents-md-section-add` | Add a new section to AGENTS.md (give heading + content) |
| `agents-md-section-modify` | Modify content within an existing AGENTS.md section |
| `agents-md-section-remove` | Remove a section from AGENTS.md |
| `agents-md-section-rename` | Rename an AGENTS.md section heading |
| `tracker-label-add` | Add a label to the tracker |
| `tracker-label-rename` | Rename an existing label |
| `tracker-label-remove` | Remove a label |
| `tracker-project-add` | Add a new project / view |
| `tracker-config-update` | Change something in the "Tracker destinations" config (without re-running full setup) |
| `skill-add` | Add a new skill file to `.claude/skills/` |
| `skill-modify` | Modify behavior in an existing skill |
| `skill-remove` | Remove an installed skill |
| `memory-add` | Add a new memory file template |
| `workflow-rule-change` | A change to the workflow rules that doesn't fit a single file (e.g., a working agreement update) |
| `manual-step` | Human action required — cannot be automated. Describe what + why. |

### Scope values

- **`plugin-internal`** — changes only inside the plugin itself, no user action needed. The plugin update delivered them.
- **`local`** — affects the user's per-machine files (memory, agent config) but not shared team config. Each user upgrades independently.
- **`team-wide`** — affects shared team config (AGENTS.md, tracker, ADRs). The first team member to upgrade applies these for everyone. Subsequent team members skip these in UPGRADE mode (they're already done).

### Automatable values

- **`yes`** — the setup can apply this mechanically with confirmation. Minimal user thought required.
- **`partial`** — the setup can prepare the change (e.g., show a diff) but the user reviews + confirms specifics.
- **`no`** — human judgment required. The setup describes what to do and leaves it to the user.

## When to write a migration

Write a migration file whenever a release contains changes that affect existing installations. Examples that warrant migrations:

- Renamed canonical labels
- New required AGENTS.md sections
- New skill files that should be installed
- Removed/deprecated skills
- Behavior changes that need user awareness

Do NOT write a migration for:

- Doc-only changes (typos, formatting, clarifications)
- Plugin-internal refactors users don't see
- Bug fixes that don't change observable behavior

If unsure: err on the side of writing one — empty/minimal migrations are fine and at least document "this version landed but didn't change anything user-visible."

## Migration ordering + idempotency

Migrations are applied in SemVer order from oldest to newest. If a user is on v0.3.0 and upgrading to v0.6.0, the setup runs `v0.4.0.md`, then `v0.5.0.md`, then `v0.6.0.md` (those that exist).

Each migration should be **idempotent on the team-wide level**: if Alice runs UPGRADE first and applies team-wide changes, then Bob runs UPGRADE later, Bob's setup run should detect those changes are already in place (because AGENTS.md / tracker now matches the post-migration state) and skip them gracefully.

This is why migrations should describe **what state to reach**, not **what commands to run** — the setup can check current state against desired state and skip no-ops.
