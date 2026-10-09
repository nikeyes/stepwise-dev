#!/usr/bin/env bash
set -euo pipefail

# check-version-bumps.sh - Fails when a change ships without the version bumps
# that .claude/rules/versioning.md requires.
#
# Rules:
#   - A change inside an owned plugin's directory requires a higher `version`
#     in its plugin.json. Vendored plugins (marketplace keyword "vendored") are
#     exempt: their plugin.json belongs upstream and is never edited here.
#   - A change to .claude-plugin/marketplace.json requires a higher top-level
#     `version`.
#   - A version never goes down.
#
# Keeping each marketplace entry's `version` equal to its plugin.json is not
# checked here: `claude plugin validate --strict` already fails on drift.
#
# Escape hatch: the `skip-version-bump` PR label lets a missing bump pass.
# Downgrades fail even with the label.
#
# Environment:
#   BASE_REF   git revision to compare against (default: origin/main)
#   PR_LABELS  JSON array of PR label names (default: [])

MARKETPLACE=".claude-plugin/marketplace.json"
SKIP_LABEL="skip-version-bump"
SEMVER_RE='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'
BASE_REF="${BASE_REF:-origin/main}"
PR_LABELS="${PR_LABELS:-[]}"

missing_bumps=()
downgrades=()

version_at_base() {
  git show "$BASE_REF:$1" 2>/dev/null | jq -r '.version // empty' 2>/dev/null || true
}

version_on_head() {
  if [ -f "$1" ]; then jq -r '.version // empty' "$1"; fi
}

# Prints "lt", "eq" or "gt": how the first MAJOR.MINOR.PATCH compares to the second
compare_semver() {
  local -a left right
  IFS=. read -r -a left <<< "$1"
  IFS=. read -r -a right <<< "$2"
  for i in 0 1 2; do
    if (( left[i] < right[i] )); then echo lt; return; fi
    if (( left[i] > right[i] )); then echo gt; return; fi
  done
  echo eq
}

check_bump() {
  local label="$1" manifest="$2" before after
  before="$(version_at_base "$manifest")"
  after="$(version_on_head "$manifest")"

  # A new manifest has nothing to compare with; a missing one is reported by
  # `claude plugin validate`.
  if [ -z "$before" ] || [ -z "$after" ]; then return 0; fi

  if ! [[ "$after" =~ $SEMVER_RE ]]; then
    missing_bumps+=("$label: '$after' is not MAJOR.MINOR.PATCH")
    return 0
  fi
  if ! [[ "$before" =~ $SEMVER_RE ]]; then return 0; fi

  case "$(compare_semver "$after" "$before")" in
    eq) missing_bumps+=("$label: version unchanged ($before); bump it per .claude/rules/versioning.md") ;;
    lt) downgrades+=("$label: version went down $before -> $after") ;;
  esac
}

has_skip_label() {
  jq -e --arg label "$SKIP_LABEL" 'index($label) != null' <<< "$PR_LABELS" >/dev/null 2>&1
}

if ! changed_files="$(git diff --name-only "$BASE_REF...HEAD")"; then
  echo "✗ Could not diff against $BASE_REF. Is BASE_REF set and the base branch fetched?" >&2
  exit 1
fi

if [ -z "$changed_files" ]; then
  echo "✓ No changes against $BASE_REF; nothing to check"
  exit 0
fi

owned_plugins="$(jq -r '.plugins[]
  | select((.keywords // []) | index("vendored") | not)
  | "\(.name)\t\(.source | ltrimstr("./"))"' "$MARKETPLACE")"

while IFS=$'\t' read -r name dir; do
  [ -n "$name" ] || continue
  if grep -q "^$dir/" <<< "$changed_files"; then
    check_bump "$name" "$dir/.claude-plugin/plugin.json"
  fi
done <<< "$owned_plugins"

if grep -qx "$MARKETPLACE" <<< "$changed_files"; then
  check_bump "marketplace" "$MARKETPLACE"
fi

if [ ${#downgrades[@]} -gt 0 ]; then
  echo "✗ Version downgrades (they fail even with the '$SKIP_LABEL' label):"
  printf '  - %s\n' "${downgrades[@]}"
  [ ${#missing_bumps[@]} -eq 0 ] || printf '  - %s\n' "${missing_bumps[@]}"
  exit 1
fi

if [ ${#missing_bumps[@]} -eq 0 ]; then
  echo "✓ Version bumps present"
  exit 0
fi

if has_skip_label; then
  echo "⚠ Missing version bumps accepted because of the '$SKIP_LABEL' label:"
  printf '  - %s\n' "${missing_bumps[@]}"
  exit 0
fi

echo "✗ Missing version bumps:"
printf '  - %s\n' "${missing_bumps[@]}"
echo ""
echo "Bump the affected version(s), or add the '$SKIP_LABEL' label to the PR."
exit 1
