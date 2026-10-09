#!/usr/bin/env bash
set -euo pipefail

# install-claude-code.sh - Installs Claude Code for CI via the official native
# installer, pinned by version and integrity-checked by SHA256.
#
# Chain of trust:
#   1. install.sh is downloaded to a file (never piped into a shell).
#   2. Its SHA256 must match CLAUDE_INSTALLER_SHA256, pinned in the workflow.
#   3. install.sh then verifies the binary's SHA256 against Anthropic's
#      manifest for the current platform.
#
# Dependabot does not track these values: when upgrading, update
# CLAUDE_CODE_VERSION and CLAUDE_INSTALLER_SHA256 together in the workflow.

: "${CLAUDE_CODE_VERSION:?CLAUDE_CODE_VERSION must be set}"
: "${CLAUDE_INSTALLER_SHA256:?CLAUDE_INSTALLER_SHA256 must be set}"

installer="$(mktemp)"
trap 'rm -f "$installer"' EXIT

echo "Downloading install.sh from claude.ai"
curl -fsSL --proto '=https' --tlsv1.2 https://claude.ai/install.sh -o "$installer"

echo "Verifying installer SHA256"
if command -v sha256sum >/dev/null; then
  actual="$(sha256sum "$installer" | awk '{print $1}')"
else
  actual="$(shasum -a 256 "$installer" | awk '{print $1}')"
fi

if [[ "$actual" != "$CLAUDE_INSTALLER_SHA256" ]]; then
  echo "✗ install.sh SHA256 mismatch" >&2
  echo "  expected: $CLAUDE_INSTALLER_SHA256" >&2
  echo "  actual:   $actual" >&2
  echo "If Anthropic released a new installer, review it and update CLAUDE_INSTALLER_SHA256 in the workflow." >&2
  exit 1
fi

echo "Installer verified. Installing Claude Code $CLAUDE_CODE_VERSION"
bash "$installer" "$CLAUDE_CODE_VERSION"
