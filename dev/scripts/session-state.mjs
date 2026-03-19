#!/usr/bin/env node
/**
 * session-state.mjs
 * Multi-Session State Management (Global)
 *
 * Manages multiple concurrent sessions per project. Each session is stored as
 * a named JSON file under <project>/.claude/state/sessions/{name}.json.
 * The internal sessionId (UUID) is the immutable identifier — file rename is safe.
 *
 * Installed at: ~/.claude/scripts/session-state.mjs
 * Sessions at:  <project>/.claude/state/sessions/
 *
 * Usage:
 *   node ~/.claude/scripts/session-state.mjs <command> [args]
 *
 * Commands:
 *   init --name <name> [--work-size <size>]   Create new named session
 *   list                                      List all sessions in project
 *   clean                                     Remove completed sessions
 *   get [field] --session <name>              Read state or specific field
 *   set <field> <value> --session <name>      Update field
 *   checkpoint <phase> --session <name>       Save checkpoint
 *   add-autofix <checkId> <resolved> --session <name>
 *   add-rollback <from> <to> <reason> --session <name>
 *   add-timeout <phase> <reason> --session <name>
 *   add-override <checkId> <decision> --session <name>
 *   status --session <name>                   Print session summary
 *
 * Note: --session is optional when only one session exists (auto-selected).
 *
 * Exit codes:
 *   0 = Success
 *   1 = Error
 */

import { readFileSync, writeFileSync, mkdirSync, existsSync, readdirSync, renameSync, unlinkSync } from 'node:fs';
import { join, dirname, resolve, basename } from 'node:path';
import { randomUUID } from 'node:crypto';
import { createRequire } from 'node:module';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const HISTORY_LIMITS = {
  autoFixHistory:  5,
  rollbackHistory: 3,
  timeoutHistory:  3,
  humanOverrides:  3,
};

const ARCHIVE_KEYS = {
  autoFixHistory:  'autoFixArchive',
  rollbackHistory: 'rollbackArchive',
  timeoutHistory:  'timeoutArchive',
  humanOverrides:  'overrideArchive',
};

const VALID_PHASES = [
  'phase1', 'phase1.5', 'phase2', 'phase3', 'phase4', 'session_complete',
];

const VALID_WORK_SIZES = ['hotfix', 'standard'];

const PROTECTED_FIELDS = [
  'sessionId', 'createdAt', 'sessionName',
  'autoFixArchive', 'rollbackArchive', 'timeoutArchive', 'overrideArchive',
];

// ---------------------------------------------------------------------------
// Path resolution (Global: uses CWD)
// ---------------------------------------------------------------------------

function findProjectRoot() {
  let dir = resolve(process.cwd());
  for (let i = 0; i < 12; i++) {
    if (existsSync(join(dir, '.claude'))) return dir;
    const parent = resolve(dir, '..');
    if (parent === dir) break;
    dir = parent;
  }
  return process.cwd();
}

const PROJECT_ROOT    = findProjectRoot();
const STATE_DIR       = join(PROJECT_ROOT, '.claude', 'state');
const SESSIONS_DIR    = join(STATE_DIR, 'sessions');

// ---------------------------------------------------------------------------
// Atomic write
// ---------------------------------------------------------------------------

function atomicWrite(filePath, data) {
  const dir = dirname(filePath);
  ensureDir(dir);
  const tmpPath = join(dir, `.tmp-${randomUUID()}.json`);
  const payload = JSON.stringify(data, null, 2) + '\n';
  try {
    writeFileSync(tmpPath, payload, 'utf8');
    renameSync(tmpPath, filePath);
  } catch {
    try { unlinkSync(tmpPath); } catch { /* cleanup */ }
    writeFileSync(filePath, payload, 'utf8');
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function ensureDir(dir) {
  if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
}

function die(msg, code = 1) {
  console.error(`[session-state] ERROR: ${msg}`);
  process.exit(code);
}

function out(data) {
  console.log(typeof data === 'string' ? data : JSON.stringify(data, null, 2));
}

// ---------------------------------------------------------------------------
// Session file management
// ---------------------------------------------------------------------------

function sessionFilePath(name) {
  return join(SESSIONS_DIR, `${name}.json`);
}

function listSessionFiles() {
  if (!existsSync(SESSIONS_DIR)) return [];
  return readdirSync(SESSIONS_DIR)
    .filter(f => f.endsWith('.json') && !f.startsWith('.tmp-'))
    .map(f => f.replace(/\.json$/, ''));
}

function readSession(name) {
  const fp = sessionFilePath(name);
  if (!existsSync(fp)) return null;
  try {
    return JSON.parse(readFileSync(fp, 'utf8'));
  } catch (err) {
    die(`Failed to parse session "${name}": ${err.message}`);
  }
}

function writeSession(name, state) {
  state.updatedAt = new Date().toISOString();
  state.sessionName = name;
  atomicWrite(sessionFilePath(name), state);
}

/**
 * Resolve which session to use:
 * 1. --session flag → use that
 * 2. Only 1 session exists → auto-select
 * 3. 0 or 2+ sessions → error with guidance
 */
function resolveSession(args) {
  const name = args.session || args.s;
  if (name) {
    const state = readSession(name);
    if (!state) die(`Session "${name}" not found. Run \`list\` to see available sessions.`);
    return { name, state };
  }
  const sessions = listSessionFiles();
  if (sessions.length === 0) die('No sessions found. Run `init --name <name>` first.');
  if (sessions.length === 1) {
    const n = sessions[0];
    const state = readSession(n);
    return { name: n, state };
  }
  // Multiple sessions — must specify
  const summaries = sessions.map(n => {
    try {
      const s = JSON.parse(readFileSync(sessionFilePath(n), 'utf8'));
      return `  - ${n} (${s.currentPhase}, ${s.workSize})`;
    } catch { return `  - ${n} (unreadable)`; }
  });
  die(`Multiple sessions found. Use --session <name>:\n${summaries.join('\n')}`);
}

// ---------------------------------------------------------------------------
// Default state factory
// ---------------------------------------------------------------------------

function createDefaultState(name, workSize = 'standard') {
  const now = new Date().toISOString();
  return {
    sessionId:        randomUUID(),
    sessionName:      name,
    createdAt:        now,
    updatedAt:        now,
    currentPhase:     'phase1',
    workSize,
    specPath:         null,
    checkpoints:      [],
    qaHistory:        [],
    check3CycleCount: 0,
    phaseStartTime:   now,
    autoFixHistory:   [],
    autoFixArchive:   [],
    rollbackHistory:  [],
    rollbackArchive:  [],
    timeoutHistory:   [],
    timeoutArchive:   [],
    humanOverrides:   [],
    overrideArchive:  [],
    checkResults:     {},
  };
}

// ---------------------------------------------------------------------------
// Auto-cleanup on init
// ---------------------------------------------------------------------------

/**
 * Remove completed sessions (currentPhase === 'session_complete').
 * Called at init time so stale sessions don't accumulate.
 */
function autoCleanCompleted() {
  const names = listSessionFiles();
  const removed = [];
  for (const n of names) {
    try {
      const s = JSON.parse(readFileSync(sessionFilePath(n), 'utf8'));
      if (s.currentPhase === 'session_complete') {
        unlinkSync(sessionFilePath(n));
        removed.push(n);
      }
    } catch { /* skip unreadable */ }
  }
  if (removed.length > 0) {
    console.error(`[session-state] Auto-cleaned ${removed.length} completed session(s): ${removed.join(', ')}`);
  }
}

// ---------------------------------------------------------------------------
// History rotation
// ---------------------------------------------------------------------------

function appendHistory(state, historyKey, entry) {
  const limit      = HISTORY_LIMITS[historyKey];
  const archiveKey = ARCHIVE_KEYS[historyKey];
  if (!Array.isArray(state[historyKey]))  state[historyKey]  = [];
  if (!Array.isArray(state[archiveKey]))  state[archiveKey]  = [];
  state[historyKey].push(entry);
  if (state[historyKey].length > limit) {
    const overflow = state[historyKey].splice(0, state[historyKey].length - limit);
    state[archiveKey].push(...overflow.map(o => ({
      check: o.check ?? o.phase ?? o.from,
      resolved: o.resolved ?? o.decision ?? o.reason ?? null,
      timestamp: o.timestamp,
    })));
  }
}

// ---------------------------------------------------------------------------
// Git helper
// ---------------------------------------------------------------------------

const _require = createRequire(import.meta.url);

function getCommitHash() {
  try {
    const { execSync } = _require('child_process');
    return execSync('git rev-parse --short HEAD', {
      cwd: PROJECT_ROOT, stdio: ['pipe', 'pipe', 'pipe'], encoding: 'utf8',
    }).trim();
  } catch { return ''; }
}

// ---------------------------------------------------------------------------
// Arg parsing
// ---------------------------------------------------------------------------

function parseArgs(argv) {
  const args = {};
  const pos  = [];
  for (let i = 0; i < argv.length; i++) {
    const tok = argv[i];
    if (tok.startsWith('--')) {
      const key  = tok.slice(2);
      const next = argv[i + 1];
      if (next !== undefined && !next.startsWith('--')) { args[key] = next; i++; }
      else { args[key] = true; }
    } else { pos.push(tok); }
  }
  return { args, pos };
}

// ---------------------------------------------------------------------------
// Commands
// ---------------------------------------------------------------------------

function cmdInit({ args }) {
  autoCleanCompleted();
  const name = args.name || args.n;
  if (!name) die('Usage: init --name <session-name> [--work-size <size>]');
  if (!/^[a-zA-Z0-9_-]+$/.test(name)) die('Session name must be alphanumeric, hyphens, or underscores.');
  const workSize = args.workSize || args['work-size'] || 'standard';
  if (!VALID_WORK_SIZES.includes(workSize)) {
    die(`Invalid workSize "${workSize}". Valid: ${VALID_WORK_SIZES.join(', ')}`);
  }
  const existing = readSession(name);
  if (existing) {
    console.error(`[session-state] Resuming session: ${name} (${existing.sessionId})`);
    out({ action: 'resumed', session: name, sessionId: existing.sessionId, currentPhase: existing.currentPhase, workSize: existing.workSize });
    return;
  }
  ensureDir(SESSIONS_DIR);
  const state = createDefaultState(name, workSize);
  writeSession(name, state);
  console.error(`[session-state] Initialized: ${name} (${workSize})`);
  out({ action: 'initialized', session: name, sessionId: state.sessionId, workSize });
}

function cmdList() {
  const names = listSessionFiles();
  if (names.length === 0) {
    out({ count: 0, sessions: [] });
    return;
  }
  const sessions = names.map(n => {
    try {
      const s = JSON.parse(readFileSync(sessionFilePath(n), 'utf8'));
      const elapsed = s.phaseStartTime
        ? Math.round((Date.now() - new Date(s.phaseStartTime).getTime()) / 1000)
        : null;
      return {
        name: n,
        sessionId:    s.sessionId,
        workSize:     s.workSize,
        currentPhase: s.currentPhase,
        phaseElapsed: elapsed,
        checkpoints:  s.checkpoints?.length ?? 0,
        cycles:       s.check3CycleCount ?? 0,
        updatedAt:    s.updatedAt,
      };
    } catch (err) {
      return { name: n, error: err.message };
    }
  });
  out({ count: sessions.length, sessions });
}

function cmdClean() {
  const names = listSessionFiles();
  const removed = [];
  for (const n of names) {
    try {
      const s = JSON.parse(readFileSync(sessionFilePath(n), 'utf8'));
      if (s.currentPhase === 'session_complete') {
        unlinkSync(sessionFilePath(n));
        removed.push(n);
      }
    } catch { /* skip unreadable */ }
  }
  console.error(`[session-state] Cleaned ${removed.length} completed session(s).`);
  out({ action: 'cleaned', removed, remainingCount: names.length - removed.length });
}

function cmdGet({ args, pos }) {
  const { name, state } = resolveSession(args);
  const field = pos[0];
  if (field) {
    if (!(field in state)) die(`Field "${field}" not found in session "${name}".`);
    out(state[field]);
  } else {
    out(state);
  }
}

function cmdSet({ args, pos }) {
  if (pos.length < 2) die('Usage: set <field> <value> --session <name>');
  const [field, rawValue] = pos;
  if (PROTECTED_FIELDS.includes(field)) die(`Field "${field}" is protected.`);
  const { name, state } = resolveSession(args);
  let value;
  try { value = JSON.parse(rawValue); } catch { value = rawValue; }
  state[field] = value;
  writeSession(name, state);
  console.error(`[session-state] [${name}] Set ${field} = ${JSON.stringify(value)}`);
  out({ session: name, field, value });
}

function cmdCheckpoint({ args, pos }) {
  const phase = pos[0];
  if (!phase) die('Usage: checkpoint <phase> --session <name>');
  if (!VALID_PHASES.includes(phase)) die(`Invalid phase "${phase}". Valid: ${VALID_PHASES.join(', ')}`);
  const { name, state } = resolveSession(args);
  const now = new Date().toISOString();
  const checkpoint = { phase, timestamp: now, commitHash: getCommitHash() };
  state.checkpoints.push(checkpoint);
  state.currentPhase   = phase;
  state.phaseStartTime = now;
  writeSession(name, state);
  console.error(`[session-state] [${name}] Checkpoint: ${phase} @ ${checkpoint.commitHash || 'no-git'}`);
  out(checkpoint);
}

const FAILURE_REASONS = [
  'CONTEXT_MISSING',   // 필요한 컨텍스트 정보 부족 (파일 경로, API 스펙 등)
  'DIRECTION_ERROR',   // 수정 방향 오류 (버그 원인 오판)
  'RULE_CONFLICT',     // 규칙 충돌 (forge-performance vs forge-module-dependency 등)
  'DEPENDENCY_ISSUE',  // 의존성 문제 (누락된 import, 순환 의존)
  'SYNTAX_ERROR',      // 문법/타입 에러 (컴파일 실패)
  'EXTERNAL_SYSTEM',   // 외부 시스템 실패 (API, DB, 네트워크)
  'UNKNOWN',           // 분류 불가
];

function cmdAddAutofix({ args, pos }) {
  const checkId  = pos[0];
  const resolved = pos[1];
  if (!checkId) die('Usage: add-autofix <checkId> <resolved> [failureReason] --session <name>');
  const { name, state } = resolveSession(args);
  state.check3CycleCount = (state.check3CycleCount || 0) + 1;
  const rawReason = pos[2];
  const failureReason = rawReason && FAILURE_REASONS.includes(rawReason.toUpperCase())
    ? rawReason.toUpperCase()
    : (rawReason ? 'UNKNOWN' : null);
  const entry = {
    check: checkId,
    resolved: resolved !== undefined ? (String(resolved).toLowerCase() === 'true') : null,
    failureReason,
    timestamp: new Date().toISOString(),
    cycle: state.check3CycleCount,
  };
  appendHistory(state, 'autoFixHistory', entry);
  writeSession(name, state);
  console.error(`[session-state] [${name}] AutoFix: ${checkId}, resolved=${entry.resolved}, reason=${failureReason || 'n/a'}, cycle=${state.check3CycleCount}`);
  out(entry);
}

function cmdAddRollback({ args, pos }) {
  const [from, to, ...reasonParts] = pos;
  if (!from || !to) die('Usage: add-rollback <from> <to> <reason> --session <name>');
  const reason = reasonParts.join(' ');
  const { name, state } = resolveSession(args);
  const entry = { from, to, reason, timestamp: new Date().toISOString() };
  appendHistory(state, 'rollbackHistory', entry);
  writeSession(name, state);
  console.error(`[session-state] [${name}] Rollback: ${from} -> ${to}${reason ? ` (${reason})` : ''}`);
  out(entry);
}

function cmdAddTimeout({ args, pos }) {
  const [phase, ...reasonParts] = pos;
  if (!phase) die('Usage: add-timeout <phase> <reason> --session <name>');
  const reason = reasonParts.join(' ');
  const { name, state } = resolveSession(args);
  const entry = { phase, reason, timestamp: new Date().toISOString() };
  appendHistory(state, 'timeoutHistory', entry);
  writeSession(name, state);
  console.error(`[session-state] [${name}] Timeout: ${phase}${reason ? ` (${reason})` : ''}`);
  out(entry);
}

function cmdAddOverride({ args, pos }) {
  const [checkId, ...decisionParts] = pos;
  if (!checkId) die('Usage: add-override <checkId> <decision> --session <name>');
  const decision = decisionParts.join(' ');
  const { name, state } = resolveSession(args);
  const entry = { check: checkId, decision, timestamp: new Date().toISOString() };
  appendHistory(state, 'humanOverrides', entry);
  writeSession(name, state);
  console.error(`[session-state] [${name}] Override: ${checkId} -> "${decision}"`);
  out(entry);
}

function cmdStatus({ args }) {
  const { name, state } = resolveSession(args);
  const elapsedSecs = state.phaseStartTime
    ? Math.round((Date.now() - new Date(state.phaseStartTime).getTime()) / 1000)
    : null;
  out({
    session:          name,
    sessionId:        state.sessionId,
    workSize:         state.workSize,
    currentPhase:     state.currentPhase,
    phaseElapsedSecs: elapsedSecs,
    checkpointCount:  state.checkpoints.length,
    lastCheckpoint:   state.checkpoints[state.checkpoints.length - 1] ?? null,
    check3CycleCount: state.check3CycleCount,
    autoFixTotal:     (state.autoFixHistory?.length ?? 0) + (state.autoFixArchive?.length ?? 0),
    rollbackTotal:    (state.rollbackHistory?.length ?? 0) + (state.rollbackArchive?.length ?? 0),
    timeoutTotal:     (state.timeoutHistory?.length ?? 0) + (state.timeoutArchive?.length ?? 0),
    overrideTotal:    (state.humanOverrides?.length ?? 0) + (state.overrideArchive?.length ?? 0),
    updatedAt:        state.updatedAt,
  });
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

function main() {
  const argv = process.argv.slice(2);
  if (argv.length === 0) {
    console.error('Usage: node ~/.claude/scripts/session-state.mjs <command> [args]');
    console.error('');
    console.error('Commands:');
    console.error('  init --name <name> [--work-size <size>]   Create new session');
    console.error('  list                                      List all sessions');
    console.error('  clean                                     Remove completed sessions');
    console.error('  status [--session <name>]                 Session summary');
    console.error('  get [field] [--session <name>]            Read state');
    console.error('  set <field> <value> [--session <name>]    Update field');
    console.error('  checkpoint <phase> [--session <name>]     Save checkpoint');
    console.error('  add-autofix, add-rollback, add-timeout, add-override');
    console.error('');
    console.error('Note: --session is optional when only 1 session exists.');
    process.exit(1);
  }
  const command = argv[0];
  const parsed  = parseArgs(argv.slice(1));
  switch (command) {
    case 'init':              return cmdInit(parsed);
    case 'list':              return cmdList();
    case 'clean':             return cmdClean();
    case 'get':               return cmdGet(parsed);
    case 'set':               return cmdSet(parsed);
    case 'checkpoint':        return cmdCheckpoint(parsed);
    case 'add-autofix':       return cmdAddAutofix(parsed);
    case 'add-rollback':      return cmdAddRollback(parsed);
    case 'add-timeout':       return cmdAddTimeout(parsed);
    case 'add-override':      return cmdAddOverride(parsed);
    case 'status':            return cmdStatus(parsed);
    default: die(`Unknown command: "${command}"`);
  }
}

main();
