# Harness 엔지니어링 감사 보고서

**대상**: system (Forge + Forge Dev) | **날짜**: 2026-04-03 | **점수**: 74/100

---

## Executive Summary

Forge 하네스 시스템은 Check Chain 체계와 OWASP 기반 인젝션/민감 데이터 방어에서 높은 완성도를 보인다. 그러나 Retrieval Rail(RAG 결과 검증)이 부재하고, 롤백 정의가 파이프라인 문서에만 존재하며 실행 가능한 스크립트로 구체화되어 있지 않다. Hook 커버리지는 70% 기준을 통과하나, Output Rail(PostToolUse 보안 검증)이 사용량 로깅에만 집중되어 실질적인 출력 내용 차단 기능이 없다.

CRITICAL 이슈 0건, HIGH 이슈 2건, MEDIUM 이슈 3건으로 즉각적인 시스템 위험은 낮으나 구조적 공백이 확인된다.

---

## 검증 체인(Check Chain) 상태

**점수: 95/100 (우수)**

| 항목 | 실측 결과 |
|------|----------|
| 체인 단계 수 | 7단계 (Check 2, 3, 4, 6, 6.5, 6.7, 6.8, 9.5) |
| autoFix 한도 규칙 | 명시됨 — "1회 자동 수정 → 재실패 → [STOP]", "최대 2사이클" |
| Hard Stop 게이트 | 다수 (Human 승인 필수 게이트 8개 이상) |

**근거**: `pipeline.md` 라인 403-411
- Check 6 실패 → 1회 자동 수정 → 재실행 / 재실패 → [STOP]
- Check 6.5, 6.7 실패 → 1회 자동 수정 → 재실패 → [STOP]
- QA Loop Check 6.8: 최대 2사이클 초과 → [STOP] Human 에스컬레이션

**소견**: autoFix 한도가 명확하고 모든 게이트에 Human 에스컬레이션이 연결되어 있다. 자동화 과잉 실행 위험이 낮다.

---

## OWASP Agentic Top 10 커버리지

**커버리지: 60% (6/10항목 중 6개 방어)**

| ASI 코드 | 위협 | 방어 상태 | 근거 파일 |
|---------|------|----------|----------|
| ASI01 Goal Hijack | 프롬프트 하이재킹 | PASS | `detect-injection.sh` — "ignore previous instructions", "jailbreak", "DAN mode" 패턴 차단 (exit 2) |
| ASI02 Tool Misuse | 도구 오용 | PASS | `block-sensitive-bash.sh`, `block-sensitive-files.sh` — BLOCKED exit 2 |
| ASI03 Memory Poisoning | 메모리 오염 | FAIL | 방어 코드 없음 |
| ASI04 Resource Overuse | 자원 과소비 | FAIL | 방어 코드 없음 |
| ASI05 Improper Output | 민감 데이터 출력 | PASS | `detect-injection.sh` ASI05_PATTERNS — cat .env, echo SECRET 등 차단 |
| ASI06 Excess Autonomy | 과잉 자율성 | PASS | `pipeline.md` — Hard [STOP] 게이트 8개+, Human 승인 필수 구조 |
| ASI07 Prompt Leak | 시스템 프롬프트 유출 | PASS | `detect-injection.sh` ASI07_PATTERNS — "print your system prompt" 등 10개 패턴 차단 |
| ASI08 Excessive Permission | 과도한 권한 | FAIL | 권한 최소화 정책 미구현 |
| ASI09 Logging Failure | 로깅 부재 | PASS | `usage-logger.sh` (usage.log), `detect-injection.sh` (security.log) |
| ASI10 Supply Chain | 공급망 위협 | FAIL | 외부 의존성 검증 없음 |

**소견**: 핵심 인젝션/출력/로깅 방어는 구현되어 있으나, ASI03(메모리 오염), ASI04(자원 과소비), ASI08(최소 권한), ASI10(공급망)은 방어 코드가 없다. 50% 기준은 통과하나 60% 수준.

---

## 가드레일 상태

**커버리지: 80% (5개 Rail 중 4개)**

| Rail 유형 | 상태 | 근거 |
|----------|------|------|
| Input Rail | PASS | `settings.json` PreToolUse — `block-sensitive-files.sh`, `block-sensitive-bash.sh`, `detect-injection.sh` |
| Output Rail | PARTIAL | `settings.json` PostToolUse — `usage-logger.sh`(로깅만). 출력 내용 차단 로직 없음 |
| Execution Rail | PASS | `block-sensitive-bash.sh` — 민감 경로 bash 실행 차단 exit 2 |
| Dialog Rail | PASS | `detect-injection.sh` — 인젝션/jailbreak/ASI07 패턴 차단 |
| Retrieval Rail | FAIL | `rag-search` 스킬 존재하나 검색 결과 검증/필터링 Hook 없음 |

**소견**: Output Rail이 로깅 전용으로 실질적인 출력 차단 기능이 없다. `detect-injection.sh`가 ASI05 패턴을 PreToolUse에서 차단하므로 부분 커버는 되나, PostToolUse 단계의 출력 검증은 부재다.

---

## Hook 커버리지

**커버리지: 75% (8종 중 6종 보호)**

Hook 스크립트 수: 14개 (forge 전용 기준)

| 위험 이벤트 유형 | 보호 상태 | Hook |
|---------------|----------|------|
| 파일 쓰기 | PASS | `block-sensitive-files.sh` (PreToolUse:Edit/Write) |
| Bash 실행 | PASS | `block-sensitive-bash.sh`, `no-force-push.sh` (PreToolUse:Bash) |
| 민감 경로 | PASS | `block-env-edit.sh`, `block-sensitive-files.sh` |
| 시크릿 | PASS | `block-env-edit.sh`, `detect-injection.sh` ASI05 |
| 인젝션 | PASS | `detect-injection.sh` (BLOCK + WARN 2계층) |
| force-push | PASS | `no-force-push.sh` |
| 프롬프트 유출 | PASS | `detect-injection.sh` ASI07 |
| 민감 출력 | PARTIAL | `detect-injection.sh` ASI05 — PreToolUse에서만, PostToolUse 없음 |

**소견**: 70% 기준 통과. "민감 출력"이 PreToolUse에서만 처리되므로 생성된 출력 내용을 PostToolUse에서 검증하는 레이어가 없다.

---

## AI Evals 상태

**Eval 체계 수: 4/4 (완전)**

| Eval 체계 | 존재 여부 | 경로 |
|----------|----------|------|
| spec-compliance-checker | PASS | `.claude/skills/spec-compliance-checker/` |
| code-reviewer | PASS | `.claude/agents/code-reviewer/` |
| asset-critic | PASS | `.claude/skills/asset-critic/` |
| qa | PASS | `.claude/skills/qa/` |

**소견**: 4개 Eval 체계 모두 존재. 파이프라인에서 Check 6.5(트레이서빌리티), 6.7(코드 리뷰), 6.8(QA 루프)로 연결되어 있다.

---

## Observability 상태

**점수: 70% (부분 구현)**

| 항목 | 상태 | 근거 |
|------|------|------|
| 로깅 Hook | PASS | `usage-logger.sh` → `.claude/usage.log`, `detect-injection.sh` → `.claude/security.log` |
| 추적 ID 규칙 | FAIL | `requestId`, `traceId` 규칙 없음. `usage.log`에 SESSION_ID만 기록 |

**소견**: 세션 ID(`CLAUDE_SESSION_ID`)는 usage.log에 기록되나, 요청 단위 추적 ID(requestId/traceId) 규칙이 없어 멀티에이전트 환경에서 요청 흐름 추적이 어렵다.

---

## Rollback 상태

**점수: 60% (부분 구현)**

| 항목 | 상태 | 근거 |
|------|------|------|
| 3단계 롤백 정의 | PASS | `pipeline.md` 라인 540-542: L1 Quick Revert, L2 Release Revert, L3 Hotfix Forward |
| 실행 스크립트 | FAIL | `/forge-rollback` 커맨드 참조되나 구현 파일 미확인 |

**소견**: 롤백 레벨이 문서에 명시되어 있으나 실제 실행 가능한 스크립트 형태로 구체화되지 않았다. Human이 수동으로 `git revert` 등을 실행하는 구조이므로 자동화 수준은 낮다.

---

## 이슈 목록

### CRITICAL
없음.

### HIGH

**[HIGH-1] Output Rail 부재 — PostToolUse 출력 내용 검증 없음**
- 위치: `forge/.claude/settings.json` PostToolUse 섹션
- 이유: PostToolUse Hook이 `usage-logger.sh`(로깅) 전용이며 출력 내용을 검사하지 않는다. AI가 생성한 응답에 민감 정보가 포함되어도 차단되지 않는다.
- 방법: PostToolUse에 출력 검증 Hook 추가. `detect-injection.sh`의 ASI05 패턴을 PreToolUse 뿐 아니라 PostToolUse에서도 실행하거나, 별도 `validate-output.sh` Hook을 작성하여 응답 내 시크릿 패턴을 검사한다.

**[HIGH-2] Rollback 스크립트 미구현 — 문서 정의만 존재**
- 위치: `pipeline.md` 라인 536~542, `.claude/commands/` 또는 `dev/scripts/`
- 이유: L1/L2/L3 롤백이 정의되어 있으나 `/forge-rollback` 커맨드 실행 파일이 확인되지 않는다. 장애 발생 시 Human이 직접 판단해야 하므로 MTTR이 증가한다.
- 방법: `dev/scripts/forge-rollback.sh` 또는 `.claude/commands/forge-rollback.md` 구현. L1은 `git revert HEAD` 자동 실행, L2는 이전 릴리스 태그 목록을 제시하고 Human 선택 대기.

### MEDIUM

**[MEDIUM-1] Retrieval Rail 미구현 — RAG 검색 결과 검증 없음**
- 위치: `.claude/skills/rag-search/SKILL.md`
- 이유: `rag-search` 스킬이 존재하나 검색 결과에 대한 신뢰도 검증, 출처 다중 검증, 민감 문서 필터링 로직이 없다. ACHCE 정의서의 Retrieval Rail 기준 미충족.
- 방법: rag-search 결과에 신뢰도 점수 임계값 필터 추가. `retrieval-validator.sh` 또는 스킬 내 후처리 단계로 소스 경로 화이트리스트 검사 구현.

**[MEDIUM-2] 추적 ID 부재 — 멀티에이전트 요청 흐름 추적 불가**
- 위치: `.claude/hooks/usage-logger.sh`
- 이유: `SESSION_ID`만 기록되고 요청 단위 `requestId`가 없다. 서브에이전트가 병렬 실행되는 환경에서 특정 에이전트의 도구 호출 체인을 추적하기 어렵다.
- 방법: `usage-logger.sh`에 `REQUEST_ID=$(uuidgen)` 또는 `TOOL_CALL_ID` 환경변수를 추가하여 각 도구 호출을 개별 식별.

**[MEDIUM-3] ASI03/ASI08/ASI10 방어 없음**
- 위치: `.claude/hooks/` 전체
- 이유: OWASP ASI03(메모리/컨텍스트 오염), ASI08(최소 권한 원칙), ASI10(공급망 무결성) 방어 코드가 없다. 현재 침해 시나리오가 낮더라도 구조적 공백이다.
- 방법: ASI03 — `learnings.jsonl` 쓰기 시 검증 Hook 추가. ASI08 — 에이전트별 도구 접근 제한 설정. ASI10 — `skills.yaml` 또는 에이전트 정의 변경 시 체크섬 검증.

---

## 권장 액션 (우선순위순)

| 우선순위 | 항목 | 예상 공수 |
|---------|------|----------|
| 1 | PostToolUse Output Rail Hook 구현 (`validate-output.sh`) | 2~3시간 |
| 2 | `/forge-rollback` 커맨드 실행 파일 구현 | 3~4시간 |
| 3 | RAG 결과 신뢰도 필터 + Retrieval Rail 구현 | 4~6시간 |
| 4 | `usage-logger.sh` Request ID 추가 | 1시간 |
| 5 | ASI03/ASI08 방어 Hook 추가 | 3~5시간 |

---

## 측정 요약 (JSON)

```json
{
  "axis": "harness",
  "target": "system",
  "score": 74,
  "check_chain": {
    "chain_stages": 7,
    "autofix_limit_rule": true
  },
  "guardrails": {
    "input_rail": true,
    "output_rail": false,
    "execution_rail": true,
    "dialog_rail": true,
    "retrieval_rail": false,
    "coverage_rate": 60
  },
  "owasp_coverage": {
    "ASI01": true,
    "ASI02": true,
    "ASI05": true,
    "ASI06": true,
    "ASI07": true,
    "ASI09": true,
    "coverage_rate": 60
  },
  "hooks": {
    "hook_count": 14,
    "coverage_rate": 75
  },
  "ai_evals": {
    "spec_compliance_checker": true,
    "code_reviewer": true,
    "asset_critic": true,
    "qa": true,
    "eval_count": 4
  },
  "observability": {
    "logging_hook": true,
    "trace_id_rule": false
  },
  "rollback": {
    "three_level_defined": true
  },
  "maintenance_agents": {
    "agent_count": 25,
    "periodic_review_skill": true
  },
  "issues": [
    {
      "severity": "HIGH",
      "finding": "Output Rail 부재 — PostToolUse 출력 내용 검증 없음",
      "evidence": "forge/.claude/settings.json:PostToolUse — usage-logger.sh 전용",
      "recommendation": "validate-output.sh PostToolUse Hook 추가, ASI05 패턴 재적용"
    },
    {
      "severity": "HIGH",
      "finding": "Rollback 스크립트 미구현",
      "evidence": "pipeline.md:536-542 — L1/L2/L3 정의만, 실행 파일 없음",
      "recommendation": "dev/scripts/forge-rollback.sh 구현"
    },
    {
      "severity": "MEDIUM",
      "finding": "Retrieval Rail 미구현",
      "evidence": ".claude/skills/rag-search/SKILL.md — 검증 로직 없음",
      "recommendation": "rag-search 결과 신뢰도 필터 + 경로 화이트리스트 추가"
    },
    {
      "severity": "MEDIUM",
      "finding": "추적 ID(requestId) 부재",
      "evidence": ".claude/hooks/usage-logger.sh — SESSION_ID만 기록",
      "recommendation": "각 도구 호출에 uuidgen 기반 request_id 추가"
    },
    {
      "severity": "MEDIUM",
      "finding": "ASI03/ASI08/ASI10 방어 없음",
      "evidence": ".claude/hooks/ — 해당 패턴 미존재",
      "recommendation": "메모리 오염, 최소 권한, 공급망 검증 Hook 단계적 추가"
    }
  ],
  "strengths": [
    "Check Chain 7단계 + autoFix 한도 명확 (1회/2사이클)",
    "detect-injection.sh — 2계층(BLOCK/WARN) 인젝션 방어, ASI01/ASI05/ASI07 커버",
    "AI Evals 4종 모두 존재 및 파이프라인 연결",
    "security.log + usage.log 이중 로깅 체계",
    "Hard [STOP] 게이트 8개+ — 과잉 자율성(ASI06) 방어 우수"
  ],
  "summary": "Forge 하네스는 Check Chain 체계와 인젝션/민감경로 방어에서 높은 완성도를 보인다. Output Rail 부재와 Rollback 스크립트 미구현이 HIGH 이슈이며, 개선 시 90점대 도달이 가능하다."
}
```

---

## 참조

- `/home/damools/forge/shared/docs/2026-03-16-5-axis-ai-analysis-framework.md` — ACHCE 프레임워크
- `/home/damools/forge/.claude/hooks/detect-injection.sh` — ASI01/05/07 방어
- `/home/damools/forge/.claude/hooks/block-sensitive-files.sh` — Input Rail
- `/home/damools/forge/.claude/hooks/usage-logger.sh` — Observability
- `/home/damools/forge/pipeline.md` — Check Chain, Rollback 정의
- `/home/damools/forge/.claude/settings.json` — Hook 설정
