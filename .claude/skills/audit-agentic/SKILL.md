---
name: audit-agentic
description: >
  에이전틱 AI 역량 감사. 자율성, 도구 사용, 멀티에이전트 조정, 성숙도 레벨(Sema4.ai L0-L5)을
  CLEAR 프레임워크 + Anthropic Composable Patterns 기준으로 평가한다.
argument-hint: "[target: system|{project-name}]"
user-invocable: true
context: fork
---

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

1. **Composable Patterns 수준** — 실측
   - Glob `.claude/agents/*.md` → 에이전트 수 카운트
   - Grep `Agent\(` or `subagent_type` in skills/ → Subagent 스폰 패턴 수
   - Grep `isolation.*worktree` → Worktree 격리 패턴 수
   - 판정: 0 agent=Augmented LLM, 1-5=Prompt Chaining, 5-10+parallel=Orchestrator-Workers

2. **Sema4.ai 성숙도 레벨** 판정
   - L0-L5 중 현재 위치 + 근거 (코드/설정 인용)

3. **도구 호출 패턴** 분석
   - Tool Call Accuracy: 과다 호출, 잘못된 도구 선택, 파라미터 오류 패턴

4. **멀티에이전트 토폴로지** 확인
   - Centralized / Decentralized / Hybrid
   - Wave 기반 의존성 관리 여부
   - 에러 증폭 방지 패턴 존재 여부

5. **CLEAR 5차원 커버리지** 체크
   - CNA, SCR, PAS, pass@k 측정 여부 확인
   - 미측정 항목 식별

6. **모니터링 체크리스트** (5축 프레임워크 기준)
   - 벤치마크 측정 여부, pass@1 vs pass@k 구분, 레이턴시/비용 보고, 토폴로지 명시

**반환 JSON 형식:**

```json
{
  "axis": "agentic",
  "target": "{target}",
  "score": 0-100,
  "maturity_level": "L0-L5",
  "composable_pattern": "현재 최고 수준 패턴",
  "issues": [
    { "severity": "CRITICAL|HIGH|MEDIUM|LOW", "finding": "...", "evidence": "파일경로:라인", "recommendation": "..." }
  ],
  "strengths": ["강점1", "강점2"],
  "metrics_coverage": { "CNA": true/false, "SCR": true/false, "PAS": true/false, "pass_k": true/false },
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

## 성숙도 평가
- **현재 레벨**: Sema4.ai {L?} — {레벨명}
- **Composable Pattern 수준**: {패턴명}

## 강점

## 이슈 목록
### CRITICAL
### HIGH
### MEDIUM / LOW

## CLEAR 5차원 커버리지

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
