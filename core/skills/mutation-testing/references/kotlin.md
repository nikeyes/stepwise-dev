# Kotlin Mutation Operators

Kotlin-specific operators, on top of [operators.md](operators.md) and the JVM ones in [java.md](java.md). Tool: [pitest.md](pitest.md).

**Prefer mental mode for Kotlin.** PIT mutates bytecode, and the Kotlin compiler generates a lot of code nobody wrote: null-check intrinsics, `data class` `equals`/`hashCode`/`copy`/`componentN`, default-argument bridges, coroutine state machines. Plain PIT reports many junk survivors there. The plugin that filters them (Arcmutate's Kotlin plugin) is commercial. Without it, ignore survivors that point to generated members.

| Original → Mutant | A killing test needs |
|---|---|
| `a ?: b` → `a` / `b` | Both a `null` and a non-`null` `a` |
| `x?.foo()` → `x!!.foo()` | A `null` receiver |
| `when` branch → removed or swapped | One input per branch; assert each result |
| `if` expression branches swapped | Inputs for both branches |
| `require(cond)` / `check(cond)` → removed | Input violating the condition; assert the exception |
| `in a..b` → `in a until b` | The upper bound itself |
| `filter { }` / `map { }` → removed | Mixed items; assert exact contents |
| `takeIf { }` → returns receiver always | Input where the predicate is false |
| `return x` → empty or default value | An assertion on the returned value |

## Examples

**Elvis operator:**

```kotlin
fun displayName(user: User?) = user?.name ?: "Anonymous"

@Test fun `missing user is Anonymous`() = assertEquals("Anonymous", displayName(null))
@Test fun `named user keeps the name`() = assertEquals("Ana", displayName(User("Ana")))
```

**Inclusive ranges:**

```kotlin
fun isWorkingHour(hour: Int) = hour in 9..17

@Test fun `17 is a working hour`() = assertTrue(isWorkingHour(17))   // kills `9 until 17`
```

**`when` branches.** Each branch needs its own input and an exact assertion:

```kotlin
fun shippingCost(zone: Zone) = when (zone) {
    Zone.LOCAL -> 0
    Zone.NATIONAL -> 5
    Zone.INTERNATIONAL -> 20
}
```
