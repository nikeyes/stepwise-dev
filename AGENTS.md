# AGENTS.md

This file is the source of truth for coding agents working in this repository.
`CLAUDE.md` is a one-line pointer to it.

## Repository Overview

This is a **workflow tooling project for Claude Code itself**, not a traditional software application. It provides skills, specialized agents, and bash scripts that implement a structured Research → Plan → Implement → Validate development cycle.

The workflow operates entirely locally without cloud dependencies and uses a `thoughts/` directory system for persistent storage.

## Plugins

The repo is one marketplace with **independent Claude Code plugins**:

| Plugin | Location | Contents |
|---|---|---|
| `stepwise-core` | `core/` | Workflow skills for each phase (research, plan, implement, validate) and `thoughts-management`; practice skills the workflow delegates to or the user invokes (TDD, test quality, bug hunting, mutation testing, slicing, plan grilling); read-only agents for codebase and `thoughts/` exploration |
| `stepwise-git` | `git/` | Skills for unattended commits, pull requests with their CI checks, and PR comment review, plus `ship-pr` that chains them |
| `stepwise-web` | `web/` | A read-only web research agent |
| `stepwise-slides` | `slides/plugins/frontend-slides/` | Vendored `frontend-slides` skill (see [Vendored plugins](#vendored-plugins)) |
| `stepwise-diagrams` | `diagrams/` | Vendored `diagram-design` skill (see [Vendored plugins](#vendored-plugins)) |

Installation steps are in README.md.

## Project Structure

```
.claude-plugin/marketplace.json   # Marketplace listing every plugin

core/                  # stepwise-core
├── .claude-plugin/plugin.json
├── agents/<agent>.md
└── skills/
    ├── <skill>/SKILL.md
    └── thoughts-management/scripts/   # thoughts-init, thoughts-metadata

git/                   # stepwise-git
├── .claude-plugin/plugin.json
└── skills/<skill>/SKILL.md

web/                   # stepwise-web
├── .claude-plugin/plugin.json
└── agents/<agent>.md

slides/                # stepwise-slides (vendored via git subtree, do not edit)
diagrams/              # stepwise-diagrams (vendored via git subtree, do not edit)

scripts/               # Repo tooling used by CI
├── check-version-bumps.sh   # Enforces .claude/rules/versioning.md
└── install-claude-code.sh   # Pinned, SHA256-verified Claude Code install

test/                  # Automated bash tests
```

## Testing

### Automated tests

```bash
make test          # Smoke tests (~2-3 seconds)
make test-verbose  # Same, with debug output
make check         # Shellcheck on all bash scripts
make validate      # claude plugin validate --strict on the marketplace and every plugin
make version-bump  # Version bumps required by .claude/rules/versioning.md (against origin/main)
make ci            # test + check + validate
```

**Test files:**
- `test/thoughts-structure-test.sh`: functional tests for `thoughts-init` and `thoughts-metadata`
- `test/plugin-structure-test.sh`: plugin structure tests
- `test/version-bump-test.sh`: tests for `scripts/check-version-bumps.sh`
- `test/test-helpers.sh`: assertion functions

**CI** (`.github/workflows/`):
- `ci.yml` runs `make ci` on every push and PR. Under CI a missing tool
  (shellcheck, claude, jq) fails the build instead of being skipped.
- `pr-checks.yml` checks that the PR title follows Conventional Commits (it becomes
  the squash commit) and runs `make version-bump`. The `skip-version-bump` label
  lets a missing bump pass; downgrades always fail.
- Actions are pinned by SHA and kept current by Dependabot. Claude Code is pinned by
  `CLAUDE_CODE_VERSION` + `CLAUDE_INSTALLER_SHA256` in `ci.yml`, which Dependabot
  does not track: update both together.

### Manual testing (skills and agents)

Skills and agents have no automated tests. Validate them in Claude Code:

1. Edit the file in the plugin directory (`core/skills/`, `core/agents/`, `git/skills/`, `web/agents/`, ...).
2. Load your copy: `claude --plugin-dir <plugin-dir>` overrides the installed plugin, or run `/reload-plugins` after a reinstall.
3. Invoke the skill in a sample project, e.g. `/stepwise-core:research-codebase` or `/stepwise-git:commit`.
4. Check the agents it spawns in the task output (e.g. `research-codebase` spawns `codebase-locator`).
5. For `thoughts-management`, create a research document or plan and check that Claude calls the skill for metadata.

## Architecture

### Skills
A directory with a `SKILL.md` entrypoint:
- Frontmatter: `name`, `description`, `model`, `disable-model-invocation`, `allowed-tools`, `argument-hint`
- Instructions and workflow steps (spawn agents, read files, generate documents)
- Optional supporting files (scripts, templates, references)

### Agents
A markdown file with:
- Frontmatter: `name`, `description`, `tools`, `model`, `color`
- Narrowly scoped instructions (locate, analyze, or find patterns)
- Spawned by skills through the `Task` tool

### Thoughts system
The `thoughts-management` skill initializes the directory and generates document metadata:
```
thoughts/
├── {username}/        # Personal notes (THOUGHTS_USER, default: nikey_es)
│   ├── tickets/
│   └── notes/
└── shared/            # Team-shared documents
    ├── research/
    ├── plans/
    └── prs/
```

### Workflow philosophy

1. **Context management:** Never exceed 60% context
2. **Phased work:** Research → Plan → Implement → Validate
3. **Clear between phases:** Use `/clear` to reset context
4. **Parallel research:** Skills spawn multiple agents concurrently
5. **Local persistence:** All documents saved to `thoughts/` for future reference

## Versioning

Every change inside a plugin directory, or to `marketplace.json`, needs a version
bump. The rules are in `.claude/rules/versioning.md`; `make validate` and
`make version-bump` enforce them.

## Vendored plugins

Two plugins are imported verbatim via `git subtree`. Do **not** edit files under
their prefix: every future `git subtree pull` must succeed without conflicts. If
divergence is needed, wrap the upstream skill externally instead of patching in place.

| Prefix | Upstream | License |
|---|---|---|
| `slides/` | [`zarazhangrui/frontend-slides`](https://github.com/zarazhangrui/frontend-slides) | MIT, Zara Zhang (`slides/LICENSE`) |
| `diagrams/` | [`cathrynlavery/diagram-design`](https://github.com/cathrynlavery/diagram-design) | MIT, Cathryn Lavery (`diagrams/LICENSE`) |

Sync on demand:

```bash
git subtree pull --prefix=slides https://github.com/zarazhangrui/frontend-slides.git main --squash
git subtree pull --prefix=diagrams https://github.com/cathrynlavery/diagram-design.git main --squash
```

If a pull changes upstream's `plugin.json` version, mirror it into the plugin's
entry of `.claude-plugin/marketplace.json` and patch-bump the top-level marketplace
`version` (`make validate` fails until the entry matches).

## Attribution

This project is derived from [HumanLayer](https://github.com/humanlayer/humanlayer) and adapted for local-only operation. All `.claude/` components are modified versions licensed under Apache License 2.0.

`stepwise-slides` is vendored from [zarazhangrui/frontend-slides](https://github.com/zarazhangrui/frontend-slides) by Zara Zhang under the MIT License.

`stepwise-diagrams` is vendored from [cathrynlavery/diagram-design](https://github.com/cathrynlavery/diagram-design) by Cathryn Lavery under the MIT License.
