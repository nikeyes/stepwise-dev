# AGENTS.md

This file is the source of truth for coding agents working in this repository.
`CLAUDE.md` is a one-line pointer to it, so Claude Code and OpenAI Codex read the same guidance.

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
- The `implement-and-validate` workflow and its agents, each preloading the skill it applies

### Plugin 2: stepwise-git
**Location**: `git/`
**Components**:
- Skills for commits without Claude attribution and for PR comment review

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
├── workflows/         # <workflow>.js, dynamic workflows (Claude Code only)
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

codex/                 # OpenAI Codex compatibility layer
├── agents/*.toml      # Generated, one per agent
├── transpile-agents.sh
├── install.sh
└── uninstall.sh

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
- `test/smoke-test.sh` - Main integration tests
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

### Workflow Structure
Workflows are JavaScript scripts in `core/workflows/` that the Claude Code runtime executes (Claude Code only; Codex has no equivalent):
- `export const meta` first, as a plain literal; `meta.name` becomes `/stepwise-core:<name>`
- The script only orchestrates: every step is an `agent()` call, usually a `core/agents/` agent that preloads one skill via `skills:`
- No automated tests for the script's logic: validate changes by running it on a real plan

`implement-and-validate` duplicates the phase cycle of `implement-plan` (tdd → bugmagnet → mutation-testing → test-desiderata → verify → checkboxes) and reads the outputs of those skills and `validate-plan` through its schemas. Keep them in sync:
- When you change the cycle in `core/skills/implement-plan/SKILL.md`, change `core/workflows/implement-and-validate.js` too, and vice versa.
- When you change `tdd`, `bugmagnet`, `mutation-testing`, `test-desiderata` or `validate-plan`, run the workflow on a plan again to check it still works.

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

## Codex compatibility

The same `skills/` directories serve both Claude Code and Codex. The only generated
artifacts are the agent `.toml` files. Workflows (`core/workflows/`) have no Codex
equivalent: Codex has no Workflow tool, so it keeps using `implement-plan` and `validate-plan`.

```
codex/
├── agents/*.toml          # GENERATED — do not edit by hand
├── transpile-agents.sh    # core|web/agents/*.md -> codex/agents/*.toml
├── install.sh             # symlinks skills + copies agents
└── uninstall.sh           # removes only what install.sh created
```

### Install

```bash
make install-codex
```

Skills are symlinked into `~/.agents/skills/` (Codex follows symlinks when scanning)
and agents are copied into `~/.codex/agents/`.

### Conventions

- **`${CLAUDE_PLUGIN_ROOT:-$HOME/.agents}`** — script paths in SKILL.md use this shell
  default so the same line resolves under both harnesses. This *codifies* `$HOME/.agents/skills/`
  as the Codex install location; it is a convention, not a detection, and `install.sh`
  must keep honoring it.
- **`agents/openai.yaml`** in a skill mirrors its `disable-model-invocation` for Codex:
  `true` becomes `allow_implicit_invocation: false`, and `false` becomes `true`.
  The test suite derives the list of skills needing one from the frontmatter, so a
  skill that declares the key without a matching `openai.yaml` fails `make test`.
- **`model: inherit`** transpiles to *no* `model` key in the TOML: a Codex agent without
  one runs on the session's configured model, which is what `inherit` means. The
  `haiku`/`sonnet`/`opus` mappings remain for an agent that deliberately pins a model.
- Agents are regenerated with `make transpile-codex`. `make check-codex` (wired into
  `make ci`) fails if a `.md` changed without regenerating, if a TOML is malformed, or
  if a bare `${CLAUDE_PLUGIN_ROOT}` appears without its `:-` default.

### Known limitations

`research-codebase`, `create-plan` and `iterate-plan` use `$ARGUMENTS`, which Codex does
not expand — under Codex, pass the input in the message itself.

`model: inherit` in a SKILL.md frontmatter makes Codex log `ignoring invalid skill
model annotation`, once per skill that declares it. Only the annotation is dropped,
never the skill: it loads and runs on the session's model, which is what `inherit`
asks for anyway. The key stays because Claude Code needs it.


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
