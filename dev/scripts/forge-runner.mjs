#!/usr/bin/env node
/**
 * forge-runner.mjs v1.0.0
 * Forge Pipeline Automation — Agent SDK
 *
 * Runs Forge S1->S4 pipeline stages programmatically using Agent SDK.
 * Each stage uses model tiering (Opus/Sonnet/Haiku) per Forge governance rules.
 *
 * Usage:
 *   node ~/.claude/scripts/forge-runner.mjs --project <name> --type <type> [options]
 *   node ~/.claude/scripts/forge-runner.mjs --help
 *
 * Options:
 *   --project <name>     Project name (required, matches forge-workspace.json)
 *   --type <type>        Project type: app|web|game|youtube|shortform (required)
 *   --start <stage>      Start stage: S1|S2|S3|S4|S4-exec (default: S1)
 *   --idea <text>        Project idea (required for S1 start)
 *   --budget <usd>       Max total budget in USD (default: 10.00)
 *   --workspace <path>   Forge workspace root (default: ~/forge)
 *   --dry-run            Show execution plan without running
 *   --help               Show this help
 *
 * Exit codes:
 *   0 = Completed (or reached gate stop)
 *   1 = Error
 */

import { createRequire } from 'node:module';
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs';
import { resolve, join } from 'node:path';
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
  console.log(`forge-runner.mjs — Forge Pipeline Automation (Agent SDK)

Usage:
  node forge-runner.mjs --project <name> --type <type> [options]

Options:
  --project <name>     Project name (required)
  --type <type>        app|web|game|youtube|shortform (required)
  --start <stage>      S1|S2|S3|S4|S4-exec (default: S1)
  --idea <text>        Project idea (required for S1)
  --budget <usd>       Max total budget (default: 10.00)
  --workspace <path>   Forge workspace root (default: ~/forge)
  --dry-run            Show plan without running
  --help               Show this help

Stages:
  S1 Research     — Market/academic/competitor research (Fan-out parallel)
  S2 Concept      — Lean Canvas + Go/No-Go scoring
  S3 Design Doc   — PRD/GDD with Competing Hypotheses (3 agents)
  S4 Intra-Gate   — S4 구조/접근 방식 제시 (Human 승인 대기)
  S4-exec         — 3 deliverables via Wave Protocol (승인 후 실행)`);
  process.exit(0);
}

const projectName = getArg('--project');
const projectType = getArg('--type');
const startStage = getArg('--start') || 'S1';
const idea = getArg('--idea');
const totalBudget = parseFloat(getArg('--budget') || '10.00');
const workspaceRoot = resolve(getArg('--workspace') || join(homedir(), 'forge'));
const dryRun = args.includes('--dry-run');

if (!projectName || !projectType) {
  console.error('ERROR: --project and --type are required.');
  process.exit(1);
}

const validTypes = ['app', 'web', 'game', 'youtube', 'shortform'];
if (!validTypes.includes(projectType)) {
  console.error(`ERROR: Invalid type. Valid: ${validTypes.join(', ')}`);
  process.exit(1);
}

const validStages = ['S1', 'S2', 'S3', 'S4', 'S4-exec'];
if (!validStages.includes(startStage)) {
  console.error(`ERROR: Invalid stage. Valid: ${validStages.join(', ')}`);
  process.exit(1);
}

if (startStage === 'S1' && !idea) {
  console.error('ERROR: --idea is required when starting from S1.');
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Workspace Config
// ---------------------------------------------------------------------------

const workspaceConfigPath = join(workspaceRoot, 'forge-workspace.json');
if (!existsSync(workspaceConfigPath)) {
  console.error(`ERROR: forge-workspace.json not found at ${workspaceConfigPath}`);
  console.error('Run forge-init to create the workspace configuration.');
  process.exit(1);
}

const workspaceConfig = JSON.parse(readFileSync(workspaceConfigPath, 'utf8'));
const fm = workspaceConfig.folderMap;
const outputsRoot = resolve(workspaceRoot, workspaceConfig.outputsRoot || '../forge-outputs');

// Resolve folder paths — outputs/ 접두사는 outputsRoot 기준, 그 외는 workspaceRoot 기준
function resolveFm(key) {
  const path = fm[key];
  if (path.startsWith('outputs/')) {
    return join(outputsRoot, path.slice('outputs/'.length));
  }
  return join(workspaceRoot, path);
}

// Track type (dev or content)
const isDevTrack = ['app', 'web', 'game'].includes(projectType);
const docTypeLabel = projectType === 'game' ? 'GDD' : (isDevTrack ? 'PRD' : 'Content Plan');

// ---------------------------------------------------------------------------
// Gate Log
// ---------------------------------------------------------------------------

const projectProductDir = join(resolveFm('product'), projectName);
const gateLogPath = join(projectProductDir, 'gate-log.md');

function ensureProjectDirs() {
  const dirs = [
    join(resolveFm('research'), projectName),
    join(resolveFm('product'), projectName),
    join(resolveFm('design'), projectName),
    join(resolveFm('content'), projectName),
  ];
  for (const d of dirs) {
    if (!existsSync(d)) mkdirSync(d, { recursive: true });
  }
}

function initGateLog() {
  if (!existsSync(gateLogPath)) {
    const content = `## Gate Log — ${projectName}

| Stage | Result | Date | Conditions | Notes |
|:-----:|:------:|------|------------|-------|
| S1 | — | — | — | |
| S2 | — | — | — | |
| S3 | — | — | — | |
| S4 | — | — | — | |
`;
    writeFileSync(gateLogPath, content);
  }
}

function updateGateLog(stage, result, conditions, notes) {
  if (!existsSync(gateLogPath)) initGateLog();
  let content = readFileSync(gateLogPath, 'utf8');
  const date = new Date().toISOString().split('T')[0];
  const emoji = result === 'PASS' ? 'PASS' : result;
  const pattern = new RegExp(`\\| ${stage} \\|[^|]*\\|[^|]*\\|[^|]*\\|[^|]*\\|`);
  content = content.replace(pattern, `| ${stage} | ${emoji} | ${date} | ${conditions} | ${notes} |`);
  writeFileSync(gateLogPath, content);
}

// ---------------------------------------------------------------------------
// Helper: Verify Output Files
// ---------------------------------------------------------------------------

function verifyOutputs(expectedFiles, stage) {
  const missing = [];
  for (const relPath of expectedFiles) {
    const absPath = join(workspaceRoot, relPath);
    if (!existsSync(absPath)) missing.push(relPath);
  }
  if (missing.length > 0) {
    console.error(`\n[${stage}] WARNING: ${missing.length} expected output(s) not found:`);
    for (const f of missing) console.error(`  - ${f}`);
    return false;
  }
  console.log(`[${stage}] All ${expectedFiles.length} expected outputs verified.`);
  return true;
}

// ---------------------------------------------------------------------------
// Helper: Run Agent
// ---------------------------------------------------------------------------

async function runAgent({ prompt, model = 'claude-sonnet-4-6', tools, maxTurns = 20, budgetUsd = 1.0, permissionMode = 'acceptEdits', outputSchema = null }) {
  let resultText = '';

  const options = {
    cwd: workspaceRoot,
    model,
    allowedTools: tools,
    maxTurns,
    maxBudgetUsd: budgetUsd,
    permissionMode,
    settingSources: ["project"],
  };

  // P2-d: Opus 모델에 adaptive thinking 자동 적용
  if (model.includes('opus')) {
    options.thinking = { type: "adaptive" };
  }

  // P2-c: 구조화된 출력 (옵션)
  if (outputSchema) {
    options.outputFormat = {
      type: "json_schema",
      schema: outputSchema,
    };
  }

  try {
    for await (const message of query({
      prompt,
      options,
    })) {
      if ('result' in message) {
        resultText = message.result;
      }
    }
  } catch (err) {
    const msg = err.message || String(err);
    if (msg.includes('budget') || msg.includes('Budget')) {
      console.error(`[Budget Exceeded] Agent exceeded $${budgetUsd} budget. Model: ${model}`);
      console.error('Consider increasing --budget or simplifying the task.');
    }
    throw err; // Re-throw so stage-level catch handles gate-log
  }

  return resultText;
}

// ---------------------------------------------------------------------------
// S1: Research (Fan-out parallel)
// ---------------------------------------------------------------------------

async function stageS1() {
  console.log('\n=== S1: Research ===\n');

  const researchDir = join(resolveFm('research'), projectName);
  const datePrefix = new Date().toISOString().split('T')[0];

  // Fan-out: 3 research agents in parallel (Promise.allSettled for partial recovery)
  const s1Results = await Promise.allSettled([
    // Market Research (Haiku — fast search)
    runAgent({
      prompt: `You are a market research agent.

Project: ${projectName}
Type: ${projectType}
Idea: ${idea}

## Task
Conduct market research for this project idea.

## Steps
1. Search for market size (TAM/SAM/SOM) data
2. Identify target audience demographics
3. Find market trends and growth projections
4. Identify existing solutions and market gaps

## Output
Write a market research report to ${fm.research}/${projectName}/${datePrefix}-s1-market-research.md

Include:
- Market size estimates with sources
- Target audience analysis
- Market trends (3-5 key trends)
- Competitive landscape overview
- Confidence level for each data point: [High|Medium|Low]`,
      model: 'claude-haiku-4-5',
      tools: ['Read', 'Write', 'Glob', 'WebSearch', 'WebFetch'],
      maxTurns: 15,
      budgetUsd: totalBudget * 0.05,
    }),

    // Academic/Technical Research (Haiku — fast search)
    runAgent({
      prompt: `You are an academic/technical research agent.

Project: ${projectName}
Type: ${projectType}
Idea: ${idea}

## Task
Research technical feasibility and academic insights for this project.

## Steps
1. Search for relevant technical approaches
2. Find similar implementations or case studies
3. Identify key technical challenges
4. Research applicable technologies and frameworks

## Output
Write a technical research report to ${fm.research}/${projectName}/${datePrefix}-s1-technical-research.md

Include:
- Technical feasibility assessment
- Recommended technology stack
- Key technical risks
- Relevant case studies or references
- Confidence level for each claim: [High|Medium|Low]`,
      model: 'claude-haiku-4-5',
      tools: ['Read', 'Write', 'Glob', 'WebSearch', 'WebFetch'],
      maxTurns: 15,
      budgetUsd: totalBudget * 0.05,
    }),

    // Competitor Analysis (Haiku — fast search)
    runAgent({
      prompt: `You are a competitive intelligence agent.

Project: ${projectName}
Type: ${projectType}
Idea: ${idea}

## Task
Analyze competitors and alternative solutions.

## Steps
1. Identify top 5-10 competitors or alternatives
2. Analyze their features, pricing, and positioning
3. Find their strengths and weaknesses
4. Identify differentiation opportunities

## Output
Write a competitor analysis to ${fm.research}/${projectName}/${datePrefix}-s1-competitor-analysis.md

Include:
- Competitor comparison table
- Feature gap analysis
- Pricing comparison
- Differentiation opportunities
- Confidence level for each finding: [High|Medium|Low]`,
      model: 'claude-haiku-4-5',
      tools: ['Read', 'Write', 'Glob', 'WebSearch', 'WebFetch'],
      maxTurns: 15,
      budgetUsd: totalBudget * 0.05,
    }),
  ]);
  const s1Settled = s1Results.map((r, i) => {
    if (r.status === 'fulfilled') return r.value;
    console.warn(`WARN: S1 agent ${i} failed: ${r.reason?.message || r.reason}`);
    return null;
  });
  const [marketResult, academicResult, competitorResult] = s1Settled;
  const s1SuccessCount = s1Settled.filter(Boolean).length;
  if (s1SuccessCount === 0) throw new Error('All S1 research agents failed');
  console.log(`S1: ${s1SuccessCount}/3 agents succeeded`);

  // Synthesis (Sonnet — judgment)
  console.log('Synthesizing research results...');
  const synthesis = await runAgent({
    prompt: `You are a research coordinator synthesizing S1 research.

Project: ${projectName}
Research directory: ${fm.research}/${projectName}/

## Task
Read all S1 research reports and create a synthesis document.

## Steps
1. Read all files in ${fm.research}/${projectName}/ that match *s1-*.md
2. Cross-reference findings for consistency
3. Flag conflicting data points
4. Create a unified research summary

## Output
Write synthesis to ${fm.research}/${projectName}/${datePrefix}-s1-research-synthesis.md

Include:
- Executive summary (1 paragraph)
- Key findings (top 5)
- Market opportunity assessment
- Technical feasibility rating (1-10)
- Risk factors (top 3)
- Recommendation: proceed / pivot / stop`,
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Write', 'Glob', 'Grep'],
    maxTurns: 10,
    budgetUsd: totalBudget * 0.05,
  });

  // Verify S1 outputs
  const s1Expected = [
    `${fm.research}/${projectName}/${datePrefix}-s1-market-research.md`,
    `${fm.research}/${projectName}/${datePrefix}-s1-technical-research.md`,
    `${fm.research}/${projectName}/${datePrefix}-s1-competitor-analysis.md`,
    `${fm.research}/${projectName}/${datePrefix}-s1-research-synthesis.md`,
  ];
  const s1Complete = verifyOutputs(s1Expected, 'S1');

  updateGateLog('S1', s1Complete ? 'PASS' : 'WARN', 'DoD checklist', s1Complete ? 'Research complete' : 'Some outputs missing');
  console.log('\n[STOP] S1 Research complete. Review before proceeding to S2.');
  return synthesis;
}

// ---------------------------------------------------------------------------
// S2: Concept (Lean Canvas + Go/No-Go)
// ---------------------------------------------------------------------------

async function stageS2() {
  console.log('\n=== S2: Concept ===\n');

  const datePrefix = new Date().toISOString().split('T')[0];

  // Phase 1: Write concept document
  await runAgent({
    prompt: `You are a concept strategist running Forge S2.

Project: ${projectName}
Type: ${projectType}
Research dir: ${fm.research}/${projectName}/

## Task
Develop the concept and run Go/No-Go scoring.

## Steps
1. Read all S1 research synthesis from ${fm.research}/${projectName}/
2. Create a Lean Canvas document
3. Define OKRs (Objectives & Key Results)
4. Run Go/No-Go scoring:
   - Market Opportunity (30%): TAM/SAM/SOM, growth, timing
   - Technical Feasibility (25%): tech stack, resources
   - Business Model (25%): monetization, unit economics
   - Risk Management (20%): regulatory, competition, tech risk
5. Check Kill Criteria:
   - TAM < $1M
   - Competitor 70%+ market share
   - Core tech impossible
   - Regulatory barrier

## Output
Write concept document to ${fm.product}/${projectName}/${datePrefix}-s2-concept.md

Include:
- Lean Canvas (9 blocks)
- OKRs (2-3 objectives, 3-4 KRs each)
- Go/No-Go scorecard with weighted scores
- Kill Criteria check results
- Final verdict: Go (80+) / Conditional (60-79) / No-Go (<60)`,
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Write', 'Glob', 'Grep', 'WebSearch'],
    maxTurns: 20,
    budgetUsd: totalBudget * 0.08,
  });

  // Phase 2: Extract structured Go/No-Go score
  const scoreResult = await runAgent({
    prompt: `Read the S2 concept document at ${fm.product}/${projectName}/${datePrefix}-s2-concept.md and extract the Go/No-Go scoring result.

Return ONLY the JSON result — no other text.`,
    model: 'claude-haiku-4-5',
    tools: ['Read', 'Glob'],
    maxTurns: 5,
    budgetUsd: totalBudget * 0.01,
    outputSchema: {
      type: "object",
      properties: {
        score: { type: "integer", description: "Go/No-Go total score (0-100)" },
        verdict: { type: "string", enum: ["Go", "Conditional", "No-Go"] },
        killCriteriaTriggered: { type: "array", items: { type: "string" }, description: "List of triggered kill criteria, empty if none" },
      },
      required: ["score", "verdict", "killCriteriaTriggered"],
      additionalProperties: false,
    },
  });

  // Verify S2 output
  const datePrefix2 = new Date().toISOString().split('T')[0];
  verifyOutputs([`${fm.product}/${projectName}/${datePrefix2}-s2-concept.md`], 'S2');

  // Parse structured score
  let score = null;
  let verdict = null;
  try {
    const parsed = JSON.parse(scoreResult);
    score = parsed.score;
    verdict = parsed.verdict;
    if (parsed.killCriteriaTriggered?.length > 0) {
      console.log(`[S2] Kill Criteria triggered: ${parsed.killCriteriaTriggered.join(', ')}`);
    }
  } catch {
    // Fallback: regex parsing
    const scoreMatch = scoreResult.match(/(?:score|Score)[^\d]*(\d{1,3})/i);
    score = scoreMatch ? parseInt(scoreMatch[1], 10) : null;
  }

  if (score !== null && score < 60) {
    updateGateLog('S2', 'NO-GO', `Score: ${score}/100`, 'Below threshold — project stopped');
    console.error(`\n[STOP] S2 No-Go — Score ${score}/100 (threshold: 60). Project halted.`);
    process.exit(0);
  } else if (score !== null && score < 80) {
    updateGateLog('S2', 'CONDITIONAL', `Score: ${score}/100`, 'Needs improvement before S3');
    console.log(`\n[STOP] S2 Conditional — Score ${score}/100. Review and improve before S3.`);
  } else {
    const label = score !== null ? `Score: ${score}/100` : 'Go/No-Go scored (score not parsed)';
    updateGateLog('S2', 'PASS', label, 'Concept confirmed');
    console.log(`\n[STOP] S2 Concept complete. ${label}`);
  }

  return scoreResult;
}

// ---------------------------------------------------------------------------
// S3: Design Document (Competing Hypotheses)
// ---------------------------------------------------------------------------

async function stageS3() {
  console.log('\n=== S3: Design Document ===\n');

  const datePrefix = new Date().toISOString().split('T')[0];

  // Competing Hypotheses: 3 agents write independent drafts in parallel
  console.log('Running Competing Hypotheses (3 independent drafts)...');

  const draftAgents = [
    {
      id: 'A', label: 'Product & UX',
      focus: `- User journey and experience flows
- Feature prioritization by user impact
- UI/UX design principles and interaction patterns
- Onboarding and retention hooks`,
    },
    {
      id: 'B', label: 'Technical Architecture',
      focus: `- System architecture and data flow
- API design and integration points
- Performance and scalability considerations
- Security and compliance requirements
- Data model design and relationships
- Analytics events and tracking plan`,
    },
    {
      id: 'C', label: 'Business & Growth',
      focus: `- Monetization strategy and pricing model
- Go-to-market positioning
- Competitive differentiation and moat
- Growth loops and viral mechanics
- Risk identification and mitigation strategies
- Regulatory and compliance considerations`,
    },
  ];

  const budgetPerDraft = totalBudget * 0.05; // 5% each = 25% total for drafts

  const draftResults = await Promise.allSettled(
    draftAgents.map(agent =>
      runAgent({
        prompt: `You are Agent ${agent.id} — a ${agent.label}-focused ${docTypeLabel} writer.

Project: ${projectName}
Type: ${projectType}
Concept: ${fm.product}/${projectName}/

## Task
Write Draft ${agent.id} of the ${docTypeLabel}, focusing on your specialized perspective.

## Steps
1. Read the S2 concept document from ${fm.product}/${projectName}/
2. Read S1 research from ${fm.research}/${projectName}/
3. Write a complete ${docTypeLabel} draft from your unique angle

## Your Perspective (${agent.label})
${agent.focus}

## Output
Write to ${fm.product}/${projectName}/${datePrefix}-s3-draft-${agent.id.toLowerCase()}.md

Follow ${docTypeLabel} standard structure:
1. Executive Summary
2. Problem Statement / Game Concept
3. Target Users / Players
4. Feature Specifications
5. User Stories / Game Mechanics
6. Technical Requirements
7. Success Metrics
8. Risks & Mitigations

Make your draft distinctive — emphasize your perspective. The judge will select the best elements from all 3 drafts.`,
        model: 'claude-sonnet-4-6',
        tools: ['Read', 'Write', 'Glob', 'Grep'],
        maxTurns: 25,
        budgetUsd: budgetPerDraft,
      })
    )
  );
  const drafts = draftResults.map((r, i) => {
    if (r.status === 'fulfilled') return r.value;
    console.warn(`WARN: S3 draft agent ${draftAgents[i].id} failed: ${r.reason?.message || r.reason}`);
    return null;
  });
  const successDrafts = drafts.filter(Boolean);
  if (successDrafts.length < 2) throw new Error(`S3: only ${successDrafts.length} drafts succeeded (min 2 required)`);
  console.log(`S3: ${successDrafts.length}/${draftAgents.length} drafts succeeded`);

  // Merge: Opus judges and combines best of 3 drafts
  console.log('Merging 3 drafts with Opus judge...');
  const draftList = draftAgents
    .map(a => `- Draft ${a.id} (${a.label}): ${fm.product}/${projectName}/${datePrefix}-s3-draft-${a.id.toLowerCase()}.md`)
    .join('\n');

  const finalDoc = await runAgent({
    prompt: `You are the ${docTypeLabel} judge and merger. You have 3 competing drafts to evaluate.

Project: ${projectName}

## Drafts
${draftList}

## Task
Compare all 3 drafts and create the definitive ${docTypeLabel}.

## Steps
1. Read all 3 drafts
2. Create a comparison matrix: for each draft, list its unique strengths and weaknesses
3. Rank the drafts by overall quality
4. Merge the best elements from all drafts into the final document
5. Ensure completeness — no perspective gap remains

## Output
1. Write agent meeting notes (comparison matrix + ranking + selection rationale) to:
   ${fm.product}/${projectName}/${datePrefix}-s3-agent-meeting-notes.md
2. Write the final ${docTypeLabel} to:
   ${fm.product}/${projectName}/${datePrefix}-s3-${projectType === 'game' ? 'gdd' : 'prd'}.md

The final document must be comprehensive, production-ready, and stronger than any single draft.`,
    model: 'claude-opus-4-6',
    tools: ['Read', 'Write', 'Glob', 'Grep'],
    maxTurns: 25,
    budgetUsd: totalBudget * 0.10,
  });

  // Verify S3 outputs
  const docSuffix = projectType === 'game' ? 'gdd' : 'prd';
  const s3Expected = [
    `${fm.product}/${projectName}/${datePrefix}-s3-agent-meeting-notes.md`,
    `${fm.product}/${projectName}/${datePrefix}-s3-${docSuffix}.md`,
  ];
  verifyOutputs(s3Expected, 'S3');

  // PPT generation (dev track only)
  const pptxPath = `${fm.product}/${projectName}/${datePrefix}-s3-${docSuffix}.pptx`;
  let pptxExists = false;

  if (isDevTrack) {
    console.log('Generating PPTX presentation...');
    const prdPath = `${fm.product}/${projectName}/${datePrefix}-s3-${docSuffix}.md`;

    try {
      await runAgent({
        prompt: `You are a presentation designer creating a PPTX from a ${docTypeLabel}.

Project: ${projectName}
Source: ${prdPath}

## Task
Read the ${docTypeLabel} document and create a professional .pptx presentation.

## Steps
1. Read the ${docTypeLabel} at ${prdPath}
2. Create a PptxGenJS script that generates a .pptx file
3. The script should be saved as a temporary file and executed with Node.js
4. Save the generated .pptx to ${fm.product}/${projectName}/${datePrefix}-s3-${docSuffix}.pptx

## Slide Structure (McKinsey Pyramid + Duarte Narrative)
- Slide 1-2: Problem/Opportunity (What Is)
- Slide 3-N: Solution + Evidence (What Could Be)
- Final: Action Plan / Call to Action

## Requirements
- Use PptxGenJS (install if needed: npm install pptxgenjs)
- Include visual elements: charts, diagrams, tables (not text-only slides)
- Use professional color scheme
- Each slide must have at least one visual element
- Maximum 15-20 slides
- Korean text for content, English for technical terms

## Important
- Write a Node.js script that uses PptxGenJS to generate the .pptx
- Execute the script with Bash tool
- Verify the .pptx file was created`,
        model: 'claude-sonnet-4-6',
        tools: ['Read', 'Write', 'Glob', 'Grep', 'Bash'],
        maxTurns: 30,
        budgetUsd: totalBudget * 0.05,
      });
    } catch (err) {
      console.error(`[S3] PPTX generation failed: ${err.message}`);
      console.error('You can manually generate PPTX later with /pptx skill.');
    }

    pptxExists = existsSync(join(workspaceRoot, pptxPath));
  }

  if (isDevTrack) {
    if (pptxExists) {
      updateGateLog('S3', 'PASS', 'Agent meeting + merge + PPTX', `${docTypeLabel} + PPTX complete`);
      console.log(`\n[STOP] S3 ${docTypeLabel} + PPTX complete.`);
    } else {
      updateGateLog('S3', 'PENDING', 'Agent meeting + merge', `${docTypeLabel} complete — PPTX missing`);
      console.log(`\n[STOP] S3 ${docTypeLabel} complete.`);
      console.log('WARNING: PPTX not generated. Run /pptx skill to create .pptx.');
    }
  } else {
    updateGateLog('S3', 'PASS', 'Agent meeting + merge', `${docTypeLabel} complete`);
    console.log(`\n[STOP] S3 ${docTypeLabel} complete.`);
  }
  return finalDoc;
}

// ---------------------------------------------------------------------------
// S4: Intra-Gate (구조 제시 → Human 승인 대기)
// ---------------------------------------------------------------------------

async function stageS4IntraGate() {
  console.log('\n=== S4: Intra-Gate (구조/접근 방식 제시) ===\n');

  const productDir = `${fm.product}/${projectName}`;

  // Read S3 document to determine admin inclusion
  const s3Info = await runAgent({
    prompt: `You are analyzing an S3 ${docTypeLabel} to prepare the S4 Intra-Gate proposal.

Project: ${projectName}
S3 docs: ${productDir}/

## Task
Read the S3 ${docTypeLabel} and produce a structured S4 approach proposal.

## Steps
1. Read the latest s3-*.md file in ${productDir}/
2. Check if admin/management features are included
3. Produce the proposal below

## Output Format (print to stdout, do NOT write a file)
Produce EXACTLY this structure:

### S4 기획 패키지 — 접근 방식 제안

**프로젝트**: ${projectName}
**관리자 포함**: [Yes/No]

#### 3종 산출물 작성 순서 + 상호 의존성
1. 상세 기획서 (사이트맵 포함) ← S3 ${docTypeLabel} 직접 참조
2. 개발 계획 (로드맵+WBS+테스트전략+Forge Dev 세션 로드맵 포함) ← 상세 기획서
3. UI/UX 기획서 ← 상세 기획서

#### 관리자 산출물 (해당 시)
[관리자 포함 시 별도 산출물 목록]

#### 각 산출물별 참조할 S3 입력 문서
[산출물 → S3 섹션 매핑]

#### Wave Protocol 실행 계획
- Wave 1: technical-writer → 3종 초안 (순차)
- Wave 2: spec-verifier → S3 요구사항 커버리지 검증
- Wave 3: cto-advisor + ux-researcher → 병렬 리뷰
- Wave 4: technical-writer → 리뷰 반영 최종본

#### 예산 배분
- Wave 1: ${(totalBudget * 0.15).toFixed(2)} USD
- Wave 2: ${(totalBudget * 0.05).toFixed(2)} USD
- Wave 3: ${(totalBudget * 0.10).toFixed(2)} USD
- Wave 4: ${(totalBudget * 0.05).toFixed(2)} USD
- Todo Tracker: ${(totalBudget * 0.02).toFixed(2)} USD`,
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Glob', 'Grep'],
    maxTurns: 10,
    budgetUsd: totalBudget * 0.02,
    permissionMode: 'plan',
  });

  console.log('\n' + s3Info);
  console.log('\n=== [INTRA-GATE] S4 접근 방식 제시 완료 ===');
  console.log('위 구조를 검토한 후, 승인하면 아래 명령으로 실행하세요:');
  console.log(`  node ~/.claude/scripts/forge-runner.mjs --project ${projectName} --type ${projectType} --start S4-exec --budget ${totalBudget}`);
  console.log('\n수정이 필요하면 S3 기획서를 업데이트한 후 다시 S4를 실행하세요.');
}

// ---------------------------------------------------------------------------
// S4-exec: Planning Package (Wave Protocol 실행)
// ---------------------------------------------------------------------------

async function stageS4Exec() {
  console.log('\n=== S4: Planning Package — Wave Protocol 실행 ===\n');

  const datePrefix = new Date().toISOString().split('T')[0];
  const productDir = `${fm.product}/${projectName}`;
  const designDir = `${fm.design}/${projectName}`;

  // Wave 1: Initial drafts (sequential — technical-writer)
  console.log('Wave 1: Initial drafts...');
  await runAgent({
    prompt: `You are a technical writer creating S4 planning package (Wave 1).

Project: ${projectName}
Type: ${projectType}
S3 docs: ${productDir}/

## Task
Create all 7 required S4 deliverables as initial drafts.

## Steps
1. Read the S3 ${docTypeLabel} from ${productDir}/ (latest s3-*.md)
2. Read S1 research and S2 concept for reference
3. Create these 7 documents:

### Required Deliverables
1. ${productDir}/${datePrefix}-s4-detailed-plan.md — Detailed spec per screen/feature (includes sitemap)
2. ${productDir}/${datePrefix}-s4-development-plan.md — Tech stack, architecture, Forge Dev session roadmap, roadmap, WBS, test strategy
3. ${designDir}/${datePrefix}-s4-uiux-spec.md — Wireframes, components, interactions

## Important
- Include Forge Dev session roadmap in development plan (sessions mapped to specs)
- If S3 includes admin features, create admin variants too
- Use RICE/ICE scoring for prioritization in roadmap`,
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Write', 'Glob', 'Grep'],
    maxTurns: 40,
    budgetUsd: totalBudget * 0.15,
  });

  // Wave 2: Spec verification (coverage check)
  console.log('Wave 2: Spec verification...');
  await runAgent({
    prompt: `You are a spec verifier for S4 Wave 2.

Project: ${projectName}
S3 docs: ${productDir}/
S4 docs: ${productDir}/ and ${designDir}/

## Task
Verify that all S3 requirements are covered in S4 deliverables.

## Steps
1. Read the S3 ${docTypeLabel} and extract all functional/non-functional requirements
2. Read each S4 document (7 files)
3. Create a coverage checklist: for each requirement, which S4 doc covers it
4. Identify gaps — requirements mentioned in S3 but missing from S4
5. If gaps found, append them to the relevant S4 documents

## Output
Write verification report to ${productDir}/${datePrefix}-s4-wave2-verification.md`,
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Write', 'Edit', 'Glob', 'Grep'],
    maxTurns: 20,
    budgetUsd: totalBudget * 0.05,
  });

  // Wave 3: Expert reviews (parallel — CTO + UX, Promise.allSettled for partial recovery)
  console.log('Wave 3: Expert reviews (parallel)...');
  const w3Results = await Promise.allSettled([
    // CTO Advisor review
    runAgent({
      prompt: `You are a CTO advisor reviewing S4 technical documents.

Project: ${projectName}
S4 docs: ${productDir}/

## Task
Review the development plan, architecture, and WBS for technical soundness.

## Review Focus
1. Architecture decisions (scalability, maintainability)
2. Tech stack choices (appropriate for requirements)
3. Session roadmap feasibility
4. WBS completeness and estimates
5. Test strategy coverage

## Output
Write review to ${productDir}/${datePrefix}-s4-wave3-cto-review.md

For each issue found:
- Severity: Critical / Suggestion
- Location: Which S4 doc and section
- Issue description
- Recommendation`,
      model: 'claude-sonnet-4-6',
      tools: ['Read', 'Write', 'Glob', 'Grep'],
      maxTurns: 15,
      budgetUsd: totalBudget * 0.05,
    }),

    // UX Researcher review
    runAgent({
      prompt: `You are a UX researcher reviewing S4 UI/UX documents.

Project: ${projectName}
S4 UI/UX spec: ${designDir}/

## Task
Review the UI/UX spec for usability and design quality.

## Review Focus
1. Information architecture (sitemap logic)
2. User flow completeness
3. Component spec clarity
4. Accessibility considerations
5. Mobile responsiveness plan
6. Admin page mobile support

## Output
Write review to ${designDir}/${datePrefix}-s4-wave3-ux-review.md

For each issue found:
- Severity: Critical / Suggestion
- Location: Which section
- Issue description
- Recommendation`,
      model: 'claude-sonnet-4-6',
      tools: ['Read', 'Write', 'Glob', 'Grep'],
      maxTurns: 15,
      budgetUsd: totalBudget * 0.05,
    }),
  ]);
  w3Results.forEach((r, i) => {
    if (r.status === 'rejected') {
      console.warn(`WARN: S4 Wave 3 reviewer ${i} failed: ${r.reason?.message || r.reason}`);
    }
  });
  if (w3Results.every(r => r.status === 'rejected')) {
    throw new Error('All S4 Wave 3 reviewers failed');
  }

  // Wave 4: Final revision (apply reviews)
  console.log('Wave 4: Final revision...');
  await runAgent({
    prompt: `You are a technical writer applying Wave 3 reviews to S4 documents.

Project: ${projectName}
S4 docs: ${productDir}/ and ${designDir}/
Reviews: Look for *wave3-*-review.md files

## Task
Apply review feedback to finalize S4 documents.

## Steps
1. Read all Wave 3 review files
2. For each Critical issue, update the relevant S4 document
3. For Suggestions, add a "Noted" comment or apply if straightforward
4. Verify all 7 required documents exist and are complete

## Output
Update the S4 documents in place (Edit tool).
Write a final summary to ${productDir}/${datePrefix}-s4-wave4-final-summary.md`,
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Write', 'Edit', 'Glob', 'Grep'],
    maxTurns: 25,
    budgetUsd: totalBudget * 0.05,
  });

  // Generate Todo Tracker
  console.log('Generating Todo Tracker...');
  await runAgent({
    prompt: `You are generating the Forge Dev Todo Tracker for project ${projectName}.

S4 development plan: ${productDir}/${datePrefix}-s4-development-plan.md

## Task
Create a Todo tracker from the S4 development plan's Forge Dev session roadmap.

## Steps
1. Read the development plan
2. Extract Forge Dev sessions from the roadmap
3. Create todo tracker at ${productDir}/${datePrefix}-todo.md

## Todo Structure
For each Forge Dev session, create a row:
| Status | Session | Spec | SP | Phase |

Status flow: Todo -> Doing -> QA -> Done

Include sections:
- Forge Gate Status (S1-S4 all PASS)
- Forge Dev Sessions (from roadmap)
- Reference Index (links to all S4 docs)`,
    model: 'claude-haiku-4-5',
    tools: ['Read', 'Write', 'Glob'],
    maxTurns: 10,
    budgetUsd: totalBudget * 0.02,
  });

  // Verify S4 outputs exist
  const s4Expected = [
    `${productDir}/${datePrefix}-s4-detailed-plan.md`,
    `${productDir}/${datePrefix}-s4-development-plan.md`,
    `${designDir}/${datePrefix}-s4-uiux-spec.md`,
  ];
  const s4Verified = verifyOutputs(s4Expected, 'S4');

  if (!s4Verified) {
    updateGateLog('S4', 'WARN', '3 deliverables incomplete', 'Missing outputs — review before PASS');
    console.warn('[S4] WARNING: Not all 3 required deliverables were found. Review output.');
  } else {
    updateGateLog('S4', 'PASS', '3 deliverables + Todo', 'Wave Protocol complete');
  }
  console.log('\n[STOP] S4 Planning Package complete.');

  if (isDevTrack) {
    console.log('Next: Run /forge command to generate Handoff document and start development.');
  } else {
    console.log('Next: Proceed to content production.');
  }
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  console.log(`forge-runner.mjs — Project: ${projectName} (${projectType})`);
  console.log(`Workspace: ${workspaceRoot}`);
  console.log(`Start: ${startStage}`);
  console.log(`Budget: $${totalBudget}`);

  if (dryRun) {
    console.log('\n--- DRY RUN ---');
    const stages = [];
    if (startStage === 'S1') stages.push('S1 Research (3 parallel agents + synthesis)');
    if (['S1', 'S2'].includes(startStage)) stages.push('S2 Concept (Lean Canvas + Go/No-Go)');
    if (['S1', 'S2', 'S3'].includes(startStage)) stages.push(`S3 Design Doc (3 competing drafts + merge)`);
    if (startStage !== 'S4-exec') stages.push('S4 Intra-Gate (구조 제시 → Human 승인)');
    stages.push('S4-exec Planning Package (4-wave protocol)');
    stages.forEach(s => console.log(`  - ${s}`));
    console.log(`\nEstimated cost: ~$${(totalBudget * 0.8).toFixed(2)}`);
    process.exit(0);
  }

  ensureProjectDirs();
  initGateLog();

  try {
    switch (startStage) {
      case 'S1': await stageS1(); break;
      case 'S2': await stageS2(); break;
      case 'S3': await stageS3(); break;
      case 'S4': await stageS4IntraGate(); break;
      case 'S4-exec': await stageS4Exec(); break;
    }

    // [STOP] Gate — human must review before next stage
    const stageOrder = ['S1', 'S2', 'S3', 'S4', 'S4-exec'];
    const nextIdx = stageOrder.indexOf(startStage) + 1;
    if (nextIdx < stageOrder.length && startStage !== 'S4-exec') {
      const nextStage = stageOrder[nextIdx];
      console.log(`\n=== [STOP] ${startStage} Gate — Review required ===`);
      console.log(`Gate log: ${gateLogPath}`);
      console.log(`\nTo continue after review:`);
      console.log(`  node ~/.claude/scripts/forge-runner.mjs --project ${projectName} --type ${projectType} --start ${nextStage} --budget ${totalBudget}`);
    } else if (startStage === 'S4-exec') {
      console.log('\n=== Forge Pipeline Complete ===');
      console.log(`Gate log: ${gateLogPath}`);
    }
    process.exit(0);

  } catch (err) {
    console.error(`\nFatal error in ${startStage}: ${err.message}`);
    updateGateLog(startStage, 'ERROR', 'Fatal error', err.message.slice(0, 50));
    process.exit(1);
  }
}

main();
