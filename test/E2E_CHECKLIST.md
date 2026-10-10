# Testing Checklist

## Automated Tests

Run before every commit:

```bash
make test           # Functional, plugin structure, Codex and version-bump tests
make check          # Shellcheck validation
make check-codex    # Generated Codex agents are in sync
make validate       # claude plugin validate --strict on the marketplace and every plugin

# Or run all at once:
make ci             # test + check + check-codex + validate
```

## Manual Plugin Tests

**These tests require Claude Code runtime and cannot be automated:**

### Installation & Setup
- [ ] `/plugin install workflow-dev@workflow-dev-marketplace`
- [ ] Restart Claude Code
- [ ] `/help` shows 6 commands (automated test verifies files exist)
- [ ] `./install-scripts.sh` installs scripts (automated test verifies script works)

### Workflow Quality (LLM behavior)
- [ ] `/stepwise-core:research-codebase [real topic]` - Verify research document quality
- [ ] `/stepwise-core:create-plan [from ticket]` - Verify plan is actionable and thorough
- [ ] Agents spawn correctly and run in parallel
- [ ] Context management warnings appear appropriately

### Plugin Lifecycle
- [ ] `/plugin disable workflow-dev@workflow-dev-marketplace`
- [ ] Commands disappear from `/help`
- [ ] `/plugin enable workflow-dev@workflow-dev-marketplace`
- [ ] Commands return

## Before Release

- [ ] All automated tests pass
- [ ] Manual tests complete
- [ ] Documentation accurate
- [ ] Version numbers consistent
- [ ] No sensitive data

## Notes

Record issues found:
-
-
