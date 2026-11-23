---
name: small-safe-steps
description: Small Safe Steps (S3): plans work as small, checked, undoable steps with zero downtime, sizing commits, CI runs, PRs and deployments separately. Use when asking "how do I implement/migrate/refactor", "what steps to do X", "plan safe migration", or handling risky DB/API changes. Applies expand-contract for migrations, refactorings and schema changes.
allowed-tools:
  - Read
  - AskUserQuestion
---

STARTER_CHARACTER = 🪜⚡

# Small Safe Steps

Plan the fewest steps that keep every change small, checked and undoable, with zero downtime. Every extra PR, CI run or deployment costs time, so each must isolate a risk.

## Steps

1. Clarify the end state and what breaks if it goes wrong. Keep the user's decisions unless new evidence changes the risk.
2. Answer unknowns first, one question per learning step.
3. If a contract breaks (schema, public API, data format, service swap), expand-contract: add the new path beside the old, move users gradually, then remove whatever still writes to, depends on or recreates the old path, and only then delete it. Wait until its usage is zero for longer than anything that can reach it lives (sessions, tokens, caches, queues, a business cycle).
4. A step is the largest change with one observable outcome, a local check and a cheap undo. Never size by hours. If the work is one step, say so.

## Boundaries

Add a boundary only when you can name the failure it isolates and the signal that stops the next action. Never justify one by size or by a rule.

- **Commit:** a mistake you can detect locally.
- **PR:** one review decision. Split only for a different reviewer, a production change to observe before the next merge, or an independent rollback.
- **Deployment or apply:** one production transition. One inert PR can drive several applies.

Never deploy together: schema and dependent code, backfill and read switch, reader support and write activation, deprecation and removal, a destructive drop and anything.

## Safety

- Run external side effects (email, payments, webhooks) on one path per entity, never two.
- Enforce guards with code, permissions or pipeline config, not convention.
- Wait on observable conditions, never fixed durations.
- Name each PR and transition's real undo (flag off, previous image, re-apply, restore).  does not undo production state. Group transitions only if each undoes alone. Put the irreversible last, behind human approval and a tested recovery.

## Output

Table of steps: outcome, check, unit (commit, PR, deployment), undo. Why each extra PR exists. Totals: steps, commits, CI runs, PRs, deployments, releases.

Author: Eduardo Ferro. Source: https://www.eferro.net/
