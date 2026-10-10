---
name: mutation-testing
description: Finds weak or missing tests by checking whether small code changes (mutants) would be caught by the test suite, then hands the gaps to TDD. Use when verifying test effectiveness, asking "would my tests catch this bug?", hunting surviving mutants, or checking changed code after TDD. Triggers on "mutation testing", "mutants", "surviving mutants", "Stryker", "mutmut", "PIT" or "pitest".
---

# Mutation Testing

Answers one question: **"If I introduced a bug here, would a test fail?"** Coverage tells you a line was executed; mutation testing tells you a change to that line would be detected.

**Attribution:** Adapted from [eferro's skill-factory](https://github.com/eferro/skill-factory) (Apache-2.0), itself based on [Paul Hammond's mutation-testing skill](https://github.com/citypaul/.dotfiles/blob/main/claude/.claude/skills/mutation-testing/SKILL.md).

## Usage

```
/mutation-testing <file>                 # whole module
/mutation-testing                        # branch diff: git diff main...HEAD plus uncommitted changes
/mutation-testing --changed <files...>   # only changed hunks: git diff HEAD -- <files>; untracked files whole
/mutation-testing --tool [...]           # force the project's mutation tool (see Modes)
```

Only production code is mutated. Skip test files, generated code and pure configuration.

## Modes

- **Mental (default):** you generate mutants by reading the code and reason about whether the tests would fail. Fast, works in any language, leaves the working tree untouched except for the empirical checks below.
- **Tool:** run the project's mutation tool restricted to the scope. Use it when `--tool` is passed or the project already configures one (`stryker.config.*`/`stryker.conf.*`, `[tool.mutmut]` in `pyproject.toml`/`setup.cfg`, the pitest plugin in `pom.xml`/`build.gradle*`). See the tool reference for the scoped command.

Never install a mutation tool or add its configuration. If `--tool` is passed and no tool is set up, say so and continue in mental mode.

## Workflow

1. **Resolve scope.** List the production files and, for diff modes, the changed line ranges.
2. **Check the baseline.** Run the tests that cover the scope. If they fail, stop and report: mutation results are meaningless on a red suite.
3. **Generate mutants.** For each function in scope, apply the operators in [operators.md](references/operators.md) plus the language reference: [python.md](references/python.md), [javascript.md](references/javascript.md) (JS/TS), [java.md](references/java.md), [kotlin.md](references/kotlin.md). Favor the high-yield operators listed there; skip mutants that would not compile.
   In tool mode, run the tool instead: [mutmut.md](references/mutmut.md), [stryker.md](references/stryker.md), [pitest.md](references/pitest.md).
4. **Evaluate each mutant.** Find the tests that exercise the line and trace a concrete input: would an assertion produce a different result? Count a mutant as killed only when you can name the test and the input that kills it. When unsure, check empirically (see Applying Mutants).
5. **Classify each survivor:**

   | Class | Meaning | Action |
   |---|---|---|
   | Missing test | No test exercises the input that distinguishes the mutant | Behavior for tdd |
   | Weak test | A test runs the line but its assertion or inputs cannot tell the difference (identity values, `toBeTruthy`, "does not throw") | Behavior for tdd |
   | Superfluous code | The mutated code does not affect observable behavior: duplicate branches, unreachable defensive checks, redundant calls | Refactor candidate for tdd |
   | Equivalent | The mutant is semantically identical to the original (`x + 0` vs `x - 0`) | Drop it |

   A survivor never proves the business logic is wrong — only that no test distinguishes the two versions.

   If the plan you're implementing explicitly asks for code that looks superfluous (a signature, a default, a defensive check), don't hand it over as a refactor candidate. Report it as still alive and give that as the reason.

6. **Hand off to tdd.** Invoke `/stepwise-core:tdd` with the Skill tool, using the handoff format below. Describe behaviors, not mutants: tdd writes tests through the public interface and does not need to know how the gap was found.
7. **Verify each kill.** For every test tdd added, apply its mutant, run that test, confirm it fails, and revert. If the mutant still survives, send tdd one sharper behavior (a more distinguishing input); after that retry, report it as still alive.
   - Tests tdd left skipped with `- BUG` cannot kill anything: list them under Bugs found instead of verifying them.
   - If tdd applied refactor candidates, rerun steps 3–5 on the refactored lines. Hand any new survivors to tdd once more.
8. **Report** using the format below.

## Applying Mutants

Empirical checks edit production code temporarily. Keep them safe:

- Record `git diff -- <file>` before the edit; after reverting, the diff must be identical.
- Revert by undoing your own edit (the inverse replacement). Never use `git checkout`, `git restore` or `git stash` on files in scope: they discard the uncommitted work you are analyzing.
- If the diff after reverting is not identical, stop and report it. Do not apply more mutants or hand off to tdd.
- Apply one mutant at a time and run only the tests that cover it.
- Never leave a mutant in place, never commit, never stage.

## Handoff Format (to tdd)

```
These behaviors already exist in the code, but no test pins them down.
Expect each test to pass on its first run; do not change production code to make it fail.

Behaviors:
1. <public entry point>: given <input>, <expected result>   (<file>:<line>)
2. ...

Refactor candidates (keep tests green before and after):
- <file>:<line> — <why the code has no observable effect>
```

Pick inputs that distinguish the original from the mutant: values on the boundary, non-identity operands, mixed booleans, `null`/`None` where the code guards against it.

## Report Format

```
## Mutation Testing Summary
Mode: mental | tool (<name>)   Scope: <files / diff>   Score: <tool mode only>

### Still alive
| Location | Mutant | Why it survived |
|---|---|---|
| src/pricing.py:42 | `>=` → `>` | No public entry point reaches qty == 10 |

### Bugs found
- <file>:<line> — <expected vs actual>, documented as skipped test `<name>` | fixed (covered by plan)
```

If nothing is left: `No surviving mutants.` Do not list killed or equivalent mutants.
