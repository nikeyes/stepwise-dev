# Universal Mutation Operators

These apply to most languages. Language references add operators specific to each one.

## Operators

| Category | Original → Mutant | A killing test needs |
|---|---|---|
| Arithmetic | `a + b` → `a - b`, `a * b` → `a / b`, `a % b` → `a * b` | Operands where the results differ (not 0 for `+`/`-`, not 1 for `*`/`/`) |
| Relational boundary | `<` ↔ `<=`, `>` ↔ `>=` | An input exactly on the boundary |
| Relational negation | `<` → `>=`, `==` → `!=` | Inputs on both sides of the condition |
| Logical | `a && b` ↔ `a \|\| b` | One operand true and the other false |
| Negation | `!a` → `a` | Both outcomes of `a` |
| Boolean literal | `true` ↔ `false` | An assertion on the outcome the literal drives |
| Return value | `return x` → `return <default>` (0, empty, null) | An assertion on the returned value, not just its type |
| Statement removal | a call or assignment → removed | An assertion on that statement's observable effect |
| Block removal | function body → empty | An assertion on the result or on observable state |
| String literal | `"text"` → `""`, `""` → `"X"` | An assertion on the exact string |
| Collection literal | `[1, 2]` → `[]` | An assertion on contents, not just on type or non-emptiness |
| Unary | `-a` → `a`, `a++` → `a--` | A non-zero operand; an assertion on the updated value |

## High-yield operators

The mutants that most often survive real suites:

1. `>=` vs `>` — the boundary value is never tested.
2. `&&` vs `||` — only tested with both operands true or both false.
3. `+` vs `-` — only tested with 0.
4. `*` vs `/` — only tested with 1.
5. Removed call — the test checks that nothing throws instead of checking the effect.
6. Return default — the test checks the type or truthiness, not the value.

## Values that kill mutants

| Avoid | Use instead |
|---|---|
| 0 for `+`/`-` | A non-zero operand |
| 1 for `*`/`/` | Operands greater than 1 |
| Values far from a threshold | The threshold itself, and one step either side |
| All-true or all-false for logical operators | Mixed operands |
| Empty or single-item collections | Several items, some matching and some not |
| Type or truthiness assertions | Exact expected values |

## Red flags in tests

- Assertions only check that no exception was raised.
- Only one side of a condition is exercised.
- Inputs are identity values (0, 1, empty string, empty list).
- Return values are never asserted.
- Collection results are checked by length only.

## Equivalent mutants

An equivalent mutant has no observable difference from the original, so no test can kill it. Drop it instead of reporting it.

- **Identity operations:** `x += 0` → `x -= 0`; `x * 1` → `x / 1`.
- **Boundaries where both branches agree:** in `return a if a >= b else b`, switching to `a > b` only matters when `a == b`, and then both branches return the same value.
- **Loop bounds made redundant by a later guard:** the extra iteration hits a `break` or `return` that produces the same result.

Separate equivalents from **superfluous code**. Equivalence comes from algebra. Superfluous code is a line or branch with no effect on any behavior, such as an `if` whose two branches do the same thing or a check that nothing upstream can trigger. Superfluous code is worth simplifying, so it goes to tdd as a refactor candidate.
