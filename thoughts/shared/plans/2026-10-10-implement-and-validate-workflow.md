# Workflow `implement-and-validate` Implementation Plan

## Overview

Añadir al plugin `stepwise-core` un workflow dinámico de Claude Code, `/stepwise-core:implement-and-validate`, que implementa un plan de `thoughts/shared/plans/` fase a fase (tdd → bugmagnet → mutation-testing → test-desiderata → verificación → checkboxes) y lo valida al final con un agente independiente en hasta 3 rondas de corrección. El orden de los pasos lo garantiza el script, no las instrucciones.

## Current State Analysis

- `implement-plan` (`core/skills/implement-plan/SKILL.md:49-83`) ya corre de seguido desde #16; la secuencia depende de que el modelo siga las instrucciones y todas las fases comparten un contexto.
- `tdd` ya no pide confirmación (#18). `bugmagnet` escribe tests y deja bugs como tests skip con "- BUG", sin tocar implementación (`bugmagnet/SKILL.md:21-29`); `test-desiderata` solo recomienda (`test-desiderata/SKILL.md:20`). Ninguna pregunta al usuario.
- `validate-plan` (`validate-plan/SKILL.md:18-48`) no es interactiva; ejecuta la verificación del plan y produce un informe.
- No existe `core/workflows/`. Los plugins cargan workflows de `workflows/` en su raíz y los nombran `/<plugin>:<meta.name>` (docs workflows, "Distribute a workflow in a plugin").
- `codex/transpile-agents.sh:32` transpila todo `core/agents/*.md`; `test/codex-test.sh` fija 6 agentes (líneas 39, 45, 131, 134, 141-147, 151).

### Key Discoveries:
- El script de un workflow no tiene I/O: todo pasa por `agent()`. Sin `Date.now()`/`Math.random()`. `${CLAUDE_PLUGIN_ROOT}` no se sustituye en scripts.
- `agentType` solo resuelve agentes; el campo `skills:` de un agente precarga la skill completa al arrancar (docs sub-agents, "Preload skills into subagents"). Skills con `disable-model-invocation: true` no se pueden precargar (ninguna de las cuatro lo tiene).
- Los agentes de plugin ignoran `hooks`, `mcpServers`, `permissionMode`.
- Un `agent()` con `await` directo que falla termina el run; `agent()` devuelve `null` si el usuario lo para.

## Desired End State

`/stepwise-core:implement-and-validate thoughts/shared/plans/<plan>.md`:
1. Lee el plan y salta las fases con todos sus criterios automáticos (con comando) marcados.
2. Por cada fase pendiente: `tdd-implementer` → `bug-hunter` por fichero de implementación (bugs con `worthFixing` vuelven a `tdd-implementer`) → `mutation-hunter` con `--changed` sobre los ficheros de producción de la fase → `test-reviewer` (incluye los tests añadidos por mutation) → ejecuta los comandos del plan (un intento de arreglo si fallan) → marca los checkboxes.
3. Valida siempre al final: `plan-validator` → `tdd-implementer` con los hallazgos arreglables, hasta 3 rondas de corrección, parando si el mismo conjunto de hallazgos se repite.
4. Devuelve un resumen en markdown con lo hecho, lo no resuelto, lo que necesita a una persona, la verificación manual pendiente y la sugerencia de `/stepwise-git:commit`.

Se para con un error "Issue in Phase N: Expected / Found / Why this matters" ante un mismatch estructural, una verificación que sigue roja, un plan sin comandos de verificación o la falta de la ruta del plan.

## What We're NOT Doing

- No se toca git (ni ramas, ni commits, ni PR). Vendrá en un plan posterior.
- No se modifican ni eliminan las skills `implement-plan` y `validate-plan`: coexisten (Codex y usuarios sin workflows).
- No se fijan modelos: todo `model: inherit` / modelo de la sesión.
- No hay tests de JS ni Node en el repo: la lógica del script se valida ejecutándolo.
- No se elimina Codex.

## Implementation Approach

El workflow solo orquesta; cada paso es un agente de `core/agents/` que precarga la skill existente, así las reglas siguen en un único sitio. Los agentes se transpilan a Codex con normalidad: su cuerpo nombra la skill, que Codex también tiene en `~/.agents/skills/`.

## Phase 1: Agentes del workflow

### Overview
Cinco agentes con `skills:` precargado y `model: inherit`.

### Changes Required:

#### 1. Agentes
**Files**: `core/agents/tdd-implementer.md`, `core/agents/bug-hunter.md`, `core/agents/mutation-hunter.md`, `core/agents/test-reviewer.md`, `core/agents/plan-validator.md`

| Agente | `skills:` | `tools` |
|---|---|---|
| `tdd-implementer` | `stepwise-core:tdd` | Read, Write, Edit, Grep, Glob, Bash |
| `bug-hunter` | `stepwise-core:bugmagnet` | Read, Write, Edit, Grep, Glob, Bash |
| `mutation-hunter` | `stepwise-core:mutation-testing`, `stepwise-core:tdd` | Read, Write, Edit, Grep, Glob, Bash |
| `test-reviewer` | `stepwise-core:test-desiderata` | Read, Write, Edit, Grep, Glob, Bash |
| `plan-validator` | `stepwise-core:validate-plan` | Read, Grep, Glob, Bash |

Cuerpo: aplicar la skill nombrada, no preguntar nunca (nadie responde), no tocar git, informar los bloqueos en la salida estructurada. `mutation-hunter` precarga también `tdd` y hace el traspaso de `mutation-testing` a `tdd` dentro del mismo agente, que ya ha leído la fase del plan: así `tdd` sabe qué comportamientos especifica el plan ("Pinning Existing Behavior").

#### 2. Codex y tests
- `make transpile-codex` regenera `codex/agents/`.
- `test/codex-test.sh`: los recuentos ya salen del repo; la aserción de solo lectura cuenta solo los agentes sin `Write`/`Edit`; añadir los 5 al bucle de contenido.
- `test/plugin-structure-test.sh`: añadir los 5 agentes a las aserciones de agentes y de TOML.

### Success Criteria:
- [x] Tests pasan: `make test`
- [x] Codex en sincronía: `make check-codex`

---

## Phase 2: Ciclo de implementación

### Overview
`core/workflows/implement-and-validate.js` con la lectura del plan, el salto de fases hechas, el ciclo por fase y las reglas de parada.

### Changes Required:

#### 1. Workflow
**File**: `core/workflows/implement-and-validate.js`
- `meta` literal con `name: 'implement-and-validate'`.
- `args`: ruta del plan (string o `{ planFile }`); si falta, error.
- Lectura del plan con un agente y esquema: fases con `automatedCriteria` (`text`, `command`, `checked`) y `manualCriteria`.
- Plan no verificable (alguna fase sin criterios con comando) → error.
- Fase hecha = todos sus criterios con comando marcados.
- Ciclo por fase en secuencia: tdd → bugmagnet por fichero de implementación → arreglo de bugs `worthFixing` → mutation-testing (`--changed`) → test-desiderata → comandos del plan (un intento de arreglo) → checkboxes.
- Si mutation-testing no puede revertir un mutante (`workingTreeIntact: false`) → error.

#### 2. Test de estructura
**File**: `test/plugin-structure-test.sh`
- El fichero existe, empieza por `export const meta` y declara `name: 'implement-and-validate'`.

### Success Criteria:
- [x] Tests pasan: `make test`

---

## Phase 3: Validación y resumen

### Overview
Bucle de validación y valor devuelto.

### Changes Required:

#### 1. Workflow
**File**: `core/workflows/implement-and-validate.js`
- Hasta 3 rondas de corrección: validar → si hay hallazgos `fixableByAgent`, `tdd-implementer` los corrige → validar de nuevo. Para si no quedan, si el conjunto se repite o si se agotan las rondas.
- Resumen markdown: fases implementadas y ya hechas, hallazgos sin resolver, hallazgos que necesitan a una persona, bugs encontrados y cómo se trató cada uno, mutantes supervivientes, mejoras de tests descartadas, verificación manual pendiente (incluye criterios automáticos sin comando), siguiente paso `/stepwise-git:commit`.

### Success Criteria:
- [x] Tests pasan: `make test`

---

## Phase 4: Documentación y versiones

### Changes Required:
- `AGENTS.md`, `README.md`, `core/README.md`: añadir el workflow y sus agentes, sin recuentos (estilo de `main`). Regla de sincronía en `AGENTS.md`.
- `core/.claude-plugin/plugin.json`: `1.6.2` → `1.7.0` (componentes nuevos).
- `.claude-plugin/marketplace.json`: entrada `stepwise-core` a `1.7.0`; versión top-level `2.0.5` → `2.0.6`.

### Success Criteria:
- [x] CI completo pasa: `make ci`

---

## Phase 5: Validación manual en stepwise-todo-api-test

### Overview
Ejecutar el workflow de verdad en [`nikeyes/stepwise-todo-api-test`](https://github.com/nikeyes/stepwise-todo-api-test) (Python, `uv`, `make test`, `make check`), con el plugin local cargado.

### Changes Required:
- En ese repo, una rama por ejecución (`try/implement-and-validate-N` desde `main`) y un plan de 2 fases para `PATCH /todos/{id}` con `make test` y `make check` como criterios y un criterio vago a propósito.

### Success Criteria:

#### Manual Verification:
- [ ] Camino feliz: ambas fases implementadas, checkboxes marcados, el criterio vago aparece en el resumen como "needs a human"
- [ ] Los agentes cargan sus skills (sin avisos de skill no encontrada en el log de depuración); si no, cambiar `skills:` a nombre sin namespace
- [ ] Parada: con un plan que referencia un fichero inexistente, el run se para con "Issue in Phase N"; tras corregir el plan y relanzar, retoma desde la fase pendiente
- [ ] Relanzar sobre el plan completo solo ejecuta la validación

## Testing Strategy

- Estructura en bash (`make test`): agentes, TOML y workflow presentes.
- Comportamiento: ejecución manual de la fase 5.

## References

- Informe: `reports/Migrar implement plan a workflows 2.md`
- Notas: `research_notes/Migrar implement plan a workflows 2/`
- Ejemplo: https://github.com/nikeyes/540-ai-development-training/blob/harness/.claude/workflows/implement.mjs
- Docs: https://code.claude.com/docs/en/workflows, https://code.claude.com/docs/en/sub-agents
