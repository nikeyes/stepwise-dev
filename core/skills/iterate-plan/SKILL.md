---
name: iterate-plan
description: Update an existing implementation plan in thoughts/shared/plans/ from feedback, checking the change against the code. Use when the user asks to change, extend or cut a plan.
argument-hint: [plan-file-path] [changes to make]
model: inherit
disable-model-invocation: false
---

<!-- SPDX-License-Identifier: Apache-2.0
     SPDX-FileCopyrightText: 2024 humanlayer Authors (original)
     SPDX-FileCopyrightText: 2025 Jorge Castro (modifications) -->

# Iterate Implementation Plan

**Input**: $ARGUMENTS, a plan path followed by the changes to make. If either is missing, ask for it. `ls -t thoughts/shared/plans/ | head` lists recent plans.

1. Read the whole plan, then work out what the feedback changes.
2. Check in the code the facts the change depends on. Spawn `stepwise-core:codebase-locator`, `codebase-analyzer` or `codebase-pattern-finder` only for code you have not seen. Facts are your job; decisions are the user's.
3. If the feedback conflicts with the plan or the code, or leaves a decision only the user can make, ask those questions in one round, each with your recommendation, and wait. Decide anything with an obvious default yourself and write it into the plan. Otherwise edit without asking for confirmation.
4. Edit the plan in place with the Edit tool, changing only what the feedback touches:
   - A new phase follows the pattern of the existing ones.
   - Update everything the change affects: "What We're NOT Doing", other phases, existing tests that assert the old behaviour, and references.
   - Success criteria stay runnable commands.
   - Leave no open questions in the plan.
5. Reply with a short list of the changes and the next step: `/stepwise-core:implement-plan <plan-path>`.
