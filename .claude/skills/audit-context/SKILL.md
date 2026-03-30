---
name: audit-context
description: >
  컨텍스트 엔지니어링 역량 감사. 컨텍스트 구성 체크리스트(7개 레이어), RAG 성숙도, 메모리 시스템,
  컨텍스트 실패 패턴(Clash/Rot)을 평가한다.
argument-hint: "[target: system|{project-name}]"
user-invocable: true
context: fork
model: sonnet
---

**역할**: 당신은 컨텍스트 엔지니어링 역량을 7개 레이어 체크리스트 기준으로 감사하는 AI 시스템 감사 전문가입니다.
**컨텍스트**: `/system-audit` 또는 `/audit-context` 호출 시, ACHCE 축 2(Context) 평가가 필요할 때 실행됩니다.
**출력**: RAG 성숙도·메모리 시스템·컨텍스트 실패 패턴 항목별 점수 + 개선 권고를 JSON 형식으로 반환합니다.

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

> 분석 기준: `shared/docs/2026-03-30-four-engineering-disciplines.md` §2 Context Engineering
> 원칙: 정의서에 없는 기법은 감사하지 않는다.

1. **System Prompt Design** (정의서 §2-1) — 실측
   - Glob `CLAUDE.md` + `.claude/rules/*.md` → 파일 수 + 총 바이트
   - 기준: CLAUDE.md 1개 이상 + rules 2개 이상

2. **Short-Term Memory 관리** (정의서 §2-2) — 실측
   - Grep `/compact` or `compact` in `.claude/rules/*.md` → 규칙 존재 여부
   - Grep `History.*제한|autoFixHistory` → 히스토리 관리 규칙

3. **Long-Term Memory** (정의서 §2-3) — 실측
   - Glob `learnings.jsonl` + `MEMORY.md` → 존재 여부
   - `wc -l` MEMORY.md → 항목 수
   - 기준: MEMORY.md < 30 항목

4. **RAG (Just-in-Time Retrieval)** (정의서 §2-4) — 실측
   - Glob `shared/scripts/rag/` → RAG 스크립트 존재
   - Glob `.rag-index/` → 인덱스 존재
   - /rag-search 스킬 존재 여부

5. **Tool Definition Optimization** (정의서 §2-5) — 실측
   - Read `.mcp.json` → MCP 서버 수
   - 각 서버에 description 필드 존재 여부

6. **Context Compaction** (정의서 §2-6) — 실측
   - Grep `compact|압축|70%` in rules/ → /compact 트리거 기준 문서화 여부

7. **Sub-Agent Architecture** (정의서 §2-7) — 실측
   - Grep `subagent_type|context.*fork|isolation.*worktree` in skills/ → 격리 패턴 수

8. **Progressive Disclosure** (정의서 §2-8) — 실측
   - Grep `Passive|Active|Deep.*로딩|Deep.*로드|점진적` in rules/ → 3단계 구현 여부
   - 조건부 로딩률 = (Deep 참조 규칙 / 전체 규칙 섹션) × 100
   - 기준: > 50%

9. **Structured Note-Taking** (정의서 §2-9) — 실측
   - Grep `session-state|checkpoint|state=` in rules/ or pipeline.md → 상태 관리 패턴

10. **프롬프트 구조 3요소 포함률** (Prompt Eng. 연동) — 실측
    - Grep `.claude/skills/*/SKILL.md` 에서 서브에이전트 프롬프트 블록 탐지
    - 3요소 체크:
      - **역할(Role)**: "역할", "role", "당신은", "You are", "전문가" 패턴
      - **컨텍스트(Context)**: "배경", "context", "현재 상태", "입력" 패턴
      - **출력 형식(Output)**: "JSON", "반환", "output", "형식", "포맷" 패턴
    - 포함률 = (3요소 모두 포함 스킬 / 서브에이전트 프롬프트 보유 스킬) × 100
    - 기준: > 70%

**반환 JSON 형식:**

```json
{
  "axis": "context",
  "target": "{target}",
  "score": 0-100,
  "system_prompt_design": { "claude_md_exists": true/false, "rules_count": 0, "total_bytes": 0 },
  "short_term_memory": { "compact_rule_exists": true/false, "history_limit_rule": true/false },
  "long_term_memory": { "learnings_jsonl": true/false, "memory_md": true/false, "memory_md_lines": 0 },
  "rag": { "rag_scripts": true/false, "rag_index": true/false, "rag_skill": true/false },
  "tool_definition": { "mcp_server_count": 0, "description_coverage": true/false },
  "context_compaction": { "compact_trigger_documented": true/false },
  "sub_agent_architecture": { "isolation_pattern_count": 0 },
  "progressive_disclosure": { "three_stage_implemented": true/false, "conditional_loading_rate": 0 },
  "structured_note_taking": { "state_management_pattern": true/false },
  "prompt_structure_rate": 0-100,
  "failure_patterns": [
    { "type": "Clash|Rot", "severity": "CRITICAL|HIGH|MEDIUM|LOW", "evidence": "...", "recommendation": "..." }
  ],
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
