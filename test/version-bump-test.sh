#!/usr/bin/env bash
set -uo pipefail

# version-bump-test.sh - Behavioral tests for scripts/check-version-bumps.sh.
# Every test runs against a throwaway git repo with a minimal marketplace: one
# owned plugin (core/) and one vendored plugin (vendor/plugin/).

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CHECK="$PROJECT_ROOT/scripts/check-version-bumps.sh"

# shellcheck source=test/test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Version Bump Check Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

REPO="$(mktemp -d)"
trap 'rm -rf "$REPO"' EXIT

set_version() {
  local manifest="$1" version="$2" tmp
  tmp="$(mktemp)"
  jq --arg v "$version" '.version = $v' "$manifest" > "$tmp" && mv "$tmp" "$manifest"
}

commit_all() {
  git add -A && git commit -qm "$1"
}

new_case() {
  git checkout -qf -B "$1" base
}

CHECK_OUTPUT=""
CHECK_STATUS=0
run_check() {
  local labels="${1:-[]}"
  CHECK_OUTPUT="$(BASE_REF=base PR_LABELS="$labels" "$CHECK" 2>&1)"
  CHECK_STATUS=$?
}

setup_git_repo "$REPO"
mkdir -p .claude-plugin core/.claude-plugin core/skills/demo vendor/plugin/.claude-plugin
cat > .claude-plugin/marketplace.json <<'EOF'
{
  "name": "fixture",
  "version": "1.0.0",
  "plugins": [
    { "name": "fixture-core", "source": "./core", "version": "1.9.0" },
    { "name": "fixture-vendor", "source": "./vendor/plugin", "version": "3.0.0", "keywords": ["vendored"] }
  ]
}
EOF
echo '{ "name": "fixture-core", "version": "1.9.0" }' > core/.claude-plugin/plugin.json
echo '{ "name": "fixture-vendor", "version": "3.0.0" }' > vendor/plugin/.claude-plugin/plugin.json
echo "demo" > core/skills/demo/SKILL.md
echo "upstream" > vendor/plugin/README.md
commit_all "base"
git branch -q base

# ============================================================================
# Test 1: No changes
# ============================================================================
section "Test 1: No changes"

new_case no-changes
run_check
assert_equals "0" "$CHECK_STATUS" "passes when nothing changed"

# ============================================================================
# Test 2: Owned plugin edited without a bump
# ============================================================================
section "Test 2: Owned plugin without bump"

new_case owned-no-bump
echo "edited" >> core/skills/demo/SKILL.md
commit_all "edit skill"
run_check
assert_equals "1" "$CHECK_STATUS" "fails when an owned plugin changes without a bump"
assert_output_contains "$CHECK_OUTPUT" "fixture-core: version unchanged (1.9.0)" "names the plugin and its version"

# ============================================================================
# Test 3: Owned plugin bumped and marketplace bumped
# ============================================================================
section "Test 3: Owned plugin with full bump"

new_case owned-full-bump
echo "edited" >> core/skills/demo/SKILL.md
set_version core/.claude-plugin/plugin.json "1.10.0"
set_version .claude-plugin/marketplace.json "1.0.1"
commit_all "edit skill and bump"
run_check
assert_equals "0" "$CHECK_STATUS" "passes when plugin and marketplace are bumped (1.9.0 -> 1.10.0 compares numerically)"

# ============================================================================
# Test 4: Marketplace edited without a top-level bump
# ============================================================================
section "Test 4: Marketplace without bump"

new_case marketplace-no-bump
echo "edited" >> core/skills/demo/SKILL.md
set_version core/.claude-plugin/plugin.json "1.9.1"
jq '.plugins[0].version = "1.9.1"' .claude-plugin/marketplace.json > mp.tmp && mv mp.tmp .claude-plugin/marketplace.json
commit_all "bump plugin, forget marketplace"
run_check
assert_equals "1" "$CHECK_STATUS" "fails when marketplace.json changes without a top-level bump"
assert_output_contains "$CHECK_OUTPUT" "marketplace: version unchanged (1.0.0)" "names the marketplace"

# ============================================================================
# Test 5: Vendored plugin edited without a bump
# ============================================================================
section "Test 5: Vendored plugin"

new_case vendored-no-bump
echo "subtree pull" >> vendor/plugin/README.md
commit_all "subtree pull"
run_check
assert_equals "0" "$CHECK_STATUS" "vendored plugins are exempt: their plugin.json belongs upstream"

# ============================================================================
# Test 6: Escape hatch label
# ============================================================================
section "Test 6: skip-version-bump label"

new_case skip-label
echo "edited" >> core/skills/demo/SKILL.md
commit_all "edit skill"
run_check '["documentation", "skip-version-bump"]'
assert_equals "0" "$CHECK_STATUS" "a missing bump passes with the skip-version-bump label"

# ============================================================================
# Test 7: Downgrades
# ============================================================================
section "Test 7: Downgrade"

new_case downgrade
set_version core/.claude-plugin/plugin.json "1.8.9"
set_version .claude-plugin/marketplace.json "1.0.1"
commit_all "downgrade"
run_check '["skip-version-bump"]'
assert_equals "1" "$CHECK_STATUS" "a downgrade fails even with the skip-version-bump label"
assert_output_contains "$CHECK_OUTPUT" "fixture-core: version went down 1.9.0 -> 1.8.9" "reports the downgrade"

# ============================================================================
# Test 8: Non-semver versions
# ============================================================================
section "Test 8: Invalid version"

new_case invalid-version
echo "edited" >> core/skills/demo/SKILL.md
set_version core/.claude-plugin/plugin.json "2.0"
set_version .claude-plugin/marketplace.json "1.0.1"
commit_all "bad version"
run_check
assert_equals "1" "$CHECK_STATUS" "fails on a version that is not MAJOR.MINOR.PATCH"
assert_output_contains "$CHECK_OUTPUT" "fixture-core: '2.0' is not MAJOR.MINOR.PATCH" "reports the invalid version"

print_summary
