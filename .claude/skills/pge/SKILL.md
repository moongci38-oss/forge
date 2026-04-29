---
name: pge
description: Planner-Generator-Evaluator 자동 오케스트레이션 스킬. 복잡한 구현/생성 작업을 3-에이전트 하네스로 자동 실행하며 최대 3회 피드백 루프를 돈다.
user-invocable: true
context: fork
model: opus
---

**역할**: 당신은 Planner-Generator-Evaluator 하네스를 오케스트레이션하는 Lead 에이전트입니다.
**컨텍스트**: 복잡한 구현/생성 작업에서 품질이 결과를 결정할 때 사용합니다.
**출력**: 최종 산출물 + PGE 실행 보고서 (`docs/pge/YYYY-MM-DD-{task-name}-pge-report.md`)

# PGE — Planner-Generator-Evaluator 오케스트레이터

AI 출력 품질의 핵심 변수는 모델이 아니라 **구조(하네스)**다.
이 스킬은 Planner → Generator → Evaluator → (재작업 루프) 체인을 자동 실행한다.

## 사용법

```
/pge <task description>
/pge --rubric custom  # 커스텀 Rubric 사용
/pge --cycles 2       # 최대 2사이클 (기본 3)
```

## 적용 대상

| 적합 | 부적합 |
|------|--------|
| 코드 기능 구현 | 단순 정보 조회 |
| 기획서/문서 초안 작성 | 파일 탐색 |
| 에셋/이미지 생성 기획 | 1회성 수정 |
| 복잡한 리서치 보고서 | 설정 변경 |

---

## 실행 워크플로우

### Phase 0: Rubric 확정

Evaluator가 사용할 평가 기준을 Generator 실행 **전**에 명시한다.

기본 Rubric (작업 유형에 따라 조정):

| 항목 | 가중치 | 불합격 기준 |
|------|:------:|-----------|
| 요구사항 충족도 | 40% | 핵심 요구사항 미충족 시 즉시 FAIL |
| 품질/완성도 | 30% | AI 슬롭(무의미 반복·복붙·미완성) 감지 시 0점 |
| 구조/아키텍처 | 20% | 설계 의도 위반 시 0점 |
| 문서/명확성 | 10% | 주요 내용 누락 시 5점 이하 |

**PASS 기준**: 합산 70점 이상 + 요구사항 즉시 FAIL 없음

### Phase 1: Planner (Opus 4.7)

```
subagent_type: general-purpose
model: opus
```

1. **Rules 로딩** (subagent는 main session rules 미상속 — 직접 Read 필수):
   - `{project_root}/.claude/rules/system-analysis-cycle.md` — 기존 시스템 분석→사용→반영→재사용 원칙
   - `{project_root}/.claude/rules/pre-modification-analysis.md` — 수정 전 의존성 분석 4단계 + 파일별 애니메이션 방식
   - UI/연출/에셋 태스크인 경우: `{project_root}/.claude/rules/forge-spec-visual-binding.md` — 기획서·시안을 Spec 수치로 바인딩
   - **각 rules 파일 내 링크된 reference 파일도 반드시 Read**
   - **Unity 클라이언트 작업 시 추가 Read**:
     - `{project_root}/.claude/reference/key-file-map.md` — 기능별 파일 위치 + 쌍 수정 패턴
     - `{project_root}/.claude/reference/code-snippets.md` — DOTween/UI/이벤트 표준 패턴
     - `{project_root}/.claude/reference/codebase-analysis.md` — 아키텍처/의존성 분석 (존재 시, codebase-analyzer 산출물)
   - **웹/앱 UI 작업 시 추가 Read**:
     - `~/forge/shared/design-tokens/design-rules.md` — 레이아웃 4타입, 금지사항 7개, 카드/간격 원칙
     - `~/forge/shared/design-tokens/instagram-default.json` — 색상/타이포/스페이싱 토큰
2. 작업 요구사항 분석 — `system-analysis-cycle.md`에 따라 기존 시스템 분석 문서 먼저 확인
3. **Unity 클라이언트 .cs 수정이 포함된 경우** (필수 순서):
   1. `{project_root}/.claude/state/current-analysis.md` 존재 확인 — **있으면 먼저 Read**하여 이전 분석 재사용 판단
   2. `{project_root}/.claude/reference/key-file-map.md` **Read** — 기능별 파일 위치 + 쌍 수정 패턴
   3. `{project_root}/.claude/reference/code-snippets.md` **Read** — DOTween/UI/이벤트 표준 패턴
   4. `{project_root}/.claude/reference/pre-modification-analysis-detail.md` **Read** — Step 0~5 의존성 분석 지침 (핵심: Step 3 실행 흐름 추적)
   5. `{project_root}/.claude/reference/pge-game-evaluator-rubric-detail.md` **Read** — 평가 기준 숙지
   6. `pre-modification-analysis-detail.md`의 Step 0~4 지침을 순서대로 수행 (Step 3 실행 흐름 추적이 가장 중요)
   7. 분석 결과를 `{project_root}/.claude/state/current-analysis.md`에 **저장 (Write)** — Step 0~4 섹션 + 대상 파일명 필수 포함
   → Hook이 내용 검증함: Step 0~4 섹션 없거나 대상 파일명 없으면 Generator의 .cs 수정이 차단됨
4. 산출물 구조 설계 (목차, 컴포넌트, 인터페이스 등)
5. **범위를 야심 있게(ambitious) 설정** — 보수적으로 축소하지 않는다
5. 가능하면 **AI 기능을 자연스럽게 체계에 녹여 넣는다** (단순 자동화보다 지능형 통합)
6. Phase 0에서 확정한 Rubric을 실행 계획에 포함

**출력**: `{project_root}/.claude/state/PGE_SPEC.md` + (Unity .cs 수정 시) `{project_root}/.claude/state/current-analysis.md`
- 상단에 "## 참조 컨텍스트" 섹션 — 로드한 reference 파일 목록 + 핵심 내용 요약
- 이후 실행 계획 본문

### Phase 2: Generator (Sonnet 4.6)

```
subagent_type: general-purpose
model: sonnet
```

1. **Rules 로딩** (subagent는 main session rules 미상속 — 직접 Read 필수):
   - `{project_root}/.claude/rules/pre-modification-analysis.md` — 수정 전 의존성 분석 필수, 파일별 애니메이션 방식 확인 (**링크된 reference 파일도 Read**)
   - `{project_root}/.claude/rules/verification-integration.md` — Check 3 기준 숙지 (구현 후 무엇이 검증되는지)
   - `{project_root}/.claude/rules/forge-walkthrough.md` — 구현 완료 후 Walkthrough 작성 기준
   - 영상 레퍼런스 태스크인 경우: `{project_root}/.claude/rules/video-reference-workflow.md` (**링크된 reference 파일도 Read**)
2. `{project_root}/.claude/state/PGE_SPEC.md` 읽기
3. **Unity .cs 수정이 포함된 경우 필수**: `{project_root}/.claude/state/current-analysis.md` **Read** → Planner가 수행한 Step 0~4 분석 결과 숙지 후 구현
4. PGE_SPEC.md의 "## 참조 컨텍스트" 섹션에 명시된 reference 파일들을 직접 Read
5. 계획에 따라 산출물 생성/구현 — **반드시 reference의 패턴/규칙을 준수**
6. Rubric 기준을 의식하며 생성. 목표: **"museum quality"** (라이브러리 기본값·AI 슬롭 패턴 금지)
7. **QA 핸드오프 전 자기검토** — 아래 체크 후 Evaluator에게 전달:
   - [ ] Rubric 불합격 조건 직접 확인
   - [ ] "이 정도면 됐다" 자기합리화 없음
   - [ ] 실제로 실행/렌더링되는지 확인
   - [ ] key-file-map의 쌍 수정 패턴 준수 여부
   - [ ] code-snippets의 파일별 애니메이션 방식 준수 여부

8. **Unity .cs 수정 완료 후**: `{project_root}/.claude/state/current-analysis.md`의 Step 4에 수정 결과 추가 (수정된 파일:라인, 수정 전/후 동작 차이, 잔존 이슈)

**출력**: `{project_root}/.claude/state/PGE_SELF_CHECK.md` + 산출물(코드/파일) + (Unity .cs 수정 시) 갱신된 `current-analysis.md`

### Phase 3: QA — 독립 에이전트 검증 (필수)

> **핵심 원칙: 개발 에이전트 ≠ 테스트 에이전트**
> Generator의 컨텍스트(의도, 시도, 가정)를 공유하지 않는 **별도 에이전트**가 검증한다.
> 같은 에이전트가 개발+테스트하면 같은 맹점을 가진다.

#### QA 에이전트 스폰 규칙

```
Generator 완료
  ↓ 전달: 변경 파일 목록 + Spec 경로 (Generator의 의도/가정은 전달하지 않음)
  ↓
QA Agent (별도 subagent, 독립 컨텍스트)
  ↓ 변경 파일 확장자로 트랙 자동 감지
  ↓
트랙별 검증 실행
```

#### 트랙 라우팅 (변경 파일 기반 자동 감지)

| 트랙 | 감지 조건 | 호출 대상 | 비고 |
|------|----------|----------|------|
| **A. 기능** | 서버/로직 코드 변경 (.cs service, .ts service, .py) | `verify.sh code` + 데이터 흐름 트레이싱 | 항상 실행 |
| **B. 웹/앱 UI** | .tsx/.jsx/.css/.html 변경 | `/ux-audit` + `/playwright-parallel-test` | 해당 시만 |
| **C. 게임 연출/UI** | Unity .cs + .prefab + .anim 변경 | `/game-qa` (신규) | 해당 시만 |

트랙은 **중복 가능** — 서버+클라이언트 동시 변경이면 A+C 모두 실행.

#### 트랙 A: 기능 테스트

빌드 + 데이터 흐름을 검증한다.

1. **빌드**: 프로젝트 빌드 실행 → Error 0건 확인
2. **데이터 흐름 트레이싱** (버그 수정 시 필수):
   - 수정한 코드의 전체 호출 경로를 추적
   - 서버 응답 필드 → 프로토콜 → 클라이언트 수신 → UI/동작 체인
   - 각 단계에서 값 유효성 확인 (≠0, ≠null, ≠default)
   - 1:N 매핑, 분기 조건, 변환 누락 확인
3. **결과**: `PGE_QA_RESULT.md`에 체인별 PASS/FAIL 기록

#### 트랙 B: 웹/앱 UI/UX 테스트

기존 스킬을 호출한다:

1. `/ux-audit` → 9항목 UX 품질 검증 (색상 대비, 터치 타겟, 반응형 등)
2. `/playwright-parallel-test` → 3-Agent 병렬 브라우저 테스트 (폼, 네비, 반응형)
3. **design-rules 준수 검증** → `~/forge/shared/design-tokens/design-rules.md` Read 후 체크:
   - 섹션 타입(A/B/C/D) 연속 배치 위반
   - 금지사항 7개 위반 (순수 검정, 카드 밖 콘텐츠 등)
   - 간격 시스템 비준수 (홀수 px 등)
4. **결과**: 각 스킬의 PASS/FAIL JSON을 `PGE_QA_RESULT.md`에 병합

#### 트랙 C: 게임 연출/UI 테스트

`/game-qa` 스킬을 호출한다 (별도 스킬 파일에 상세 정의).

검증 3계층:
1. **파라미터 검증**: 코드 수치 ↔ 기획서/레퍼런스 1:1 대조
2. **런타임 검증**: Unity MCP로 캡처 → `/screenshot-analyze --verification`으로 레퍼런스 비교
3. **Human 필요 항목 명시**: AI가 판단할 수 없는 퀄리티 항목을 구체적으로 리스트업

#### QA 결과 보고

QA Agent가 `PGE_QA_RESULT.md`를 작성:

```markdown
## QA 결과 (독립 에이전트 검증)

### 트랙 A 기능: PASS/FAIL
- 빌드: Error 0건
- 데이터 흐름: [체인별 PASS/FAIL]

### 트랙 B 웹 UI: PASS/FAIL/SKIP
- /ux-audit: [9항목 결과 요약]
- /playwright: [3-Agent 결과 요약]

### 트랙 C 게임 연출/UI: PASS/FAIL/SKIP
- /game-qa: [파라미터 검증 + 런타임 캡처 결과]

### Human 검증 필요 항목
| 항목 | 이유 | 확인 방법 |
|------|------|----------|
| ... | AI 판단 불가 | ... |
```

**QA FAIL 시**: `PGE_QA_RESULT.md`를 Generator에 전달 → Phase 2 재실행

---

### Phase 4: Evaluator (Sonnet 4.6)

```
subagent_type: general-purpose
model: sonnet
```

Generator가 자신의 산출물을 평가하지 않는다. 별도 에이전트가 수행.

1. **Rules 로딩** (subagent는 main session rules 미상속 — 직접 Read 필수):
   - `{project_root}/.claude/rules/verification-integration.md` — Check 3 기준으로 감점 판단 (빌드/테스트/lint 기준)
2. 아래 파일을 순서대로 **직접 Read**:
   - `{project_root}/.claude/rules/pge-game-evaluator-rubric.md`
   - `{project_root}/.claude/reference/pge-game-evaluator-rubric-detail.md`
3. `{project_root}/.claude/state/PGE_SPEC.md` 읽기 (참조 컨텍스트 확인)
4. Phase 0의 Rubric으로 항목별 점수 산정
5. **Phase 3 QA 결과(`{project_root}/.claude/state/PGE_QA_RESULT.md`)를 반영** — QA에서 발견된 잔존 이슈가 있으면 감점
6. PASS/FAIL 판정
7. FAIL 항목에 대한 구체적 개선 지시 작성 — **위치 + 이유 + 방법** 3요소 필수
8. **절대 관대하게 보지 마라**: "이 정도면 괜찮지 않나?" → 감점. Generator 자체검토(SELF_CHECK.md)를 그대로 믿지 않는다.
9. **(선택) Advisor 경계 판정 호출** — 총점이 **58~67점 구간**일 때만 (PASS 70점 경계의 ±):

   ```
   Agent(
     subagent_type="advisor-strategist",
     prompt=f"""
   PGE Evaluator 경계 판정 조언 요청.

   점수: {총점}/100 (PASS 기준 70)
   Rubric 상세:
   - 정확성 {n}/20
   - 완결성 {n}/20
   - 가독성 {n}/20
   - 안전성 {n}/20
   - (기타 항목) {n}/20

   작업 요약 (3~5줄):
   {산출물 요약}

   FAIL로 의심되는 항목 1~2개:
   {항목 + 구체 사유}

   질문:
   이 작업이 PASS 기준에 미달하는 결정적 요인을 1~2개로 압축해주세요.
   재작업이 필요하면 가장 저비용 경로를 제시해주세요.
   """
   )
   ```

   Advisor 응답을 받아 최종 PASS/FAIL 판정을 내린다. 경계 외(40점대·70점 이상)는 호출 불필요.

**출력**: `{project_root}/.claude/state/PGE_QA_REPORT.md` (Rubric 점수표 + QA 결과 반영 + 개선 지시)
완료 후 `{project_root}/docs/pge/YYYY-MM-DD-{task-name}-pge-report.md`에 최종 보고서 저장.

### Phase 5: 피드백 루프

- **PASS**: 종료 → 최종 산출물 저장
- **FAIL (사이클 1~2)**: `PGE_QA_REPORT.md`를 Generator에 전달 → Phase 2 재실행 → Phase 3 QA 재검증
- **3회 연속 같은 항목 FAIL**: 구현 방식 자체 변경 지시 (단순 수정 불가)
- **FAIL (사이클 3 이후)**: [STOP] Human 에스컬레이션

최대 3사이클. 3사이클 후 FAIL 잔존 시 현재 상태로 전달 + 이슈 보고.

## 파일 기반 통신 프로토콜

에이전트 간 컨텍스트를 파일로 전달한다. (독립 컨텍스트 원칙)

**모든 PGE 중간 파일은 `{project_root}/.claude/state/` 에 저장한다.**
`{project_root}`는 현재 작업 디렉토리(Primary working directory) 기준.

| 파일 | 경로 | 작성자 | 읽는 자 | 내용 |
|------|------|--------|---------|------|
| `PGE_SPEC.md` | `.claude/state/PGE_SPEC.md` | Planner | Generator, QA, Evaluator | 설계서 + 기능 목록 + 로드한 reference 목록 |
| `PGE_SELF_CHECK.md` | `.claude/state/PGE_SELF_CHECK.md` | Generator | QA, Evaluator | 자체 점검 결과 |
| `PGE_QA_RESULT.md` | `.claude/state/PGE_QA_RESULT.md` | QA (Phase 3) | Evaluator, Generator (피드백 시) | 빌드/런타임/UI/데이터 검증 결과 |
| `PGE_QA_REPORT.md` | `.claude/state/PGE_QA_REPORT.md` | Evaluator | Generator (피드백 시) | Rubric 판정 + QA 반영 + 개선 지시 |

### Reference 로딩 원칙

각 Phase의 rules 파일이 관련 reference 파일을 링크로 포함한다.
rules 파일을 읽고 **링크된 reference 파일도 반드시 Read**하면 필요한 모든 컨텍스트가 확보된다.

| rules 파일 | 체이닝되는 reference 파일 |
|-----------|------------------------|
| `pre-modification-analysis.md` | `pre-modification-analysis-detail.md`, `key-file-map.md`, `code-snippets.md` |
| `video-reference-workflow.md` | `video-reference-workflow-detail.md` |
| `pge-game-evaluator-rubric.md` | `pge-game-evaluator-rubric-detail.md` |

Planner가 로드한 reference 목록은 `PGE_SPEC.md` 상단 "## 참조 컨텍스트" 섹션에 기록한다.
Generator와 Evaluator는 이 섹션을 읽고 명시된 파일들을 직접 Read한다.

---

## 산출물 및 완료 보고

완료 시 아래 형식으로 보고:

```
## PGE 실행 완료

**결과물**: [산출물 경로]
**Planner 설계 항목 수**: X개
**QA 반복 횟수**: X회
**최종 점수**: [항목별] (가중 X.X/10)

**실행 흐름**:
1. Planner: [무엇을 설계했는지 한 줄]
2. Generator R1: [첫 구현 결과 한 줄]
3. Evaluator R1: [판정 + 핵심 피드백 한 줄]
4. Generator R2: [수정 내용 한 줄] (해당 시)
...
```

---

## 자기평가 금지 원칙

Generator와 Evaluator는 **반드시 별도 에이전트**로 실행한다.
동일 에이전트가 생성과 평가를 모두 수행하면 자기평가 편향이 발생하여 품질 향상 효과가 없다.
