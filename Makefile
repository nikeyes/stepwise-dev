.PHONY: test check test-verbose install help

# Default target
help:
	@echo "Claude Code Dev Workflow - Available targets:"
	@echo ""
	@echo "  make test          - Run smoke tests"
	@echo "  make test-verbose  - Run smoke tests with debug output"
	@echo "  make check         - Run shellcheck on all bash scripts"
	@echo "  make install       - Run install.sh to install globally"
	@echo "  make help          - Show this help message"
	@echo ""

# Run smoke tests
test:
	@echo "Running smoke tests..."
	@./test/smoke-test.sh

# Run smoke tests with verbose output (shows all commands)
test-verbose:
	@echo "Running smoke tests (verbose mode)..."
	@bash -x ./test/smoke-test.sh

# Run shellcheck on all bash scripts
check:
	@echo "Running shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck bin/* install.sh test/*.sh && echo "✓ Shellcheck passed"; \
	else \
		echo "⚠ shellcheck not installed, skipping..."; \
		echo "  Install with: brew install shellcheck (macOS) or apt install shellcheck (Linux)"; \
	fi

# Install globally (interactive)
install:
	@./install.sh
