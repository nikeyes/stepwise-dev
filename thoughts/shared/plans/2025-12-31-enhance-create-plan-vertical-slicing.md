---
date: 2025-12-31T13:32:10+0000
researcher: Jorge Castro
git_commit: 8c4b61405fc57551e5aa0f7afc03d4364fdc81c6
branch: main
repository: stepwise-dev
topic: "Enhance create_plan command with vertical slicing and small safe steps"
tags: [plan, create_plan, vertical-slicing, small-safe-steps, hamburger-method, lean-delivery]
status: complete
last_updated: 2025-12-31
last_updated_by: Jorge Castro
---

# Enhance create_plan Command with Vertical Slicing and Small Safe Steps

**Date**: 2025-12-31 14:32:10 CET
**Researcher**: Jorge Castro
**Git Commit**: 8c4b61405fc57551e5aa0f7afc03d4364fdc81c6
**Branch**: main
**Repository**: stepwise-dev

## Overview

Enhance the `/stepwise-dev:create_plan` command to guide Claude in creating implementation plans that emphasize vertical slicing, small safe steps, and progressive delivery. This integrates Eduardo Ferro's lean delivery philosophy, the Hamburger Method, and learning-driven development into the planning process.

## Current State Analysis

**What exists now:**
- `/stepwise-dev:create_plan` command at `commands/create_plan.md` (480 lines)
- Current planning flow:
  1. Context gathering & initial analysis
  2. Research & discovery (spawn agents)
  3. Plan structure development
  4. Detailed plan writing
  5. Sync and review

**Current plan template includes:**
- Overview, Current State Analysis, Desired End State
- What We're NOT Doing
- Implementation Approach
- Multiple phases with changes and success criteria
- Testing strategy, performance considerations, migration notes

**What's missing:**
- No vertical slicing guidance (Hamburger Method)
- No learning vs earning classification
- No Eduardo Ferro leadership philosophy prompts
- No progressive delivery pattern suggestions
- No complexity dimension assessment
- No emphasis on "smallest safe step"
- Phases may be too large or technically layered
- No questions about reversibility and postponing decisions

**Key constraints discovered:**
- Must maintain backward compatibility with existing plan format (commands/create_plan.md:194-281)
- Must preserve interactive planning process
- Success criteria structure must remain (automated vs manual)
- Thoughts directory integration must work unchanged
- File naming conventions must remain: `YYYY-MM-DD-[ENG-XXXX-]description.md`

## Desired End State

After this plan is complete:
1. `create_plan.md` will guide Claude to apply vertical slicing techniques when planning
2. Plans will emphasize small safe steps and progressive delivery
3. Each phase will be tagged as "Learning" or "Earning"
4. Complexity dimensions will be assessed before finalizing plans
5. Eduardo Ferro's leadership philosophy will challenge scope and push for simplicity
6. The final plan template will include vertical slicing analysis
7. All existing commands and workflows continue to work unchanged

### Success Criteria:
- [ ] Modified command file is valid markdown: `make check`
- [ ] New sections integrate seamlessly with existing flow
- [ ] Plan template includes vertical slicing analysis
- [ ] Leadership philosophy prompts are strategically placed
- [ ] Learning vs Earning classification is clear
- [ ] Examples demonstrate the new approach
- [ ] Documentation is updated to reflect changes

## What We're NOT Doing

- Not changing the file naming conventions or directory structure
- Not modifying other commands (`research_codebase`, `implement_plan`, etc.)
- Not altering the thoughts-management Skill
- Not changing the interactive planning nature (still collaborative, not one-shot)
- Not removing existing plan template sections (additive changes only)
- Not requiring all plans to use every new technique (provide guidance, not mandates)
- Not changing success criteria format (automated vs manual distinction remains)

## Implementation Approach

**Strategy: Progressive Enhancement of Planning Process**

We'll enhance the planning command by:
1. Adding vertical slicing analysis as a new step after research
2. Injecting Eduardo Ferro's leadership philosophy prompts at key decision points
3. Enhancing the plan template with vertical slicing sections
4. Adding learning vs earning classification to phases
5. Including complexity dimension assessment checklist
6. Providing progressive delivery pattern examples

This approach:
- Maintains backward compatibility (additive changes)
- Preserves interactive planning process
- Guides without mandating specific approaches
- Aligns with TDD and lean delivery principles
- Builds on existing strong foundation

## Phase 1: Add Vertical Slicing Analysis Step **[Earning]**

### Overview
Insert a new step in the planning process that applies the Hamburger Method and Eduardo Ferro's leadership philosophy to generate vertical slice options before finalizing the plan structure.

### Vertical Slice:
This phase delivers a complete new planning step that Claude can immediately use to challenge scope and identify smaller delivery options.

### Reversibility:
Easy - additive change, can be removed without affecting other steps.

### Changes Required:

#### 1. Add New Step 2.5: Vertical Slicing Analysis
**File**: `commands/create_plan.md`
**Changes**: Insert new section after "Step 2: Research & Discovery" (after line 149)

After the current "Present findings and design options" section (line 149), add:

```markdown
### Step 2.5: Vertical Slicing Analysis

After understanding the current state and design options, but before committing to a plan structure, apply vertical slicing techniques to identify the smallest valuable increments.

1. **Apply the Hamburger Method:**

   a. **Identify Technical/Logical Layers:**
      - List the main technical or logical steps involved in the feature
      - Examples: Data input → Processing → Storage → Delivery → UI
      - For each layer, note what currently exists vs what needs to be built

   b. **Define Quality Attributes per Layer:**
      - For each layer, ask: "What makes this layer good?"
      - List options from simplest (manual, hardcoded) to most robust (automated, dynamic)
      - Example for "Deliver notification" layer:
        - Manual email to one user
        - Scripted email to test users
        - Automated email via queue
        - Multi-channel (email + push + SMS)

   c. **Compose Vertical Slice Options:**
      - Create 3-4 vertical slice combinations (one option per layer)
      - Each slice must deliver value to real users (even if limited scope)
      - Order from smallest/fastest to most complete
      - Example:
        ```
        Slice 1 (Minimal - ship by tomorrow):
        - Manual input → Hardcoded logic → Local file → Manual delivery
        - Learning value: Validate workflow and user need
        - Risk: No automation, manual effort

        Slice 2 (Next iteration):
        - Form input → Hardcoded logic → Database → Automated email
        - Learning value: Test database integration, email delivery
        - Builds on: Slice 1's workflow validation

        Slice 3 (Enhanced):
        - Form input → Dynamic rules → Database → Multi-channel
        - Learning value: Test complex routing logic
        - Builds on: Slice 2's infrastructure
        ```

2. **Apply Eduardo Ferro's Leadership Philosophy Prompts:**

   Present these questions to challenge scope and identify simpler alternatives:

   a. **"If you had to develop and test something your customer wants, and ship it by tomorrow, what would it be?"**
      - Forces identification of absolute minimum viable deliverable
      - Strips away non-essentials
      - Example: "Manual CSV upload tested with one real customer"

   b. **"Can we avoid doing it?"**
      - Question whether the task is necessary
      - Explore alternatives (buy vs build, existing solutions, workarounds)
      - Example: "Could we use an existing third-party service instead?"

   c. **"Can we achieve the same impact with fewer resources?"**
      - Identify scope reduction opportunities
      - Find simpler implementations
      - Example: "Backend-only API first, add UI later when usage proves value"

   d. **"What if we only had half the time?"**
      - Surface core value proposition
      - Identify nice-to-haves vs must-haves
      - Example: "Focus on happy path only, handle edge cases in iteration 2"

   e. **"What's the worst that could happen?"**
      - Evaluate risk realistically for small, reversible steps
      - Encourage experimentation within safe boundaries
      - Example: "If manual process fails, we can fix and retry - reversible"

3. **Assess Complexity Dimensions:**

   Check key complexity factors to guide implementation decisions:

   **Data & Volume:**
   - Expected data size (KB/MB/GB)?
   - Number of elements processed?
   - Growth rate (slow/moderate/explosive)?
   - → Small volume = simpler approach OK, large volume = need optimization

   **Consistency & Order:**
   - Processing order critical?
   - Strong or eventual consistency needed?
   - Distributed transactions required?
   - → Eventual consistency and relaxed order = simpler

   **Resilience & Reversibility:**
   - Error criticality (tolerable vs critical)?
   - Can operations be undone or compensated?
   - Idempotence required?
   - → Reversible operations = lower risk, faster delivery

   **Dependencies & Integration:**
   - External service dependencies?
   - Third-party API requirements?
   - Versioning and backward compatibility needs?
   - → Fewer dependencies = simpler, faster

   **Evolution & Maintenance:**
   - How easy to refactor later?
   - Cost sensitivity?
   - Availability requirements?
   - → If change is cheap later = optimize for delivery now

4. **Identify Learning vs Earning Opportunities:**

   Categorize potential work:

   **Learning (time-boxed research/validation):**
   - De-risk technical uncertainties
   - Validate user needs and workflows
   - Test integration feasibility
   - Measure performance or capacity
   - Examples:
     - "Spike: Test third-party API integration (4 hours max)"
     - "Experiment: Hardcoded data to validate workflow with 3 users (2 days)"
     - "Research: Load test current system to identify bottlenecks (1 day)"

   **Earning (value delivery to users):**
   - Deliver working functionality
   - Improve existing features
   - Fix bugs or issues
   - Examples:
     - "Backend API for data export (CSV only)"
     - "UI for basic search (exact match only, no filters)"
     - "Email notifications for critical events only"

5. **Identify Progressive Delivery Patterns:**

   Suggest applicable progressive delivery approaches:

   **Dummy → Dynamic:**
   - Start with hardcoded data to validate workflow
   - Later integrate with real data source
   - Example: "Hardcode test notifications → Connect to event stream"

   **Backend-only → Full Stack:**
   - Build API/logic first, test with curl/Postman
   - Add UI after backend proves valuable
   - Example: "Admin API endpoint → Public UI later"

   **Limited Scope → Full Feature:**
   - Narrow customer segment first
   - Support one format/channel before many
   - Example: "Export CSV only → Add JSON, XML later"
   - Example: "Email only → Add push notifications later"

   **Manual → Automated:**
   - Manual process to validate value
   - Automate after usage proves worth it
   - Example: "Manual report generation → Scheduled automation"

   **Feature Flagged Rollout:**
   - Internal users → 1% → 10% → 100%
   - Easy rollback if issues found
   - Example: "Team only → Beta users → All users"

   **Parallel Systems:**
   - Write to old and new systems in parallel
   - Compare results, gain confidence
   - Migrate reads after validation
   - Example: "Dual-write to old and new DB → Migrate reads → Remove old"

6. **Present Vertical Slicing Analysis to User:**

   ```
   ## Vertical Slicing Analysis

   I've identified opportunities to deliver this feature incrementally using small safe steps.

   **Layers Identified:**
   1. [Layer 1 - e.g., Data collection]
   2. [Layer 2 - e.g., Processing/validation]
   3. [Layer 3 - e.g., Storage]
   4. [Layer 4 - e.g., Delivery/presentation]

   **Minimal Vertical Slice (ship by tomorrow):**
   - [Simplest option for each layer that delivers real value]
   - Learning value: [What we'll validate]
   - Risk: [Low/Medium/High - explain]
   - Reversibility: [Easy/Moderate/Difficult]

   **Progressive Iterations:**
   - Slice 2: [Next improvement]
   - Slice 3: [Further enhancement]

   **Complexity Assessment:**
   - Data volume: [Small/Medium/Large - implications]
   - Consistency needs: [Eventual/Strong - why]
   - Reversibility: [Easy/Hard - approach]
   - External dependencies: [List - fallback plans]

   **Learning vs Earning:**
   - Learning phases: [Time-boxed spikes/experiments needed]
   - Earning phases: [Value delivery increments]

   **Recommended Progressive Delivery Pattern:**
   - [Specific pattern that fits this feature - e.g., "Backend-only → UI", "Dummy → Dynamic"]

   **Questions for you:**
   - Does the minimal slice deliver enough value to be worth shipping?
   - Are there any irreversible decisions we can postpone until later iterations?
   - Which progressive delivery pattern resonates with your vision?
   ```

7. **Get user feedback on vertical slicing approach before proceeding to plan structure**

This new step ensures plans emphasize small safe steps and progressive delivery before committing to a detailed implementation plan.
```

#### 2. Update Step 3 Reference
**File**: `commands/create_plan.md`
**Changes**: Update line references and step numbers after inserting new Step 2.5

The current "Step 3: Plan Structure Development" (line 150) becomes "Step 3: Plan Structure Development" (stays same) but now follows the vertical slicing analysis.

Update the introduction to Step 3:

```markdown
### Step 3: Plan Structure Development

Once aligned on the vertical slicing approach and progressive delivery pattern:

1. **Create initial plan outline based on vertical slices:**
   ```
   Here's my proposed plan structure based on our vertical slicing analysis:

   ## Overview
   [1-2 sentence summary]

   ## Implementation Phases (organized as vertical slices):
   1. [Slice 1 - Minimal] - [what it delivers, learning value] **[Learning/Earning]**
   2. [Slice 2 - Enhanced] - [what it builds on, what it delivers] **[Earning]**
   3. [Slice 3 - Complete] - [final capabilities] **[Earning]**

   Each phase delivers working, valuable functionality to real users (even if limited scope).

   Does this phasing make sense? Should I adjust the order or granularity?
   ```

2. **Get feedback on structure** before writing details
```

### Success Criteria:

#### Automated Verification:
- [x] Command file is valid markdown: `make check`
- [x] No broken references or syntax errors

#### Manual Verification:
- [ ] New Step 2.5 integrates logically in the planning flow
- [ ] Hamburger Method explanation is clear and actionable
- [ ] Eduardo Ferro's prompts are strategically placed and explained
- [ ] Complexity dimensions checklist is comprehensive but not overwhelming
- [ ] Learning vs Earning distinction is clear with examples
- [ ] Progressive delivery patterns cover common scenarios
- [ ] Example output format guides Claude effectively

---

## Phase 2: Enhance Plan Template with Vertical Slicing **[Earning]**

### Overview
Modify the plan document template (used in Step 4) to include vertical slicing analysis sections and learning/earning classification.

### Vertical Slice:
This phase delivers an enhanced plan template that captures vertical slicing decisions and makes progressive delivery explicit in every plan.

### Reversibility:
Easy - template changes only affect new plans, existing plans unaffected.

### Changes Required:

#### 1. Add Vertical Slicing Analysis Section to Template
**File**: `commands/create_plan.md`
**Changes**: Modify the template structure at lines 194-281

After the "## What We're NOT Doing" section in the template, insert new sections:

```markdown
## Vertical Slicing Analysis

### Layers Identified:
1. [Layer name - e.g., Data input]
   - Current state: [What exists]
   - Needed: [What needs to be built]

2. [Layer name - e.g., Processing]
   - Current state: [What exists]
   - Needed: [What needs to be built]

3. [Layer name - e.g., Storage]
   - Current state: [What exists]
   - Needed: [What needs to be built]

4. [Layer name - e.g., Delivery/UI]
   - Current state: [What exists]
   - Needed: [What needs to be built]

### Quality Attributes per Layer:

**[Layer 1 name]:**
- Simplest: [Manual/hardcoded option]
- Basic: [Simple automation]
- Enhanced: [Full automation with error handling]
- Advanced: [Robust with monitoring, retry, fallback]

**[Layer 2 name]:**
[Similar quality progression]

### Vertical Slice Options:

**Slice 1: Minimal (Deliver first)**
- [Layer 1]: [Simplest option chosen]
- [Layer 2]: [Simplest option chosen]
- [Layer 3]: [Simplest option chosen]
- [Layer 4]: [Simplest option chosen]
- **Learning value**: [What this validates]
- **User value**: [What users can do with this]
- **Time estimate**: [Rough estimate - e.g., "1-2 days"]

**Slice 2: Enhanced (Next iteration)**
- [Layer 1]: [Improved option]
- [Layer 2]: [Improved option]
- [Layer 3]: [Same or improved]
- [Layer 4]: [Same or improved]
- **Builds on**: Slice 1
- **Learning value**: [What new things this validates]
- **User value**: [Additional capabilities]

**Slice 3: Complete (Final target)**
- [All layers at desired quality level]
- **Builds on**: Slice 2
- **Completes**: Full feature as originally envisioned

### Complexity Assessment:

**Data & Volume:**
- Expected data size: [KB/MB/GB]
- Number of elements: [Range]
- Growth expectations: [Slow/Moderate/Fast]
- **Implication**: [How this affects implementation choices]

**Consistency & Order:**
- Processing order required: [Yes/No - explain]
- Consistency needs: [Eventual/Strong - justify]
- Distributed transactions: [Needed/Avoided - approach]
- **Implication**: [Simpler or more complex approach]

**Resilience & Reversibility:**
- Error criticality: [Tolerable/Critical - why]
- Reversibility: [Easy/Moderate/Hard - explain]
- Idempotence required: [Yes/No - approach]
- **Implication**: [Risk level and mitigation]

**Dependencies & Integration:**
- External dependencies: [List services/APIs]
- Fallback strategies: [For each dependency]
- Versioning needs: [Backward compatibility requirements]
- **Implication**: [Risk and complexity]

**Evolution & Maintenance:**
- Refactoring ease: [Easy/Moderate/Hard later]
- Cost sensitivity: [Low/High - optimize for what]
- Availability requirements: [Uptime needs]
- **Implication**: [Optimize for delivery now vs future flexibility]

### Progressive Delivery Pattern:

**Pattern chosen**: [Name - e.g., "Dummy → Dynamic", "Backend-only → Full Stack"]

**Rationale**: [Why this pattern fits this feature]

**Rollout strategy**:
1. [First step - e.g., "Internal team only"]
2. [Second step - e.g., "Beta users (10%)"]
3. [Final step - e.g., "All users (100%)"]

**Rollback plan**: [How to revert if issues found]

### Decisions and Postponements:

**Irreversible decisions made now:**
- [Decision 1 - why it must be decided now]
- [Decision 2 - why it must be decided now]

**Decisions postponed to later iterations:**
- [Decision 1 - what we'll learn before deciding]
- [Decision 2 - what we'll learn before deciding]

## Implementation Approach

[Existing section - high-level strategy and reasoning based on vertical slicing analysis]
```

#### 2. Modify Phase Template
**File**: `commands/create_plan.md`
**Changes**: Enhance individual phase template to include Learning/Earning classification

Modify the "## Phase 1: [Descriptive Name]" template section:

```markdown
## Phase 1: [Descriptive Name] **[Learning/Earning]**

### Overview
[What this phase accomplishes]

### Vertical Slice Delivered:
[Describe the minimal working functionality this phase delivers to real users, even if limited in scope or quality]

### Type: [Learning / Earning]

**If Learning (time-boxed research/validation):**
- **Time box**: [Maximum time to spend - e.g., "4 hours", "1 day"]
- **Research question**: [What uncertainty are we reducing?]
- **Success criteria**: [What do we need to learn to proceed?]
- **Outcomes possible**:
  - [Outcome 1 → Next action]
  - [Outcome 2 → Alternative approach]

**If Earning (value delivery):**
- **User value**: [What users can now do that they couldn't before]
- **Business value**: [Why this matters to the organization]
- **Builds on**: [Previous phase or existing functionality]

### Reversibility:
- **Can be undone**: [Yes/No]
- **Mechanism**: [How to reverse if needed - e.g., feature flag, database rollback, code revert]
- **Compensating actions**: [If not directly reversible, what compensates - e.g., data migration back, manual cleanup]
- **Risk if not reversed**: [What's the impact if we keep this even if it doesn't work out]

### Changes Required:

#### 1. [Component/File Group]
**File**: `path/to/file.ext`
**Changes**: [Summary of changes]

```[language]
// Specific code to add/modify
```

### Success Criteria:

**For Learning phases:**
- [ ] Time box respected (stop even if incomplete): [timestamp check]
- [ ] Research question answered: [specific findings documented]
- [ ] Decision made on next steps: [document in plan or notes]

**For Earning phases:**

#### Automated Verification:
- [ ] Tests pass: `make test`
- [ ] Linting passes: `make lint`
- [ ] Type checking passes: `make typecheck`
- [ ] [Component-specific tests]: `make test-[component]`

#### Manual Verification (only if truly needed):
- [ ] [Subjective quality check - e.g., "Animation feels smooth"]
- [ ] [Aesthetic judgment - e.g., "Visual appearance matches mockup"]

**What we learned from this phase:**
[To be filled in after implementation - what worked, what didn't, what to adjust for next phase]

---
```

#### 3. Add Progressive Delivery Examples Section
**File**: `commands/create_plan.md`
**Changes**: Add new section after "## Common Patterns" (around line 408)

Insert new section:

```markdown
## Progressive Delivery Patterns

Use these patterns to guide vertical slicing and incremental delivery:

### Pattern: Dummy → Dynamic

**When to use**: Complex data integration, uncertain data quality, external API dependencies

**Approach**:
1. **Phase 1**: Build interface and workflow with hardcoded (dummy) data
   - Validates UI/UX and user workflow
   - No external dependencies
   - Fast to build and test

2. **Phase 2**: Integrate with real (dynamic) data source
   - Builds on validated workflow
   - De-risks integration separately from workflow

**Example**: "Notification system with hardcoded messages → Connect to event stream"

---

### Pattern: Backend-only → Full Stack

**When to use**: API-first development, uncertain UI requirements, testing before broad exposure

**Approach**:
1. **Phase 1**: Build and expose API/logic only
   - Test with curl, Postman, or admin tools
   - Validates business logic and data model
   - No UI complexity

2. **Phase 2**: Add user interface after backend proves valuable
   - UI built on stable, tested API
   - Can iterate on UX separately

**Example**: "Admin API for user management → Public self-service UI"

---

### Pattern: Limited Scope → Full Feature

**When to use**: Large features, broad functionality, risk mitigation

**Approach**:
1. **Phase 1**: Narrow customer segment or limited functionality
   - Full feature for subset of users, or
   - Core functionality for all users
   - De-risks before full investment

2. **Phase 2**: Expand scope incrementally
   - Add user segments, or
   - Add capabilities

**Examples**:
- "CSV export only → Add JSON, XML formats"
- "Email notifications → Add push, SMS"
- "Power users only → All users"

---

### Pattern: Manual → Automated

**When to use**: Unproven value, uncertain volume, learning required

**Approach**:
1. **Phase 1**: Manual process to validate value
   - Minimal automation
   - Learn about usage patterns and edge cases
   - Fast to build

2. **Phase 2**: Automate after usage proves worth it
   - Informed by real usage data
   - Build exactly what's needed

**Example**: "Manual report generation on request → Scheduled automation → Self-service"

---

### Pattern: Feature Flagged Rollout

**When to use**: Risk mitigation, gradual exposure, A/B testing

**Approach**:
1. **Phase 1**: Internal team only (feature flag: team)
   - Validate in production with safety net
   - Quick feedback loop

2. **Phase 2**: Beta users (feature flag: 1-10%)
   - Real user feedback
   - Monitor metrics and errors
   - Easy rollback if issues

3. **Phase 3**: All users (feature flag: 100%)
   - Full rollout after validation

**Example**: "New search algorithm: team → 5% users → 100%"

---

### Pattern: Parallel Systems (Dual Write)

**When to use**: Data migrations, system replacements, high-risk changes

**Approach**:
1. **Phase 1**: Write to both old and new systems
   - Compare results
   - Build confidence in new system
   - Reads still from old system (safe)

2. **Phase 2**: Migrate reads to new system
   - Old system still receives writes (safety net)
   - Monitor for differences

3. **Phase 3**: Remove old system
   - After validation period
   - New system fully proven

**Example**: "Dual-write to old and new database → Migrate reads → Remove old DB"

---

### Pattern: CSV/File Before Pipeline

**When to use**: Data ingestion, uncertain data quality, external data sources

**Approach**:
1. **Phase 1**: Simple file upload/processing
   - Validates data structure and quality
   - Learn about edge cases
   - Fast to build

2. **Phase 2**: Build automated pipeline
   - Informed by real data experience
   - Handle known edge cases

**Example**: "Manual CSV upload → Automated API ingestion pipeline"

---

### Choosing the Right Pattern:

Ask these questions:
1. **What's the biggest uncertainty?** → Use pattern that validates it first
2. **What's the biggest risk?** → Use pattern that mitigates it (feature flags, parallel systems)
3. **What delivers user value fastest?** → Use that pattern
4. **What's irreversible?** → Postpone with pattern that keeps options open

**Combine patterns** when appropriate:
- "Dummy data + Backend-only + Feature flagged" for high-risk features
- "Limited scope + Manual" to validate niche use cases cheaply
```

### Success Criteria:

#### Automated Verification:
- [x] Command file is valid markdown: `make check`
- [x] Template structure is well-formed
- [x] No syntax errors in example code blocks

#### Manual Verification:
- [ ] New template sections integrate seamlessly with existing ones
- [ ] Vertical slicing analysis template is comprehensive but not overwhelming
- [ ] Learning vs Earning classification is clear with concrete examples
- [ ] Progressive delivery patterns cover common scenarios
- [ ] Phase template enhancements preserve existing success criteria structure
- [ ] Examples are actionable and realistic

---

## Phase 3: Add Small Safe Steps Guidance to Planning Guidelines **[Earning]**

### Overview
Enhance the "Important Guidelines" section to emphasize small safe steps, reversibility, and postponing decisions.

### Vertical Slice:
This phase delivers additional guidance that reinforces small safe steps thinking throughout the planning process.

### Reversibility:
Easy - additive guidance, doesn't change core behavior.

### Changes Required:

#### 1. Enhance "Be Practical" Guideline
**File**: `commands/create_plan.md`
**Changes**: Expand the "Be Practical" section (around line 343)

Replace the current "4. **Be Practical**:" section with:

```markdown
4. **Be Practical - Emphasize Small Safe Steps**:
   - **Favor reversible changes**: Design phases that can be undone or rolled back easily
     - Use feature flags for new functionality
     - Parallel writes before migrating reads
     - Gradual rollouts (1% → 10% → 100%)

   - **Focus on incremental, testable changes**: Each phase should deliver working functionality
     - No "infrastructure-only" phases unless necessary
     - Every phase should be demonstrable to users
     - Build up complexity gradually, not all at once

   - **Postpone irreversible decisions**: Wait until you have more information
     - Schema changes → Start with new columns, migrate later
     - API design → Start with flexible structure, optimize later
     - Architecture → Start simple, refactor when needed
     - Ask: "What can we learn before committing to this decision?"

   - **Consider migration and rollback**: Always have an escape hatch
     - Document rollback procedures for each phase
     - Use database migrations with down scripts
     - Keep old code paths until new ones are proven
     - Feature flags for easy disable

   - **Think about edge cases**: But handle them progressively
     - Phase 1: Happy path only
     - Phase 2: Common error cases
     - Phase 3: Edge cases and rare scenarios
     - Don't over-engineer for hypothetical edge cases upfront

   - **Include "what we're NOT doing"**: Prevent scope creep
     - Be explicit about deferred features
     - Call out edge cases being postponed
     - Document assumptions and their validity period

   - **Apply Eduardo Ferro's anti-patterns check**:
     - ❌ Building infrastructure "just in case" you scale
     - ❌ Generalizing code after writing it once
     - ❌ Creating a library for something used by one team
     - ❌ Designing APIs with dozens of parameters for future use cases
     - ❌ Breaking working systems in pursuit of "cleaner" architecture
     - ✅ Build the simplest system that works **today**
     - ✅ Understand every line of code carries a **basal cost** (maintenance)
```

#### 2. Add New Guideline: "Apply Lean Delivery Philosophy"
**File**: `commands/create_plan.md`
**Changes**: Insert new guideline after "Be Practical" (after line 347)

Add new guideline:

```markdown
5. **Apply Lean Delivery Philosophy**:

   - **Challenge the necessity**:
     - Before planning, ask: "Can we avoid doing it?"
     - Explore alternatives: existing solutions, third-party services, workarounds
     - Question whether features add value or just complexity

   - **Maximize impact, minimize effort**:
     - Ask: "Can we achieve the same impact with fewer resources?"
     - Identify scope reduction opportunities
     - Reuse existing patterns and components
     - Find simpler implementations

   - **Force prioritization**:
     - Ask: "What if we only had half the time?"
     - Surface core value proposition
     - Separate must-haves from nice-to-haves
     - Focus on delivering value, not building architecture

   - **Embrace small experiments**:
     - Ask: "What's the worst that could happen?" (for safe, reversible steps)
     - Encourage action within safe boundaries
     - Support learning through small experiments
     - View phases as survivable experiments to test assumptions

   - **Enable safe removal**:
     - Suggest: "Let's build it behind a feature flag and monitor impact"
     - Make features easy to remove if they don't deliver value
     - Prefer additive changes over replacements
     - Monitor usage and be ready to remove unused features

   - **Separate learning from earning**:
     - **Learning phases** (time-boxed spikes/research):
       - De-risk technical uncertainties
       - Validate user needs
       - Test integration feasibility
       - Answer specific questions before committing
       - Always time-boxed with clear decision criteria

     - **Earning phases** (value delivery):
       - Deliver working functionality to users
       - Build on validated learnings
       - Focus on user and business value
       - Measurable impact

   - **Check outcomes with real users**:
     - After delivering, measure if intended impact materialized
     - Use telemetry, analytics, user feedback
     - Be ready to pivot or remove features that don't deliver value
     - Feedback loop ensures focus on actual impact
```

#### 3. Update Guideline Numbering
**File**: `commands/create_plan.md`
**Changes**: Renumber subsequent guidelines

Current guideline "5. **Track Progress**:" becomes "6. **Track Progress**:"
Current guideline "6. **No Open Questions in Final Plan**:" becomes "7. **No Open Questions in Final Plan**:"

### Success Criteria:

#### Automated Verification:
- [x] Command file is valid markdown: `make check`
- [x] Guideline numbering is sequential
- [x] No broken references

#### Manual Verification:
- [ ] Enhanced "Be Practical" guideline emphasizes small safe steps
- [ ] New "Lean Delivery Philosophy" guideline is actionable
- [ ] Examples are concrete and realistic
- [ ] Anti-patterns section helps identify what to avoid
- [ ] Learning vs Earning distinction is clear
- [ ] Guidance aligns with Eduardo Ferro's philosophy

---

## Phase 4: Add Linguistic Heuristics for Story Splitting **[Earning]**

### Overview
Add a new section that helps Claude identify when user requirements are too large and suggest splits using linguistic heuristics.

### Vertical Slice:
This phase delivers pattern recognition guidance that helps Claude automatically identify opportunities to split large requirements into smaller ones.

### Reversibility:
Easy - additive reference section, doesn't change core behavior.

### Changes Required:

#### 1. Add Linguistic Heuristics Section
**File**: `commands/create_plan.md`
**Changes**: Add new section after "## Sub-task Spawning Best Practices" (after line 463)

Insert new section:

```markdown
## Linguistic Heuristics for Identifying Large Scopes

When gathering requirements or reading tickets, watch for these linguistic patterns that signal the scope might be too large and should be split:

### 1. Coordinating Conjunctions (and, or, but, yet, nor...)
**Signal**: Multiple distinct capabilities in one request

**Example**:
- Request: "Users can upload and download files"
- **Split into**:
  - Phase 1: Upload files (smaller, delivers value)
  - Phase 2: Download files (builds on storage from Phase 1)

**Action**: Propose splitting into separate vertical slices, deliver one first.

---

### 2. Action-Related Connectors (manage, handle, support, process, maintain, administer...)
**Signal**: Generic verbs hiding multiple operations

**Example**:
- Request: "Admins can manage users"
- **Reveals**: Create, read, update, delete, assign roles, deactivate
- **Split into**:
  - Phase 1: View users (read-only, safest)
  - Phase 2: Create new users (write capability)
  - Phase 3: Edit user details (update)
  - Phase 4: Deactivate users (soft delete)

**Action**: Ask user to clarify which specific operations are needed, prioritize by value and risk.

---

### 3. Sequence Connectors (before, after, then, while, during, when...)
**Signal**: Multi-step process that can be delivered incrementally

**Example**:
- Request: "Users can save their work before submitting"
- **Split into**:
  - Phase 1: Save work (provides value immediately)
  - Phase 2: Submit work (builds on save capability)

**Action**: Deliver earlier steps first, validate workflow before completing sequence.

---

### 4. Scope Indicators (including, as-well-as, along with, also, additionally, plus, with...)
**Signal**: Extra requirements that can be separated

**Example**:
- Request: "Send notifications via email and SMS"
- **Split into**:
  - Phase 1: Email notifications (simpler, more common)
  - Phase 2: SMS notifications (additional channel)

**Action**: Deliver core capability first, add extra channels/formats later.

---

### 5. Option Indicators (either/or, whether, alternatively, optionally...)
**Signal**: Multiple paths or features, each can be separate

**Example**:
- Request: "Users can log in with password or with Google"
- **Split into**:
  - Phase 1: Password login (traditional, well-understood)
  - Phase 2: Google OAuth login (additional option)

**Action**: Deliver one path first, add alternatives after validation.

---

### 6. Exception Indicators (except, unless, however, although, despite...)
**Signal**: Edge cases or special rules to handle separately

**Example**:
- Request: "Users can delete their account unless they are an admin"
- **Split into**:
  - Phase 1: Account deletion for regular users
  - Phase 2: Admin account protection rules

**Action**: Handle happy path first, add exception handling in later phase.

---

### How to Use These Heuristics:

**During context gathering (Step 1)**:
1. Read user's request carefully
2. Highlight conjunctions and connectors
3. Count distinct capabilities mentioned
4. If 3+ capabilities → Propose splitting

**When presenting understanding (Step 1, section 5)**:
```
Based on your request, I notice several distinct capabilities:
1. [Capability 1 from "and"]
2. [Capability 2 from "and"]
3. [Capability 3 from "also"]

I recommend delivering these incrementally:
- Phase 1 (minimal): [Capability 1] - delivers core value
- Phase 2 (enhanced): [Capability 2] - builds on Phase 1
- Phase 3 (complete): [Capability 3] - completes vision

This allows faster feedback and reduces risk. Does this approach work for you?
```

**Benefits**:
- Smaller, clearer, more testable increments
- Faster delivery of initial value
- Easier to validate assumptions early
- Reduced risk of building wrong thing
- Better alignment with TDD and lean delivery
```

### Success Criteria:

#### Automated Verification:
- [x] Command file is valid markdown: `make check`
- [x] No syntax errors

#### Manual Verification:
- [x] All six linguistic heuristic categories covered
- [x] Examples are clear and realistic
- [x] Guidance on how to use heuristics is actionable
- [x] Integration with existing steps is clear
- [x] Benefits are well-articulated

---

## Phase 5: Update Documentation and Examples **[Earning]**

### Overview
Update project documentation to reflect the enhanced planning approach with vertical slicing and small safe steps.

### Vertical Slice:
This phase delivers updated documentation that helps users understand and leverage the new planning capabilities.

### Reversibility:
Easy - documentation only, can be reverted or refined anytime.

### Changes Required:

#### 1. Update CLAUDE.md
**File**: `CLAUDE.md`
**Changes**: Document the vertical slicing enhancement

In the "## Plugin Structure" or a new "## Planning Philosophy" section, add:

```markdown
## Planning Philosophy

The `create_plan` command emphasizes **vertical slicing** and **small safe steps** based on Eduardo Ferro's lean delivery philosophy.

### Key Principles:

1. **Vertical Slicing** (Hamburger Method):
   - Identify technical layers (input → processing → storage → delivery)
   - Define quality attributes (simplest → most robust) for each layer
   - Compose minimal vertical slices that deliver real user value
   - Iterate to enhance quality and scope

2. **Small Safe Steps**:
   - Each phase delivers working functionality
   - Favor reversible changes (feature flags, parallel writes, gradual rollouts)
   - Postpone irreversible decisions until more information is available
   - Separate learning (time-boxed research) from earning (value delivery)

3. **Progressive Delivery Patterns**:
   - Dummy → Dynamic (hardcoded → real data)
   - Backend-only → Full Stack (API → UI)
   - Limited Scope → Full Feature (one segment/format → many)
   - Manual → Automated (prove value → automate)
   - Feature Flagged Rollout (team → beta → all)

4. **Eduardo Ferro's Leadership Philosophy**:
   - "Can we avoid doing it?" - Challenge necessity
   - "Can we achieve the same impact with fewer resources?" - Maximize impact, minimize effort
   - "What if we only had half the time?" - Force prioritization
   - "If you had to ship by tomorrow, what would you build?" - Identify minimum viable deliverable
   - "What's the worst that could happen?" - Evaluate risk realistically for safe experiments

### Planning Process:

The enhanced planning flow includes:
1. Context gathering (read files, spawn research agents)
2. **Vertical slicing analysis** (new - Hamburger Method, complexity assessment)
3. Plan structure development (based on vertical slices)
4. Detailed plan writing (with Learning/Earning phases, reversibility notes)
5. Review and iteration

### Plan Structure:

Plans now include:
- **Vertical Slicing Analysis**: Layers, quality attributes, slice options, complexity assessment
- **Progressive Delivery Pattern**: Specific pattern chosen and rollout strategy
- **Decisions and Postponements**: What's decided now vs later
- **Phases with Learning/Earning tags**: Each phase classified by type
- **Reversibility notes**: How to undo or compensate for each phase
- **Success criteria**: Still separated into automated vs manual

This approach ensures plans are incremental, testable, and aligned with TDD and lean delivery principles.
```

#### 2. Update README.md (if applicable)
**File**: `README.md`
**Changes**: Mention vertical slicing in features or usage section

If README.md has a Features section, update it:

```markdown
### Enhanced Planning with Vertical Slicing

The `create_plan` command guides you through creating implementation plans that emphasize:
- **Small safe steps** using the Hamburger Method for vertical slicing
- **Progressive delivery** patterns (dummy → dynamic, backend-only → full stack, etc.)
- **Learning vs Earning** phases to separate research from value delivery
- **Complexity assessment** to guide implementation decisions
- **Reversibility** and rollback strategies for each phase

Plans are created interactively, with vertical slicing analysis before committing to detailed phases.
```

#### 3. Add Example to Documentation
**File**: Create new example file `thoughts/shared/examples/vertical-slicing-example.md` (or add to existing docs)

Create a concrete example showing before/after:

```markdown
# Vertical Slicing Example: User Favorites Feature

## Original Request (Before Enhancement)

"Add a favorites feature so users can bookmark items and see them in a favorites list. They should be able to add and remove favorites, and favorites should sync across devices."

## Traditional Approach (Large Phases)

❌ **Phase 1**: Database schema and API
❌ **Phase 2**: Frontend UI components
❌ **Phase 3**: Sync logic for multi-device
❌ **Phase 4**: Testing and edge cases

**Problems**:
- No user-facing value until Phase 2 or 3
- Large, risky changes
- Sync complexity added early (might not be needed)

## Vertical Slicing Approach (Small Safe Steps)

### Vertical Slicing Analysis:

**Layers**:
1. Storage (where favorites are saved)
2. Add/Remove logic (how users interact)
3. Display (showing favorites list)
4. Sync (multi-device consistency)

**Quality Attributes**:
- Storage: localStorage → database → distributed cache
- Add/Remove: Client-side only → API calls → Optimistic updates
- Display: Simple list → Filtered → Sorted with metadata
- Sync: None → Polling → Real-time

**Vertical Slice Options**:

**Slice 1 (Minimal - ship tomorrow):**
- Storage: localStorage
- Add/Remove: Click handler
- Display: Simple list
- Sync: None (single device)
- **Learning value**: Do users actually use this? How often?
- **User value**: Can bookmark items immediately
- **Time**: 4 hours

**Slice 2 (Enhanced):**
- Storage: Backend database
- Add/Remove: API calls
- Display: Same
- Sync: None (but data in backend enables future sync)
- **Learning value**: API performance, usage patterns
- **Builds on**: Slice 1 validated user need

**Slice 3 (Complete):**
- Storage: Same
- Add/Remove: Optimistic updates
- Display: Sorted with metadata
- Sync: Polling (load from backend on login)
- **Completes**: Multi-device support

### Implementation Plan:

✅ **Phase 1: Frontend-Only Favorites [Earning]**
- localStorage for favorites
- Add/remove buttons
- Simple list view
- **No backend needed**
- **Reversibility**: Easy - feature flag or remove JS
- **Success**: Users can favorite items, see list
- **Learning**: Usage patterns, feature adoption

✅ **Phase 2: Backend Persistence [Earning]**
- API endpoints for favorites
- Database schema
- Migrate localStorage to backend on login
- **Builds on**: Validated user need from Phase 1
- **Reversibility**: Keep localStorage fallback if API fails
- **Success**: Data persists across sessions
- **Learning**: API performance, data volume

✅ **Phase 3: Multi-Device Sync [Earning]**
- Polling for updates
- Conflict resolution (simple: last-write-wins)
- **Builds on**: Backend infrastructure from Phase 2
- **Reversibility**: Feature flag to disable sync
- **Success**: Favorites available on all devices
- **Learning**: Sync frequency needs, conflict scenarios

### Progressive Delivery Pattern: Frontend-Only → Backend → Sync

### Decisions Postponed:
- Real-time sync (WebSockets) - wait to see if polling is sufficient
- Advanced conflict resolution - wait to see if it's needed
- Favorites categories/organization - wait to see usage patterns

## Outcome

**Before**: 3-4 large phases, weeks before user value, high risk

**After**: 3 small vertical slices, user value in hours, validated at each step

This is vertical slicing with small safe steps in action.
```

### Success Criteria:

#### Automated Verification:
- [x] All documentation files are valid markdown: `make check`
- [x] No broken links

#### Manual Verification:
- [ ] CLAUDE.md accurately describes the planning philosophy
- [ ] README.md mentions vertical slicing in features
- [ ] Example demonstrates before/after clearly
- [ ] Documentation is accessible and helpful
- [ ] All references are correct

---

## Testing Strategy

### Manual Testing Steps:

1. **Test Enhanced Planning Command:**
   - Invoke `/stepwise-dev:create_plan "Add user favorites feature"`
   - Verify Step 2.5 (Vertical Slicing Analysis) executes
   - Check that Hamburger Method questions are asked
   - Confirm Eduardo Ferro's prompts appear
   - Validate complexity assessment is performed
   - Verify progressive delivery pattern is suggested

2. **Test Plan Template:**
   - Complete a full planning cycle
   - Verify generated plan includes new sections:
     - Vertical Slicing Analysis
     - Learning/Earning phase tags
     - Reversibility notes
     - Progressive delivery pattern
   - Check that success criteria format is preserved (automated vs manual)

3. **Test Linguistic Heuristics:**
   - Provide request with conjunctions: "Users can upload and download and share files"
   - Verify Claude identifies splitting opportunities
   - Check that vertical slices are proposed

4. **Test Learning vs Earning:**
   - Plan a feature with uncertainty
   - Verify Learning phases are time-boxed with clear questions
   - Verify Earning phases focus on user value
   - Check that Learning comes before Earning

5. **Test Progressive Delivery Patterns:**
   - Plan features that match each pattern
   - Verify appropriate pattern is suggested
   - Check that rationale is provided

### Validation Checks:

For each test:
- ✓ Command file executes without errors
- ✓ New steps integrate smoothly with existing flow
- ✓ Interactive planning process is preserved
- ✓ Plans emphasize small safe steps
- ✓ Vertical slicing analysis is thorough but not overwhelming
- ✓ Documentation is clear and helpful
- ✓ Examples are realistic and actionable

## Performance Considerations

**Planning session length:**
- Additional vertical slicing analysis adds one interactive step
- Expected increase: 2-5 minutes for analysis and user feedback
- Benefit: Plans are smaller and more focused, reducing implementation time significantly

**Token usage:**
- Vertical slicing analysis: ~1500-2000 tokens
- Enhanced template sections: ~500 tokens per plan
- Progressive delivery patterns reference: ~1000 tokens (one-time)
- Total increase: ~2000-3000 tokens per planning session
- Still well within context limits

**User experience:**
- More interactive (additional questions at Step 2.5)
- Better guidance (Eduardo Ferro's prompts)
- Clearer outcomes (vertical slices are concrete and demonstrable)
- Faster value delivery (smaller phases)

## Migration Notes

**Backward compatibility:**
- Existing plans are not affected (template changes only apply to new plans)
- Commands that reference plans continue to work
- Thoughts directory structure unchanged
- No migration of existing plans required

**For users:**
- Planning sessions will have one additional step (vertical slicing analysis)
- Plans will be more detailed in vertical slicing analysis section
- Phases will be smaller and more incremental
- Success criteria format remains the same
- Learning curve: minimal - guidance is built into the process

**For existing workflows:**
- `/stepwise-dev:create_plan` flow adds Step 2.5 but remains interactive
- `/stepwise-dev:implement_plan` works with new plan format unchanged
- `/stepwise-dev:validate_plan` works with new success criteria format
- No breaking changes to any workflows

## References

- Knowledge base source: `~/mordor/personal/eferro-lean-delivery-agent/knowledge-base/`
  - `philosophy.md` - Eduardo Ferro's core principles
  - `user_story_split.md` - User story splitting heuristics
  - `hamburger_method.md` - The Hamburger Method for vertical slicing
  - `complexity_dimensions.md` - Complexity assessment factors
  - `progressive_delivery_conversations.md` - Progressive delivery examples
  - `leadership_philosophy.md` - Eduardo Ferro's leadership phrases
  - `examples.md` - Small safe steps examples
  - `anti_patterns.md` - Anti-patterns to avoid
- Modified command: `commands/create_plan.md`
- Project guidelines: `CLAUDE.md`, `README.md`
- Existing plan example: `thoughts/shared/plans/2025-11-13-prevent-6000-token-limit-error.md`
