#!/usr/bin/env node
/**
 * setup.mjs — Forge Dev Bootstrap Script
 *
 * One-command setup for team members. After cloning the forge repo:
 *
 *   node /home/damools/forge/dev/scripts/setup.mjs
 *
 * This single command does everything:
 *   1. Verify prerequisites (Node.js 18+, ~/.claude/ exists)
 *   2. Install scripts → ~/.claude/scripts/
 *   3. Install global components → ~/.claude/ (rules, agents, skills, commands, prompts)
 *   4. Install dependencies (Agent SDK, Agent Teams, tmux)
 *   5. Detect platform & configure workspaces → manifest.json
 *   6. Auto-discover Claude Code projects in workspaces
 *   7. Run first sync (forge-sync --include-recommended)
 *
 * Flags:
 *   --update          Only update scripts + global-components + deps (skip manifest/discover/sync)
 *   --skip-discover   Skip project auto-discovery (steps 6-7)
 *   --skip-deps       Skip dependency installation (step 4)
 *
 * Non-interactive (CI/script):
 *   node setup.mjs --workspace ~/projects --business ~/biz            # Mac/Linux
 *   node setup.mjs --wsl-path "Z:/path" --win-path "E:/path"          # Windows
 *
 * Cross-platform: Windows (win32 = all Windows incl. 64-bit), macOS (darwin), Linux
 */

import { existsSync, copyFileSync, readFileSync, writeFileSync, mkdirSync, readdirSync, statSync, renameSync } from 'node:fs';
import { join, dirname, basename, resolve } from 'node:path';
import { homedir, platform } from 'node:os';
import { fileURLToPath } from 'node:url';
import { createInterface } from 'node:readline';
import { execFileSync, execSync } from 'node:child_process';

// ---------------------------------------------------------------------------
// Paths
// ---------------------------------------------------------------------------

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const FORGE_DEV_ROOT = dirname(__dirname);
const HOME = homedir();
const CLAUDE_DIR = join(HOME, '.claude');
const SCRIPTS_DIR = join(CLAUDE_DIR, 'scripts');
const RULES_DIR = join(CLAUDE_DIR, 'rules');
const USER_SETTINGS_PATH = join(CLAUDE_DIR, 'settings.json');

const SRC_SCRIPTS = join(FORGE_DEV_ROOT, 'scripts');
const SRC_GLOBAL_RULES = join(FORGE_DEV_ROOT, 'global-rules');
const MANIFEST_EXAMPLE = join(FORGE_DEV_ROOT, 'manifest.example.json');
const MANIFEST_PATH = join(FORGE_DEV_ROOT, 'manifest.json');
const TRINE_SYNC_PATH = join(SCRIPTS_DIR, 'forge-sync.mjs');

// Note: process.platform returns 'win32' for ALL Windows (32-bit and 64-bit alike).
// This is a Node.js/Win32 API naming convention, not an architecture indicator.
const PLATFORM = platform();

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function ensureDir(dir) {
  if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
}

function copyFile(src, dst, label) {
  copyFileSync(src, dst);
  console.log(`  + ${label}`);
}

function skipFile(label, reason) {
  console.log(`  - ${label} (${reason})`);
}

function getArg(args, flag) {
  const idx = args.indexOf(flag);
  return idx !== -1 && idx + 1 < args.length ? args[idx + 1] : null;
}

async function ask(rl, question) {
  return new Promise(resolve => {
    rl.question(question, answer => resolve(answer.trim()));
  });
}

function normalPath(p) {
  return p.replace(/\\/g, '/');
}

function toKebabCase(name) {
  return name
    .replace(/([a-z])([A-Z])/g, '$1-$2')
    .replace(/[_\s]+/g, '-')
    .toLowerCase();
}

function isDirectory(p) {
  try { return statSync(p).isDirectory(); } catch { return false; }
}

function runQuiet(cmd) {
  try {
    return execSync(cmd, { encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }).trim();
  } catch {
    return null;
  }
}

// ---------------------------------------------------------------------------
// [1/7] Prerequisites
// ---------------------------------------------------------------------------

function checkPrerequisites() {
  console.log('\n[1/7] Prerequisites');

  const nodeVersion = process.versions.node;
  const major = parseInt(nodeVersion.split('.')[0], 10);
  if (major < 18) {
    console.error(`  ERROR: Node.js 18+ required (current: ${nodeVersion})`);
    console.error('');
    console.error('  해결: https://nodejs.org 에서 Node.js 18+ 설치');
    process.exit(1);
  }
  console.log(`  Node.js v${nodeVersion} ... OK`);

  if (!existsSync(CLAUDE_DIR)) {
    console.error('  ERROR: ~/.claude/ not found.');
    console.error('');
    console.error('  해결: Claude Code를 먼저 설치하세요.');
    console.error('    npm install -g @anthropic-ai/claude-code');
    console.error('    claude  # 최초 실행 시 ~/.claude/ 자동 생성');
    process.exit(1);
  }
  console.log(`  ~/.claude/ ... OK`);

  // Check if forge is cloned to the correct location (/home/damools/forge/dev/)
  const expectedForge DevRoot = join(CLAUDE_DIR, 'forge');
  const normalizedActual = normalPath(resolve(FORGE_DEV_ROOT));
  const normalizedExpected = normalPath(resolve(expectedForge DevRoot));
  if (normalizedActual !== normalizedExpected) {
    console.error('');
    console.error('  ERROR: forge이 잘못된 경로에 clone되었습니다.');
    console.error(`    현재 위치: ${FORGE_DEV_ROOT}`);
    console.error(`    올바른 위치: ${expectedForge DevRoot}`);
    console.error('');
    console.error('  PowerShell에서 ~ 가 확장되지 않아 발생하는 문제입니다.');
    console.error('  해결:');
    console.error('    1. 잘못된 폴더 삭제');
    console.error('    2. 다시 clone:');
    if (PLATFORM === 'win32') {
      console.error(`       git clone git@github.com:moongci38-oss/forge.git "$HOME\\.claude\\forge"`);
    } else {
      console.error('       git clone git@github.com:moongci38-oss/forge.git /home/damools/forge/dev');
    }
    process.exit(1);
  }

  const platformLabel = PLATFORM === 'darwin' ? 'macOS' : PLATFORM === 'win32' ? 'Windows' : 'Linux';
  console.log(`  Platform: ${platformLabel}`);
}

// ---------------------------------------------------------------------------
// [2/7] Install Scripts
// ---------------------------------------------------------------------------

function installScripts() {
  console.log('\n[2/7] Install Scripts → ~/.claude/scripts/');
  ensureDir(SCRIPTS_DIR);

  const scriptFiles = ['forge-sync.mjs', 'session-state.mjs'];
  for (const file of scriptFiles) {
    const src = join(SRC_SCRIPTS, file);
    const dst = join(SCRIPTS_DIR, file);
    if (!existsSync(src)) { skipFile(file, 'source not found'); continue; }
    copyFile(src, dst, file);
  }
}

// ---------------------------------------------------------------------------
// [3/7] Install Global Components
// ---------------------------------------------------------------------------

function copyDirContents(srcDir, dstDir, forceOverwrite) {
  ensureDir(dstDir);
  let copied = 0, upToDate = 0;

  for (const entry of readdirSync(srcDir, { withFileTypes: true })) {
    const srcPath = join(srcDir, entry.name);
    const dstPath = join(dstDir, entry.name);

    if (entry.isDirectory()) {
      const sub = copyDirContents(srcPath, dstPath, forceOverwrite);
      copied += sub.copied;
      upToDate += sub.upToDate;
    } else {
      if (existsSync(dstPath) && !forceOverwrite) {
        const srcContent = readFileSync(srcPath, 'utf8');
        const dstContent = readFileSync(dstPath, 'utf8');
        if (srcContent === dstContent) { upToDate++; continue; }
      }
      copyFileSync(srcPath, dstPath);
      copied++;
    }
  }

  return { copied, upToDate };
}

function installGlobalComponents(forceOverwrite = false) {
  console.log('\n[3/7] Install Global Components → ~/.claude/');

  const GLOBAL_SOURCES = [
    { src: SRC_GLOBAL_RULES, dst: RULES_DIR, label: 'rules (global)' },
    { src: join(FORGE_DEV_ROOT, 'rules'), dst: RULES_DIR, label: 'rules (forge)' },
    { src: join(FORGE_DEV_ROOT, 'agents'), dst: join(CLAUDE_DIR, 'agents'), label: 'agents' },
    { src: join(FORGE_DEV_ROOT, 'skills'), dst: join(CLAUDE_DIR, 'skills'), label: 'skills' },
    { src: join(FORGE_DEV_ROOT, 'commands'), dst: join(CLAUDE_DIR, 'commands'), label: 'commands' },
    { src: join(FORGE_DEV_ROOT, 'prompts'), dst: join(CLAUDE_DIR, 'prompts'), label: 'prompts' },
    { src: join(FORGE_DEV_ROOT, 'recommended', 'skills'), dst: join(CLAUDE_DIR, 'skills'), label: 'recommended/skills' },
    { src: join(FORGE_DEV_ROOT, 'recommended', 'commands'), dst: join(CLAUDE_DIR, 'commands'), label: 'recommended/commands' },
    { src: join(FORGE_DEV_ROOT, 'recommended', 'prompts'), dst: join(CLAUDE_DIR, 'prompts'), label: 'recommended/prompts' },
  ];

  let totalCopied = 0;
  let totalUpToDate = 0;

  for (const cat of GLOBAL_SOURCES) {
    if (!existsSync(cat.src)) continue;
    ensureDir(cat.dst);

    const entries = readdirSync(cat.src);
    for (const entry of entries) {
      const srcPath = join(cat.src, entry);
      const dstPath = join(cat.dst, entry);

      if (isDirectory(srcPath)) {
        const result = copyDirContents(srcPath, dstPath, forceOverwrite);
        totalCopied += result.copied;
        totalUpToDate += result.upToDate;
        if (result.copied > 0) console.log(`  + ${cat.label}/${entry}/ (${result.copied} files)`);
        else skipFile(`${cat.label}/${entry}/`, 'up to date');
      } else {
        if (existsSync(dstPath) && !forceOverwrite) {
          const srcContent = readFileSync(srcPath, 'utf8');
          const dstContent = readFileSync(dstPath, 'utf8');
          if (srcContent === dstContent) { totalUpToDate++; skipFile(`${cat.label}/${entry}`, 'up to date'); continue; }
        }
        copyFileSync(srcPath, dstPath);
        console.log(`  + ${cat.label}/${entry}`);
        totalCopied++;
      }
    }
  }

  console.log(`  → ${totalCopied} copied, ${totalUpToDate} up-to-date`);
}

// ---------------------------------------------------------------------------
// [4/7] Dependencies — Agent SDK, Agent Teams, tmux
// ---------------------------------------------------------------------------

function installDependencies() {
  console.log('\n[4/7] Dependencies');

  // 4a. Agent SDK (global install)
  const agentSdkInstalled = runQuiet('npm list -g @anthropic-ai/claude-agent-sdk --depth=0');
  if (agentSdkInstalled && agentSdkInstalled.includes('claude-agent-sdk')) {
    console.log('  Agent SDK ... OK (installed)');
  } else {
    console.log('  Agent SDK ... installing');
    try {
      execSync('npm install -g @anthropic-ai/claude-agent-sdk', { stdio: 'inherit' });
      console.log('  + Agent SDK installed');
    } catch {
      console.log('  ⚠ Agent SDK 설치 실패. 수동 설치: npm install -g @anthropic-ai/claude-agent-sdk');
    }
  }

  // 4b. Agent Teams env var → ~/.claude/settings.json
  let settings = {};
  if (existsSync(USER_SETTINGS_PATH)) {
    try { settings = JSON.parse(readFileSync(USER_SETTINGS_PATH, 'utf8')); } catch { settings = {}; }
  }

  if (settings.env?.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS === '1') {
    console.log('  Agent Teams ... OK (enabled)');
  } else {
    if (!settings.env) settings.env = {};
    settings.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = '1';
    writeFileSync(USER_SETTINGS_PATH, JSON.stringify(settings, null, 2) + '\n', 'utf8');
    console.log('  + Agent Teams enabled (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1)');
  }

  // 4c. tmux check (Agent Teams requires tmux for parallel execution)
  if (PLATFORM !== 'win32') {
    // Mac/Linux: check tmux directly
    const tmuxVersion = runQuiet('tmux -V');
    if (tmuxVersion) {
      console.log(`  tmux ... OK (${tmuxVersion})`);
    } else {
      console.log('  ⚠ tmux 미설치. Agent Teams에 필요합니다.');
      if (PLATFORM === 'darwin') {
        console.log('    설치: brew install tmux');
      } else {
        console.log('    설치: sudo apt install tmux');
      }
    }
  } else {
    // Windows: tmux is used via WSL
    const wslTmux = runQuiet('wsl -e which tmux');
    if (wslTmux) {
      console.log('  tmux (WSL) ... OK');
    } else {
      console.log('  ⚠ tmux (WSL) 미설치. Agent Teams에 필요합니다.');
      console.log('    WSL에서 설치: sudo apt install tmux');
    }
  }

}

// ---------------------------------------------------------------------------
// [5/7] Configure — Platform-aware manifest setup
// ---------------------------------------------------------------------------

async function configure(args) {
  console.log('\n[5/7] Configure');

  if (existsSync(MANIFEST_PATH)) {
    console.log('  manifest.json already exists (keeping current)');
    return;
  }

  if (!existsSync(MANIFEST_EXAMPLE)) {
    console.error('  ERROR: manifest.example.json not found');
    process.exit(1);
  }

  let content = readFileSync(MANIFEST_EXAMPLE, 'utf8');

  // Collect paths — CLI args first, then interactive
  const paths = {};

  if (PLATFORM === 'win32') {
    // Windows: WSL + Windows workspaces
    paths.wsl = getArg(args, '--wsl-path');
    paths.windows = getArg(args, '--win-path');
    paths.forge = getArg(args, '--business-path') || getArg(args, '--business');
  } else {
    // Mac / Linux: single workspace
    paths.mac = getArg(args, '--workspace');
    paths.forge = getArg(args, '--business-path') || getArg(args, '--business');
  }

  // Interactive mode if needed
  const needsInteractive = PLATFORM === 'win32'
    ? (!paths.wsl && !paths.windows)
    : !paths.mac;

  if (needsInteractive) {
    console.log('');
    console.log('  워크스페이스 경로를 입력하세요. (Enter = 건너뛰기)');
    console.log('');

    const rl = createInterface({ input: process.stdin, output: process.stdout });

    if (PLATFORM === 'win32') {
      if (!paths.wsl) {
        paths.wsl = await ask(rl, '  WSL 워크스페이스 경로 (예: Z:/home/user/workspace): ');
      }
      if (!paths.windows) {
        paths.windows = await ask(rl, '  Windows 워크스페이스 경로 (예: E:/workspace): ');
      }
    } else {
      if (!paths.mac) {
        paths.mac = await ask(rl, '  프로젝트 워크스페이스 경로 (예: ~/projects): ');
      }
    }

    if (!paths.forge) {
      paths.forge = await ask(rl, '  Business 워크스페이스 경로 (선택, Enter=건너뛰기): ');
    }

    rl.close();
  }

  // Resolve ~ to home directory
  for (const [key, val] of Object.entries(paths)) {
    if (val && val.startsWith('~')) {
      paths[key] = join(HOME, val.slice(1));
    }
  }

  // Validate paths exist (warn, don't block)
  for (const [key, val] of Object.entries(paths)) {
    if (val && !existsSync(val)) {
      console.log(`  ⚠ ${key}: 경로가 존재하지 않습니다 → ${val}`);
      console.log(`    프로젝트 발견(Step 6)에서 해당 워크스페이스는 건너뜁니다.`);
    }
  }

  // Replace placeholders (escape backslashes for JSON compatibility)
  const jsonSafe = (p) => p.replace(/\\/g, '/');
  if (paths.wsl) content = content.replace('{WSL_WORKSPACE}', jsonSafe(paths.wsl));
  if (paths.windows) content = content.replace('{WIN_WORKSPACE}', jsonSafe(paths.windows));
  if (paths.mac) content = content.replace('{MAC_WORKSPACE}', jsonSafe(paths.mac));
  if (paths.forge) content = content.replace('{FORGE_PATH}', jsonSafe(paths.forge));

  // Remove unused workspaces (placeholder still present)
  const manifest = JSON.parse(content);
  const toRemove = [];
  for (const [key, ws] of Object.entries(manifest.workspaces)) {
    if (typeof ws.basePath === 'string' && ws.basePath.startsWith('{')) {
      toRemove.push(key);
    }
  }
  for (const key of toRemove) {
    delete manifest.workspaces[key];
  }

  saveManifest(manifest);
  console.log('  + manifest.json created');

  const wsKeys = Object.keys(manifest.workspaces);
  if (wsKeys.length > 0) {
    console.log(`  Workspaces: ${wsKeys.join(', ')}`);
  }

  return manifest;
}

// ---------------------------------------------------------------------------
// [6/7] Discover & Register Projects
// ---------------------------------------------------------------------------

async function discoverAndRegister() {
  console.log('\n[6/7] Discover & Register');

  const manifest = loadManifest();
  const workspaces = manifest.workspaces || {};

  if (Object.keys(workspaces).length === 0) {
    console.log('  (no workspaces configured, skipping)');
    return;
  }

  // Scan each workspace for Claude Code projects
  const discovered = [];

  for (const [wsKey, wsConfig] of Object.entries(workspaces)) {
    const wsPath = wsConfig.basePath;
    if (!existsSync(wsPath) || !isDirectory(wsPath)) {
      console.log(`  - ${wsKey}: path not found (${wsPath})`);
      continue;
    }

    let entries;
    try { entries = readdirSync(wsPath); } catch { continue; }

    for (const entry of entries) {
      const fullPath = join(wsPath, entry);
      if (!isDirectory(fullPath)) continue;

      // Check if this directory has .claude/ (Claude Code project)
      const claudeDir = join(fullPath, '.claude');
      if (!existsSync(claudeDir) || !isDirectory(claudeDir)) continue;

      // Derive project name
      const name = toKebabCase(basename(fullPath));

      // Check if already registered
      const normalFull = normalPath(resolve(fullPath));
      const alreadyByName = manifest.targets[name];
      const alreadyByPath = Object.entries(manifest.targets)
        .find(([, cfg]) => normalPath(resolve(cfg.path)) === normalFull);

      if (alreadyByName || alreadyByPath) {
        const existingName = alreadyByPath ? alreadyByPath[0] : name;
        skipFile(existingName, 'already registered');
        continue;
      }

      // Determine scope
      const isBusiness = name.includes('business');
      const scope = isBusiness ? 'shared-only' : 'all';

      discovered.push({ name, path: normalFull, scope, workspace: wsKey });
    }
  }

  if (discovered.length === 0) {
    console.log('  (no new projects found)');
    console.log('');
    console.log('  .claude/ 폴더가 있는 프로젝트만 자동 발견됩니다.');
    console.log('  수동 등록: node ~/.claude/scripts/forge-sync.mjs init <path> --name <name>');
    return;
  }

  // Show discovered projects
  console.log('');
  console.log('  발견된 프로젝트:');
  for (let i = 0; i < discovered.length; i++) {
    const p = discovered[i];
    console.log(`    ${i + 1}. ${p.name}  → ${p.path}  [${p.scope}]`);
  }
  console.log('');

  // Ask confirmation
  const rl = createInterface({ input: process.stdin, output: process.stdout });
  const answer = await ask(rl, '  등록하시겠습니까? (Y/n): ');
  rl.close();

  if (answer.toLowerCase() === 'n') {
    console.log('  건너뜀. 수동 등록: node ~/.claude/scripts/forge-sync.mjs init <path> --name <name>');
    return;
  }

  // Register all discovered projects
  for (const p of discovered) {
    const target = { path: p.path, scope: p.scope };
    if (p.workspace) target.workspace = p.workspace;
    manifest.targets[p.name] = target;
    console.log(`  + ${p.name} registered`);
  }

  saveManifest(manifest);
}

// ---------------------------------------------------------------------------
// [7/7] First Sync
// ---------------------------------------------------------------------------

function firstSync() {
  console.log('\n[7/7] First Sync');

  if (!existsSync(TRINE_SYNC_PATH)) {
    console.error('  ERROR: forge-sync.mjs not found. Scripts installation may have failed.');
    return;
  }

  const manifest = loadManifest();
  if (!manifest.targets || Object.keys(manifest.targets).length === 0) {
    console.log('  (no projects registered, skipping sync)');
    return;
  }

  console.log('  Running forge-sync sync --include-recommended ...');
  console.log('');

  try {
    execFileSync(process.execPath, [TRINE_SYNC_PATH, 'sync', '--include-recommended'], {
      stdio: 'inherit',
      cwd: HOME,
    });
  } catch (err) {
    console.error('');
    console.error('  ⚠ Sync 실패. 일반적인 원인:');
    console.error('    - 등록된 프로젝트 경로가 존재하지 않음');
    console.error('    - 파일 권한 문제 (관리자 권한 필요할 수 있음)');
    console.error('');
    console.error('  수동 실행: node ~/.claude/scripts/forge-sync.mjs sync --include-recommended');
    console.error('  상태 확인: node ~/.claude/scripts/forge-sync.mjs status');
  }
}

// ---------------------------------------------------------------------------
// Manifest helpers (inline — forge-sync.mjs may not be installed yet)
// ---------------------------------------------------------------------------

function loadManifest() {
  if (!existsSync(MANIFEST_PATH)) {
    console.error('Error: manifest.json not found at', MANIFEST_PATH);
    process.exit(1);
  }
  return JSON.parse(readFileSync(MANIFEST_PATH, 'utf8'));
}

function saveManifest(manifest) {
  const content = JSON.stringify(manifest, null, 2) + '\n';
  const tmpPath = MANIFEST_PATH + '.tmp';
  writeFileSync(tmpPath, content, 'utf8');
  renameSync(tmpPath, MANIFEST_PATH);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const args = process.argv.slice(2);
  const isUpdate = args.includes('--update');
  const skipDiscover = args.includes('--skip-discover');
  const skipDeps = args.includes('--skip-deps');

  console.log('');
  console.log('========================================');
  console.log('  Forge Dev Setup' + (isUpdate ? ' (update)' : ''));
  console.log('  SDD+DDD+TDD AI-Native Dev System');
  console.log('========================================');

  // Steps 1-3: Always run
  checkPrerequisites();
  installScripts();
  installGlobalComponents(isUpdate);

  // Step 4: Dependencies (runs in both normal and update mode)
  if (!skipDeps) {
    installDependencies();
  } else {
    console.log('\n[4/7] Dependencies (skipped via --skip-deps)');
  }

  if (isUpdate) {
    console.log('\n[5/7] Configure (skipped in update mode)');
    console.log('[6/7] Discover (skipped in update mode)');
    console.log('[7/7] Sync (skipped in update mode)');
  } else {
    // Step 5: Configure manifest
    await configure(args);

    // Step 6: Discover & register projects
    if (!skipDiscover) {
      await discoverAndRegister();
    } else {
      console.log('\n[6/7] Discover (skipped via --skip-discover)');
    }

    // Step 7: First sync
    firstSync();
  }

  console.log('');
  console.log('========================================');
  console.log('  Setup complete!');
  console.log('========================================');

  if (!isUpdate) {
    console.log('');
    console.log('사용법:');
    console.log('  forge-sync status                상태 확인');
    console.log('  forge-sync sync                  동기화');
    console.log('  forge-sync init <path> --name x  프로젝트 추가');
    console.log('');
    console.log('시스템 업데이트:');
    console.log('  cd /home/damools/forge/dev && git pull');
    console.log('  node /home/damools/forge/dev/scripts/setup.mjs --update');
  }
}

main();
