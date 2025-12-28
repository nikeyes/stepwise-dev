---
date: 2025-12-28 10:45:00 PST
researcher: Jorge Castro
git_commit: 225cad592ff0539a02a0568cb2009cbe88966252
branch: main
repository: stepwise-dev
topic: "HumanLayer Comparison and Improvement Opportunities for stepwise-dev"
tags: [research, humanlayer, improvements, comparison, features, architecture]
status: complete
last_updated: 2025-12-28
last_updated_by: Jorge Castro
---

# Research: HumanLayer Comparison and Improvement Opportunities for stepwise-dev

**Date**: 2025-12-28 10:45:00 PST
**Researcher**: Jorge Castro
**Git Commit**: 225cad592ff0539a02a0568cb2009cbe88966252
**Branch**: main
**Repository**: stepwise-dev

## Research Question

How can we improve the stepwise-dev repository based on HumanLayer's architecture, features, and best practices?

## Summary

This research compares stepwise-dev (a Claude Code plugin for structured development workflows) with HumanLayer (an IDE for orchestrating AI coding agents), identifying 12 key improvement opportunities across architecture, collaboration, performance, and user experience. The analysis reveals that while stepwise-dev excels at individual developer workflows with local persistence, it could benefit from HumanLayer's multi-session parallelization, advanced context engineering, team collaboration features, and enterprise scaling capabilities.

**Key Finding**: stepwise-dev and HumanLayer serve complementary but different purposes - stepwise-dev is a workflow extension within a single Claude Code session, while HumanLayer is a full orchestration platform managing multiple sessions. Improvements should enhance stepwise-dev's strengths while selectively adopting HumanLayer's architectural patterns.

## Detailed Findings

### 1. HumanLayer Architecture and Features

**What is HumanLayer?**

HumanLayer is an open-source IDE designed to orchestrate AI coding agents for tackling complex development challenges in large codebases. It operates as a layer above Claude Code, managing multiple parallel sessions with intelligent context engineering.

**Core Components**:

1. **Keyboard-First Interface** - "Superhuman for Claude Code" with speed-optimized workflows
2. **Advanced Context Engineering** - Proprietary methodology preventing token waste
3. **Multi-Claude Parallelization** - Run multiple Claude Code sessions simultaneously
4. **Human-in-the-Loop Architecture** - Maintains human decision authority
5. **Web UI (humanlayer-wui)** - Visual orchestration interface
6. **Enterprise Team Scaling** - Distributed work across worktrees and cloud workers

**Technology Stack**:
- TypeScript: 59.2% (primary language for web UI and apps)
- Go: 33.6% (backend/integration via claudecode-go)
- Rust: 1.4% (systems programming)
- Shell: 1.4% (infrastructure scripting)
- JavaScript: 1.6%
- CSS: 1.6%

**Project Metrics**:
- 8.2k GitHub stars
- 334 releases
- 30+ contributors
- 2,095+ commits
- Apache 2.0 license

**Key Resources**:
- Main Site: https://humanlayer.dev/code
- GitHub: https://github.com/humanlayer/humanlayer
- Discord: https://humanlayer.dev/discord
- YouTube: Advanced Context Engineering talk (YC, August 20, 2025)
- Podcast: "AI That Works" (weekly series)

**Reported Benefits**:
- 50% productivity improvement (Revlo.ai testimonial)
- Token consumption reduction through context engineering
- Prevention of "slop-fest" scenario (degraded output quality)

**Architecture**:
```
humanlayer/
├── apps/                 # Applications
├── claudecode-go/        # Go integrations
├── packages/             # Shared libraries
├── humanlayer-wui/       # Web user interface
├── hld/                  # Architecture documentation
└── hlyr/                 # Core CLI tooling
```

Uses Turbo monorepo tooling for managing multiple packages, Bun as package manager, Docker support for deployment.

---

### 2. stepwise-dev Current State

**What is stepwise-dev?**

stepwise-dev is a Claude Code plugin implementing a structured Research → Plan → Implement → Validate development cycle with context management and local persistence via a `thoughts/` directory system.

**Core Components**:

1. **6 Slash Commands** (`commands/*.md`):
   - `/stepwise-dev:research_codebase` - Document codebase comprehensively
   - `/stepwise-dev:create_plan` - Create implementation plans iteratively
   - `/stepwise-dev:iterate_plan` - Update existing plans
   - `/stepwise-dev:implement_plan` - Execute plans phase-by-phase
   - `/stepwise-dev:validate_plan` - Validate implementation
   - `/stepwise-dev:commit` - Create git commits

2. **6 Specialized Agents** (`agents/*.md`):
   - codebase-locator (blue) - Find WHERE code lives
   - codebase-analyzer (green) - Understand HOW code works
   - codebase-pattern-finder (purple) - Find similar patterns
   - thoughts-locator (cyan) - Discover documents in thoughts/
   - thoughts-analyzer (yellow) - Extract insights from docs
   - web-search-researcher (orange) - External research

3. **1 Agent Skill** (`skills/thoughts-management/`):
   - thoughts-init - Initialize directory structure
   - thoughts-sync - Sync hardlinks for efficient searching
   - thoughts-metadata - Generate git metadata

**Technology Stack**:
- Markdown: 100% (commands and agents are instruction files)
- Bash: 100% (skills are shell scripts)
- Zero dependencies: No npm, no compilation, no build

**Project Metrics** (as of version 0.0.5):
- 6 commands
- 6 agents
- 3 bash scripts
- 124+ automated test assertions
- ~2-3 second test execution
- Apache 2.0 license

**Key Philosophy**:
- Context < 60% (LLM attention threshold)
- Phased workflow: Research → Plan → Implement → Validate
- Local-only operation (no cloud dependencies)
- Document-only mindset (no unsolicited improvements)
- Thoughts persistence across sessions

**Architecture**:
```
stepwise-dev/
├── commands/              # 6 slash commands (markdown)
├── agents/                # 6 specialized agents (markdown)
├── skills/                # 1 Agent Skill
│   └── thoughts-management/
│       ├── SKILL.md
│       └── scripts/       # 3 bash scripts
├── test/                  # Automated bash tests
└── thoughts/              # Self-hosted persistence
    ├── {username}/        # Personal notes
    ├── shared/            # Team documents
    └── searchable/        # Hardlinks (auto-generated)
```

---

### 3. Feature Comparison Matrix

| Feature | HumanLayer | stepwise-dev | Gap Analysis |
|---------|------------|--------------|--------------|
| **Multi-Session Parallelization** | ✅ Multiple Claude sessions simultaneously | ❌ Single session only | **HIGH PRIORITY** - Major productivity limitation |
| **Context Engineering** | ✅ Proprietary methodology | ⚠️ 60% threshold + phasing | **MEDIUM** - Could optimize further |
| **Web UI** | ✅ humanlayer-wui for visual orchestration | ❌ CLI/text only | **LOW** - Not core to mission |
| **Team Collaboration** | ✅ Distributed work, worktrees, cloud workers | ⚠️ Basic (shared/ directory) | **MEDIUM** - Limited team features |
| **Keyboard Shortcuts** | ✅ "Superhuman for Claude Code" | ❌ Standard slash commands | **LOW** - Nice to have |
| **Local Persistence** | ❌ Not emphasized | ✅ thoughts/ directory with hardlinks | **ADVANTAGE** - stepwise-dev wins |
| **Workflow Structure** | ⚠️ Flexible | ✅ Rigid 4-phase cycle | **ADVANTAGE** - stepwise-dev wins |
| **Testing Infrastructure** | ❓ Unknown | ✅ Automated bash tests | **ADVANTAGE** - stepwise-dev wins |
| **Documentation** | ✅ Extensive (docs/, blog, video) | ✅ Good (README, CLAUDE.md) | **PARITY** |
| **Enterprise Scaling** | ✅ Designed for teams | ❌ Individual developers | **HIGH** - Market expansion opportunity |
| **Quality Control Metrics** | ✅ Anti-"slop-fest" measures | ⚠️ Manual verification in validation | **MEDIUM** - Could automate more |
| **Technology Stack** | ✅ TypeScript, Go, Rust | ⚠️ Bash only | **MEDIUM** - More robust options available |
| **Installation Complexity** | ❓ Likely higher (Turbo, Docker) | ✅ Simple plugin install | **ADVANTAGE** - stepwise-dev wins |
| **Zero Cloud Dependency** | ❌ Cloud workers supported | ✅ 100% local | **ADVANTAGE** - stepwise-dev wins |

**Legend**: ✅ Fully supported | ⚠️ Partially supported | ❌ Not supported | ❓ Unknown

---

### 4. Architectural Differences

#### Scope and Purpose

**HumanLayer**: Full orchestration platform
- Manages multiple Claude Code sessions
- Operates as an IDE layer above Claude Code
- Designed for complex, large-scale codebase work
- Team-oriented from ground up

**stepwise-dev**: Single-session workflow extension
- Enhances one Claude Code session with structure
- Operates as a plugin within Claude Code
- Designed for phased, context-managed development
- Individual developer oriented

#### Key Architectural Distinction

HumanLayer and stepwise-dev are **complementary, not competitive**:
- HumanLayer: "How do I orchestrate multiple AI sessions?"
- stepwise-dev: "How do I structure work within one session?"

**Implication**: stepwise-dev could potentially be *used within* HumanLayer sessions, or adopt HumanLayer's orchestration patterns for multi-session support.

#### Context Management Philosophy

**HumanLayer**:
- Proprietary context engineering methodology
- Focus on "what information reaches the AI model"
- Intelligent curation to prevent token waste
- 50% productivity improvement claimed

**stepwise-dev**:
- 60% context threshold rule
- Phased workflow (Research → Plan → Implement → Validate)
- `/clear` between phases
- Persistence in thoughts/ directory

**Learning Opportunity**: HumanLayer's "proprietary methodology" suggests more sophisticated techniques beyond simple thresholding. Research into their specific approaches could improve stepwise-dev's efficiency.

#### Persistence Strategy

**HumanLayer**:
- Not emphasized in public documentation
- Likely relies on session state + git
- Cloud workers suggest remote persistence

**stepwise-dev**:
- Explicit thoughts/ directory with hardlinks
- Searchable/ for fast grep operations
- Personal (username/) vs shared/ organization
- Zero-copy duplication via hardlinks

**Advantage**: stepwise-dev's hardlink system is unique and efficient for local-only operation.

---

### 5. Improvement Opportunities (Prioritized)

#### HIGH PRIORITY

##### 1. Multi-Session Parallelization

**Current State**: stepwise-dev operates within a single Claude Code session.

**HumanLayer Approach**: Run multiple Claude Code sessions simultaneously across different worktrees or cloud workers.

**Improvement Opportunity**:
- Design a multi-session orchestration layer
- Enable parallel research, planning, implementation across branches
- Coordinate results back to main session
- Potential implementation: Extend thoughts-management Skill to spawn/coordinate sessions

**Benefits**:
- Massive productivity improvement (HumanLayer reports 50%)
- Parallel research on multiple components
- Simultaneous plan iteration and implementation
- Reduced wall-clock time for complex tasks

**Complexity**: HIGH - Requires fundamental architectural changes

**References**:
- Current limitation: Single session paradigm throughout all commands
- Parallel agent spawning exists (`research_codebase.md:52-75`) but within one session

---

##### 2. Enterprise Team Scaling Features

**Current State**: stepwise-dev supports basic team collaboration via `thoughts/shared/` directory.

**HumanLayer Approach**: Distributed work across worktrees, cloud workers, designed for team scaling.

**Improvement Opportunities**:
- **Work Distribution**: Assign phases (research, plan, implement) to different team members
- **Merge Conflict Resolution**: Handle thoughts/ directory conflicts
- **Permission System**: Control who can modify shared/ vs personal directories
- **Review Workflows**: Add approval gates for plans before implementation
- **Metrics Dashboard**: Track team progress across research → plan → implement phases

**Benefits**:
- Expand from individual to team market
- Better support for distributed development
- Formal approval processes for enterprise compliance

**Complexity**: MEDIUM-HIGH

**References**:
- `thoughts/shared/` exists but limited collaboration features (`SKILL.md:131-145`)
- No conflict resolution beyond standard git

---

#### MEDIUM PRIORITY

##### 3. Advanced Context Engineering

**Current State**: 60% threshold + phasing + `/clear` commands.

**HumanLayer Approach**: Proprietary methodology for intelligent curation of information fed to models.

**Improvement Opportunities**:
- **Token Budgeting**: Track actual token usage vs limits in real-time
- **Relevance Scoring**: Prioritize which files/info to include based on task
- **Progressive Loading**: Start with minimal context, expand only as needed
- **Context Compression**: Summarize previously read files for re-reference
- **Smart Filtering**: Exclude boilerplate, focus on business logic

**Benefits**:
- Reduce token consumption (cost savings)
- Improve response quality (less noise)
- Extend capability for larger codebases

**Complexity**: MEDIUM - Requires research into HumanLayer's specific techniques

**References**:
- Current approach: `README.md:22-27` (context < 60% guideline)
- Token optimization research already exists: `thoughts/shared/research/2025-12-20-token-optimization-strategies.md`
- Implementation plans exist: `thoughts/shared/plans/2025-12-20-token-optimization-implementation.md`

**Action**: Review existing token optimization research and integrate findings

---

##### 4. Quality Control Metrics

**Current State**: Manual verification sections in plans, visual inspection.

**HumanLayer Approach**: Anti-"slop-fest" measures to prevent degraded output quality.

**Improvement Opportunities**:
- **Code Quality Metrics**: Track cyclomatic complexity, duplication, test coverage
- **LLM Response Quality Scoring**: Detect when responses become generic or low-quality
- **Automated Code Review**: Run linters, formatters, security scanners automatically
- **Regression Detection**: Compare new code against existing patterns
- **Quality Gates**: Fail validation if metrics degrade

**Benefits**:
- Prevent quality degradation over iterations
- Objective quality standards
- Automated enforcement

**Complexity**: MEDIUM

**References**:
- Current manual verification: `validate_plan.md` relies on human inspection
- TDD projects have automated tests but no quality metrics tracked

---

##### 5. TypeScript/Go Integration for Robustness

**Current State**: 100% bash scripts for all automation.

**HumanLayer Approach**: TypeScript (59%), Go (33%) for robust tooling.

**Improvement Opportunities**:
- **TypeScript for Complex Logic**: thoughts-sync logic is complex, could benefit from type safety
- **Go for Performance**: Metadata gathering, file operations could be faster
- **Testing**: Better unit test support with proper languages
- **Maintainability**: Type checking catches errors at compile time

**Benefits**:
- More robust error handling
- Better performance for large thoughts/ directories
- Easier to maintain as complexity grows
- Type safety prevents bugs

**Complexity**: MEDIUM - Requires introducing build step (conflicts with zero-dependency philosophy)

**References**:
- Current bash scripts: `skills/thoughts-management/scripts/*`
- Complexity examples: `thoughts-sync` has 147 lines of bash with complex find loops

**Trade-off**: Conflicts with current "zero dependencies" advantage. Consider only for new features, not rewrites.

---

##### 6. Team Thoughts Synchronization

**Current State**: thoughts/ is local filesystem, shared via git.

**HumanLayer Approach**: Distributed workers suggest synchronized state.

**Improvement Opportunities**:
- **Real-time Sync**: Update searchable/ when teammates commit to thoughts/
- **Conflict Resolution**: Detect and resolve simultaneous edits
- **Notification System**: Alert when new research/plans published
- **Remote thoughts/**: Optional cloud backup of thoughts/ directory
- **Search Across Team**: Find documents across all team members' thoughts/

**Benefits**:
- Better team awareness
- Faster knowledge sharing
- Reduced duplication of research

**Complexity**: MEDIUM-HIGH - Requires backend service (conflicts with local-only philosophy)

**References**:
- Current sync: Manual git operations
- Hardlink system: `thoughts-sync` script (`scripts/thoughts-sync:1-147`)

**Trade-off**: Optional feature for teams, preserve local-only as default

---

#### LOW PRIORITY (Nice to Have)

##### 7. Web UI for Workflow Visualization

**Current State**: Text-based CLI interaction.

**HumanLayer Approach**: Web UI (humanlayer-wui) for visual orchestration.

**Improvement Opportunities**:
- **Workflow Dashboard**: Visualize current phase (research/plan/implement/validate)
- **Context Meter**: Show real-time context usage vs 60% threshold
- **Thoughts Browser**: Web interface to search thoughts/ directory
- **Agent Activity View**: See which agents are running in parallel
- **Plan Progress Tracker**: Visual checklist for implementation phases

**Benefits**:
- Easier monitoring of complex workflows
- Better context awareness
- More accessible to visual thinkers

**Complexity**: HIGH - Requires full web stack

**References**:
- Current interface: Pure text via Claude Code CLI
- No UI components exist

**Justification for LOW Priority**: stepwise-dev's strength is simplicity and text-first approach. Web UI would add significant complexity for marginal benefit in core use case.

---

##### 8. Keyboard-First Shortcuts

**Current State**: Standard slash commands (`/stepwise-dev:command_name`).

**HumanLayer Approach**: "Superhuman for Claude Code" with optimized keyboard workflows.

**Improvement Opportunities**:
- **Shorter Aliases**: `/rsh` for research, `/pln` for plan, `/imp` for implement
- **Quick Context Check**: Keyboard shortcut to show current context usage
- **Fast Phase Switching**: Jump between research/plan/implement/validate
- **Thoughts Search**: Inline search of thoughts/ without leaving Claude Code
- **Quick Commit**: One-key git commit with auto-generated message

**Benefits**:
- Faster workflow navigation
- Reduced typing
- Better flow state

**Complexity**: LOW-MEDIUM - Depends on Claude Code plugin API capabilities

**References**:
- Current commands: Full names like `/stepwise-dev:research_codebase`
- No aliases defined

**Limitation**: Plugin system may not support custom keybindings

---

##### 9. Remote Worker Support

**Current State**: 100% local execution.

**HumanLayer Approach**: Cloud workers for distributed execution.

**Improvement Opportunities**:
- **Remote Research**: Offload expensive research tasks to cloud
- **Parallel Plan Generation**: Generate multiple plan variations remotely
- **Distributed Testing**: Run validation on remote machines
- **Larger Context Windows**: Use cloud resources for bigger codebases

**Benefits**:
- Scale beyond local machine resources
- Faster execution for large codebases
- Access to more powerful compute

**Complexity**: HIGH - Requires cloud infrastructure

**Justification for LOW Priority**: Conflicts with core "local-only" philosophy and zero-dependency advantage. Only relevant if targeting enterprise market.

---

##### 10. Advanced Documentation (Video, Podcast)

**Current State**: README.md, CLAUDE.md, text documentation.

**HumanLayer Approach**: YouTube talks, "AI That Works" podcast, extensive content.

**Improvement Opportunities**:
- **Video Tutorials**: Walkthrough of research → plan → implement → validate workflow
- **Blog Posts**: Case studies of complex features built with stepwise-dev
- **Podcast/Interviews**: Share philosophy and approach
- **Conference Talks**: Present at developer conferences
- **Interactive Demos**: Live coding sessions

**Benefits**:
- Better user onboarding
- Increased adoption
- Community building
- Thought leadership

**Complexity**: LOW (just time investment)

**References**:
- Current docs: `README.md` (455 lines), `CLAUDE.md` (206 lines)
- No video or multimedia content

---

##### 11. Monorepo Tooling (Like Turbo)

**Current State**: Single plugin package, no monorepo.

**HumanLayer Approach**: Turbo monorepo for managing multiple packages.

**Improvement Opportunities**:
- **Split Commands**: Separate package per command for modular installation
- **Shared Libraries**: Extract common patterns to reusable packages
- **Plugin Marketplace**: Offer à la carte installation (just research, just planning, etc.)
- **Version Independence**: Update individual commands without full plugin update

**Benefits**:
- More flexible installation
- Faster iteration on individual components
- Reduced overhead for users who only need subset

**Complexity**: MEDIUM-HIGH

**Justification for LOW Priority**: Current all-in-one approach is simpler and works well for integrated workflow. Monorepo makes sense only with many more components.

---

##### 12. Discord Community

**Current State**: GitHub issues only.

**HumanLayer Approach**: Active Discord community (humanlayer.dev/discord).

**Improvement Opportunities**:
- **Create Discord Server**: Channel for users to ask questions
- **Share Workflows**: Users share their thoughts/ organization patterns
- **Feature Requests**: Collaborative discussion of new features
- **Office Hours**: Live support sessions
- **Showcase**: Channel for sharing successful projects built with stepwise-dev

**Benefits**:
- Faster support
- Community building
- User feedback loop
- Shared best practices

**Complexity**: LOW (just moderation effort)

**References**:
- Current support: GitHub issues at https://github.com/nikeyes/stepwise-dev
- No community platform

---

## Code References

### stepwise-dev Key Files

- `README.md:1-455` - Main documentation
- `CLAUDE.md:1-206` - Developer guide
- `.claude-plugin/plugin.json:1-19` - Plugin manifest
- `commands/research_codebase.md:1-240` - Research workflow
- `commands/create_plan.md:1-480` - Planning workflow
- `agents/codebase-locator.md:1-128` - File location agent
- `skills/thoughts-management/SKILL.md:1-224` - Thoughts system
- `skills/thoughts-management/scripts/thoughts-sync:1-147` - Hardlink synchronization
- `test/thoughts-structure-test.sh:1-127` - Functional tests
- `Makefile:1-59` - Test automation

### Historical Context (from thoughts/)

**Token Optimization Focus**:
- `thoughts/shared/research/2025-12-20-token-optimization-strategies.md` - Research on reducing token usage
- `thoughts/shared/plans/2025-12-20-token-optimization-implementation.md` - Multi-phase implementation plan
- `thoughts/shared/plans/2025-12-20-phase1-agent-filtering.md` - Agent result filtering
- `thoughts/shared/plans/2025-12-21-testing-token-optimization.md` - Testing strategy

**Plugin Development**:
- `thoughts/shared/plans/2025-11-11-convert-to-plugin.md` - Original plugin conversion
- `thoughts/shared/plans/2025-11-13-prevent-6000-token-limit-error.md` - Context management

**Testing Infrastructure**:
- `thoughts/shared/research/2025-11-12-testing-infrastructure.md` - Testing approach research

**Notes**:
- `thoughts/nikey_es/notes/claude-code-skills.md` - Agent Skills documentation
- `thoughts/nikey_es/notes/plugins-claude-code.md` - Claude Code plugins info

**Key Insight**: Token optimization has been a major focus. HumanLayer's 50% productivity improvement + token reduction validates this priority. The existing token optimization research should be reviewed and integrated with HumanLayer's approaches.

---

## Architectural Recommendations

### Short Term (1-3 months)

1. **Review Token Optimization Research**
   - Action: Implement findings from `thoughts/shared/plans/2025-12-20-token-optimization-implementation.md`
   - HumanLayer Inspiration: Their proprietary context engineering
   - Benefit: Immediate efficiency gains
   - Complexity: MEDIUM (research exists, just needs implementation)

2. **Add Quality Metrics to Validation**
   - Action: Integrate linters, formatters, security scanners into `validate_plan.md`
   - HumanLayer Inspiration: Anti-"slop-fest" measures
   - Benefit: Automated quality gates
   - Complexity: LOW (tooling already exists, just integration)

3. **Expand Documentation**
   - Action: Create video walkthrough, blog post case study
   - HumanLayer Inspiration: YouTube talks, podcast
   - Benefit: Better user onboarding
   - Complexity: LOW (just time)

### Medium Term (3-6 months)

4. **Enhanced Team Collaboration**
   - Action: Add conflict resolution, review workflows to thoughts/
   - HumanLayer Inspiration: Distributed team work
   - Benefit: Expand to team use cases
   - Complexity: MEDIUM

5. **Advanced Context Engineering**
   - Action: Implement relevance scoring, progressive loading, context compression
   - HumanLayer Inspiration: Proprietary methodology
   - Benefit: Handle larger codebases
   - Complexity: MEDIUM-HIGH (requires research)

6. **Keyboard Shortcuts**
   - Action: Add command aliases, quick phase switching
   - HumanLayer Inspiration: "Superhuman for Claude Code"
   - Benefit: Faster workflows
   - Complexity: LOW-MEDIUM (plugin API dependent)

### Long Term (6-12 months)

7. **Multi-Session Orchestration**
   - Action: Design and implement parallel session coordination
   - HumanLayer Inspiration: Core architecture
   - Benefit: Massive productivity improvement
   - Complexity: HIGH (fundamental change)

8. **Enterprise Features** (Optional, only if targeting enterprise)
   - Action: Remote workers, permissions, metrics dashboard
   - HumanLayer Inspiration: Team scaling features
   - Benefit: Market expansion
   - Complexity: HIGH

### NOT Recommended

9. **Web UI** - Conflicts with text-first philosophy, high complexity, low benefit
10. **Full Monorepo** - Overcomplicated for current scope
11. **Cloud Dependency** - Conflicts with local-only advantage

---

## Strategic Positioning

### stepwise-dev's Unique Advantages (Preserve)

1. **Local-Only Operation** - Zero cloud dependency, privacy-focused
2. **Zero Dependencies** - No npm, no build, pure markdown + bash
3. **Hardlink System** - Unique thoughts/ architecture with efficient searching
4. **Workflow Structure** - Rigid 4-phase cycle enforces discipline
5. **Simple Installation** - Single plugin install, no configuration
6. **Testing Infrastructure** - Automated bash tests with fast execution

### HumanLayer's Strengths (Selectively Adopt)

1. **Multi-Session Parallelization** - ADOPT (high impact)
2. **Advanced Context Engineering** - ADOPT (aligns with existing research)
3. **Team Collaboration** - ADOPT (market expansion)
4. **Quality Metrics** - ADOPT (low complexity, high value)
5. **Keyboard Optimization** - ADOPT (low complexity)
6. **Web UI** - SKIP (conflicts with philosophy)
7. **Cloud Workers** - SKIP (conflicts with local-only)

### Differentiation Strategy

**stepwise-dev should be**: "The local-first, zero-dependency workflow system for structured Claude Code development with team collaboration"

**NOT**: "A HumanLayer clone"

**Key Differentiators**:
- Local-only (vs HumanLayer's cloud workers)
- Markdown + Bash (vs TypeScript/Go complexity)
- Single-plugin simplicity (vs monorepo)
- Thoughts persistence (vs session-based)
- Rigid workflow (vs flexible orchestration)

---

## Open Questions

1. **What specific context engineering techniques does HumanLayer use?**
   - Action: Reach out to HumanLayer team, study their blog/talks
   - Alternative: Reverse-engineer from public examples

2. **How does HumanLayer coordinate multiple sessions?**
   - Action: Examine claudecode-go integration
   - Relevance: Critical for multi-session feature

3. **What metrics define "slop-fest" prevention?**
   - Action: Research their quality control approach
   - Relevance: Needed for quality metrics feature

4. **How do cloud workers communicate with local sessions?**
   - Action: Study architecture documentation
   - Relevance: Only if pursuing remote worker feature (low priority)

5. **Can Claude Code plugin API support multi-session spawning?**
   - Action: Research Claude Code plugin documentation
   - Relevance: Determines feasibility of highest-priority feature

---

## Related Research

- `thoughts/shared/research/2025-12-20-token-optimization-strategies.md` - Token optimization research
- `thoughts/shared/research/2025-11-12-testing-infrastructure.md` - Testing infrastructure approach
- `thoughts/nikey_es/notes/claude-code-skills.md` - Agent Skills documentation
- `thoughts/nikey_es/notes/plugins-claude-code.md` - Plugin development notes

---

## Next Steps

Based on this research, recommended priorities:

### IMMEDIATE (Week 1-2)
1. Review existing token optimization research from December 2025
2. Create video walkthrough demonstrating research → plan → implement → validate
3. Add basic quality metrics (linters) to validation phase

### SHORT TERM (Month 1-3)
4. Implement token optimization strategies from existing plans
5. Design multi-session orchestration architecture (research phase)
6. Add keyboard shortcuts/aliases for commands
7. Enhance team collaboration features (conflict resolution, review workflows)

### MEDIUM TERM (Month 4-6)
8. Implement multi-session prototype
9. Add advanced context engineering (relevance scoring, progressive loading)
10. Create Discord community

### LONG TERM (Month 7-12)
11. Full multi-session orchestration (if prototype successful)
12. Enterprise features (if market demand exists)
13. Conference talks, thought leadership content

---

## External Resources

**HumanLayer**:
- GitHub Repository: https://github.com/humanlayer/humanlayer
- Official Site: https://humanlayer.dev/code
- Discord Community: https://humanlayer.dev/discord
- YouTube: Advanced Context Engineering talk (YC, August 20, 2025)
- Podcast: "AI That Works" (weekly series)

**stepwise-dev**:
- GitHub Repository: https://github.com/nikeyes/stepwise-dev
- Current Documentation: README.md, CLAUDE.md
- Issue Tracker: https://github.com/nikeyes/stepwise-dev/issues

---

## Conclusion

HumanLayer and stepwise-dev represent two different approaches to enhancing AI-assisted development:

- **HumanLayer**: Full orchestration platform for multiple sessions, teams, enterprise
- **stepwise-dev**: Structured workflow within a single session, local-first, individual developer

**Key Recommendation**: stepwise-dev should selectively adopt HumanLayer's strengths (multi-session, context engineering, team features) while preserving its unique advantages (local-only, zero-dependency, thoughts system).

**Highest Impact Improvements**:
1. Multi-session parallelization (50% productivity gain potential)
2. Advanced context engineering (token reduction, quality improvement)
3. Team collaboration features (market expansion)

**Preserve Core Identity**:
- Local-first philosophy
- Zero dependencies
- Simple installation
- Thoughts/ persistence

The goal is not to become HumanLayer, but to learn from their successes while remaining true to stepwise-dev's mission of providing a lightweight, local, structured workflow system.
