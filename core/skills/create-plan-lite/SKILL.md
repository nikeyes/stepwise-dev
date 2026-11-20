---
name: create-plan-lite
description: Create a short implementation plan (under 80 lines) from a ticket or a description, after researching the codebase. Experimental lighter alternative to create-plan
argument-hint: [ticket-file-path or description of the change]
model: inherit
disable-model-invocation: true
---

<!-- SPDX-License-Identifier: Apache-2.0
     SPDX-FileCopyrightText: 2024 humanlayer Authors (original)
     SPDX-FileCopyrightText: 2025 Jorge Castro (modifications) -->

# Create Plan (lite)

**Request**: $ARGUMENTS. It is a ticket file or a description of the change. If it is empty, ask what to build and wait.

The plan is short. A reviewer reads it in two minutes. `/stepwise-core:implement-plan` builds it phase by phase with TDD.

## Steps

1. Read the request. If it is a file, read it fully, and read every file it mentions.
2. Research with sub-agents in parallel: **stepwise-core:codebase-locator** (files involved), **stepwise-core:codebase-pattern-finder** (the closest existing sibling of what you add, and every place that sibling is registered: lists, baselines, maps, docs), **stepwise-core:thoughts-locator** (earlier plans or research on this area). Read the files they find.
3. Tell the user in a few lines what you understood, what you found (file:line) and the phases you propose. If the user corrects you, check the correction in the code.
4. Invoke `/stepwise-core:grill-me` with the Skill tool. Give it what you found and the decisions that are still open. If the request is a short description, grill-me also confirms its scope. Do not ask questions yourself.
5. Write the plan to `thoughts/shared/plans/YYYY-MM-DD-description.md` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/thoughts-management/scripts/thoughts-init` first if `thoughts/` does not exist).
6. Give the path and ask the user to review it. Change it until they approve. Then give the next step: `/stepwise-core:implement-plan <path>`.

## Rules

- Build what the request asks. Nothing more. Copy the sibling's patterns.
- No code. Write behaviors and contracts.
- Write a decision only if the request or the code does not already settle it. No open questions in the plan.
- Name the existing pieces you reuse (components, hooks, helpers, icons, tables) with file:line.
- Keep the plan under 80 lines.

## Template

````markdown
# [Title]

Request: [ticket path, or the user's description in one line]

## Goal
[One or two sentences.]

## Decisions
- [Decision] — [reason, file:line of the pattern it follows]

## What We're NOT Doing
- [Tempting extra that the request does not ask for]

## Phase 1: [Name]
Behaviors (each one a test):
- [Observable behavior]

Contracts: [endpoints, shapes, error codes, signatures, config, log events, data model — only what changes]

Files: `path` — [what changes]

### Success Criteria:
- [ ] [Full test suite command, prefer `make`]
- [ ] [Lint and type check command]
- [ ] Manual: [only for what a test cannot check, such as how the UI looks; omit otherwise]
````

Use one phase unless the work has a natural split.
