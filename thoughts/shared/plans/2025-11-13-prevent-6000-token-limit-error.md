# Prevent 6000 Token Limit Error in research_codebase Command

## Overview

The `/stepwise-dev:research_codebase` command currently hits the 6000 output token maximum during Step 4 when synthesizing and presenting research findings inline. This plan implements incremental file writes to avoid the token limit by writing research findings progressively to a markdown file and only presenting concise progress updates to the user.

## Current State Analysis

**What exists now:**
- `/stepwise-dev:research_codebase` command at `commands/research_codebase.md`
- Current flow:
  1. Read mentioned files (Step 1)
  2. Spawn parallel research agents (Step 2-3)
  3. Wait for all agents to complete (Step 4)
  4. **Synthesize ALL findings inline** ← Token limit hit here
  5. Gather metadata (Step 5-6)
  6. Write complete research document (Step 7)
  7. Sync and present summary (Step 8-9)

**The problem:**
- Step 4 synthesizes all agent findings in Claude's response (commands/research_codebase.md:74-83)
- When agents return large outputs (e.g., codebase-analyzer with detailed traces, pattern-finder with code examples), the combined synthesis exceeds 6000 tokens
- Current pattern: Collect everything → Present everything → Write to file
- Need: Collect → Write incrementally → Present summaries only

**Key constraints discovered:**
- Research documents have structured format with YAML frontmatter (lines 107-163)
- Must maintain backward compatibility with existing workflow
- Must still use thoughts-management Skill for sync
- File path format must remain: `thoughts/shared/research/YYYY-MM-DD-[ENG-XXXX-]description.md`

## Desired End State

After this plan is complete:
1. The `/stepwise-dev:research_codebase` command will write research findings incrementally to avoid token limits
2. Users will see concise progress updates instead of full synthesis
3. The final research document format remains unchanged
4. All existing commands continue to work with the new approach

### Success Criteria:
- [ ] Research command handles large agent outputs without hitting 6000 token limit: `make test` (if we add tests)
- [ ] Generated research documents match existing format exactly
- [ ] Incremental writes preserve markdown structure and frontmatter
- [ ] Sync operations work correctly with incrementally written files

## What We're NOT Doing

- Not modifying other commands (`create_plan`, `iterate_plan`, etc.) - only `research_codebase`
- Not changing the research document format or template
- Not altering how agents return their findings
- Not modifying the thoughts-management Skill scripts
- Not changing file naming conventions or directory structure
- Not adding new configuration options or environment variables

## Implementation Approach

**Strategy: Early File Creation with Incremental Appends**

Instead of synthesizing everything inline and then writing once, we'll:
1. Create the research file early (after gathering metadata but before spawning agents)
2. Write frontmatter and initial sections immediately
3. As each research phase completes, append findings to the file
4. Present only brief progress messages to the user
5. Sync at the end as before

This approach:
- Eliminates large inline presentations
- Maintains document structure integrity
- Allows user to monitor progress via file updates
- Preserves backward compatibility

## Phase 1: Restructure Research Document Creation

### Overview
Modify the research_codebase command to create the research file early and write incrementally throughout the research process.

### Changes Required:

#### 1. Reorganize Command Steps
**File**: `commands/research_codebase.md`
**Changes**: Restructure steps to create file early and write incrementally

**Current order** (lines 36-191):
1. Read mentioned files
2. Analyze and decompose
3. Spawn agents
4. **Wait and synthesize all findings** ← Inline presentation
5. Initialize thoughts dir
6. Gather metadata
7. **Generate research document** ← Single write
8. Add GitHub links
9. Sync and present

**New order:**
1. Read mentioned files
2. Analyze and decompose
3. **Initialize thoughts dir** (moved up)
4. **Gather metadata** (moved up)
5. **Create research file with frontmatter and skeleton** (new step)
6. Spawn agents
7. **As each agent completes, append findings to file** (modified)
8. **Write final sections** (Open Questions, Related Research)
9. Add GitHub links
10. Sync and present

Edit the command file to reflect this new order.

#### 2. Early File Creation Section
**File**: `commands/research_codebase.md`
**Changes**: Add new step after "Analyze and decompose" (currently line 44)

Insert new step between current Step 2 and Step 3:

```markdown
3. **Initialize thoughts directory and create research file:**
   - Check if `thoughts/` directory exists
   - If it doesn't exist, use the thoughts-management Skill to initialize it:
     ```bash
     bash ${CLAUDE_PLUGIN_ROOT}/skills/thoughts-management/scripts/thoughts-init
     ```

4. **Gather metadata and create research file skeleton:**
   - Use the thoughts-management Skill to generate metadata:
     ```bash
     bash ${CLAUDE_PLUGIN_ROOT}/skills/thoughts-management/scripts/thoughts-metadata
     ```
   - Generate filename: `thoughts/shared/research/YYYY-MM-DD-[ENG-XXXX-]description.md`
     - Format: `YYYY-MM-DD-ENG-XXXX-description.md` where:
       - YYYY-MM-DD is today's date
       - ENG-XXXX is the ticket number (omit if no ticket)
       - description is a brief kebab-case description of the research topic
     - Examples:
       - With ticket: `2025-01-08-ENG-1478-parent-child-tracking.md`
       - Without ticket: `2025-01-08-authentication-flow.md`

   - Write initial research document structure to the file:
     ```markdown
     ---
     date: [ISO datetime from metadata]
     researcher: [Git user from metadata]
     git_commit: [Commit hash from metadata]
     branch: [Branch name from metadata]
     repository: [Repository name from metadata]
     topic: "[User's Question/Topic]"
     tags: [research, codebase, relevant-component-names]
     status: in-progress
     last_updated: [Date short from metadata]
     last_updated_by: [Git user from metadata]
     ---

     # Research: [User's Question/Topic]

     **Date**: [Current date and time with timezone from metadata]
     **Researcher**: [Git user from metadata]
     **Git Commit**: [Commit hash from metadata]
     **Branch**: [Branch name from metadata]
     **Repository**: [Repository name from metadata]

     ## Research Question
     [Original user query]

     ## Summary
     [To be completed after research]

     ## Detailed Findings

     [Findings will be appended as research progresses]

     ## Code References

     [References will be added as discovered]

     ## Architecture Documentation

     [To be completed after research]

     ## Historical Context (from thoughts/)

     [To be completed if relevant thoughts found]

     ## Related Research

     [To be completed at end]

     ## Open Questions

     [To be completed at end]
     ```

   - Present file creation to user:
     ```
     Research document created: `thoughts/shared/research/[filename].md`

     I'll update this file incrementally as research progresses.
     ```
```

#### 3. Incremental Findings Append
**File**: `commands/research_codebase.md`
**Changes**: Modify Step 4 (currently "Wait for all sub-agents...") at lines 74-83

Replace current step with:

```markdown
5. **Spawn parallel sub-agent tasks for comprehensive research:**
   - Create multiple Task agents to research different aspects concurrently
   - We now have specialized agents that know how to do specific research tasks:

   **For codebase research:**
   - Use the **stepwise-dev:codebase-locator** agent to find WHERE files and components live
   - Use the **stepwise-dev:codebase-analyzer** agent to understand HOW specific code works (without critiquing it)
   - Use the **stepwise-dev:codebase-pattern-finder** agent to find examples of existing patterns (without evaluating them)

   **IMPORTANT**: All agents are documentarians, not critics. They will describe what exists without suggesting improvements or identifying issues.

   **For thoughts directory:**
   - Use the **stepwise-dev:thoughts-locator** agent to discover what documents exist about the topic
   - Use the **stepwise-dev:thoughts-analyzer** agent to extract key insights from specific documents (only the most relevant ones)

   The key is to use these agents intelligently:
   - Start with locator agents to find what exists
   - Then use analyzer agents on the most promising findings to document how they work
   - Run multiple agents in parallel when they're searching for different things
   - Each agent knows its job - just tell it what you're looking for
   - Don't write detailed prompts about HOW to search - the agents already know
   - Remind agents they are documenting, not evaluating or improving

6. **As each agent completes, append findings to the research file:**
   - IMPORTANT: As soon as an agent returns results, append them to the research document
   - DO NOT wait for all agents to complete before writing
   - DO NOT present full agent findings inline to the user

   For each completed agent:

   a. **Append codebase findings to "Detailed Findings" section:**
      - Use the Edit tool to locate the `## Detailed Findings` section
      - Append a new subsection with the agent's findings:
        ```markdown

        ### [Component/Area Name]
        [Agent's findings with file:line references]
        - Description of what exists ([file.ext:line](link))
        - How it connects to other components
        - Current implementation details (without evaluation)
        ```

   b. **Append code references to "Code References" section:**
      - Use the Edit tool to locate the `## Code References` section
      - Append new references discovered by the agent:
        ```markdown
        - `path/to/file.ext:123` - Description of what's there
        - `another/file.ext:45-67` - Description of the code block
        ```

   c. **Append thoughts findings to "Historical Context" section (if applicable):**
      - If the agent found relevant thoughts documents, append to `## Historical Context (from thoughts/)`
      - Format:
        ```markdown
        - `thoughts/shared/something.md` - Historical decision about X
        - `thoughts/nikey_es/notes.md` - Past exploration of Y
        ```
      - Note: Paths exclude "searchable/" even if found there

   d. **Present brief progress message to user:**
      ```
      ✓ [Agent type] research complete
      - [1-2 line summary of what was found]
      - Findings appended to research document
      ```

   e. **Continue spawning and processing agents until all research areas are covered**

7. **After all agents complete, finalize the research document:**
   - Use the Edit tool to update the `## Summary` section with a high-level overview
   - Use the Edit tool to update the `## Architecture Documentation` section
   - Use the Edit tool to update the `## Open Questions` section (if any)
   - Use the Edit tool to update the `## Related Research` section (links to other docs)
   - Update the frontmatter `status` field from `in-progress` to `complete`
   - Present completion message:
     ```
     ✓ Research synthesis complete
     - Summary and architecture documentation added
     - All findings documented in research file
     ```
```

#### 4. Remove Old "Generate Research Document" Step
**File**: `commands/research_codebase.md`
**Changes**: Delete or significantly reduce old Step 7 (lines 104-163)

Since the document is now created early and updated incrementally, remove the old "Generate research document" step that did a single large write.

Keep only the GitHub permalink logic (currently lines 165-170) and sync step (currently lines 172-190).

#### 5. Update Final Sync and Presentation
**File**: `commands/research_codebase.md`
**Changes**: Simplify lines 172-190

Replace with:

```markdown
8. **Add GitHub permalinks (if applicable):**
   - Check if on main branch or if commit is pushed: `git branch --show-current` and `git status`
   - If on main/master or pushed, generate GitHub permalinks:
     - Get repo info: `gh repo view --json owner,name`
     - Create permalinks: `https://github.com/{owner}/{repo}/blob/{commit}/{file}#L{line}`
   - Use Edit tool to replace local file references with permalinks in the document

9. **Sync and present completion:**
   - Use the thoughts-management Skill to sync the thoughts directory:
     ```bash
     bash ${CLAUDE_PLUGIN_ROOT}/skills/thoughts-management/scripts/thoughts-sync
     ```
   - Present completion message:
     ```
     ✓ Research complete: `thoughts/shared/research/[filename].md`

     Key findings documented:
     - [Brief 1-2 line summary of main discoveries]
     - [File references for navigation]

     Next steps in the workflow:
     - Review the research document for full details
     - Use `/stepwise-dev:create_plan [task description]` to plan implementation based on findings
     - Ask follow-up questions if needed

     💡 Tip: Use `/clear` to free up context before planning or implementation
     ```
```

### Success Criteria:

#### Automated Verification:
- [ ] Command file syntax is valid markdown: `make check` (if markdown linting exists)
- [ ] No broken references in command file
- [ ] Shellcheck passes on any inline bash: `shellcheck commands/research_codebase.md` (if applicable)

#### Manual Verification:
- [ ] Read through modified command file and verify flow makes sense
- [ ] Check that all step numbers are sequential and references are correct
- [ ] Verify frontmatter template includes all required fields
- [ ] Confirm Edit tool usage is appropriate for incremental appends

---

## Phase 2: Test the Modified Command

### Overview
Validate that the modified research_codebase command works correctly with incremental writes and doesn't hit token limits.

### Changes Required:

#### 1. Create Test Research Query
**File**: Manual testing (no file changes)
**Changes**: Test the command with a query that previously hit the token limit

Test scenarios:
1. **Small research query** (baseline):
   - Query: "Where are error handlers defined?"
   - Expected: Single agent, small output, works fine

2. **Medium research query**:
   - Query: "How does the plugin system work?"
   - Expected: Multiple agents (locator, analyzer), moderate output, should work

3. **Large research query** (the critical test):
   - Query: "Document the complete command execution flow from invocation to completion"
   - Expected: Many agents (locator, analyzer, pattern-finder), large outputs, previously failed
   - Should now work with incremental writes

#### 2. Validation Checks During Testing
**File**: Manual observation
**Changes**: Verify behavior at each step

For each test:
1. **Verify file creation timing:**
   - Check that research file is created BEFORE agents are spawned
   - File should exist with skeleton structure immediately
   - Use: `ls -la thoughts/shared/research/` to confirm

2. **Verify incremental updates:**
   - After each agent completes, check the file contents
   - Use: `tail -n 50 thoughts/shared/research/[filename].md` to see latest additions
   - Confirm findings are being appended, not rewriting entire file

3. **Verify inline messages are concise:**
   - Claude's responses should be < 500 tokens each
   - Should show progress messages, not full synthesis
   - Should never see "API Error: Claude's response exceeded the 6000 output token maximum"

4. **Verify final document structure:**
   - Read complete research document
   - Check all sections are populated correctly
   - Verify frontmatter is complete and status is "complete"
   - Confirm code references are formatted correctly

#### 3. Edge Case Testing
**File**: Manual testing
**Changes**: Test edge cases and error conditions

Test cases:
1. **No agents return findings:**
   - Query about non-existent component
   - Should create file with skeleton, mark as complete with note in Open Questions

2. **Agents return errors:**
   - Invalid directory reference
   - Should document the error in Open Questions section

3. **Very large single agent output:**
   - Pattern-finder returns 20+ code examples
   - Should append to file without presenting inline
   - Should stay under token limit

4. **Follow-up research:**
   - Test the follow-up flow (commands/research_codebase.md:192-198)
   - Ensure incremental appends work for follow-ups too

### Success Criteria:

#### Automated Verification:
- [ ] All test queries complete without token limit errors
- [ ] Generated research files pass markdown validation (if linting exists)

#### Manual Verification:
- [ ] Small query generates complete research document
- [ ] Medium query shows incremental updates in file
- [ ] Large query (previously failing) now succeeds without token errors
- [ ] All inline messages stay under ~500 tokens
- [ ] Final research documents match expected format exactly
- [ ] Frontmatter fields are populated correctly (no placeholders)
- [ ] Edit tool successfully appends to sections without corrupting markdown
- [ ] Sync operation works correctly with incrementally written files
- [ ] Follow-up research appends correctly to existing documents

---

## Phase 3: Update Documentation

### Overview
Update project documentation to reflect the new incremental writing approach.

### Changes Required:

#### 1. Update CLAUDE.md
**File**: `CLAUDE.md`
**Changes**: Document the incremental writing pattern in relevant sections

At the "## Plugin Structure" section (around line 11), ensure it's clear this is for development guidance.

Add a new section after "## Development Workflow" (around line 149):

```markdown
## Command Output Management

### Token Limit Handling

Commands that generate large outputs use **incremental file writes** to avoid exceeding Claude Code's 6000 output token limit.

**Pattern: Early File Creation with Progressive Writes**

Instead of collecting all findings and presenting them inline before writing:
1. Create the output file early (after metadata gathering)
2. Write the document skeleton with frontmatter immediately
3. As each research phase completes, append findings to the file using Edit tool
4. Present only brief progress messages to the user (< 500 tokens each)
5. Sync at the end

**Commands using this pattern:**
- `/stepwise-dev:research_codebase` - Creates research file before spawning agents, appends findings incrementally

**Benefits:**
- Never hits 6000 token output limit, even with large research queries
- Users can monitor progress by reading the file
- Maintains document structure integrity
- Preserves backward compatibility with existing formats

**Implementation notes:**
- Use Edit tool for appends, not Write (preserves existing content)
- Update frontmatter `status` field: `in-progress` → `complete`
- Always sync after final updates using thoughts-management Skill
```

#### 2. Update README.md (if applicable)
**File**: `README.md`
**Changes**: Add note about token limit handling in Usage section

If README.md has a Usage or Features section, add a brief note:

```markdown
### Large Output Handling

The plugin handles large outputs efficiently to avoid token limits:
- Research documents are written incrementally as findings are discovered
- Only concise progress updates are shown during execution
- Full details are saved to `thoughts/` directory for review
```

### Success Criteria:

#### Automated Verification:
- [ ] Documentation files are valid markdown: `make check` (if linting exists)
- [ ] No broken internal links in documentation

#### Manual Verification:
- [ ] Documentation accurately describes the incremental writing pattern
- [ ] Examples are clear and helpful
- [ ] No outdated information about old single-write approach
- [ ] Links and references are correct

---

## Testing Strategy

### Manual Testing Steps:

1. **Baseline Test:**
   - Run `/stepwise-dev:research_codebase "Where are CLI commands defined?"`
   - Verify file is created early
   - Verify incremental updates occur
   - Verify no token limit error

2. **Large Query Test:**
   - Run `/stepwise-dev:research_codebase "Document the complete workflow from research to implementation including all commands, agents, and the thoughts management system"`
   - This should spawn many agents with large outputs
   - Verify file updates incrementally
   - Verify inline messages stay concise
   - Verify no token limit error
   - Verify final document is complete and well-structured

3. **Follow-up Test:**
   - After completing a research query, ask a follow-up question
   - Verify follow-up appends correctly to existing document
   - Verify frontmatter is updated appropriately

4. **Edge Case Tests:**
   - Query about non-existent component
   - Query that triggers agent errors
   - Query that returns minimal results

### Validation Checks:

For each test, verify:
- ✓ No "6000 token limit" error message
- ✓ Research file created before agents spawn
- ✓ Incremental appends visible in file
- ✓ Inline messages < 500 tokens each
- ✓ Final document structure matches template
- ✓ Frontmatter complete with no placeholders
- ✓ Sync operation successful
- ✓ Code references formatted correctly
- ✓ Sections properly organized

## Performance Considerations

**Token efficiency:**
- Incremental writes eliminate large inline presentations (save ~2000-5000 tokens per research)
- Progress messages are concise (< 500 tokens each)
- User can monitor progress via file reads instead of waiting for full synthesis

**File I/O:**
- Multiple Edit operations vs single Write operation
- Trade-off: More file operations for better token management
- Edit tool is efficient for appends (doesn't rewrite entire file)

**User experience:**
- Users see progress in real-time via brief updates
- Can read research file anytime during execution
- Final result identical to current format (backward compatible)

## Migration Notes

**Backward compatibility:**
- Existing research documents remain unchanged
- New documents use same format and structure
- No changes to thoughts-management Skill scripts
- No changes to other commands

**For existing workflows:**
- `/stepwise-dev:research_codebase` behavior changes from user perspective:
  - Before: Long wait → Large synthesis presented → File written
  - After: Quick file creation → Progress updates → File complete
- Final research document format is identical
- No action required for existing research documents

## References

- Original issue: "API Error: Claude's response exceeded the 6000 output token maximum"
- Modified command: `commands/research_codebase.md`
- Thoughts management: `skills/thoughts-management/SKILL.md`
- Pattern reference: Commands already write final outputs to files (commands/create_plan.md:183-281)
