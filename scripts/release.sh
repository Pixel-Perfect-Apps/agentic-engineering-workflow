#!/usr/bin/env bash
# release.sh — bump version, update CHANGELOG, commit, tag, push.
#
# Usage:
#   scripts/release.sh <new-version>
#
# Example:
#   scripts/release.sh 0.2.0
#
# What it does:
#   1. Validates the new version is SemVer.
#   2. Bumps version in plugin.json + marketplace.json (both fields).
#   3. Promotes the [Unreleased] section in CHANGELOG.md to [<new-version>] — <date>.
#   4. Commits the version bump + tags v<new-version>.
#   5. Pushes commit + tag. The release.yml workflow then creates the GitHub Release.
#
# Requires: jq, git, gh CLI.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <new-version>" >&2
  echo "Example: $0 0.2.0" >&2
  exit 1
fi

NEW_VERSION="$1"

# Validate SemVer (basic — major.minor.patch with optional pre-release / build metadata)
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$ ]]; then
  echo "Error: '$NEW_VERSION' is not a valid SemVer string." >&2
  echo "Expected: MAJOR.MINOR.PATCH (e.g., 0.2.0 or 1.0.0-rc.1)" >&2
  exit 1
fi

cd "$(dirname "$0")/.."

# Refuse to release with uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Error: working tree has uncommitted changes. Commit or stash first." >&2
  git status --short >&2
  exit 1
fi

# Refuse to release if not on main
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "Error: not on main branch (currently on '$CURRENT_BRANCH'). Releases ship from main." >&2
  exit 1
fi

# Refuse to release if tag already exists
if git rev-parse "v$NEW_VERSION" >/dev/null 2>&1; then
  echo "Error: tag 'v$NEW_VERSION' already exists." >&2
  exit 1
fi

PLUGIN_JSON="plugins/agentic-engineering-workflow/.claude-plugin/plugin.json"
MARKETPLACE_JSON=".claude-plugin/marketplace.json"

OLD_VERSION=$(jq -r '.version' "$PLUGIN_JSON")
echo "Bumping $OLD_VERSION → $NEW_VERSION"

# Bump plugin.json
tmp=$(mktemp)
jq --arg v "$NEW_VERSION" '.version = $v' "$PLUGIN_JSON" > "$tmp" && mv "$tmp" "$PLUGIN_JSON"

# Bump marketplace.json (both top-level and the plugin entry)
tmp=$(mktemp)
jq --arg v "$NEW_VERSION" '.version = $v | .plugins[0].version = $v' "$MARKETPLACE_JSON" > "$tmp" && mv "$tmp" "$MARKETPLACE_JSON"

# Promote [Unreleased] in CHANGELOG
TODAY=$(date +%Y-%m-%d)
if grep -q "^## \[Unreleased\]" CHANGELOG.md; then
  # Replace ## [Unreleased] line with ## [Unreleased]\n\n## [<NEW>] — <date>
  # Then update the compare/tag links at the bottom
  awk -v new="$NEW_VERSION" -v today="$TODAY" '
    /^## \[Unreleased\]/ {
      print
      print ""
      print "## [" new "] \xe2\x80\x94 " today
      next
    }
    { print }
  ' CHANGELOG.md > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md
fi

# Update reference links at the bottom of CHANGELOG.md
# [Unreleased] should now compare against v<NEW>, and add a [<NEW>] release tag link
REPO_URL="https://github.com/Pixel-Perfect-Apps/agentic-engineering-workflow"
if grep -q "^\[Unreleased\]:" CHANGELOG.md; then
  sed -i.bak \
    -e "s|^\[Unreleased\]:.*$|[Unreleased]: ${REPO_URL}/compare/v${NEW_VERSION}...HEAD|" \
    CHANGELOG.md
  # Insert new version link below [Unreleased] if not already present
  if ! grep -q "^\[${NEW_VERSION}\]:" CHANGELOG.md; then
    sed -i.bak2 "/^\[Unreleased\]:/a\\
[${NEW_VERSION}]: ${REPO_URL}/releases/tag/v${NEW_VERSION}
" CHANGELOG.md
  fi
  rm -f CHANGELOG.md.bak CHANGELOG.md.bak2
fi

# Show what changed
echo
echo "Changes staged:"
git diff --stat

# Confirm before committing
echo
read -rp "Commit, tag v$NEW_VERSION, and push? [y/N] " answer
case "$answer" in
  [yY]|[yY][eE][sS]) ;;
  *)
    echo "Aborted. Manifests + CHANGELOG were modified locally; revert with 'git checkout -- .'"
    exit 0
    ;;
esac

git add "$PLUGIN_JSON" "$MARKETPLACE_JSON" CHANGELOG.md
git commit -m "Release v${NEW_VERSION}"
git tag "v${NEW_VERSION}"
git push origin main
git push origin "v${NEW_VERSION}"

echo
echo "Pushed. The release.yml workflow will create the GitHub Release shortly."
echo "Watch: gh run watch --repo Pixel-Perfect-Apps/agentic-engineering-workflow"
