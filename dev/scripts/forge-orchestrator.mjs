#!/usr/bin/env node
/**
 * forge-orchestrator.mjs v2.0.0
 * Forge Dev Session Orchestrator — Agent SDK
 *
 * Automates a Forge Dev session: Context -> Requirements -> Spec -> Plan -> Implement -> Check -> Walkthrough -> PR
 * Uses Agent SDK for programmatic agent execution with model tiering.
 *
 * v2.0.0 Changes:
 *   - 2-Tier work-size: hotfix | standard (was 4-tier)
 *   - session-state.mjs integration (was self-managed .forge/ state)
 *   - Check 3 via verify.sh (Bash), Check 3.5/3.7 via check-parallel.mjs
 *   - SDK: settingSources, adaptive thinking for Opus, outputSchema, session resumption
 *   - --resume <session-id> for resuming a previous SDK session
 *   - Improved error recovery with session-state checkpoint
 *
 * Usage:
 *   node ~/.claude/scripts/forge-orchestrator.mjs --project <path> --session <name> [options]
 *   node ~/.claude/scripts/forge-orchestrator.mjs --help
 *
 * Options:
 *   --project <path>          Project root directory (required)
 *   --session <name>          Session name from S4 roadmap (required)
 *   --work-size <size>        hotfix | standard (default: standard)
 *   --phase <N>               Start from phase (default: 1)
 *                              1=Context, 1.5=Requirements, 2=Spec, 2.5=Plan, 3=Implement, 3.5=Check, 3.9=Walkthrough, 4=PR
 *   --spec <path>             Existing spec path (skip phase 2)
 *   --plan <path>             Existing plan path (skip plan step)
 *   --resume <session-id>     Resume a previous SDK session
 *   --skip-checks             Skip Check 3.5/3.7 parallel execution
 *   --budget <usd>            Max total budget in USD (default: 5.00)
 *   --dry-run                 Show what would be executed without running
 *   --help                    Show this help
 *
 * Exit codes:
 *   0 = Session completed successfully
 *   1 = Error
 *   2 = Check failures (needs manual intervention)
 */

import { createRequire } from 'node:module';
import { readFileSync, existsSync, mkdirSync } from 'node:fs';
import { resolve, join, basename } from 'node:path';
import { execFileSync } from 'node:child_process';
import { homedir } from 'node:os';

// Resolve globally-installed Agent SDK
const globalModules = join(process.execPath, '..', '..', 'lib', 'node_modules');
const require = createRequire(join(globalModules, '_anchor.js'));
const { query } = require('@anthropic-ai/claude-agent-sdk');

// ---------------------------------------------------------------------------
// CLI Parsing
// ---------------------------------------------------------------------------

const args = process.argv.slice(2);

function getArg(flag) {
  const idx = args.indexOf(flag);
  return idx !== -1 && idx + 1 < args.length ? args[idx + 1] : null;
}

if (args.includes('--help') || args.length === 0) {
  console.log(`forge-orchestrator.mjs v2.0.0 — Forge Dev Session Orchestrator (Agent SDK)

Usage:
  node forge-orchestrator.mjs --project <path> --session <name> [options]

Options:
  --project <path>          Project root directory (required)
  --session <name>          Session name from S4 roadmap (required)
  --work-size <size>        hotfix | standard (default: standard)
  --phase <N>               Start from phase: 1, 1.5, 2, 2.5, 3, 3.5, 3.9, 4 (default: 1)
  --spec <path>             Existing spec path (skip phase 2)
  --plan <path>             Existing plan path (skip plan step)
  --resume <session-id>     Resume a previous SDK session
  --skip-checks             Skip Check 3.5/3.7 parallel execution
  --budget <usd>            Max total budget in USD (default: 5.00)
  --dry-run                 Show execution plan without running
  --help                    Show this help

Work Sizes:
  hotfix    Phase 1(lightweight) -> Phase 3 -> Check 3 -> Phase 4
  standard  Full pipeline: Phase 1 -> 1.5 -> 2 -> 2.5 -> 3 -> Check 3/3.5/3.7 -> Walkthrough -> PR`);
  process.exit(0);
}

const projectPath = getArg('--project');
const sessionName = getArg('--session');
const workSize = getArg('--work-size') || 'standard';
const startPhase = parseFloat(getArg('--phase') || '1');
const existingSpec = getArg('--spec');
const existingPlan = getArg('--plan');
const resumeSessionId = getArg('--resume');
const skipChecks = args.includes('--skip-checks');
const totalBudget = parseFloat(getArg('--budget') || '5.00');
const dryRun = args.includes('--dry-run');

if (!projectPath || !sessionName) {
  console.error('ERROR: --project and --session are required.');
  process.exit(1);
}

if (!['hotfix', 'standard'].includes(workSize)) {
  console.error(`ERROR: --work-size must be "hotfix" or "standard" (got "${workSize}")`);
  process.exit(1);
}

const projectRoot = resolve(projectPath);
if (!existsSync(projectRoot)) {
  console.error(`ERROR: Project path not found: ${projectRoot}`);
  process.exit(1);
}

const HOME = homedir();
const SESSION_STATE = join(HOME, '.claude', 'forge', 'scripts', 'session-state.mjs');
const CHECK_PARALLEL = join(HOME, '.claude', 'scripts', 'check-parallel.mjs');

// ---------------------------------------------------------------------------
// Session State Integration (via session-state.mjs CLI)
// ---------------------------------------------------------------------------

function stateCmd(cmd, ...cmdArgs) {
  try {
    return execFileSync(
      process.execPath,
      [SESSION_STATE, cmd, ...cmdArgs],
      { cwd: projectRoot, encoding: 'utf8', timeout: 10000 }
    ).trim();
  } catch (err) {
    console.error(`[session-state] Command failed: ${cmd} ${cmdArgs.join(' ')}`);
    console.error(err.stderr || err.message);
    return null;
  }
}

function initSession() {
  // Check if session already exists
  const status = stateCmd('status', '--session', sessionName);
  if (status && !status.includes('ERROR')) {
    console.log(`Session "${sessionName}" already exists, resuming.`);
    return;
  }
  // Create new session
  const result = stateCmd('init', '--name', sessionName, '--work-size', workSize);
  if (result) {
    console.log(`Session initialized: ${sessionName} (${workSize})`);
  }
}

function checkpoint(phase) {
  const phaseMap = {
    1: 'phase1',
    1.5: 'phase1.5',
    2: 'phase2',
    3: 'phase3',
    4: 'session_complete',
  };
  const phaseName = phaseMap[phase];
  if (phaseName) {
    stateCmd('checkpoint', phaseName, '--session', sessionName);
  }
}

function setStateField(field, value) {
  stateCmd('set', field, String(value), '--session', sessionName);
}

function getStateField(field) {
  return stateCmd('get', field, '--session', sessionName);
}

// ---------------------------------------------------------------------------
// Helper: Run Agent (SDK v2)
// ---------------------------------------------------------------------------

// Initialize from --resume CLI flag if provided
let lastSessionId = resumeSessionId || null;

async function runAgent({
  prompt,
  model = 'claude-sonnet-4-6',
  tools,
  maxTurns = 20,
  budgetUsd = 1.0,
  permissionMode = 'acceptEdits',
  outputSchema = null,
}) {
  let resultText = '';

  const options = {
    cwd: projectRoot,
    model,
    allowedTools: tools,
    maxTurns,
    maxBudgetUsd: budgetUsd,
    permissionMode,
    settingSources: ['project'],  // P2-a: load project CLAUDE.md
  };

  // P2-d: Opus adaptive thinking
  if (model.includes('opus')) {
    options.thinking = { type: 'adaptive' };
  }

  // P2-c: structured output
  if (outputSchema) {
    options.outputFormat = { type: 'json_schema', schema: outputSchema };
  }

  // P2-e: session resumption
  if (lastSessionId) {
    options.resume = lastSessionId;
  }

  let sessionId = null;
  try {
    for await (const message of query({ prompt, options })) {
      // P2-e: capture session_id for resumption
      if (message.type === 'system' && message.subtype === 'init') {
        sessionId = message.session_id;
      }
      if ('result' in message) {
        resultText = message.result;
      }
    }
  } catch (err) {
    const msg = err.message || String(err);
    if (msg.includes('budget') || msg.includes('Budget')) {
      console.error(`[Budget Exceeded] Agent exceeded $${budgetUsd} budget. Model: ${model}`);
    }
    throw err;
  }

  // Store SDK session_id for resumption across phases
  if (sessionId) {
    lastSessionId = sessionId;
    stateCmd('set', 'sdkSessionId', sessionId, '--session', sessionName);
  }

  return { text: resultText, sessionId };
}

// ---------------------------------------------------------------------------
// Phase 1: Context Loading
// ---------------------------------------------------------------------------

async function phase1Context() {
  console.log('\n=== Phase 1: Context Loading ===\n');

  const isHotfix = workSize === 'hotfix';

  const { text } = await runAgent({
    prompt: `You are a Forge Dev session context loader.

Session: ${sessionName}
Project: ${projectRoot}
Work Size: ${workSize}

## Task
${isHotfix
    ? `Lightweight context loading for Hotfix.
Read the project CLAUDE.md and identify the specific issue/error and the file(s) to modify. Skip full project analysis.`
    : `Load and summarize the project context for this Forge Dev session.

## Steps
1. Read the Forge handoff document (look in docs/planning/active/forge/ for handoff.md or forge-handoff.md)
2. Read the S4 development plan (s4-development-plan.md)
3. Read the S4 roadmap to find this session's scope
4. Read the Todo tracker for current status
5. Read the project's CLAUDE.md for project conventions`}

## Output
Provide a structured context summary:
- Session scope (what features/specs this session covers)
- Tech stack and conventions
${isHotfix ? '- Specific file(s) to fix' : '- Dependencies on previous sessions (if any)\n- Key S4 references for spec writing'}`,
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Glob', 'Grep'],
    maxTurns: isHotfix ? 6 : 10,
    budgetUsd: isHotfix ? 0.15 : 0.30,
    permissionMode: 'plan',
  });

  console.log(text);
  checkpoint(1);
  return text;
}

// ---------------------------------------------------------------------------
// Phase 1.5: Requirements Analysis (Standard only)
// ---------------------------------------------------------------------------

async function phase15Requirements(context) {
  console.log('\n=== Phase 1.5: Requirements Analysis ===\n');

  const { text } = await runAgent({
    prompt: `You are a requirements analyst for a Forge Dev session.

Session: ${sessionName}
Project: ${projectRoot}
${context ? `\nContext from Phase 1:\n${context}` : ''}

## Task
Extract and organize functional requirements for this session from S4 documents.

## Steps
1. Read the S3 PRD/GDD (look in docs/planning/active/forge/ for s3-prd.md or s3-gdd.md)
2. Read the S4 detailed plan (s4-detailed-plan.md)
3. Read the S4 UI/UX spec (s4-uiux-spec.md)
4. Extract functional requirements relevant to session "${sessionName}"
5. Create a requirements list with IDs (FR-001, FR-002, ...)

## Output
Structured requirements list:
- FR-ID, Description, Priority (High/Medium/Low), Acceptance Criteria
- API endpoints needed
- Data models needed
- UI components needed`,
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Glob', 'Grep'],
    maxTurns: 15,
    budgetUsd: 0.50,
    permissionMode: 'plan',
  });

  console.log(text);
  checkpoint(1.5);
  return text;
}

// ---------------------------------------------------------------------------
// Phase 2: Spec Writing (Standard only)
// ---------------------------------------------------------------------------

async function phase2Spec(requirements) {
  if (existingSpec && existsSync(resolve(projectRoot, existingSpec))) {
    console.log(`\n=== Phase 2: Spec (using existing: ${existingSpec}) ===\n`);
    setStateField('specPath', existingSpec);
    return readFileSync(resolve(projectRoot, existingSpec), 'utf8');
  }

  console.log('\n=== Phase 2: Spec Writing ===\n');

  const specDir = join(projectRoot, '.specify', 'specs');
  if (!existsSync(specDir)) mkdirSync(specDir, { recursive: true });

  const { text } = await runAgent({
    prompt: `You are a technical spec writer for a Forge Dev session.

Session: ${sessionName}
Project: ${projectRoot}
${requirements ? `\nRequirements from Phase 1.5:\n${requirements}` : ''}

## Task
Write a technical spec document for this session.

## Spec Structure
Create the spec at: .specify/specs/${sessionName}.md

The spec must include:
1. **Overview** — What this session implements
2. **Functional Requirements** — FR-001, FR-002, ... with acceptance criteria
3. **API Specification** — Endpoints, methods, request/response schemas
4. **Data Models** — Entity definitions, relationships
5. **UI Components** — Component list, props, behavior
6. **Non-Functional Requirements** — Performance, security, accessibility
7. **Dependencies** — External services, libraries, previous session outputs
8. **Test Requirements** — What must be tested and how

## References
Read S4 documents from docs/planning/active/forge/ for reference:
- s4-detailed-plan.md
- s4-development-plan.md (includes test strategy section)
- s4-uiux-spec.md

Write the spec file to .specify/specs/${sessionName}.md`,
    model: 'claude-opus-4-6',
    tools: ['Read', 'Write', 'Glob', 'Grep'],
    maxTurns: 25,
    budgetUsd: 1.0,
  });

  const specPath = `.specify/specs/${sessionName}.md`;
  setStateField('specPath', specPath);
  console.log(`Spec written to: ${specPath}`);
  return text;
}

// ---------------------------------------------------------------------------
// Phase 2.5: Plan Writing (conditional — multi-domain or 10+ files)
// ---------------------------------------------------------------------------

async function phase25Plan() {
  const specPath = existingSpec || getStateField('specPath') || `.specify/specs/${sessionName}.md`;

  if (existingPlan && existsSync(resolve(projectRoot, existingPlan))) {
    console.log(`\n=== Phase 2.5: Plan (using existing: ${existingPlan}) ===\n`);
    setStateField('planPath', existingPlan);
    return readFileSync(resolve(projectRoot, existingPlan), 'utf8');
  }

  console.log('\n=== Phase 2.5: Plan Writing ===\n');

  const planDir = join(projectRoot, '.specify', 'plans');
  if (!existsSync(planDir)) mkdirSync(planDir, { recursive: true });

  const { text } = await runAgent({
    prompt: `You are a technical planner for a Forge Dev session.

Session: ${sessionName}
Project: ${projectRoot}
Spec: ${specPath}

## Task
Read the spec at ${specPath} and create an implementation plan.

## Plan Structure
Create the plan at: .specify/plans/${sessionName}.plan.md

The plan must include:
1. **Task Breakdown** — Ordered list of implementation tasks
2. **File Changes** — Which files to create/modify per task
3. **Dependencies** — Task ordering (what must be done first)
4. **Test Strategy** — Which tests to write for each task
5. **Estimated Complexity** — Simple/Medium/Complex per task

## Important
- The plan should be What-focused (what to do), not How-focused (implementation details)
- Each task should be independently verifiable
- Group related changes into logical tasks`,
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Write', 'Glob', 'Grep'],
    maxTurns: 15,
    budgetUsd: 0.50,
  });

  const planPath = `.specify/plans/${sessionName}.plan.md`;
  setStateField('planPath', planPath);
  console.log(`Plan written to: ${planPath}`);
  return text;
}

// ---------------------------------------------------------------------------
// Phase 3: Implementation
// ---------------------------------------------------------------------------

async function phase3Implement() {
  console.log('\n=== Phase 3: Implementation ===\n');

  const specPath = existingSpec || getStateField('specPath') || `.specify/specs/${sessionName}.md`;
  const planPath = existingPlan || getStateField('planPath') || `.specify/plans/${sessionName}.plan.md`;

  const isHotfix = workSize === 'hotfix';

  let result;
  try {
    result = await runAgent({
      prompt: `You are a senior developer implementing a Forge Dev session.

Session: ${sessionName}
Project: ${projectRoot}
Work Size: ${workSize}
${isHotfix ? '' : `Spec: ${specPath}\nPlan: ${planPath}\n`}

## Task
${isHotfix
    ? `Implement the hotfix. Focus on the specific fix only.
Read the project context and apply the minimal change needed.`
    : `Implement the features described in the spec following the plan.

## Steps
1. Read the spec at ${specPath}
2. Read the plan at ${planPath}
3. Read the project's existing code structure (CLAUDE.md, package.json, tsconfig)
4. Implement each task from the plan in order
5. Write tests for each implemented feature (TDD: write test first, then implement)
6. Ensure all existing tests still pass`}

## Rules
- Follow existing project conventions
- Write TypeScript with strict types (no any)
- Include proper error handling
${isHotfix ? '' : `- Write unit tests for all new functions
- Write integration tests for API endpoints
- Follow the test strategy section from S4 development-plan.md
`}
## After Implementation
Run the project's verify/build/test commands to ensure everything passes.`,
      model: isHotfix ? 'claude-sonnet-4-6' : 'claude-opus-4-6',
      tools: ['Read', 'Write', 'Edit', 'Glob', 'Grep', 'Bash'],
      maxTurns: isHotfix ? 25 : 50,
      budgetUsd: isHotfix ? totalBudget * 0.3 : totalBudget * 0.4,
    });

  } catch (err) {
    stateCmd('set', 'currentPhase', 'phase3', '--session', sessionName);
    console.error(`\nPhase 3 Implementation FAILED: ${err.message}`);
    console.error('\n--- Recovery Guidance ---');
    console.error('Implementation failed. State saved at Phase 3. Options:');
    console.error(`  1. Resume implementation: node ~/.claude/scripts/forge-orchestrator.mjs --project "${projectRoot}" --session "${sessionName}" --work-size ${workSize} --phase 3`);
    console.error(`  2. Resume with updated spec: ... --phase 3 --spec <new-spec-path>`);
    console.error(`  3. Start fresh from plan: ... --phase 2`);
    console.error(`  4. Resume SDK session: ... --phase 3 --resume ${lastSessionId || '<session-id>'}`);
    console.error(`  5. Check session state: node /home/damools/forge/dev/scripts/session-state.mjs status --session "${sessionName}"`);
    console.error(`\nBudget consumed: ~$${(totalBudget * 0.4).toFixed(2)} (40% of $${totalBudget})`);
    throw err;
  }

  console.log('Implementation complete.');
  return result.text;
}

// ---------------------------------------------------------------------------
// Check 3: verify.sh code (Bash — build + test + lint)
// ---------------------------------------------------------------------------

function runCheck3() {
  console.log('\n=== Check 3: verify.sh code ===\n');

  const verifyPath = join(projectRoot, 'scripts', 'verify.sh');
  if (!existsSync(verifyPath)) {
    console.log('verify.sh not found, skipping Check 3.');
    return { status: 'SKIP', reason: 'verify.sh not found' };
  }

  try {
    const output = execFileSync(
      'bash',
      [verifyPath, 'code'],
      { encoding: 'utf8', cwd: projectRoot, timeout: 300000, stdio: ['pipe', 'pipe', 'pipe'] }
    );
    console.log('Check 3: PASS');
    console.log(output);
    return { status: 'PASS', output };
  } catch (err) {
    console.error('Check 3: FAIL');
    console.error(err.stdout || '');
    console.error(err.stderr || '');
    return { status: 'FAIL', output: err.stdout, error: err.stderr };
  }
}

// ---------------------------------------------------------------------------
// Check 3.5 + 3.7: Parallel via check-parallel.mjs (Standard only)
// ---------------------------------------------------------------------------

function runParallelChecks() {
  if (skipChecks || workSize === 'hotfix') {
    console.log('\n=== Check 3.5/3.7: SKIPPED ===\n');
    return null;
  }

  console.log('\n=== Check 3.5/3.7: Parallel Checks ===\n');

  const specBasename = basename(
    existingSpec || getStateField('specPath') || sessionName,
    '.md'
  );

  try {
    const output = execFileSync(
      process.execPath,
      [CHECK_PARALLEL, '--project', projectRoot, '--spec', specBasename, '--checks', '3.5,3.7', '--budget', '0.50'],
      { encoding: 'utf8', timeout: 600000, stdio: ['pipe', 'pipe', 'inherit'] }
    );

    let checkResults;
    try {
      checkResults = JSON.parse(output);
    } catch {
      checkResults = { overallStatus: 'ERROR', rawOutput: output.slice(0, 1000) };
    }

    console.log(`Parallel checks result: ${checkResults.overallStatus}`);

    if (checkResults.overallStatus === 'FAIL') {
      console.error('\nCheck 3.5/3.7 FAILED — Manual intervention needed.');
      console.error('Run individual checks to debug:');
      console.error(`  node ${CHECK_PARALLEL} --project "${projectRoot}" --spec "${specBasename}" --checks 3.5`);
      console.error(`  node ${CHECK_PARALLEL} --project "${projectRoot}" --spec "${specBasename}" --checks 3.7`);
    }

    return checkResults;
  } catch (err) {
    console.error(`Parallel checks execution failed: ${err.message}`);
    console.error('\n--- Recovery Guidance ---');
    console.error('The check process itself failed (not a check failure, but an execution error).');
    console.error('Options:');
    console.error(`  1. Retry checks: node ${CHECK_PARALLEL} --project "${projectRoot}" --spec "${specBasename}"`);
    console.error(`  2. Skip checks and continue: node ~/.claude/scripts/forge-orchestrator.mjs --project "${projectRoot}" --session "${sessionName}" --work-size ${workSize} --phase 3.9 --skip-checks`);
    console.error(`  3. Resume from Phase 3 (re-implement): ... --phase 3`);
    return { overallStatus: 'ERROR', error: err.message };
  }
}

// ---------------------------------------------------------------------------
// Phase 3.9: Walkthrough (Standard only)
// ---------------------------------------------------------------------------

async function phase39Walkthrough() {
  if (workSize === 'hotfix') {
    console.log('\n=== Phase 3.9: Walkthrough (SKIPPED for Hotfix) ===\n');
    return null;
  }

  console.log('\n=== Phase 3.9: Walkthrough ===\n');

  const specPath = existingSpec || getStateField('specPath') || `.specify/specs/${sessionName}.md`;

  const walkthroughDir = join(projectRoot, 'docs', 'walkthroughs');
  if (!existsSync(walkthroughDir)) mkdirSync(walkthroughDir, { recursive: true });

  const { text } = await runAgent({
    prompt: `You are a technical writer creating a walkthrough document.

Session: ${sessionName}
Project: ${projectRoot}
Spec: ${specPath}

## Task
Create a walkthrough document summarizing what was implemented in this session.

## Steps
1. Read the spec at ${specPath}
2. Check git diff to see all changes made
3. Write a walkthrough at docs/walkthroughs/${sessionName}-walkthrough.md

## Walkthrough Structure
1. **Summary** — What was implemented
2. **Files Changed** — List of new/modified files with brief description
3. **Key Decisions** — Any architectural or design decisions made
4. **Testing** — What tests were added and coverage
5. **Known Issues** — Any remaining issues or limitations
6. **Next Steps** — What should be done in the next session`,
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Write', 'Glob', 'Grep', 'Bash'],
    maxTurns: 15,
    budgetUsd: 0.30,
  });

  setStateField('walkthroughPath', `docs/walkthroughs/${sessionName}-walkthrough.md`);
  console.log(`Walkthrough written to: docs/walkthroughs/${sessionName}-walkthrough.md`);
  return text;
}

// ---------------------------------------------------------------------------
// Phase 4: PR Preparation
// ---------------------------------------------------------------------------

async function phase4PR() {
  console.log('\n=== Phase 4: PR Preparation ===\n');

  const specPath = existingSpec || getStateField('specPath') || `.specify/specs/${sessionName}.md`;
  const walkthroughPath = getStateField('walkthroughPath') || `docs/walkthroughs/${sessionName}-walkthrough.md`;

  const { text } = await runAgent({
    prompt: `You are preparing a Pull Request for a Forge Dev session.

Session: ${sessionName}
Project: ${projectRoot}
Work Size: ${workSize}
${workSize !== 'hotfix' ? `Spec: ${specPath}\nWalkthrough: ${walkthroughPath}` : ''}

## Task
Create a git commit and prepare PR content (do NOT push or create the PR).

## Steps
1. Run git status to see all changes
2. Run git diff to review changes
3. Stage relevant files (exclude .claude/state/ files)
4. Create a commit with message format:
   ${workSize === 'hotfix' ? `fix(${sessionName}): <summary>` : `feat(${sessionName}): <summary>`}

   <detailed description${workSize !== 'hotfix' ? ' from walkthrough' : ''}>

   Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
5. Output the PR title and body that should be used

## Output
Provide:
- The commit hash
- Suggested PR title
- Suggested PR body (markdown)
- Branch name suggestion

Do NOT run git push or gh pr create — the human will do that.`,
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Glob', 'Grep', 'Bash'],
    maxTurns: 10,
    budgetUsd: 0.20,
  });

  checkpoint(4);
  console.log(text);
  return text;
}

// ---------------------------------------------------------------------------
// Main Pipeline
// ---------------------------------------------------------------------------

async function main() {
  console.log(`forge-orchestrator.mjs v2.0.0 — Session: ${sessionName}`);
  console.log(`Project: ${projectRoot}`);
  console.log(`Work Size: ${workSize}`);
  console.log(`Start phase: ${startPhase}`);
  console.log(`Budget: $${totalBudget}`);
  if (resumeSessionId) {
    console.log(`Resume SDK session: ${resumeSessionId}`);
  }

  const isHotfix = workSize === 'hotfix';

  if (dryRun) {
    console.log('\n--- DRY RUN ---');
    const phases = [];
    if (startPhase <= 1) phases.push('Phase 1: Context Loading' + (isHotfix ? ' (lightweight)' : ''));
    if (!isHotfix && startPhase <= 1.5) phases.push('Phase 1.5: Requirements Analysis');
    if (!isHotfix && startPhase <= 2) phases.push('Phase 2: Spec Writing');
    if (!isHotfix && startPhase <= 2.5) phases.push('Phase 2.5: Plan Writing');
    if (startPhase <= 3) phases.push('Phase 3: Implementation');
    phases.push('Check 3: verify.sh code');
    if (!isHotfix && !skipChecks && startPhase <= 3.5) phases.push('Check 3.5 + 3.7: Parallel Checks');
    if (!isHotfix && startPhase <= 3.9) phases.push('Phase 3.9: Walkthrough');
    if (startPhase <= 4) phases.push('Phase 4: PR Preparation');
    phases.forEach(p => console.log(`  - ${p}`));
    process.exit(0);
  }

  // Initialize session via session-state.mjs
  initSession();

  let context = null;
  let requirements = null;

  try {
    // Phase 1: Context Loading (both Hotfix and Standard)
    if (startPhase <= 1) {
      context = await phase1Context();
    }

    // Standard-only phases: 1.5, 2, 2.5
    if (!isHotfix) {
      if (startPhase <= 1.5) {
        requirements = await phase15Requirements(context);
      }

      if (startPhase <= 2) {
        await phase2Spec(requirements);
        checkpoint(2);
      }

      if (startPhase <= 2.5) {
        await phase25Plan();
      }
    }

    // Phase 3: Implementation (both)
    if (startPhase <= 3) {
      await phase3Implement();
      checkpoint(3);
    }

    // Check 3: verify.sh code (both Hotfix and Standard)
    if (startPhase <= 3.5) {
      const check3Result = runCheck3();
      if (check3Result.status === 'FAIL') {
        console.error('\nCheck 3 FAILED — verify.sh code did not pass.');
        console.error('Fix the issues and re-run with --phase 3');
        process.exit(2);
      }
    }

    // Check 3.5 + 3.7: Parallel (Standard only, not Hotfix)
    if (startPhase <= 3.5 && !isHotfix) {
      const parallelResults = runParallelChecks();
      if (parallelResults?.overallStatus === 'FAIL') {
        console.error('\nParallel checks FAILED — fix issues and re-run with --phase 3.5');
        process.exit(2);
      }
    }

    // Phase 3.9: Walkthrough (Standard only)
    if (startPhase <= 3.9) {
      await phase39Walkthrough();
    }

    // Phase 4: PR Preparation (both)
    if (startPhase <= 4) {
      await phase4PR();
    }

    console.log('\n=== Session Complete ===');
    console.log(`Session state managed by: node /home/damools/forge/dev/scripts/session-state.mjs status --session "${sessionName}"`);
    process.exit(0);

  } catch (err) {
    console.error(`\nFatal error: ${err.message}`);
    console.error(`Session state: node /home/damools/forge/dev/scripts/session-state.mjs status --session "${sessionName}"`);
    console.error(`Resume with: node ~/.claude/scripts/forge-orchestrator.mjs --project "${projectRoot}" --session "${sessionName}" --work-size ${workSize} --phase <N>${lastSessionId ? ` --resume ${lastSessionId}` : ''}`);
    process.exit(1);
  }
}

main();
