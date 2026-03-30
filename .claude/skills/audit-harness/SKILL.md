---
name: audit-harness
description: >
  AI 하네스 엔지니어링 감사. Check Chain, OWASP Agentic Top 10,
  가드레일 패턴, Hook 커버리지를 기준으로 측정·제어 역량을 평가한다.
argument-hint: "[target: system|{project-name}]"
user-invocable: true
context: fork
---

# AI 하네스 엔지니어링 감사

> ACHCE 프레임워크 축 3: Harness
> 참조: `docs/tech/2026-03-16-5-axis-ai-analysis-framework.md`

## 인자

- `$ARGUMENTS` = 감사 대상. 미입력 시 `system` (Forge+Forge Dev).

## 대상 경로 매핑

| target | 감사 경로 |
|--------|----------|
| `system` | `~/.claude/forge/rules/` + `.claude/rules/` + `.claude/agents/` + `.claude/skills/` |
| `{project-name}` | `forge-workspace.json`에 등록된 프로젝트 경로 (`.specify/`, `apps/`, `.claude/` 등) |

## 실행 흐름

### Step 1: target 파싱

`$ARGUMENTS`가 비어 있으면 `TARGET=system`. 아니면 첫 단어를 target으로 사용.

### Step 2: axis-harness 서브에이전트 스폰

아래 JSON 구조를 반환하도록 Subagent를 스폰한다 (model: sonnet):

**에이전트 분석 항목:**

> 분석 기준: `shared/docs/2026-03-30-four-engineering-disciplines.md` §3 Harness Engineering
> 원칙: 정의서에 없는 기법은 감사하지 않는다.

1. **Check Chain** (정의서 §3-1) — 실측
   - Grep `Check 3|Check 6|check.*chain` in pipeline.md → 체인 단계 수
   - Grep `autoFix|auto-fix|1회.*수정` → autoFix 한도 규칙

2. **Guardrails (5 Rail Types)** (정의서 §3-2) — 실측
   - Input Rail: Grep `PreToolUse` in settings.json → 입력 검증 Hook
   - Output Rail: Grep `PostToolUse` in settings.json → 출력 검증 Hook
   - Execution Rail: Grep `block.*sensitive|exit 2` in hooks/ → 실행 차단
   - Dialog Rail: Grep `injection|jailbreak` in hooks/ → 대화 보호
   - Retrieval Rail: RAG 검증 존재 여부
   - 커버리지 = 구현된 Rail / 5

3. **OWASP Agentic Top 10** (정의서 §3-3) — 실측
   각 ASI 항목별 방어 코드 존재를 Grep으로 실제 확인:
   - ASI01 (Goal Hijack): Grep "ignore.*instructions|jailbreak|DAN" in hooks/ → exit 2 패턴
   - ASI02 (Tool Misuse): Grep "block.*sensitive|BLOCKED" in hooks/ → 차단 패턴
   - ASI05 (Improper Output): Grep "ASI05|sensitive.*output" in hooks/
   - ASI06 (Excess Autonomy): Grep "\\[STOP\\]" in pipeline.md → Hard Stop 게이트 수
   - ASI07 (Prompt Leak): Grep "system.*prompt|ASI07" in hooks/
   - ASI09 (Logging): Grep "security.log|usage.log" in hooks/
   - 커버리지 = (방어 코드 존재 ASI 수 / 10) × 100
   - 기준: > 50%

4. **Hooks** (정의서 §3-4) — 실측
   - Glob .claude/hooks/*.sh → Hook 스크립트 수
   - 위험 이벤트 유형: [파일쓰기, Bash실행, 민감경로, 시크릿, 인젝션, force-push, 프롬프트유출, 민감출력] = 8종
   - 각 유형별 Hook 존재 여부 Grep으로 확인
   - 커버리지 = (보호된 이벤트 / 8) × 100
   - 기준: > 70%

5. **AI Evals** (정의서 §3-5) — 실측
   - Glob `spec-compliance-checker` 스킬 → Spec 추적성 평가
   - Glob `code-reviewer` 에이전트 → 코드 리뷰 평가
   - Glob `asset-critic` 스킬 → 에셋 품질 평가
   - Glob `qa` 스킬 → QA 루프
   - 평가 체계 수 = 위 존재 카운트

6. **Observability** (정의서 §3-6) — 실측
   - Grep `usage-logger|security.log|usage.log` in hooks/ → 로깅 Hook
   - Grep `requestId|traceId` in rules/ → 추적 ID 규칙

7. **Rollback** (정의서 §3-7) — 실측
   - Grep `L1.*rollback|L2.*rollback|L3.*rollback|forge-rollback` in pipeline.md → 3단계 정의

8. **Maintenance Agents** (정의서 §3-8) — 실측
   - Glob `.claude/agents/` → 에이전트 수
   - daily-system-review, weekly-research 등 주기적 검증 스킬 존재

**반환 JSON 형식:**

```json
{
  "axis": "harness",
  "target": "{target}",
  "score": 0-100,
  "check_chain": { "chain_stages": 0, "autofix_limit_rule": true/false },
  "guardrails": { "input_rail": true/false, "output_rail": true/false, "execution_rail": true/false, "dialog_rail": true/false, "retrieval_rail": true/false, "coverage_rate": 0 },
  "owasp_coverage": { "ASI01": true/false, "ASI02": true/false, "ASI05": true/false, "ASI06": true/false, "ASI07": true/false, "ASI09": true/false, "coverage_rate": 0 },
  "hooks": { "hook_count": 0, "coverage_rate": 0 },
  "ai_evals": { "spec_compliance_checker": true/false, "code_reviewer": true/false, "asset_critic": true/false, "qa": true/false, "eval_count": 0 },
  "observability": { "logging_hook": true/false, "trace_id_rule": true/false },
  "rollback": { "three_level_defined": true/false },
  "maintenance_agents": { "agent_count": 0, "periodic_review_skill": true/false },
  "issues": [
    { "severity": "CRITICAL|HIGH|MEDIUM|LOW", "finding": "...", "evidence": "파일경로:라인", "recommendation": "..." }
  ],
  "strengths": ["강점1", "강점2"],
  "summary": "2-3문장 요약"
}
```

### Step 3: 보고서 작성

Subagent 결과를 기반으로 Lead가 보고서를 작성한다.

**저장 위치:** `docs/reviews/audit/{date}-audit-harness[-{target}].md`
(`target`이 `system`이면 suffix 생략)

**보고서 형식:**

```markdown
# Harness 엔지니어링 감사 보고서

**대상**: {target} | **날짜**: {date} | **점수**: {score}/100

## Executive Summary

## 검증 체인(Check Chain) 상태

## OWASP Agentic Top 10 커버리지

## 가드레일 상태

## Hook 커버리지

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
      "제목": "{date} Harness 감사 [{target}]",
      "축": "Harness",
      "대상": "{target}",
      "점수": "{score}",
      "date:날짜:start": "{date}",
      "상태": "완료",
      "CRITICAL": "{CRITICAL 이슈 수}",
      "HIGH": "{HIGH 이슈 수}",
      "보고서 경로": "docs/reviews/audit/{date}-audit-harness.md"
    },
    "content": "{보고서 전체 내용}"
  }]
}
```

> Notion MCP 미연결 시 경고 출력 후 스킵 (파이프라인 중단 안 함).
