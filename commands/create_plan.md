---
description: Create detailed implementation plans through interactive research and iteration
argument-hint: [ticket-file-path or task description]
---

<!-- SPDX-License-Identifier: Apache-2.0
     SPDX-FileCopyrightText: 2024 humanlayer Authors (original)
     SPDX-FileCopyrightText: 2025 Jorge Castro (modifications) -->

# Implementation Plan

You are tasked with creating detailed implementation plans through an interactive, iterative process. You should be skeptical, thorough, and work collaboratively with the user to produce high-quality technical specifications.

## Initial Response

When this command is invoked:

**Input**: $ARGUMENTS

1. **Check if parameters were provided via $ARGUMENTS**:
   - If $ARGUMENTS contains a file path (e.g., `thoughts/nikey_es/tickets/eng_1234.md`), skip the default message
   - Immediately read any provided files FULLY
   - Begin the research process
   - If $ARGUMENTS contains a task description (not a file path), use it as context for planning

2. **If $ARGUMENTS is empty**, respond with:
```
I'll help you create a detailed implementation plan. Let me start by understanding what we're building.

Please provide:
1. The task/ticket description (or reference to a ticket file)
2. Any relevant context, constraints, or specific requirements
3. Links to related research or previous implementations

I'll analyze this information and work with you to create a comprehensive plan.

Tip: You can also invoke this command with a ticket file directly: `/stepwise-dev:create_plan thoughts/nikey_es/tickets/eng_1234.md`
For deeper analysis, try: `/stepwise-dev:create_plan think deeply about thoughts/nikey_es/tickets/eng_1234.md`
```

Then wait for the user's input.

## Process Steps

### Step 1: Context Gathering & Initial Analysis

1. **Read all mentioned files immediately and FULLY**:
   - Ticket files (e.g., `thoughts/nikey_es/tickets/eng_1234.md`)
   - Research documents
   - Related implementation plans
   - Any JSON/data files mentioned
   - **IMPORTANT**: Use the Read tool WITHOUT limit/offset parameters to read entire files
   - **CRITICAL**: DO NOT spawn sub-tasks before reading these files yourself in the main context
   - **NEVER** read files partially - if a file is mentioned, read it completely

2. **Spawn initial research tasks to gather context**:
   Before asking the user any questions, use specialized agents to research in parallel:

   - Use the **stepwise-dev:codebase-locator** agent to find all files related to the ticket/task
   - Use the **stepwise-dev:codebase-analyzer** agent to understand how the current implementation works
   - If relevant, use the **stepwise-dev:thoughts-locator** agent to find any existing thoughts documents about this feature

   These agents will:
   - Find relevant source files, configs, and tests
   - Identify the specific directories to focus on (e.g., if the frontend is mentioned, they'll focus on frontend/ or web/)
   - Trace data flow and key functions
   - Return detailed explanations with file:line references

3. **Read all files identified by research tasks**:
   - After research tasks complete, read ALL files they identified as relevant
   - Read them FULLY into the main context
   - This ensures you have complete understanding before proceeding

4. **Analyze and verify understanding**:
   - Cross-reference the ticket requirements with actual code
   - Identify any discrepancies or misunderstandings
   - Note assumptions that need verification
   - Determine true scope based on codebase reality

5. **Present informed understanding and focused questions**:
   ```
   Based on the ticket and my research of the codebase, I understand we need to [accurate summary].

   I've found that:
   - [Current implementation detail with file:line reference]
   - [Relevant pattern or constraint discovered]
   - [Potential complexity or edge case identified]

   Questions that my research couldn't answer:
   - [Specific technical question that requires human judgment]
   - [Business logic clarification]
   - [Design preference that affects implementation]
   ```

   Only ask questions that you genuinely cannot answer through code investigation.

### Step 2: Research & Discovery

After getting initial clarifications:

1. **If the user corrects any misunderstanding**:
   - DO NOT just accept the correction
   - Spawn new research tasks to verify the correct information
   - Read the specific files/directories they mention
   - Only proceed once you've verified the facts yourself

2. **Create a research todo list** using TodoWrite to track exploration tasks

3. **Spawn parallel sub-tasks for comprehensive research**:
   - Create multiple Task agents to research different aspects concurrently
   - Use the right agent for each type of research:

   **For deeper investigation:**
   - **stepwise-dev:codebase-locator** - To find more specific files (e.g., "find all files that handle [specific component]")
   - **stepwise-dev:codebase-analyzer** - To understand implementation details (e.g., "analyze how [system] works")
   - **stepwise-dev:codebase-pattern-finder** - To find similar features we can model after

   **For historical context:**
   - **stepwise-dev:thoughts-locator** - To find any research, plans, or decisions about this area
   - **stepwise-dev:thoughts-analyzer** - To extract key insights from the most relevant documents

   Each agent knows how to:
   - Find the right files and code patterns
   - Identify conventions and patterns to follow
   - Look for integration points and dependencies
   - Return specific file:line references
   - Find tests and examples

3. **Wait for ALL sub-tasks to complete** before proceeding

4. **Present findings and design options**:
   ```
   Based on my research, here's what I found:

   **Current State:**
   - [Key discovery about existing code]
   - [Pattern or convention to follow]

   **Design Options:**
   1. [Option A] - [pros/cons]
   2. [Option B] - [pros/cons]

   **Open Questions:**
   - [Technical uncertainty]
   - [Design decision needed]

   Which approach aligns best with your vision?
   ```

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

### Step 4: Detailed Plan Writing

After structure approval:

1. **Initialize thoughts directory if needed:**
   - Check if `thoughts/` directory exists
   - If it doesn't exist, use the thoughts-management Skill to initialize it:
     ```bash
     bash ${CLAUDE_PLUGIN_ROOT}/skills/thoughts-management/scripts/thoughts-init
     ```
   - This creates the complete directory structure for organizing plans

2. **Write the plan** to `thoughts/shared/plans/YYYY-MM-DD-ENG-XXXX-description.md`
   - Format: `YYYY-MM-DD-ENG-XXXX-description.md` where:
     - YYYY-MM-DD is today's date
     - ENG-XXXX is the ticket number (omit if no ticket)
     - description is a brief kebab-case description
   - Examples:
     - With ticket: `2025-01-08-ENG-1478-parent-child-tracking.md`
     - Without ticket: `2025-01-08-improve-error-handling.md`

3. **Use this template structure**:

````markdown
# [Feature/Task Name] Implementation Plan

## Overview

[Brief description of what we're implementing and why]

## Current State Analysis

[What exists now, what's missing, key constraints discovered]

## Desired End State

[A Specification of the desired end state after this plan is complete, and how to verify it]

### Key Discoveries:
- [Important finding with file:line reference]
- [Pattern to follow]
- [Constraint to work within]

## What We're NOT Doing

[Explicitly list out-of-scope items to prevent scope creep]

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

[High-level strategy and reasoning based on vertical slicing analysis]

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

## Phase 2: [Descriptive Name] **[Learning/Earning]**

[Similar structure with vertical slice, type, reversibility, and success criteria...]

---

## Testing Strategy

### Unit Tests:
- [What to test]
- [Key edge cases]

### Integration Tests:
- [End-to-end scenarios]

### Manual Testing Steps:
1. [Specific step to verify feature]
2. [Another verification step]
3. [Edge case to test manually]

## Performance Considerations

[Any performance implications or optimizations needed]

## Migration Notes

[If applicable, how to handle existing data/systems]

## References

- Original ticket: `thoughts/nikey_es/tickets/eng_XXXX.md`
- Related research: `thoughts/shared/research/[relevant].md`
- Similar implementation: `[file:line]`
````

### Step 5: Sync and Review

1. **Sync the thoughts directory**:
   - Use the thoughts-management Skill to sync the newly created plan
   - This ensures the plan is properly indexed and available

2. **Present the draft plan location**:
   ```
   I've created the initial implementation plan at:
   `thoughts/shared/plans/YYYY-MM-DD-ENG-XXXX-description.md`

   Please review it and let me know:
   - Are the phases properly scoped?
   - Are the success criteria specific enough?
   - Any technical details that need adjustment?
   - Missing edge cases or considerations?
   ```

3. **Iterate based on feedback** - be ready to:
   - Add missing phases
   - Adjust technical approach
   - Clarify success criteria (both automated and manual)
   - Add/remove scope items
   - After making changes, use the thoughts-management Skill to sync again

4. **Continue refining** until the user is satisfied

5. **When plan is finalized**, inform the user:
   ```
   ✓ Implementation plan complete: `thoughts/shared/plans/[filename].md`

   Next steps in the workflow:
   - Review and approve the plan
   - Use `/stepwise-dev:implement_plan thoughts/shared/plans/[filename].md` to execute it
   - Or use `/stepwise-dev:iterate_plan thoughts/shared/plans/[filename].md [changes]` to refine further

   💡 Tip: Use `/clear` to free up context before starting implementation
   ```

## Important Guidelines

1. **Be Skeptical**:
   - Question vague requirements
   - Identify potential issues early
   - Ask "why" and "what about"
   - Don't assume - verify with code

2. **Be Interactive**:
   - Don't write the full plan in one shot
   - Get buy-in at each major step
   - Allow course corrections
   - Work collaboratively

3. **Be Thorough**:
   - Read all context files COMPLETELY before planning
   - Research actual code patterns using parallel sub-tasks
   - Include specific file paths and line numbers
   - Write measurable success criteria with clear automated vs manual distinction
   - automated steps should use `make` whenever possible - for example `make -C frontend check` instead of `cd frontend && npm run fmt`

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

6. **Track Progress**:
   - Use TodoWrite to track planning tasks
   - Update todos as you complete research
   - Mark planning tasks complete when done

7. **No Open Questions in Final Plan**:
   - If you encounter open questions during planning, STOP
   - Research or ask for clarification immediately
   - Do NOT write the plan with unresolved questions
   - The implementation plan must be complete and actionable
   - Every decision must be made before finalizing the plan

## Success Criteria Guidelines

**CRITICAL RULE FOR TDD PROJECTS:**
- If a phase writes/runs automated tests → NO "Manual Verification" section needed
- If it can be tested with code (`assert X == Y`) → It MUST be an automated test
- Manual verification is ONLY for subjective qualities (aesthetics, "feel", human judgment)

**Always separate success criteria into two categories:**

1. **Automated Verification** (can be run by execution agents):
   - Commands: `make test`, `pytest -v`, `npm run lint`, etc.
   - Files should exist, code compiles, tests pass

2. **Manual Verification** (RARELY needed in TDD):
   - Visual appearance requiring aesthetic judgment
   - Subjective UX ("does it feel responsive?")
   - Real assistive technology testing (screen readers)
   - Cross-browser visual compatibility

**INVALID Manual Verification (write tests instead):**
- ❌ "Review test output" → Redundant, covered by automated
- ❌ "Verify function returns correct value" → Should be unit test
- ❌ "Test with input X produces output Y" → Should be test
- ❌ "Confirm calculation is correct" → Should be unit test

**Format examples:**

Example 1 - TDD Test Phase (NO manual verification):
```markdown
### Success Criteria:
- [ ] All tests pass: `pytest tests/ -v`
- [ ] No linting errors: `pylint src/`
```

Example 2 - Web UI Feature (justified manual verification):
```markdown
### Success Criteria:

#### Automated Verification:
- [ ] Component tests pass: `npm test components/Button`
- [ ] E2E tests pass: `playwright test button.spec.ts`

#### Manual Verification:
- [ ] Button animation feels smooth (subjective)
- [ ] Visual appearance matches mockup (aesthetic judgment)
```

## Common Patterns

### For Database Changes:
- Start with schema/migration
- Add store methods
- Update business logic
- Expose via API
- Update clients

### For New Features:
- Research existing patterns first
- Start with data model
- Build backend logic
- Add API endpoints
- Implement UI last

### For Refactoring:
- Document current behavior
- Plan incremental changes
- Maintain backwards compatibility
- Include migration strategy

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

## Sub-task Spawning Best Practices

When spawning research sub-tasks:

1. **Spawn multiple tasks in parallel** for efficiency
2. **Each task should be focused** on a specific area
3. **Provide detailed instructions** including:
   - Exactly what to search for
   - Which directories to focus on
   - What information to extract
   - Expected output format
4. **Be EXTREMELY specific about directories**:
   - If the ticket mentions "frontend" or "web UI", specify `frontend/` or `web/` directory
   - If it mentions "backend" or "API", specify `backend/` or `api/` directory
   - Never use generic terms - always specify the exact directory structure
   - Include the full path context in your prompts
5. **Specify read-only tools** to use
6. **Request specific file:line references** in responses
7. **Wait for all tasks to complete** before synthesizing
8. **Verify sub-task results**:
   - If a sub-task returns unexpected results, spawn follow-up tasks
   - Cross-check findings against the actual codebase
   - Don't accept results that seem incorrect

Example of spawning multiple tasks:
```python
# Spawn these tasks concurrently:
tasks = [
    Task("Research database schema", db_research_prompt),
    Task("Find API patterns", api_research_prompt),
    Task("Investigate UI components", ui_research_prompt),
    Task("Check test patterns", test_research_prompt)
]
```

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

## Example Interaction Flow

```
User: /implementation_plan
Assistant: I'll help you create a detailed implementation plan...

User: We need to add parent-child tracking for Claude sub-tasks. See thoughts/nikey_es/tickets/eng_1478.md
Assistant: Let me read that ticket file completely first...

[Reads file fully]

Based on the ticket, I understand we need to track parent-child relationships for Claude sub-task events in the hld daemon. Before I start planning, I have some questions...

[Interactive process continues...]
```
