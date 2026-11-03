# Variables
FUNCTIONAL_TEST := test/thoughts-structure-test.sh
STRUCTURE_TEST := test/plugin-structure-test.sh
VERSION_BUMP_TEST := test/version-bump-test.sh
MARKETPLACE_MANIFEST := .claude-plugin/marketplace.json

# A missing tool skips its check locally, but fails under CI (where $CI is set)
# so a broken runner can never report green.
SKIP_OR_FAIL = if [ -n "$$CI" ]; then echo "✗ $(1) not installed (required in CI)"; exit 1; fi; \
	echo "⚠ $(1) not installed, skipping..."

# Eval viewer
SKILL_CREATOR_PATH ?= $(HOME)/.claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/skills/skill-creator
GENERATE_REVIEW := $(SKILL_CREATOR_PATH)/eval-viewer/generate_review.py
ITER ?= LAST

# Phony targets
.PHONY: help test test-verbose check validate version-bump ci eval-list eval-view

# Default target
help:
	@echo "Claude Code Dev Workflow - Available targets:"
	@echo ""
	@echo "  make test               - Run all tests (default)"
	@echo "  make test-verbose       - Run tests with debug output"
	@echo "  make check              - Run shellcheck on all bash scripts"
	@echo "  make validate           - Run claude plugin validate --strict on the marketplace and plugins"
	@echo "  make version-bump       - Check version bumps against BASE_REF (default: origin/main)"
	@echo "  make ci                 - Run full CI validation (test + check + validate)"
	@echo ""
	@echo "Eval viewer:"
	@echo "  make eval-list                                      - List skills with eval iterations"
	@echo "  make eval-view SKILL=test-desiderata                - View latest iteration"
	@echo "  make eval-view SKILL=test-desiderata ITER=1         - View specific iteration"
	@echo "  make eval-view SKILL=test-desiderata PREV=1         - Compare latest vs iteration-1"
	@echo ""

# ============================================================================
# Test targets
# ============================================================================

# Run all automated tests (functional + structure)
test:
	@echo "Running functional tests..."
	@$(FUNCTIONAL_TEST)
	@echo "Running plugin structure tests..."
	@$(STRUCTURE_TEST)
	@echo "Running version bump check tests..."
	@$(VERSION_BUMP_TEST)
	@echo ""
	@echo "✓ All automated tests completed"

# Run tests with verbose debug output
test-verbose:
	@echo "Running functional tests (verbose mode)..."
	@bash -x $(FUNCTIONAL_TEST)
	@echo "Running plugin structure tests (verbose mode)..."
	@bash -x $(STRUCTURE_TEST)
	@echo "Running version bump check tests (verbose mode)..."
	@bash -x $(VERSION_BUMP_TEST)

# Run shellcheck on all bash scripts
check:
	@echo "Running shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck core/skills/thoughts-management/scripts/* scripts/*.sh test/*.sh && echo "✓ Shellcheck passed"; \
	else \
		echo "  Install with: brew install shellcheck (macOS) or apt install shellcheck (Linux)"; \
		$(call SKIP_OR_FAIL,shellcheck); \
	fi

# ============================================================================
# CI
# ============================================================================

# Validate marketplace and plugin manifests against Claude Code's own schema.
# --strict also fails when a marketplace entry's version drifts from its plugin.json.
validate:
	@echo "Validating marketplace and plugins..."
	@if command -v claude >/dev/null 2>&1; then \
		claude plugin validate --strict . || exit 1; \
		for source in $$(jq -r '.plugins[].source' $(MARKETPLACE_MANIFEST)); do \
			claude plugin validate --strict "$$source/.claude-plugin/plugin.json" || exit 1; \
		done; \
		echo "✓ Marketplace and plugins valid"; \
	else \
		echo "  Install with: https://code.claude.com/docs/en/setup"; \
		$(call SKIP_OR_FAIL,claude); \
	fi

# Fail when plugin or marketplace content changed without a version bump
version-bump:
	@scripts/check-version-bumps.sh

# Full CI validation (test + check + manifest validation)
ci: test check validate
	@echo ""
	@echo "✓ All CI checks passed"

# ============================================================================
# Eval viewer targets
# ============================================================================

_check-skill:
ifndef SKILL
	$(error SKILL is required. Usage: make eval-view SKILL=test-desiderata)
endif

_check-viewer:
	@test -f "$(GENERATE_REVIEW)" || (echo "Error: generate_review.py not found at $(GENERATE_REVIEW)" && echo "Set SKILL_CREATOR_PATH to your skill-creator directory" && exit 1)

eval-list:
	@for ws in */skills/*-workspace; do \
		skill=$$(basename "$$ws" | sed 's/-workspace$$//'); \
		iters=$$(ls -d "$$ws"/iteration-* 2>/dev/null | sort -V); \
		if [ -n "$$iters" ]; then \
			count=$$(echo "$$iters" | wc -l | tr -d ' '); \
			last=$$(echo "$$iters" | tail -1 | xargs basename); \
			echo "  $$skill  ($$count iterations, latest: $$last)"; \
		fi; \
	done

eval-view: _check-skill _check-viewer
	$(eval _WS := $(shell ls -d */skills/$(SKILL)-workspace 2>/dev/null | head -1))
	$(eval _RESOLVED_ITER := $(if $(filter LAST,$(ITER)),$(shell ls -d $(_WS)/iteration-* 2>/dev/null | sort -V | tail -1 | xargs basename),iteration-$(ITER)))
	@python "$(GENERATE_REVIEW)" "$(_WS)/$(_RESOLVED_ITER)" \
		--skill-name "$(SKILL)" \
		--benchmark "$(_WS)/$(_RESOLVED_ITER)/benchmark.json" \
		$(if $(PREV),--previous-workspace "$(_WS)/iteration-$(PREV)")
