# Playwright Parallel Test Skill Validation Report

**Test Date**: 2026-03-30
**Skill**: playwright-parallel-test
**Tester**: Claude Haiku 4.5

---

## SKILL.md Structural Analysis

### Frontmatter ✅ PASS
```yaml
name: playwright-parallel-test
description: Run parallel UI tests using 3 subagents with Playwright CLI
context: fork
model: sonnet
user-invocable: true
```
All required metadata present and correct.

### Role/Context/Output Header ✅ PASS
- **역할** (Role): Clearly defined - "3개 서브에이전트로 UI를 병렬 테스트하는 프론트엔드 QA 자동화 전문가"
- **컨텍스트** (Context): Present - "종합 UI 테스트, 병렬 브라우저 테스트 요청"
- **출력** (Output): Present - "3개 영역 병렬 테스트 결과를 통합 보고서로 반환"

### Execution Structure ✅ PASS
- **Step 1**: Target Confirmation (URL, scope, headed option)
- **Step 2**: 3-Agent Parallel Spawn (clear agent definitions)
- **Step 3**: Result Integration (summary table template)
- **Step 4**: Report Storage (path and conditions)

---

## Critical Issues

### ISSUE 1: Missing "Output Requirements" Section ❌ FAIL

**Severity**: CRITICAL - Blocks standardization

**Problem**:
The skill lacks an explicit "Output Requirements" section with MUST-HAVE checklist items. Comparison with forge standards (react-best-practices, kaizen, etc.) shows this is a required pattern:

```markdown
## Output Requirements

Every {skill-name} MUST include ALL of the following:

1. {Requirement}
2. {Requirement}
...
```

**Current State**:
The skill has implicit output specifications embedded in Step 3 ("Result Integration"), but no standalone requirements section listing what the consumer MUST validate.

**Fix Required**:
Add section after "Playwright Parallel UI Test" heading:

```markdown
## Output Requirements

Every playwright-parallel-test execution MUST include ALL of the following:

1. **Test Target** — URL and scope explicitly stated in header
2. **Agent Execution Status** — Each of 3 agents shows STARTED/COMPLETED status
3. **Unified Summary Table** — Rows: Form Validation, Navigation, Responsive | Columns: Test Count, PASS, FAIL, %Pass
4. **Evidence** — Screenshots or logs for each FAIL item with assertion details
5. **Timestamp** — Execution date + time in report header (ISO 8601)
```

---

### ISSUE 2: Inaccurate Playwright CLI Commands ❌ FAIL

**Severity**: CRITICAL - Execution will fail

**Problem**:
Lines 41-105 reference playwright-cli commands that don't exist:

| Command | Status | Issue |
|---------|--------|-------|
| `playwright-cli open {URL}` | ❌ Invalid | Playwright doesn't have "open" command. Should be `browser.goto()` in code. |
| `playwright-cli snapshot` | ❌ Invalid | No "snapshot" command in playwright-cli. Likely meant `page.screenshot()` or `page.locator()`. |
| `playwright-cli resize {width} {height}` | ❌ Invalid | Not a valid command. Should be `context.browser_context` with `viewport` option. |
| `playwright-cli close` | ❌ Invalid | Should be `browser.close()` or `context.close()` in code. |

**Current Example (Agent A, Line 53)**:
```
- playwright-cli open {URL}
- playwright-cli snapshot → 폼 요소 식별
- 시나리오별 fill + click + snapshot
- 결과를 마크다운 테이블로 정리
- playwright-cli close
```

**Fix Required**:
Choose ONE approach and document it:

**Option A: Playwright Test Framework** (Recommended)
```markdown
각 에이전트는 `playwright test` 형식의 테스트 파일을 구현:

```javascript
test('Form validation - empty submit', async ({ page }) => {
  await page.goto('{URL}');
  await page.locator('form').screenshot({ path: 'form-empty.png' });
  // assertions...
});
```
```

**Option B: Playwright Code Gen + Custom Scripts**
```markdown
각 에이전트는 자체 테스트 스크립트를 구현:

```javascript
const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto('{URL}');
// custom test logic
await browser.close();
```
```

---

### ISSUE 3: Result Format Path Inconsistency ❌ WARN

**Severity**: HIGH - Conflicts with forge file-naming standards

**Problem**:
Step 4 specifies: `docs/reviews/{date}-ui-test-results.md`

**Issues**:
1. **"Trine 세션" reference** (Line 134) — Undefined term. Should be "Forge session" or "Claude Code session"?
2. **Path location** — docs/ is project-root specific, but skill runs on dev servers (portfolio, game projects, etc.). Where should output go?
3. **forge-outputs confusion** — Forge core rules (forge-core.md §산출물 경로) specify: forge/=시스템, forge-outputs/=결과물. No guidance for skill outputs.

**Expected Behavior** (by forge standards):
- Report should go to: `~/forge-outputs/01-research/ui-test/{project-name}/{date}-{description}.md`
- OR clarify that reports are project-local (not in forge-outputs)

**Fix Required**:
```markdown
### Step 4: 리포트 저장

현재 세션 컨텍스트에 따라:

- **Forge session** (/forge 프롬프트 호출):
  `~/forge-outputs/01-research/ui-test/{target-project}/{YYYY-MM-DD}-ui-test-results.md`
- **프로젝트 세션** (프로젝트 루트에서 호출):
  `docs/reviews/{YYYY-MM-DD}-ui-test-results.md`
- **독립 실행**: stdout 출력만 (파일 저장 안 함)
```

---

## High-Priority Issues

### ISSUE 4: Assessment Tests Prompt, Not Execution ⚠️ WARN

**Severity**: MEDIUM — Evals are incomplete

**Problem**:
assessment.md (lines 1-27) defines 5 evaluation criteria:

```
1. 3개 에이전트(form validation, navigation, responsive layout) 병렬 실행이 계획되어 있는가?
2. 대상 URL 또는 테스트 대상이 명시되어 있는가?
3. 각 에이전트의 테스트 범위가 구분되어 있는가?
4. 테스트 결과 통합(PASS/FAIL 리포트)이 계획되어 있는가?
5. 스크린샷 또는 증거 수집이 포함되어 있는가?
```

**Issues**:
- All 5 criteria evaluate the **PROMPT structure**, not **ACTUAL EXECUTION**
- No validation that agents truly run in parallel (vs sequentially)
- No check for real pass/fail counts (not templated values)
- No assertion that playwright commands actually execute

**Missing Assessment Dimensions**:
1. ✅ Do 3 agents spawn simultaneously? (parallel execution check)
2. ✅ Does each agent produce actual test results (not just format)?
3. ✅ Are real pass/fail metrics computed (not template placeholders)?
4. ✅ Do agents handle auth/cookies if target requires them?

**Fix Required**:
Add to assessment.md:
```markdown
## 실행 검증 기준 (Execution Validation)

pass 조건:
- 3개 에이전트가 **동시에** spawn되었는가? (순차 실행 아님)
- 각 에이전트가 실제 테스트 결과를 반환했는가? (템플릿 아님)
- 통합 리포트의 PASS/FAIL 수가 실제 값인가? (정수, 계산된 퍼센트)
- 실패 항목에 구체적 증거(스크린샷 경로, 에러 메시지)가 포함되어 있는가?
```

---

## Medium-Priority Issues

### ISSUE 5: Agent Prompts Lack Error Handling ⚠️ WARN

**Severity**: MEDIUM — Reduces robustness

**Agent A (Form Validation)** — Line 59:
```
특수문자 입력 → XSS 방지 확인
```
**Missing**: What special characters? Unicode? HTML tags? `<script>`? XSS payloads should be documented.

**Agent B (Navigation)** — Line 71:
```
404 페이지 → 존재하지 않는 경로 접근
```
**Missing**: Timeout handling if 404 page takes >5s. Recovery if 404 isn't implemented.

**Agent C (Responsive)** — Line 99:
```
텍스트 잘림/오버플로우 확인
```
**Missing**: Threshold for "overflow" (pixel overflow? line wrapping?). Visual diff tool?

**Fix Required**:
Add timeout/error specs to each agent prompt:

```markdown
#### Agent A: 폼/입력 검증 — Error Handling

- **Timeout**: 각 폼 액션은 5초 내 완료, 실패 시 스크린샷 후 다음 테스트 진행
- **특수문자 payload**: `<script>alert(1)</script>`, `"` , `'`, `\x00`
- **실패 처리**: 폼이 응답 없으면 "Form Timeout" 기록
```

---

## Summary Table

| Category | Status | Severity | Details |
|----------|:------:|:--------:|---------|
| **Frontmatter** | ✅ PASS | — | Metadata correct |
| **Role/Context/Output** | ✅ PASS | — | Clearly defined |
| **Execution Steps** | ✅ PASS | — | Logical flow |
| **Output Requirements Section** | ❌ FAIL | CRITICAL | Missing required section |
| **Playwright CLI Commands** | ❌ FAIL | CRITICAL | Commands don't exist |
| **Result Path Format** | ⚠️ WARN | HIGH | Conflicts with forge standards |
| **Assessment Coverage** | ⚠️ WARN | MEDIUM | Tests prompt, not execution |
| **Agent Error Handling** | ⚠️ WARN | MEDIUM | Missing timeout/recovery specs |
| **File Naming** | ⚠️ WARN | MEDIUM | `{date}` format vs `{YYYY-MM-DD}` |

---

## Overall Grade

**WARN** — Functional for parallel test planning, but requires corrections before production use.

### Blocker Issues (MUST FIX)
1. ❌ Add explicit "Output Requirements" section with 5 MUST-HAVE items
2. ❌ Replace playwright-cli commands with valid approach (playwright test framework or custom scripts)
3. ❌ Clarify result storage path per forge standards

### Recommended Fixes (SHOULD FIX)
1. ⚠️ Expand assessment.md to validate actual execution (not just prompt structure)
2. ⚠️ Document timeout/error handling in agent prompts
3. ⚠️ Update file naming to `{YYYY-MM-DD}-{description}` format

---

## Validation Checklist

- [x] Frontmatter present and valid
- [x] Role/Context/Output defined
- [x] Execution steps documented
- [ ] Output Requirements section present (FAIL)
- [ ] Playwright commands accurate (FAIL)
- [x] Assessment criteria defined
- [ ] Assessment tests execution (WARN)
- [ ] Result path matches forge conventions (WARN)
- [ ] Error handling documented (WARN)
- [ ] File naming consistent (WARN)

**Pass Rate**: 6/10 (60%) — Below 0.8 minimum

---

## Next Steps

1. **Priority 1**: Add Output Requirements section + fix playwright commands
2. **Priority 2**: Update assessment.md and result path specs
3. **Priority 3**: Add error handling + timeout documentation to agent prompts
4. **Test**: Run skill with sample URL after fixes to validate parallel execution

---

*Report generated by: Playwright Parallel Test Skill Validation*
*Framework: Forge Skill Assessment Protocol v1*
