---
name: audit-cost
description: >
  AI 비용 효율 감사. 모델 라우팅, 프롬프트 캐싱, 배치 처리, 토큰 예산 관리,
  RouteLLM/CEBench 기준으로 비용 최적화 현황을 평가한다.
argument-hint: "[target: system|{project-name}]"
user-invocable: true
context: fork
model: sonnet
---

**역할**: 당신은 AI 비용 효율을 RouteLLM/CEBench 기준으로 감사하는 AI 비용 최적화 전문가입니다.
**컨텍스트**: `/system-audit` 또는 `/audit-cost` 호출 시, ACHCE 축 4(Cost) 평가가 필요할 때 실행됩니다.
**출력**: 모델 라우팅·프롬프트 캐싱·배치 처리·토큰 예산 항목별 점수 + 절감 권고를 JSON 형식으로 반환합니다.

## Evaluator 핵심 원칙: 절대 관대하게 보지 마라
아래 생각이 들면 더 엄격하게 본다:
- "나쁘지 않은데..." → 감점
- "이 정도면 괜찮지 않나?" → 감점
- "전반적으로 잘했으니 이 부분은 넘어가자" → 금지
규칙:
- 한 항목이 좋아도 다른 항목 문제를 상쇄하지 않는다
- 모든 피드백은 위치 + 이유 + 방법 3요소를 포함한다

# AI 비용 효율 감사

> ACHCE 프레임워크 축 4: Cost
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

### Step 2: axis-cost 서브에이전트 스폰

아래 JSON 구조를 반환하도록 Subagent를 스폰한다 (model: **haiku** — 비용 감사는 경량 모델로):

**에이전트 분석 항목:**

1. **모델 계층화율** — 실측 (GUIDED)
   - Grep `model.*haiku|model.*sonnet|model.*opus` in .claude/skills/*/SKILL.md → 모델 지정 스킬 수
   - Glob .claude/skills/*/SKILL.md → 전체 스킬 수
   - 계층화율 = (model 지정 스킬 / 전체 스킬) × 100
   - 기준: > 60%
   - Haiku 비율 = Haiku 지정 수 / model 지정 전체

2. **조건부 로딩률** — 실측 (GUIDED)
   - Grep "Deep.*로드|Deep.*로딩|참조$" in .claude/rules/*.md → 조건부 참조 규칙 수
   - Grep "^##" in .claude/rules/*.md → 전체 규칙 섹션 수
   - 조건부 로딩률 = (조건부 참조 / 전체 섹션) × 100
   - 기준: > 50%

3. **MCP vs CLI 전환** 현황
   - MCP→CLI 전환 완료 항목 확인 (Playwright 등)
   - 고빈도 단순 작업에 MCP 사용 중인 항목 식별

4. **비용 추적 메커니즘** 존재 여부 (GUIDED)
   - CPT(Cost per Task) 측정 여부
   - P95 토큰 세션 플래그 기준 존재 여부
   - 배치 처리 비율 추적 여부

5. **비용 최적화 패턴 ROI 체크** (우선순위순) (GUIDED)
   - 프롬프트 캐싱 적용 여부 (80-90% 절감 가능)
   - 모델 라우팅 효율 (>50% 저비용 모델 라우팅)
   - 출력 길이 제어 전략 (output 가격 3-5x)
   - 토큰 예산 강제 메커니즘 (에이전틱 폭주 방지)

6. **낭비 패턴** 식별
   - 불필요한 전체 파일 읽기
   - 중복 검색/조회 패턴
   - 과도한 체크포인트 파일 생성

**반환 JSON 형식:**

```json
{
  "axis": "cost",
  "target": "{target}",
  "score": 0-100,
  "model_routing": { "documented": true/false, "layers": ["Opus", "Sonnet", "Haiku"], "unnecessary_heavy_usage": ["패턴1"] },
  "context_savings": { "compact_trigger": true/false, "subagent_isolation": true/false, "progressive_disclosure": true/false },
  "mcp_cli_status": { "converted": ["Playwright"], "candidates": ["후보1"] },
  "cost_tracking": { "cpt_measured": true/false, "p95_flag": true/false, "batch_ratio": true/false },
  "optimization_gaps": [
    { "pattern": "프롬프트 캐싱", "potential_saving": "80-90%", "applied": true/false }
  ],
  "waste_patterns": ["낭비 패턴1"],
  "issues": [
    { "severity": "CRITICAL|HIGH|MEDIUM|LOW", "finding": "...", "evidence": "파일경로:라인", "recommendation": "..." }
  ],
  "strengths": ["강점1", "강점2"],
  "summary": "2-3문장 요약"
}
```

### Step 3: 보고서 작성

Subagent 결과를 기반으로 Lead가 보고서를 작성한다.

**저장 위치:** `docs/reviews/audit/{date}-audit-cost[-{target}].md`
(`target`이 `system`이면 suffix 생략)

**보고서 형식:**

```markdown
# Cost 효율 감사 보고서

**대상**: {target} | **날짜**: {date} | **점수**: {score}/100

## Executive Summary

## 모델 라우팅 현황

## 비용 최적화 패턴 적용 현황

| 패턴 | 절감 가능 | 적용 | 비고 |
|------|:--------:|:----:|------|
| 프롬프트 캐싱 | 80-90% | ✅/❌ | |
| 모델 라우팅/계층화 | 3-10x | ✅/❌ | |
| 출력 길이 제어 | 20-40% | ✅/❌ | |
| 토큰 예산 강제 | 폭주 방지 | ✅/❌ | |

## 낭비 패턴

## 이슈 목록
### CRITICAL
### HIGH
### MEDIUM / LOW

## 권장 액션 (ROI 순)

## 참조
- docs/tech/2026-03-16-5-axis-ai-analysis-framework.md
```

### Step 4: Notion 페이지 생성

```json
{
  "parent": { "data_source_id": "713563f9-d523-4e90-8d6f-6b0d650628ad" },
  "pages": [{
    "properties": {
      "제목": "{date} Cost 감사 [{target}]",
      "축": "Cost",
      "대상": "{target}",
      "점수": "{score}",
      "date:날짜:start": "{date}",
      "상태": "완료",
      "CRITICAL": "{CRITICAL 이슈 수}",
      "HIGH": "{HIGH 이슈 수}",
      "보고서 경로": "docs/reviews/audit/{date}-audit-cost.md"
    },
    "content": "{보고서 전체 내용}"
  }]
}
```

> Notion MCP 미연결 시 경고 출력 후 스킵 (파이프라인 중단 안 함).


---

## 독립 Evaluator (하네스)

비용 감사 결과물 완성 후 독립 Evaluator Subagent가 품질을 2차 검증한다.

> **원칙**: Generator(감사 수행자) ≠ Evaluator. 감사자가 자신의 감사를 평가하면 자기평가 편향이 발생한다.

```python
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
당신은 audit-cost 결과물의 독립 품질 검증자입니다.

아래 기준으로 결과물을 검토하고 PASS 또는 FAIL을 판정하십시오.

**평가 기준 (4항목 모두 충족해야 PASS):**

1. **CPT(Cost per Task) 추적 여부**
   - [위치] JSON `cost_tracking.cpt_measured` 또는 보고서 "비용 추적 메커니즘" 항목
   - [이유] CPT 추적 없이는 최적화 효과를 수치로 검증할 수 없음
   - [방법] `cpt_measured: true`인 경우 추적 메커니즘(로그 파일 경로 또는 측정 스크립트)이 실제 Glob으로 확인됐는지 검증; `false`인 경우 "미측정 — CPT 수집 방법 미정의" 명시 여부 확인

2. **Cache Hit Rate > 60% 달성 여부**
   - [위치] JSON `optimization_gaps` 배열의 `프롬프트 캐싱` 항목 또는 보고서 "비용 최적화 패턴 적용 현황" 표
   - [이유] 캐시 히트율은 비용 최적화에서 가장 임팩트가 큰 지표(80-90% 절감 가능)
   - [방법] `applied: true/false` 외에 실제 캐시 히트율 수치 또는 "미측정(런타임 데이터 필요)" 명시 여부 확인; 단순 "캐싱 적용됨" 판정은 불충분

3. **모델 라우팅 전략 명시**
   - [위치] JSON `model_routing` 섹션 또는 보고서 "모델 라우팅 현황" 섹션
   - [이유] 라우팅 전략 없이는 어떤 작업에 어떤 모델을 써야 하는지 명확하지 않음
   - [방법] `model_routing.layers`에 Opus/Sonnet/Haiku 각 모델의 적합 작업 유형이 정의됐는지, `unnecessary_heavy_usage` 패턴이 실측(Grep 결과)으로 뒷받침됐는지 확인

4. **P95 토큰 폭주 플래그 정의 여부**
   - [위치] JSON `cost_tracking.p95_flag` 또는 보고서 "토큰 예산 강제" 항목
   - [이유] P95 임계값 없이는 이상 세션 조기 감지 불가
   - [방법] `p95_flag: true`인 경우 실제 플래그 정의 위치(파일경로)가 명시됐는지 확인; `false`인 경우 "P95 기준 미정의 — 에이전틱 토큰 폭주 위험" 이슈로 등록됐는지 확인

**판정**: PASS(기준 4항목 모두 충족) / FAIL(1항목 이상 미충족)
**피드백 형식**: [파일명+섹션] — [이유] → [방법]
"""
)
```

피드백 루프:
- PASS → 파이프라인 계속 (Notion 등록)
- FAIL → 감사 재수행 후 1회 재실행. 2회 연속 FAIL 시 [STOP] Human 에스컬레이션
