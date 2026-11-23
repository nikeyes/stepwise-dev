---
name: small-safe-steps
description: Small Safe Steps (S3): breaks work into independently verifiable steps with zero downtime, sizing commits, CI runs, PRs and deployments separately. Use when asking "how do I implement/migrate/refactor", "what steps to do X", "plan safe migration", or handling risky DB/API changes. Applies expand-contract pattern for migrations, refactorings, schema changes.
allowed-tools:
  - Read
  - AskUserQuestion
---

STARTER_CHARACTER = 🪜⚡

# Small Safe Steps

## Mission

Help you divide **ANY work** into the smallest, safest, most valuable steps possible — each with one observable outcome, one check and a cheap undo.

**Core belief:** Risk grows faster than the size of the change.

---

## How to Use This Skill

**Automatic activation - just ask:**
- "How do I migrate from SendGrid to AWS SES?"
- "I need to refactor this legacy code"
- "How do I rename this database column safely?"
- "What's the safest way to implement X?"

**Manual invocation:**
- `/small-safe-steps` + describe your work
- Example: `/small-safe-steps Migrate authentication from Auth0 to Keycloak`

**In workflow with other skills:**
1. Use **story-splitting** → Break large story into smaller ones
2. Use **small-safe-steps** (THIS SKILL) → Plan verifiable implementation steps

---

## When to Use This Skill

**Use when:**
- Work feels too big or risky (refactoring, migrations, performance fixes)
- Database schema changes, API changes, service replacements
- User asks "how do I implement" after deciding what to build
- Work has more than one independent outcome or production transition

**Do NOT use when:**
- User is still deciding WHAT to build (use story-splitting or hamburger-method first)
- Work is already one verifiable step

---

## Applies to ALL Types of Work

### Product Work
- Feature implementation
- User stories (after initial splitting)
- UX improvements

### Technical Work
- Refactorings
- Performance improvements
- Tech debt reduction
- Architecture changes
- Database migrations

### Research & Investigation
- Debugging complex issues
- Spike/POC work
- Technology evaluation
- Root cause analysis

### Operations & Deployment
- Infrastructure changes
- Service migrations
- Deployment process improvements

---

## Core Process

### Step 1: Understand the Goal

Clarify the goal by asking:
- "What's the end state we want?"
- "Why are we doing this now?"
- "What's the smallest outcome that would be valuable?"
- "How will we know it's done?"
- "What's the risk if this goes wrong?"

### Step 2: Detect Risky Changes

🚨 **Identify if this is a risky/breaking change:**

**Red flags for risky changes:**
- Renaming database columns, tables, or fields
- Changing data types or formats (string → object, XML → JSON)
- Modifying public APIs or contracts
- Replacing existing services/libraries
- Changes that break backward compatibility
- Anything that can't be easily reversed

**If risky change detected → Apply Expand-Contract Pattern**

See "Quick Reference: Risky Changes" below and [small-safe-steps.md](references/small-safe-steps.md) for detailed examples.

### Step 3: Break Down into Phases

Identify 3-5 major phases, each independently valuable:

**Example: "Improve API performance"**
- Phase 1: Establish baseline (measure current performance)
- Phase 2: Identify bottleneck
- Phase 3: Implement fix
- Phase 4: Measure improvement
- Phase 5: (If needed) Fix secondary issues

**Example: "Migrate from SendGrid to AWS SES" (risky change)**
- Phase 1: Expand (add AWS SES alongside SendGrid)
- Phase 2: Migrate (gradually switch to AWS SES)
- Phase 3: Contract (remove SendGrid)

### Step 4: Slice each phase into verifiable steps

A step is the largest coherent change that has one observable outcome,
can be checked independently, and can be undone cheaply.
Do not size steps in hours or ask the agent for a time estimate.

A step is ready when:
1. Its outcome fits in one sentence: one behavior or one preserved invariant.
2. A named local check proves it, seen failing first where applicable.
3. Build and relevant tests are green afterwards.
4. It can be committed and reverted on its own.
5. A reviewer can understand its intent from the diff.
6. A fresh agent could resume from the repo, plan and commits alone.

Split further when the step has two independent outcomes, couples unrelated
modules, has weak or missing checks, unclear requirements, or two failed
attempts.

Merge with a neighbor when the split would create a commit that cannot be
verified or reverted alone, or would add review and CI cost without
isolating a separate risk.

#### Put each risk at the cheapest boundary that contains it

Boundaries, cheapest first: step/commit, PR, deployment or apply, release or flag.
Before adding a boundary, name the failure it isolates and the signal that would
stop the next action. No named failure and signal means no boundary.

- A commit isolates a mistake you can detect locally.
- A PR isolates one review decision.
- A deployment or apply isolates a production transition.
- A flag or cohort isolates user exposure.

Risky work does not automatically need its own PR. If one PR can land inert and
its production transitions run separately, keep one PR and several applies.
Open another PR only when one of these is true:
- It needs a different reviewer or approval decision.
- Merging it triggers a production change that must be observed before the next merge.
- It must land or roll back independently.
- A reviewer could not reach one decision on the combined diff.

#### Make every boundary undoable

For every PR and production transition, state how to undo it and its point of
no return, if it has one.

- A PR may group transitions only if each can be undone separately, including
  after only some of them have been applied. Otherwise split the PR.
- If the repo squash merges, or you do not know, the PR is the revert unit, not the commit.
- `git revert` is not an undo once production state has changed. Name the real
  undo: flag off, previous image, re-apply, restore.
- When something cannot be undone, say so. Put it as late as possible, behind
  human approval and a verified recovery path.

Do not push to discover failures a local command could reveal.
Push when the slice is coherent, or when you need a signal unavailable locally.
Every integration to trunk is verified by CI and leaves trunk deployable.

Size PRs as one review decision. Around 100 changed lines is a healthy default;
200-400 is a warning; above 1,000 needs an explicit reason. Exclude generated
code, lockfiles, snapshots and verified deletions.

Never combine in one deployment: schema with dependent code, backfill with
read switch, reader support with write activation, deprecation with removal,
or a destructive drop with anything else.

Never dual-execute external side effects (payments, email, webhooks).
Give each entity one owner path at a time and compare intended payloads.

Base every wait on an observable condition: a full cycle of the affected process,
enough traffic, or a named metric. Do not invent fixed durations. Respect decisions
the user already made unless new evidence changes the risk.

Report the plan by unit: steps, commits, pushes/CI runs, PRs, deployments and releases.
For each PR beyond the first, state which rule above justifies it.

### Step 5: Identify Learning vs. Earning Steps

Flag steps by type:

**Learning steps** (bounded research/investigation):
- Bounded by one named question: "Answer X"
- Goal: Reduce uncertainty, inform decisions
- Output: Document, decision, or data

**Earning steps** (deliver value):
- Goal: Ship working software to production
- Output: Deployed feature, improvement, or fix
- Measurable user impact

**Key principle:** Learning before earning. Don't build before you understand.

---

## Quick Reference: Risky Changes → Expand-Contract Pattern

Use this table to quickly identify risky changes and apply the correct pattern.

| Change Type | Example | Expand-Contract Phases |
|-------------|---------|----------------------|
| **Rename DB column** | `email` → `email_address` | 1. Add new column + dual-write<br>2. Switch reads to new<br>3. Drop old column |
| **Change data type** | String → JSON object | 1. Add new column + parse/backfill<br>2. Switch to new format<br>3. Drop old column |
| **API field rename** | `userName` → `username` | 1. Return both fields<br>2. Deprecate old, notify consumers<br>3. Remove old field |
| **Replace service** | SendGrid → AWS SES | 1. Add new service behind one-owner routing<br>2. Route traffic % to new<br>3. Remove old service |
| **Replace library** | Lodash → Native JS | 1. Add new code alongside old<br>2. Migrate callers incrementally<br>3. Remove old library |
| **Refactor logic** | `calculate_v1` → `calculate_v2` | 1. Implement new alongside old<br>2. Compare outputs, migrate callers<br>3. Remove old function |

**For detailed step-by-step examples, see [small-safe-steps.md](references/small-safe-steps.md).**

---

## Expand-Contract Pattern (Summary)

When you detect a **risky/breaking change**, use the **Expand-Contract pattern** to maintain zero downtime:

### Phase 1: EXPAND (Add New Alongside Old)

**Goal:** System supports BOTH old and new

**Pattern:**
1. Add new implementation/column/field/service alongside the old
2. For owned, reconcilable state, dual-write to old and new. For external side effects, route each entity to exactly one path
3. Deploy and verify both paths work in production
4. (Optional) Backfill: migrate existing data to new format

**Key principle:** Zero users are affected yet. System continues working with old.

---

### Phase 2: MIGRATE (Switch to New)

**Goal:** Gradually migrate reads/usage from old to new

**Pattern:**
1. Update readers/consumers to use new path
2. Deploy incrementally (feature flag, canary, percentage rollout)
3. Monitor for errors, performance issues
4. **Keep dual-write active** (safety net to rollback)

**Key principle:** System now uses new, but still maintains old as backup.

---

### Phase 3: CONTRACT (Remove Old)

**Goal:** Clean up by removing old implementation

**Pattern:**
1. Stop writing to old path
2. Deploy and monitor (verify old truly unused)
3. Remove old code/column/service
4. Clean up migration/compatibility code

**Key principle:** Only remove after old path has ZERO usage across one relevant business cycle.

---

### Expand-Contract Checklist

**✅ Before MIGRATE phase:**
- [ ] Dual-write is working (data going to both old and new)
- [ ] New path is fully functional in production
- [ ] Monitoring shows both paths are healthy
- [ ] Rollback plan is clear

**✅ Before CONTRACT phase:**
- [ ] Old path has ZERO usage (verified via logs/monitoring)
- [ ] New path has been stable across one relevant business cycle
- [ ] No errors related to old path
- [ ] Team agrees it's safe to remove

---

## Techniques by Work Type (Quick Reference)

| Work Type | Primary Pattern | Phases | Key Considerations |
|-----------|----------------|--------|-------------------|
| **Refactoring** | Expand-Contract | Add new → Dual-call → Migrate → Remove old | Compare outputs if possible |
| **Performance** | Baseline → Fix → Verify | Measure → Identify → Implement → Measure again | Always measure before optimizing |
| **Migration** | Expand-Contract | Add new → Route % → Remove old | Use feature flags for gradual rollout |
| **Debugging** | Linear investigation | Reproduce → Log → Analyze → Fix → Verify | Bound each investigation step to one question |
| **Research/Spike** | Bounded learning | Define questions → Evaluate options → Decide | One question per option, document findings |
| **DB Schema** | Expand-Contract | Add column → Dual-write → Migrate reads → Drop old | Never drop columns immediately |
| **API Changes** | Expand-Contract | Return both → Deprecate → Remove | Remove only after observed consumer usage reaches zero |

**For detailed examples of each pattern, see [small-safe-steps.md](references/small-safe-steps.md).**

---

## Red Flags That a Step is Too Big

Watch for these signs:

- ❌ "Then we also need to..."
- ❌ "While we're at it, let's..."
- ❌ "This requires..."
- ❌ "First we have to..."
- ❌ Multiple verbs in the description ("implement and test and deploy")
- ❌ Has more than one independent outcome
- ❌ Can't be easily reversed
- ❌ Affects multiple systems at once
- ❌ "We need to coordinate with X team first"

**When you spot these, force more slicing.**

---

## Coaching Tone

- **Be ruthless about one outcome, one check, one cheap undo per step**
- **Challenge steps too large to verify, and steps too small to justify their own CI or review**
- **Detect risky changes proactively** and suggest expand-contract
- **Ask forcing questions:**
  - "What's the smallest thing we could deploy right now?"
  - "Can we learn this before building it?"
  - "What would we do if we had to ship tomorrow?"
  - "How would we roll this back if it fails?"
  - "Is this a breaking change? Should we use expand-contract?"
- Use Eduardo Ferro's phrases:
  - "What if we only had half the time?"
  - "What's the worst that could happen?"
  - "Can we avoid doing it entirely?"

---

## Integration with Other Skills

This skill works in sequence with other skills:

**Typical workflow:**
1. **story-splitting**: Break down large user stories into smaller ones
2. **hamburger-method**: Choose vertical slice to implement first
3. **small-safe-steps** (THIS SKILL): Break the approach into verifiable steps

**Use this skill when:**
- User knows WHAT to build and asks HOW to implement it
- When planning execution of a story/feature/refactoring

**Integration examples:**
- Use **story-splitting** first → "Admin can create user" → Then use small-safe-steps to plan verifiable steps
- Use **hamburger-method** first → Choose slice (manual email notification) → Then use small-safe-steps for implementation steps

**Do NOT use this skill when:**
- User hasn't decided what to build yet (use story-splitting first)

---

## Self-Check: Did I Apply This Correctly?

After applying this skill, verify:

- [ ] Every step has one observable outcome and a named check
- [ ] Every integration to trunk leaves it deployable
- [ ] Every step is reversible (can undo without major pain)
- [ ] Every PR and production transition names its real undo and point of no return
- [ ] Risky changes use expand-contract pattern (3 phases: Expand → Migrate → Contract)
- [ ] I separated learning steps (bounded investigation) from earning steps (ship value)
- [ ] Owned-state dual-write stays active during migrate; external effects never run twice
- [ ] Contract starts after zero usage across one relevant business cycle, with restore tested if data is deleted
- [ ] Each phase is independently valuable (delivers some benefit)

**If any checkbox fails, revisit the breakdown.**

**Red flags that I didn't do this right:**
- Steps are "research and implement" (not separated into learning vs. earning)
- Steps are "update database and API" (too many things at once)
- Risky change doesn't use expand-contract (trying to rename column in one step)
- No monitoring/verification steps between phases
- Contract phase happens immediately after 100% migration (no waiting period)

---

## Key Principles

1. **Risk grows faster than the size of the change**
   - Small steps = low risk = fast feedback

2. **Every step must be verifiable; every integration deployable**
   - If you can't check it, it's too big

3. **Every step must be reversible**
   - If you can't undo it easily, it's too risky

4. **Zero downtime is non-negotiable**
   - Use expand-contract for risky changes
   - System must keep working at all times

5. **Learning before earning**
   - Investigate before implementing
   - Bound research to one named question
   - Don't build without understanding

6. **Size each unit by its own cost**
   - Steps by verification, CI by coherent push, PRs by review decision, deployments by production transition
   - Never use time estimates as the size

---

## Reference

For detailed step-by-step examples of expand-contract pattern across different contexts (database changes, API migrations, service replacements, refactorings), see [small-safe-steps.md](references/small-safe-steps.md) in this skill directory.

Examples included:
- Database schema changes (rename column, change data type)
- API contract changes (rename field, versioning)
- Service migrations (email provider, authentication, microservices extraction)
- Refactorings and performance improvements
- Complete interaction examples with user

Author: Eduardo Ferro (expand-contract pattern applied to micro-steps)
Source: https://www.eferro.net/
