# JavaScript / TypeScript Mutation Operators

JS/TS-specific operators, on top of [operators.md](operators.md). Tool: [stryker.md](stryker.md).

| Original → Mutant | A killing test needs |
|---|---|
| `a === b` ↔ `a !== b` | Inputs on both sides |
| `a ?? b` → `a && b` / `a \|\| b` | A falsy but non-nullish `a` (`0`, `""`, `false`) |
| `foo?.bar` → `foo.bar` | A `null` or `undefined` `foo` |
| `some()` ↔ `every()` | A mix of matching and non-matching items |
| `filter()` / `sort()` / `reverse()` → removed | Input where removing the call changes the result; assert the exact array |
| `startsWith()` ↔ `endsWith()` | A string that matches at one end only |
| `toUpperCase()` ↔ `toLowerCase()` | Input whose case changes the result |
| `trim()` → `trimStart()` / `trimEnd()` | Whitespace on the side the mutant keeps |
| `Math.min` ↔ `Math.max` | Distinct values |
| `[a, b]` → `[]` | An assertion on contents |
| `"text"` → `""` | An assertion on the exact string |

TypeScript-only syntax (`!`, `as`, type annotations) is erased at runtime. Mutating it is not meaningful; Stryker does not do it either.

## Examples

**Nullish coalescing.** `??` and `||` only differ for falsy values that are not `null` or `undefined`:

```typescript
const port = (configured?: number) => configured ?? 3000;

it('keeps an explicit port 0', () => {
  expect(port(0)).toBe(0);   // `0 || 3000` → 3000
});
```

**Optional chaining:**

```typescript
const userName = (user?: { name: string }) => user?.name ?? 'Anonymous';

it('names a missing user Anonymous', () => {
  expect(userName(undefined)).toBe('Anonymous');   // `user.name` throws
});
```

**`some` vs `every`:**

```typescript
const hasActiveUser = (users: User[]) => users.some(u => u.isActive);

it('is true when only one user is active', () => {
  expect(hasActiveUser([{ isActive: true }, { isActive: false }])).toBe(true);
});
```

**Exact array contents:**

```typescript
it('keeps only positive numbers', () => {
  expect(positives([1, -2, 3])).toEqual([1, 3]);   // `Array.isArray(result)` would not kill a removed filter

});
```
