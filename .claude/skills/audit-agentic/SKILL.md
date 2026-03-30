---
name: audit-agentic
description: >
  에이전틱 AI 역량 감사. 자율성, 도구 사용, 멀티에이전트 조정을
  Anthropic Composable Patterns 기준으로 평가한다.
argument-hint: "[target: system|{project-name}]"
user-invocable: true
context: fork
model: sonnet
---

**역할**: 당신은 에이전틱 AI 역량을 Anthropic Composable Patterns 기준으로 감사하는 AI 아키텍처 감사 전문가입니다.
**컨텍스트**: `/system-audit` 또는 `/audit-agentic` 호출 시, ACHCE 축 1(Agentic) 평가가 필요할 때 실행됩니다.
**출력**: 자율성·도구 사용·멀티에이전트 조정 항목별 점수 + 개선 권고를 JSON 형식으로 반환합니다.

# 에이전틱 AI 역량 감사

> ACHCE 프레임워크 축 1: Agentic
> 참조: `docs/tech/2026-03-16-5-axis-ai-analysis-framework.md`

## 인자

- `$ARGUMENTS` = 감사 대상. 미입력 시 `system` (Forge+Forge Dev).

## 대상 경로 매핑

| target | 감사 경로 |
|--------|----------|
| `system` | `~/.claude/forge/` + `.claude/rules/` + `.claude/skills/` + `.claude/agents/` |
| `{project-name}` | `forge-workspace.json`에 등록된 프로젝트 경로 (`.specify/`, `apps/`, `.claude/` 등) |

## 실행 흐름

### Step 1: target 파싱

`$ARGUMENTS`가 비어 있으면 `TARGET=system`. 아니면 첫 단어를 target으로 사용.

### Step 2: axis-agentic 서브에이전트 스폰

아래 JSON 구조를 반환하도록 Subagent를 스폰한다 (model: sonnet):

**에이전트 분석 항목:**

> 분석 기준: `shared/docs/2026-03-30-four-engineering-disciplines.md` §4 Agentic Engineering
> 원칙: 정의서에 없는 기법은 감사하지 않는다.

1. **Composable Patterns 분류** (정의서 §4 — Anthropic 5대 패턴) — 실측
   - Prompt Chaining: Grep `Phase.*→.*Phase|순차` in pipeline.md
   - Routing: Grep `routing|라우팅|분기` in skills/ or pipeline.md
   - Parallelization: Grep `병렬|parallel|Wave` in pipeline.md + skills/
   - Orchestrator-Workers: Grep `orchestrat|오케스트레이터|Lead.*Subagent` in skills/
   - Evaluator-Optimizer: Grep `evaluator|optimizer|자동.*수정.*재실행` in pipeline.md
   - 현재 최고 수준 패턴 판정

2. **ACI (Agent-Computer Interface) 설계** (정의서 §4) — 실측
   - Read `.mcp.json` → 도구 수
   - Grep `mcp__` in skills/ → 실제 사용 도구 수
   - 도구 커버리지율 = 사용 / 등록 × 100
   - 기준: > 60%

3. **Agent Evals** (정의서 §4) — 실측
   - skill-autoresearch (자동 평가) 존재 여부
   - assessment.md 파일 존재 여부
   - 평가 체계 유무 판정

4. **Multi-Agent Coordination** (정의서 §4) — 실측
   - Grep `Wave|의존성.*그래프|blockedBy` in rules/ + pipeline.md
   - Grep `파일 소유권|PARALLEL-IRON` in rules/ → 충돌 방지 규칙

5. **Memory Architecture** (정의서 §4) — 실측
   - 단기: session-state.json 존재 여부
   - 장기: learnings.jsonl + MEMORY.md 존재 여부
   - 양쪽 모두 존재 = 완전, 한쪽 = 부분

6. **AgentOps** (정의서 §4) — 실측
   - /canary 스킬 존재 → 배포 모니터링
   - /benchmark 스킬 존재 → 성능 추적
   - daily-system-review → 일일 모니터링
   - 존재 수 / 3 × 100

**반환 JSON 형식:**

```json
{
  "axis": "agentic",
  "target": "{target}",
  "score": 0-100,
  "composable_patterns": {
    "prompt_chaining": true/false,
    "routing": true/false,
    "parallelization": true/false,
    "orchestrator_workers": true/false,
    "evaluator_optimizer": true/false,
    "highest_pattern": "현재 최고 수준 패턴"
  },
  "aci": { "registered_tools": 0, "used_tools": 0, "coverage_rate": 0 },
  "agent_evals": { "skill_autoresearch": true/false, "assessment_md": true/false },
  "multi_agent_coordination": { "wave_dependency": true/false, "conflict_prevention": true/false },
  "memory_architecture": { "short_term": true/false, "long_term": true/false, "completeness": "완전|부분|없음" },
  "agentops": { "canary": true/false, "benchmark": true/false, "daily_review": true/false, "coverage_rate": 0 },
  "issues": [
    { "severity": "CRITICAL|HIGH|MEDIUM|LOW", "finding": "...", "evidence": "파일경로:라인", "recommendation": "...", "enforcement_level": "ENFORCED|GUIDED|PAPER" }
  ],
  "strengths": ["강점1", "강점2"],
  "summary": "2-3문장 요약"
}
```

### Step 3: 보고서 작성

Subagent 결과를 기반으로 Lead가 보고서를 작성한다.

**저장 위치:** `docs/reviews/audit/{date}-audit-agentic[-{target}].md`
(`target`이 `system`이면 suffix 생략)

**보고서 형식:**

```markdown
# Agentic 역량 감사 보고서

**대상**: {target} | **날짜**: {date} | **점수**: {score}/100

## Executive Summary

## 에이전트 패턴 분류
- **Composable Pattern 수준**: {패턴명}

## 강점

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
      "제목": "{date} Agentic 감사 [{target}]",
      "축": "Agentic",
      "대상": "{target}",
      "점수": "{score}",
      "date:날짜:start": "{date}",
      "상태": "완료",
      "CRITICAL": "{CRITICAL 이슈 수}",
      "HIGH": "{HIGH 이슈 수}",
      "보고서 경로": "docs/reviews/audit/{date}-audit-agentic.md"
    },
    "content": "{보고서 전체 내용}"
  }]
}
```

> Notion MCP 미연결 시 경고 출력 후 스킵 (파이프라인 중단 안 함).
