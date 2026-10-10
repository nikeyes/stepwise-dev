---
name: validate-plan
description: Validate that plan was correctly implemented, verify all success criteria
argument-hint: [plan-file-path]
model: inherit
disable-model-invocation: false
---

# Validate Plan

Validate that an implementation plan was correctly executed by comparing the plan's claims against the actual codebase state.

## Input

- If a plan path is provided, use it
- Otherwise, search `thoughts/shared/plans/` or ask the user

## Validation Steps

1. **Read the plan completely** — identify every phase, checkbox, success criterion, and manual verification item.

2. **Read every file the plan references** — source code, test files, config files. Compare what the plan says should exist against what actually exists.

3. **Run automated verification** — execute `make test` (or whatever the plan specifies). Capture full output.

4. **Compare plan claims to reality for each phase**, at the level of behavior:
   - Does the system do what the phase asks? Every behavior and success criterion should be implemented and tested.
   - Does the public contract match: endpoints, request and response shapes, error codes, and signatures other code relies on?
   - Do checked items (`[x]`) match what's actually in the code? Are there items marked complete that are missing or incomplete?
   - Internal deviations are expected: plans are written before the code meets reality. A different data structure, private name or approach that keeps or improves the planned behavior is **not a finding**. List it under "Plan out of date" so the plan can catch up.
   - Tests the plan didn't list are not a deviation. Judge them only as in step 5.

5. **Assess test quality** — don't just check that tests pass. Read the test code:
   - Do tests actually assert the expected behavior, or are assertions missing/trivial?
   - Do tests mock the method they're supposed to test (tautological tests)?
   - Do the plan's success criteria have corresponding test assertions?

6. **Look for regressions** — did the implementation break pre-existing methods or behavior? Check methods that aren't part of the plan but exist in modified files.

7. **Evaluate plan quality** — if the plan has vague or unmeasurable criteria ("handle edge cases well", "good performance"), flag them as unverifiable rather than inventing interpretations.

## Report Format

```markdown
## Validation Report: [Plan Name]

### Implementation Status
Phase N: [Name] — [Fully implemented | Deviations found | NOT implemented]

### Automated Verification
[Full test output, pass/fail count]

### Findings
[Missing or broken behavior, contract changes, weak tests, regressions, unverifiable criteria]

### Plan out of date
[Internal deviations that keep the planned behavior: what the plan said, what the code does, and why]

### Recommendations
[What needs fixing before this can be considered complete]
```

## Key Principles

- A passing test suite does not mean the plan is satisfied — tests can lie.
- Checked checkboxes do not mean work is done — verify against actual code.
- Validate what the plan asks the system to do, not how the plan sketched it. The code is closer to reality than the plan; keep its solution when it does the job.
- Vague criteria cannot be validated — flag them, don't rubber-stamp them.
