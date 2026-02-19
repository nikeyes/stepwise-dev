# Deep Research Plugin Implementation Plan

## Context

This plan addresses the need for a **deep research capability** within the Claude Code plugin ecosystem. The user has provided comprehensive research on Anthropic's multi-agent Research system (from Claude.ai) and wants to replicate its core functionality as a standalone plugin.

**Why this change is needed:**
- Current `web-search-researcher` agent in stepwise-web is single-agent and limited
- Anthropic's Research system demonstrates that **multi-agent orchestration with parallel execution** produces 90.2% better results than single-agent approaches
- Users need deep research capabilities for technical investigations that require multiple sources, cross-referencing, and comprehensive synthesis

**Intended outcome:**
- A standalone `stepwise-research` plugin with multi-agent orchestration
- Parallel web search, source evaluation, and cross-referencing
- Integration with `thoughts/` system for persistence
- Structured research reports with citations and metadata

## Architecture Overview

### Plugin Structure
```
stepwise-dev/
├── .claude-plugin/
│   └── marketplace.json           # Updated: add stepwise-research plugin
└── research/                       # NEW stepwise-research plugin
    ├── .claude-plugin/
    │   └── plugin.json            # Plugin metadata
    ├── commands/
    │   └── deep_research.md       # Main orchestration command
    ├── agents/
    │   ├── research-lead.md       # Lead researcher (orchestrator)
    │   ├── research-worker.md     # Worker agents (multiple spawned)
    │   └── citation-analyst.md    # Citation verification agent
    ├── skills/
    │   └── research-reports/
    │       ├── SKILL.md          # Report generation skill
    │       └── scripts/
    │           └── generate-report    # Report formatting script
    └── README.md
```

## Implementation Plan

### Phase 1: Plugin Foundation

**1.1 Create plugin directory structure**
- Create `research/` directory
- Create `.claude-plugin/plugin.json` with metadata
- Create subdirectories: `commands/`, `agents/`, `skills/`

**1.2 Update marketplace configuration**
- Edit `.claude-plugin/marketplace.json`
- Add `stepwise-research` plugin entry with version 0.0.1
- Include keywords: `research`, `multi-agent`, `web`, `synthesis`

**1.3 Create plugin README**
- Document purpose, installation, and usage
- Explain multi-agent architecture
- Provide examples

### Phase 2: Core Agents

**2.1 Research Lead Agent (`research-lead.md`)**

**Purpose:** Orchestrates research workflow (like Anthropic's LeadResearcher)

**Key responsibilities:**
- Parse research query into sub-questions
- Determine complexity and spawn appropriate number of workers
- Synthesize worker findings
- Detect research gaps and spawn additional workers if needed
- Generate final structured report

**Tools:** `Task, Read, Write, TodoWrite`

**Model:** `opus` (for complex orchestration and extended thinking)

**Architecture decisions:**
- Uses **OODA loop** (Observe, Orient, Decide, Act) from Anthropic's prompts
- Implements **escalation rules**:
  - Simple queries → 1 worker agent
  - Comparisons → 2-3 workers
  - Deep research → 4-6+ workers
- Saves research plan to `thoughts/shared/research/plans/` for context preservation
- Cross-references worker findings before synthesizing

**2.2 Research Worker Agent (`research-worker.md`)**

**Purpose:** Execute focused research tasks (like Anthropic's Subagents)

**Key responsibilities:**
- Execute web searches on assigned topic/angle
- Fetch full content from promising sources
- Evaluate source quality (prefer .gov, .edu, peer-reviewed)
- Return compressed findings with citations

**Tools:** `WebSearch, WebFetch, Read, Grep, Glob, LS`

**Model:** `sonnet` (efficiency and cost optimization)

**Architecture decisions:**
- Operates **independently** with own context window
- Follows **OODA loop** internally
- Uses **broad-then-narrow** search strategy (Anthropic's documented approach)
- Short queries (1-6 words initially), refine based on results
- Limits: ~10-15 tool calls max per worker (prevent runaway)
- Returns **structured findings** in markdown format with citations

**2.3 Citation Analyst Agent (`citation-analyst.md`)**

**Purpose:** Verify citation accuracy and completeness (like Anthropic's CitationAgent)

**Key responsibilities:**
- Map claims in draft report to source evidence
- Flag unsupported or weakly-supported claims
- Verify URLs and source accessibility
- Suggest citation improvements

**Tools:** `Read, WebFetch, Grep`

**Model:** `sonnet`

**Architecture decisions:**
- Runs **after** lead agent completes synthesis
- Operates on draft report file
- Outputs citation quality report
- Does NOT edit report directly (presents findings for lead to incorporate)

### Phase 3: Orchestration Command

**3.1 Deep Research Command (`deep_research.md`)**

**File:** `research/commands/deep_research.md`

**Command signature:** `/stepwise-research:deep_research <research topic>`

**Workflow steps:**

1. **Clarification Phase** (if needed)
   - Ask 1-2 clarifying questions if topic is ambiguous
   - Skip if topic is explicit (e.g., starts with "research...")

2. **Spawn Lead Agent**
   - Use `Task` tool to spawn `research-lead` agent
   - Pass full research query with context
   - Lead agent handles orchestration internally

3. **Monitor and Wait**
   - Wait for lead agent completion
   - Lead agent spawns workers internally (user doesn't see individual workers)

4. **Post-Processing**
   - Spawn `citation-analyst` agent on draft report
   - Review citation quality feedback
   - Optionally re-spawn lead agent for citation improvements

5. **Finalization**
   - Save final report to `thoughts/shared/research/`
   - Invoke `thoughts-management` Skill to sync
   - Present report path to user

**Model:** `opus` (for command orchestration)

**Frontmatter:**
```yaml
description: Conduct multi-agent deep research on a topic with parallel web searches and synthesis
argument-hint: <research topic or question>
```

### Phase 4: Research Report Skill

**4.1 Skill Definition (`research-reports/SKILL.md`)**

**Purpose:** Format and structure research reports

**Responsibilities:**
- Generate YAML frontmatter for reports
- Format citations consistently
- Apply standard report structure
- Integrate with `thoughts/` directory system

**Allowed tools:** `Bash, Write, Read`

**4.2 Report Generation Script (`generate-report`)**

**Bash script** at `research/skills/research-reports/scripts/generate-report`

**Functionality:**
- Takes research findings as input
- Generates structured markdown with:
  - YAML frontmatter (title, date, query, keywords, status)
  - Executive summary section
  - Detailed findings by theme
  - Cross-references and contradictions section
  - Full bibliography with numbered citations
  - Metadata footer

**Output format:**
```markdown
---
title: Research on [Topic]
date: YYYY-MM-DD
query: [Original research question]
keywords: [extracted, key, terms]
status: complete
agent_count: N
source_count: M
---

# Research on [Topic]

## Executive Summary
[3-5 sentence overview]

## Detailed Findings

### [Theme 1]
[Synthesized findings with citations]
[1] [2]

### [Theme 2]
[More findings]

## Cross-References and Contradictions
[Areas of consensus and disagreement]

## Conclusions
[Key takeaways]

## Bibliography
[1] Source Title - URL
[2] Another Source - URL
...
```

### Phase 5: Integration with Existing Components

**5.1 Marketplace Integration**
- Update `.claude-plugin/marketplace.json` with stepwise-research entry
- Ensure version consistency across all plugins
- Test marketplace installation flow

**5.2 Thoughts Directory Integration**
- Research reports saved to `thoughts/shared/research/`
- Invoke `thoughts-management` Skill after report creation
- Ensure hardlinks created in `searchable/` for grep

**5.3 Web Agent Reusability**
- Consider whether to **reuse** existing `web-search-researcher` agent from stepwise-web
- OR create new specialized `research-worker` agents
- **Recommendation:** Create new specialized workers for this plugin to:
  - Have tighter control over behavior
  - Avoid dependency on stepwise-web
  - Allow independent evolution

### Phase 6: Testing & Validation

**6.1 Manual Testing Checklist**

Test cases to validate after implementation:

1. **Simple query** (should spawn 1 worker):
   ```
   /stepwise-research:deep_research What is Docker and how does it work?
   ```
   - Verify: 1 worker spawned
   - Report generated in `thoughts/shared/research/`
   - Citations present and accurate

2. **Comparison query** (should spawn 2-3 workers):
   ```
   /stepwise-research:deep_research Compare React vs Vue.js for enterprise applications
   ```
   - Verify: 2-3 workers spawned in parallel
   - Balanced findings from multiple sources
   - Contrarian perspectives included

3. **Complex research** (should spawn 4-6+ workers):
   ```
   /stepwise-research:deep_research Analyze the state of AI code generation tools in 2026
   ```
   - Verify: 4+ workers spawned
   - Diverse sources (.gov, .edu, industry blogs, academic)
   - Cross-references identified
   - Gap detection and follow-up searches

4. **Citation verification**:
   - Manually check 5-10 citations for accuracy
   - Verify URLs are accessible
   - Confirm claims are supported by sources

5. **Thoughts integration**:
   - Verify report saved to correct location
   - Confirm YAML frontmatter present
   - Check hardlink created in `searchable/`

**6.2 Automated Testing**
- No bash scripts in this plugin initially (only report generation)
- Future: Add `make test-research` target for report format validation

## Critical Files to Modify

### New Files to Create

1. **Plugin configuration:**
   - `research/.claude-plugin/plugin.json`

2. **Commands:**
   - `research/commands/deep_research.md`

3. **Agents:**
   - `research/agents/research-lead.md`
   - `research/agents/research-worker.md`
   - `research/agents/citation-analyst.md`

4. **Skills:**
   - `research/skills/research-reports/SKILL.md`
   - `research/skills/research-reports/scripts/generate-report`

5. **Documentation:**
   - `research/README.md`

### Existing Files to Modify

1. **Marketplace configuration:**
   - `.claude-plugin/marketplace.json` (add stepwise-research plugin entry)

2. **Main README:**
   - `README.md` (add stepwise-research to plugin list)

## Design Decisions & Trade-offs

### 1. Multi-Agent vs Single-Agent
**Decision:** Multi-agent architecture (spawn multiple research-worker agents)

**Reasoning:**
- Anthropic's research shows 90.2% performance gain with multi-agent
- Enables parallel execution (faster results)
- Independent context windows avoid 200K token limit
- Follows proven architecture from Claude.ai Research

**Trade-off:** More complex orchestration logic, higher token cost

### 2. Plugin Independence vs Reuse
**Decision:** Standalone plugin with own agents (don't reuse web-search-researcher)

**Reasoning:**
- Allows independent evolution
- No dependency on stepwise-web installation
- Tighter control over worker behavior
- Clearer separation of concerns

**Trade-off:** Some code duplication (web search patterns)

### 3. Lead Agent Orchestration Strategy
**Decision:** Lead agent spawns workers internally (not the command)

**Reasoning:**
- Command stays simple (spawn lead, wait, post-process)
- Lead agent has full control over worker count and delegation
- Easier to implement iterative refinement (lead detects gaps, spawns more workers)
- Matches Anthropic's architecture

**Trade-off:** Less visibility into worker spawning for user (but cleaner UX)

### 4. Citation Verification Timing
**Decision:** Run citation-analyst AFTER lead completes synthesis

**Reasoning:**
- Follows Anthropic's CitationAgent pattern
- Cleaner separation of concerns
- Allows lead to focus on research, not citation accuracy
- Enables iterative citation improvement

**Trade-off:** Adds extra step (but significantly improves quality)

### 5. Report Format and Storage
**Decision:** Markdown with YAML frontmatter in `thoughts/shared/research/`

**Reasoning:**
- Consistent with existing stepwise architecture
- Enables grep-based discovery via thoughts-sync
- Structured metadata for future tooling
- Shareable across team

**Trade-off:** Not suitable for non-markdown consumers (but CLI-first workflow)

## Dependencies

### Built-in Claude Code Tools (No Configuration Required)

The plugin uses **native Claude Code tools** that are available out-of-the-box:

- **WebSearch** - Built-in web search (no API key needed)
- **WebFetch** - Built-in page content retrieval
- **Task** - Spawn sub-agents
- **Read/Write** - File operations
- **Grep/Glob** - Code search

**No MCP servers, API keys, or external dependencies required!** The plugin works immediately after installation.

## Verification Plan

### End-to-End Test Flow

After implementation, verify with this workflow:

1. **Install plugin:**
   ```bash
   /plugin marketplace add nikeyes/stepwise-dev
   /plugin install stepwise-research@stepwise-dev
   # Restart Claude Code
   ```

   **No additional configuration needed!** WebSearch and WebFetch are built-in.

2. **Run simple research:**
   ```bash
   /stepwise-research:deep_research What is the current state of WebAssembly?
   ```

3. **Verify outputs:**
   - Check report generated at `thoughts/shared/research/[topic]-[date].md`
   - Confirm YAML frontmatter present with correct fields
   - Validate 10-15 citations with accessible URLs
   - Check sources are diverse (.gov, .edu, blogs, docs)
   - Verify executive summary is 3-5 sentences
   - Confirm detailed findings are well-structured

4. **Test parallel agent spawning:**
   - Run comparison query (should see 2-3 workers in task output)
   - Verify findings are balanced and cross-referenced

5. **Test citation verification:**
   - Inspect citation-analyst output
   - Confirm unsupported claims are flagged

6. **Test thoughts integration:**
   - Run `thoughts-sync` (via thoughts-management Skill)
   - Verify hardlink in `thoughts/searchable/`
   - Test grep on `searchable/` to find report

## Success Criteria

The implementation is complete and successful when:

1. ✅ Plugin installs cleanly via `/plugin install stepwise-research@stepwise-dev`
2. ✅ `/stepwise-research:deep_research` command executes without errors
3. ✅ Multiple research-worker agents spawn in parallel (visible in task output)
4. ✅ Research report is generated with proper structure and YAML frontmatter
5. ✅ Report contains 10-15+ citations with accessible URLs
6. ✅ Citation-analyst identifies any unsupported claims
7. ✅ Report is saved to `thoughts/shared/research/`
8. ✅ Hardlink is created in `thoughts/searchable/` via thoughts-management Skill
9. ✅ Plugin works with zero configuration (uses built-in WebSearch/WebFetch)
10. ✅ Manual testing checklist completes successfully

## Future Enhancements (Out of Scope for v0.0.1)

- **Memory persistence** (like Anthropic's Memory tool): Save research plan across context truncations
- **Recursive depth-first exploration**: For highly complex queries
- **Multi-modal research**: Image, PDF, video analysis
- **Data analysis integration**: Spawn data-analyst sub-agents for quantitative research
- **Custom source filters**: Allow user to specify preferred domains
- **Research templates**: Pre-configured workflows for common research types
- **Interactive refinement**: Ask user questions mid-research to narrow scope

## Implementation Notes

### Key Insights from Anthropic's Architecture

From the research documents, these insights should guide implementation:

1. **Token usage correlates with quality** (80% variance explained):
   - Don't prematurely limit worker tool calls
   - Allow iterative searches (3-5 rounds per worker)
   - Lead agent should detect gaps and spawn additional workers

2. **Broad-then-narrow search strategy**:
   - Workers start with 1-6 word queries
   - Progressively refine based on results
   - Avoid hyper-specific queries too early

3. **Source quality hierarchy**:
   - Prefer: .gov, .edu, peer-reviewed, official docs
   - Avoid: SEO farms, aggregators, forums (unless authoritative like Stack Overflow)

4. **Compression is critical**:
   - Workers should return **compressed findings**, not raw fetched content
   - Lead agent synthesizes, doesn't just concatenate
   - Citation analyst operates on final compressed report

5. **Context management**:
   - Each worker operates in independent context (200K tokens)
   - Lead agent keeps plan in Memory (if implementing Memory later)
   - Command context stays clean (only orchestration logic)

### Following Stepwise Architecture Patterns

From the exploration results, these patterns must be followed:

1. **Documentarian philosophy**:
   - Agents document WHAT, WHERE, HOW
   - No critique, no recommendations (pure research)
   - Research-lead can synthesize but not evaluate

2. **Tool restrictions**:
   - Commands: `Task, Read, Write, Bash, Skill`
   - Research-lead: `Task, Read, Write, TodoWrite`
   - Research-worker: `WebSearch, WebFetch, Read, Grep, Glob, LS`
   - Citation-analyst: `Read, WebFetch, Grep`

3. **Model selection**:
   - Commands: `opus` (complex orchestration)
   - Research-lead: `opus` (extended thinking, synthesis)
   - Research-worker: `sonnet` (efficiency, parallelism)
   - Citation-analyst: `sonnet`

4. **Context management**:
   - Spawn agents to keep main context clean
   - Use `thoughts/` for persistence
   - Encourage `/clear` after research completion

## Appendix: Reference Files

### Research Documents (Provided by User)
- `/Users/jorge.castro/mordor/personal/stepwise-dev/thoughts/nikey_es/notes/create_deep_reasearch_plugin_research.md`
- `/Users/jorge.castro/mordor/personal/stepwise-dev/thoughts/nikey_es/notes/deep-research-claude-code-references.md`

### Existing Plugin Examples
- **Command structure:** `core/commands/research_codebase.md`
- **Agent structure:** `web/agents/web-search-researcher.md`
- **Skill structure:** `core/skills/thoughts-management/SKILL.md`
- **Plugin config:** `core/.claude-plugin/plugin.json`
- **Marketplace config:** `.claude-plugin/marketplace.json`

### Official Anthropic Prompts (Referenced in Research)
- Lead agent prompt: `anthropic-cookbook/patterns/agents/prompts/research_lead_agent.md`
- Sub-agent prompt: `anthropic-cookbook/patterns/agents/prompts/research_subagent.md`

### Community Implementations (For Reference)
- `willccbb/claude-deep-research` (222 stars)
- `AnkitClassicVision/Claude-Code-Deep-Research` (67 stars)
- `dzhng/deep-research` (18,400 stars)

---

**Plan Version:** 1.0
**Created:** 2026-02-19
**Estimated Effort:** ~4-6 hours for complete implementation and testing
