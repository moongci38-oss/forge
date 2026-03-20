---
name: system-audit
description: >
  5축 통합 시스템 감사 (ACHCE). Agentic/Context/Harness/Cost/Human-AI 5개 축 에이전트를
  병렬 스폰하고 Lead가 종합 + 축간 트레이드오프 분석 + 통합 개선 로드맵을 생성한다.
argument-hint: "[target: system|{project-name}]"
user-invocable: true
---

# 5축 통합 시스템 감사 (ACHCE)

> ACHCE: Agentic · Context · Harness · Cost · Human-AI Escalation
> 참조: `forge-outputs/docs/tech/2026-03-16-5-axis-ai-analysis-framework.md`

## 인자

- `$ARGUMENTS` = 감사 대상. 미입력 시 `system` (Forge+Forge Dev).

## 대상 경로 매핑

| target | 감사 경로 |
|--------|----------|
| `system` | `~/.claude/forge/` + `.claude/rules/` + `.claude/skills/` + `.claude/agents/` |
| `{project-name}` | `forge-workspace.json`에 등록된 프로젝트 경로 (`.specify/`, `apps/`, `.claude/` 등) |

## 실행 흐름

### Step 0: target 파싱

`$ARGUMENTS`가 비어 있으면 `TARGET=system`. 아니면 첫 단어를 target으로 사용.

감사 시작 전 아래 메시지를 출력한다:
```
🔍 5축 통합 감사 시작: {target}
Wave 1 — 5개 축 에이전트 병렬 스폰 중...
```

---

### Wave 1: 5개 축 에이전트 병렬 스폰 (단일 메시지, 동시 실행)

아래 5개 Agent를 **한 번에** 병렬로 스폰한다. 각 에이전트는 독립적으로 실행되며 JSON만 반환한다.

**파일 소유권 선언:**
- 5개 에이전트 모두 읽기 전용 (대상 경로 분석만)
- 보고서 쓰기는 Wave 3에서 Lead만 수행

**에이전트 1 — axis-agentic (model: sonnet)**

프롬프트: `{target} 경로의 에이전틱 역량을 분석한다. Sema4.ai L0-L5 성숙도, Anthropic Composable Patterns 수준, CLEAR 5차원 커버리지, 멀티에이전트 토폴로지를 점검한다. 아래 JSON 형식으로만 반환한다.`

반환 JSON: `{ "axis": "agentic", "score": 0-100, "maturity_level": "L?", "composable_pattern": "...", "issues": [...], "strengths": [...], "summary": "..." }`

**에이전트 2 — axis-context (model: sonnet)**

프롬프트: `{target} 경로의 컨텍스트 엔지니어링을 분석한다. 7-Layer Architecture 커버리지, 5가지 컨텍스트 실패 패턴(Poisoning/Distraction/Confusion/Clash/Rot), Progressive Disclosure 적용, 메모리 시스템, 토큰 효율을 점검한다. 아래 JSON 형식으로만 반환한다.`

반환 JSON: `{ "axis": "context", "score": 0-100, "layer_coverage": {...}, "failure_patterns": [...], "progressive_disclosure": true/false, "issues": [...], "strengths": [...], "summary": "..." }`

**에이전트 3 — axis-harness (model: sonnet)**

프롬프트: `{target} 경로의 AI 하네스를 분석한다. Check Chain(3→3.5→3.7), 3-Layer 테스트 아키텍처, OWASP Agentic Top 10 커버리지(ASI01-ASI10), 가드레일 5 Rail Types, OTel GenAI 옵저버빌리티를 점검한다. 아래 JSON 형식으로만 반환한다.`

반환 JSON: `{ "axis": "harness", "score": 0-100, "check_chain": {...}, "test_layers": {...}, "owasp_coverage": {...}, "issues": [...], "strengths": [...], "summary": "..." }`

**에이전트 4 — axis-cost (model: haiku)**

프롬프트: `{target} 경로의 비용 효율을 분석한다. 모델 라우팅 3계층(Opus/Sonnet/Haiku) 문서화, 컨텍스트 절약 패턴, MCP→CLI 전환 현황, 비용 최적화 패턴(캐싱/라우팅/배치/길이제어) 적용 여부, 낭비 패턴을 점검한다. 아래 JSON 형식으로만 반환한다.`

반환 JSON: `{ "axis": "cost", "score": 0-100, "model_routing": {...}, "context_savings": {...}, "optimization_gaps": [...], "waste_patterns": [...], "issues": [...], "strengths": [...], "summary": "..." }`

**에이전트 5 — axis-human-ai (model: sonnet)**

프롬프트: `{target} 경로의 Human-AI 경계 설계를 분석한다. 5-Level Autonomy 매핑, [STOP]/[AUTO-PASS] 게이트 적절성, 에스컬레이션 트리거 5유형 커버리지, 안티패턴(Quasi-Automation/Rubber Stamping/Alert Fatigue), Sterz 4조건, Override Rate 추적을 점검한다. 아래 JSON 형식으로만 반환한다.`

반환 JSON: `{ "axis": "human-ai", "score": 0-100, "autonomy_mapping": [...], "gate_analysis": [...], "anti_patterns": [...], "sterz_conditions": {...}, "issues": [...], "strengths": [...], "summary": "..." }`

---

### Wave 2: Lead 종합 (5개 결과 의존)

5개 에이전트 결과를 모두 수신한 후 Lead가 아래를 수행한다:

**2-1. 전체 점수 산출**
- 각 축 점수 가중 평균 (균등 가중치 20%씩)
- 전체 ACHCE 점수 = (A + C + H + Co + E) / 5

**2-2. 축간 트레이드오프 식별**
주요 트레이드오프 패턴:
- Cost vs Harness: 비용 절감(Haiku 사용) ↔ 검증 품질
- Agentic vs Human-AI: 자율성 증가 ↔ 감독 필요성
- Context vs Cost: 컨텍스트 풍부 ↔ 토큰 비용
- Harness vs Agentic: 가드레일 강화 ↔ 에이전트 유연성
- Human-AI vs Cost: 게이트 추가 ↔ 파이프라인 속도

**2-3. 통합 이슈 목록 정렬**
- 5개 축의 모든 이슈를 CRITICAL → HIGH → MEDIUM → LOW 순으로 통합
- 여러 축에 걸친 이슈는 cross-axis 태그 부여
- 중복 이슈 제거 (동일 파일/설정의 이슈는 하나로 합산)

---

### Wave 3: 통합 보고서 작성

**저장 위치:** `docs/reviews/audit/{date}-system-audit[-{target}].md`
(`target`이 `system`이면 suffix 생략)

**보고서 형식:**

```markdown
# ACHCE 5축 통합 시스템 감사 보고서

**대상**: {target} | **날짜**: {date}

## Executive Summary

**전체 ACHCE 점수: {전체점수}/100**

| 축 | 점수 | 등급 | 핵심 발견 |
|----|:----:|:----:|---------|
| Agentic | {A}/100 | ⭐~⭐⭐⭐⭐⭐ | |
| Context | {C}/100 | | |
| Harness | {H}/100 | | |
| Cost | {Co}/100 | | |
| Human-AI | {E}/100 | | |

> 등급 기준: 90+ ⭐⭐⭐⭐⭐ / 75+ ⭐⭐⭐⭐ / 60+ ⭐⭐⭐ / 45+ ⭐⭐ / <45 ⭐

## 1. 축별 감사 결과 요약

### 1.1 Agentic (자율성·도구·멀티에이전트)
{axis-agentic summary + top 2 issues}

### 1.2 Context (컨텍스트 엔지니어링)
{axis-context summary + top 2 issues}

### 1.3 Harness (측정·제어·보안)
{axis-harness summary + top 2 issues}

### 1.4 Cost (비용 효율)
{axis-cost summary + top 2 issues}

### 1.5 Human-AI (경계 설계)
{axis-human-ai summary + top 2 issues}

## 2. 축간 트레이드오프 분석

| 트레이드오프 | 현재 균형 | 권장 방향 |
|------------|:--------:|---------|
| Cost vs Harness | | |
| Agentic vs Human-AI | | |
| Context vs Cost | | |

## 3. 통합 이슈 목록

### CRITICAL (즉시 대응)
### HIGH (이번 주)
### MEDIUM (이번 달)
### LOW (모니터링)

## 4. 강점 요약

## 5. 통합 개선 로드맵

### P0 — 즉시 (이번 주)
### P1 — 단기 (이번 달)
### P2 — 중기 (다음 분기)

## 6. 재감사 권장 시점

- CRITICAL 이슈 해결 후 즉시
- 정기 감사: 분기 1회 권장

## 참조
- forge-outputs/docs/tech/2026-03-16-5-axis-ai-analysis-framework.md
```

---

### Wave 4: Notion 페이지 생성

보고서 작성 완료 후 Notion에 전체 내용을 기록한다.

1. `Read("docs/reviews/audit/{date}-system-audit.md")` → 전체 내용 로드
2. `mcp__notion__notion-create-pages` 호출:

```json
{
  "parent": { "data_source_id": "713563f9-d523-4e90-8d6f-6b0d650628ad" },
  "pages": [{
    "properties": {
      "제목": "{date} ACHCE 5축 통합 감사 [{target}]",
      "축": "통합",
      "대상": "{target}",
      "전체점수": "{전체점수}",
      "Agentic점수": "{A}",
      "Context점수": "{C}",
      "Harness점수": "{H}",
      "Cost점수": "{Co}",
      "HumanAI점수": "{E}",
      "date:날짜:start": "{date}",
      "상태": "완료",
      "CRITICAL": "{전체 CRITICAL 이슈 수}",
      "HIGH": "{전체 HIGH 이슈 수}",
      "보고서 경로": "docs/reviews/audit/{date}-system-audit.md"
    },
    "content": "{보고서 전체 내용}"
  }]
}
```

> Notion MCP 미연결 시 경고 출력 후 스킵 (파이프라인 중단 안 함).

---

## 완료 보고

모든 Wave 완료 후 아래 형식으로 결과를 요약 출력한다:

```
✅ ACHCE 5축 통합 감사 완료

전체 점수: {전체점수}/100
- Agentic:  {A}/100
- Context:  {C}/100
- Harness:  {H}/100
- Cost:     {Co}/100
- Human-AI: {E}/100

이슈: CRITICAL {n}건 / HIGH {n}건 / MEDIUM {n}건

보고서: docs/reviews/audit/{date}-system-audit.md
```
