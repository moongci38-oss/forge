# Context 엔지니어링 감사 보고서

**대상**: system (Forge + Forge Dev) | **날짜**: 2026-04-12 | **점수**: 62/100

---

## Executive Summary

Forge 시스템의 Context Engineering은 Long-Term Memory, RAG 인프라, Sub-Agent Architecture, Progressive Disclosure에서 강점을 보이나 세 가지 영역에서 심각한 결함을 드러낸다. Context Compaction 트리거 규칙이 전혀 문서화되어 있지 않고, MCP 서버 7개 전부 `description` 필드가 없으며, 프롬프트 구조 3요소 충족률(49.3%)이 기준치(70%)를 20%p 이상 미달한다. 메모리 파일(MEMORY.md 51줄)은 기준(30항목)을 초과하여 로딩 비용이 누적되고 있다.

---

## 컨텍스트 구성 체크리스트

| 레이어 | 구현 | 비고 |
|--------|:----:|------|
| System Instructions (CLAUDE.md + rules) | ✅ | CLAUDE.md 7개 이상, forge rules 5개 파일 12,210 bytes |
| Persistent Memory (Long-Term) | ⚠️ | MEMORY.md 51줄 (기준 30항목 초과), learnings.jsonl 343줄 |
| Retrieved Data (RAG) | ✅ | LightRAG 인덱스 2개 + RAG 스킬 존재, 인덱스 위치 비표준 |
| Available Tools (MCP) | ❌ | 7개 서버 모두 description 필드 없음 |
| Output Specifications (Prompt Structure) | ❌ | 3요소 충족률 49.3% (기준 70% 미달) |

---

## 컨텍스트 실패 패턴 분석 (Clash / Rot)

### Context Rot — CRITICAL

**MEMORY.md 비대화**
- 증거: `51줄` (`wc -l /home/damools/.claude/projects/-home-damools-forge/memory/MEMORY.md`)
- 기준 30항목을 초과. 세션 시작 시 매번 전체 로딩 발생.
- 권고: 30항목 초과 항목을 `memory/archive/`로 이동. 사용 빈도 기반 정리 규칙 추가.

### Context Clash — HIGH

**compact 트리거 미문서화**
- 증거: `forge/.claude/rules/*.md`, `~/.claude/rules/` 어디에도 `/compact` 실행 기준이 없음
- `rd-plan` 스킬에만 Phase 전환 시 압축 지침이 있으나 시스템 전체 규칙 없음
- 권고: `forge/.claude/rules/forge-core.md`에 compact 트리거 기준 (예: "70% 토큰 소비 시 /compact 실행") 추가.

### Context Rot — HIGH

**MCP description 전무**
- 증거: `brave-search`, `notion`, `stitch`, `nano-banana`, `forge-tools`, `sequential-thinking`, `hwpx` 7개 서버 모두 `description=False`
- LLM이 도구를 선택할 때 이름만으로 추론해야 함 → 잘못된 도구 선택 위험
- 권고: 각 MCP 서버 config에 1-2문장 `description` 필드 추가.

---

## Progressive Disclosure 상태

**3단계 구현: ✅ 부분 구현**

- `forge-core.md`: "Passive Summary" + "Deep 로딩 라우팅" 테이블 포함
- `forge-planning.md`: "Passive Summary (~750 토큰)" + Deep 로드 대상 명시
- 나머지 3개 rules 파일 (`opus-4-6-best-practices.md`, `plan-mode.md`, `telegram-remote-control.md`): Passive/Active/Deep 구분 없음

**조건부 로딩률**: 5개 rules 파일 중 2개에 Deep 참조 → 40% (기준 50% 미달)

**문제점**: 전역 `~/.claude/rules/` 폴더가 비어 있어(0개 파일) 글로벌 레벨 Progressive Disclosure가 존재하지 않음.

---

## 메모리 시스템 평가

| 항목 | 현황 | 평가 |
|------|------|------|
| learnings.jsonl (forge) | 343줄 | ✅ 활성 기록 중 |
| learnings.jsonl (global) | 12줄 | ✅ 존재 |
| MEMORY.md | 51줄 | ⚠️ 기준(30) 초과 |
| memory/ 세부 파일 | 30+ 파일 | ✅ 모듈화 양호 |

MEMORY.md는 섹션별 세부 파일로 분리(`feedback_*.md`, `project_*.md`)하는 구조는 우수하나, 메인 MEMORY.md 자체가 계속 증가하는 패턴이다. 세부 파일로 위임하고 MEMORY.md는 인덱스 역할만 유지해야 한다.

---

## RAG 인프라 평가

| 항목 | 현황 |
|------|------|
| RAG 스크립트 (`shared/scripts/rag/`) | ✅ index.py, search.py, setup.sh 존재 |
| LightRAG 인덱스 | ✅ `lightrag-grants-data/index/`, `lightrag-pilot-data/index/` |
| 표준 `.rag-index/` 경로 | ❌ 인덱스가 표준 경로(`~/forge-outputs/.rag-index/`)에 없음 |
| rag-search 스킬 | ✅ 존재, context: fork 설정 |

**이슈**: 스킬 내 인덱스 예상 경로(`~/forge-outputs/.rag-index/`)와 실제 LightRAG 인덱스 경로(`forge/shared/lightrag-grants-data/index/`)가 불일치. 스킬 실행 시 "인덱스 없음" 오류 발생 가능.

---

## Sub-Agent Architecture 평가

- **격리 패턴 수**: `context: fork`를 사용하는 SKILL.md 파일 58개
- **평가**: ✅ 우수. 대부분의 스킬이 독립 컨텍스트로 실행됨
- `isolation: worktree` 패턴은 `forge-core.md`에 문서화되어 있으나 실제 스킬에서 사용된 사례는 확인되지 않음

---

## 이슈 목록

### CRITICAL

| # | 항목 | 근거 | 권고 |
|---|------|------|------|
| C-1 | MEMORY.md 비대화 (51줄) | `wc -l` 실측. 기준 30항목 초과 | 오래된 항목 `memory/archive/` 이동, 30항목 상한 규칙 추가 |

### HIGH

| # | 항목 | 근거 | 권고 |
|---|------|------|------|
| H-1 | Context Compaction 트리거 미문서화 | `forge/.claude/rules/`, `~/.claude/rules/` grep 결과 없음 | `forge-core.md`에 compact 트리거 기준 섹션 추가 |
| H-2 | MCP 서버 description 전무 (7/7) | `~/.claude.json` + `forge/.mcp.json` 실측 | 각 서버 `description` 1-2문장 추가 |
| H-3 | 프롬프트 3요소 충족률 49.3% (기준 70%) | 67개 SKILL.md 실측. 33개만 충족 | 역할/컨텍스트/출력 3요소 누락 스킬 순차 개선 |

### MEDIUM

| # | 항목 | 근거 | 권고 |
|---|------|------|------|
| M-1 | RAG 인덱스 경로 불일치 | rag-search 스킬 예상 경로 vs LightRAG 실제 경로 다름 | 스킬 내 인덱스 경로를 실제 경로로 업데이트 또는 심볼릭 링크 생성 |
| M-2 | 전역 `~/.claude/rules/` 비어 있음 | `ls` 결과 파일 0개 | 글로벌 레벨 Progressive Disclosure 규칙 필요 시 이 경로 활용 |
| M-3 | 조건부 로딩률 40% (기준 50%) | 5개 rules 중 2개만 Deep 참조 포함 | 나머지 3개 rules에도 On-Demand 참조 섹션 추가 |

### LOW

| # | 항목 | 근거 | 권고 |
|---|------|------|------|
| L-1 | `isolation: worktree` 실사용 미확인 | skills/ grep 결과 0건 | 동일 파일 병렬 수정 시나리오에서 실제 적용 여부 검증 |

---

## 권장 액션 (우선순위순)

1. **[CRITICAL] MEMORY.md 정리** — 30항목 초과분을 `memory/archive/`로 이동. 상한 규칙을 `forge-core.md`에 명시.
2. **[HIGH] compact 트리거 기준 추가** — `forge-core.md` 또는 별도 `context-management.md`에 "컨텍스트 70% 소비 시 /compact 실행" 규칙 작성.
3. **[HIGH] MCP description 추가** — `~/.claude.json`과 `forge/.mcp.json`의 7개 서버에 각 1-2문장 description 추가.
4. **[HIGH] 프롬프트 3요소 미충족 스킬 개선** — 34개 미충족 스킬 중 우선순위 높은 10개부터 역할/컨텍스트/출력 요소 보강.
5. **[MEDIUM] RAG 인덱스 경로 정렬** — `rag-search` 스킬이 참조하는 경로와 실제 LightRAG 인덱스 위치를 일치시킴.

---

## 상세 측정 데이터

```json
{
  "axis": "context",
  "target": "system",
  "score": 62,
  "system_prompt_design": {
    "claude_md_exists": true,
    "rules_count": 5,
    "total_bytes": 12210
  },
  "short_term_memory": {
    "compact_rule_exists": false,
    "history_limit_rule": false
  },
  "long_term_memory": {
    "learnings_jsonl": true,
    "memory_md": true,
    "memory_md_lines": 51,
    "memory_md_over_limit": true
  },
  "rag": {
    "rag_scripts": true,
    "rag_index": true,
    "rag_skill": true,
    "index_path_mismatch": true
  },
  "tool_definition": {
    "mcp_server_count": 7,
    "description_coverage": false,
    "servers_with_description": 0
  },
  "context_compaction": {
    "compact_trigger_documented": false
  },
  "sub_agent_architecture": {
    "isolation_pattern_count": 58,
    "worktree_isolation_count": 0
  },
  "progressive_disclosure": {
    "three_stage_implemented": true,
    "conditional_loading_rate": 40,
    "global_rules_count": 0
  },
  "structured_note_taking": {
    "state_management_pattern": true,
    "checkpoint_in_pipeline": true
  },
  "prompt_structure_rate": 49.3,
  "failure_patterns": [
    {
      "type": "Rot",
      "severity": "CRITICAL",
      "evidence": "MEMORY.md 51줄 (기준 30 초과)",
      "recommendation": "30항목 초과분 archive 이동"
    },
    {
      "type": "Clash",
      "severity": "HIGH",
      "evidence": "compact 트리거 기준 rules에 없음",
      "recommendation": "forge-core.md에 트리거 기준 추가"
    },
    {
      "type": "Rot",
      "severity": "HIGH",
      "evidence": "MCP 7서버 description 전무",
      "recommendation": "각 서버 description 필드 추가"
    }
  ],
  "issues": [
    {
      "severity": "CRITICAL",
      "finding": "MEMORY.md 비대화",
      "evidence": "~/.claude/projects/-home-damools-forge/memory/MEMORY.md:51줄",
      "recommendation": "오래된 항목 archive/ 이동, 30항목 상한 규칙 추가"
    },
    {
      "severity": "HIGH",
      "finding": "Context Compaction 트리거 미문서화",
      "evidence": "forge/.claude/rules/*.md grep: 결과 없음",
      "recommendation": "forge-core.md에 compact 기준 섹션 추가"
    },
    {
      "severity": "HIGH",
      "finding": "MCP 서버 description 전무 (7/7)",
      "evidence": "~/.claude.json, forge/.mcp.json: description=False 7건",
      "recommendation": "각 서버 config에 description 추가"
    },
    {
      "severity": "HIGH",
      "finding": "프롬프트 3요소 충족률 49.3%",
      "evidence": "67개 SKILL.md 실측, 33개만 role+context+output 모두 포함",
      "recommendation": "미충족 34개 스킬 순차 보강"
    },
    {
      "severity": "MEDIUM",
      "finding": "RAG 인덱스 경로 불일치",
      "evidence": "rag-search SKILL.md 예상: ~/forge-outputs/.rag-index/, 실제: forge/shared/lightrag-*-data/index/",
      "recommendation": "경로 통일 또는 심볼릭 링크"
    },
    {
      "severity": "MEDIUM",
      "finding": "전역 ~/.claude/rules/ 비어 있음",
      "evidence": "ls ~/.claude/rules/: 파일 0개",
      "recommendation": "글로벌 규칙 필요 시 이 경로 활용"
    },
    {
      "severity": "MEDIUM",
      "finding": "조건부 로딩률 40% (기준 50%)",
      "evidence": "5개 rules 중 2개만 Deep 참조",
      "recommendation": "나머지 3개 rules에 On-Demand 참조 추가"
    }
  ],
  "strengths": [
    "Sub-Agent 격리 패턴 우수: 58개 스킬이 context: fork 사용",
    "LightRAG 인프라 구축: 스크립트 + 인덱스 + 전용 스킬",
    "Pipeline checkpoint 상태 관리: pipeline.md에 state=phaseN_complete 체계",
    "learnings.jsonl 활성 기록: forge 343줄로 지식 축적 중",
    "Memory 모듈화: 30+ 세부 파일로 분리 관리"
  ],
  "summary": "Context Engineering 핵심 인프라(RAG, Sub-Agent, Progressive Disclosure)는 구축되어 있으나 Context Compaction 미문서화, MCP description 전무, 프롬프트 구조 충족률 49%라는 세 가지 HIGH+ 이슈가 실제 에이전트 실패 위험을 높이고 있다. MEMORY.md 비대화는 매 세션 불필요한 컨텍스트 로딩을 유발한다."
}
```

---

## 참조

- `docs/tech/2026-03-16-5-axis-ai-analysis-framework.md`
- `forge/shared/docs/2026-03-30-four-engineering-disciplines.md` §2 Context Engineering
- 감사 기준: audit-context SKILL.md (정의서 §2-1 ~ §2-9)
