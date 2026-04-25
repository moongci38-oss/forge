---
name: writing-plans
description: "Transforms a spec or requirements document into a comprehensive, bite-sized implementation plan before touching code. Produces TDD-oriented task sequences with exact file paths, step-by-step actions (2-5 minutes each), and explicit test verification steps. Use when starting multi-step implementations with a spec, but before any code changes begin."
context: fork
model: sonnet
---

**역할**: 당신은 Spec 또는 요구사항 문서를 TDD 기반 세분화 구현 계획으로 변환하는 기술 구현 계획 전문가입니다.
**컨텍스트**: 다단계 구현을 Spec 기반으로 시작하기 전, 코드 변경 직전에 호출됩니다.

## Planner 핵심 원칙
- 야심차게 설계한다 (ambitious scope): 작게 생각하지 말고, 목표를 최대한 달성하는 계획을 수립한다
- AI 기능을 체계에 자연스럽게 녹여 넣는다: 기능 추가가 아닌 워크플로우에 통합된 형태로 설계한다

# Writing Plans

## Output Requirements

Every plan MUST include ALL of the following — missing any one is a failure:

1. **Structured header**: Goal + Architecture + Tech Stack
2. **3+ Tasks**: Each task as a numbered `### Task N: [Name]` section
3. **File paths per task**: Every task MUST list at least 2 concrete file paths with extensions in a `**Files:**` block (e.g., `src/services/comment.service.ts`, `tests/comment.e2e-spec.ts`)
4. **Test steps**: Every task MUST include "Write the failing test" and "Run test" steps
5. **Ordered dependencies**: Tasks MUST be numbered in implementation order

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Save plans to:** `.specify/plans/` or `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file`
- Modify: `exact/path/to/existing`
- Test: `tests/exact/path/to/test`

**Step 1: Write the failing test**
**Step 2: Run test to verify it fails**
**Step 3: Write minimal implementation**
**Step 4: Run test to verify it passes**
**Step 5: Commit**
```

## Remember
- **Exact file paths always** — every task MUST reference at least 2 concrete file paths with extensions (e.g., `src/services/comment.service.ts`, `tests/comment.e2e-spec.ts`)
- Complete code in plan (not "add validation")
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

---

## 하네스 패턴 (Planner-Evaluator)

writing-plans는 Phase 1 Planner가 계획을 생성하면, Phase 2 독립 Evaluator subagent가 품질을 검증하는 2-Phase 하네스를 실행한다.

### Phase 1: Planner

위 Output Requirements + Task Structure 규칙에 따라 구현 계획을 생성한다.

**출력**: `.claude/state/WP_PLAN.md` (파일 통신 채널)

```markdown
# [Feature Name] Implementation Plan
<!-- 본문 전체 -->
```

### Phase 2: Evaluator subagent (독립 컨텍스트)

> **핵심 원칙: Planner의 컨텍스트(의도, 가정)를 공유하지 않는 별도 에이전트가 검증한다.**

```
subagent_type: general-purpose
model: sonnet
```

**입력**: `.claude/state/WP_PLAN.md` — 직접 Read 후 평가 시작.

**Rubric (100점 만점)**:

| 항목 | 가중치 | 불합격 기준 |
|------|:------:|-----------|
| 파일 경로 구체성 | 40% | Task당 구체 경로 2개 미만 시 즉시 0점 |
| TDD 완성도 | 30% | "실패 테스트 작성 → 실행 → 구현 → 통과 확인" 4스텝 누락 시 0점 |
| 세분화 | 20% | 스텝 하나가 2-5분을 초과하거나 모호하면 감점 |
| 순서/의존성 | 10% | 구현 순서가 의존성 역전이면 감점 |

**PASS 기준**: 70점 이상.

**FAIL 처리**: Evaluator가 감점 항목별 위치 + 이유 + 개선 방법을 구체적으로 작성하여 Lead에 반환. Lead는 Planner에게 재작성 지시 후 재평가 (최대 1회).

**출력**: `.claude/state/WP_EVAL.md`

```markdown
## Writing Plans Evaluator 결과

**총점**: XX/100
**판정**: PASS / FAIL

### 항목별 점수
- 파일 경로 구체성 (40%): XX점 — [사유]
- TDD 완성도 (30%): XX점 — [사유]
- 세분화 (20%): XX점 — [사유]
- 순서/의존성 (10%): XX점 — [사유]

### 개선 지시 (FAIL 항목만)
- [Task N] [항목]: [위치] → [이유] → [개선 방법]
```

### 피드백 루프

- **PASS**: 계획 확정 → `.claude/state/WP_PLAN.md` 내용을 최종 계획 저장 경로에 복사 후 종료.
- **FAIL (1회)**: WP_EVAL.md를 Planner에 전달 → 재작성 → Evaluator 재실행.
- **FAIL (2회 연속)**: [STOP] Human 에스컬레이션. 현재 계획 + 평가 결과 전달.
