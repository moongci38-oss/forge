---
description: 알려진 버그/이슈를 Hotfix 흐름으로 빠르게 처리
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent
argument-hint: <이슈 설명 또는 Notion task URL>
model: sonnet
---

# /forge-fix

알려진 버그/이슈를 **Hotfix 흐름**으로 빠르게 처리하는 단일 진입 커맨드.

Phase 1.5(요구사항 분석) / Phase 2(Spec 작성) 오버헤드 없이:
`Phase 1(경량) → Phase 3 → Check 3 → Check 3.7 → Phase 4`

## 사용법

```
/forge-fix <이슈 설명 또는 Notion task URL>
```

**예시**:
```
/forge-fix 로그인 페이지에서 이메일 유효성 검사가 작동하지 않음
/forge-fix https://notion.so/xxx (Notion 이슈 URL)
```

## 실행 흐름

### Step 1. 이슈 파싱

- 자유 텍스트 입력 → 이슈 내용 직접 파악
- Notion URL 입력 → `forge-pm-updater` Subagent로 상세 조회

### Step 2. Hotfix 분류 확인

이슈 내용을 분석하여 Hotfix 적합성을 판단한다:

| 조건 | 판정 |
|------|------|
| 단일 파일 수정 예상 + 명확한 버그 | ✅ Hotfix 진행 |
| 변경 파일 2개 이상 예상 | **[STOP]** Standard로 재분류 제안 |
| 새 기능/리팩토링 성격 | **[STOP]** `/forge` 커맨드로 전환 제안 |

### Step 3. E2E 버그 재현 시도 (선택)

E2E 테스트가 존재하는 경우:
```bash
# 관련 E2E 테스트만 실행하여 버그 재현
npx playwright test --grep "관련 테스트명"
```
- 재현 성공 → 에러 컨텍스트를 Step 4에 전달
- 재현 실패 또는 테스트 없음 → Step 4로 바로 진행

### Step 4. 구현

Spec/Plan 작성 없이 직접 수정:
- 단일 파일 원칙: 수정 범위가 2개 이상 파일로 확대되면 **[STOP]** 재분류
- `test-results/` 폴더의 E2E 컨텍스트가 있으면 수정에 활용

### Step 5. 검증

```
Check 3: verify.sh code (build + test + lint + type)
  → FAIL → autoFix 1회 → 재실행 → FAIL → [STOP]
  → PASS → Check 3.7

Check 3.7: code-reviewer 에이전트 스폰 (역할 분리 병렬)
  → FAIL → 수정 → Check 3 재실행
  → PASS | CONDITIONAL → Phase 4
```

### Step 6. PR 생성 + CI 대기

```bash
# 브랜치: hotfix/{issue-summary}
# PR 생성 후 CI 대기
gh run watch {RUN_ID}
# CI PASS → 리뷰 폴링 3종 실행
```

## 에스컬레이션 규칙

| 상황 | 행동 |
|------|------|
| 수정 범위 확대 (2+ 파일) | **[STOP]** "Standard 작업으로 재분류가 필요합니다. `/forge` 커맨드를 사용하세요." |
| 새 기능/리팩토링 성격 감지 | **[STOP]** "이 작업은 Hotfix가 아닙니다. `/forge` 커맨드로 시작하세요." |
| Check 3 autoFix 1회 초과 | **[STOP]** 에러 내용 + 시도한 수정 요약 보고 |
| Check 3.7 Critical 발견 + 수정 불가 | **[STOP]** 이슈 내용 + 수정 방향 제안 |

## forge-sync 배포 대상

이 커맨드는 `forge-sync` 실행 시 `~/.claude/commands/forge-fix.md`에 자동 배포된다.
