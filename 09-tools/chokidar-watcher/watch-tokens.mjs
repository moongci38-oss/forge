#!/usr/bin/env node
/**
 * chokidar Design Token Watcher
 *
 * 디자인 토큰 파일 변경 감지 → Claude CLI 자동 트리거
 * Usage: node 09-tools/chokidar-watcher/watch-tokens.mjs [--dry-run]
 *
 * 감시 대상:
 *   - apps/web/src/app/globals.css (CSS 변수 + @theme)
 *
 * 변경 감지 시:
 *   1. 변경된 토큰 추출 (diff 기반)
 *   2. Claude CLI 호출 → 관련 컴포넌트 업데이트 제안
 */

import { watch } from 'fs';
import { readFileSync, existsSync } from 'fs';
import { execSync, spawn } from 'child_process';
import { resolve, relative } from 'path';

// ─── Config ────────────────────────────────────────────────────────────────
const PORTFOLIO_ROOT = process.env.PORTFOLIO_PROJECT
  || resolve(process.env.HOME, 'mywsl_workspace/portfolio-project');

const WATCH_FILES = [
  'apps/web/src/app/globals.css',
];

const DRY_RUN = process.argv.includes('--dry-run');
const DEBOUNCE_MS = 2000; // 2초 디바운스 (연속 저장 방지)

// ─── State ─────────────────────────────────────────────────────────────────
let lastTrigger = 0;
const fileSnapshots = new Map();

// ─── Init: 초기 스냅샷 저장 ────────────────────────────────────────────────
function initSnapshots() {
  for (const file of WATCH_FILES) {
    const fullPath = resolve(PORTFOLIO_ROOT, file);
    if (existsSync(fullPath)) {
      fileSnapshots.set(file, readFileSync(fullPath, 'utf-8'));
      console.log(`📸 Snapshot: ${file}`);
    } else {
      console.warn(`⚠️  File not found: ${fullPath}`);
    }
  }
}

// ─── Diff: 변경된 토큰 추출 ────────────────────────────────────────────────
function extractChangedTokens(file, newContent) {
  const oldContent = fileSnapshots.get(file) || '';
  const oldLines = oldContent.split('\n');
  const newLines = newContent.split('\n');

  const changes = [];

  // CSS 변수 변경 감지 (--로 시작하는 라인)
  const oldVars = new Map();
  const newVars = new Map();

  for (const line of oldLines) {
    const match = line.match(/^\s*(--[\w-]+)\s*:\s*(.+?)\s*;/);
    if (match) oldVars.set(match[1], match[2]);
  }

  for (const line of newLines) {
    const match = line.match(/^\s*(--[\w-]+)\s*:\s*(.+?)\s*;/);
    if (match) newVars.set(match[1], match[2]);
  }

  // 추가된 토큰
  for (const [key, val] of newVars) {
    if (!oldVars.has(key)) {
      changes.push({ type: 'added', token: key, value: val });
    } else if (oldVars.get(key) !== val) {
      changes.push({ type: 'changed', token: key, from: oldVars.get(key), to: val });
    }
  }

  // 삭제된 토큰
  for (const key of oldVars.keys()) {
    if (!newVars.has(key)) {
      changes.push({ type: 'removed', token: key, value: oldVars.get(key) });
    }
  }

  return changes;
}

// ─── Claude CLI 트리거 ─────────────────────────────────────────────────────
function triggerClaude(file, changes) {
  if (changes.length === 0) {
    console.log('  ℹ️  No token changes detected (non-token edit)');
    return;
  }

  const changeSummary = changes.map(c => {
    if (c.type === 'changed') return `${c.token}: ${c.from} → ${c.to}`;
    if (c.type === 'added') return `+${c.token}: ${c.value}`;
    if (c.type === 'removed') return `-${c.token}`;
    return '';
  }).join('\n');

  const prompt = `디자인 토큰이 변경되었습니다. 영향 받는 컴포넌트를 찾아 업데이트해주세요.

변경 파일: ${file}
변경 내용:
${changeSummary}

작업:
1. 변경된 토큰을 사용하는 컴포넌트를 grep으로 찾기
2. 각 컴포넌트에서 토큰 사용이 올바른지 확인
3. 필요 시 컴포넌트 업데이트 (새 토큰 반영)`;

  console.log(`\n🤖 Claude CLI 트리거:`);
  console.log(`  변경 토큰: ${changes.length}개`);
  changes.forEach(c => console.log(`    ${c.type}: ${c.token}`));

  if (DRY_RUN) {
    console.log(`\n  [DRY RUN] 실행하지 않음. 프롬프트:`);
    console.log(`  ${prompt.split('\n')[0]}...`);
    return;
  }

  try {
    const child = spawn('claude', ['-p', prompt], {
      cwd: PORTFOLIO_ROOT,
      stdio: 'inherit',
    });

    child.on('close', (code) => {
      console.log(`\n✅ Claude CLI 완료 (exit: ${code})`);
    });

    child.on('error', (err) => {
      console.error(`❌ Claude CLI 실행 실패: ${err.message}`);
    });
  } catch (err) {
    console.error(`❌ Claude CLI 실행 실패: ${err.message}`);
  }
}

// ─── Watch ─────────────────────────────────────────────────────────────────
function startWatch() {
  console.log(`\n🔍 Design Token Watcher 시작`);
  console.log(`  Portfolio: ${PORTFOLIO_ROOT}`);
  console.log(`  감시 파일: ${WATCH_FILES.length}개`);
  console.log(`  모드: ${DRY_RUN ? 'DRY RUN' : 'LIVE'}`);
  console.log(`  디바운스: ${DEBOUNCE_MS}ms`);
  console.log(`\n  Ctrl+C로 종료\n`);

  for (const file of WATCH_FILES) {
    const fullPath = resolve(PORTFOLIO_ROOT, file);
    if (!existsSync(fullPath)) continue;

    watch(fullPath, (eventType) => {
      if (eventType !== 'change') return;

      const now = Date.now();
      if (now - lastTrigger < DEBOUNCE_MS) return;
      lastTrigger = now;

      console.log(`\n📝 변경 감지: ${file} (${new Date().toLocaleTimeString()})`);

      const newContent = readFileSync(fullPath, 'utf-8');
      const changes = extractChangedTokens(file, newContent);

      triggerClaude(file, changes);

      // 스냅샷 업데이트
      fileSnapshots.set(file, newContent);
    });

    console.log(`  👁️  Watching: ${file}`);
  }
}

// ─── Main ──────────────────────────────────────────────────────────────────
initSnapshots();
startWatch();
