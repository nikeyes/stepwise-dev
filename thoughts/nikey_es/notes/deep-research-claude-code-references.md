# Referencias completas para implementar Deep Research en Claude Code

## Tabla de contenido

1. [Fuentes oficiales de Anthropic](#1-fuentes-oficiales-de-anthropic)
2. [System prompts filtrados y publicados](#2-system-prompts-filtrados-y-publicados)
3. [Documentación de Claude Code (subagents, skills, slash commands)](#3-documentación-de-claude-code)
4. [Servidores MCP necesarios](#4-servidores-mcp-necesarios)
5. [Repositorios de la comunidad para replicar](#5-repositorios-de-la-comunidad)
6. [Guía de implementación paso a paso](#6-guía-de-implementación)
7. [Arquitectura del sistema original](#7-arquitectura-del-sistema-original)
8. [Recursos adicionales de aprendizaje](#8-recursos-adicionales)

---

## 1. Fuentes oficiales de Anthropic

### Blog de ingeniería (LA fuente definitiva)
- **"How we built our multi-agent research system"** — Jeremy Hadfield, Barry Zhang et al., 13 junio 2025
  - URL: https://www.anthropic.com/engineering/multi-agent-research-system
  - Contiene: Arquitectura completa, métricas, modos de fallo, 8 principios de diseño
  - **Es el documento más importante de todos. Leerlo de principio a fin.**

### Prompts oficiales en el Anthropic Cookbook
- **Prompt del agente líder (LeadResearcher)**:
  - https://github.com/anthropics/anthropic-cookbook/blob/main/patterns/agents/prompts/research_lead_agent.md
- **Prompt del sub-agente (Research Worker)**:
  - https://github.com/anthropics/anthropic-cookbook/blob/main/patterns/agents/prompts/research_subagent.md
  - Usa un **loop OODA** (Observe, Orient, Decide, Act) como ciclo central
  - Límite duro: 20 llamadas a herramientas y ~100 fuentes

### Implementación de referencia oficial con Claude Agent SDK
- **Research Agent Demo**:
  - https://github.com/anthropics/claude-agent-sdk-demos/tree/main/research-agent
  - Incluye: Sub-agentes RESEARCHER, DATA-ANALYST, generación de visualizaciones y PDFs

### Blogs complementarios de Anthropic
- **"Building agents with the Claude Agent SDK"**:
  - https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk
- **"Effective context engineering for AI agents"**:
  - https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- **Carpeta completa de patrones de agentes**:
  - https://github.com/anthropics/anthropic-cookbook/tree/main/patterns/agents

### Documentación de usuario de Research
- **Centro de ayuda — Using Research on Claude**:
  - https://support.claude.com/en/articles/11088861-using-research-on-claude

### Documentación de la API (herramientas disponibles)
- **Web Search Tool**: https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/web-search-tool
- **Web Fetch Tool**: https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/web-fetch-tool

---

## 2. System prompts filtrados y publicados

### System prompt del modo Research (filtrado)
- **Autor**: @fun000001 (fisherdaddy) en X, 6 mayo 2025
  - https://x.com/fun000001/status/1919791886489006511
  - Contiene el bloque `<research_instructions>` con:
    - `launch_extended_search_task` como herramienta prioritaria
    - Reglas de preguntas clarificadoras (máx. 3)
    - Bloque `<harmful_content_safety>` para Research
    - Ejemplos de cuándo preguntar vs. lanzar directamente

### Colección completa de system prompts filtrados
- **Repositorio asgeirtj/system_prompts_leaks** (31.7K+ estrellas):
  - https://github.com/asgeirtj/system_prompts_leaks
  - Incluye prompts de Claude.ai, ChatGPT, Gemini y otros

### System prompts de Claude Code (built-in subagents)
- **Claude Code System Prompts by Piebald AI**:
  - Referenciado en: https://github.com/hesreallyhim/awesome-claude-code
  - Incluye: Tool descriptions, sub-agent prompts (Plan/Explore/Task), utility prompts

### Análisis de system prompts
- **PromptHub — "An Analysis of the Claude 4 System Prompt"**:
  - https://www.prompthub.us/blog/an-analysis-of-the-claude-4-system-prompt
- **DEJAN AI — "Claude System Internals"**:
  - https://dejan.ai/blog/claude-system-internals/
- **Simon Willison — Análisis del blog de Anthropic**:
  - https://simonwillison.net/2025/Jun/14/multi-agent-research-system/

---

## 3. Documentación de Claude Code

### Subagents (clave para la implementación)
- **Documentación oficial de subagents**:
  - https://code.claude.com/docs/en/sub-agents
  - Explica: Creación, frontmatter YAML, herramientas, modelos, permisos
  - **Comando clave**: `/agents` para crear/gestionar subagents interactivamente

### Estructura de archivos para subagents

```
~/.claude/agents/           # Subagents globales (todos los proyectos)
.claude/agents/             # Subagents por proyecto
```

**Formato del archivo** (`.md` con YAML frontmatter):

```yaml
---
name: deep-researcher
description: Research a topic thoroughly using web search, fetch, and parallel subagents. Use proactively for any research task.
tools: Read, Write, Bash, WebFetch, WebSearch, Task
model: opus
permissionMode: bypassPermissions
---

[System prompt del agente aquí]
```

### Skills (alternativa/complemento a subagents)
- **Documentación oficial de skills**:
  - https://code.claude.com/docs/en/skills
  - Skills con `context: fork` ejecutan en contexto aislado (como sub-agentes)
  - Soportan `agent: Explore | Plan | general-purpose | [custom]`

**Ejemplo de skill con fork**:
```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: general-purpose
---
Research $ARGUMENTS thoroughly:
1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

### Slash Commands
- **Documentación oficial**:
  - https://code.claude.com/docs/en/slash-commands
  - https://platform.claude.com/docs/en/agent-sdk/slash-commands
- **Ubicación**: `.claude/commands/` (proyecto) o `~/.claude/commands/` (global)

### Slash Commands en el SDK
- https://platform.claude.com/docs/en/agent-sdk/slash-commands

### Subagents en el SDK
- https://platform.claude.com/docs/en/agent-sdk/subagents

### Plugins (empaquetado de skills + subagents + commands)
- https://code.claude.com/docs/en/plugins

### Guías de la comunidad sobre customización
- **alexop.dev — "Claude Code Customization Guide"**:
  - https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/
  - Incluye ejemplo de slash command de research con subagents paralelos
- **Product Talk — "How to Use Claude Code: Slash Commands, Agents, Skills, Plug-ins"**:
  - https://www.producttalk.org/how-to-use-claude-code-features/
- **Young Leaders Tech — "Understanding Claude Code: Skills vs Commands vs Subagents"**:
  - https://www.youngleaders.tech/p/claude-skills-commands-subagents-plugins
- **Jason Liu — "Slash Commands vs Subagents"**:
  - https://jxnl.co/writing/2025/08/29/context-engineering-slash-commands-subagents/
- **Shrivu Shankar — "How I Use Every Claude Code Feature"**:
  - https://blog.sshh.io/p/how-i-use-every-claude-code-feature
- **Sankalp — "A Guide to Claude Code 2.0"**:
  - https://sankalp.bearblog.dev/my-experience-with-claude-code-20-and-how-to-get-better-at-using-coding-agents/
- **Cranot — "The Complete Claude Code CLI Guide"**:
  - https://github.com/Cranot/claude-code-guide

### Lista curada de plugins y extensiones
- **awesome-claude-code**:
  - https://github.com/hesreallyhim/awesome-claude-code

---

## 4. Servidores MCP necesarios

### Búsqueda web — Brave Search (recomendado)
```bash
claude mcp add brave-search \
  -e BRAVE_API_KEY=$BRAVE_API_KEY \
  -- npx -y @modelcontextprotocol/server-brave-search
```
- Repo: https://github.com/modelcontextprotocol/servers/tree/main/src/brave-search
- API Key: https://brave.com/search/api/

### Fetch de páginas web
```bash
claude mcp add fetch \
  -- npx -y @modelcontextprotocol/server-fetch
```
- Repo: https://github.com/modelcontextprotocol/servers/tree/main/src/fetch

### Puppeteer (opcional, para JS-heavy pages)
```bash
claude mcp add puppeteer \
  -- npx -y @modelcontextprotocol/server-puppeteer
```
- Repo: https://github.com/modelcontextprotocol/servers/tree/main/src/puppeteer

### Filesystem (para guardar reportes)
```bash
claude mcp add filesystem \
  -- npx -y @modelcontextprotocol/server-filesystem /ruta/a/reportes
```

### Sandbox de ejecución (opcional, para análisis de datos)
```bash
claude mcp add e2b \
  -e E2B_API_KEY=$E2B_API_KEY \
  -- npx -y @e2b/mcp-server
```

### Deep Research MCP combinado (Brave + Puppeteer)
- **brave-deep-research-mcp** by suthio:
  - https://github.com/suthio/brave-deep-research-mcp
  - Combina Brave Search con Puppeteer para extracción profunda
  ```bash
  npx @suthio/brave-deep-research-mcp
  ```

### Deep Research MCP (DuckDuckGo + Semantic Scholar)
- **mcherukara/Claude-Deep-Research**:
  - https://github.com/mcherukara/Claude-Deep-Research
  - Herramienta `deep_research` para Claude Desktop
  ```bash
  pip install mcp httpx beautifulsoup4
  git clone https://github.com/mcherukara/Claude-Deep-Research.git
  ```

### Directorio general de servidores MCP
- https://github.com/modelcontextprotocol/servers
- https://www.pulsemcp.com/ (directorio con búsqueda)
- https://claudelog.com/claude-code-mcps/ (curado para Claude Code)

---

## 5. Repositorios de la comunidad

### Implementaciones específicas para Claude Code

| Repo | Estrellas | Descripción | URL |
|------|-----------|-------------|-----|
| **willccbb/claude-deep-research** | ~222 | Config de Claude Code con Brave + E2B + Filesystem MCP | https://github.com/willccbb/claude-deep-research |
| **AnkitClassicVision/Claude-Code-Deep-Research** | ~67 | Playbook de 7 fases + Graph-of-Thoughts | https://github.com/AnkitClassicVision/Claude-Code-Deep-Research |
| **gtrusler/claude-code-heavy** | — | Orquestador shell que lanza 2-8 Claude Code en paralelo | https://github.com/gtrusler/claude-code-heavy |
| **XInTheDark/gist (Custom Deep Research prompt)** | — | Prompt personalizado con MCP (Brave + Fetch + Puppeteer) | https://gist.github.com/XInTheDark/6fef041cb3edfe054b507813a03cb47d |

### `willccbb/claude-deep-research` — Detalles

Estructura del proyecto:
```
claude-deep-research/
├── CLAUDE.md          # System prompt completo
├── claude-dr          # Script de lanzamiento (configura MCPs)
├── reports/           # Directorio de salida
└── pyproject.toml
```

Script `claude-dr` configura los MCPs:
```bash
claude mcp add brave-search -e BRAVE_API_KEY=$BRAVE_API_KEY -- npx -y @modelcontextprotocol/server-brave-search
claude mcp add e2b -e E2B_API_KEY=$E2B_API_KEY -- npx -y @e2b/mcp-server
```

El CLAUDE.md instruye a:
1. Recibir consulta → hacer 2-3 preguntas clarificadoras
2. Entrar en "report writing mode"
3. Ejecutar búsquedas paralelas con diversidad de queries
4. Balancear breadth (amplio) y depth (profundo)
5. Target: ~20 citas con enlaces
6. Guardar en `reports/{topic-summary}-{YYYY-MM-DD}.md`

### Implementaciones con la API de Anthropic

| Repo | Estrellas | Descripción | URL |
|------|-----------|-------------|-----|
| **dzhng/deep-research** | ~18,400 | Implementación fundacional (<500 líneas TS), recursivo depth+breadth | https://github.com/dzhng/deep-research |
| **Cranot/deep-research** | ~84 | "Exploración fractal", 4 estrategias, 7 proveedores LLM | https://github.com/Cranot/deep-research |
| **langchain-ai/open_deep_research** | ~2,685 | LangGraph con supervisor-researcher | https://github.com/langchain-ai/open_deep_research |

### Guías y tutoriales
- **Paddo.dev — "Three Ways to Build Deep Research with Claude"**:
  - https://paddo.dev/blog/three-ways-deep-research-claude/
- **PulseMCP — "How to do Deep Research with Claude"**:
  - https://www.pulsemcp.com/use-cases/deep-research/claude-brave-google-playwright
- **DeepLearning.AI — "Agent Skills with Anthropic"** (curso):
  - https://www.deeplearning.ai/short-courses/agent-skills-with-anthropic/

---

## 6. Guía de implementación

### Opción A: Subagent personalizado (recomendado)

Crear `.claude/agents/deep-researcher.md`:

```yaml
---
name: deep-researcher
description: >
  Conducts comprehensive multi-source research on any topic. 
  Use PROACTIVELY when the user asks to research, investigate, 
  analyze, or compare topics that require web information.
  MUST BE USED for any query starting with "research", "investigate",
  or "find out about".
tools: Read, Write, Bash, WebFetch, WebSearch, Grep, Glob
model: sonnet
---

You are an expert research analyst. Your job is to conduct thorough, 
multi-source research and produce comprehensive, well-cited reports.

## Research Process (OODA Loop)

### 1. OBSERVE — Understand the Query
- Parse the research question into sub-questions
- Identify key entities, timeframes, and scope
- Determine what types of sources would be most authoritative

### 2. ORIENT — Plan the Research
- Create a research plan with 3-5 distinct investigation angles
- For each angle, prepare 2-3 search queries (short, 1-6 words)
- Prioritize original sources over aggregators

### 3. DECIDE — Execute Searches
- Run searches in parallel when possible
- Start broad, then narrow based on results
- For each promising result, use web_fetch to get full content
- Evaluate source quality: prefer .gov, .edu, peer-reviewed, 
  official company blogs over forums and aggregators
- Flag contradictions between sources
- Track citations as you go: [Source Title](URL)

### 4. ACT — Synthesize and Report
- Cross-reference findings across sources
- Identify consensus vs. disputed claims
- Structure findings logically
- Cite every factual claim

## Output Format

Produce a structured markdown report:
- Title and date
- Executive summary (3-5 sentences)
- Detailed findings organized by theme
- Key takeaways / conclusions
- Sources cited (numbered, with URLs)

## Rules
- Minimum 10 unique web sources per report
- Every factual claim must be cited
- Flag low-confidence or contradictory findings
- Use parallel tool calls for efficiency
- Do NOT stop after first search — iterate until thorough
- Target 15-25 citations in the final report
```

### Opción B: Slash command con subagents paralelos

Crear `.claude/commands/research.md`:

```yaml
---
description: Research a problem using web search, documentation, and parallel exploration
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Bash, Grep, Glob
---

# Deep Research: $ARGUMENTS

## Instructions

Conduct thorough multi-source research on the following topic:

> **$ARGUMENTS**

### Step 1: Launch Parallel Research Agents

Use the Task tool to spawn these subagents **in parallel** (all in a single message):

1. **Web Research Agent** (subagent_type: general-purpose)
   - Search for authoritative sources on the topic
   - Use web_fetch to read full articles (not just snippets)
   - Find 5-10 high-quality sources
   - Return: key findings with source URLs

2. **Counter-Perspective Agent** (subagent_type: general-purpose)
   - Search for opposing viewpoints, critiques, or limitations
   - Look for recent developments that may change the picture
   - Return: contrarian findings with source URLs

3. **Data & Statistics Agent** (subagent_type: general-purpose)
   - Search for quantitative data, statistics, benchmarks
   - Look for official reports, surveys, studies
   - Return: numerical findings with source URLs

### Step 2: Synthesize Results

After all agents report back:
- Cross-reference findings across agents
- Identify areas of consensus and disagreement
- Note any gaps that need additional research
- If gaps exist, launch 1-2 more targeted subagents

### Step 3: Write Report

Create a comprehensive markdown report in `reports/` with:
- Executive summary
- Detailed findings by theme
- Data and statistics section
- Contrarian perspectives
- Conclusions and recommendations
- Full bibliography with numbered citations
```

### Opción C: Skill con fork (contexto aislado)

Crear `.claude/skills/deep-research/SKILL.md`:

```yaml
---
name: deep-research
description: >
  Thorough multi-source research agent. Activates for research,
  investigation, analysis, or comparison tasks requiring web info.
context: fork
agent: general-purpose
---

# Deep Research Skill

Research the following topic thoroughly: $ARGUMENTS

[Incluir aquí el system prompt del Opción A]
```

### Opción D: Plugin completo (distribuible)

Estructura de un plugin:
```
deep-research-plugin/
├── manifest.json
├── agents/
│   ├── lead-researcher.md    # Orquestador (Opus)
│   └── research-worker.md    # Worker (Sonnet)
├── commands/
│   └── research.md           # /research slash command
├── skills/
│   └── deep-research/
│       └── SKILL.md
└── install.sh                # Configura MCPs
```

`manifest.json`:
```json
{
  "name": "deep-research",
  "version": "1.0.0",
  "description": "Multi-agent deep research system for Claude Code",
  "components": {
    "agents": ["agents/lead-researcher.md", "agents/research-worker.md"],
    "commands": ["commands/research.md"],
    "skills": ["skills/deep-research"]
  }
}
```

---

## 7. Arquitectura del sistema original

### Los 3 agentes de Claude.ai Research

```
┌─────────────────────────────────────────────┐
│              LeadResearcher                  │
│         (Claude Opus 4 + Extended Thinking)  │
│                                              │
│  1. Recibe consulta                         │
│  2. Guarda plan en Memory                   │
│  3. Delega a sub-agentes en paralelo        │
│  4. Sintetiza resultados                    │
│  5. Itera si hay gaps                       │
│  6. Genera reporte final                    │
└──────┬──────┬──────┬──────┬────────────────┘
       │      │      │      │
       ▼      ▼      ▼      ▼
┌──────┐┌──────┐┌──────┐┌──────┐
│Sub-  ││Sub-  ││Sub-  ││Sub-  │
│agent ││agent ││agent ││agent │
│  1   ││  2   ││  3   ││  N   │
│Sonnet││Sonnet││Sonnet││Sonnet│
└──┬───┘└──┬───┘└──┬───┘└──┬───┘
   │       │       │       │
   ▼       ▼       ▼       ▼
 Contextos independientes (200K c/u)
 web_search + web_fetch en paralelo
   │       │       │       │
   └───────┴───────┴───────┘
                │
                ▼
       ┌────────────────┐
       │ CitationAgent  │
       │ (precisión     │
       │  de citas)     │
       └────────────────┘
                │
                ▼
         Reporte final
         con citas
```

### Reglas de escalamiento (del prompt original)

| Complejidad | Sub-agentes | Herramientas/agente | Ejemplo |
|-------------|-------------|---------------------|---------|
| Simple | 1 | 3-10 | "¿Qué es X?" |
| Comparación | 2-4 | 10-15 | "Compara A vs B" |
| Investigación compleja | 5-10+ | 15-20 | "Análisis del mercado de..." |

### Hallazgo clave de Anthropic
> **El uso de tokens explica el 80% de la varianza en rendimiento.**
> Más tokens = mejores resultados. La arquitectura multi-agente es un mecanismo para escalar tokens más allá de los límites de un solo agente.

---

## 8. Recursos adicionales

### Análisis y comparativas
- **ByteByteGo — "How Anthropic Built a Multi-Agent Research System"**:
  - https://blog.bytebytego.com/p/how-anthropic-built-a-multi-agent
- **ByteByteGo — "How OpenAI, Gemini, and Claude Use Agents to Power Deep Research"**:
  - https://blog.bytebytego.com/p/how-openai-gemini-and-claude-use
- **01cloud — "Claude Meets the Research Team: Inside Anthropic's Multi-Agent Masterpiece"**:
  - https://engineering.01cloud.com/2025/06/30/claude-meets-the-research-team-inside-anthropics-multi-agent-masterpiece/
- **ZenML — "Building a Multi-Agent Research System for Complex Information Tasks"**:
  - https://www.zenml.io/llmops-database/building-a-multi-agent-research-system-for-complex-information-tasks
- **Medium (Agent Native) — "Reverse Engineering Anthropic's Agent Blueprint"**:
  - https://agentnativedev.medium.com/reverse-engineering-anthropics-agent-blueprint-to-outperform-claude-opus-4-by-90-564f20a0e0a3

### Context Engineering
- **Substack (Thomas Landgraf) — "Context Engineering for Claude Code"**:
  - https://thomaslandgraf.substack.com/p/context-engineering-for-claude-code

### Competidores (para referencia)
- **OpenAI Deep Research**: https://openai.com/index/introducing-deep-research/
- **Gemini Deep Research**: https://gemini.google/overview/deep-research/
- **Gemini Deep Research API**: https://ai.google.dev/gemini-api/docs/deep-research
- **Perplexity Deep Research**: https://www.perplexity.ai/hub/blog/introducing-perplexity-deep-research
- **PromptLayer — "How OpenAI's Deep Research Works"**: https://blog.promptlayer.com/how-deep-research-works/

### Costos estimados de replicación
- Implementación optimizada (Sonnet workers): **$0.20 - $0.60 por consulta**
- Con spawning agresivo (Opus leader + múltiples Sonnet): **$1 - $5 por consulta**
- Claude.ai Research nativo: incluido en planes Pro ($20), Max ($100)

---

## Checklist de implementación rápida

```
□ 1. Obtener API keys:
  □ Brave Search API (https://brave.com/search/api/)
  □ (Opcional) E2B API para sandbox

□ 2. Configurar MCPs en Claude Code:
  □ claude mcp add brave-search ...
  □ claude mcp add fetch ...
  □ (Opcional) claude mcp add puppeteer ...

□ 3. Crear el subagent/skill/command:
  □ .claude/agents/deep-researcher.md (Opción A)
  □ O .claude/commands/research.md (Opción B)
  □ O .claude/skills/deep-research/SKILL.md (Opción C)

□ 4. Crear directorio de salida:
  □ mkdir -p reports/

□ 5. Probar:
  □ claude "Use deep-researcher to investigate [topic]"
  □ O claude "/research [topic]"

□ 6. Iterar el prompt basándose en resultados
```

---

*Documento generado el 19 de febrero de 2026. Todas las URLs verificadas al momento de generación.*
