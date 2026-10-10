# Stepwise Dev - Multi-Plugin Suite

[![Plugin Available](https://img.shields.io/badge/Claude_Code-Plugin_Available-blue)](https://github.com/nikeyes/stepwise-dev)
[![License](https://img.shields.io/badge/License-Apache_2.0-green.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen)](test/)

A modular development workflow suite for Claude Code inspired by [Ashley Ha's workflow](https://medium.com/@ashleyha/i-mastered-the-claude-code-workflow-145d25e502cf), adapted to work 100% locally with thoughts.

**📖 Read more**: [Tu CLAUDE.md no funciona sin Context Engineering](https://nikeyes.github.io/tu-claude-md-no-funciona-sin-context-engineering-es/) (Spanish article about Stepwise-dev)

## 🎯 What This Is

Solves the context management problem: LLMs lose attention after 60% context usage.

Implements **Research → Plan → Implement → Validate** with frequent `/clear` and persistent `thoughts/` storage.

### Philosophy

- Keep context < 60% (attention threshold)
- Split work into phases
- Clear between phases, save to `thoughts/`
- Never lose research or decisions

### Why This Workflow With AI

**More generated code = more risk if you don't have a solid feedback loop.**

The faster AI generates code, the more these practices matter:

- **Story Splitting** — AI can produce a lot in little time. If scope isn't cut, chaos scales just as fast.
- **Hamburger Method** — Deliver value end-to-end continuously by slicing features into thin vertical layers.
- **Small Safe Steps** — Each step must be reversible. Speed of generation is not speed to production.
- **Advanced testing** — Mutation, acceptance, and architectural testing. The feedback loop must be solid. No more excuses.

## 📦 Available Plugins

This repository contains **independent plugins** that can be installed separately based on your needs:

### 1. **stepwise-core** (Core Workflow)
The foundation plugin with the complete Research → Plan → Implement → Validate cycle.

**Includes:**
- A skill for each phase, plus practice skills (TDD, test quality, bug hunting, mutation testing, slicing). See [the four-phase workflow](#-the-four-phase-workflow) for when to use each one
- Read-only agents for codebase exploration and thoughts management
- The `implement-and-validate` workflow: implements a plan phase by phase and validates it, unattended (Claude Code only)

[→ Read more](./core/README.md)

### 2. **stepwise-git** (Git & GitHub Operations)
Clean git commit workflow without Claude attribution, plus rigorous PR comment review.

**Includes:**
- Smart staging and commit message generation
- PR comment negotiation with individual inline replies

[→ Read more](./git/README.md)

### 3. **stepwise-web** (Web Research)
Web search and research capabilities for external context.

**Includes:**
- `web-search-researcher` agent: deep web research with source citations

[→ Read more](./web/README.md)

### 4. **stepwise-slides** (HTML Slide Decks)
Generate beautiful HTML presentations from a coding agent. **Vendored** from [zarazhangrui/frontend-slides](https://github.com/zarazhangrui/frontend-slides) (MIT, author Zara Zhang).

**Includes:**
- `frontend-slides` skill with a large template pack

### 5. **stepwise-diagrams** (Editorial Diagrams)
Create editorial diagrams (architecture, flowchart, sequence, ER, sankey, quadrant, radar, and more) as self-contained HTML/SVG. **Vendored** from [cathrynlavery/diagram-design](https://github.com/cathrynlavery/diagram-design) (MIT, author Cathryn Lavery).

**Includes:**
- `diagram-design` skill with references, assets, and diagram type packs

## 🚀 Installation

### Option 1: Install All Plugins (Recommended for first-time users)

```bash
claude plugin marketplace add https://github.com/nikeyes/stepwise-dev.git

# Install all plugins
claude plugin install stepwise-core@stepwise-dev
claude plugin install stepwise-git@stepwise-dev
claude plugin install stepwise-web@stepwise-dev
claude plugin install stepwise-slides@stepwise-dev
claude plugin install stepwise-diagrams@stepwise-dev
```

### Option 2: Install Only What You Need

```bash
# Add marketplace (SSH or HTTPS)
claude plugin marketplace add https://github.com/nikeyes/stepwise-dev.git

# Install only the core workflow
claude plugin install stepwise-core@stepwise-dev

# Optionally add git operations
claude plugin install stepwise-git@stepwise-dev

# Optionally add web research
claude plugin install stepwise-web@stepwise-dev

# Optionally add HTML slide generation (vendored)
claude plugin install stepwise-slides@stepwise-dev

# Optionally add editorial diagram generation (vendored)
claude plugin install stepwise-diagrams@stepwise-dev
```

**Restart Claude Code after installation.**

### Local Development (Testing Without Installing)

There are two ways to test your local plugin directories without reinstalling anything.

**Option 1: `--bare` (quickest).** Loads only the directories you pass via `--plugin-dir` and skips all installed/marketplace plugins:

```bash
claude --bare \
    --plugin-dir /path/to/stepwise-dev/core \
    --plugin-dir /path/to/stepwise-dev/git \
    --plugin-dir /path/to/stepwise-dev/web
```

`--bare` disables plugin sync (so installed plugins are ignored) but still loads the directories you pass via `--plugin-dir`. Good for testing a single skill you invoke yourself.

> **Limitation:** `--bare` runs in minimal mode, so the model only gets Bash, Read and Edit. Without the `Skill` tool, a skill can't invoke another one. A skill you type as `/skill-name` still runs, but its handoffs don't: `implement-plan` (delegates to tdd, bugmagnet, mutation-testing and test-desiderata), `create-plan` (calls `grill-me`) and `mutation-testing` (calls `tdd`). Use Option 2 for those.

**Option 2: disable the installed copies.** A normal session with every tool, including `Skill`:

```bash
claude plugin disable stepwise-core@stepwise-dev
claude plugin disable stepwise-git@stepwise-dev
claude plugin disable stepwise-web@stepwise-dev

claude --plugin-dir /path/to/stepwise-dev/core \
       --plugin-dir /path/to/stepwise-dev/git \
       --plugin-dir /path/to/stepwise-dev/web

# When you're done
claude plugin enable stepwise-core@stepwise-dev   # and the same for git and web
```

## 🤖 Using It with Codex

The same skills also run under OpenAI Codex.

- **From a clone of this repo:**
  ```bash
  make install-codex
  ```
- **Already installed via the Claude Code marketplace?** The full repo (including `Makefile` and `codex/`) lives in `~/.claude/plugins/marketplaces/stepwise-dev/`, so:
  ```bash
  cd ~/.claude/plugins/marketplaces/stepwise-dev && make install-codex
  ```

This installs:

- **Every skill** from core, git and the vendored slides and diagrams plugins, symlinked into `~/.agents/skills/`. Codex follows symlinks when scanning that directory, so edits in the repo take effect immediately
- **Every agent** copied into `~/.codex/agents/` as TOML, generated from the agent markdown by `codex/transpile-agents.sh`

Regenerate the agents after editing any `*/agents/*.md` with `make transpile-codex`; `make check-codex` fails if they're out of sync.

### Known limitations under Codex

- `research-codebase`, `create-plan` and `iterate-plan` use `$ARGUMENTS`, which Codex does not expand. You'll see the literal string — pass your input in the message itself instead.
- Codex only delegates to subagents on an explicit instruction, so the skills spell out the parallel spawns. If a skill investigates in its main context instead of spawning agents, say so explicitly in your prompt.
- Skills that declare `disable-model-invocation` carry an `agents/openai.yaml` with the matching `allow_implicit_invocation` policy. This is documented for the ChatGPT desktop app; whether the Codex CLI honors it is unverified.

## 🧪 Try It Out

Don't have a project to test with? Use [stepwise-todo-api-test](https://github.com/nikeyes/stepwise-todo-api-test) — a sample repository designed for testing these plugins.

## 📁 Directory Structure

After running `thoughts-init` (from stepwise-core) in a project:

```
<your-project>/
├── thoughts/
│   ├── nikey_es/          # Your personal notes (you write)
│   │   ├── tickets/       # Ticket documentation
│   │   └── notes/         # Personal notes
│   └── shared/            # Team-shared documents (Claude writes)
│       ├── research/      # Research documents
│       ├── plans/         # Implementation plans
│       └── prs/           # PR descriptions
└── ...
```

**Key distinction:**
- **`nikey_es/`**: Personal tickets/notes you create manually
- **`shared/`**: Formal docs Claude generates from commands

Use `grep -r thoughts/` to search across all documents.

## 🔄 The Four-Phase Workflow

**Use `/clear` between phases.** Knowledge lives in `thoughts/`, not in the context window.

### Quick reference

| Phase | Main command | Helpers (skills / agents) |
|---|---|---|
| Across all phases | `/clear` between phases | `thoughts-management`, `thoughts-locator`, `thoughts-analyzer` |
| **Before** (product side) | `/story-splitting` | Applied to the PRD / ticket / use case — **not** the code |
| 🔍 Research | `/research-codebase` | `codebase-locator`, `codebase-analyzer`, `codebase-pattern-finder`, `web-search-researcher` |
| 🗺️ Plan | `/create-plan`, `/iterate-plan` | `/hamburger-method`, `/small-safe-steps`, `/grill-me` (stress-test the plan) |
| 🛠️ Implement | `/implement-plan` (or `/implement-and-validate` to implement and validate unattended), `/commit` | `/tdd` (test-first development), `/test-desiderata` (test quality), `/bugmagnet <file>` (edge-case & bug hunt), `/mutation-testing` (would tests catch a bug?) |
| ✅ Validate | `/validate-plan` | — |
| 🌐 Any web lookup | _"search the web for..."_ | `web-search-researcher` fires automatically |

### Phase 1: Research (stepwise-core)

```bash
/stepwise-core:research-codebase How does authentication work?
```

Spawns parallel agents, searches codebase and thoughts/, generates comprehensive research document.

### Phase 2: Plan (stepwise-core)

```bash
/stepwise-core:create-plan Add rate limiting to the API
```

Iterates with you 5+ times, creates detailed phases with verification steps. Use `/grill-me` to stress-test the plan before moving on — it interviews you on every assumption until the design is solid.

### Phase 3: Implement (stepwise-core)

```bash
/stepwise-core:implement-plan @thoughts/shared/plans/2025-11-09-rate-limiting.md
```

Executes one phase at a time, validates before proceeding. Use `/tdd` to drive the implementation test-first (red→green→refactor). While implementing, lean on `/test-desiderata` to keep test quality high, `/bugmagnet <file>` to surface edge cases on a specific module, and `/mutation-testing` to check that the tests would actually catch a bug in the changed code.

### Phase 4: Validate (stepwise-core)

```bash
/stepwise-core:validate-plan @thoughts/shared/plans/2025-11-09-rate-limiting.md
```

Systematically verifies the entire implementation.

### Commit (stepwise-git)

```bash
/stepwise-git:commit
```

Creates clean commits without Claude attribution.

## 💡 Usage Examples

### Example 1: Complete Feature Development

```bash
# Research (core)
/stepwise-core:research-codebase Where is user registration handled?
# /clear

# Plan (core)
/stepwise-core:create-plan Add OAuth login support
# /clear

# Implement (core)
/stepwise-core:implement-plan @thoughts/shared/plans/...md
# /clear

# Validate (core)
/stepwise-core:validate-plan @thoughts/shared/plans/...md

# Commit (git)
/stepwise-git:commit
```

### Example 2: Using Web Research

```bash
# Research external best practices (web)
"What are the best practices for implementing rate limiting in REST APIs?"
# The web-search-researcher agent will be invoked automatically

# Research your codebase (core)
/stepwise-core:research-codebase Where do we handle API rate limiting?

# Continue with plan and implementation...
```

## 🏷️ Version Management

```bash
# Check versions
claude plugin list

# Update marketplace and all plugins
claude plugin marketplace update stepwise-dev

claude plugin update stepwise-core@stepwise-dev
claude plugin update stepwise-git@stepwise-dev
claude plugin update stepwise-web@stepwise-dev
claude plugin update stepwise-slides@stepwise-dev
claude plugin update stepwise-diagrams@stepwise-dev
```

### Syncing vendored plugins

Vendored plugins are imported from upstream via `git subtree`. To pull the latest upstream changes:

```bash
# stepwise-slides
git subtree pull \
  --prefix=slides \
  https://github.com/zarazhangrui/frontend-slides.git \
  main --squash

# stepwise-diagrams
git subtree pull \
  --prefix=diagrams \
  https://github.com/cathrynlavery/diagram-design.git \
  main --squash
```

Do **not** edit files under `slides/` or `diagrams/` — every future sync must apply cleanly. If the pull brings meaningful changes, patch-bump the affected plugin in `.claude-plugin/marketplace.json` and the top-level marketplace `version` per `.claude/rules/versioning.md`.

## 📝 Golden Rules

1. **Keep context under 60%** — past that, accuracy drops.
2. **`/clear` between phases** — knowledge lives in `thoughts/`, not in the context window.
3. **Read a 200-line plan before Claude writes 2,000 lines of code.**
4. **Implement one phase at a time** — with its own tests and its own commit.
5. **Delegate noisy work** (web research, large codebase scans) to **sub-agents** so the parent context stays clean.

```bash
/context  # Check current usage
/clear    # Clear between phases
```

## 🔧 Customization

**Change Username**: Set `export THOUGHTS_USER=your_name` or edit the thoughts-init script.

## 🧪 Testing

```bash
make test          # Run all automated tests
make test-verbose  # Run tests with debug output
make check         # Run shellcheck on bash scripts
make validate      # Run claude plugin validate --strict
make version-bump  # Check required version bumps against origin/main
make ci            # Run full CI validation
```

### Skill Evaluation

Each skill has an eval suite in its `<skill-name>-workspace/evals/` directory:

```
core/skills/bugmagnet-workspace/evals/
├── evals.json              # Eval definitions (prompts, assertions, grading guide)
├── files/                  # Test fixtures (source files the skill analyzes)
├── iteration-1/            # Benchmark run results
│   ├── benchmark.json      # Machine-readable: per-eval pass rates, timing, tokens
│   ├── benchmark.md        # Human-readable summary table
│   └── eval-1-name/        # Per-eval evidence
│       └── eval_metadata.json
├── iteration-2/
└── ...
```

**Running evals:**

```bash
/skill-creator:skill-creator Run evals from <skill-name>-workspace/evals/evals.json
```

This runs each eval with-skill and without-skill, grades assertions, and writes results to a new `iteration-N/` directory.

**Reading benchmark results:**

Open `iteration-N/benchmark.md` for a quick summary table, or `benchmark.json` for detailed per-assertion evidence. Key metrics:

- **pass_rate**: percentage of assertions passed (with_skill vs without_skill)
- **delta**: the skill's added value over baseline — higher is better
- **time_seconds / tokens**: cost of using the skill

Compare across iterations to track skill improvements over time.

**Viewing detailed eval reports:**

```bash
make eval-list                                # List skills with eval iterations
make eval-view SKILL=test-desiderata          # View latest iteration
make eval-view SKILL=test-desiderata ITER=1   # View specific iteration
make eval-view SKILL=test-desiderata PREV=1   # Compare latest vs iteration-1
```

The viewer opens two tabs: **Outputs** (per-eval outputs, grading, and feedback) and **Benchmark** (aggregate pass rates, delta, timing, and token usage).

## 📚 Learn More

- **Original Article**: [I mastered the Claude Code workflow](https://medium.com/@ashleyha/i-mastered-the-claude-code-workflow-145d25e502cf) by Ashley Ha
- **HumanLayer**: Original inspiration from [HumanLayer's .claude directory](https://github.com/humanlayer/humanlayer)

## 🤝 Contributing

Test improvements in your workflow, document changes, and share with the community.

## 📄 License

Apache License 2.0 - See LICENSE file for details.

## 🔖 Attribution

Derived from [HumanLayer's Claude Code workflow](https://github.com/humanlayer/humanlayer/tree/main/.claude) under Apache License 2.0.

`stepwise-slides` is vendored verbatim from [zarazhangrui/frontend-slides](https://github.com/zarazhangrui/frontend-slides) (MIT, author Zara Zhang) under the `slides/` prefix, imported via `git subtree`.

`stepwise-diagrams` is vendored verbatim from [cathrynlavery/diagram-design](https://github.com/cathrynlavery/diagram-design) (MIT, author Cathryn Lavery) under the `diagrams/` prefix, imported via `git subtree`.

Several skills are derived from [Matt Pocock's skills](https://github.com/mattpocock/skills) (grill-me, tdd), [eferro's skill-factory](https://github.com/eferro/skill-factory) (hamburger-method, small-safe-steps, story-splitting, test-desiderata, mutation-testing, and tdd/zombies reference) and [Gojko Adzic's BugMagnet](https://github.com/gojko/bugmagnet-ai-assistant). See [NOTICE](NOTICE) for detailed attribution.

**Major enhancements**:
- Multi-plugin architecture for modular installation
- Specialized agent system
- Local-only thoughts/ management with Agent Skill
- Automated testing infrastructure
- Enhanced TDD-focused success criteria

---

**Happy Coding! 🚀**

Questions? [Open an issue](https://github.com/nikeyes/stepwise-dev/issues) on GitHub.
