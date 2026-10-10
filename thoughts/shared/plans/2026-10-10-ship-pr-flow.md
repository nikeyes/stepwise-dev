# Flujo desatendido `ship-pr` Implementation Plan

## Overview

Convertir `stepwise-git` en un flujo desatendido que lleva el trabajo actual hasta una PR lista para merge: commit, push, PR, espera de checks, arreglo de checks rojos y respuesta a los comentarios de review, en hasta 3 rondas de arreglo. Son cuatro skills: `commit` y `review-pr-comments` pasan a ser desatendidas, y se añaden `open-pr` y la orquestadora `ship-pr`. Nunca hace merge.

## Current State Analysis

- `commit` (`git/skills/commit/SKILL.md:15,28`) pide confirmación antes de cada commit.
- `review-pr-comments` (`git/skills/review-pr-comments/SKILL.md:47,53-54`) itera con el usuario hasta acordar y solo responde en los hilos: nunca implementa el arreglo que anuncia en `Fix:`.
- Nada hace push, crea la PR, espera los checks ni arregla un check rojo.
- `stepwise-git` no depende de ningún otro plugin en ejecución. `implement-plan` (`core/skills/implement-plan/SKILL.md:140`) y el workflow (`core/workflows/implement-and-validate.js:514`) solo sugieren `/stepwise-git:commit` como texto.

### Key Discoveries:
- `implement-plan` es el modelo de orquestadora: delega con la herramienta `Skill` y anula la interacción en el punto de llamada (`core/skills/implement-plan/SKILL.md:33-37,55,66-68`).
- `tdd` no pregunta nada y espera el trabajo descrito como una fase: cambios de interfaz y comportamientos (`core/skills/tdd/SKILL.md:49`). No tiene `disable-model-invocation`, así que se puede invocar con `Skill`.
- `test/plugin-structure-test.sh:232-244` exige `agents/openai.yaml` a toda skill que declare `disable-model-invocation`: con `false`, debe contener `allow_implicit_invocation: true`. Una skill nueva sin ese fichero pone `make test` en rojo.
- `test/plugin-structure-test.sh:124-127` lista a mano las skills de git. `codex/install.sh:14-17` y `test/codex-test.sh:25-26` las descubren por glob, sin lista.
- `allowed-tools` preaprueba herramientas, no las restringe. `tdd` ejecuta los tests del proyecto, que son comandos arbitrarios: que el flujo no se pare en un aviso de permiso depende del modo de permisos de la sesión.
- Un comando en primer plano tiene un tope de 10 minutos, menor que la espera de 30 minutos de los checks.
- `make version-bump` no forma parte de `make ci` y compara commits contra `origin/main` (`scripts/check-version-bumps.sh:28,79`): solo sirve de criterio una vez commiteado.
- En este repo dos de los tres checks no son de código: el título de la PR (`.github/workflows/pr-checks.yml:13-22`) y el bump de versión.

## Desired End State

`/stepwise-git:ship-pr [plan]`, lanzado desde cualquier estado del repo, sin preguntar nada:

1. Crea una rama si está en la rama por defecto y hace commit de lo pendiente.
2. En cada ronda: push, PR (si no existe) y espera a que todos los checks terminen; arregla los rojos; decide sobre los comentarios pendientes, implementa los aceptados, los sube y responde en cada hilo.
3. Para cuando la PR está limpia, tras 3 rondas de arreglo, cuando no hay progreso, cuando los checks no terminan en 30 minutos o cuando un fallo no se puede arreglar desde el repo.
4. Devuelve un informe con la PR, los checks, las rondas, lo aceptado (con su commit), lo rechazado (con su razón) y lo que queda para el usuario.

Las tres piezas funcionan sueltas: `/stepwise-git:commit`, `/stepwise-git:open-pr` y `/stepwise-git:review-pr-comments [PR] [plan]`.

Verificación: `make ci` en verde y las ejecuciones manuales de la Phase 6.

## What We're NOT Doing

- No se integra en el workflow `implement-and-validate`, ni se crea un workflow nuevo. Solo cambia su texto de "Next steps".
- No se hace merge ni se resuelven hilos automáticamente.
- No se tocan los evals: `git/skills/commit-workspace/` y `core/skills/implement-plan-workspace/` quedan como están (se rehacen aparte).
- No se guarda copia de la descripción de la PR en `thoughts/shared/prs/`.
- No se añade un modo interactivo ni argumentos de modo: cada skill tiene un único comportamiento.
- No se añaden agentes a `stepwise-git`, así que `codex/agents/` no cambia.
- No se tocan `web/README.md:42` ni `core/README.md:69` (su frase sobre `stepwise-git` sigue siendo cierta), ni la referencia desfasada a `test/smoke-test.sh` en `AGENTS.md`.

## Implementation Approach

Cada skill es prosa en un `SKILL.md`; el contenido completo va en cada fase para que la implementación no tenga que decidir nada. Los tests del repo solo comprueban estructura, así que el único paso test-first es la aserción de existencia de las skills nuevas. El comportamiento se valida a mano en la Phase 6.

Reglas compartidas entre skills, cada una en un solo sitio:

| Regla | Vive en | La usan |
|---|---|---|
| Formato de commit, staging, sin atribución | `commit` | `review-pr-comments` y `ship-pr`, invocándola |
| Push, PR y espera de checks | `open-pr` | `ship-pr`, invocándola |
| Qué comentario está pendiente, criterio ACCEPT/REJECT | `review-pr-comments` | `ship-pr`, invocándola |
| Bucle, tope, paradas | `ship-pr` | — |

Dependencia blanda de `stepwise-core:tdd`: se usa si está disponible; si no, el arreglo se hace con un test que falle primero.

Las versiones se suben una sola vez, en la Phase 5.

## Phase 1: `commit` desatendida

### Overview
`commit` deja de pedir confirmación y hace explícito qué entra en el commit.

### Changes Required:

#### 1. Skill
**File**: `git/skills/commit/SKILL.md`
**Changes**: sustituir el fichero completo. Se conserva la cabecera SPDX.

```markdown
---
name: commit
description: Create git commits unattended, with semantic commit format and no Claude attribution
model: inherit
disable-model-invocation: false
allowed-tools: Bash(git status:*) Bash(git diff:*) Bash(git log:*) Bash(git add:*) Bash(git commit:*)
---

<!-- SPDX-License-Identifier: Apache-2.0
     SPDX-FileCopyrightText: 2024 humanlayer Authors (original)
     SPDX-FileCopyrightText: 2025 Jorge Castro (modifications) -->

# Commit Changes

Create git commit(s) for the uncommitted changes in the working tree. Do not ask for confirmation: decide, commit, then report what you committed.

## Rules

- **Format**: `TYPE([SCOPE])[!]: description` (e.g. `feat(kyc): add disapproval reason to kyc mail`)
  - **Types**: `feat`, `fix`, `refactor`, `perf`, `style`, `test`, `docs`, `build`, `ops`, `chore`, `revert`, `reapply`
  - **Scope**: optional, contextual (never a ticket id)
  - **Breaking change**: `!` before `:`, or a `BREAKING CHANGES:` footer
  - **Description**: imperative present tense, lowercase, no trailing period
  - **Body/footer**: optional; use to explain motivation and contrast with previous behavior
- **Splitting**: group related changes; multiple commits if the changes have distinct purposes
- **Staging**: `git add` each file by name, never `-A` or `.`. Stage every modified or new file that belongs to the work. Leave out anything that looks like a secret (`.env`, keys, credentials), a large binary or a generated artifact.
- **Never include**: ticket identifiers (Jira, Linear, etc.), Claude attribution, `Co-Authored-By` lines
- **Nothing to commit**: say so and stop.
- **Report**: the commits you created (hash and subject) and every file you left out, with the reason.
```

### Success Criteria:
- [x] Tests pasan: `make test`
- [x] Manifiestos válidos: `make validate`

---

## Phase 2: Skill `open-pr`

### Overview
Skill nueva de una pasada: push, PR si no existe, espera de checks e informe. No toca código.

### Changes Required:

#### 1. Test de estructura (primero, para verlo fallar)
**File**: `test/plugin-structure-test.sh`
**Changes**: tras la línea 127 añadir:

```bash
assert_file_exists "git/skills/open-pr/SKILL.md" "open-pr skill exists"
```

#### 2. Skill
**File**: `git/skills/open-pr/SKILL.md` (nuevo)

```markdown
---
name: open-pr
description: Push the current branch, open its pull request if it has none, and wait for every PR check to finish. Reports the result without fixing anything.
model: inherit
disable-model-invocation: false
allowed-tools: Bash(git status:*) Bash(git branch:*) Bash(git switch:*) Bash(git log:*) Bash(git diff:*) Bash(git push:*) Bash(gh repo view:*) Bash(gh pr view:*) Bash(gh pr create:*) Bash(gh pr checks:*) Bash(gh run view:*) Read Glob
---

# Open PR

Push the current branch, make sure it has a pull request, wait until every check on it has finished, and report the result. Do not ask for confirmation and do not change any file.

## Rules

- **Uncommitted changes**: they are not part of the PR. List them in the report and carry on with what is committed.
- **Nothing to open**: if the branch has no commits ahead of the default branch and no open PR, say so and stop.
- **Branch**: if you are on the repository's default branch, create `type/short-description` from the main commit with `git switch -c`; the commits come with it. Do not reset the local default branch: report that it is still ahead of its remote. On any other branch, use it as it is.
- **Push**: `git push -u origin <branch>`. Never force-push. If the push is rejected, stop and report why.
- **Existing PR**: if the branch already has an open PR, leave its title and body alone.
- **New PR**: ready for review (not a draft), against the default branch.
  - **Title**: one Conventional Commits subject (`type(scope): description`) that covers the whole branch. With a single commit, use its subject. It becomes the squash commit in many repos.
  - **Body**: if the repo has a pull request template, fill it in. Otherwise write `## Summary` (what changes and why) and `## Testing` (what was run and its result; only what actually ran).
  - **Never include**: ticket identifiers, Claude attribution, "Generated with" lines.
- **Waiting**:
  - Checks take a few seconds to register after a push. If none are reported, retry for up to 2 minutes before concluding that the repo has no checks.
  - Wait with `gh pr checks <pr> --watch`, in stretches shorter than your command timeout, repeating until no check is pending or 30 minutes have passed in total.
  - A check that failed, was cancelled or timed out has finished. Do not wait for reviews that are not checks.
- **Failed checks**: for each one, get the end of its log with `gh run view <run-id> --log-failed`. If it is not a GitHub Actions run, give its details URL instead.
- **Report**:
  - the PR URL, and whether you created it or it already existed
  - every check with its result
  - for each failed check, the end of its log
  - the checks still pending if the 30 minutes ran out
  - uncommitted changes you left out
```

#### 3. Política para Codex
**File**: `git/skills/open-pr/agents/openai.yaml` (nuevo)

```yaml
policy:
  allow_implicit_invocation: true
```

### Success Criteria:
- [x] Tests pasan: `make test`
- [x] Manifiestos válidos: `make validate`
- [x] Codex en sincronía: `make check-codex`

---

## Phase 3: `review-pr-comments` desatendida

### Overview
Reescritura completa: decide sin iterar con el usuario, implementa los ACCEPT, los sube y responde. Desaparece el formato de resumen para confirmar.

### Changes Required:

#### 1. Skill
**File**: `git/skills/review-pr-comments/SKILL.md`
**Changes**: sustituir el fichero completo.

````markdown
---
name: review-pr-comments
description: Review PR comments unattended, deciding on each one, implementing the accepted changes, pushing them and replying in every thread
model: inherit
disable-model-invocation: false
allowed-tools: Bash(gh pr view:*) Bash(gh api:*) Bash(git status:*) Bash(git diff:*) Bash(git log:*) Bash(git add:*) Bash(git commit:*) Bash(git push:*) Read Glob Grep Edit Write Skill
argument-hint: "[PR number] [plan file] (both optional)"
---

# Review PR Comments

Review the pending comments on a PR, decide on each one, implement the accepted changes, push them and reply in every thread. Do not ask for confirmation: the report at the end is how the user learns what you decided.

## Rules

- **PR target**: the PR number if given, otherwise the PR of the current branch. If there is none, say so and stop.
- **Plan**: if a plan file is given, read it. It is the agreed design: a comment that asks to go against it needs a stronger reason to be accepted.
- **Scope**: comments from anyone, bots and people alike. "Yours" below means written by the authenticated GitHub user.
- **Pending**:
  - An inline thread is pending when it is not resolved, not outdated, and its last comment is not yours.
  - A general comment or a review body is pending when it is not yours and was created or edited after your last comment on the PR. If you never commented, all of them are.
  - If nothing is pending, say so and stop.
- **Bias**: defend the existing code. Only accept a change with a concrete technical reason (bug, violated principle, demonstrable readability gain). Reject style preferences without objective justification.
- **Context**: before evaluating, read the full files affected plus related files (tests, types, direct dependencies).
- **Severity**: take it from the comment's prefix when present (`[SECURITY — CRITICAL]`, `[CODE QUALITY — HIGH]`, `[TESTS — LOW]`, `[SUGGESTION]`, etc.). Otherwise infer it: correctness or security bugs are HIGH; performance, tests or missing error paths are MEDIUM; style, docstrings, naming and "for consistency" nits are LOW.
- **Decision**: one of these for every pending comment.
  - `ACCEPT`: you will make the change.
  - `REJECT`: you will not, and you can say why.
  - `REPEATED`: it raises a point you already answered on this PR and adds no new argument. Do not reply again.
- **Implementing**: change only what the accepted comments ask for.
  - A change in behavior goes test-first. If `/stepwise-core:tdd` is available, invoke it with the `Skill` tool: describe the accepted comment as the behavior to implement and pass the plan file if you have one. If it is not available, write the failing test yourself before the fix.
  - A change that does not alter behavior (naming, comments, docs, configuration) is a direct edit.
  - If you cannot make an accepted change, do not pretend: reply saying what blocked it and list it in the report.
- **Publishing the code**: if any file changed, invoke `/stepwise-git:commit` with the `Skill` tool, then `git push`. Never force-push. Do this before replying. If the commit or the push fails, do not post any reply that says a change is done: stop and report.
- **Replying**: one reply per `ACCEPT` and per `REJECT`, posted after the code is pushed.
  - Inline threads get a reply in the thread. General comments and review bodies get a general PR comment that links to the comment it answers.
  - `ACCEPT`: what changed and the commit that changed it.
  - `REJECT`: the technical reason, and what you propose instead if anything. One line is enough for LOW.
  - Always in English, whatever the comment's language. No Claude attribution.
  - Never resolve a thread: that belongs to whoever opened it.
- **Report**: every comment grouped by severity, one block each, and then whether you pushed code (with the commits), so a caller knows a new round of checks has started.

  ```
  N. [ACCEPT|REJECT|REPEATED] {path}:{line or "general"} @{user} — {the claim in one sentence, in your own words}
     Reason: {1-2 lines, technical}
     Commit: {sha}                          # only if ACCEPT
     Alternative: {what you proposed}       # only if REJECT
     Link: {comment.html_url}
  ```
````

### Success Criteria:
- [x] Tests pasan: `make test`
- [x] Manifiestos válidos: `make validate`

---

## Phase 4: Skill `ship-pr`

### Overview
La orquestadora: encadena las otras tres, lleva la cuenta de rondas de arreglo, decide cuándo parar y escribe el informe.

### Changes Required:

#### 1. Test de estructura (primero, para verlo fallar)
**File**: `test/plugin-structure-test.sh`
**Changes**: tras la aserción de `open-pr` añadir:

```bash
assert_file_exists "git/skills/ship-pr/SKILL.md" "ship-pr skill exists"
```

#### 2. Skill
**File**: `git/skills/ship-pr/SKILL.md` (nuevo)

````markdown
---
name: ship-pr
description: Take the current work to a pull request that is ready to merge, unattended. Commits, pushes, opens the PR, waits for its checks, fixes the failures and answers the review comments, in up to 3 fix rounds. Never merges.
model: inherit
disable-model-invocation: false
allowed-tools: Bash(git status:*) Bash(git branch:*) Bash(git switch:*) Bash(git log:*) Bash(git diff:*) Bash(git add:*) Bash(git commit:*) Bash(git push:*) Bash(gh repo view:*) Bash(gh pr view:*) Bash(gh pr create:*) Bash(gh pr edit:*) Bash(gh pr checks:*) Bash(gh run view:*) Bash(gh api:*) Read Glob Grep Edit Write Skill
argument-hint: "[plan file (optional)]"
---

# Ship PR

Take the work in this repository to a pull request that is ready to merge: commit it, push it, open the PR, wait for its checks, fix what fails and answer the review comments.

Nobody will answer questions while you run. Do not ask for confirmation at any step: the report you write at the end is the user's control point. Never merge the PR and never force-push.

## Your Role: Orchestrator

You coordinate; the delegated skills do the work and own their rules. Invoke each one with the `Skill` tool:

- `/stepwise-git:commit` creates the commits
- `/stepwise-git:open-pr` pushes, opens the PR and waits for the checks
- `/stepwise-git:review-pr-comments` decides on the comments, implements, pushes and replies
- `/stepwise-core:tdd` fixes behavior test-first, when it is available

If a delegated skill fails, stop and report what happened. Do not work around it by doing its job yourself.

## Getting Started

- **Plan**: if a plan file is given, pass it to `tdd` and to `review-pr-comments` as context. Do not look for one yourself.
- **Nothing to ship**: if the working tree is clean, the branch has no commits ahead of the default branch and it has no open PR, say so and stop.
- **Branch first**: if you are on the default branch and there are changes to commit, create `type/short-description` with `git switch -c` before committing.
- **Commit**: if there are uncommitted changes, invoke `/stepwise-git:commit`.

Then run the round cycle. Keep a count of fix rounds, starting at 0.

## Round Cycle

### Step 1 — Push and wait

Invoke `/stepwise-git:open-pr`. It pushes whatever is not on the remote yet, so the fixes of the previous round are verified here.

Stop with **timeout** if checks are still pending when it returns.

Stop with **round limit** if the fix-round count is 3. The comments that arrived after the last push have not been processed: say so in the report.

### Step 2 — Fix the failed checks

Skip this step if no check failed.

Stop with **no progress** if a check fails with the same error as in the previous round.

Read the log of each failed check and decide what kind of failure it is:

| Failure | What to do |
|---|---|
| A reviewer that only reports findings it posted as PR comments | Nothing here: Step 3 handles them |
| Behavior or a failing test | Fix it test-first, without weakening or skipping tests. Invoke `/stepwise-core:tdd` with the log if it is available; otherwise write the failing test yourself first |
| Lint, format, version, generated file or configuration | Edit directly |
| PR title, body or labels | `gh pr edit` |
| Nothing in the repository can fix it (infrastructure, secrets, permissions, an external service) | Stop with **blocked** |

If any file changed, invoke `/stepwise-git:commit`. Do not push: the next step or the next round does it.

### Step 3 — Answer the review comments

Invoke `/stepwise-git:review-pr-comments` with the PR number and the plan file, if any. It pushes its own changes together with the commits from Step 2.

### Step 4 — Decide whether to go again

- Something changed in this round (a commit or a PR edit): add 1 to the fix-round count and go back to Step 1.
- Nothing changed and every check passed: stop with **clean**.
- Nothing changed and a check is still failing: stop with **no progress**.

## Final Report

```
PR: {url}
Result: {clean | round limit | no progress | timeout | blocked} — {one line saying why}
Fix rounds used: {n} of 3

Checks:
- {name}: {passed | failed | pending}

Check failures fixed:
- {check}: {what was wrong and what you changed}

Comments:
- Accepted: {claim} — {commit}
- Rejected: {claim} — {reason}
- Repeated, not answered again: {claim}

Left for you:
- {failing checks with the end of their log, comments not processed, files left out of the commits}

The PR has not been merged.
```

Omit a section that has nothing in it.
````

#### 3. Política para Codex
**File**: `git/skills/ship-pr/agents/openai.yaml` (nuevo)

```yaml
policy:
  allow_implicit_invocation: true
```

### Success Criteria:
- [x] Tests pasan: `make test`
- [x] Manifiestos válidos: `make validate`
- [x] Codex en sincronía: `make check-codex`

---

## Phase 5: Documentación, referencias y versiones

### Overview
Las descripciones del plugin dejan de decir "commits con aprobación y review de comentarios", `stepwise-core` sugiere `ship-pr` al terminar, y se suben las versiones.

### Changes Required:

#### 1. README del plugin
**File**: `git/README.md`
**Changes**:
- Línea 3: `Git and GitHub workflow: unattended commits, pull requests, CI checks and PR comment review.`
- "Commands (2)" pasa a "Commands (4)", en este orden:
  - `/stepwise-git:ship-pr [plan]` - Take the current work to a PR that is ready to merge: commit, push, open the PR, wait for checks, fix failures and answer review comments, in up to 3 fix rounds. Never merges
  - `/stepwise-git:commit` - Create git commits without asking, with no Claude attribution
  - `/stepwise-git:open-pr` - Push the branch, open its PR if it has none and wait for every check to finish
  - `/stepwise-git:review-pr-comments [PR] [plan]` - Decide on each pending PR comment, implement the accepted changes, push them and reply in every thread
- "Usage": un bloque por comando con sus pasos. En `commit` quitar la confirmación; en `review-pr-comments` sustituir "Present a summary" e "Iterate with you" por decidir, implementar (vía `tdd` si `stepwise-core` está instalado), commit y push, y responder. Añadir los bloques de `open-pr` y `ship-pr` con sus cinco motivos de parada.
- "Features": quitar "Pre-commit hook support" si no lo respalda ninguna regla; añadir que todas las skills son desatendidas, que nunca se hace merge ni force-push, y la dependencia blanda de `stepwise-core:tdd`.
- Añadir una nota: que el flujo no se pare en avisos de permiso depende del modo de permisos de la sesión, porque los tests del proyecto son comandos que no se pueden preaprobar.

#### 2. README raíz
**File**: `README.md`
**Changes**:
- `:50`: `Unattended git and GitHub workflow: commits without Claude attribution, pull requests, CI checks and PR comment review.`
- `:53-54`: sustituir las dos viñetas por tres: staging y mensajes de commit; push, PR y espera de checks; decisión, arreglo y respuesta a comentarios de review con `/ship-pr` como comando único.
- `:214` (fila Implement): sustituir `/commit` por `/ship-pr` (o `/commit` para solo commitear).
- `:250-256`: la sección "Commit (stepwise-git)" pasa a "Ship (stepwise-git)", con `/stepwise-git:ship-pr thoughts/shared/plans/<plan>.md` y una frase sobre las tres piezas sueltas.
- `:278-279`: sustituir el ejemplo por `/stepwise-git:ship-pr`.

#### 3. AGENTS.md
**File**: `AGENTS.md`
**Changes**: `:27` pasa a `- Skills for unattended commits, pull requests with their CI checks, and PR comment review, plus the \`ship-pr\` skill that chains them`.

#### 4. Manifiestos
**Files**: `git/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`
**Changes**:
- `description` de `stepwise-git` en ambos: `Git and GitHub workflow: unattended commits, pull requests, CI checks and PR comment review`.
- `keywords` de `git/.claude-plugin/plugin.json`: añadir `pr`, `github`, `ci`.

#### 5. Siguiente paso en stepwise-core
**File**: `core/skills/implement-plan/SKILL.md`
**Changes**: `:140` pasa a:

```
   - Use `/stepwise-git:ship-pr thoughts/shared/plans/[filename].md` to commit, open the PR and take it through its checks and review (or `/stepwise-git:commit` to only commit)
```

**File**: `core/workflows/implement-and-validate.js`
**Changes**: `:514`, la última viñeta de "Next steps" pasa a:

```js
sections.push(`### Next steps\n- Review the changes: \`git diff\`\n- Ship them: \`/stepwise-git:ship-pr ${planPath}\` (or \`/stepwise-git:commit\` to only commit)`)
```

#### 6. Versiones
| Fichero | De | A | Motivo |
|---|---|---|---|
| `git/.claude-plugin/plugin.json` | 1.6.1 | 2.0.0 | Cambia la interfaz de `commit` y `review-pr-comments` |
| `core/.claude-plugin/plugin.json` | 1.7.0 | 1.7.1 | Edición de una skill y del workflow |
| `.claude-plugin/marketplace.json` entrada `stepwise-git` | 1.6.1 | 2.0.0 | Espejo |
| `.claude-plugin/marketplace.json` entrada `stepwise-core` | 1.7.0 | 1.7.1 | Espejo |
| `.claude-plugin/marketplace.json` versión superior | 2.0.6 | 2.0.7 | Entradas editadas |

### Success Criteria:
- [x] CI completo pasa: `make ci`

---

## Phase 6: Validación manual

### Overview
Los tests solo comprueban estructura. El comportamiento se valida ejecutando las skills con el plugin cargado desde el directorio local (`claude --plugin-dir git`, o reinstalando el plugin), en modo de permisos que no pida confirmación para los tests del proyecto.

Este repo no tiene bot de review: sirve para commit, PR, espera y arreglo de checks rojos. La parte de comentarios se valida en un repo con el review de Claude como check.

### Changes Required:
Ninguno salvo los ajustes de redacción que salgan de las ejecuciones. Si alguno cambia una regla, actualizar también `git/README.md`.

### Success Criteria:

#### Automated Verification:
- [x] CI completo pasa: `make ci`

#### Manual Verification:
- [x] `/stepwise-git:commit` con cambios y un `.env` sin seguir: hace commit sin preguntar, deja fuera el `.env` y lo lista
- [x] `/stepwise-git:open-pr` en una rama con commits: crea la PR con título Conventional Commits y cuerpo `Summary`/`Testing`, espera a los tres checks e informa de cada uno
- [x] `/stepwise-git:open-pr` relanzada sobre la misma rama: no crea otra PR ni cambia título o cuerpo
- [ ] `/stepwise-git:ship-pr` con un título de PR inválido: lo corrige con `gh pr edit` y el check pasa sin push
- [x] La espera de checks supera los 10 minutos sin cortarse (repo con CI lento o un job con `sleep`)
- [ ] En un repo con review de Claude: `/stepwise-git:ship-pr` responde a todos los comentarios, los ACCEPT citan un commit que existe en la PR, y un comentario general editado tras el push vuelve a salir como pendiente
- [ ] En ese repo: una objeción repetida por el bot se marca `REPEATED`, no recibe segunda respuesta y el flujo para con `clean` si los checks pasan (`no progress` si alguno sigue rojo)
- [ ] Ninguna de las skills invocadas desde `ship-pr` provoca un aviso de permiso por una herramienta listada en sus `allowed-tools`; si lo hace, la lista de `ship-pr` necesita ese permiso
- [ ] Sin `stepwise-core` instalado, `review-pr-comments` arregla un comentario aceptado escribiendo antes un test que falla
- [ ] Bajo Codex (`make install-codex`): `open-pr` y `ship-pr` aparecen como skills y `ship-pr` completa una ronda

## Testing Strategy

### Unit Tests:
- `test/plugin-structure-test.sh`: existencia de `open-pr/SKILL.md` y `ship-pr/SKILL.md`. La política de `openai.yaml` la cubre el test derivado del frontmatter (`:232-244`), y el recuento de skills instaladas en Codex se deriva del sistema de ficheros (`test/codex-test.sh:25-26`).

### Manual Testing Steps:
Los de la Phase 6. No hay forma automática de comprobar que una skill en prosa se comporta como dice.

## Performance Considerations

`ship-pr` corre en la sesión principal y carga en contexto los logs de CI, los comentarios y los ciclos de `tdd` de hasta 3 rondas. Conviene lanzarla tras `/clear`. Si el contexto resulta ser un problema en la práctica, la salida es mover el bucle a un workflow, que queda fuera de este plan.

Cada ronda de arreglo cuesta una ejecución completa del CI de la PR.

## Migration Notes

Cambio incompatible para quien use `stepwise-git` 1.x: `commit` ya no enseña el plan y espera, y `review-pr-comments` publica respuestas, también a personas, sin acordarlas antes. De ahí el salto a 2.0.0. Hay que decirlo en el cuerpo de la PR.

## References

- Diseño acordado en la sesión de `/stepwise-core:grill-me` del 2026-10-10
- Orquestadora de referencia: `core/skills/implement-plan/SKILL.md`
- Skill delegada para arreglos: `core/skills/tdd/SKILL.md:49`
- Reglas de versión: `.claude/rules/versioning.md`
- Plan anterior, que dejó git fuera: `thoughts/shared/plans/2026-10-10-implement-and-validate-workflow.md:33`
