---
name: audit-human-ai
description: >
  Human-AI 경계 설계 감사. 5-Level Autonomy, 에스컬레이션 트리거 5유형, 게이트 설계 8패턴,
  Sterz 4조건, Override/Rubber-Stamp Rate를 기준으로 자율성-감독 최적 경계를 평가한다.
argument-hint: "[target: system|{project-name}]"
user-invocable: true
context: fork
---

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

2. **[STOP]/[AUTO-PASS] 게이트 설계** 분석
   - 각 게이트의 유형 분류 (Hard Stop / Conditional Auto-Pass / Confidence-Based 등)
   - 비가역적 행동에 Hard Stop 존재 여부 확인
   - Auto-Pass 6조건 적용 여부 (가역성+이전승인+외부영향없음+신뢰도+규제+분포)
   - 게이트 과잉(Alert Fatigue) 위험 식별

3. **에스컬레이션 트리거** 커버리지
   - 신뢰도 기반 / 가역성 기반 / 리스크 도메인 기반 / 이상 감지 기반 / 감정 기반
   - 가장 중요한 가역성 기반 에스컬레이션 구현 여부

4. **안티패턴** 탐지
   - Quasi-Automation: 형식적 HITL (실질 검토 없음) 패턴
   - False Agency: 재정의 권한 없는 감독 패턴
   - Rubber Stamping: 무비판적 승인 위험
   - Alert Fatigue: 과다 알림으로 둔감화 위험

5. **Sterz 4조건** 충족 여부
   - 개입/재정의 가능 여부
   - 관련 정보 접근 가능 여부
   - 실제 행동 권한 존재 여부
   - 정렬된 의도 확인

6. **지표 추적** 현황
   - Override Rate 추적 여부 (너무 낮으면 rubber-stamp 위험)
   - Rubber-Stamp Rate 기준 (< 20% 목표) 문서화 여부
   - Gate Bypass Rate 모니터링 여부

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
  "sterz_conditions": { "intervene": true/false, "information_access": true/false, "action_authority": true/false, "aligned_intent": true/false },
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

## Sterz 4조건 충족 여부

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
