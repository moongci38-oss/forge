#!/usr/bin/env node

// =============================================================================
// Spec 유효성 검증 스크립트 — Spec 파일의 필수 섹션 및 구조를 검증
// Spec Validation Script — Validates Spec files for required sections and structure
// =============================================================================
//
// [한글]
// 기능: .specify/specs/{name}.md 파일을 읽어 필수 섹션 존재 여부,
//       제목 형식, 요구사항 항목 수, 코드 블록, 체크리스트를 검증한다.
// 트리거 시점:
//   1. Trine Phase 2 (Spec 작성) 완료 후 — spec-writer가 작성한 Spec을 검증
//   2. spec-check.yml 워크플로우에서 호출 가능 (GitHub Actions CI)
//   3. 개발자가 로컬에서 수동 실행: node validate-spec.js --spec=<name>
//
// 사용법:
//   node validate-spec.js --spec=user-auth          # 전체 검증
//   node validate-spec.js --spec=user-auth --fast   # 빠른 모드 (섹션 존재만 확인)
//
// 검증 항목:
//   [필수] 개요(Overview) 섹션 존재
//   [필수] 요구사항(Requirements) 섹션 존재
//   [필수] 테스트(Testing) 섹션 존재
//   [조건] API 섹션 (기능 Spec엔 필수, 인프라 Spec엔 선택)
//   [선택] 데이터베이스(Database) 섹션
//   [선택] 보안(Security) 섹션
//   [상세] 요구사항 항목 수, 코드 블록 수, 체크리스트 수 (--fast 시 스킵)
//
// 종료 코드:
//   0 = 검증 통과 (PASS)
//   1 = 필수 섹션 누락 (FAIL) — Spec 수정 필요
//
// Trine 파이프라인 연계:
//   - Phase 2에서 Spec 작성 완료 후 자동 실행
//   - Check 1-2 (문서 검증)의 일부
//   - 실패 시 Phase 3 (구현)으로 진행 불가
//   - spec-check.yml 워크플로우에서도 동일 검증 로직 사용 (패턴 일치)
//
// 배포 위치: 프로젝트의 .specify/scripts/validate-spec.js 또는
//           .github/scripts/validate-spec.js 에 복사하여 사용
//
// [English]
// Purpose: Reads .specify/specs/{name}.md and validates required sections,
//          title format, requirement item count, code blocks, and checklists.
// Trigger points:
//   1. After Trine Phase 2 (Spec writing) — validates Spec written by spec-writer
//   2. Can be called from spec-check.yml workflow (GitHub Actions CI)
//   3. Manual local execution: node validate-spec.js --spec=<name>
//
// Usage:
//   node validate-spec.js --spec=user-auth          # Full validation
//   node validate-spec.js --spec=user-auth --fast   # Fast mode (section check only)
//
// Validation items:
//   [Required] Overview section exists
//   [Required] Requirements section exists
//   [Required] Testing section exists
//   [Conditional] API section (required for feature specs, optional for infra)
//   [Optional] Database section
//   [Optional] Security section
//   [Detailed] Requirement item count, code blocks, checklists (skipped with --fast)
//
// Exit codes:
//   0 = Validation passed (PASS)
//   1 = Required section missing (FAIL) — Spec needs fixing
//
// Trine pipeline integration:
//   - Auto-runs after Spec writing in Phase 2
//   - Part of Check 1-2 (document validation)
//   - Failure blocks progression to Phase 3 (implementation)
//   - spec-check.yml workflow uses the same validation patterns
//
// Deployment: Copy to .specify/scripts/validate-spec.js or
//             .github/scripts/validate-spec.js in your project
// =============================================================================

const fs = require('fs');
const path = require('path');

// [한글] CLI 인자 파싱: --spec=<이름> (필수), --fast (선택)
// [English] CLI argument parsing: --spec=<name> (required), --fast (optional)
const args = process.argv.slice(2);
const specName = args.find(arg => arg.startsWith('--spec='))?.replace('--spec=', '');
const fastMode = args.includes('--fast');

console.log('Spec Validation Tool\n');

if (!specName) {
  console.error('Error: --spec argument is required');
  console.error('Usage: node validate-spec.js --spec=<spec-name>');
  process.exit(1);
}

// [한글] Spec 파일 경로: 프로젝트 루트의 .specify/specs/{name}.md
// [English] Spec file path: .specify/specs/{name}.md from project root
const specFile = path.join(process.cwd(), '.specify', 'specs', `${specName}.md`);

if (!fs.existsSync(specFile)) {
  console.error(`Spec file not found: ${specFile}`);
  process.exit(1);
}

console.log(`Validating: ${specFile}\n`);

const specContent = fs.readFileSync(specFile, 'utf-8');

const results = {
  passed: [],
  warnings: [],
  failed: []
};

// =============================================================================
// 1. 필수 섹션 검증 (Required Sections Check)
// [한글] 번호 접두사(## 1. 개요) + 한글/영문 모두 인식하는 패턴
// [English] Recognizes numbered prefix (## 1. Overview) + Korean/English patterns
// =============================================================================
console.log('Checking required sections...');

const requiredSections = [
  { name: 'Overview', pattern: /##\s*(\d+\.\s*)?(개요|Overview)/i },
  { name: 'Requirements', pattern: /##\s*(\d+\.\s*)?(기능\s*)?(요구사항|Requirements)/i },
  { name: 'Testing', pattern: /##\s*(\d+\.\s*)?(테스트|Testing)/i },
];

// [한글] 선택 섹션: 없어도 FAIL 아닌 WARNING
// [English] Optional sections: missing → WARNING, not FAIL
const optionalSections = [
  { name: 'Database', pattern: /##\s*(\d+\.\s*)?(데이터베이스|데이터\s*모델|Database|Schema)/i },
  { name: 'Security', pattern: /##\s*(\d+\.\s*)?(보안|Security)/i },
];

requiredSections.forEach(({ name, pattern }) => {
  if (pattern.test(specContent)) {
    results.passed.push(`${name} section found`);
  } else {
    results.failed.push(`${name} section missing (required)`);
  }
});

// [한글] API 섹션: 기능 Spec엔 필수지만, "해당 없음/N/A" 명시 시 통과
//       인프라/설정 Spec에는 선택적 (WARNING)
// [English] API section: required for feature specs, but passes if marked "N/A"
//           Optional for infra/config specs (WARNING)
const apiPattern = /##\s*(\d+\.\s*)?(API|Endpoints)/i;
const apiNaPattern = /##\s*(\d+\.\s*)?(API|Endpoints)[^#]*?(해당\s*없음|N\/A|not applicable)/is;
if (apiPattern.test(specContent)) {
  if (apiNaPattern.test(specContent)) {
    results.passed.push('API section found (marked N/A)');
  } else {
    results.passed.push('API section found');
  }
} else {
  results.warnings.push('API section not found (required for feature specs, optional for infra)');
}

optionalSections.forEach(({ name, pattern }) => {
  if (pattern.test(specContent)) {
    results.passed.push(`${name} section found`);
  } else {
    results.warnings.push(`${name} section not found (optional)`);
  }
});

// =============================================================================
// 2. 제목 형식 검증 (Title Format Check)
// [한글] Markdown H1 제목(# ) 존재 확인
// [English] Check for Markdown H1 title (# ) existence
// =============================================================================
console.log('Checking title format...');
const titleMatch = specContent.match(/^#\s+(.+)/m);
if (titleMatch) {
  results.passed.push(`Title found: "${titleMatch[1]}"`);
} else {
  results.warnings.push('Main title (# ) not found');
}

// =============================================================================
// 3. 상세 검증 (Detailed Validation) — --fast 모드에서는 스킵
// [한글] 요구사항 항목 수, 코드 블록 수, 체크리스트 수를 세어 Spec 품질 확인
// [English] Counts requirement items, code blocks, checklists for Spec quality
// =============================================================================
if (!fastMode) {
  console.log('Performing detailed validation...');

  // 3-1. 요구사항 항목 수 (Requirement items count)
  const requirementItems = specContent.match(/^[-*]\s+.+/gm) || [];
  if (requirementItems.length > 0) {
    results.passed.push(`${requirementItems.length} requirement items found`);
  } else {
    results.warnings.push('No requirement items (- or * lists) found');
  }

  // 3-2. 코드 블록 수 (Code blocks count)
  const codeBlocks = specContent.match(/```[\s\S]*?```/g) || [];
  if (codeBlocks.length > 0) {
    results.passed.push(`${codeBlocks.length} code blocks found`);
  }

  // 3-3. 체크리스트 항목 수 (Checklist items count)
  const checklistItems = specContent.match(/^- \[ \].+/gm) || [];
  if (checklistItems.length > 0) {
    results.passed.push(`${checklistItems.length} checklist items found`);
  }
}

// =============================================================================
// 결과 출력 (Output Results)
// [한글] PASS/WARNING/FAIL 분류하여 콘솔 출력
// [English] Categorized console output: PASS/WARNING/FAIL
// =============================================================================
console.log('\n' + '='.repeat(50));
console.log('Validation Results\n');

if (results.passed.length > 0) {
  console.log('Passed:');
  results.passed.forEach(msg => console.log(`  + ${msg}`));
  console.log('');
}

if (results.warnings.length > 0) {
  console.log('Warnings:');
  results.warnings.forEach(msg => console.log(`  ? ${msg}`));
  console.log('');
}

if (results.failed.length > 0) {
  console.log('Failed:');
  results.failed.forEach(msg => console.log(`  x ${msg}`));
  console.log('');
}

console.log('='.repeat(50));

// [한글] 필수 섹션 누락이 1개라도 있으면 exit 1 (FAIL)
// [English] Exit 1 (FAIL) if any required section is missing
if (results.failed.length > 0) {
  console.log('\nSpec validation failed');
  process.exit(1);
}

console.log('\nSpec validation passed');
process.exit(0);
