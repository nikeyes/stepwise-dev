# Workflow `quality-cycle` Implementation Plan (DRAFT)

> **Status: Paused (2026-11-09).**
> **Reason:** an experiment in ka-minions (23 runs with Opus 5.5 in the container) showed that a strict SKILL.md, with one step per skill and "doing it by hand does not count", makes the session call all 6 skills in 13 of 13 tasks with code. The MVP does not need a workflow. Report: branch `research/prompt-compliance` of `jorge-castro/ka-minions`, `thoughts/shared/research/2026-11-09-prompt-compliance-experiment.md`.
> **To resume:** answer the open question below, then write the phases (outline at the end). The decisions recorded here were made with Jorge and should not be reopened unless the facts change.

## Overview

A Claude Code workflow in `stepwise-core`, `core/workflows/quality-cycle.js`, run as `/stepwise-core:quality-cycle`. It runs the quality cycle of one task in an order that the script guarantees (`agent()`/`phase()`), not the prompt:

tdd → bugmagnet → mutation-testing `--changed` → test-desiderata → `/simplify` → tests → commit → `/security-review` → fixes → tests → commit

It is generic: nothing specific to ka-minions.

**Motivation:** in ka-minions (LLM-90), the `ka-implement` session only invoked `simplify` and `security-review`. It did the work of tdd, bugmagnet, mutation-testing and test-desiderata by hand.

## Current State Analysis

- `implement-plan` already describes this cycle per phase, through the prompt and without commits (`core/skills/implement-plan/SKILL.md:47-95`). At the end it runs `/code-review medium` and `/security-review` once (`:113-118`).
- `mutation-testing` already hands its gaps to `tdd` through the Skill tool (`core/skills/mutation-testing/SKILL.md:44`). `--changed` computes `git diff HEAD -- <files>` (`:18`).
- `stepwise-git:commit` lives in another plugin (`git/skills/commit/SKILL.md`).
- Test 8 of `test/plugin-structure-test.sh:205-221` accepts a `stepwise-<plugin>:<name>` reference only if it names a skill or an agent. A reference to `stepwise-core:quality-cycle` in any README would fail `make test`.
- `claude plugin validate --strict` does not check `workflows/`. A broken `.js` gives the same result as a valid one (checked 2026-11-07 with 2.1.319).
- `node --check` rejects the top-level `return` that workflow scripts use. Tests need a node harness that loads the script body as an `AsyncFunction` with stub `agent`/`phase`/`log`/`args`/`parallel`.
- CI runs on `ubuntu-latest` (node available) with Claude Code pinned to 2.1.295 (`.github/workflows/ci.yml`).
- A previous plan covers a similar idea at the plan level: `thoughts/shared/plans/2026-10-10-implement-and-validate-workflow.md`.

### Verified facts

From the spike (`ka-minions` worktree `spike-claude-workflows`, `thoughts/shared/research/2026-11-07-claude-code-workflows-spike.md`, Claude Code 2.1.318, `claude -p`, Bedrock):

- A plugin ships workflows in `workflows/` (or the `workflows` manifest field). They run as `/<plugin>:<meta.name>`.
- Workflow subagents follow managed settings and the CLI `--disallowedTools` rules, and they see every session skill.
- `permission_denials` in the final `--output-format json` object is **empty** when the denials happen in subagents.
- Transcripts live in `<session>/subagents/workflows/<runId>/`, plus `journal.jsonl` and `<session>/workflows/<runId>.json`.

**Test run on 2026-11-09** (EC2 container, `claude -p`, Bedrock, Claude Code 2.1.318, managed settings and the `claude.py` flags; a 2-agent workflow on a toy repo; 50 s, 0.34 USD; checked in the transcripts, not only in the agents' reports):

- Inside a workflow agent, the Skill tool works. Agent 1 invoked `simplify` and agent 2 invoked `security-review`.
- The `Agent` tool is **not** available in a workflow agent: no transcript has an `Agent` `tool_use`. `/simplify` ran its 4 lenses in one context and still applied correct cleanups: it removed a duplicate loop by reusing a function, removed a dead assignment and an impossible `== None`, and used `join` instead of concatenation. The tests passed and the agent made its commit.
- `/security-review` reviewed the commits against `origin/HEAD` and edited nothing.
- The agents work in the session's directory: the commit landed in the repo where `claude -p` was launched.
- `permission_denials` in the final JSON: 0, because nothing was denied this time.
- For comparison, outside a workflow (LLM-90, main session), `/simplify` launched 4 subagents (Reuse, Simplification, Efficiency, Altitude) and `/security-review` launched 1.

## Decisions Made

### 1. Commits use `stepwise-git:commit`

The commit agents invoke `/stepwise-git:commit`, so the commit rules have a single source. If `stepwise-git` is not installed, the workflow stops before it changes anything and says so.

### 2. Input: `args = {task, testCommand?, base?}`

The script cannot read the disk, so `args` is its only input.

- `task`: text, or a path to a file with acceptance criteria. If it is a path, the TDD agent reads the file. A bare string is accepted as `task`, so `/stepwise-core:quality-cycle add X` works.
- `testCommand` (optional): if it is missing, a **preparation agent** discovers it (Makefile, package.json, pyproject…). It runs the suite and checks that the suite **starts green**. If it finds no command, or the suite is red, the workflow stops without touching anything. Every later step uses the same command, so the test gates are reliable, and mutation testing never runs on a red suite.
- `base` (optional, a commit or ref): by default, the HEAD at the start, which the preparation agent records. "What changed" means `base..HEAD` plus the working tree.
  - Why: ka-minions takes up to 3 rounds on the same branch (LLM-89 had 3 commits). In round 2, what changed starts at the branch base, not at that round's HEAD. In implement-plan, phase 2 starts where phase 1 ended.
  - The spike saw `/security-review` get an empty diff when the change was only staged. The range must be a range of commits.
  - Consequence: `mutation-testing` gains an optional `--base <ref>` flag (`git diff <ref> -- <files>`, default `HEAD`). It is backward compatible.
  - `/security-review` is bundled and compares against `origin/HEAD`. The agent passes `<base>..HEAD` as a hint. At worst it reviews the whole branch, which contains that range.

**Outside the workflow, on purpose:** the caller (for example ka-minions, in the `task` text or in its own script) handles the working directory (the session's, verified on 2026-11-09), the findings file of a previous round, the venv path, the commit suffix, and the output files.

**Fixed in the workflow, not parameters:** the order of the steps and the git rules. No push, no branch switch, no history rewrite.

### 3. Output: the script's return value

The script writes no files. It returns a value, which arrives in the final JSON of `claude -p`, and the caller writes it wherever it wants.

- `status`: `done` | `blocked` | `question`, with the reason. A blocking question waits for nobody: the workflow returns it and stops.
- `summary`:
  - what changed;
  - which test covers each acceptance criterion;
  - how mutation testing ran (tool such as `make mutate`, or mental mode);
  - what `/simplify` and `/security-review` changed;
  - the skipped `- BUG` tests and the surviving mutants.
- `denials`: the denied permissions of each agent. Each agent sees the "Permission to use … has been denied" messages in its own context and returns them in its schema (`denials: [{tool, input}]`). The script merges them. This is the agent's own report. Checking the transcripts is up to the caller (option B of the spike).
- `commits`: the commits the workflow made, with hash and subject.

### 4. Red test gates: up to 2 fix attempts, then `blocked`

This applies to the gate after `/simplify` and to the gate after the security fixes.

- If a gate is red, one agent invokes `/stepwise-core:tdd` with the failing output, and the script runs the gate again. It tries at most 2 times.
- If the gate is still red, the workflow returns `status: blocked`, makes no commit, and leaves the working tree as it is (no `checkout` or `reset`).
- Skipped `- BUG` tests from bugmagnet or mutation-testing do not count as red. They are listed in `summary`.

### 5. `/security-review` findings: a reviewer and a fixer, separate

1. The review agent invokes `/security-review` on `<base>..HEAD`. It returns the findings in a schema (`file:line`, severity, description) and edits nothing.
2. The fix agent decides each finding. It either fixes it through `/stepwise-core:tdd` (a test that shows the finding, then the fix) or dismisses it with a short reason. The schema forces a decision on every finding.
3. Then come the test gate (decision 4) and the second commit, only if something changed.

Rules:

- A dismissed high-severity finding does not block, but it is marked as `BLOCKING` in `summary` with its reason, so a person sees it.
- If `origin/HEAD` does not exist, the workflow does not change the git config. It returns `status: blocked` with "security review not run: `git remote set-head origin -a`". The first commit stays.

### 6. `/simplify` and `/security-review`: the bundled skills, even without subagents (option A)

The workflow uses the bundled skills as they are. The 2026-11-09 run showed that they work in a workflow agent without the `Agent` tool, with correct results.

- Phase 1 keeps only a short regression check, not a full trace test.
- **Possible future improvement (option B):** the 4 lenses as their own agents in `parallel()`, plus an agent that applies the changes. Do this only if the quality of the cleanups drops in real cases.

### 7. Versioning (per `.claude/rules/versioning.md`)

- `core/.claude-plugin/plugin.json`: minor bump (new workflow, plus the `--base` flag): `2.0.4` → `2.1.0`, or whatever is current when the plan resumes.
- `.claude-plugin/marketplace.json`: mirror the new version in the `stepwise-core` entry and patch-bump the top-level `version`.

## Open Question (where the interview stopped)

**Should `implement-plan` use the workflow in each phase?**

- **A (recommended): yes, one `quality-cycle` run per phase.**
  - Steps 1 to 5 of the Phase Cycle (`core/skills/implement-plan/SKILL.md:47-95`) become one step: launch `/stepwise-core:quality-cycle` with `task` (the phase section with its success criteria) and `testCommand` (from the plan's automated criteria). `base` stays the default.
  - The skill waits for the result and checks off the plan. On `blocked` or `question`, it stops and shows the result to the person.
  - The final `/code-review medium` over the whole plan stays. The final `/security-review` goes away, because each phase already runs one.
  - Consequence: `implement-plan` makes commits, 1 or 2 per phase, and `ship-pr` only opens the PR. The "Next steps" text changes to match.
  - If the `Workflow` tool is unavailable (old Claude Code, or disabled by policy), the skill stops and says so with the minimum version. It keeps no prompt-driven fallback, because that would be the same logic twice and the LLM-90 failure mode.
- **B: leave `implement-plan` alone.** Ship the workflow on its own and integrate it in another plan.
- **C: a full `implement-plan` workflow** that runs `workflow('quality-cycle')` per phase. It would need extra agents to read the plan and check boxes. Not worth it now.

Jorge did not answer: the plan was paused at this question. In light of the prompt-compliance experiment, B, or no workflow at all, may be the right answer.

## Draft Phase Outline (not detailed yet)

1. **Regression check.** A minimal workflow run confirms that the Skill tool, `/simplify` and `/security-review` still work in a workflow agent on the current Claude Code.
2. **Test harness.** A node harness that loads a workflow script with stub globals. Add a `make` target, with node required in CI through `SKIP_OR_FAIL`. Extend test 8 so that `stepwise-<plugin>:<name>` also resolves to a `workflows/*.js` whose `meta.name` matches.
3. **`mutation-testing --base <ref>`**, test-first where testable.
4. **`core/workflows/quality-cycle.js`**, driven by harness tests:
   - the order of the steps;
   - a stop on `question`;
   - the preparation failure;
   - the gate retries, then `blocked`;
   - a stop when `stepwise-git:commit` is missing;
   - no second commit when nothing changed;
   - the missing `origin/HEAD`;
   - the result shape `{status, summary, denials, commits}`.
5. **Documentation.** `core/README.md` and the root `README.md`, with the minimum Claude Code version for plugin workflows (verified on 2.1.318).
6. **Version bumps.**
7. **`implement-plan` integration**, depending on the answer to the open question.

## References

- Spike: `/Users/jorge.castro/.herdr/worktrees/ka-minions/spike-claude-workflows/thoughts/shared/research/2026-11-07-claude-code-workflows-spike.md`
- Order of `/simplify` and `/security-review`: `ka-minions` `thoughts/shared/research/2026-11-07-anthropic-code-reviews.md`
- Pause reason: `ka-minions` branch `research/prompt-compliance`, `thoughts/shared/research/2026-11-09-prompt-compliance-experiment.md`
- Related earlier plan: `thoughts/shared/plans/2026-10-10-implement-and-validate-workflow.md`
- Workflow docs: https://code.claude.com/docs/en/workflows
