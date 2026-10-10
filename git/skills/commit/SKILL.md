---
name: commit
description: Create git commits unattended, with semantic commit format and no Claude attribution
model: inherit
disable-model-invocation: false
allowed-tools: Bash(git status:*) Bash(git diff:*) Bash(git log:*) Bash(git add:*) Bash(git commit:*)
---

<!-- SPDX-License-Identifier: Apache-2.0
     SPDX-FileCopyrightText: 2024 humanlayer Authors (original)
     SPDX-FileCopyrightText: 2025 Jorge Castro (modifications) -->

# Commit Changes

Create git commit(s) for the uncommitted changes in the working tree. Do not ask for confirmation: decide, commit, then report what you committed.

## Rules

- **Format**: `TYPE([SCOPE])[!]: description` (e.g. `feat(kyc): add disapproval reason to kyc mail`)
  - **Types**: `feat`, `fix`, `refactor`, `perf`, `style`, `test`, `docs`, `build`, `ops`, `chore`, `revert`, `reapply`
  - **Scope**: optional, contextual (never a ticket id)
  - **Breaking change**: `!` before `:`, or a `BREAKING CHANGES:` footer
  - **Description**: imperative present tense, lowercase, no trailing period
  - **Body/footer**: optional; use to explain motivation and contrast with previous behavior
- **Splitting**: group related changes; multiple commits if the changes have distinct purposes
- **Staging**: `git add` each file by name, never `-A` or `.`. Stage every modified or new file that belongs to the work. Leave out anything that looks like a secret (`.env`, keys, credentials), a large binary or a generated artifact.
- **Never include**: ticket identifiers (Jira, Linear, etc.), Claude attribution, `Co-Authored-By` lines
- **Nothing to commit**: say so and stop.
- **Report**: the commits you created (hash and subject) and every file you left out, with the reason.
