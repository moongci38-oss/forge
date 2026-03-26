---
name: spec-compliance-checker
description: "Spec 문서와 구현 코드 간의 추적성(Traceability)을 검증하는 전문 스킬. FR별 구현 파일 매핑, 테스트 존재 여부, API 계약 일치, 데이터 모델 일치를 체크하고 PASS/WARN/FAIL JSON을 반환한다. Forge Dev Phase 3 구현 완료 후 Check 3.5에서 자동 실행."
context: fork
agent: general-purpose
---

# Spec Compliance Checker

Spec 문서와 구현 코드 간의 추적성(Traceability)을 검증하는 전문 스킬.
Forge Dev Check 3.5에서 사용된다.

## 실행 모드

- **Subagent 격리 실행** (Check 3.6/3.7/3.8과 병렬)
- 커맨드: `/forge-check-traceability`
- 읽기 전용 — 코드 수정은 Lead가 수행

## 사용 시점

- Phase 3 구현 완료 후, Check 3 (빌드/테스트) 통과 후 실행
- Spec의 기능 요구사항이 코드와 테스트에 매핑되는지 검증

## 입력 우선순위

1. **Traceability Matrix** (`.specify/traceability/{spec-name}-matrix.json`) — 우선 사용
2. **Spec 파일** (`.specify/specs/{spec-name}.md`) — Matrix 미존재 시 직접 추출
3. **Walkthrough 파일** (`docs/walkthroughs/`) — Files Changed 크로스 체크

## 검증 항목

### 1. Spec → 코드 추적성

Spec 문서의 각 기능 요구사항이 실제 코드에 구현되었는지 확인:

- Traceability Matrix의 `implementationFiles` 경로에서 관련 코드 존재 확인
- Matrix 미존재 시: Spec의 "기능 요구사항" 섹션에서 각 항목 추출 → Grep/Glob 검색
- 매핑되지 않은 요구사항 = **누락** 으로 보고

### 2. Spec → 테스트 추적성

Spec의 각 기능 요구사항에 대응하는 테스트가 존재하는지 확인:

- Traceability Matrix의 `testFiles` 경로에서 관련 테스트 존재 확인
- 테스트 파일에서 관련 describe/it/test 블록 검색
- 커버리지 미달 요구사항 보고

### 3. API 계약 일치

Spec의 API 엔드포인트 정의와 실제 구현이 일치하는지 확인:

- HTTP Method, 경로, 요청/응답 형식
- 인증/인가 요구사항 반영 여부

### 4. 데이터 모델 일치

Spec의 데이터 모델 정의와 실제 Entity/Interface가 일치하는지 확인

## 출력 형식 (JSON, ~500 토큰)

```json
{
  "checkId": "check-3.5",
  "status": "PASS|WARN|FAIL",
  "matrixSource": "traceability-json|spec-extracted",
  "requirements": [
    {
      "id": "FR-001",
      "description": "요구사항 설명",
      "priority": "High|Medium|Low",
      "implStatus": "found|missing",
      "implFile": "path/to/file.ts",
      "testStatus": "found|missing",
      "testFile": "path/to/test.ts",
      "testType": "unit|integration|both",
      "relatedDescribeBlocks": ["describe block name 1", "describe block name 2"]
    }
  ],
  "summary": "전체 N개, 구현 N개 (N%), 테스트 N개 (N%), 누락 N개",
  "autoFixable": false
}
```

> raw grep/read 출력을 그대로 반환하지 않는다. 반드시 구조화 JSON만 반환.

## 판정 기준

| 판정 | 조건 | 행동 |
|------|------|------|
| **PASS** | 모든 필수(High) FR 구현 + 테스트 존재 | 통과 |
| **WARN** | Medium/Low FR 누락 | Lead에게 보고 |
| **FAIL** | High FR 1개+ 누락 | Lead에게 보고 |

## 실행 절차 (Step-by-Step)

### Step 1: 입력 소스 결정

```
IF .specify/traceability/{spec-name}-matrix.json 존재
  → Matrix JSON 로드 (matrixSource: "traceability-json")
ELSE IF .specify/specs/{spec-name}.md 존재
  → Spec 파일에서 FR/NFR 추출 (matrixSource: "spec-extracted")
  → "## 기능 요구사항" 또는 "## Functional Requirements" 섹션 파싱
  → 각 항목에서 ID(FR-NNN), 설명, 우선순위 추출
ELSE
  → FAIL: 입력 소스 없음
```

### Step 2: 구현 코드 존재 검증

Matrix 사용 시:
- 각 requirement의 `implementationFiles` 배열 순회
- 각 파일 경로가 프로젝트 내 실제 존재하는지 Glob/Read로 확인
- 존재 → `implStatus: "found"` / 미존재 → `implStatus: "missing"`

Spec 직접 추출 시:
- 각 FR의 핵심 키워드로 Grep 검색 (*.ts, *.tsx, *.service.ts, *.controller.ts)
- 관련 파일 발견 → `implStatus: "found"` + 파일 경로 기록
- 미발견 → `implStatus: "missing"`

### Step 3: 테스트 코드 존재 검증

Matrix 사용 시:
- 각 requirement의 `testFiles` 배열 순회
- 테스트 파일 존재 + describe/it 블록에서 관련 키워드 확인

Spec 직접 추출 시:
- `*.spec.ts`, `*.test.ts`, `*.e2e-spec.ts` 파일에서 FR 키워드 Grep
- 발견 → `testStatus: "found"` + 관련 describe 블록 이름 기록
- 미발견 → `testStatus: "missing"`

### Step 4: API 계약 일치 확인

- Spec의 API 섹션에서 엔드포인트 목록 추출 (Method, 경로, 인증)
- Controller 파일에서 `@Get/@Post/@Put/@Delete/@Patch` 데코레이터 검색
- Method + 경로 매칭 확인
- `@UseGuards(JwtAuthGuard)` 등 인증 데코레이터 존재 확인

### Step 5: 데이터 모델 일치 확인

- Spec의 데이터 모델 섹션에서 Entity/필드 목록 추출
- `*.entity.ts` 파일에서 `@Column`, `@PrimaryGeneratedColumn` 검색
- 필드명/타입 매칭 확인

### Step 6: 결과 집계 + JSON 반환

```
전체 High FR 중 구현+테스트 모두 존재 → PASS
Medium/Low FR만 누락 → WARN
High FR 1개+ 누락 → FAIL
```

## Walkthrough 크로스 체크 (선택)

Walkthrough 파일이 존재하면 추가 검증:
- "Files Changed" 섹션의 모든 파일이 실제 존재하는지 확인
- "Spec 대비 검증" 섹션의 상태와 본 체크 결과가 일치하는지 확인
- 불일치 시 WARN 추가

## Traceability Matrix JSON 표준 포맷

```json
{
  "spec": "spec-name",
  "plan": "plan-name",
  "createdAt": "2026-03-08",
  "requirements": [
    {
      "id": "FR-001",
      "description": "기능 요구사항 설명",
      "priority": "High",
      "implementationFiles": ["src/modules/xxx/xxx.service.ts"],
      "testFiles": ["src/modules/xxx/xxx.service.spec.ts"],
      "task": "Task 이름",
      "owner": "Teammate 이름"
    }
  ]
}
```

이 포맷은 Phase 1.5 요구사항 분석 시 자동 생성되며, Phase 3 구현 중 `implementationFiles`와 `testFiles`가 업데이트된다.
