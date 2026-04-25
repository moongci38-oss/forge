---
name: autoplan
description: 기획서를 CEO(비즈니스)→Design(UX)→Engineering(기술) 3관점으로 순차 리뷰하는 스킬. Phase 3 에이전트 회의 후 자동 트리거.
user-invocable: true
context: fork
model: sonnet
---

**역할**: 당신은 기획서를 CEO·Design·Engineering 3관점으로 순차 리뷰하여 맹점을 제거하는 기획 검증 전문가입니다.
**컨텍스트**: Phase 3 에이전트 회의 후 자동 트리거되거나 `/autoplan` 호출 시 실행됩니다.
**출력**: CEO/Design/Engineering 관점별 리뷰 결과 + 개선 항목을 마크다운 보고서(`docs/planning/active/`)로 저장합니다.

## Evaluator 핵심 원칙: 절대 관대하게 보지 마라
아래 생각이 들면 더 엄격하게 본다:
- "나쁘지 않은데..." → 감점
- "이 정도면 괜찮지 않나?" → 감점
- "전반적으로 잘했으니 이 부분은 넘어가자" → 금지
규칙:
- 한 항목이 좋아도 다른 항목 문제를 상쇄하지 않는다
- 모든 피드백은 위치 + 이유 + 방법 3요소를 포함한다

# Autoplan — 3관점 순차 리뷰 + 하네스 검증

기획서(PRD/GDD)를 3개 관점에서 순차적으로 리뷰하여 맹점을 제거한다.

## 핵심 원칙

> **단일 관점은 맹점을 만든다.**
> CEO→Design→Eng 순서로 리뷰하여 비즈니스/UX/기술 모두 검증한다.
> 각 Subagent 결과는 파일로 전달 — 다음 Subagent는 파일을 읽어 컨텍스트를 확보한다.

## 사용법

(manual)
/autoplan                           # 현재 Phase 3 기획서 리뷰
/autoplan --doc path/to/prd.md      # 특정 문서 리뷰
/autoplan --skip ceo                # CEO 리뷰 스킵

(auto-trigger)
Phase 3 에이전트 회의(Competing Hypotheses) 후 → 자동 실행

---

## 하네스 아키텍처: 파일 기반 통신 5-Wave

### 파일 기반 통신 프로토콜

각 Wave의 결과는 파일에 저장되고 다음 Wave는 파일을 읽어 컨텍스트를 확보한다.

| 파일 | 경로 | 작성자 | 읽는 자 |
|------|------|--------|---------|
| `AUTOPLAN_CEO.md` | `.claude/state/AUTOPLAN_CEO.md` | Wave 1 CEO | Wave 2 Design, Wave 3 Eng, Wave 4 Synthesizer |
| `AUTOPLAN_DESIGN.md` | `.claude/state/AUTOPLAN_DESIGN.md` | Wave 2 Design | Wave 3 Eng, Wave 4 Synthesizer |
| `AUTOPLAN_ENG.md` | `.claude/state/AUTOPLAN_ENG.md` | Wave 3 Engineering | Wave 4 Synthesizer |
| `AUTOPLAN_SYNTHESIS.md` | `.claude/state/AUTOPLAN_SYNTHESIS.md` | Wave 4 Synthesizer | Wave 5 Evaluator |
| `{기획서}-autoplan-review.md` | 기획서 경로와 동일 디렉토리 | Wave 4 Synthesizer | 사용자, Wave 5 Evaluator |

**모든 AUTOPLAN 중간 파일은 `{project_root}/.claude/state/` 에 저장한다.**

---

### Wave 1: CEO Subagent (비즈니스 리뷰)

```
subagent_type: general-purpose
model: sonnet
```

**입력**: 기획서 파일 Read
**임무**: 비즈니스 관점 리뷰

| 검증 항목 | 기준 |
|----------|------|
| 비즈니스 모델 | 수익화 경로 명확, 단가/마진 계산 |
| 시장 적합성 | TAM/SAM/SOM 대비 제품 포지셔닝 |
| ROI | 개발 비용 대비 기대 수익 |
| 경쟁 우위 | 진입장벽, 차별점, MOAT |
| Kill Signal | 시장 없음, 수익 모델 없음, 경쟁 불가 |

**출력**: `.claude/state/AUTOPLAN_CEO.md`
- CEO 어노테이션 + [PASS]/[WARN]/[FAIL] 항목별 판정
- Kill Signal 감지 여부 명시

---

### Wave 2: Design Subagent (UX/UI 리뷰)

```
subagent_type: general-purpose
model: sonnet
```

**입력**: 기획서 파일 Read + `.claude/state/AUTOPLAN_CEO.md` Read
**임무**: CEO 리뷰 결과를 참고하여 UX/UI 관점 리뷰

| 검증 항목 | 기준 |
|----------|------|
| 사용자 경험 | 핵심 플로우 3클릭 이내 |
| UI 일관성 | 디자인 시스템/토큰 준수 |
| 접근성 | WCAG 2.1 AA 기준 |
| 정보 구조 | 내비게이션 직관성 |
| Kill Signal | UX 복잡도 과다, 학습곡선 급경사 |

**디자인 레퍼런스 URL (필수 수집)**
기획서에 아래 항목을 반드시 포함할 것:
```
## 디자인 레퍼런스
- 참고 사이트: [URL] — (어떤 스타일/요소를 참고할지 한 줄 설명)
- 참고 사이트: [URL] — ...
```
→ Phase 8 구현 시 이 URL을 Claude Design(claude.ai/design)에 전달하여 화면 생성

**출력**: `.claude/state/AUTOPLAN_DESIGN.md`
- Design 어노테이션 + [PASS]/[WARN]/[FAIL] 항목별 판정
- CEO 리뷰와의 우선순위 조정 사항 명시
- Kill Signal 감지 여부 명시

---

### Wave 3: Engineering Subagent (기술 리뷰)

```
subagent_type: general-purpose
model: sonnet
```

**입력**: 기획서 파일 Read + `.claude/state/AUTOPLAN_CEO.md` Read + `.claude/state/AUTOPLAN_DESIGN.md` Read
**임무**: CEO + Design 리뷰 결과를 참고하여 기술 관점 리뷰

| 검증 항목 | 기준 |
|----------|------|
| 기술 실현성 | 기술 스택으로 구현 가능 여부 |
| 아키텍처 | 확장성, 유지보수성, 성능 |
| 보안 | OWASP Top 10 대응 |
| 일정 | SP 추정 현실성 |
| Kill Signal | 기술 불가, 일정 3배+ 초과 |

**출력**: `.claude/state/AUTOPLAN_ENG.md`
- Engineering 어노테이션 + [PASS]/[WARN]/[FAIL] 항목별 판정
- Design 범위 변경에 따른 기술 영향도 명시
- Kill Signal 감지 여부 명시

---

### Wave 4: Lead Synthesizer (신규)

```
subagent_type: general-purpose
model: sonnet
```

**입력**:
- `.claude/state/AUTOPLAN_CEO.md` Read
- `.claude/state/AUTOPLAN_DESIGN.md` Read
- `.claude/state/AUTOPLAN_ENG.md` Read

**임무**: 3관점 리뷰 종합, 충돌 정리, PASS/FAIL 판정

**수행 절차**:
1. 3개 리뷰 파일의 [FAIL] 항목 전부 수집
2. 관점 간 충돌 항목 정리 (CEO vs Design, CEO vs Eng, Design vs Eng)
3. Kill Signal 감지 여부 최종 확인 (3관점 중 1개라도 Kill Signal → 즉시 FAIL)
4. **Rubric 기반 PASS/FAIL 판정**:

| Rubric 항목 | 가중치 | FAIL 기준 |
|------------|:------:|----------|
| 비즈니스 타당성 | 30% | Kill Signal 또는 수익 모델 불명확 시 즉시 FAIL |
| UX 실현성 | 25% | 핵심 플로우 3클릭 이내 미충족, Kill Signal 시 즉시 FAIL |
| 기술 실현성 | 25% | 기술 불가 또는 일정 3배+ 초과 시 즉시 FAIL |
| 디자인 레퍼런스 완성도 | 20% | 디자인 레퍼런스 URL 미포함 시 WARN, 기획서 내 화면 명세 누락 시 FAIL |

**PASS 기준**: 합산 70점 이상 + 즉시 FAIL 항목 없음

5. (선택) Advisor 통합 조언 — 3관점 리뷰에서 충돌이 2건 이상 발생하거나, 고위험 기획(1억 이상 예산·신규 시장 진입·아키텍처 대전환)일 때만:

   ```
   Agent(
     subagent_type="advisor-strategist",
     prompt="""
   3관점 리뷰 충돌 통합 조언 요청.

   기획서 핵심 (3~5줄):
   {기획 요약}

   CEO 리뷰 (1문단):
   {CEO 어노테이션 요약}

   Design 리뷰 (1문단):
   {Design 어노테이션 요약}

   Engineering 리뷰 (1문단):
   {Engineering 어노테이션 요약}

   충돌 리스트:
   - {충돌 1}
   - {충돌 2}

   질문:
   1. 이 기획의 전체 전략 방향에서 놓치기 쉬운 맹점 2개.
   2. 3관점 충돌 중 어느 쪽 의견에 더 가중치를 둬야 하는지 근거 제시.
   """
   )
   ```

   Advisor 응답을 별도 "## Advisor 통합 조언" 섹션으로 리뷰 리포트에 첨부.

**출력**:
- `.claude/state/AUTOPLAN_SYNTHESIS.md` (내부 작업 파일)
- `{기획서 경로}-autoplan-review.md` (최종 리뷰 리포트)

```
## Autoplan 3관점 리뷰 결과

### CEO Review
- [PASS] 비즈니스 모델: ...
- [WARN] ROI: ...

### Design Review
- [PASS] UX 플로우: ...
- [FAIL] 접근성: ...

### Engineering Review
- [PASS] 기술 실현성: ...
- [WARN] 일정: ...

### 충돌 사항
- CEO vs Eng: 기능 A의 우선순위 (비즈니스 가치 높음 vs 기술 복잡도 높음)

### Rubric 점수 (Lead Synthesizer 판정)
| 항목 | 가중치 | 점수 | 비고 |
|------|:------:|:----:|------|
| 비즈니스 타당성 | 30% | X/100 | ... |
| UX 실현성 | 25% | X/100 | ... |
| 기술 실현성 | 25% | X/100 | ... |
| 디자인 레퍼런스 완성도 | 20% | X/100 | ... |
| **가중 합산** | 100% | X.X/100 | |

### 판정: PASS / FAIL

### 개선 권고사항
- [위치]: [이유] → [방법]
```

---

### Wave 5: 독립 Evaluator Subagent (신규)

```
subagent_type: general-purpose
model: sonnet
```

> **핵심 원칙: Lead Synthesizer ≠ Evaluator**
> Lead가 너무 관대하게 보지 않았는가를 별도 에이전트가 재확인한다.
> Synthesizer의 의도나 판단 근거는 전달하지 않는다.

**입력**:
- `{기획서 경로}-autoplan-review.md` Read (Synthesizer 판정 결과)
- `.claude/state/AUTOPLAN_CEO.md` Read
- `.claude/state/AUTOPLAN_DESIGN.md` Read
- `.claude/state/AUTOPLAN_ENG.md` Read
- 기획서 원본 Read

**임무**: Lead Synthesizer 판정의 독립 검증

**검증 포인트**:
1. **Kill Signal 재확인**: 3관점 리뷰에서 Kill Signal이 있었는가? Lead가 이를 무시하거나 완화하지 않았는가?
2. **관대함 체크**: Synthesizer가 "나쁘지 않은데", "이 정도면 괜찮지 않나" 수준으로 PASS를 준 항목이 있는가?
3. **충돌 해소 검증**: 관점 간 충돌을 납득할 근거 없이 넘어갔는가?
4. **Rubric 점수 독자 산정**: Synthesizer 점수와 독자적으로 산정한 점수 간 차이가 10점 이상이면 ESCALATE
5. **디자인 레퍼런스 완성도**: 기획서에 구체적인 레퍼런스 URL이 포함되어 있는가? 화면 명세와 연결되어 있는가?

**Evaluator 판정 원칙:**
- Synthesizer PASS를 그대로 믿지 않는다 — 원본 리뷰 파일에서 직접 확인
- "Lead가 이미 검토했으니" → 금지. 독자적으로 판단한다
- 모든 피드백: **위치 + 이유 + 방법** 3요소 필수

**출력**: `{기획서 경로}-autoplan-review.md` 하단에 "## Wave 5 독립 Evaluator 검증" 섹션 추가

```
## Wave 5 독립 Evaluator 검증

### Lead Synthesizer 판정 검증
- Kill Signal 재확인: [OK / ESCALATE — 이유]
- 관대함 체크: [OK / 지적사항]
- 충돌 해소 검증: [OK / 불충분 — 이유]
- Rubric 독자 점수: X.X/100 (Lead: X.X/100, 차이: X점)

### 최종 판정: CONFIRM PASS / CONFIRM FAIL / ESCALATE

### 에스컬레이션 항목 (해당 시)
- [항목]: [이유] → [Human 확인 필요 사항]
```

**최종 판정 기준**:
- **CONFIRM PASS**: Rubric 차이 10점 미만, Kill Signal 없음, 충돌 해소 납득
- **CONFIRM FAIL**: Rubric 합산 70점 미만 또는 즉시 FAIL 항목 존재
- **ESCALATE**: Rubric 차이 10점 이상 또는 Lead가 Kill Signal을 무시한 정황

---

## 워크플로우 요약

1. Phase 3 기획서 + Competing Hypotheses 최종안 읽기
2. **Wave 1 CEO Subagent** → `.claude/state/AUTOPLAN_CEO.md` 저장
3. **Wave 2 Design Subagent** → CEO 파일 읽기 → `.claude/state/AUTOPLAN_DESIGN.md` 저장
4. **Wave 3 Engineering Subagent** → CEO+Design 파일 읽기 → `.claude/state/AUTOPLAN_ENG.md` 저장
5. **Wave 4 Lead Synthesizer** → 3파일 읽기 → 충돌 정리 + PASS/FAIL → `{기획서}-autoplan-review.md` 저장
6. **Wave 5 독립 Evaluator** → 리뷰 파일 + 원본 3파일 읽기 → Lead 판정 검증 → CONFIRM PASS/FAIL/ESCALATE
7. CONFIRM PASS → 완료
8. CONFIRM FAIL / ESCALATE → Human 에스컬레이션 + 충돌 리포트

## 순차 실행 이유

병렬이 아닌 순차인 이유:
1. CEO 리뷰 결과가 Design 리뷰의 우선순위를 결정
2. Design 리뷰 결과가 Engineering 리뷰의 범위를 결정
3. 순차적으로 쌓이는 어노테이션이 다음 리뷰어의 컨텍스트가 됨
4. 파일 기반 통신으로 각 Wave가 이전 Wave 결과를 완전히 흡수 후 판단
