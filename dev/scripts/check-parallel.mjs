#!/usr/bin/env node
/**
 * check-parallel.mjs v2.0.0
 * Forge Dev Check Parallel Runner — Agent SDK
 *
 * Runs Check 3.5 (Traceability) and 3.7 (Code Quality) in parallel by default.
 * Extended checks (3.6, 3.7P, 3.8) available via --checks option.
 *
 * v2.0.0 Changes:
 *   - Default checks: 3.5, 3.7 only (was all 5)
 *   - Extended checks via --checks flag
 *   - SDK: settingSources for CLAUDE.md rule loading
 *   - Improved error messages with recovery guidance
 *   - Check 3 (verify.sh) is NOT run here — it's handled by forge-orchestrator directly
 *
 * Usage:
 *   node ~/.claude/scripts/check-parallel.mjs --project <path> --spec <spec-name>
 *   node ~/.claude/scripts/check-parallel.mjs --help
 *
 * Options:
 *   --project <path>     Project root directory (required)
 *   --spec <spec-name>   Spec name for traceability check (required)
 *   --checks <list>      Comma-separated checks to run (default: 3.5,3.7)
 *                         Values: 3.5,3.6,3.7,3.7P,3.8
 *   --output <path>      Output JSON report path (default: stdout)
 *   --budget <usd>       Max budget per check in USD (default: 0.50)
 *   --help               Show this help
 *
 * Exit codes:
 *   0 = All checks PASS
 *   1 = Error (invalid args, SDK failure)
 *   2 = One or more checks FAIL/WARN
 */

import { createRequire } from 'node:module';
import { writeFileSync, existsSync } from 'node:fs';
import { resolve, join } from 'node:path';

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
  console.log(`check-parallel.mjs v2.0.0 — Forge Dev Check Parallel Runner (Agent SDK)

Usage:
  node check-parallel.mjs --project <path> --spec <spec-name> [options]

Options:
  --project <path>     Project root directory (required)
  --spec <spec-name>   Spec name (required)
  --checks <list>      Comma-separated: 3.5,3.6,3.7,3.7P,3.8 (default: 3.5,3.7)
  --output <path>      Output JSON path (default: stdout)
  --budget <usd>       Max budget per check in USD (default: 0.50)
  --help               Show this help

Default checks (MVP):
  3.5  Traceability — spec-compliance-checker (spec vs code vs tests)
  3.7  Code Quality — code-reviewer agent (quality, patterns, security)

Extended checks (opt-in via --checks):
  3.6  UI/UX Quality — responsive, a11y, perf (frontend PRs)
  3.7P Performance — N+1 queries, bundle size, caching
  3.8  Security — OWASP Top 10, framework-specific (auth/payment PRs)`);
  process.exit(0);
}

const projectPath = getArg('--project');
const specName = getArg('--spec');
const checksArg = getArg('--checks');
const outputPath = getArg('--output');
const budgetPerCheck = parseFloat(getArg('--budget') || '0.50');

if (!projectPath || !specName) {
  console.error('ERROR: --project and --spec are required.');
  process.exit(1);
}

const projectRoot = resolve(projectPath);
if (!existsSync(projectRoot)) {
  console.error(`ERROR: Project path not found: ${projectRoot}`);
  process.exit(1);
}

// MVP default: 3.5 + 3.7 only
const DEFAULT_CHECKS = ['3.5', '3.7'];
const ALL_CHECKS = ['3.5', '3.6', '3.7', '3.7P', '3.8'];
const checksToRun = checksArg
  ? checksArg.split(',').map(c => c.trim())
  : DEFAULT_CHECKS;

const invalidChecks = checksToRun.filter(c => !ALL_CHECKS.includes(c));
if (invalidChecks.length > 0) {
  console.error(`ERROR: Invalid checks: ${invalidChecks.join(', ')}`);
  console.error(`Valid values: ${ALL_CHECKS.join(', ')}`);
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Check Prompt Builders
// ---------------------------------------------------------------------------

function buildTraceabilityPrompt(spec) {
  return `You are a Spec Compliance Checker (Check 3.5 - Traceability).

Project root: ${projectRoot}
Spec name: ${spec}

## Task
Verify that every functional requirement in the Spec is implemented in code and has corresponding tests.

## Steps
1. Find the spec file: look in .specify/specs/${spec}.md or docs/planning/active/forge/
2. Find traceability matrix if exists: .specify/traceability/${spec}-matrix.json
3. Extract all functional requirements (FR-xxx) from the spec
4. For each requirement:
   - Search for implementation in source code (Grep/Glob)
   - Search for corresponding test (describe/it/test blocks)
5. Check API contracts match (HTTP method, path, request/response)
6. Check data models match (Entity/Interface definitions)

## Output Format
Return ONLY a JSON object (no markdown, no explanation):
{
  "checkId": "check-3.5",
  "status": "PASS|WARN|FAIL",
  "matrixSource": "traceability-json|spec-extracted",
  "requirements": [
    {
      "id": "FR-001",
      "description": "requirement description",
      "priority": "High|Medium|Low",
      "implStatus": "found|missing",
      "implFile": "path/to/file",
      "testStatus": "found|missing",
      "testFile": "path/to/test",
      "testType": "unit|integration|both"
    }
  ],
  "summary": "Total N, Impl N (N%), Tests N (N%), Missing N"
}

Status rules:
- PASS: All High/Medium requirements implemented + tested
- WARN: All implemented but some tests missing
- FAIL: Any High requirement missing implementation`;
}

function buildUIQualityPrompt(spec) {
  return `You are a UI/UX Quality Inspector (Check 3.6).

Project root: ${projectRoot}
Spec name: ${spec}

## Task
Inspect frontend code for UI/UX quality issues across 11 categories.

## Categories to Check
1. Responsive Design: mobile/tablet/desktop breakpoints
2. Accessibility: WCAG 2.1 AA compliance
3. Performance: image optimization, lazy loading
4. Image Optimization: WebP/AVIF, srcset
5. Cross-browser: vendor prefixes, feature detection
6. Typography: font-display, line-height, font-size
7. Animation: prefers-reduced-motion, compositor properties, 60fps
8. Forms: labels, autocomplete, error messages, a11y
9. Focus States: focus-visible, tab order, focus traps
10. Dark Mode: color-scheme, CSS variables, prefers-color-scheme
11. Navigation: skip links, aria-current, breadcrumbs

## Steps
1. Find frontend source files (tsx/jsx/css/scss in src/)
2. For each category, search for compliance patterns
3. Flag violations with file:line references

## Output Format
Return ONLY a JSON object:
{
  "checkId": "check-3.6",
  "status": "PASS|WARN|FAIL",
  "categories": {
    "responsive": { "status": "PASS|WARN|FAIL|SKIP", "issues": [] },
    "accessibility": { "status": "...", "issues": ["file:line - description"] },
    "performance": { "status": "...", "issues": [] },
    "imageOptimization": { "status": "...", "issues": [] },
    "crossBrowser": { "status": "...", "issues": [] },
    "typography": { "status": "...", "issues": [] },
    "animation": { "status": "...", "issues": [] },
    "forms": { "status": "...", "issues": [] },
    "focusStates": { "status": "...", "issues": [] },
    "darkMode": { "status": "...", "issues": [] },
    "navigation": { "status": "...", "issues": [] }
  },
  "summary": "PASS N, WARN N, FAIL N, SKIP N"
}

SKIP a category if no relevant code exists.
FAIL status if any category is FAIL. WARN if any WARN but no FAIL.`;
}

function buildCodeQualityPrompt(spec) {
  return `You are a Code Quality Reviewer (Check 3.7).

Project root: ${projectRoot}
Spec name: ${spec}

## Task
Review code quality of files changed/created for this spec.

## Steps
1. Find changed files: look at recent git diff or walkthrough docs
2. Check each file for:
   - TypeScript strict mode compliance (no any type abuse)
   - Proper error handling (no swallowed errors)
   - No console.log in production code
   - No TODO/FIXME/HACK comments left
   - Proper naming conventions (camelCase vars, PascalCase components)
   - No magic numbers/strings (use constants)
   - Function complexity (< 20 lines preferred)
   - No duplicate code blocks
   - Proper imports (no circular dependencies)
   - Security: no hardcoded secrets, no injection vulnerabilities

## Output Format
Return ONLY a JSON object:
{
  "checkId": "check-3.7",
  "status": "PASS|WARN|FAIL",
  "filesReviewed": 0,
  "issues": [
    {
      "severity": "error|warning|info",
      "file": "path/to/file.ts",
      "line": 42,
      "rule": "no-any|no-console|no-todo|...",
      "message": "description",
      "autoFixable": true
    }
  ],
  "summary": "Reviewed N files, Errors N, Warnings N, Info N"
}

FAIL if any error. WARN if warnings only. PASS if clean.`;
}

function buildPerformancePrompt(spec) {
  return `You are a Performance Reviewer (Check 3.7P).

Project root: ${projectRoot}
Spec name: ${spec}

## Task
Review performance characteristics of the implementation.

## Steps
1. Find source files for this spec
2. Check for:
   - N+1 query patterns (ORM/database)
   - Missing pagination on list endpoints
   - Unbounded array operations in hot paths
   - Missing memoization (React.memo, useMemo, useCallback)
   - Large bundle imports (tree-shakeable?)
   - Missing lazy loading for routes/components
   - Missing index suggestions for database queries
   - Expensive computations in render cycle
   - Missing cache headers / caching strategy
3. Run build command to check bundle size if applicable

## Output Format
Return ONLY a JSON object:
{
  "checkId": "check-3.7P",
  "status": "PASS|WARN|FAIL",
  "bundleSize": { "total": "N KB", "delta": "+N KB" },
  "issues": [
    {
      "severity": "error|warning|info",
      "category": "database|rendering|bundle|caching",
      "file": "path/to/file.ts",
      "line": 42,
      "message": "description",
      "suggestion": "how to fix"
    }
  ],
  "summary": "Errors N, Warnings N, Info N"
}

FAIL if any error. WARN if warnings only.`;
}

function buildSecurityPrompt(spec) {
  return `You are a Security Auditor (Check 3.8).

Project root: ${projectRoot}
Spec name: ${spec}

## Task
Security audit of code changes for this spec.

## OWASP Top 10 + Framework-Specific Checks
1. Injection (SQL, NoSQL, Command, XSS via unsafe HTML rendering)
2. Broken Authentication (JWT validation, session management)
3. Sensitive Data Exposure (hardcoded secrets, logging PII)
4. Broken Access Control (RBAC, route guards, canActivate)
5. Security Misconfiguration (CORS, headers, debug mode)
6. Insecure Dependencies (known CVEs in package.json)
7. CSRF Protection (token validation, SameSite cookies)
8. Server-Side Request Forgery (URL validation)
9. Input Validation (sanitization, schema validation)
10. API Security (rate limiting, input size limits)

## Framework-Specific
- NestJS: Guard implementation, DTO validation, Helmet
- Next.js: Server Actions security, CSP headers, middleware auth
- React: unsafe HTML rendering patterns, user input in URLs

## Output Format
Return ONLY a JSON object:
{
  "checkId": "check-3.8",
  "status": "PASS|WARN|FAIL",
  "findings": [
    {
      "severity": "critical|high|medium|low",
      "category": "injection|auth|exposure|access|config|deps|csrf|ssrf|validation|api",
      "file": "path/to/file.ts",
      "line": 42,
      "description": "what was found",
      "recommendation": "how to fix",
      "cwe": "CWE-XXX"
    }
  ],
  "summary": "Critical N, High N, Medium N, Low N"
}

FAIL if any critical or high finding. WARN if medium only. PASS if low or none.`;
}

// ---------------------------------------------------------------------------
// Check Definitions
// ---------------------------------------------------------------------------

const CHECK_DEFS = {
  '3.5': {
    name: 'Traceability',
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Glob', 'Grep'],
    maxTurns: 15,
    needsBash: false,
    buildPrompt: buildTraceabilityPrompt,
  },
  '3.6': {
    name: 'UI/UX Quality',
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Glob', 'Grep', 'Bash'],
    maxTurns: 20,
    needsBash: true,
    buildPrompt: buildUIQualityPrompt,
  },
  '3.7': {
    name: 'Code Quality',
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Glob', 'Grep', 'Bash'],
    maxTurns: 15,
    needsBash: true,
    buildPrompt: buildCodeQualityPrompt,
  },
  '3.7P': {
    name: 'Performance',
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Glob', 'Grep', 'Bash'],
    maxTurns: 15,
    needsBash: true,
    buildPrompt: buildPerformancePrompt,
  },
  '3.8': {
    name: 'Security',
    model: 'claude-sonnet-4-6',
    tools: ['Read', 'Glob', 'Grep'],
    maxTurns: 15,
    needsBash: false,
    buildPrompt: buildSecurityPrompt,
  },
};

// ---------------------------------------------------------------------------
// Agent Runner
// ---------------------------------------------------------------------------

async function runCheck(checkId) {
  const def = CHECK_DEFS[checkId];
  if (!def) throw new Error(`Unknown check: ${checkId}`);

  const startTime = Date.now();
  console.error(`[${checkId}] ${def.name} — Starting...`);

  let resultText = '';

  try {
    for await (const message of query({
      prompt: def.buildPrompt(specName),
      options: {
        cwd: projectRoot,
        model: def.model,
        allowedTools: def.tools,
        maxTurns: def.maxTurns,
        maxBudgetUsd: budgetPerCheck,
        permissionMode: def.needsBash ? 'acceptEdits' : 'plan',
        settingSources: ['project'],
      },
    })) {
      if ('result' in message) {
        resultText = message.result;
      }
    }
  } catch (err) {
    const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
    const msg = err.message || String(err);
    console.error(`[${checkId}] ${def.name} — ERROR after ${elapsed}s: ${msg}`);

    // Recovery guidance per check type
    const guidance = {
      '3.5': 'Ensure .specify/specs/ contains the spec file. Check spec name spelling.',
      '3.6': 'Ensure frontend source files exist (tsx/jsx/css). This check may SKIP if no frontend.',
      '3.7': 'Ensure git diff shows changed files. This check reviews recent changes.',
      '3.7P': 'Ensure build command works. Check package.json for build script.',
      '3.8': 'Ensure source files are accessible. This check scans for security patterns.',
    };

    return {
      checkId: `check-${checkId}`,
      status: 'ERROR',
      error: msg,
      elapsed: `${elapsed}s`,
      recoveryHint: guidance[checkId] || 'Check agent logs for details.',
    };
  }

  const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);

  // Extract JSON from result — try multiple strategies
  let parsed;
  try {
    // Strategy 1: markdown code block
    const codeBlockMatch = resultText.match(/```(?:json)?\s*([\s\S]*?)```/);
    if (codeBlockMatch) {
      parsed = JSON.parse(codeBlockMatch[1].trim());
    } else {
      // Strategy 2: find first { ... last } in the text
      const firstBrace = resultText.indexOf('{');
      const lastBrace = resultText.lastIndexOf('}');
      if (firstBrace !== -1 && lastBrace > firstBrace) {
        parsed = JSON.parse(resultText.slice(firstBrace, lastBrace + 1));
      } else {
        // Strategy 3: try the entire text
        parsed = JSON.parse(resultText.trim());
      }
    }
  } catch {
    console.error(`[${checkId}] ${def.name} — Failed to parse JSON output`);
    parsed = {
      checkId: `check-${checkId}`,
      status: 'ERROR',
      error: 'Failed to parse agent output as JSON',
      rawOutput: resultText.slice(0, 500),
    };
  }

  parsed.elapsed = `${elapsed}s`;
  console.error(`[${checkId}] ${def.name} — ${parsed.status} (${elapsed}s)`);
  return parsed;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const startTime = Date.now();
  console.error(`\ncheck-parallel.mjs v2.0.0 — Running ${checksToRun.length} checks in parallel`);
  console.error(`Project: ${projectRoot}`);
  console.error(`Spec: ${specName}`);
  console.error(`Checks: ${checksToRun.join(', ')}`);
  console.error(`Budget: $${budgetPerCheck}/check\n`);

  // Run all checks in parallel
  const results = await Promise.allSettled(
    checksToRun.map(checkId => runCheck(checkId))
  );

  // Collect results
  const report = {
    timestamp: new Date().toISOString(),
    project: projectRoot,
    spec: specName,
    checksRun: checksToRun,
    totalElapsed: `${((Date.now() - startTime) / 1000).toFixed(1)}s`,
    checks: {},
    overallStatus: 'PASS',
  };

  for (let i = 0; i < checksToRun.length; i++) {
    const checkId = checksToRun[i];
    const result = results[i];

    if (result.status === 'fulfilled') {
      report.checks[checkId] = result.value;
    } else {
      report.checks[checkId] = {
        checkId: `check-${checkId}`,
        status: 'ERROR',
        error: result.reason?.message || 'Unknown error',
        recoveryHint: 'Check agent logs. Retry with: --checks ' + checkId,
      };
    }
  }

  // Determine overall status
  const statuses = Object.values(report.checks).map(c => c.status);
  if (statuses.includes('FAIL') || statuses.includes('ERROR')) {
    report.overallStatus = 'FAIL';
  } else if (statuses.includes('WARN')) {
    report.overallStatus = 'WARN';
  }

  // Summary
  const statusCounts = {};
  for (const s of statuses) {
    statusCounts[s] = (statusCounts[s] || 0) + 1;
  }
  report.statusSummary = statusCounts;

  const reportJson = JSON.stringify(report, null, 2);

  if (outputPath) {
    writeFileSync(resolve(outputPath), reportJson);
    console.error(`\nReport written to: ${outputPath}`);
  } else {
    console.log(reportJson);
  }

  console.error(`\nOverall: ${report.overallStatus} (${report.totalElapsed})`);

  // Recovery guidance on failure
  if (report.overallStatus === 'FAIL') {
    console.error('\n--- Recovery Guidance ---');
    for (const [checkId, checkResult] of Object.entries(report.checks)) {
      if (checkResult.status === 'FAIL' || checkResult.status === 'ERROR') {
        console.error(`  [${checkId}] ${checkResult.status}: ${checkResult.recoveryHint || checkResult.error || 'See details above'}`);
      }
    }
    console.error(`\nRetry specific check: node check-parallel.mjs --project "${projectRoot}" --spec "${specName}" --checks <id>`);
  }

  // Exit code
  if (report.overallStatus === 'PASS') process.exit(0);
  if (report.overallStatus === 'WARN' || report.overallStatus === 'FAIL') process.exit(2);
  process.exit(1);
}

main().catch(err => {
  console.error(`Fatal error: ${err.message}`);
  console.error('\n--- Recovery Guidance ---');
  console.error('The check runner itself crashed. This is likely an SDK or environment issue.');
  console.error('1. Verify Agent SDK is installed: npm ls -g @anthropic-ai/claude-agent-sdk');
  console.error('2. Verify project path exists and is accessible');
  console.error(`3. Retry: node check-parallel.mjs --project "${projectPath}" --spec "${specName}"`);
  process.exit(1);
});
