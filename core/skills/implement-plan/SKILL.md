---
name: implement-plan
description: Implement technical plans from thoughts/shared/plans with verification
argument-hint: [plan-file-path]
model: inherit
disable-model-invocation: false
---

<!-- SPDX-License-Identifier: Apache-2.0
     SPDX-FileCopyrightText: 2024 humanlayer Authors (original)
     SPDX-FileCopyrightText: 2025 Jorge Castro (modifications) -->

# Implement Plan

You are tasked with implementing an approved technical plan from `thoughts/shared/plans/`. These plans contain phases with specific changes and success criteria.

## Getting Started

When given a plan path:
- Read the plan completely and check for any existing checkmarks (- [x])
- Read the original ticket if referenced
- Create a todo list to track your progress (one item per phase)
- Then follow the Phase Cycle below for each phase

**Do NOT read source or test files mentioned in the plan.** The delegated skills will read them. Your role is orchestrator: you understand the plan's structure and delegate execution. If you read the implementation files, you will be tempted to implement directly — that defeats the purpose of this skill.

If no plan path provided, ask for one.

## Your Role: Orchestrator

Your job is to coordinate, not to implement on your own initiative:
- Understand what each phase needs to accomplish
- Delegate implementation to `/stepwise-core:tdd` — let it decide what to write and when
- Delegate quality checks to `/stepwise-core:bugmagnet`, `/stepwise-core:mutation-testing` and `/stepwise-core:test-desiderata`
- Run verification commands and update progress

You may edit files when a delegated skill instructs you to. What you must not do is decide on your own to write code, add tests, or modify source files.

If a delegated skill reports a structural mismatch (file doesn't exist, architecture changed), STOP and ask the user:
```
Issue in Phase [N]:
Expected: [what the plan says]
Found: [actual situation]
Why this matters: [explanation]

How should I proceed?
```

## Phase Cycle

For **each phase** in the plan, follow this cycle in order:

### Step 1 — Delegate to TDD skill

Invoke `/stepwise-core:tdd` using the `Skill` tool. Pass it:
- The phase description (copy the relevant section from the plan)
- The file paths that need to be created or modified
- The success criteria for this phase

Example argument: "Implement Phase 2 from the plan: Add TodoUpdate model to models.py. Files: src/todo_api/models.py, tests/test_models.py. Success: make test passes."

TDD will read the files, write failing tests, implement, and refactor. Wait for it to complete before proceeding to Step 2.

### Step 2 — Delegate to BugMagnet skill

**Do not analyze bugs yourself.** Invoke `/stepwise-core:bugmagnet` using the `Skill` tool on each file modified in this phase.

Then apply the findings you judge worthwhile, without asking the user, and move on to Step 3.

### Step 3 — Delegate to Mutation Testing skill

**Do not analyze mutants yourself.** Invoke `/stepwise-core:mutation-testing` using the `Skill` tool with `--changed` and the production files modified in this phase (e.g. `--changed src/todo_api/models.py`). It mutates only the changed hunks and hands any gaps to tdd itself.

Include its "Still alive" and "Bugs found" sections in the final summary, then move on to Step 4.

### Step 4 — Delegate to Test Desiderata skill

**Do not analyze test quality yourself.** Invoke `/stepwise-core:test-desiderata` using the `Skill` tool on the test files for this phase, including any tests added in Step 3.

Then apply the improvements you judge worthwhile, without asking the user, and move on to Step 5.

### Step 5 — Verify and Advance

- Run all automated success criteria checks (usually `make check test` covers everything)
- Fix any issues before proceeding
- Update your progress in both the plan and your todos
- Check off completed items in the plan file itself using Edit

Do not pause for manual verification. Leave those items unchecked, continue to the next phase, and list them in the final summary.


## If You Get Stuck

When a delegated skill fails or reports issues:
- Present the problem to the user with context from the skill's output
- Consider if the codebase has evolved since the plan was written
- Ask for guidance before retrying

Do not attempt to fix issues by reading source files and implementing directly — re-invoke the skill with adjusted instructions.

## Resuming Work

If the plan has existing checkmarks:
- Trust that completed work is done
- Pick up from the first unchecked item
- Verify previous work only if something seems off

Remember: You're implementing a solution, not just checking boxes. Keep the end goal in mind and maintain forward momentum.

## Completion

When all phases are complete:
1. **Run final verification**:
   ```bash
   make check test  # Or project-specific command
   ```

2. **Update the plan file**:
   - Ensure all checkboxes are marked
   - Note any deviations from the original plan

3. **Inform the user**:
   ```
   Implementation complete for: [Plan Name]

   All phases implemented and verified:
   - [List key accomplishments]

   Pending manual verification:
   - [Manual verification items from the plan, if any]

   Mutation testing:
   - [Surviving mutants and bugs reported per phase, or "No surviving mutants"]

   Next steps in the workflow:
   - Use `/stepwise-core:validate-plan thoughts/shared/plans/[filename].md` to verify completeness
   - Use `/stepwise-git:commit` to create git commits for the changes

   Tip: Use `/clear` to free up context before validation
   ```
