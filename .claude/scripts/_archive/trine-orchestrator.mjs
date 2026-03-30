#!/usr/bin/env node
/**
 * trine-orchestrator.mjs v1.0.0
 * Trine Session Orchestrator — Agent SDK
 *
 * Automates a Trine session: Spec -> Plan -> Implementation -> Check -> Walkthrough -> PR
 * Uses Agent SDK for programmatic agent execution with model tiering.
 *
 * Usage:
 *   node ~/.claude/scripts/trine-orchestrator.mjs --project <path> --session <name> [options]
 *   node ~/.claude/scripts/trine-orchestrator.mjs --help
 *
 * Options:
 *   --project <path>     Project root directory (required)
 *   --session <name>     Session name from S4 roadmap (required)
 *   --phase <N>          Start from phase (default: 1)
 *                         1=Context, 1.5=Requirements, 2=Spec, 3=Implement, 4=PR
 *   --spec <path>        Existing spec path (skip phase 2)
 *   --plan <path>        Existing plan path (skip plan step)
 *   --skip-checks        Skip Check 3 parallel execution
 *   --budget <usd>       Max total budget in USD (default: 5.00)
 *   --dry-run            Show what would be executed without running
 *   --help               Show this help
 *
 * Exit codes:
 *   0 = Session completed successfully
 *   1 = Error
 *   2 = Check failures (needs manual intervention)
 */

import { createRequire } from 'node:module';
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs';
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
  console.log(`trine-orchestrator.mjs — Trine Session Orchestrator (Agent SDK)

Usage:
  node trine-orchestrator.mjs --project <path> --session <name> [options]

Options:
  --project <path>     Project root directory (required)
  --session <name>     Session name from S4 roadmap (required)
  --phase <N>          Start from phase: 1, 1.5, 2, 3, 4 (default: 1)
  --spec <path>        Existing spec path (skip phase 2)
  --plan <path>        Existing plan path (skip plan step)
  --skip-checks        Skip Check 3 parallel execution
  --budget <usd>       Max total budget in USD (default: 5.00)
  --dry-run            Show execution plan without running
  --help               Show this help`);
  process.exit(0);
}

const projectPath = getArg('--project');
const sessionName = getArg('--session');
const startPhase = parseFloat(getArg('--phase') || '1');
const existingSpec = getArg('--spec');
const existingPlan = getArg('--plan');
const skipChecks = args.includes('--skip-checks');
const totalBudget = parseFloat(getArg('--budget') || '5.00');
const dryRun = args.includes('--dry-run');

if (!projectPath || !sessionName) {
  console.error('ERROR: --project and --session are required.');
  process.exit(1);
}

const projectRoot = resolve(projectPath);
if (!existsSync(projectRoot)) {
  console.error(`ERROR: Project path not found: ${projectRoot}`);
  process.exit(1);
}

const HOME = homedir();
const CHECK_PARALLEL = join(HOME, '.claude', 'scripts', 'check-parallel.mjs');

// ---------------------------------------------------------------------------
// Session State
// ---------------------------------------------------------------------------

const stateDir = join(projectRoot, '.trine');
const stateFile = join(stateDir, `${sessionName}.state.json`);

function loadState() {
  if (existsSync(stateFile)) {
    return JSON.parse(readFileSync(stateFile, 'utf8'));
  }
  return {
    session: sessionName,
    project: projectRoot,
    startedAt: new Date().toISOString(),
    currentPhase: startPhase,
    specPath: existingSpec || null,
    planPath: existingPlan || null,
    checkResults: null,
    walkthroughPath: null,
    prUrl: null,
  };
}

function saveState(state) {
  if (!existsSync(stateDir)) mkdirSync(stateDir, { recursive: true });
  writeFileSync(stateFile, JSON.stringify(state, null, 2));
}

// ---------------------------------------------------------------------------
// Helper: Run Agent
// ---------------------------------------------------------------------------

async function runAgent({ prompt, model = 'claude-sonnet-4-6', tools, maxTurns = 20, budgetUsd = 1.0, permissionMode = 'acceptEdits' }) {
  let resultText = '';

  for await (const message of query({
    prompt,
    options: {
      cwd: projectRoot,
      model,
      allowedTools: tools,
      maxTurns,
      maxBudgetUsd: budgetUsd,
      permissionMode,
    },
  })) {
    if ('result' in message) {
      resultText = message.result;
    }
  }

  return resultText;
}

// ---------------------------------------------------------------------------
// Phase 1: Context Loading
// ---------------------------------------------------------------------------

async function phase1Context(state) {
  console.log('\n=== Phase 1: Context Loading ===\n');

  const result = await runAgent({
    prompt: `You are a Trine session context loader.

Session: ${sessionName}
Project: ${projectRoot}

## Task
Load and summarize the project context for this Trine session.

## Steps
1. Read the SIGIL handoff document (look in docs/planning/active/sigil/ for handoff.md or sigil-handoff.md)
2. Read the S4 development plan (s4-development-plan.md)
3. Read the S4 roadmap to find this session's scope
4. Read the Todo tracker for current status
5. Read the project's CLAUDE.md for project conventions

## Output
Provide a structured context summary:
- Session scope (what features/specs this session covers)
- Tech stack and conventions
- Dependencies on previous sessions (if any)
- Key S4 references for spec writing`,
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Glob', 'Grep'],
    maxTurns: 10,
    budgetUsd: 0.30,
    permissionMode: 'plan',
  });

  console.log(result);
  state.currentPhase = 1.5;
  saveState(state);
  return result;
}

// ---------------------------------------------------------------------------
// Phase 1.5: Requirements Analysis
// ---------------------------------------------------------------------------

async function phase15Requirements(state, context) {
  console.log('\n=== Phase 1.5: Requirements Analysis ===\n');

  const result = await runAgent({
    prompt: `You are a requirements analyst for a Trine session.

Session: ${sessionName}
Project: ${projectRoot}
${context ? `\nContext from Phase 1:\n${context}` : ''}

## Task
Extract and organize functional requirements for this session from S4 documents.

## Steps
1. Read the S3 PRD/GDD (look in docs/planning/active/sigil/ for s3-prd.md or s3-gdd.md)
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

  console.log(result);
  state.currentPhase = 2;
  saveState(state);
  return result;
}

// ---------------------------------------------------------------------------
// Phase 2: Spec Writing
// ---------------------------------------------------------------------------

async function phase2Spec(state, requirements) {
  if (state.specPath && existsSync(resolve(projectRoot, state.specPath))) {
    console.log(`\n=== Phase 2: Spec (using existing: ${state.specPath}) ===\n`);
    return readFileSync(resolve(projectRoot, state.specPath), 'utf8');
  }

  console.log('\n=== Phase 2: Spec Writing ===\n');

  const specDir = join(projectRoot, '.specify', 'specs');
  if (!existsSync(specDir)) mkdirSync(specDir, { recursive: true });

  const result = await runAgent({
    prompt: `You are a technical spec writer for a Trine session.

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
Read S4 documents from docs/planning/active/sigil/ for reference:
- s4-detailed-plan.md
- s4-uiux-spec.md
- s4-test-strategy.md

Write the spec file to .specify/specs/${sessionName}.md`,
    model: 'claude-opus-4-6',
    tools: ['Read', 'Write', 'Glob', 'Grep'],
    maxTurns: 25,
    budgetUsd: 1.0,
  });

  const specPath = `.specify/specs/${sessionName}.md`;
  state.specPath = specPath;
  state.currentPhase = 2.5;
  saveState(state);

  console.log(`Spec written to: ${specPath}`);
  return result;
}

// ---------------------------------------------------------------------------
// Phase 2.5: Plan Writing
// ---------------------------------------------------------------------------

async function phase25Plan(state) {
  if (state.planPath && existsSync(resolve(projectRoot, state.planPath))) {
    console.log(`\n=== Phase 2.5: Plan (using existing: ${state.planPath}) ===\n`);
    return readFileSync(resolve(projectRoot, state.planPath), 'utf8');
  }

  console.log('\n=== Phase 2.5: Plan Writing ===\n');

  const planDir = join(projectRoot, '.specify', 'plans');
  if (!existsSync(planDir)) mkdirSync(planDir, { recursive: true });

  const result = await runAgent({
    prompt: `You are a technical planner for a Trine session.

Session: ${sessionName}
Project: ${projectRoot}
Spec: ${state.specPath}

## Task
Read the spec at ${state.specPath} and create an implementation plan.

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
  state.planPath = planPath;
  state.currentPhase = 3;
  saveState(state);

  console.log(`Plan written to: ${planPath}`);
  return result;
}

// ---------------------------------------------------------------------------
// Phase 3: Implementation
// ---------------------------------------------------------------------------

async function phase3Implement(state) {
  console.log('\n=== Phase 3: Implementation ===\n');

  let result;
  try {
  result = await runAgent({
    prompt: `You are a senior developer implementing a Trine session.

Session: ${sessionName}
Project: ${projectRoot}
Spec: ${state.specPath}
Plan: ${state.planPath}

## Task
Implement the features described in the spec following the plan.

## Steps
1. Read the spec at ${state.specPath}
2. Read the plan at ${state.planPath}
3. Read the project's existing code structure (CLAUDE.md, package.json, tsconfig)
4. Implement each task from the plan in order
5. Write tests for each implemented feature
6. Ensure all existing tests still pass

## Rules
- Follow existing project conventions
- Write TypeScript with strict types (no any)
- Include proper error handling
- Write unit tests for all new functions
- Write integration tests for API endpoints
- Follow the test strategy from S4 test-strategy.md

## After Implementation
Run the project's verify/build/test commands to ensure everything passes.`,
    model: 'claude-opus-4-6',
    tools: ['Read', 'Write', 'Edit', 'Glob', 'Grep', 'Bash'],
    maxTurns: 50,
    budgetUsd: totalBudget * 0.4,
  });

  } catch (err) {
    state.currentPhase = 3;
    saveState(state);
    console.error(`\nPhase 3 Implementation FAILED: ${err.message}`);
    console.error('\n--- Recovery Guidance ---');
    console.error('Implementation failed. State saved at Phase 3. Options:');
    console.error(`  1. Resume implementation: node ~/.claude/scripts/trine-orchestrator.mjs --project "${projectRoot}" --session "${sessionName}" --phase 3`);
    console.error(`  2. Resume with updated spec: node ~/.claude/scripts/trine-orchestrator.mjs --project "${projectRoot}" --session "${sessionName}" --phase 3 --spec <new-spec-path>`);
    console.error(`  3. Start fresh from plan: node ~/.claude/scripts/trine-orchestrator.mjs --project "${projectRoot}" --session "${sessionName}" --phase 2`);
    console.error(`\nBudget consumed: ~$${(totalBudget * 0.4).toFixed(2)} (40% of $${totalBudget})`);
    throw err;
  }

  state.currentPhase = 3.5;
  saveState(state);

  console.log('Implementation complete.');
  return result;
}

// ---------------------------------------------------------------------------
// Phase 3.5: Check 3 (Parallel)
// ---------------------------------------------------------------------------

async function phase35Checks(state) {
  if (skipChecks) {
    console.log('\n=== Phase 3.5: Checks (SKIPPED) ===\n');
    state.currentPhase = 3.9;
    saveState(state);
    return null;
  }

  console.log('\n=== Phase 3.5: Check 3 Parallel ===\n');

  const specBasename = basename(state.specPath || sessionName, '.md');

  try {
    // Use execFileSync to avoid shell injection
    const output = execFileSync(
      process.execPath,
      [CHECK_PARALLEL, '--project', projectRoot, '--spec', specBasename, '--budget', '0.50'],
      { encoding: 'utf8', timeout: 600000, stdio: ['pipe', 'pipe', 'inherit'] }
    );

    let checkResults;
    try {
      checkResults = JSON.parse(output);
    } catch {
      checkResults = { overallStatus: 'ERROR', rawOutput: output.slice(0, 1000) };
    }

    state.checkResults = checkResults;
    state.currentPhase = 3.9;
    saveState(state);

    console.log(`Check results: ${checkResults.overallStatus}`);

    if (checkResults.overallStatus === 'FAIL') {
      console.error('\nCheck 3 FAILED — Manual intervention needed.');
      console.error('Run individual checks to debug:');
      console.error(`  node ${CHECK_PARALLEL} --project "${projectRoot}" --spec "${specBasename}" --checks 3.5`);
      return checkResults;
    }

    return checkResults;
  } catch (err) {
    console.error(`Check 3 execution failed: ${err.message}`);
    state.checkResults = { overallStatus: 'ERROR', error: err.message };
    state.currentPhase = 3.9;
    saveState(state);
    console.error('\n--- Recovery Guidance ---');
    console.error('The Check 3 process itself failed (not a check failure, but an execution error).');
    console.error('Options:');
    console.error(`  1. Retry checks: node ${CHECK_PARALLEL} --project "${projectRoot}" --spec "${basename(state.specPath || sessionName, '.md')}"`);
    console.error(`  2. Skip checks and continue: node ~/.claude/scripts/trine-orchestrator.mjs --project "${projectRoot}" --session "${sessionName}" --phase 4 --skip-checks`);
    console.error(`  3. Resume from Phase 3 (re-implement): node ~/.claude/scripts/trine-orchestrator.mjs --project "${projectRoot}" --session "${sessionName}" --phase 3`);
    return state.checkResults;
  }
}

// ---------------------------------------------------------------------------
// Phase 3.9: Walkthrough
// ---------------------------------------------------------------------------

async function phase39Walkthrough(state) {
  console.log('\n=== Phase 3.9: Walkthrough ===\n');

  const walkthroughDir = join(projectRoot, 'docs', 'walkthroughs');
  if (!existsSync(walkthroughDir)) mkdirSync(walkthroughDir, { recursive: true });

  const result = await runAgent({
    prompt: `You are a technical writer creating a walkthrough document.

Session: ${sessionName}
Project: ${projectRoot}
Spec: ${state.specPath}

## Task
Create a walkthrough document summarizing what was implemented in this session.

## Steps
1. Read the spec at ${state.specPath}
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

  state.walkthroughPath = `docs/walkthroughs/${sessionName}-walkthrough.md`;
  state.currentPhase = 4;
  saveState(state);

  console.log(`Walkthrough written to: ${state.walkthroughPath}`);
  return result;
}

// ---------------------------------------------------------------------------
// Phase 4: PR Preparation
// ---------------------------------------------------------------------------

async function phase4PR(state) {
  console.log('\n=== Phase 4: PR Preparation ===\n');

  const result = await runAgent({
    prompt: `You are preparing a Pull Request for a Trine session.

Session: ${sessionName}
Project: ${projectRoot}
Spec: ${state.specPath}
Walkthrough: ${state.walkthroughPath}

## Task
Create a git commit and prepare PR content (do NOT push or create the PR).

## Steps
1. Run git status to see all changes
2. Run git diff to review changes
3. Stage relevant files (exclude .trine/ state files)
4. Create a commit with message format:
   feat(${sessionName}): <summary>

   <detailed description from walkthrough>

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

  state.currentPhase = 'complete';
  state.completedAt = new Date().toISOString();
  saveState(state);

  console.log(result);
  return result;
}

// ---------------------------------------------------------------------------
// Main Pipeline
// ---------------------------------------------------------------------------

async function main() {
  console.log(`trine-orchestrator.mjs — Session: ${sessionName}`);
  console.log(`Project: ${projectRoot}`);
  console.log(`Start phase: ${startPhase}`);
  console.log(`Budget: $${totalBudget}`);

  if (dryRun) {
    console.log('\n--- DRY RUN ---');
    const phases = [];
    if (startPhase <= 1) phases.push('Phase 1: Context Loading');
    if (startPhase <= 1.5) phases.push('Phase 1.5: Requirements Analysis');
    if (startPhase <= 2) phases.push('Phase 2: Spec Writing');
    if (startPhase <= 2.5) phases.push('Phase 2.5: Plan Writing');
    if (startPhase <= 3) phases.push('Phase 3: Implementation');
    if (!skipChecks && startPhase <= 3.5) phases.push('Phase 3.5: Check 3 Parallel');
    if (startPhase <= 3.9) phases.push('Phase 3.9: Walkthrough');
    if (startPhase <= 4) phases.push('Phase 4: PR Preparation');
    phases.forEach(p => console.log(`  - ${p}`));
    process.exit(0);
  }

  const state = loadState();

  // CLI args override state file values (for resume with new paths)
  if (existingSpec) state.specPath = existingSpec;
  if (existingPlan) state.planPath = existingPlan;

  let context = null;
  let requirements = null;

  try {
    if (startPhase <= 1 && state.currentPhase <= 1) {
      context = await phase1Context(state);
    }

    if (startPhase <= 1.5 && state.currentPhase <= 1.5) {
      requirements = await phase15Requirements(state, context);
    }

    if (startPhase <= 2 && state.currentPhase <= 2) {
      await phase2Spec(state, requirements);
    }

    if (startPhase <= 2.5 && state.currentPhase <= 2.5) {
      await phase25Plan(state);
    }

    if (startPhase <= 3 && state.currentPhase <= 3) {
      await phase3Implement(state);
    }

    if (startPhase <= 3.5 && state.currentPhase <= 3.5) {
      const checkResults = await phase35Checks(state);
      if (checkResults?.overallStatus === 'FAIL') {
        console.error('\nSession paused at Check 3 — fix issues and re-run with --phase 3.5');
        process.exit(2);
      }
    }

    if (startPhase <= 3.9 && state.currentPhase <= 3.9) {
      await phase39Walkthrough(state);
    }

    if (startPhase <= 4 && state.currentPhase <= 4) {
      await phase4PR(state);
    }

    console.log('\n=== Session Complete ===');
    console.log(`State saved to: ${stateFile}`);
    process.exit(0);

  } catch (err) {
    console.error(`\nFatal error in phase ${state.currentPhase}: ${err.message}`);
    saveState(state);
    console.error(`State saved. Resume with: --phase ${state.currentPhase}`);
    process.exit(1);
  }
}

main();
