export const meta = {
  name: 'implement-and-validate',
  description: 'Implement a stepwise plan phase by phase (tdd, bugmagnet, mutation-testing, test-desiderata, plan verification), then validate it in up to 3 fix rounds',
  whenToUse: 'An approved plan in thoughts/shared/plans/ should be implemented and validated end to end without supervision',
  phases: [
    { title: 'Read plan', detail: 'Phases, success criteria and their checkboxes' },
  ],
}

const MAX_FIX_ROUNDS = 3

const planPath = typeof args === 'string' ? args.trim() : args?.planFile
if (!planPath) {
  throw new Error('Pass the plan file path, e.g. /stepwise-core:implement-and-validate thoughts/shared/plans/2026-10-10-my-feature.md')
}

const SHARED = `Plan file: ${planPath}
You run unattended inside a workflow: nobody will answer questions.
Do not run git commands that change history or the working tree (commit, stash, reset, checkout, restore, rebase).`

const strings = { type: 'array', items: { type: 'string' } }

const PLAN_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['title', 'phases'],
  properties: {
    title: { type: 'string' },
    phases: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['number', 'name', 'automatedCriteria', 'manualCriteria'],
        properties: {
          number: { type: 'integer' },
          name: { type: 'string' },
          automatedCriteria: {
            type: 'array',
            items: {
              type: 'object',
              additionalProperties: false,
              required: ['text', 'command', 'checked'],
              properties: {
                text: { type: 'string' },
                command: { type: 'string' },
                checked: { type: 'boolean' },
              },
            },
          },
          manualCriteria: strings,
        },
      },
    },
  },
}

const MISMATCH = {
  type: 'object',
  additionalProperties: false,
  required: ['expected', 'found', 'whyItMatters'],
  properties: {
    expected: { type: 'string' },
    found: { type: 'string' },
    whyItMatters: { type: 'string' },
  },
}

const IMPLEMENTATION_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['status', 'implementationFiles', 'testFiles', 'mismatch'],
  properties: {
    status: { type: 'string', enum: ['done', 'mismatch'] },
    implementationFiles: strings,
    testFiles: strings,
    mismatch: MISMATCH,
  },
}

const BUG_HUNT_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['testFiles', 'bugs'],
  properties: {
    testFiles: strings,
    bugs: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['title', 'location', 'proposedFix', 'skippedTest', 'worthFixing', 'reason'],
        properties: {
          title: { type: 'string' },
          location: { type: 'string' },
          proposedFix: { type: 'string' },
          skippedTest: { type: 'string' },
          worthFixing: { type: 'boolean' },
          reason: { type: 'string' },
        },
      },
    },
  },
}

const FIX_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['fixed', 'notFixed', 'implementationFiles', 'testFiles'],
  properties: {
    fixed: strings,
    notFixed: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['title', 'reason'],
        properties: { title: { type: 'string' }, reason: { type: 'string' } },
      },
    },
    implementationFiles: strings,
    testFiles: strings,
  },
}

const MUTATION_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['workingTreeIntact', 'stillAlive', 'bugsFound', 'testFiles'],
  properties: {
    workingTreeIntact: { type: 'boolean' },
    stillAlive: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['location', 'mutant', 'reason'],
        properties: {
          location: { type: 'string' },
          mutant: { type: 'string' },
          reason: { type: 'string' },
        },
      },
    },
    bugsFound: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['location', 'description', 'handling'],
        properties: {
          location: { type: 'string' },
          description: { type: 'string' },
          handling: { type: 'string', enum: ['fixed', 'skipped test'] },
        },
      },
    },
    testFiles: strings,
  },
}

const TEST_REVIEW_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['applied', 'declined'],
  properties: {
    applied: strings,
    declined: strings,
  },
}

const VERIFICATION_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['results'],
  properties: {
    results: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['command', 'passed', 'outputTail'],
        properties: {
          command: { type: 'string' },
          passed: { type: 'boolean' },
          outputTail: { type: 'string' },
        },
      },
    },
  },
}

const CHECKBOX_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['checked'],
  properties: { checked: strings },
}

const VALIDATION_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['findings', 'planDrift', 'skippedBugTests'],
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['title', 'phase', 'file', 'detail', 'fixableByAgent'],
        properties: {
          title: { type: 'string' },
          phase: { type: 'string' },
          file: { type: 'string' },
          detail: { type: 'string' },
          fixableByAgent: { type: 'boolean' },
        },
      },
    },
    planDrift: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['phase', 'planSaid', 'codeDoes', 'why'],
        properties: {
          phase: { type: 'string' },
          planSaid: { type: 'string' },
          codeDoes: { type: 'string' },
          why: { type: 'string' },
        },
      },
    },
    skippedBugTests: strings,
  },
}

const APPEND_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['appendedOnly'],
  properties: { appendedOnly: { type: 'boolean' } },
}

// A directly awaited agent() resolves to null when the user stops it; nothing after it can run.
async function run(prompt, opts) {
  const result = await agent(prompt, opts)
  if (!result) throw new Error(`Stopped: the "${opts.label}" agent returned no result.`)
  return result
}

function issueInPhase(phase, mismatch) {
  return new Error(`Issue in Phase ${phase.number}: ${phase.name}
Expected: ${mismatch.expected}
Found: ${mismatch.found}
Why this matters: ${mismatch.whyItMatters}

Fix the plan or the code, then start a new run of the workflow; completed phases are skipped.
Do not resume the stopped run: resuming replays the saved results, including this failure.`)
}

const unique = (items) => [...new Set(items)]
const commandsOf = (phase) => phase.automatedCriteria.filter((c) => c.command)
const isDone = (phase) => commandsOf(phase).every((c) => c.checked)
const bulleted = (items) => items.map((item) => `- ${item}`).join('\n')
const fileName = (path) => path.split('/').pop()
const clause = (text) => text.trim().replace(/\.+$/, '')
const describeDrift = (d) => `${clause(d.phase)} — Plan: ${clause(d.planSaid)}. Code: ${clause(d.codeDoes)}. Why: ${clause(d.why)}.`

// ---------------------------------------------------------------------------
phase('Read plan')

const plan = await run(
  `${SHARED}

Read the plan file completely. Do not modify any file.
Return its title and every "## Phase N: <name>" section in order.
For each phase, list the checkboxes under its success criteria:
- automatedCriteria: every checkbox that is not under a "Manual Verification" heading. "command" is the shell command it names (usually in backticks), or "" when it names none. "checked" is true for "- [x]".
- manualCriteria: the text of every checkbox under a "Manual Verification" heading.`,
  { label: 'read-plan', phase: 'Read plan', schema: PLAN_SCHEMA },
)

if (plan.phases.length === 0) throw new Error(`No "## Phase N:" sections found in ${planPath}.`)

const unverifiable = plan.phases.filter((p) => commandsOf(p).length === 0)
if (unverifiable.length > 0) {
  throw new Error(`The plan cannot be verified. These phases have no command in their automated success criteria: ${unverifiable.map((p) => `Phase ${p.number}`).join(', ')}. Add one (e.g. "make test") and relaunch.`)
}

const pending = plan.phases.filter((p) => !isDone(p))
log(`${plan.phases.length - pending.length} of ${plan.phases.length} phases already done; implementing ${pending.length}.`)

// ---------------------------------------------------------------------------
const bugsFixed = []
const survivingMutants = []
const testImprovementsDeclined = []

async function verify(phaseLabel, commands) {
  const verification = await run(
    `Run each command from the repository root, exactly as written, and report whether it exited with status 0. Do not fix anything.
${bulleted(commands)}`,
    { label: `verify ${phaseLabel}`, phase: phaseLabel, schema: VERIFICATION_SCHEMA },
  )
  return verification.results.filter((r) => !r.passed)
}

for (const planPhase of pending) {
  const label = `Phase ${planPhase.number}: ${planPhase.name}`
  phase(label)

  const implementation = await run(
    `${SHARED}

Implement ${label} from the plan. Read that section first.
Report status "mismatch" (and fill "mismatch") if the plan does not match the codebase; otherwise "done" with empty mismatch fields.`,
    { label: `tdd ${label}`, phase: label, agentType: 'stepwise-core:tdd-implementer', schema: IMPLEMENTATION_SCHEMA },
  )
  if (implementation.status === 'mismatch') throw issueInPhase(planPhase, implementation.mismatch)

  const testFiles = [...implementation.testFiles]
  const productionFiles = [...implementation.implementationFiles]
  const bugsToFix = []
  for (const file of implementation.implementationFiles) {
    const hunt = await run(
      `${SHARED}

Hunt bugs in ${file}, implemented for ${label} of the plan.
Read that section of the plan first: whether a bug is worth fixing depends on what it asks for.`,
      { label: `bugmagnet ${fileName(file)}`, phase: label, agentType: 'stepwise-core:bug-hunter', schema: BUG_HUNT_SCHEMA },
    )
    testFiles.push(...hunt.testFiles)
    for (const bug of hunt.bugs) {
      if (bug.worthFixing) bugsToFix.push(bug)
    }
  }

  if (bugsToFix.length > 0) {
    const fix = await run(
      `${SHARED}

BugMagnet documented these bugs in ${label} as skipped tests. For each one: un-skip its test, watch it fail, then make it pass.
${bulleted(bugsToFix.map((b) => `${b.title} — ${b.location}. Test: ${b.skippedTest}. Proposed fix: ${b.proposedFix}`))}`,
      { label: `fix bugs ${label}`, phase: label, agentType: 'stepwise-core:tdd-implementer', schema: FIX_SCHEMA },
    )
    testFiles.push(...fix.testFiles)
    productionFiles.push(...fix.implementationFiles)
    const notFixed = new Set(fix.notFixed.map((b) => b.title))
    bugsFixed.push(...bugsToFix.filter((b) => !notFixed.has(b.title)).map((b) => `${b.title} (${b.location})`))
  }

  if (productionFiles.length > 0) {
    const mutation = await run(
      `${SHARED}

Run mutation testing on the production code changed in ${label}: --changed ${unique(productionFiles).join(' ')}
Read that section of the plan first: when a pinned behavior fails, fix the code only if this phase specifies that behavior.`,
      { label: `mutation-testing ${label}`, phase: label, agentType: 'stepwise-core:mutation-hunter', schema: MUTATION_SCHEMA },
    )
    if (!mutation.workingTreeIntact) {
      throw issueInPhase(planPhase, {
        expected: 'Every mutant is reverted and production files match their checksum from before mutation testing',
        found: 'A mutant could not be reverted to the original checksum',
        whyItMatters: 'A mutant may still be in the production code. Inspect `git diff` on the changed files before relaunching.',
      })
    }
    testFiles.push(...mutation.testFiles)
    bugsFixed.push(...mutation.bugsFound.filter((b) => b.handling === 'fixed').map((b) => `${b.location}: ${b.description}`))
    survivingMutants.push(...mutation.stillAlive.map((m) => `${m.location}: \`${m.mutant}\` — ${m.reason}`))
  }

  const commands = unique(commandsOf(planPhase).map((c) => c.command))

  const review = await run(
    `${SHARED}

Review these test files written for ${label}, including the tests added by mutation testing, and apply the worthwhile improvements:
${bulleted(unique(testFiles))}
These commands must keep passing:
${bulleted(commands)}`,
    { label: `test-desiderata ${label}`, phase: label, agentType: 'stepwise-core:test-reviewer', schema: TEST_REVIEW_SCHEMA },
  )
  testImprovementsDeclined.push(...review.declined)

  let failures = await verify(label, commands)
  if (failures.length > 0) {
    await run(
      `${SHARED}

After ${label} these verification commands fail. Fix the code so they pass, without weakening or skipping tests:
${failures.map((f) => `- ${f.command}\n${f.outputTail}`).join('\n')}`,
      { label: `fix verification ${label}`, phase: label, agentType: 'stepwise-core:tdd-implementer', schema: FIX_SCHEMA },
    )
    failures = await verify(label, commands)
  }
  if (failures.length > 0) {
    throw issueInPhase(planPhase, {
      expected: `These commands pass: ${commands.join(', ')}`,
      found: failures.map((f) => `${f.command} still fails:\n${f.outputTail}`).join('\n'),
      whyItMatters: 'Later phases build on this one; continuing on red would compound the failure.',
    })
  }

  await run(
    `In ${planPath}, inside "## Phase ${planPhase.number}: ${planPhase.name}", change "- [ ]" to "- [x]" for exactly these success criteria and change nothing else:
${bulleted(commandsOf(planPhase).map((c) => c.text))}`,
    { label: `checkboxes ${label}`, phase: label, schema: CHECKBOX_SCHEMA },
  )
}

// ---------------------------------------------------------------------------
phase('Validate')

const allCommands = unique(plan.phases.flatMap((p) => commandsOf(p).map((c) => c.command)))

let report
let unresolved = []
let previousSignature = ''
for (let fixRound = 0; ; fixRound++) {
  report = await run(
    `${SHARED}

Validate the implementation of the plan against the codebase.`,
    { label: `validate ${fixRound + 1}`, phase: 'Validate', agentType: 'stepwise-core:plan-validator', schema: VALIDATION_SCHEMA },
  )
  const fixable = report.findings.filter((f) => f.fixableByAgent)
  const signature = fixable.map((f) => `${f.phase}|${f.file}|${f.title}`).sort().join(' ;; ')

  if (fixable.length === 0) break
  if (signature === previousSignature) {
    log(`Validation round ${fixRound + 1} returned the same ${fixable.length} findings after a fix: stopping.`)
    unresolved = fixable
    break
  }
  if (fixRound === MAX_FIX_ROUNDS) {
    unresolved = fixable
    break
  }
  previousSignature = signature

  await run(
    `${SHARED}

The validation of the plan found these problems. Fix them test-first, and change nothing else:
${bulleted(fixable.map((f) => `${f.title} (${f.phase}, ${f.file}): ${f.detail}`))}
These commands must pass when you finish:
${bulleted(allCommands)}`,
    { label: `fix round ${fixRound + 1}`, phase: 'Validate', agentType: 'stepwise-core:tdd-implementer', schema: FIX_SCHEMA },
  )
}

// A fix round can break what the phases left green: verify the whole plan once more.
let finalFailures = await verify('Validate', allCommands)
if (finalFailures.length > 0) {
  await run(
    `${SHARED}

After validating the plan these verification commands fail. Fix the code so they pass, without weakening or skipping tests:
${finalFailures.map((f) => `- ${f.command}\n${f.outputTail}`).join('\n')}`,
    { label: 'fix final verification', phase: 'Validate', agentType: 'stepwise-core:tdd-implementer', schema: FIX_SCHEMA },
  )
  finalFailures = await verify('Validate', allCommands)
}
if (finalFailures.length > 0) {
  const failing = new Set(finalFailures.map((f) => f.command))
  await run(
    `In ${planPath}, change "- [x]" back to "- [ ]" for every success criterion whose command is one of these, and change nothing else:
${bulleted([...failing])}`,
    { label: 'uncheck failing criteria', phase: 'Validate', schema: CHECKBOX_SCHEMA },
  )
}

// Record accepted deviations in the plan without touching what was approved.
let planNotes = 'none'
if (report.planDrift.length > 0) {
  const appended = await run(
    `Append implementation notes to ${planPath}. Before editing, copy the file to a temporary location.
Add the entries below at the very end of the file, under a "## Implementation notes" heading (create it if it is missing; skip entries it already lists). Each entry says what the plan said, what the code does instead, and why. Do not change any existing line.
${bulleted(report.planDrift.map(describeDrift))}
Then diff the copy against the file. Report appendedOnly true only if the diff adds lines at the end and changes nothing else; otherwise restore the copy and report false.`,
    { label: 'implementation notes', phase: 'Validate', schema: APPEND_SCHEMA },
  )
  planNotes = appended.appendedOnly ? 'appended' : 'failed'
}

// ---------------------------------------------------------------------------
const needsHuman = report.findings.filter((f) => !f.fixableByAgent)
const pendingManual = plan.phases.flatMap((p) => [
  ...p.manualCriteria.map((c) => `Phase ${p.number}: ${c}`),
  ...p.automatedCriteria.filter((c) => !c.command).map((c) => `Phase ${p.number}: ${c.text} (no command to run it)`),
])
const describeFinding = (f) => `${f.title} (${f.phase}, ${f.file}): ${f.detail}`

const sections = [
  `## implement-and-validate: ${plan.title}`,
  `### Phases\n${bulleted(plan.phases.map((p) => `Phase ${p.number}: ${p.name} — ${pending.includes(p) ? 'implemented in this run' : 'already done'}`))}`,
  `### Validation\n${unresolved.length === 0 ? 'No fixable findings left.' : `Unresolved after the fix rounds:\n${bulleted(unresolved.map(describeFinding))}`}`,
]
if (finalFailures.length > 0) {
  sections.push(`### Verification is red\nThese commands still fail, so their success criteria were unchecked in the plan:\n${finalFailures.map((f) => `- ${f.command}\n${f.outputTail}`).join('\n')}`)
}
if (needsHuman.length > 0) sections.push(`### Needs a human\n${bulleted(needsHuman.map(describeFinding))}`)
if (report.planDrift.length > 0) {
  const where = planNotes === 'appended'
    ? 'Recorded under "## Implementation notes" at the end of the plan. To make one of them part of the design, use `/stepwise-core:iterate-plan`.'
    : 'Could not append them to the plan without touching other lines, so the plan was left as it was.'
  sections.push(`### Plan out of date\n${where}\n${bulleted(report.planDrift.map(describeDrift))}`)
}
if (pendingManual.length > 0) sections.push(`### Pending manual verification\n${bulleted(pendingManual)}`)
if (bugsFixed.length > 0) sections.push(`### Bugs fixed\n${bulleted(unique(bugsFixed))}`)
if (report.skippedBugTests.length > 0) sections.push(`### Bugs still documented as skipped tests\n${bulleted(report.skippedBugTests)}`)
if (survivingMutants.length > 0) sections.push(`### Surviving mutants\n${bulleted(survivingMutants)}`)
if (testImprovementsDeclined.length > 0) sections.push(`### Test improvements declined\n${bulleted(testImprovementsDeclined)}`)
sections.push(`### Next steps\n- Review the changes: \`git diff\`\n- Ship them: \`/stepwise-git:ship-pr ${planPath}\` (or \`/stepwise-git:commit\` to only commit)`)

return sections.join('\n\n')
