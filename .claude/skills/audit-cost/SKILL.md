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
