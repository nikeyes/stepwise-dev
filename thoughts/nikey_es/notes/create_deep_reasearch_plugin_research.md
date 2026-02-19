# Anatomía completa del agente Research de Claude.ai

**La función Research de Claude.ai es un sistema multi-agente con patrón orquestador-trabajador**, donde un agente líder (Claude Opus 4) coordina múltiples sub-agentes especializados (Claude Sonnet 4) que buscan información en paralelo, cada uno con su propia ventana de contexto de 200K tokens. Este sistema superó al Claude Opus 4 en modo single-agent por un **90.2%** en las evaluaciones internas de Anthropic. Anthropic publicó en junio de 2025 un blog de ingeniería extraordinariamente detallado documentando toda la arquitectura, y la comunidad ha filtrado los system prompts completos que gobiernan tanto el modo Research dedicado como las instrucciones de búsqueda del chat regular.

---

## Tres agentes distintos conforman la arquitectura

El sistema Research opera con tres tipos de agentes claramente diferenciados, según documenta el blog de ingeniería de Anthropic ("How we built our multi-agent research system", publicado el 13 de junio de 2025 por Jeremy Hadfield, Barry Zhang y equipo):

**LeadResearcher (Orquestador):** Ejecuta Claude Opus 4 con extended thinking mode activado. Recibe la consulta del usuario, analiza la complejidad, desarrolla un plan de investigación y lo guarda en una herramienta de **Memory** (crítica porque si el contexto supera 200K tokens se trunca, y el plan debe persistir). Luego delega tareas específicas a sub-agentes, sintetiza sus resultados, y decide si necesita más investigación o puede proceder a generar el reporte final.

**Subagents (Trabajadores):** Ejecutan Claude Sonnet 4 con interleaved thinking (razonamiento intercalado entre llamadas a herramientas). Cada sub-agente opera **independientemente** con su propia ventana de contexto, ejecuta búsquedas web iterativamente, evalúa la calidad de los resultados, y devuelve hallazgos comprimidos al LeadResearcher. Funcionan como "filtros inteligentes" y "motores de compresión" — exploran extensamente y destilan lo más importante.

**CitationAgent:** Procesa el reporte final e identifica con precisión quirúrgica dónde corresponde cada cita. Reduce las alucinaciones de fuentes de ~10% a prácticamente 0%. Opera después de que el LeadResearcher completa la síntesis.

La clave arquitectónica es que los sub-agentes operan en **contextos separados**, lo que resuelve el problema fundamental de la ventana de contexto limitada. Como señaló Simon Willison en su análisis: el beneficio principal es gestionar el límite de 200K tokens distribuyendo el trabajo en contextos independientes.

---

## El system prompt filtrado revela dos capas de instrucciones

Los system prompts han sido extensamente documentados por la comunidad. Existen **dos capas** de instrucciones de búsqueda distintas:

**Capa 1 — El prompt del modo Research dedicado** fue filtrado por @fun000001 (fisherdaddy) en X el 6 de mayo de 2025. Cuando el usuario activa el botón Research en la interfaz, Claude.ai inyecta un bloque `<research_instructions>` que incluye:

- Instrucción de usar `launch_extended_search_task` como herramienta prioritaria sobre todas las demás
- Solo dos excepciones: mensajes conversacionales básicos ("hola") o preguntas extremadamente simples ("capital de Francia")
- Reglas de preguntas clarificadoras: máximo 3 preguntas, solo cuando hay ambigüedades genuinas; si el usuario dice "Research X" explícitamente, lanzar inmediatamente
- Instrucciones de seguridad específicas para el modo Research (bloque `<harmful_content_safety>`)
- Ejemplos trabajados mostrando cuándo preguntar vs. cuándo lanzar directamente

**Capa 2 — Las instrucciones de búsqueda del chat regular** (~6,471 tokens) clasifican cada consulta en cuatro categorías: Never Search (hechos atemporales), Do Not Search But Offer (datos estables), Single Search (datos en tiempo real), y **Research** (análisis multi-fuente que requiere 2-20 llamadas a herramientas). El prompt incluye un flowchart de decisión basado en complejidad, e instruye que si una tarea necesita más de 20 llamadas, debe sugerir al usuario activar la función Research dedicada.

Los prompts de los agentes de investigación están publicados oficialmente en el Anthropic Cookbook en GitHub: el prompt del agente líder en `anthropic-cookbook/patterns/agents/prompts/research_lead_agent.md` y el del sub-agente en `research_subagent.md`. El sub-agente usa un **loop OODA** (Observe, Orient, Decide, Act) como ciclo de investigación central, con un límite duro de **20 llamadas a herramientas y ~100 fuentes** antes de ser terminado.

Las filtraciones completas están recopiladas en el repositorio `asgeirtj/system_prompts_leaks` (31.7K estrellas), con análisis detallados publicados por Simon Willison, PromptHub, O'Reilly Radar, y DEJAN AI.

---

## Siete herramientas componen el arsenal del agente

El sistema Research tiene acceso a las siguientes herramientas documentadas:

- **`web_search`** — búsqueda web (se cree que usa Brave Search, con latencia de ~0.56 segundos por consulta)
- **`web_fetch`** — recupera el contenido completo de páginas web, no solo snippets
- **`launch_extended_search_task`** — la herramienta clave del modo Research, que instancia sub-agentes independientes
- **`Memory`** — persiste el plan de investigación y hallazgos clave para sobrevivir truncamientos de contexto
- **Servidores MCP** — conectan con herramientas externas como Google Workspace (Gmail, Calendar, Drive, Docs), Slack, y otras integraciones
- **`complete_task`** — herramienta que los sub-agentes invocan para devolver su reporte al agente líder
- **Llamadas paralelas a herramientas** — directiva `<use_parallel_tool_calls>` que obliga a invocar herramientas simultáneamente

La orquestación opera en **dos niveles de paralelización**: el agente líder lanza **3-5 sub-agentes en paralelo**, y cada sub-agente ejecuta **3+ herramientas en paralelo**. Este doble nivel de paralelismo redujo el tiempo de investigación hasta un **90%** para consultas complejas.

---

## El flujo paso a paso desde consulta hasta reporte citado

El workflow completo sigue estas fases:

**1. Recepción y clasificación.** El agente líder recibe la consulta y usa extended thinking para evaluar su complejidad. Aplica reglas de escalamiento embebidas en el prompt: consultas simples → 1 agente con 3-10 llamadas; comparaciones → 2-4 sub-agentes con 10-15 llamadas cada uno; investigación compleja → **10+ sub-agentes** con responsabilidades claramente divididas.

**2. Planificación y persistencia.** El LeadResearcher desarrolla un plan de investigación detallado y lo guarda en Memory. Este paso es crucial porque si el contexto se trunca a 200K tokens, el plan sobrevive.

**3. Delegación paralela.** El agente líder crea sub-agentes con instrucciones extremadamente específicas: objetivo concreto, formato de salida esperado, contexto relevante, fuentes sugeridas, y límites de alcance para evitar solapamiento.

**4. Investigación independiente.** Cada sub-agente ejecuta un loop iterativo: busca con queries **cortas y amplias** (menos de 5 palabras), evalúa resultados con interleaved thinking, luego progresivamente estrecha el enfoque. La estrategia de búsqueda imita la investigación humana experta: explorar el panorama antes de profundizar en detalles.

**5. Síntesis iterativa.** El LeadResearcher reúne los hallazgos comprimidos de todos los sub-agentes, evalúa la completitud, e identifica vacíos. Si hay gaps, puede lanzar sub-agentes adicionales o refinar la estrategia. Este loop continúa hasta que la información es suficiente.

**6. Citación.** El CitationAgent procesa el reporte final y mapea cada afirmación a sus fuentes con precisión (números de página, índices de caracteres, bloques de contenido).

**7. Entrega.** El reporte citado se presenta al usuario, típicamente como un documento de ~5 páginas con 20-25 fuentes, completado en **2-6 minutos**.

Un dato revelador: **86.7% de las citas finales provienen de los resultados de búsqueda iniciales**, y el sistema re-busca automáticamente cuando la confianza cae por debajo del 95%.

---

## La documentación oficial es excepcionalmente transparente

Anthropic ha publicado documentación técnica de calidad extraordinaria sobre este sistema:

El **blog de ingeniería** en `anthropic.com/engineering/multi-agent-research-system` es la fuente definitiva, con arquitectura completa, métricas de rendimiento, modos de fallo tempranos, y 8 principios de diseño de prompts. Complementariamente, el blog "Building agents with the Claude Agent SDK" documenta el SDK (renombrado de "Claude Code SDK") que permite construir agentes similares, y el blog "Effective context engineering for AI agents" detalla las técnicas de gestión de contexto.

El **Anthropic Cookbook** en GitHub contiene los prompts de producción del agente líder y del sub-agente, lo que constituye un caso excepcional de transparencia — ningún otro proveedor ha publicado los prompts reales de su sistema de investigación. Además, el repositorio `anthropics/claude-agent-sdk-demos/tree/main/research-agent` incluye una implementación oficial de referencia con agentes RESEARCHER, DATA-ANALYST, y generación de visualizaciones.

El **anuncio de producto** en `anthropic.com/news/research` describe las capacidades desde la perspectiva del usuario, y la documentación de la API en `docs.anthropic.com` cubre la herramienta web_search para uso programático (una versión simplificada single-agent del sistema completo de Research).

---

## Más de 20 proyectos de la comunidad replican la funcionalidad

La comunidad ha creado un ecosistema vibrante de proyectos open-source que replican la funcionalidad Research:

**Proyectos específicos para Claude Code** incluyen `willccbb/claude-deep-research` (222 estrellas), que es un wrapper de Claude Code con MCP servers (Brave Search, E2B sandbox, filesystem); `AnkitClassicVision/Claude-Code-Deep-Research` (67 estrellas), con un playbook de 7 fases y Graph-of-Thoughts; y `gtrusler/claude-code-heavy`, un orquestador shell que lanza 2-8 asistentes Claude Code en paralelo.

**Implementaciones con la API de Anthropic** son abundantes: `dzhng/deep-research` (**18,400 estrellas**) es el proyecto fundacional — menos de 500 líneas de TypeScript con exploración recursiva depth-first + breadth-first; `Cranot/deep-research` (84 estrellas) implementa "exploración fractal" con 4 estrategias de investigación y soporte para 7 proveedores LLM incluyendo Claude; y `langchain-ai/open_deep_research` (~2,685 estrellas) usa LangGraph con arquitectura supervisor-researcher compatible con modelos Anthropic.

**Servidores MCP** como `mcherukara/Claude-Deep-Research` proporcionan una herramienta `deep_research` para Claude Desktop usando DuckDuckGo y Semantic Scholar. El gist de XInTheDark ofrece un prompt personalizado completo con MCP servers (Brave Search, Fetch, Puppeteer) que el autor argumenta produce mejores resultados que el Research integrado.

**La implementación oficial de referencia** en `anthropics/claude-agent-sdk-demos` usa el Claude Agent SDK con sub-agentes tipados (RESEARCHER-1, DATA-ANALYST-1), hooks de seguimiento, y generación de PDFs con visualizaciones. El curso "Agent Skills with Anthropic" de DeepLearning.AI (enseñado por Elie Schoppik) cubre la construcción de estos agentes paso a paso.

El costo de replicación en producción oscila entre **$0.20-0.60 por consulta** para implementaciones optimizadas, pudiendo llegar a $1-5 con spawning recursivo agresivo.

---

## Claude es el único sistema genuinamente multi-agente entre sus competidores

La comparación arquitectónica con otros sistemas de deep research revela diferencias fundamentales:

**OpenAI Deep Research** usa un agente único basado en o3 (o o4-mini para la versión ligera), entrenado end-to-end con reinforcement learning en entornos simulados de investigación. No es multi-agente — es un modelo de razonamiento extendido con un loop ReAct (Plan-Act-Observe). Ejecuta 30-60 búsquedas, lee 120-150 páginas, y tarda **5-30 minutos** produciendo reportes extensos de 8,000-15,000+ palabras. Su fortaleza es la profundidad analítica; su debilidad es la lentitud y el precio (requiere suscripción Pro de $200/mes para uso completo).

**Gemini Deep Research** de Google opera como un agente único con gestor asíncrono de tareas y una ventana de contexto de **1M+ tokens**. Su diferenciador es que presenta el plan de investigación al usuario para revisión antes de ejecutar (único entre los competidores). Ejecuta 80-160 queries de búsqueda, tarda **15-60 minutos** (el más lento), pero lidera en precisión de datos según benchmarks independientes. Es nativamente multimodal (texto, imágenes, audio, video) y se integra profundamente con el ecosistema Google.

**Perplexity Deep Research** usa un pipeline RAG iterativo con routing multi-modelo (Sonar propietario + GPT-5, Claude 4.5, Gemini). No es multi-agente sino un loop iterativo de 3-5 pasadas secuenciales sobre infraestructura Vespa.ai. Es **el más rápido** (2-4 minutos) y **el más accesible** ($20/mes), con la mejor transparencia de citas (cada respuesta tiene citas numeradas con enlaces directos). Lidera en accuracy en el benchmark DR-50 de AIMultiple con **34%**.

| Dimensión | Claude Research | OpenAI Deep Research | Gemini Deep Research | Perplexity |
|---|---|---|---|---|
| **Arquitectura** | Multi-agente (orquestador + workers paralelos) | Agente único con RL | Agente único con task manager async | Pipeline RAG iterativo |
| **Modelo** | Opus 4 (líder) + Sonnet 4 (sub-agentes) | o3 / o4-mini | Gemini 3 Pro | Multi-modelo (routing) |
| **Sub-agentes** | Sí (1-10+) | No | No | No |
| **Tiempo típico** | 2-6 minutos | 5-30 minutos | 15-60 minutos | 2-4 minutos |
| **Búsquedas** | Variable (3-100+ distribuidas entre sub-agentes) | 30-60 | 80-160 | Docenas (3-5 pasadas) |
| **Precio mínimo** | $100/mes (Max) | $20/mes (Plus, limitado) | $20/mes (Advanced) | $20/mes (Pro) |
| **Fortaleza** | Cobertura de fuentes, paralelismo | Profundidad analítica | Precisión, multimodal | Velocidad, citas |

El hallazgo más significativo de Anthropic es que el **uso de tokens explica el 80% de la varianza en rendimiento** — más tokens equivale a mejores resultados. La arquitectura multi-agente es fundamentalmente un mecanismo para escalar el consumo de tokens más allá de los límites de un agente único, con cada sub-agente aportando su propio presupuesto de 200K tokens al esfuerzo colectivo.

---

## Conclusión: transparencia como ventaja competitiva

Lo más notable del sistema Research de Claude.ai no es solo su arquitectura — es el nivel de transparencia con que Anthropic la ha documentado. Mientras OpenAI, Google y Perplexity mantienen sus implementaciones como cajas negras, Anthropic publicó el blog de ingeniería más detallado de la industria sobre diseño de agentes, junto con los prompts de producción reales en GitHub. Esta transparencia ha catalizado un ecosistema de más de 20 proyectos open-source que replican y extienden la funcionalidad.

Los modos de fallo documentados son igualmente valiosos: agentes tempranos lanzaban 50 sub-agentes para consultas simples, elegían granjas de contenido SEO sobre fuentes autoritativas, y se distraían mutuamente con actualizaciones excesivas. Las soluciones — reglas de escalamiento embebidas, estrategia de búsqueda "ancha primero", y sub-agentes como filtros de compresión — representan lecciones prácticas que ningún paper académico sobre sistemas multi-agente ha articulado con esta claridad.

Para quien desee replicar el sistema, el camino más directo es el Claude Agent SDK con los prompts del Anthropic Cookbook como punto de partida, complementado con Brave Search API para búsquedas web y MCP servers para integraciones. El patrón arquitectónico fundamental es sorprendentemente simple: **planificar → delegar en paralelo → comprimir resultados → iterar si hay gaps → citar**. La complejidad está en los detalles de prompt engineering, no en la orquestación.