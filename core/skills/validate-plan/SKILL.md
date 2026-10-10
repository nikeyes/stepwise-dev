---
name: validate-plan
description: Validate that plan was correctly implemented, verify all success criteria
argument-hint: [plan-file-path]
model: inherit
disable-model-invocation: false
---

# Validate Plan

Check that the code does what an implementation plan asks.

## Input

- If a plan path is provided, use it
- Otherwise, search `thoughts/shared/plans/` or ask the user

## Validation Steps

1. **Read the plan completely**: every phase, checkbox, success criterion and manual verification item.

2. **Run the automated verification** its success criteria name, and capture the output.

3. **Compare each phase with the code, at the level of behavior.** The plan was written before the code met reality; keep the code's solution when it does the job.
   - Does the system do what the phase asks, and is each behavior tested? Does the public contract match: endpoints, request and response shapes, error codes, signatures other code relies on?
   - Do checked items (`[x]`) match the code?
   - A different internal approach, or tests the plan didn't list, is not a finding. Under "Plan out of date", note only the deviations that would mislead someone reading the plan, such as a different approach, data structure or interface detail. Leave out cosmetic changes and extra tests.

4. **Assess test quality**: read the tests, don't just run them. Are assertions missing or trivial? Do they mock the thing they're supposed to test?

5. **Look for regressions** in the pre-existing behavior of the modified files.

6. **Flag vague or unmeasurable criteria** as unverifiable instead of inventing interpretations.

## Report Format

```markdown
## Validation Report: [Plan Name]

### Implementation Status
Phase N: [Name] — [Fully implemented | Gaps found | NOT implemented]

### Automated Verification
[Commands run, pass/fail]

### Findings
[Missing or broken behavior, contract changes, weak tests, regressions, unverifiable criteria]

### Plan out of date
[What the plan said, what the code does, and why]
```
