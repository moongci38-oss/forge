# Agentic 역량 감사 보고서

**대상**: system | **날짜**: 2026-04-12 | **점수**: 72/100

---

## Executive Summary

Forge + Forge Dev 시스템은 Anthropic Composable Patterns 5대 패턴 중 4개를 구현했으며, Wave 기반 멀티에이전트 조정과 장기 메모리 아키텍처가 강점이다. 그러나 ACI(Agent-Computer Interface) 도구 커버리지가 33%에 머물러 있고, Evaluator-Optimizer 패턴이 파이프라인 수준에서만 부분 구현되어 실질적 자동 개선 루프가 없다. AgentOps 3종이 모두 존재하지만 session-state.json 기반 단기 메모리가 없어 메모리 아키텍처가 불완전하다.

---

## 에이전트 패턴 분류

**Composable Pattern 수준**: Orchestrator-Workers (4/5 달성)

| 패턴 | 구현 여부 | 근거 |
|------|---------|------|
| Prompt Chaining | true | `pipeline.md`: Phase 1→2→3→4→5→6 순차 체인, `/autoplan` 3관점 순차 리뷰 |
| Routing | true | `forge-planning-router/SKILL.md`: 10개 요청 유형 자동 분기, `grants-write` 피드백 라우팅 |
| Parallelization | true | `pipeline.md`: Wave 3 병렬 실행, Fan-out 에이전트 스폰, Wave 단위 병렬 구현 |
| Orchestrator-Workers | true | `grants-write/SKILL.md`: 오케스트레이터 명시, `system-audit/SKILL.md`: 5축 병렬 스폰 |
| Evaluator-Optimizer | **false** | 파이프라인에 "1회 자동 수정→재실행" 구문 존재하나, 독립된 Evaluator-Optimizer 에이전트 없음. `skill-autoresearch`는 존재하나 자동 루프 실행이 아닌 수동 트리거 |

---

## 강점

1. **Wave 기반 의존성 관리**: `pipeline.md`에 Wave 1~4 프로토콜과 PARALLEL-IRON-1 파일 소유권 규칙이 명시되어 있어 병렬 충돌 방지 체계가 갖춰져 있다.
2. **Orchestrator 패턴 다층 구현**: `system-audit`, `grants-write`, `game-asset-generate` 등 여러 스킬에서 Lead(오케스트레이터)-Subagent(Worker) 패턴이 일관되게 구현되어 있다.
3. **장기 메모리 이중 구조**: `learnings.jsonl`(구조화 로그) + `MEMORY.md`(서사 메모리) 이중 구조로 장기 컨텍스트가 보존된다.
4. **AgentOps 3종 완비**: `canary`, `benchmark`, `daily-system-review` 스킬이 모두 존재하여 배포 모니터링·성능 추적·일일 리뷰 체계가 구축되어 있다.
5. **Routing 자동화**: `forge-planning-router`가 Haiku 모델로 경량 라우팅을 수행하며, 워크스페이스 gate-log 상태 기반 분기까지 구현되어 있다.

---

## 이슈 목록

### CRITICAL

없음.

### HIGH

**[H-1] ACI 도구 커버리지 33% — forge-tools 14개 함수 중 실제 스킬 참조 극소수**

- **위치**: `/home/damools/forge/shared/mcp/forge-tools-server.py` (14개 함수 정의) vs `/home/damools/.claude/skills/` (실제 `mcp__` 호출)
- **증거**: `mcp__forge-tools__*` 형태의 직접 MCP 호출이 스킬 전체에서 발견되지 않음. `notion_create_page`, `telegram_notify`, `rag_search` 등 고가치 도구가 스킬에서 직접 참조 대신 Bash 명령으로 우회
- **권고**: 각 스킬에서 forge-tools MCP 도구를 `mcp__forge-tools__` 접두사로 명시적 호출하도록 마이그레이션. 우선순위: `rag_search`, `notion_create_page`, `git_commit`

**[H-2] Evaluator-Optimizer 패턴 미구현 — 자동 개선 루프 없음**

- **위치**: `pipeline.md` — "실패 → 1회 자동 수정 → 재실행" 구문 존재하지만 독립 에이전트 아님
- **증거**: `skill-autoresearch/SKILL.md`가 AutoResearch 패턴을 정의하나, 자동 트리거 없이 수동 `/skill-autoresearch` 호출 방식. Evaluator→Optimizer→재실행 루프의 자동화 없음
- **권고**: `pipeline.md` Phase 6~12 구현 단계에 Evaluator 에이전트를 명시적으로 스폰하는 Check 6.5 게이트 추가. `skill-autoresearch`에 cron 트리거 연결 검토

### MEDIUM / LOW

**[M-1] 단기 메모리(session-state.json) 부재 — 세션 간 상태 손실 위험**

- **위치**: `/home/damools/.claude/` 디렉토리
- **증거**: `learnings.jsonl`, `MEMORY.md` 존재 확인. `session-state.json` 파일 없음
- **권고**: 세션 내 진행 상태(현재 Phase, Wave 완료 여부, 활성 에이전트 목록)를 저장하는 `session-state.json` 도입 검토. 특히 장시간 파이프라인 실행 시 세션 재개 기능 필요

**[M-2] forge-tools MCP 서버 등록 3개 중 forge-tools 단독 — 도구 다양성 부족**

- **위치**: `/home/damools/forge/.mcp.json`
- **증거**: `forge-tools`, `sequential-thinking`, `hwpx` 3개 서버만 등록. `brave-search` 등 스킬에서 참조하는 MCP가 전역 설정에만 있고 프로젝트 `.mcp.json`에 미등록
- **권고**: `brave-search`, `notion`, `nano-banana` 등 실제 스킬에서 사용하는 MCP를 프로젝트 `.mcp.json`에 명시적 등록

**[L-1] Agent Evals 체계가 단일 스킬(skill-autoresearch)에 집중**

- **위치**: `/home/damools/.claude/skills/skill-autoresearch/`
- **증거**: `assessment.md`, `evals/evals.json` 존재하지만, 다른 65개+ 스킬 중 assessment.md가 있는 스킬이 `skill-autoresearch` 하나뿐으로 추정
- **권고**: 고우선순위 스킬(grants-write, system-audit, daily-system-review)에 `assessment.md` 추가. `skill-autoresearch` 자동 평가 대상 스킬 목록 확장

---

## 권장 액션 (우선순위순)

1. **[즉시] forge-tools MCP 도구 커버리지 향상**: `grants-write`, `daily-system-review`, `weekly-research` 스킬의 Bash 기반 Notion/Telegram/RAG 호출을 `forge-tools` MCP 도구로 마이그레이션
2. **[단기 — 1주] Evaluator-Optimizer 루프 자동화**: `skill-autoresearch` cron 트리거 설정 (weekly 주기), pipeline.md Check 6.5에 코드 품질 Evaluator 에이전트 명시
3. **[단기 — 1주] session-state.json 도입**: 파이프라인 Phase/Wave 진행 상태를 세션 간 유지할 수 있는 경량 상태 파일 설계
4. **[중기 — 2주] 고우선순위 스킬 assessment.md 확장**: grants-write, system-audit 2개 스킬에 assessment.md + evals.json 추가

---

## 감사 결과 JSON

```json
{
  "axis": "agentic",
  "target": "system",
  "score": 72,
  "composable_patterns": {
    "prompt_chaining": true,
    "routing": true,
    "parallelization": true,
    "orchestrator_workers": true,
    "evaluator_optimizer": false,
    "highest_pattern": "Orchestrator-Workers"
  },
  "aci": {
    "registered_tools": 14,
    "used_tools": 5,
    "coverage_rate": 33
  },
  "agent_evals": {
    "skill_autoresearch": true,
    "assessment_md": true
  },
  "multi_agent_coordination": {
    "wave_dependency": true,
    "conflict_prevention": true
  },
  "memory_architecture": {
    "short_term": false,
    "long_term": true,
    "completeness": "부분"
  },
  "agentops": {
    "canary": true,
    "benchmark": true,
    "daily_review": true,
    "coverage_rate": 100
  },
  "issues": [
    {
      "severity": "HIGH",
      "finding": "ACI 도구 커버리지 33% — forge-tools 14개 함수 중 스킬 직접 참조 극소수",
      "evidence": "forge/shared/mcp/forge-tools-server.py:1-17 (14 함수) vs skills/ (mcp__ 호출 5개)",
      "recommendation": "rag_search, notion_create_page, git_commit 우선 마이그레이션",
      "enforcement_level": "GUIDED"
    },
    {
      "severity": "HIGH",
      "finding": "Evaluator-Optimizer 패턴 미구현 — 독립 에이전트 없이 수동 트리거만 존재",
      "evidence": "pipeline.md: '1회 자동 수정 → 재실행' (조건부 구문), skill-autoresearch/SKILL.md (수동 트리거)",
      "recommendation": "pipeline.md Check 6.5 Evaluator 게이트 추가, skill-autoresearch cron 연결",
      "enforcement_level": "GUIDED"
    },
    {
      "severity": "MEDIUM",
      "finding": "단기 메모리(session-state.json) 부재",
      "evidence": "/home/damools/.claude/ — session-state.json 없음",
      "recommendation": "Phase/Wave 진행 상태 저장용 경량 session-state.json 도입",
      "enforcement_level": "GUIDED"
    },
    {
      "severity": "MEDIUM",
      "finding": "프로젝트 .mcp.json에 실사용 MCP 서버 미등록",
      "evidence": "forge/.mcp.json: 3개 서버만 등록 (brave-search, notion 누락)",
      "recommendation": "스킬에서 실제 사용하는 MCP 서버 전체 .mcp.json 명시 등록",
      "enforcement_level": "GUIDED"
    },
    {
      "severity": "LOW",
      "finding": "Agent Evals가 skill-autoresearch 단일 스킬에 집중",
      "evidence": "skills/ 디렉토리 — assessment.md 보유 스킬: skill-autoresearch 1개",
      "recommendation": "grants-write, system-audit, daily-system-review에 assessment.md 추가",
      "enforcement_level": "PAPER"
    }
  ],
  "strengths": [
    "Wave 1~4 프로토콜 + PARALLEL-IRON-1 파일 소유권으로 병렬 충돌 방지 체계 완비",
    "system-audit·grants-write·game-asset-generate 등 다층 Orchestrator-Workers 구현",
    "learnings.jsonl + MEMORY.md 이중 구조 장기 메모리",
    "canary·benchmark·daily-system-review AgentOps 3종 100% 구비",
    "forge-planning-router Haiku 경량 라우팅 + gate-log 상태 기반 분기"
  ],
  "summary": "Composable Patterns 4/5 달성(Evaluator-Optimizer 미구현)하고 AgentOps 체계는 완비되어 있으나, ACI 도구 커버리지 33%와 단기 메모리 부재가 실질적 자율성을 제한한다. 우선순위는 forge-tools MCP 마이그레이션과 Evaluator 루프 자동화다."
}
```

---

## 참조

- `docs/tech/2026-03-16-5-axis-ai-analysis-framework.md`
- `forge/pipeline.md`
- `forge/shared/mcp/forge-tools-server.py`
- `~/.claude/skills/skill-autoresearch/assessment.md`
- `~/.claude/skills/forge-planning-router/SKILL.md`
