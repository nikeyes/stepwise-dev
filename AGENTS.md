# AGENTS.md

This file is the source of truth for coding agents working in this repository.
`CLAUDE.md` is a one-line pointer to it.

## Repository Overview

This is a **workflow tooling project for Claude Code itself**, not a traditional software application. It provides skills, specialized agents, and bash scripts that implement a structured Research → Plan → Implement → Validate development cycle.

The workflow operates entirely locally without cloud dependencies and uses a `thoughts/` directory system for persistent storage.

## Multi-Plugin Architecture

This project is distributed as **independent Claude Code plugins** in a single marketplace:

### Plugin 1: stepwise-core
**Location**: `core/`
**Components**:
- Workflow skills for each phase (research, plan, implement, validate) and `thoughts-management`
- Practice skills the workflow delegates to or the user invokes: TDD, test quality, bug hunting, mutation testing, slicing, plan grilling
- Read-only agents for codebase and `thoughts/` exploration

### Plugin 2: stepwise-git
**Location**: `git/`
**Components**:
- Skills for unattended commits, pull requests with their CI checks, and PR comment review, plus the `ship-pr` skill that chains them

### Plugin 3: stepwise-web
**Location**: `web/`
**Components**:
- A read-only web research agent

### Plugin 4: stepwise-slides
**Location**: `slides/plugins/frontend-slides/` (vendored from `zarazhangrui/frontend-slides`, MIT)
**Components**:
- The `frontend-slides` skill with a large template pack

### Plugin 5: stepwise-diagrams
**Location**: `diagrams/` (vendored from `cathrynlavery/diagram-design`, MIT)
**Components**:
- The `diagram-design` skill: editorial diagrams (architecture, flowchart, sequence, ER, sankey, etc.) as self-contained HTML/SVG

**Installation**:
```bash
# Add marketplace
claude plugin marketplace add git@github.com:nikeyes/stepwise-dev.git

# Install all (or pick individual ones)
claude plugin install stepwise-core@stepwise-dev
claude plugin install stepwise-git@stepwise-dev
claude plugin install stepwise-web@stepwise-dev
claude plugin install stepwise-slides@stepwise-dev
claude plugin install stepwise-diagrams@stepwise-dev
```

See README.md for detailed installation instructions.

## Project Structure

```
.claude-plugin/        # Marketplace configuration
└── marketplace.json   # Marketplace listing every plugin

core/                  # stepwise-core plugin
├── .claude-plugin/
│   └── plugin.json
├── agents/            # <agent>.md, one per agent
└── skills/
    ├── <skill>/SKILL.md
    └── thoughts-management/scripts/   # thoughts-init, thoughts-metadata

git/                   # stepwise-git plugin
├── .claude-plugin/
│   └── plugin.json
└── skills/<skill>/SKILL.md

web/                   # stepwise-web plugin
├── .claude-plugin/
│   └── plugin.json
└── agents/<agent>.md

slides/                # stepwise-slides plugin (vendored via git subtree)
├── LICENSE            # Upstream MIT — preserved for attribution
└── plugins/frontend-slides/
    ├── .claude-plugin/plugin.json
    └── skills/frontend-slides/
        ├── SKILL.md
        └── ...        # template pack

diagrams/              # stepwise-diagrams plugin (vendored via git subtree)
├── LICENSE            # Upstream MIT — preserved for attribution
├── .claude-plugin/plugin.json
└── skills/diagram-design/
    ├── SKILL.md
    └── ...            # references, assets, diagram type packs

scripts/               # Repo tooling used by CI
├── check-version-bumps.sh   # Enforces .claude/rules/versioning.md
└── install-claude-code.sh   # Pinned, SHA256-verified Claude Code install

test/                  # Automated bash tests (for development)
```

## Installation & Testing Workflow

### Installation
```bash
# Add marketplace and install plugins
claude plugin marketplace add git@github.com:nikeyes/stepwise-dev.git
claude plugin install stepwise-core@stepwise-dev
claude plugin install stepwise-git@stepwise-dev
claude plugin install stepwise-web@stepwise-dev
claude plugin install stepwise-slides@stepwise-dev
claude plugin install stepwise-diagrams@stepwise-dev
# Restart Claude Code

# That's it! All components are included in the respective plugins
# No additional installation steps required
```

### Testing Changes

This project has **two types of testing**:

#### 1. Automated Smoke Tests (for bash scripts)

Run automated tests for core bash functionality:

```bash
# Quick smoke test (~2-3 seconds)
make test

# Verbose output with debug info
make test-verbose

# Shellcheck on all bash scripts
make check

# claude plugin validate --strict on the marketplace and every plugin
make validate

# Version bumps required by .claude/rules/versioning.md (compares against origin/main)
make version-bump
```

**What's covered:**
- `core/skills/thoughts-management/scripts/thoughts-init` - Directory creation, README generation
- `core/skills/thoughts-management/scripts/thoughts-metadata` - Metadata generation
- `scripts/check-version-bumps.sh` - Version bump rules

**CI** (`.github/workflows/`):
- `ci.yml` runs `make ci` on every push and PR. Under CI a missing tool
  (shellcheck, claude, jq) fails the build instead of being skipped.
- `pr-checks.yml` checks that the PR title follows Conventional Commits (it becomes
  the squash commit) and runs `make version-bump`. The `skip-version-bump` label
  lets a missing bump pass; downgrades always fail.
- Actions are pinned by SHA and kept current by Dependabot. Claude Code is pinned by
  `CLAUDE_CODE_VERSION` + `CLAUDE_INSTALLER_SHA256` in `ci.yml`, which Dependabot
  does not track: update both together.

**Test files:**
- `test/thoughts-structure-test.sh` - Functional tests for the thoughts scripts
- `test/plugin-structure-test.sh` - Plugin structure tests
- `test/version-bump-test.sh` - Version bump check tests
- `test/test-helpers.sh` - Assertion functions and utilities
- `Makefile` - Test runner targets

#### 2. Manual Testing (for skills/agents)

Skills and agents require manual validation in Claude Code:

1. **Test skills in Claude Code:**
   - Skills are loaded via the plugins
   - After modifying a skill file, restart Claude Code or use `/reload-plugins`
   - Test by invoking: `/stepwise-core:research-codebase`, `/stepwise-git:commit`, etc.

2. **Validate agents:**
   - Agents spawn as sub-tasks when skills execute
   - Test by running skills that use them (e.g., `/stepwise-core:research-codebase` spawns `codebase-locator`)
   - Check agent behavior in Claude Code's task output

3. **Test the thoughts-management Skill:**
   - The Skill activates automatically when Claude needs to manage thoughts/
   - Test by creating research documents or plans with stepwise-core
   - Verify Claude calls the Skill to gather metadata

### Iterative Development Cycle

When modifying **skills/agents**:
1. **Edit** the file in `core/skills/`, `core/agents/`, `git/skills/`, `web/agents/`, etc.
2. **Test locally** via plugin development mode or by reinstalling the specific plugin
3. **Validate** in a sample project
4. **Iterate** based on results

When modifying **scripts in a Skill**:
1. **Edit** the file in the skill's `scripts/` directory
2. **Reinstall** the plugin or test in development mode
3. **Test** by triggering the Skill
4. **Iterate** based on results

## Architecture

### Skill Structure
Skills are directories with a `SKILL.md` entrypoint:
- Frontmatter: `name`, `description`, `model`, `disable-model-invocation`, `allowed-tools`, `argument-hint`
- Instructions for Claude Code on how to behave
- Workflow steps (spawn agents, read files, generate documents)
- Optional supporting files (scripts, templates, references)

### Agent Structure
Agents are specialized markdown files with:
- Frontmatter: `name`, `description`, `tools`, `model`, `color`
- Narrowly-scoped instructions (locate, analyze, or find patterns)
- Called via `Task` tool by skills

### Thoughts System & Skill
The `thoughts-management` Skill provides directory initialization and metadata generation:
```
thoughts/
├── {username}/        # Personal notes (default: nikey_es)
│   ├── tickets/
│   └── notes/
└── shared/            # Team-shared documents
    ├── research/      # Research documents
    ├── plans/         # Implementation plans
    └── prs/           # PR descriptions
```

Use `grep -r thoughts/` to search across all documents.

### Workflow Philosophy

1. **Context management:** Never exceed 60% context
2. **Phased work:** Research → Plan → Implement → Validate
3. **Clear between phases:** Use `/clear` to reset context
4. **Parallel research:** Skills spawn multiple agents concurrently
5. **Local persistence:** All documents saved to `thoughts/` for future reference

## Configuration

**Username**: Set `export THOUGHTS_USER=your_name` (default: `nikey_es`)

### Version Management

**Plugin versions:**
- Managed by Claude Code plugin system
- Check with `claude plugin list`
- Update marketplace and individual plugins:
  - `claude plugin marketplace update stepwise-dev`
  - `claude plugin update stepwise-core@stepwise-dev`
  - `claude plugin update stepwise-git@stepwise-dev`
  - `claude plugin update stepwise-web@stepwise-dev`

**Scripts:**
- Updated automatically when plugin updates
- Part of the plugin package, no separate installation

## Development Workflow

For **scripts**:
1. Edit file in the skill's `scripts/` directory
2. Test using `make test` (runs automated tests)
3. Test manually by triggering the Skill in Claude Code
4. Iterate based on results

For **skills/agents**:
1. Edit file in the specific plugin directory (`core/skills/`, `git/skills/`, `web/agents/`, etc.)
2. Test via plugin reload or development mode
3. Validate in Claude Code
4. Iterate

## Vendored plugins

`stepwise-slides` is imported verbatim from
[`zarazhangrui/frontend-slides`](https://github.com/zarazhangrui/frontend-slides)
(MIT, author Zara Zhang) under the `slides/` prefix via `git subtree`. Upstream
attribution is preserved via `slides/LICENSE`.

Do **not** edit files under `slides/`. Every future `git subtree pull` must
succeed without conflicts; if divergence is needed, wrap the upstream skill
externally instead of patching in place.

Optional sync one-liner (run manually, on demand):

```bash
git subtree pull \
  --prefix=slides \
  https://github.com/zarazhangrui/frontend-slides.git \
  main --squash
```

If the pull changes upstream's `plugin.json` version, mirror it into the
`stepwise-slides` entry of `.claude-plugin/marketplace.json` and patch-bump the
top-level marketplace `version` per `.claude/rules/versioning.md`
(`make validate` fails until the entry matches).

`stepwise-diagrams` is imported verbatim from
[`cathrynlavery/diagram-design`](https://github.com/cathrynlavery/diagram-design)
(MIT, author Cathryn Lavery) under the `diagrams/` prefix via `git subtree`.
Upstream attribution is preserved via `diagrams/LICENSE`.

Do **not** edit files under `diagrams/`. Same rule as above: every future
`git subtree pull` must succeed without conflicts.

Optional sync one-liner (run manually, on demand):

```bash
git subtree pull \
  --prefix=diagrams \
  https://github.com/cathrynlavery/diagram-design.git \
  main --squash
```

If the pull changes upstream's `plugin.json` version, mirror it into the
`stepwise-diagrams` entry of `.claude-plugin/marketplace.json` and patch-bump the
top-level marketplace `version` per `.claude/rules/versioning.md`
(`make validate` fails until the entry matches).

## Attribution

This project is derived from [HumanLayer](https://github.com/humanlayer/humanlayer) and adapted for local-only operation. All `.claude/` components are modified versions licensed under Apache License 2.0.

`stepwise-slides` is vendored from [zarazhangrui/frontend-slides](https://github.com/zarazhangrui/frontend-slides) by Zara Zhang under the MIT License.

`stepwise-diagrams` is vendored from [cathrynlavery/diagram-design](https://github.com/cathrynlavery/diagram-design) by Cathryn Lavery under the MIT License.
