# mutmut (Python)

Checked against mutmut 3.8. Flags change between versions, so check `mutmut --help` and the project's existing config before running anything. mutmut refuses to start, even for `--help`, if it can't find what to mutate.

## Detecting it

A `[tool.mutmut]` section in `pyproject.toml` (or `[mutmut]` in `setup.cfg`). It sets `source_paths` (older 3.x configs use `paths_to_mutate`). Do not add one if it is missing.

Run mutmut from the project's own environment (`uv run mutmut`, `.venv/bin/mutmut`), where the dev dependencies are installed. `uv run --with mutmut` builds a separate environment without them, so test collection fails and every mutant ends up `not checked`.

## Running on the scope

mutmut copies the project into `mutants/` and keeps its results there. Mutant names follow the module path, so a glob limits the run:

```bash
mutmut run "price_calculator.x_calculate_discount*"            # function: <module>.x_<function>__mutmut_<n>
mutmut run "todo_api.storage.xǁInMemoryStorageǁget_all*"       # method:   <module>.xǁ<Class>ǁ<method>__mutmut_<n>
mutmut run "price_calculator.*"                                # whole module
```

mutmut 3 has no line-range option. In diff modes, run the functions that contain the changed hunks and ignore survivors outside those hunks.

## What mutmut does not cover

- **Decorated functions are not mutated**, for example FastAPI or Flask endpoints (`@app.get`). Analyze them in mental mode even when the tool is available.
- **Tests that import through the source root** (`from src.pkg import ...`) fail to collect inside `mutants/`. If the baseline under mutmut errors this way, report it and fall back to mental mode; don't rewrite the imports.

## Reading results

```bash
mutmut results                      # mutants not killed: survived, no tests, not checked, ...
mutmut show <mutant-name>           # the diff of one mutant
mutmut tests-for-mutant <mutant-name>   # tests that cover it
```

Only `survived` and `no tests` are survivors. `not checked` means the mutant was outside the glob you ran. `timeout` counts as detected. `suspicious` means the run was inconsistent; re-check by applying the mutant. `mutmut browse` is an interactive TUI, so don't use it from an agent.

## Running the plain test suite afterwards

The `mutants/` copy contains the test files too. Run pytest on the test directory (`pytest tests/`), not from the project root, or collection fails with `import file mismatch`. Never commit `mutants/`.

## Applying a mutant

`mutmut apply <mutant-name>` writes the mutant into the real source tree. Follow the Applying Mutants rules in SKILL.md and restore the file afterwards. Rerunning `mutmut run` with the same glob after tdd adds tests is usually simpler.

## Excluding code

`# pragma: no mutate` on a line excludes it. Only use it if the project already relies on it.
