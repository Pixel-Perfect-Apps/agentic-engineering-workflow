# Releasing

Standard SemVer (`MAJOR.MINOR.PATCH`).

## Quick release

```bash
scripts/release.sh 0.2.0
```

The script:
1. Validates the input is a SemVer string.
2. Refuses if working tree is dirty, you're not on `main`, or the tag already exists.
3. Bumps `version` in both `plugins/agentic-engineering-workflow/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` (top-level + plugin entry).
4. Promotes the `## [Unreleased]` section in `CHANGELOG.md` to `## [<version>] — <today>` and updates the link refs at the bottom.
5. Shows a diff and asks you to confirm.
6. On confirmation: commits, tags `v<version>`, pushes commit + tag to `origin/main`.

After the tag lands on `origin`, the `.github/workflows/release.yml` workflow:
1. Validates that `plugin.json` and `marketplace.json` versions match the tag.
2. Extracts the matching `## [<version>]` section from `CHANGELOG.md` as release notes.
3. Creates a GitHub Release via `gh release create`.

Watch the workflow with:

```bash
gh run watch --repo Pixel-Perfect-Apps/agentic-engineering-workflow
```

## Manual release (no script)

If you want to do it by hand:

1. Edit both manifests to bump `version`.
2. Move the `[Unreleased]` notes to a new `[<version>] — <date>` section in `CHANGELOG.md`.
3. Update the link refs at the bottom of `CHANGELOG.md`.
4. `git commit -am "Release v<version>"`
5. `git tag v<version> && git push origin main && git push origin v<version>`

The release workflow handles the GitHub Release creation.

## SemVer guidance for this plugin

| Bump | When to use |
|---|---|
| **PATCH** (0.1.0 → 0.1.1) | Bug fixes in skill content; wording tweaks; doc clarifications; broken-link fixes. No behavior change for users. |
| **MINOR** (0.1.0 → 0.2.0) | New skills added; new templates; new sections in the spec; new setup behaviors that don't break existing flows. Backwards-compatible additions. |
| **MAJOR** (0.x.x → 1.0.0+) | Breaking changes — removed skills, renamed slash commands, restructured spec sections referenced by other docs, changes to AGENTS.md template structure that existing installations depend on. |

The plugin is pre-1.0 (`0.x.x`); some breaking changes are allowed in MINOR bumps until 1.0. Once we hit 1.0, strict SemVer.

## Migration files

Whenever a release changes anything that affects existing installations, ship a migration file in `plugins/agentic-engineering-workflow/migrations/v<this-version>.md`. The setup skill walks these in version order when a user runs UPGRADE mode, applying confirmed changes incrementally so users don't have to re-install from scratch.

**When to write a migration:**
- Renamed canonical labels
- New required AGENTS.md sections
- New skill files that should land in user installs
- Removed / deprecated skills
- Renamed slash commands
- Behavior changes that need user awareness
- Anything that requires the user to know "here's what changed for you"

**When you can skip writing a migration:**
- Pure plugin-internal refactor that users don't observe
- Doc-only changes (typo fixes, wording clarifications)
- Bug fixes that restore correct behavior without changing what the user does

**If unsure: err on the side of writing one.** Empty/minimal migrations are still useful — they document that "this version landed but nothing user-visible changed." See `plugins/agentic-engineering-workflow/migrations/README.md` for the file format spec and `v0.3.0.md` for the meta-migration that introduced the system.

**Format reminder:**

```markdown
---
from: <previous-version>
to: <this-version>
date: YYYY-MM-DD
---

# Migration vX.Y.Z

## Summary
<what this migration does at a high level>

## Changes

### <change-type>: <short title>
**Scope:** local | team-wide | plugin-internal
**Automatable:** yes | partial | no
**Action:** <what to do>
```

The release.sh script does NOT yet validate that a migration file exists for the new version. Maintainer convention for now: write one when relevant.

## Why pin a version?

Without `version` in `plugin.json`, every commit on `main` is implicitly a new version — users get the latest on every `/plugin update`. That's fine for active development but unpredictable for adopters.

With `version` pinned, users only get a new version when:
1. The `version` field bumps in `plugin.json`, AND
2. They run `/plugin update` (or it auto-updates on next session, depending on Claude Code config).

This lets us land work-in-progress commits without forcing every adopter to test mid-stream changes.

## If the release workflow fails

The most common failures:

- **Version mismatch.** The tag, `plugin.json.version`, and `marketplace.json.plugins[0].version` must agree. Run `scripts/release.sh` to fix versions in lock-step, or fix by hand and re-tag.
- **`CHANGELOG.md` has no matching `[<version>]` section.** The workflow falls back to auto-generated notes from commits. To use curated notes, ensure the changelog has the heading exactly: `## [<version>] — <date>`.
- **Token scopes.** The workflow uses `${{ secrets.GITHUB_TOKEN }}` with `contents: write` — that should always be available. If it fails, the repo's Actions permissions may have been narrowed; check Settings → Actions → General → Workflow permissions.

## Rollback

To unpublish a bad release:

```bash
gh release delete v<bad-version> --repo Pixel-Perfect-Apps/agentic-engineering-workflow --yes
git push --delete origin v<bad-version>
git tag -d v<bad-version>
```

Then revert the offending commit and ship a new patch release. Don't reuse the deleted version number — bump it.
