---
description: Conduct multi-agent deep research on a topic with parallel web searches and synthesis
argument-hint: <research topic or question>
model: opus
---

# Deep Research Command

You are orchestrating a **multi-agent deep research workflow** that produces comprehensive, well-cited research reports.

## Command Workflow

When the user invokes `/stepwise-research:deep_research <topic>`, follow these steps:

### 1. Clarification Phase (Only if Needed)

If the research topic is **ambiguous or unclear**, ask 1-2 clarifying questions using the AskUserQuestion tool:
- What specific aspect should be prioritized?
- What timeframe or context is relevant?
- Are there specific sources to include/exclude?

**Skip this step if:**
- Topic is explicit (e.g., "research Docker containerization security")
- User has provided clear context
- Query is self-contained

### 2. Spawn Research Lead Agent

Use the `Task` tool to spawn the `research-lead` agent:

```
Task:
  subagent_type: "research-lead"
  description: "Research [topic]"
  prompt: "Conduct comprehensive research on: [full user query with context]

  Research requirements:
  - Original query: [user's exact words]
  - Context: [any clarifications from step 1]
  - Expected deliverable: Structured research report with 10-15+ citations
  "
```

**Important:**
- Pass the **full research query** with all context
- The lead agent will handle orchestration internally (spawning workers, synthesis, gap detection)
- Wait for lead agent completion before proceeding

### 3. Monitor Lead Agent Progress

The lead agent will:
- Parse the query into sub-questions
- Spawn 1-6+ research-worker agents in parallel based on complexity
- Synthesize findings from all workers
- Detect research gaps and spawn additional workers if needed
- Generate a draft research report

**Do not interrupt this process.** Let the lead agent complete its work.

### 4. Citation Verification

After the lead agent completes, spawn the `citation-analyst` agent:

```
Task:
  subagent_type: "citation-analyst"
  description: "Verify citations"
  prompt: "Analyze the research report at [report_path] for citation accuracy and completeness.

  Tasks:
  - Map claims to source evidence
  - Flag unsupported or weakly-supported claims
  - Verify URLs are accessible
  - Suggest citation improvements

  Output a citation quality report."
```

### 5. Citation Improvement (If Needed)

Review the citation-analyst's feedback:
- If **major issues** found (unsupported claims, broken URLs): Re-spawn the lead agent with instructions to address specific issues
- If **minor issues** or no issues: Proceed to finalization

### 6. Finalization

1. **Verify report location:** Confirm the report is saved to `thoughts/shared/research/[topic]-[date].md`

2. **Sync with thoughts system:** The `thoughts-management` Skill should automatically create hardlinks when the report is saved. If not, manually trigger it.

3. **Present results to user:**
   ```
   Research complete! Report saved to:
   thoughts/shared/research/[filename].md

   Summary:
   - [X] workers spawned
   - [Y] sources analyzed
   - [Z] citations included

   Key findings:
   [2-3 sentence summary of main insights]
   ```

## Behavioral Guidelines

- **Stay concise:** This is a CLI tool. Keep communication brief.
- **Trust the agents:** The research-lead and research-worker agents are specialized. Don't micromanage.
- **Context management:** The lead agent handles worker orchestration. You only orchestrate the high-level workflow.
- **No time estimates:** Never promise how long research will take.
- **Parallel execution:** Agents spawn workers in parallel automatically.

## Error Handling

If the lead agent fails:
- Check if the query is too broad (suggest narrowing scope)
- Check if web search tools are available (they should be built-in)
- Check if `thoughts/shared/research/` directory exists (create if missing)

If citation-analyst fails:
- Continue anyway (citation verification is nice-to-have)
- Warn user that citations should be manually verified

## Example Usage

**Simple query:**
```
/stepwise-research:deep_research What is Kubernetes and how does it work?
```
Expected: 1 worker, 10-15 sources, 15-minute research time

**Comparison query:**
```
/stepwise-research:deep_research Compare PostgreSQL vs MySQL for high-traffic applications
```
Expected: 2-3 workers, 15-20 sources, 20-25 minute research time

**Complex research:**
```
/stepwise-research:deep_research Analyze the current state of WebAssembly adoption in enterprise applications
```
Expected: 4-6+ workers, 25+ sources, 30-40 minute research time

## Integration with Thoughts System

All research reports are saved to:
```
thoughts/shared/research/[sanitized-topic]-[YYYY-MM-DD].md
```

Reports include YAML frontmatter:
```yaml
---
title: Research on [Topic]
date: YYYY-MM-DD
query: [Original research question]
keywords: [extracted, key, terms]
status: complete
agent_count: N
source_count: M
---
```

After report creation, the `thoughts-management` Skill creates hardlinks in `thoughts/searchable/` for efficient grep-based discovery.

## Success Criteria

A successful research session produces:
- ✅ Structured report with YAML frontmatter
- ✅ 10-15+ citations with accessible URLs
- ✅ Diverse sources (.gov, .edu, industry, academic)
- ✅ Cross-references and synthesis (not just concatenation)
- ✅ Executive summary (3-5 sentences)
- ✅ Detailed findings organized by theme
- ✅ Full bibliography with numbered citations

## Notes

- **No external configuration required:** WebSearch and WebFetch are built-in Claude Code tools
- **Multi-agent architecture:** Lead agent spawns workers internally for parallel execution
- **Automatic context management:** Each agent operates in its own context window
- **Cost optimization:** Workers use Sonnet model (efficiency), lead uses Opus (synthesis quality)
