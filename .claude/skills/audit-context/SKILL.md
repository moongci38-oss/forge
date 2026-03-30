---
name: audit-context
description: >
  컨텍스트 엔지니어링 역량 감사. 컨텍스트 구성 체크리스트(7개 레이어), RAG 성숙도, 메모리 시스템,
  컨텍스트 실패 패턴(Clash/Rot)을 평가한다.
argument-hint: "[target: system|{project-name}]"
user-invocable: true
context: fork
---

# 컨텍스트 엔지니어링 역량 감사

> ACHCE 프레임워크 축 2: Context
> 참조: `docs/tech/2026-03-16-5-axis-ai-analysis-framework.md`

## 인자

- `$ARGUMENTS` = 감사 대상. 미입력 시 `system` (Forge+Forge Dev).

## 대상 경로 매핑

| target | 감사 경로 |
|--------|----------|
| `system` | `~/.claude/forge/rules/` + `.claude/rules/` + `.claude/skills/` + `memory/` |
| `{project-name}` | `forge-workspace.json`에 등록된 프로젝트 경로 (`.specify/`, `.claude/`, `docs/` 등) |

## 실행 흐름

### Step 1: target 파싱

`$ARGUMENTS`가 비어 있으면 `TARGET=system`. 아니면 첫 단어를 target으로 사용.

### Step 2: axis-context 서브에이전트 스폰

아래 JSON 구조를 반환하도록 Subagent를 스폰한다 (model: sonnet):

**에이전트 분석 항목:**

1. **컨텍스트 구성 체크리스트**
   - System Instructions / User Prompt / Conversation History / Persistent Memory / Retrieved Data / Available Tools / Output Specifications 각 레이어 구현 여부

2. **컨텍스트 실패 패턴 탐지** — 실측
   - **Clash**: Grep for conflicting patterns — same keyword with opposite instructions across rules files. Count files with "금지" and "허용" for same subject.
   - **Rot**: Check MEMORY.md dates — entries older than 90 days without update = Rot risk

3. **Progressive Disclosure 구현** 확인
   - Passive → Active → Deep 3단계 로딩 적용 여부
   - 불필요한 전체 로드 패턴 식별

4. **메모리 시스템** 평가
   - Factual / Experiential / Working 메모리 분류
   - Cross-Session Continuity 메커니즘 존재 여부
   - MEMORY.md / session-state 활용 패턴

5. **세션 시작 토큰** — 추정
   - `wc -c` on all .claude/rules/*.md → byte count → ÷4 = estimated tokens
   - `wc -c` on CLAUDE.md → tokens
   - `wc -c` on MEMORY.md → tokens
   - Total = sum of above
   - 기준: < 12,000 tokens (≈ 48,000 bytes)

**반환 JSON 형식:**

```json
{
  "axis": "context",
  "target": "{target}",
  "score": 0-100,
  "context_checklist": { "system_instructions": true/false, "persistent_memory": true/false, "retrieved_data": true/false, "available_tools": true/false, "output_specifications": true/false },
  "failure_patterns": [
    { "type": "Clash|Rot", "severity": "CRITICAL|HIGH|MEDIUM|LOW", "evidence": "...", "recommendation": "..." }
  ],
  "progressive_disclosure": true/false,
  "memory_types": ["Factual", "Working"],
  "token_budget_awareness": true/false,
  "issues": [
    { "severity": "CRITICAL|HIGH|MEDIUM|LOW", "finding": "...", "evidence": "파일경로:라인", "recommendation": "..." }
  ],
  "strengths": ["강점1", "강점2"],
  "summary": "2-3문장 요약"
}
```

### Step 3: 보고서 작성

Subagent 결과를 기반으로 Lead가 보고서를 작성한다.

**저장 위치:** `docs/reviews/audit/{date}-audit-context[-{target}].md`
(`target`이 `system`이면 suffix 생략)

**보고서 형식:**

```markdown
# Context 엔지니어링 감사 보고서

**대상**: {target} | **날짜**: {date} | **점수**: {score}/100

## Executive Summary

## 컨텍스트 구성 체크리스트

| 레이어 | 구현 | 비고 |
|--------|:----:|------|
| System Instructions | ✅/❌ | |
| Persistent Memory | ✅/❌ | |
| Retrieved Data (RAG) | ✅/❌ | |
| Available Tools | ✅/❌ | |
| Output Specifications | ✅/❌ | |

## 컨텍스트 실패 패턴 분석 (Clash / Rot)

## Progressive Disclosure 상태

## 메모리 시스템 평가

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
      "제목": "{date} Context 감사 [{target}]",
      "축": "Context",
      "대상": "{target}",
      "점수": "{score}",
      "date:날짜:start": "{date}",
      "상태": "완료",
      "CRITICAL": "{CRITICAL 이슈 수}",
      "HIGH": "{HIGH 이슈 수}",
      "보고서 경로": "docs/reviews/audit/{date}-audit-context.md"
    },
    "content": "{보고서 전체 내용}"
  }]
}
```

> Notion MCP 미연결 시 경고 출력 후 스킵 (파이프라인 중단 안 함).
