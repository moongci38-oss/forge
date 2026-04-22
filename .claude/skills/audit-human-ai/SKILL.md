---
name: audit-human-ai
description: >
  Human-AI 경계 설계 감사. 5-Level Autonomy, 에스컬레이션 트리거 5유형, 게이트 설계,
  Override/Rubber-Stamp Rate를 기준으로 자율성-감독 최적 경계를 평가한다.
argument-hint: "[target: system|{project-name}]"
user-invocable: true
context: fork
model: sonnet
---

**역할**: 당신은 Human-AI 경계 설계를 5-Level Autonomy 기준으로 감사하는 자율성-감독 균형 전문가입니다.
**컨텍스트**: `/system-audit` 또는 `/audit-human-ai` 호출 시, ACHCE 축 5(Human-AI) 평가가 필요할 때 실행됩니다.
**출력**: 에스컬레이션 트리거·게이트 설계·Override Rate 항목별 점수 + 경계 설계 권고를 JSON 형식으로 반환합니다.

## Evaluator 핵심 원칙: 절대 관대하게 보지 마라
아래 생각이 들면 더 엄격하게 본다:
- "나쁘지 않은데..." → 감점
- "이 정도면 괜찮지 않나?" → 감점
- "전반적으로 잘했으니 이 부분은 넘어가자" → 금지
규칙:
- 한 항목이 좋아도 다른 항목 문제를 상쇄하지 않는다
- 모든 피드백은 위치 + 이유 + 방법 3요소를 포함한다

# Human-AI 경계 설계 감사

> ACHCE 프레임워크 축 5: Human-AI Escalation
> 참조: `docs/tech/2026-03-16-5-axis-ai-analysis-framework.md`

## 인자

- `$ARGUMENTS` = 감사 대상. 미입력 시 `system` (Forge+Forge Dev).

## 대상 경로 매핑

| target | 감사 경로 |
|--------|----------|
| `system` | `~/.claude/forge/rules/` + `.claude/rules/` + `.claude/agents/` + `.claude/skills/` |
| `{project-name}` | `forge-workspace.json`에 등록된 프로젝트 경로 (`.specify/`, `.claude/` 등) |

## 실행 흐름

### Step 1: target 파싱

`$ARGUMENTS`가 비어 있으면 `TARGET=system`. 아니면 첫 단어를 target으로 사용.

### Step 2: axis-human-ai 서브에이전트 스폰

아래 JSON 구조를 반환하도록 Subagent를 스폰한다 (model: sonnet):

**에이전트 분석 항목:**

1. **5-Level Autonomy 매핑**
   - 현재 시스템의 각 Phase/단계별 자율성 레벨 판정
   - L1(Operator) ~ L5(Observer) 중 실제 적용 레벨
   - "자율성은 능력과 별개의 설계 결정" 원칙 반영 여부

2. **게이트 커버리지** — 실측
   - Grep "\\[STOP\\]" in pipeline.md → Hard Stop 게이트 수
   - Grep "AUTO-PASS" in pipeline.md → Auto-Pass 게이트 수
   - Grep "Phase.*비가역|DB 마이그레이션|프로덕션|force" in pipeline.md/rules → 비가역 작업 수
   - 커버리지 = (STOP 게이트 / 비가역 작업) × 100
   - 기준: 100%

3. **에스컬레이션 트리거** 커버리지
   - 신뢰도 기반 / 가역성 기반 / 리스크 도메인 기반 / 이상 감지 기반 / 감정 기반
   - 가장 중요한 가역성 기반 에스컬레이션 구현 여부

4. **안티패턴** 탐지
   - Quasi-Automation: 형식적 HITL (실질 검토 없음) 패턴
   - False Agency: 재정의 권한 없는 감독 패턴
   - Rubber Stamping: 무비판적 승인 위험
   - Alert Fatigue: 과다 알림으로 둔감화 위험

5. **지표 추적** — 실측 (Design Review로 정직 표기)
   - Override Rate: ⚠️ 런타임 데이터 필요 — 현재 측정 불가. "미측정" 표기.
   - Rubber-Stamp Rate: ⚠️ 승인 이력 필요 — 현재 측정 불가. "미측정" 표기.
   - Gate Bypass Rate: Grep "no-verify|skip.*check" in git log → 우회 시도 수
   - 측정 불가 항목은 "Design Review" 라벨, 측정 가능 항목만 "Audit" 라벨

**반환 JSON 형식:**

```json
{
  "axis": "human-ai",
  "target": "{target}",
  "score": 0-100,
  "autonomy_mapping": [
    { "phase": "Phase 1", "level": "L2", "rationale": "..." }
  ],
  "gate_analysis": [
    { "gate": "[STOP] Phase 2 Spec", "type": "Hard Stop", "irreversible": true, "auto_pass_conditions": false }
  ],
  "escalation_triggers": { "confidence": true/false, "reversibility": true/false, "risk_domain": true/false, "anomaly": true/false, "emotion": false },
  "anti_patterns": [
    { "type": "Rubber Stamping|Quasi-Automation|False Agency|Alert Fatigue", "severity": "CRITICAL|HIGH|MEDIUM|LOW", "evidence": "..." }
  ],
  "metrics_tracking": { "override_rate": true/false, "rubber_stamp_rate": true/false, "gate_bypass_rate": true/false },
  "issues": [
    { "severity": "CRITICAL|HIGH|MEDIUM|LOW", "finding": "...", "evidence": "파일경로:라인", "recommendation": "..." }
  ],
  "strengths": ["강점1", "강점2"],
  "summary": "2-3문장 요약"
}
```

### Step 3: 보고서 작성

Subagent 결과를 기반으로 Lead가 보고서를 작성한다.

**저장 위치:** `docs/reviews/audit/{date}-audit-human-ai[-{target}].md`
(`target`이 `system`이면 suffix 생략)

**보고서 형식:**

```markdown
# Human-AI 경계 설계 감사 보고서

**대상**: {target} | **날짜**: {date} | **점수**: {score}/100

## Executive Summary

## 자율성 레벨 매핑

| Phase/단계 | 현재 레벨 | 적합 여부 |
|-----------|:--------:|:--------:|

## 게이트 설계 분석

| 게이트 | 유형 | 비가역성 체크 | Auto-Pass 조건 |
|--------|------|:-----------:|:--------------:|

## 에스컬레이션 트리거 커버리지

## 안티패턴 감지 결과

## 이슈 목록
### CRITICAL
### HIGH
### MEDIUM / LOW

## 권장 액션 (우선순위순)

## 참조
- docs/tech/2026-03-16-5-axis-ai-analysis-framework.md
```

### Step 4: Notion 페이지 생성

```json
{
  "parent": { "data_source_id": "713563f9-d523-4e90-8d6f-6b0d650628ad" },
  "pages": [{
    "properties": {
      "제목": "{date} Human-AI 감사 [{target}]",
      "축": "Human-AI",
      "대상": "{target}",
      "점수": "{score}",
      "date:날짜:start": "{date}",
      "상태": "완료",
      "CRITICAL": "{CRITICAL 이슈 수}",
      "HIGH": "{HIGH 이슈 수}",
      "보고서 경로": "docs/reviews/audit/{date}-audit-human-ai.md"
    },
    "content": "{보고서 전체 내용}"
  }]
}
```

> Notion MCP 미연결 시 경고 출력 후 스킵 (파이프라인 중단 안 함).


---

## 독립 Evaluator (하네스)

Human-AI 경계 감사 결과물 완성 후 독립 Evaluator Subagent가 품질을 2차 검증한다.

> **원칙**: Generator(감사 수행자) ≠ Evaluator. 감사자가 자신의 감사를 평가하면 자기평가 편향이 발생한다.

```python
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
당신은 audit-human-ai 결과물의 독립 품질 검증자입니다.

아래 기준으로 결과물을 검토하고 PASS 또는 FAIL을 판정하십시오.

**평가 기준 (4항목 모두 충족해야 PASS):**

1. **자율성 레벨 5단계 명시**
   - [위치] JSON `autonomy_mapping` 배열 또는 보고서 "자율성 레벨 매핑" 표
   - [이유] L1-L5 매핑 없이는 어떤 Phase가 과도하게 자율적이거나 과도하게 제한됐는지 판단 불가
   - [방법] 각 Phase/단계에 L1(Operator) ~ L5(Observer) 레벨이 명시되고 `rationale`이 규칙 파일 또는 pipeline.md의 실측 근거(파일경로:라인)를 포함하는지 확인

2. **Override Rate > 5% 측정 여부**
   - [위치] JSON `metrics_tracking.override_rate` 또는 보고서 "지표 추적" 섹션
   - [이유] Override Rate는 Human-AI 경계의 실효성을 나타내는 핵심 지표
   - [방법] `override_rate: true`이면 측정 방법(로그 경로)이 명시됐는지 확인; 런타임 데이터 필요 시 "미측정(런타임 이력 필요) — Override 로깅 메커니즘 부재" 이슈로 등록됐는지 확인

3. **Rubber-Stamp Rate < 20% 확인**
   - [위치] JSON `metrics_tracking.rubber_stamp_rate` 또는 JSON `anti_patterns` 배열의 `Rubber Stamping` 항목
   - [이유] 형식적 승인이 20%를 넘으면 HITL 설계 자체가 무의미해짐
   - [방법] `rubber_stamp_rate` 측정값 또는 "미측정" 명시 여부 확인; `anti_patterns`에서 `Rubber Stamping` 탐지 근거(어떤 패턴에서 감지됐는지)가 구체적으로 제시됐는지 검증

4. **에스컬레이션 경로 구체적 정의**
   - [위치] JSON `escalation_triggers` 객체 또는 보고서 "에스컬레이션 트리거 커버리지" 섹션
   - [이유] 에스컬레이션 경로가 추상적이면 실제 상황에서 작동하지 않음
   - [방법] `confidence`, `reversibility`, `risk_domain`, `anomaly`, `emotion` 5개 트리거 각각에 True/False 외에 실제 구현 위치(파일경로)가 명시됐는지 확인; 미구현 트리거는 이슈 목록에 등록됐는지 확인

**판정**: PASS(기준 4항목 모두 충족) / FAIL(1항목 이상 미충족)
**피드백 형식**: [파일명+섹션] — [이유] → [방법]
"""
)
```

피드백 루프:
- PASS → 파이프라인 계속 (Notion 등록)
- FAIL → 감사 재수행 후 1회 재실행. 2회 연속 FAIL 시 [STOP] Human 에스컬레이션
