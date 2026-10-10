# Java Mutation Operators

Java-specific operators, on top of [operators.md](operators.md). Tool: [pitest.md](pitest.md). The names in parentheses are PIT's mutator names, so mental findings line up with tool reports.

| Original → Mutant | A killing test needs |
|---|---|
| `<` ↔ `<=` (CONDITIONALS_BOUNDARY) | The boundary value |
| `==` → `!=` (NEGATE_CONDITIONALS) | Inputs on both sides |
| `return x` → `return 0` / `false` / `""` / `null` / `Optional.empty()` / `Collections.emptyList()` (*_RETURNS) | An assertion on the returned value |
| `void` call → removed (VOID_METHOD_CALLS) | An assertion on the call's observable effect |
| `i++` → `i--` (INCREMENTS) | An assertion on the counter or on what it controls |
| `-x` → `x` (INVERT_NEGS) | A non-zero operand |
| `a.equals(b)` → `true` / `false` | Equal and unequal inputs |
| `Objects.requireNonNull(x)` → removed | A `null` argument, asserting the exception |
| `stream.filter(p)` → removed | Mixed items; assert exact contents |
| `Optional.orElse(d)` → returns `d` always | A present value |

## Examples

**Boundary:**

```java
boolean isAdult(int age) { return age >= 18; }

@Test void eighteenIsAdult() { assertTrue(isAdult(18)); }   // kills `>`
@Test void seventeenIsNot()  { assertFalse(isAdult(17)); }  // kills `true` return
```

**Empty returns.** PIT replaces collection returns with empty ones; asserting `isNotNull()` does not kill that:

```java
@Test void listsActiveUsers() {
    assertEquals(List.of(alice), directory.activeUsers());
}
```

**Removed `void` calls.** Assert the effect through the public interface, not by verifying a mock:

```java
@Test void placingAnOrderStoresIt() {
    orders.place(order);
    assertEquals(Optional.of(order), orders.find(order.id()));
}
```
