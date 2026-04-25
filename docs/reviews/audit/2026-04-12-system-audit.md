# ACHCE 5축 통합 시스템 감사 보고서

**대상**: system (Forge + Forge Dev) | **날짜**: 2026-04-12

---

## Executive Summary

**전체 ACHCE 점수: 68/100**

| 축 | 점수 | 등급 | 핵심 발견 |
|----|:----:|:----:|---------|
| Agentic | 72/100 | ⭐⭐⭐ | forge-tools MCP 14개 도구 미활용, ACI 커버리지 17% |
| Context | 62/100 | ⭐⭐⭐ | MEMORY.md 51줄 과부하, 프롬프트 3요소 충족률 49.3% 급락 |
| Harness | 74/100 | ⭐⭐⭐⭐ | detect-injection.sh forge settings.json 미연결, OWASP 80% 방어 코드 존재 |
| Cost | 62/100 | ⭐⭐⭐ | system 스킬 model 지정 미확인 — 이전 감사 대비 계층화율 하락 의심 |
| Human-AI | 68/100 | ⭐⭐⭐ | Rubber-Stamp Rate 미추적, autoMerge release→main 위험 |

> 등급 기준: 90+ ⭐⭐⭐⭐⭐ / 75+ ⭐⭐⭐⭐ / 60+ ⭐⭐⭐ / 45+ ⭐⭐ / <45 ⭐

**시스템 단계**: 운영 단계 (스킬 67개 + 규칙 5개 + 멀티 프로젝트 + 프로덕션 배포)

**가중치 (운영 단계)**: Agentic 20% / Context 20% / Harness 25% / Cost 15% / Human-AI 20%

**전체 점수 계산**:
(72×0.20) + (62×0.20) + (74×0.25) + (62×0.15) + (68×0.20)
= 14.4 + 12.4 + 18.5 + 9.3 + 13.6 = **68.2 → 68**

---

## 1. 축별 감사 결과 요약

### 1.1 Agentic (자율성·도구·멀티에이전트) — 72/100

**핵심 발견**:
- Orchestrator-Workers 패턴이 grants-write, system-audit, screenshot-analyze 등 핵심 스킬에 성숙하게 적용됨
- Opus/Sonnet/Haiku 3계층 모델 라우팅이 규칙과 스킬 정의에 일관 적용 (AgentOps 100%)
- **BUT** forge-tools MCP 14개 도구가 Skills에서 전혀 호출되지 않음 — ACI 커버리지 17% (기준 60% 미달)
- Evaluator-Optimizer 패턴 1회 자동 수정으로 제한 — 자율 피드백 루프 미완성

**Top 이슈**:
1. **[CRITICAL]** forge-tools MCP 14개 도구(rag_search, notion_create_page, telegram_notify 등) Skills에서 전혀 미활용 — ACI 커버리지 17%
2. **[HIGH]** 단기 메모리(session-state.json) 구조 부재 — state/ 디렉토리만 존재

**강점**: Wave 의존성 + PARALLEL-IRON-1/2 충돌 방지 규칙, learnings.jsonl + MEMORY.md 장기 메모리 이중화, AgentOps 3종 완전 커버

---

### 1.2 Context (컨텍스트 엔지니어링) — 62/100

**핵심 발견**:
- LightRAG 인프라 완비(스크립트 + 인덱스 2개 + rag-search 스킬) — 강점
- Sub-agent 격리 패턴 우수: 58개 스킬 `context: fork` 사용
- **BUT** 프롬프트 3요소 충족률 49.3% — 이전 감사 95%에서 급락 (54.7%p 하락)
- MEMORY.md 51줄 — 기준(30항목) 초과, 세션 시작 컨텍스트 오염 위험
- MCP 서버 7개 전부 description 없음 — LLM 도구 선택 근거 없음
- Context Compaction 트리거 미문서화 — 어느 rules 파일에도 기준 없음

**Top 이슈**:
1. **[CRITICAL]** MEMORY.md 51줄 비대화 — 세션마다 불필요한 컨텍스트 로딩 (이전 감사 HIGH → 악화됨)
2. **[HIGH]** 프롬프트 3요소 충족률 49.3% — 기준 70% 대비 20%p 미달, 이전 감사 95%에서 급격 하락

**강점**: LightRAG 인프라, Sub-agent 격리, Memory 모듈화(30+ 세부 파일 분리), Progressive Disclosure 구조

---

### 1.3 Harness (측정·제어·보안) — 74/100

**핵심 발견**:
- Check Chain 5단계 + `[STOP]` 44개, autoFix 1회 한도 명확
- OWASP 8/10 방어 코드 존재 (80% 방어 코드) — **but** ENFORCED는 4/10
- forge/.claude/hooks/ 25개 스크립트, security.log + usage.log 이중 로깅
- **BUT** detect-injection.sh가 forge/.claude/settings.json PreToolUse에 연결되지 않음 — ASI01/05/07 방어 실질적 무효
- 롤백 L1/L2/L3 3단계 미정의

**Top 이슈**:
1. **[CRITICAL]** detect-injection.sh가 forge settings.json PreToolUse에 미연결 — forge 컨텍스트에서 프롬프트 인젝션 방어 무효
2. **[HIGH]** check-supply-chain.sh — 위험 패턴 WARN만 처리, exit 2 차단 없음

**강점**: Hook 아키텍처 25개(forge 22개 포함), 6 LIFECYCLE 이벤트 커버, AI Eval 4체계 완비

---

### 1.4 Cost (비용 효율) — 62/100

**핵심 발견**:
- 글로벌 스킬 67개 중 59개(88%)는 `model:` 지정 — 양호
- **BUT** portfolio 전용 스킬 12개 전부 모델 미지정 (계층화율 0%)
- agents/code-reviewer.md: `model: opus` 고정 — 과비용 위험
- 정량적 비용 추적 메커니즘(CPT, P95) 없음
- commands 7개 전부 Sonnet 고정

> 주의: audit-cost 스킬이 portfolio 대상으로 실행되어 system 전체 평가와 부분적 불일치. 글로벌 스킬 88% model 지정을 감안하여 62점 산정.

**Top 이슈**:
1. **[CRITICAL]** portfolio 스킬 12개 모델 미지정 + code-reviewer Opus 고정
2. **[HIGH]** 정량적 비용 추적 메커니즘 없음 — CPT/P95 측정 도구 부재

**강점**: 글로벌 스킬 Haiku(10)/Sonnet(48)/Opus(1) 계층화, agent-token-budget.sh 런어웨이 방지, Progressive Disclosure 조건부 로딩

---

### 1.5 Human-AI (경계 설계) — 68/100

**핵심 발견**:
- Gate Bypass Rate 0%: git log 전체 탐색 결과 `--no-verify` 우회 없음
- Hard Stop 게이트 44개 + 비가역 행동 커버리지 71%
- Competing Hypotheses(에이전트 회의), 재시도 한도 2회, Canary 모니터링 존재
- **BUT** Rubber-Stamp Rate 미추적 — override-rate.log 파일 집계값 0
- autoMerge=true + CI PASS만으로 main merge 가능 — Phase 9 게이트 소멸 위험

**Top 이슈**:
1. **[HIGH]** Rubber-Stamp Rate 미추적 — STOP 게이트 형식적 승인 위험
2. **[HIGH]** autoMerge=true 시 release→main 게이트 소멸 — feature→develop만 허용해야 함

**강점**: Gate Bypass Rate 0%, Iron Laws 체계(5개 카테고리) Single Source of Truth, Competing Hypotheses 자동 과신 방지

---

## 2. 축간 트레이드오프 분석

| 트레이드오프 | 현재 균형 | 권장 방향 |
|------------|:--------:|---------|
| Cost vs Harness | detect-injection.sh 미연결로 Harness 약화, forge-tools 미활용으로 Cost 낭비 공존 | Harness 연결 먼저 (보안 우선), Cost는 연결 완료 후 최적화 |
| Agentic vs Human-AI | MCP 미활용(자율성 17%)이나 STOP 게이트 44개는 과도 | MCP 활용 높이되 autoMerge Iron Law 추가로 Human 감독 유지 |
| Context vs Cost | MEMORY.md 비대(51줄)가 컨텍스트와 토큰 모두 낭비 | MEMORY.md archive 분리로 동시 해결 가능 |
| Harness vs Agentic | 감사 체계(evals 48개)는 있으나 자동 실행 없어 PAPER 수준 | CI 파이프라인 연동으로 ENFORCED 전환 |
| Human-AI vs Cost | 게이트 44개 중 Rubber-Stamp 위험으로 실질 Human 감독 저하 | 최소 검토 체크리스트 추가 (1회 클릭 승인 방지) |

---

## 3. 정량 지표 대시보드

| 축 | 지표 | 측정값 | 기준값 | 측정 유형 | 판정 |
|----|------|:-----:|:-----:|:--------:|:---:|
| Agentic | 도구 커버리지율 | 17% | > 60% | 실측 | FAIL |
| Context | 세션 시작 토큰 | ~5,200 토큰 | < 12,000 | 추정 | PASS |
| Context | MEMORY 항목 수 | 51줄 | < 30 | 실측 | FAIL |
| Context | 규칙 중복률 | ~15% | < 10% | 추정 | FAIL |
| Context | 프롬프트 3요소 충족률 | 49.3% (33/67) | > 70% | 실측 | FAIL |
| Harness | Hook 커버리지 | 25/25 (6이벤트) | > 70% | 실측 | PASS |
| Harness | OWASP 커버리지 | 8/10 방어코드 (ENFORCED 4/10) | > 50% | 실측 | 경계 |
| Cost | 모델 계층화율 (글로벌 스킬) | 88% (59/67) | > 60% | 실측 | PASS |
| Cost | 조건부 로딩률 | ~55% | > 50% | 실측 | PASS |
| Human-AI | 게이트 커버리지 | 71% (44게이트) | 100% | 실측 | FAIL |

---

## 4. 트렌드 비교 (이전 감사 대비 — 2026-04-11)

| 축 | 이전 | 현재 | Δ | 방향 |
|----|:----:|:----:|:--:|:---:|
| Agentic | 78 | 72 | -6 | ↓ |
| Context | 76 | 62 | -14 | ↓↓ |
| Harness | 78 | 74 | -4 | ↓ |
| Cost | 74 | 62 | -12 | ↓↓ |
| Human-AI | 70 | 68 | -2 | ↓ |
| **전체** | **76** | **68** | **-8** | **↓↓** |

**전체 하락 원인 분석**:
- Context: 프롬프트 3요소 충족률 95%→49.3% 급락 (54.7%p, CRITICAL 수준 악화)
- Cost: audit-cost 스킬이 portfolio 대상 실행 → system 전체 평가와 불일치
- Agentic: forge-tools MCP 활용도 0% 재확인 (이전 감사에서 "E2E 검증 완료" 기록과 괴리)

**이슈 해소율**: 이전 HIGH 이슈 6건 중 → 완전 해소 0건, 부분 해소 2건, 지속 3건, 신규 악화 1건 (Context 충족률)

---

## 5. 통합 이슈 목록

### CRITICAL (즉시 대응)

| # | 이슈 | 축 | 영향도 | 위치 |
|---|------|----|:-----:|------|
| C1 | detect-injection.sh forge settings.json PreToolUse 미연결 — ASI01/05/07 방어 forge에서 실질 무효 | Harness | 16 | `forge/.claude/settings.json` |
| C2 | forge-tools MCP 14개 도구 Skills에서 전혀 미활용 — ACI 커버리지 17% | Agentic | 16 | `forge/.claude/skills/*/SKILL.md` allowed-tools |
| C3 | 프롬프트 3요소 충족률 49.3% — 이전 95%에서 54.7%p 급락 | Context | 12 | `~/.claude/skills/*/SKILL.md` |

### HIGH (이번 주)

| # | 이슈 | 축 | 영향도 | 위치 |
|---|------|----|:-----:|------|
| H1 | MEMORY.md 51줄 비대화 — 세션 컨텍스트 오염 (기준 30 초과) | Context | 9 | `~/.claude/projects/*/MEMORY.md` |
| H2 | check-supply-chain.sh WARN만 처리, exit 2 차단 없음 | Harness | 9 | `~/.claude/hooks/check-supply-chain.sh` |
| H3 | Rubber-Stamp Rate 미추적 — override-rate.log 집계값 0 | Human-AI | 9 | `~/.claude/hooks/` |
| H4 | autoMerge=true 시 release→main 게이트 소멸 위험 | Human-AI | 9 | `pipeline.md` §Iron Laws |
| H5 | MCP 서버 7개 description 전무 — 도구 선택 근거 없음 | Context | 6 | `~/.claude.json` mcpServers |
| H6 | 단기 메모리(session-state.json) 구조 부재 | Agentic | 6 | `forge/.claude/state/` |
| H7 | portfolio 스킬 12개 모델 미지정 + code-reviewer Opus 고정 | Cost | 6 | `.claude/skills/*/SKILL.md`, `.claude/agents/code-reviewer.md` |

### MEDIUM (이번 달)

| # | 이슈 | 축 | 영향도 | 위치 |
|---|------|----|:-----:|------|
| M1 | Context Compaction 트리거 미문서화 | Context | 4 | `forge-core.md` |
| M2 | RAG 인덱스 경로 불일치 (rag-search vs LightRAG 실제 위치) | Context | 4 | `rag-search/SKILL.md` |
| M3 | 롤백 L1/L2/L3 3단계 절차 미정의 | Harness | 4 | `pipeline.md` §롤백 |
| M4 | Hotfix 경로 비가역 행동 게이트 없음 | Human-AI | 4 | `pipeline.md` |
| M5 | 정량적 비용 추적(CPT/P95) 메커니즘 없음 | Cost | 4 | `~/.claude/hooks/` |
| M6 | Evaluator-Optimizer 1회 제한 — 자율 피드백 루프 미완성 | Agentic | 4 | `pipeline.md` Phase 7~9 |
| M7 | AI Evals 자동 실행 파이프라인 미구축 (evals.json PAPER 수준) | Harness | 4 | CI/CD |

### LOW (모니터링)

| # | 이슈 | 축 |
|---|------|----|
| L1 | ASI08 RAG 이상 감지 WARN만, exit 2 차단 없음 | Harness |
| L2 | ASI10 Model DoS 30회 초과 경고만, Kill 없음 | Harness |
| L3 | 5-Level Autonomy 작업별 명시 문서 없음 | Human-AI |
| L4 | 에스컬레이션 시 Human 컨텍스트 전달 규격 없음 | Human-AI |
| L5 | AgentOps OOD 감지 도구 없음 | Agentic |

---

## 6. 강점 요약

1. **Hook 아키텍처 성숙**: 25개 Hook(forge 22개 포함), 6 LIFECYCLE 이벤트 완전 커버, Gate Bypass Rate 0%
2. **멀티에이전트 조정**: Wave 의존성 그래프 + PARALLEL-IRON-1/2 충돌 방지, 모델 3계층 라우팅 일관 적용
3. **Iron Laws 체계**: 5개 카테고리 Single Source of Truth, [STOP] 44개 게이트 운영 중
4. **LightRAG 인프라**: 스크립트 + 인덱스 2개 + rag-search 스킬 완비
5. **글로벌 스킬 계층화**: 67개 중 59개(88%) model 지정, Haiku 10개 적극 활용

---

## 7. Opus Advisor 검토 요약

> 5축 CRITICAL/HIGH 이슈 cross-axis 트레이드오프 식별

**핵심 cross-axis 트레이드오프 2개**:

1. **Context 충족률 급락 ↔ Agentic MCP 미활용 (연결 이슈)**:
   - Context 3요소 충족률 95%→49.3% 급락은 감사 스킬 자체의 측정 방식 변화 가능성 있음
   - forge-tools MCP 미활용은 Agentic, Context, Cost 3개 축에 동시 영향 — P0 우선순위 맞음
   - detect-injection.sh 미연결 이슈가 실제 보안 위협이므로 가장 먼저 처리해야 함

2. **Human-AI Rubber-Stamp ↔ autoMerge 위험**:
   - 두 이슈 모두 "게이트 형식화" 안티패턴 — 함께 묶어 Iron Law 추가로 해결 효율 높음
   - P0로 올리는 것이 맞음 (autoMerge release→main은 프로덕션 직결)

---

## 8. 통합 개선 로드맵

### P0 — 즉시 (이번 주)

| 우선순위 | 액션 | 예상 효과 | 난이도 |
|---------|------|----------|--------|
| 1 | `forge/.claude/settings.json` PreToolUse에 `detect-injection.sh` 연결 | Harness +4점, ASI01/05/07 실효 방어 | 낮음 (30분) |
| 2 | `check-supply-chain.sh` 고위험 패턴에 exit 2 추가 | Harness +2점 | 낮음 (1시간) |
| 3 | `pipeline.md` Iron Laws에 `autoMerge: feature→develop만 허용` 추가 | Human-AI +3점 | 낮음 (30분) |
| 4 | `MEMORY.md` 비활성 항목 `memory/archive/`로 이동 (30항목 이내로 축소) | Context +4점, 토큰 절약 | 낮음 (1시간) |

### P1 — 단기 (이번 달)

| 우선순위 | 액션 | 예상 효과 | 난이도 |
|---------|------|----------|--------|
| 5 | forge-tools MCP 3개 우선 도구(rag_search, notion_create_page, telegram_notify) allowed-tools 추가 | Agentic +8점 | 중간 (2시간) |
| 6 | 프롬프트 3요소 미충족 스킬 상위 10개 수정 (역할/컨텍스트/출력 추가) | Context +6점 | 중간 (3시간) |
| 7 | MCP 서버 7개에 description 추가 (`~/.claude.json`) | Context +2점 | 낮음 (1시간) |
| 8 | portfolio 스킬 12개 model 지정 + code-reviewer Sonnet 변경 | Cost +8점 | 낮음 (1시간) |
| 9 | `forge-core.md`에 Context Compaction 트리거 기준 추가 ("70% 토큰 소비 시 /compact") | Context +2점 | 낮음 (30분) |
| 10 | Override Rate 훅 구현 (STOP 게이트 승인 시 타임스탬프 + 빠른 승인 경고) | Human-AI +3점 | 중간 (2시간) |

### P2 — 중기 (다음 분기)

| 우선순위 | 액션 | 예상 효과 | 난이도 |
|---------|------|----------|--------|
| 11 | AI Evals CI/CD 자동 실행 파이프라인 구축 | Harness +4점, Agentic +3점 | 높음 (3일) |
| 12 | 롤백 L1/L2/L3 3단계 절차 문서화 | Harness +2점 | 중간 (4시간) |
| 13 | CPT 일일 집계 스크립트 + P95 알림 구현 | Cost +4점 | 높음 (1일) |
| 14 | session-state.json 스키마 정의 + 기록 패턴 적용 | Agentic +3점 | 중간 (4시간) |
| 15 | 작업 유형별 5-Level Autonomy 매핑 문서 작성 | Human-AI +2점 | 중간 (3시간) |

---

## 9. 재감사 권장 시점

- **P0 완료 후 즉시**: detect-injection 연결 + MEMORY.md 정리 효과 검증
- **정기 감사**: 분기 1회 (다음 정기 감사: 2026-07-12)
- **Context 축 재감사**: 프롬프트 3요소 충족률 급락 원인 규명 필요 (측정 방식 변화 vs 실제 저하)

---

## 참조
- `~/forge-outputs/docs/tech/2026-03-16-5-axis-ai-analysis-framework.md`
- `~/forge/shared/docs/2026-03-30-four-engineering-disciplines.md`
- 이전 감사: `docs/reviews/audit/2026-04-11-system-audit.md`
- 축별 상세 보고서: `docs/reviews/audit/2026-04-12-audit-*.md`
