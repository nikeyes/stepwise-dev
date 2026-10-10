# StrykerJS (JavaScript / TypeScript)

Check the installed version (`npx stryker --version`) and the project's config before running anything.

## Detecting it

`@stryker-mutator/core` in `package.json` plus a `stryker.config.*` or `stryker.conf.*` file. Do not run `npm init stryker` or add a config if they are missing.

## Running on the scope

`--mutate` accepts globs or line ranges. The two can't be combined in a single pattern:

```bash
npx stryker run --mutate "src/pricing.ts"                          # whole file
npx stryker run --mutate "src/pricing.ts:40-58,src/cart.ts:10-22"  # changed hunks
```

`--incremental` reuses previous results from `reports/stryker-incremental.json`. Use it when the project already does.

## Reading results

Use the `clear-text` reporter output, or `reports/mutation/mutation.json` when the `json` reporter is enabled. Statuses:

| Status | Meaning |
|---|---|
| Killed | A test failed |
| Survived | Tests passed with the mutant |
| NoCoverage | No test covers the mutant |
| Timeout | Tests hung; counts as detected |
| CompileError / RuntimeError | Invalid mutant; ignore |
| Ignored | Excluded by config or a disable comment |

Mutation score = detected / valid, where detected = Killed + Timeout and valid = detected + Survived + NoCoverage.

## Excluding code

`// Stryker disable next-line <mutator>: <reason>`. Only use it if the project already relies on it.
