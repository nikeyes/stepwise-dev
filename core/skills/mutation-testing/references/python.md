# Python Mutation Operators

Python-specific operators, on top of [operators.md](operators.md). Tool: [mutmut.md](mutmut.md).

| Original → Mutant | A killing test needs |
|---|---|
| `a // b` → `a / b` | A division with a remainder: `7 // 2 == 3` but `7 / 2 == 3.5` |
| `a ** b` → `a * b` | Operands where they differ (`3 ** 3 = 27`, `3 * 3 = 9`); avoid `2, 2` |
| `a and b` ↔ `a or b` | One truthy operand and one falsy |
| `x is None` → `x is not None` | Both a `None` and a non-`None` input |
| `a in b` ↔ `a not in b` | Assert one case: the mutant flips every result |
| `break` ↔ `continue` | An input where items exist after the stop condition |
| `any(...)` ↔ `all(...)` | A mix of matching and non-matching items |
| `d.get(k, default)` → `d[k]` | A missing key |
| `x[:3]` → `x[3:]` / `x[:2]` | A sequence longer than the slice; assert the exact contents |
| `@decorator` → removed | An assertion on the decorator's observable effect (caching, retries, validation) |

## Examples

**Membership.** The mutant `not in` inverts every result, so any assertion on the outcome kills it:

```python
def has_permission(user, permission):
    return permission in user.permissions

def test_reader_can_read():
    assert has_permission(User(permissions=["read"]), "read") is True   # kills `not in`
```

A survivor here means no test calls `has_permission` and asserts its result at all.

**`is None` vs `== None`.** These only differ for objects with a custom `__eq__`. Plain values such as `""` or `0` do not distinguish them:

```python
def label(value):
    return "default" if value is None else value

class AlwaysEqual:
    def __eq__(self, other):
        return True

def test_keeps_values_that_compare_equal_to_everything():
    obj = AlwaysEqual()
    assert label(obj) is obj   # `obj == None` is True, `obj is None` is False
```

If the codebase has no such types, treat `is None` → `== None` as equivalent.

**Floor division.** Assert the value, not just the type:

```python
def pages(total, per_page):
    return total // per_page

def test_pages_round_down():
    assert pages(10, 3) == 3   # `/` gives 3.33…
```

**Filtering comprehensions.** Mix matching and non-matching items and assert the exact result:

```python
def even_squares(numbers):
    return [n ** 2 for n in numbers if n % 2 == 0]

def test_even_squares():
    assert even_squares([1, 2, 3, 4]) == [4, 16]
    # `n * 2` → [4, 8]; `!= 0` → [1, 9]; empty list → []
```

**Missing keys:**

```python
def timeout(config):
    return config.get("timeout", 30)

def test_timeout_defaults_when_missing():
    assert timeout({}) == 30   # `config["timeout"]` raises KeyError
```
