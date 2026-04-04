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

### Phase 1: Planner (Opus 4.6)

```
subagent_type: general-purpose
model: opus
```

1. 작업 요구사항 분석
2. 산출물 구조 설계 (목차, 컴포넌트, 인터페이스 등)
3. **범위를 야심 있게(ambitious) 설정** — 보수적으로 축소하지 않는다
4. 가능하면 **AI 기능을 자연스럽게 체계에 녹여 넣는다** (단순 자동화보다 지능형 통합)
5. Phase 0에서 확정한 Rubric을 실행 계획에 포함

**출력**: 실행 계획 문서 (Generator 입력)

### Phase 2: Generator (Sonnet 4.6)

```
subagent_type: general-purpose
model: sonnet
```

1. Planner의 실행 계획을 입력으로 받음
2. 계획에 따라 산출물 생성/구현
3. Rubric 기준을 의식하며 생성. 목표: **"museum quality"** (라이브러리 기본값·AI 슬롭 패턴 금지)
4. **QA 핸드오프 전 자기검토** — 아래 체크 후 Evaluator에게 전달:
   - [ ] Rubric 불합격 조건 직접 확인
   - [ ] "이 정도면 됐다" 자기합리화 없음
   - [ ] 실제로 실행/렌더링되는지 확인

**출력**: 자기검토 완료된 초안 산출물

### Phase 3: Evaluator (Sonnet 4.6)

```
subagent_type: general-purpose
model: sonnet
```

Generator가 자신의 산출물을 평가하지 않는다. 별도 에이전트가 수행.

1. Phase 0의 Rubric으로 항목별 점수 산정
2. PASS/FAIL 판정
3. FAIL 항목에 대한 구체적 개선 지시 작성 — **위치 + 이유 + 방법** 3요소 필수
4. **절대 관대하게 보지 마라**: "이 정도면 괜찮지 않나?" → 감점. Generator 자체검토(SELF_CHECK.md)를 그대로 믿지 않는다.

**출력**: `PGE_QA_REPORT.md` (Rubric 점수표 + 개선 지시)

### Phase 4: 피드백 루프

- **PASS**: 종료 → 최종 산출물 저장
- **FAIL (사이클 1~2)**: `PGE_QA_REPORT.md`를 Generator에 전달 → Phase 2 재실행
- **3회 연속 같은 항목 FAIL**: 구현 방식 자체 변경 지시 (단순 수정 불가)
- **FAIL (사이클 3 이후)**: [STOP] Human 에스컬레이션

최대 3사이클. 3사이클 후 FAIL 잔존 시 현재 상태로 전달 + 이슈 보고.

## 파일 기반 통신 프로토콜

에이전트 간 컨텍스트를 파일로 전달한다. (독립 컨텍스트 원칙)

| 파일 | 작성자 | 읽는 자 | 내용 |
|------|--------|---------|------|
| `PGE_SPEC.md` | Planner | Generator, Evaluator | 설계서 + 기능 목록 |
| `PGE_SELF_CHECK.md` | Generator | Evaluator | 자체 점검 결과 |
| `PGE_QA_REPORT.md` | Evaluator | Generator (피드백 시) | 판정 + 개선 지시 |

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
