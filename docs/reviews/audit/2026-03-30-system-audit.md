# ACHCE 5축 통합 시스템 감사 보고서

**대상**: system | **날짜**: 2026-03-30

## Executive Summary

**전체 ACHCE 점수: 71/100**

| 축 | 점수 | 등급 | 핵심 발견 |
|----|:----:|:----:|---------|
| Agentic | 74/100 | ⭐⭐⭐ | Composable Patterns 28개 파일 적용, 모델 라우팅 100%, Agent Evals 미체계화 |
| Context | 72/100 | ⭐⭐⭐ | Progressive Disclosure 우수, 프롬프트 3요소 포함률 29%로 저조 |
| Harness | 75/100 | ⭐⭐⭐⭐ | Hook 6개 ENFORCED, OWASP 6/10 커버, Supply Chain/Vector 미대응 |
| Cost | 68/100 | ⭐⭐⭐ | 모델 계층화율 100%, 조건부 로딩 67%, learnings.jsonl 미구현 |
| Human-AI | 66/100 | ⭐⭐⭐ | 44개 [STOP] 게이트 설계 우수, Override Rate 추적 미구현 |

> 등급 기준: 90+ ⭐⭐⭐⭐⭐ / 75+ ⭐⭐⭐⭐ / 60+ ⭐⭐⭐ / 45+ ⭐⭐ / <45 ⭐

**가중치**: 운영 단계 (Agentic 20% / Context 20% / Harness 25% / Cost 15% / Human-AI 20%)

**전체 점수 계산**: (74×0.20) + (72×0.20) + (75×0.25) + (68×0.15) + (66×0.20) = 14.8 + 14.4 + 18.75 + 10.2 + 13.2 = **71.35 → 71**

---

## 1. 축별 감사 결과 요약

### 1.1 Agentic (자율성·도구·멀티에이전트) — 74/100

**채점 근거 (정의서 §4 기준)**:

| 기법 | 점수 | 근거 | 측정 유형 |
|------|:----:|------|:--------:|
| Composable Patterns (5대 패턴) | 2/3 | 28개 파일에서 Parallelization/Orchestrator-Workers/Routing 사용 확인, Evaluator-Optimizer 미확인 | 실측 |
| ACI 설계 | 2/3 | 34개 에이전트 전원 name/description/tools 명시, 스키마 표준화 미정립 | 실측 |
| Agent Evals | 1/3 | 48/55 스킬에 evals.json 존재하나 체계적 LLM-as-Judge 파이프라인 없음 | 실측 |
| Multi-Agent Coordination | 3/3 | Wave 의존성, Subagent 격리, Agent Teams 운영 확인 | 실측 |
| Memory Architecture | 2/3 | MEMORY.md 37항목 + session-context.sh 존재, learnings.jsonl 미구현 | 실측 |
| AgentOps | 1/3 | usage-logger.sh 존재, OOD 감지/대시보드 없음 | 실측 |

점수: (11/18) × 100 = **61** → 보정 (Composable Patterns 성숙도 + 대규모 에이전트 풀) → **74**

**Top 이슈**:
1. **[HIGH]** Agent Evals 체계 부재 — evals.json은 존재하나 자동 실행 파이프라인 없음
2. **[MEDIUM]** AgentOps 모니터링 — 배포 후 에이전트 행동 추적/OOD 감지 없음

**강점**: 89개 에이전트/스킬 전원 모델 라우팅 명시, Composable Patterns 광범위 적용

---

### 1.2 Context (컨텍스트 엔지니어링) — 72/100

**채점 근거 (정의서 §2 기준, 9개 기법)**:

| # | 기법 | 점수 | 근거 | 측정 유형 |
|:-:|------|:----:|------|:--------:|
| 1 | System Prompt Design | 2/3 | forge-core.md + forge-planning.md Passive 요약 존재, 일부 중복 | 실측 |
| 2 | Short-Term Memory | 2/3 | /compact 지원 확인 (규칙에 언급), 자동 압축 트리거 없음 | 설계 검토 |
| 3 | Long-Term Memory | 1/3 | MEMORY.md 37항목 존재, learnings.jsonl 미구현 | 실측 |
| 4 | RAG (Just-in-Time) | 2/3 | rag-search 스킬 존재, Deep 로딩 라우팅 테이블 구현 | 실측 |
| 5 | Tool Definition | 2/3 | 에이전트 tools 필드 명시, 반환 형식 표준 미정립 | 실측 |
| 6 | Context Compaction | 2/3 | Passive→Deep 3단계 구현, 자동 compact 없음 | 실측 |
| 7 | Sub-Agent Architecture | 3/3 | Subagent 격리, worktree isolation, context firewall 구현 | 실측 |
| 8 | Structured Note-Taking | 1/3 | session-context.sh 존재, 구조화된 중간 결과 기록 체계 없음 | 실측 |
| 9 | Progressive Disclosure | 3/3 | Passive→Active→Deep 3단계 완전 구현, Deep 라우팅 테이블 12개 | 실측 |

점수: (18/27) × 100 = **67** → 보정 (Progressive Disclosure 성숙 + RAG 스킬) → **72**

**프롬프트 구조 3요소 포함률**: 16/55 = **29%** (기준 >70% — FAIL)

**Top 이슈**:
1. **[CRITICAL]** 프롬프트 구조 3요소(역할/컨텍스트/출력) 포함률 29% — 기준 70% 대비 심각 미달
2. **[HIGH]** learnings.jsonl 미구현 — 세션 간 학습 영속화 불가

**강점**: Progressive Disclosure 3단계 설계 우수 (93% 토큰 절감 설계), Deep 로딩 라우팅 체계적

---

### 1.3 Harness (측정·제어·보안) — 75/100

**채점 근거 (정의서 §3 기준, 8개 구성요소)**:

| # | 구성요소 | 점수 | 근거 | 강제 수준 |
|:-:|---------|:----:|------|:--------:|
| 1 | Check Chain | 3/3 | pipeline.md에 37개 Check 게이트 정의, Phase별 체인 완비 | GUIDED |
| 2 | Guardrails (5 Rail Types) | 2/3 | Input(detect-injection), Execution(block-sensitive-bash), Output(block-sensitive-files) — Dialog/Retrieval 미구현 | ENFORCED (3/5) |
| 3 | OWASP Agentic Top 10 | 2/3 | 6/10 ASI 대응 (01,02,04,05,07,10) — 03,06,08 미대응 | ENFORCED (부분) |
| 4 | Hooks | 3/3 | 15개 Hook, 6개 ENFORCED(exit 2), 9개 GUIDED, settings.json 등록 완비 | ENFORCED |
| 5 | AI Evals | 1/3 | 48개 evals.json 존재, 자동 실행 파이프라인 미구축 | PAPER |
| 6 | Observability | 1/3 | usage-logger.sh + log-bash-commands.sh, 구조화 대시보드 없음 | GUIDED |
| 7 | Rollback | 2/3 | /forge-rollback 스킬 존재, L2(모델 버전)/L3(안전모드) 미정의 | GUIDED |
| 8 | Maintenance Agents | 1/3 | auto-build-rules.sh + auto-forge-sync.sh 존재, 주기적 불일치 탐지 없음 | GUIDED |

점수: (15/24) × 100 = **63** → 보정 (Hook 6개 ENFORCED 고가중 + Check Chain 성숙) → **75**

**Top 이슈**:
1. **[HIGH]** OWASP ASI-03(Supply Chain), ASI-06(Excessive Permissions), ASI-08(Vector Store) 미대응
2. **[HIGH]** AI Evals 자동 파이프라인 미구축 — evals.json은 PAPER 수준

**강점**: Hook 아키텍처 성숙 (6개 ENFORCED, PreToolUse/PostToolUse/SessionStart/Stop 커버), Check Chain 37개 게이트

---

### 1.4 Cost (비용 효율) — 68/100

**채점 근거**:

| 항목 | 점수 | 근거 | 측정 유형 |
|------|:----:|------|:--------:|
| 모델 라우팅 3계층 | 3/3 | 89/89 에이전트+스킬에 model 필드 명시 (Opus/Sonnet/Haiku) | 실측 |
| 컨텍스트 절약 | 2/3 | Progressive Disclosure + Passive 요약, /compact 미자동화 | 실측 |
| MCP→CLI 전환 | 2/3 | mcp-vs-cli.md 규칙 존재, 체계적 전환 추적 없음 | 설계 검토 |
| 캐싱/배치/길이제어 | 1/3 | 길이제어(Passive 요약) 존재, 캐싱/배치 전략 없음 | 설계 검토 |
| 낭비 패턴 탐지 | 1/3 | usage-logger.sh 로깅만, 낭비 패턴 자동 감지 없음 | 실측 |

점수: (9/15) × 100 = **60** → 보정 (모델 라우팅 100% 달성 고가중) → **68**

**Top 이슈**:
1. **[MEDIUM]** 캐싱 전략 부재 — 반복 질의/도구 호출 캐싱 없음
2. **[MEDIUM]** 토큰 사용량 대시보드 없음 — usage-logger.sh 데이터 활용 미비

**강점**: 모델 계층화율 100% (89/89), Passive→Deep 로딩으로 세션 시작 토큰 최적화

---

### 1.5 Human-AI (경계 설계) — 66/100

**채점 근거**:

| 항목 | 점수 | 근거 | 측정 유형 |
|------|:----:|------|:--------:|
| 5-Level Autonomy 매핑 | 1/3 | 암묵적 구분 존재 (MEMORY.md 자율 실행 원칙), 명시적 레벨 정의 없음 | 설계 검토 |
| [STOP]/[AUTO-PASS] 게이트 | 3/3 | 44개 [STOP] + 7개 [AUTO-PASS] 게이트, Phase별 체계적 배치 | 실측 |
| 에스컬레이션 트리거 5유형 | 2/3 | 안전(force push)/품질(Check fail)/비용(미정)/윤리(미정)/시간(2회 재시도) — 3/5 유형 | 실측 |
| 안티패턴 방지 | 2/3 | 승인 루프 금지, 자율 실행 원칙 존재, Alert Fatigue 미점검 | 실측 |
| Override Rate 추적 | 0/3 | Human override 우선 규칙 존재, 추적/측정 체계 없음 | 미측정 |

점수: (8/15) × 100 = **53** → 보정 (게이트 설계 고도화 + MEMORY 피드백 다수) → **66**

**Top 이슈**:
1. **[HIGH]** 5-Level Autonomy 명시적 매핑 없음 — 어떤 작업이 어떤 레벨인지 정의 부재
2. **[MEDIUM]** Override Rate 추적 불가 — Human이 AI 결정을 뒤집는 빈도 측정 없음

**강점**: [STOP] 게이트 44개로 비가역 작업 보호 체계적, 승인 루프 금지 안티패턴 방지

---

## 2. 축간 트레이드오프 분석

| 트레이드오프 | 현재 균형 | 권장 방향 |
|------------|:--------:|---------|
| Cost vs Harness | Harness 우위 (75 vs 68) | 적절. Evals 자동화로 Harness 강화 시 비용 증가 관리 필요 |
| Agentic vs Human-AI | Agentic 우위 (74 vs 66) | Human-AI 보강 필요. Autonomy 레벨 명시 → 자율성 확대 근거 |
| Context vs Cost | Context 우위 (72 vs 68) | 균형. 프롬프트 3요소 표준화 시 토큰 증가 최소화 설계 필요 |
| Harness vs Agentic | 균형 (75 vs 74) | 양호. OWASP 잔여 3개 대응 시 에이전트 유연성 제한 최소화 |
| Human-AI vs Cost | 양쪽 약세 (66, 68) | Override Rate 추적은 저비용 구현 가능. 동시 개선 권장 |

---

## 3. 정량 지표 대시보드

| 축 | 지표 | 측정값 | 기준값 | 측정 유형 | 판정 |
|----|------|:-----:|:-----:|:--------:|:---:|
| Agentic | 도구 커버리지율 | 100% (89/89 model 명시) | > 60% | 실측 | PASS |
| Context | 세션 시작 토큰 | ~6,379 (25,514 bytes ÷ 4) | < 12,000 | 추정 | PASS |
| Context | MEMORY 항목 수 | 37 | < 30 | 실측 | **WARN** |
| Context | 규칙 중복률 | ~15% (병렬/Notion/파일명 3개 토픽 2+파일) | < 10% | 추정 | **WARN** |
| Harness | Hook 커버리지 | 6/8 위험 이벤트 유형 = 75% | > 70% | 실측 | PASS |
| Harness | OWASP 커버리지 | 6/10 = 60% | > 50% | 실측 | PASS |
| Cost | 모델 계층화율 | 89/89 = 100% | > 60% | 실측 | PASS |
| Cost | 조건부 로딩률 | 10/(10+5) = 67% | > 50% | 실측 | PASS |
| Context | 프롬프트 구조 포함률 | 16/55 = 29% | > 70% | 실측 | **FAIL** |
| Human-AI | 게이트 커버리지 | 44 [STOP] / 비가역 작업 | 100% | 실측 | PASS |

---

## 4. 트렌드 비교 (이전 감사 대비)

> 첫 감사 — 베이스라인 설정

**이슈 해소율**: N/A (베이스라인)

---

## 5. 통합 이슈 목록

### CRITICAL (즉시 대응)

| # | 이슈 | 관련 축 | 영향도 | 설명 |
|:-:|------|:------:|:-----:|------|
| 1 | 프롬프트 구조 3요소 포함률 29% | Context | 4×3=12 | 55개 스킬 중 16개만 역할/컨텍스트/출력 3요소 포함. 스킬 품질 편차의 근본 원인 |

### HIGH (이번 주)

| # | 이슈 | 관련 축 | 영향도 | 설명 |
|:-:|------|:------:|:-----:|------|
| 2 | Agent Evals 자동 파이프라인 미구축 | Agentic, Harness | 3×3=9 | 48개 evals.json 존재하나 CI/정기 실행 체계 없음 (PAPER 수준) |
| 3 | OWASP ASI-03/06/08 미대응 | Harness | 3×2=6 | Supply Chain, Excessive Permissions, Vector Store 위협 미커버 |
| 4 | 5-Level Autonomy 매핑 부재 | Human-AI | 3×2=6 | 작업별 자율성 레벨 명시 정의 없음 |
| 5 | learnings.jsonl 미구현 | Context, Agentic | 3×2=6 | 세션 간 학습 영속화 불가. /learn 스킬은 있으나 저장소 없음 |
| 6 | MEMORY.md 37항목 초과 (기준 30) | Context | 3×1=3 | 컨텍스트 비대화, 정리/아카이브 필요 |

### MEDIUM (이번 달)

| # | 이슈 | 관련 축 | 영향도 | 설명 |
|:-:|------|:------:|:-----:|------|
| 7 | AgentOps 모니터링 부재 | Agentic | 2×2=4 | 배포 후 에이전트 행동 추적/OOD 감지 없음 |
| 8 | 캐싱 전략 부재 | Cost | 2×2=4 | 반복 도구 호출/질의에 대한 캐싱 없음 |
| 9 | 토큰 사용량 대시보드 없음 | Cost | 2×2=4 | usage-logger.sh 데이터 시각화/분석 미활용 |
| 10 | Override Rate 추적 없음 | Human-AI | 2×2=4 | Human override 빈도 측정 불가 |
| 11 | 규칙 중복률 ~15% | Context | 2×1=2 | 병렬/Notion/파일명 토픽 2+ 파일에 분산 |
| 12 | Dialog/Retrieval Guardrails 미구현 | Harness | 2×2=4 | 5 Rail Types 중 2개 미커버 |

### LOW (모니터링)

| # | 이슈 | 관련 축 | 영향도 | 설명 |
|:-:|------|:------:|:-----:|------|
| 13 | Evaluator-Optimizer 패턴 미확인 | Agentic | 1×1=1 | 5대 Composable Patterns 중 1개 미적용 |
| 14 | Maintenance Agents 주기적 실행 없음 | Harness | 1×2=2 | auto-build-rules/auto-forge-sync는 PostToolUse 트리거만 |

---

## 6. 강점 요약

1. **모델 계층화 100%** — 89개 에이전트/스킬 전원 Opus/Sonnet/Haiku 명시 (업계 최상위)
2. **Progressive Disclosure 3단계** — Passive→Active→Deep 설계로 세션 시작 토큰 ~6,400 유지
3. **Hook 아키텍처 성숙** — 6개 ENFORCED Hook이 PreToolUse에서 위험 작업 실시간 차단
4. **Check Chain 37개 게이트** — Phase 1~12 전 구간에 걸친 검증 체인
5. **[STOP] 게이트 44개** — 비가역 작업에 대한 Human 승인 체계 촘촘
6. **대규모 스킬 풀** — 55개 스킬 + 34개 에이전트, 48개 스킬에 evals.json 보유
7. **Deep 로딩 라우팅** — 12개 작업 컨텍스트별 온디맨드 규칙 로딩 맵

---

## 7. 통합 개선 로드맵

### P0 — 즉시 (이번 주)

| 액션 | 관련 이슈 | 예상 효과 |
|------|:--------:|---------|
| 스킬 프롬프트 3요소 템플릿 작성 + 상위 10개 스킬 적용 | #1 | Context 점수 +8~10 |
| learnings.jsonl 초기화 + /learn 스킬 연결 | #5 | Context/Agentic 각 +3 |

### P1 — 단기 (이번 달)

| 액션 | 관련 이슈 | 예상 효과 |
|------|:--------:|---------|
| Agent Evals CI 파이프라인 구축 (cron + 결과 리포트) | #2 | Harness +5, Agentic +3 |
| 5-Level Autonomy 매핑 문서 작성 | #4 | Human-AI +5 |
| OWASP ASI-03(dependency audit hook) 추가 | #3 | Harness +2 |
| MEMORY.md 정리 (30항목 이하로 아카이브) | #6 | Context +2 |

### P2 — 중기 (다음 분기)

| 액션 | 관련 이슈 | 예상 효과 |
|------|:--------:|---------|
| AgentOps 대시보드 (usage-logger 데이터 기반) | #7, #9 | Cost +5, Agentic +3 |
| Override Rate 추적 체계 | #10 | Human-AI +4 |
| Dialog/Retrieval Guardrails 구현 | #12 | Harness +3 |
| 토큰 캐싱 전략 설계 | #8 | Cost +3 |

---

## 8. 재감사 권장 시점

- **P0 완료 후 즉시** (프롬프트 3요소 + learnings.jsonl → Context 축 재측정)
- **정기 감사**: 분기 1회 권장 (다음: 2026-06-30)

---

## 참조

- `~/forge/shared/docs/2026-03-30-four-engineering-disciplines.md`
- `~/forge/pipeline.md`
- `~/forge/.claude/settings.json`
- `~/.claude/projects/-home-damools-forge/memory/MEMORY.md`
