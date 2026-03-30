---
name: system-audit
description: >
  5축 통합 시스템 감사 (ACHCE). Agentic/Context/Harness/Cost/Human-AI 5개 축 에이전트를
  병렬 스폰하고 Lead가 종합 + 축간 트레이드오프 분석 + 통합 개선 로드맵을 생성한다.
argument-hint: "[target: system|{project-name}]"
user-invocable: true
context: fork
model: opus
---

**역할**: 당신은 ACHCE 5축 에이전트를 병렬 스폰하여 AI 시스템을 통합 감사하는 수석 시스템 감사 오케스트레이터입니다.
**컨텍스트**: `/system-audit` 호출 또는 종합 AI 시스템 점검이 필요할 때 실행됩니다.
**출력**: 5축 병렬 감사 결과 + 축간 트레이드오프 분석 + 통합 개선 로드맵을 마크다운 보고서로 반환합니다.

# 5축 통합 시스템 감사 (ACHCE)

> ACHCE: Agentic · Context · Harness · Cost · Human-AI Escalation
> 참조: `~/forge-outputs/docs/tech/2026-03-16-5-axis-ai-analysis-framework.md`

## 감사 유형 정의

| 유형 | 방법 | 신뢰도 |
|------|------|:------:|
| **실측 (Audit)** | Glob/Grep/wc/Read로 파일 직접 탐색하여 카운트 | 높음 |
| **추정 (Estimate)** | 바이트→토큰 변환, 패턴 매칭 기반 계산 | 중간 |
| **설계 검토 (Design Review)** | 코드/규칙 구조 분석, LLM 판단 | 낮음 |
| **미측정 (N/A)** | 런타임 로그/이력 데이터 필요, 현재 수집 불가 | - |

> 모든 지표에 유형을 명시한다. "실측"이 아닌 항목은 과신하지 않는다.

## 항목별 강제 수준

| 수준 | 의미 | 점수 반영 |
|------|------|:--------:|
| **ENFORCED** | Hook/스크립트가 `exit 2`로 위반 차단 | 100% 반영 |
| **GUIDED** | 규칙 존재, AI가 자발적 준수 | 70% 반영 |
| **PAPER** | 감사에만 존재, 운영 미적용 | 점수 제외 (0%) |

> PAPER 항목은 보고서에 "미적용" 표기만 하고 점수에 포함하지 않는다.

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

프롬프트: `{target} 경로의 에이전틱 역량을 분석한다. 반드시 `shared/docs/2026-03-30-four-engineering-disciplines.md`의 §4 Agentic Engineering 섹션을 Read한 후, 정의서 기법 목록을 기준으로 체크하라. 정의서에 없는 항목은 감사하지 않는다. Anthropic Composable Patterns 수준, ACI 설계, Agent Evals, Multi-Agent Coordination, Memory Architecture, AgentOps를 점검한다. 반드시 Glob/Grep/Read 도구로 실제 파일을 탐색하여 정량 지표를 측정하라. 주관적 판단 금지 — 모든 점수는 실측 데이터 기반이어야 한다. 측정 불가 항목은 "N/A (런타임 데이터 필요)" 로 표기하라. 아래 JSON 형식으로만 반환한다.`

반환 JSON: `{ "axis": "agentic", "score": 0-100, "composable_pattern": "...", "issues": [...], "strengths": [...], "summary": "..." }`

**에이전트 2 — axis-context (model: sonnet)**

프롬프트: `{target} 경로의 컨텍스트 엔지니어링을 분석한다. 반드시 `shared/docs/2026-03-30-four-engineering-disciplines.md`의 §2 Context Engineering 섹션을 Read한 후, 정의서 기법 목록을 기준으로 체크하라. 정의서에 없는 항목은 감사하지 않는다. System Prompt Design(§2-1), Short-Term Memory(§2-2), Long-Term Memory(§2-3), RAG(§2-4), Tool Definition(§2-5), Context Compaction(§2-6), Sub-Agent Architecture(§2-7), Progressive Disclosure(§2-8), Structured Note-Taking(§2-9) 9개 기법과 프롬프트 구조 3요소 포함률을 점검한다. 반드시 Glob/Grep/Read 도구로 실제 파일을 탐색하여 정량 지표를 측정하라. 주관적 판단 금지 — 모든 점수는 실측 데이터 기반이어야 한다. 측정 불가 항목은 "N/A (런타임 데이터 필요)" 로 표기하라. 아래 JSON 형식으로만 반환한다.`

반환 JSON: `{ "axis": "context", "score": 0-100, "context_checklist": {...}, "failure_patterns": [...], "progressive_disclosure": true/false, "issues": [...], "strengths": [...], "summary": "..." }`

**에이전트 3 — axis-harness (model: sonnet)**

프롬프트: `{target} 경로의 AI 하네스를 분석한다. 반드시 `shared/docs/2026-03-30-four-engineering-disciplines.md`의 §3 Harness Engineering 섹션을 Read한 후, 정의서 기법 목록을 기준으로 체크하라. 정의서에 없는 항목은 감사하지 않는다. Check Chain(§3-1), Guardrails 5 Rail Types(§3-2), OWASP Agentic Top 10(§3-3), Hooks(§3-4), AI Evals(§3-5), Observability(§3-6), Rollback(§3-7), Maintenance Agents(§3-8) 8개 구성요소를 점검한다. 반드시 Glob/Grep/Read 도구로 실제 파일을 탐색하여 정량 지표를 측정하라. 주관적 판단 금지 — 모든 점수는 실측 데이터 기반이어야 한다. 측정 불가 항목은 "N/A (런타임 데이터 필요)" 로 표기하라. 아래 JSON 형식으로만 반환한다.`

반환 JSON: `{ "axis": "harness", "score": 0-100, "check_chain": {...}, "owasp_coverage": {...}, "issues": [...], "strengths": [...], "summary": "..." }`

**에이전트 4 — axis-cost (model: haiku)**

프롬프트: `{target} 경로의 비용 효율을 분석한다. 모델 라우팅 3계층(Opus/Sonnet/Haiku) 문서화, 컨텍스트 절약 패턴, MCP→CLI 전환 현황, 비용 최적화 패턴(캐싱/라우팅/배치/길이제어) 적용 여부, 낭비 패턴을 점검한다. 반드시 Glob/Grep/Read 도구로 실제 파일을 탐색하여 정량 지표를 측정하라. 주관적 판단 금지 — 모든 점수는 실측 데이터 기반이어야 한다. 측정 불가 항목은 "N/A (런타임 데이터 필요)" 로 표기하라. 아래 JSON 형식으로만 반환한다.`

반환 JSON: `{ "axis": "cost", "score": 0-100, "model_routing": {...}, "context_savings": {...}, "optimization_gaps": [...], "waste_patterns": [...], "issues": [...], "strengths": [...], "summary": "..." }`

**에이전트 5 — axis-human-ai (model: sonnet)**

프롬프트: `{target} 경로의 Human-AI 경계 설계를 분석한다. 5-Level Autonomy 매핑, [STOP]/[AUTO-PASS] 게이트 적절성, 에스컬레이션 트리거 5유형 커버리지, 안티패턴(Quasi-Automation/Rubber Stamping/Alert Fatigue), Override Rate 추적을 점검한다. 반드시 Glob/Grep/Read 도구로 실제 파일을 탐색하여 정량 지표를 측정하라. 주관적 판단 금지 — 모든 점수는 실측 데이터 기반이어야 한다. 측정 불가 항목은 "N/A (런타임 데이터 필요)" 로 표기하라. 아래 JSON 형식으로만 반환한다.`

반환 JSON: `{ "axis": "human-ai", "score": 0-100, "autonomy_mapping": [...], "gate_analysis": [...], "anti_patterns": [...], "issues": [...], "strengths": [...], "summary": "..." }`

---

### Wave 2: Lead 종합 (5개 결과 의존)

5개 에이전트 결과를 모두 수신한 후 Lead가 아래를 수행한다:

**2-1. 정량 점수 산출 (Weighted Scoring)**

각 축 에이전트는 체크리스트 항목별 0-3점 루브릭으로 채점한다:
- 0 = 미구현 (Not implemented)
- 1 = 부분 구현 (Partial — 문서만 있거나 일부만 적용)
- 2 = 구현됨 (Implemented — 동작하나 측정/개선 루프 없음)
- 3 = 성숙 (Mature — 동작 + 측정 + 지속 개선 루프)

축 점수 = (획득 점수 합 / 최대 점수 합) × 100

**가중치 (시스템 상태에 따라 조정):**

| 축 | 기본 가중치 | 초기 단계 | 운영 단계 | 스케일링 단계 |
|----|:--------:|:-------:|:-------:|:---------:|
| Agentic | 20% | 25% | 20% | 15% |
| Context | 20% | 25% | 20% | 15% |
| Harness | 20% | 15% | 25% | 25% |
| Cost | 20% | 10% | 15% | 25% |
| Human-AI | 20% | 25% | 20% | 20% |

현재 시스템 단계를 target 분석에서 자동 판별한다:
- 초기: 스킬 < 20개 또는 규칙 < 5개
- 운영: 스킬 20-50개 + 규칙 5-15개 + 프로덕션 배포 있음
- 스케일링: 멀티 프로젝트 + 팀 2명+ 또는 월 비용 $500+

전체 점수 = Σ(축 점수 × 가중치)

**2-2. 정량 지표 실측 (Quantitative Measurement)**

각 축 에이전트는 체크리스트 외에 아래 정량 지표를 실제 측정하여 보고한다:

측정 유형 범례:

| 측정 유형 | 의미 |
|----------|------|
| 실측 | Glob/Grep/wc로 직접 카운트 |
| 추정 | 바이트→토큰 변환 등 계산 |
| 미측정 | 런타임 로그 필요, 현재 불가 |

| 축 | 측정 지표 | 측정 방법 | 기준값 | 측정 유형 |
|----|---------|---------|-------|---------|
| Agentic | 도구 커버리지율 | (사용된 도구 / 등록된 도구) × 100 | > 60% | 실측 |
| Context | 세션 시작 토큰 | rules + CLAUDE.md + MEMORY.md 합산 (wc -c ÷ 4) | < 12,000 | 추정 |
| Context | MEMORY.md 항목 수 | grep "^## " 카운트 | < 30 | 실측 |
| Context | 규칙 중복률 | (중복 규칙 / 전체 규칙) × 100 | < 10% | 추정 |
| Harness | Hook 커버리지 | (Hook 보호 이벤트 / 위험 이벤트 유형) × 100 | > 70% | 실측 |
| Harness | OWASP 커버리지 | (대응 ASI / 10) × 100 | > 50% | 실측 |
| Cost | 모델 계층화율 | (Haiku+Sonnet 작업 / 전체) × 100 | > 60% | 실측 |
| Cost | 조건부 로딩률 | (on-demand 규칙 / 전체 규칙) × 100 | > 50% | 실측 |
| Context | 프롬프트 구조 포함률 | (3요소 포함 스킬 / 프롬프트 보유 스킬) × 100 | > 70% | 실측 |
| Human-AI | 게이트 커버리지 | (STOP 게이트 작업 / 비가역 작업) × 100 | 100% | 실측 |

**2-3. 트렌드 비교 (Delta Analysis)**

이전 감사 보고서가 존재하면 (`docs/reviews/audit/` 폴더) 최신 보고서와 비교:
- 각 축 점수 변화량 (Δ)
- 이슈 해소율 = (이전 이슈 중 해결된 수 / 이전 전체 이슈) × 100
- 신규 이슈 발생 수
- 정량 지표 변화 방향 (↑↓→)

트렌드 테이블:
```
| 축 | 이전 | 현재 | Δ | 방향 |
|----|:----:|:----:|:--:|:---:|
| Agentic | 72 | 78 | +6 | ↑ |
```

**2-4. 축간 트레이드오프 식별**
주요 트레이드오프 패턴:
- Cost vs Harness: 비용 절감(Haiku 사용) ↔ 검증 품질
- Agentic vs Human-AI: 자율성 증가 ↔ 감독 필요성
- Context vs Cost: 컨텍스트 풍부 ↔ 토큰 비용
- Harness vs Agentic: 가드레일 강화 ↔ 에이전트 유연성
- Human-AI vs Cost: 게이트 추가 ↔ 파이프라인 속도

**2-5. 통합 이슈 목록 정렬**
- 5개 축의 모든 이슈를 CRITICAL → HIGH → MEDIUM → LOW 순으로 통합
- 여러 축에 걸친 이슈는 cross-axis 태그 부여
- 중복 이슈 제거 (동일 파일/설정의 이슈는 하나로 합산)
- 각 이슈에 **영향도 점수** 부여: (심각도 × 영향 범위) — CRITICAL=4, HIGH=3, MEDIUM=2, LOW=1

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

## 3. 정량 지표 대시보드

| 축 | 지표 | 측정값 | 기준값 | 측정 유형 | 판정 |
|----|------|:-----:|:-----:|:--------:|:---:|
| Agentic | 도구 커버리지율 | | > 60% | 실측 | |
| Context | 세션 시작 토큰 | | < 12,000 | 추정 | |
| Context | MEMORY 항목 수 | | < 30 | 실측 | |
| Context | 규칙 중복률 | | < 10% | 추정 | |
| Harness | Hook 커버리지 | | > 70% | 실측 | |
| Harness | OWASP 커버리지 | | > 50% | 실측 | |
| Cost | 모델 계층화율 | | > 60% | 실측 | |
| Cost | 조건부 로딩률 | | > 50% | 실측 | |
| Human-AI | 게이트 커버리지 | | 100% | 실측 | |

## 4. 트렌드 비교 (이전 감사 대비)

| 축 | 이전 | 현재 | Δ | 방향 |
|----|:----:|:----:|:--:|:---:|

> 이전 감사 없으면 "첫 감사 — 베이스라인 설정" 표기

**이슈 해소율**: N/A (또는 이전 이슈 대비 해결률)

## 5. 통합 이슈 목록

### CRITICAL (즉시 대응)
### HIGH (이번 주)
### MEDIUM (이번 달)
### LOW (모니터링)

## 6. 강점 요약

## 7. 통합 개선 로드맵

### P0 — 즉시 (이번 주)
### P1 — 단기 (이번 달)
### P2 — 중기 (다음 분기)

## 6. 재감사 권장 시점

- CRITICAL 이슈 해결 후 즉시
- 정기 감사: 분기 1회 권장

## 참조
- ~/forge-outputs/docs/tech/2026-03-16-5-axis-ai-analysis-framework.md
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
