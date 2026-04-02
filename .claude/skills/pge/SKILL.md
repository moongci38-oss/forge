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
3. Generator가 따를 실행 계획 작성
4. Phase 0에서 확정한 Rubric을 실행 계획에 포함

**출력**: 실행 계획 문서 (Generator 입력)

### Phase 2: Generator (Sonnet 4.6)

```
subagent_type: general-purpose
model: sonnet
```

1. Planner의 실행 계획을 입력으로 받음
2. 계획에 따라 산출물 생성/구현
3. Rubric 기준을 의식하며 생성

**출력**: 초안 산출물

### Phase 3: Evaluator (Sonnet 4.6)

```
subagent_type: general-purpose
model: sonnet
```

Generator가 자신의 산출물을 평가하지 않는다. 별도 에이전트가 수행.

1. Phase 0의 Rubric으로 항목별 점수 산정
2. PASS/FAIL 판정
3. FAIL 항목에 대한 구체적 개선 지시 작성

**출력**: Rubric 점수표 + 개선 지시 (재작업 필요 시)

### Phase 4: 피드백 루프

- **PASS**: 종료 → 최종 산출물 저장
- **FAIL (사이클 1~2)**: Generator에게 개선 지시 전달 → Phase 2 재실행
- **FAIL (사이클 3 이후)**: [STOP] Human 에스컬레이션

최대 3사이클. 3사이클 후 FAIL 잔존 시 보고서에 이슈 기록 후 Human 판단 요청.

---

## 산출물

`docs/pge/YYYY-MM-DD-{task-name}-pge-report.md`

| 항목 | 내용 |
|------|------|
| 작업 설명 | 입력 태스크 |
| Rubric | 사용한 평가 기준 |
| 사이클 수 | 실행된 루프 수 |
| 최종 판정 | PASS / FAIL + 점수 |
| 산출물 경로 | 최종 생성물 위치 |

---

## 자기평가 금지 원칙

Generator와 Evaluator는 **반드시 별도 에이전트**로 실행한다.
동일 에이전트가 생성과 평가를 모두 수행하면 자기평가 편향이 발생하여 품질 향상 효과가 없다.
