ㅅㅜㅈ# 4대 AI 엔지니어링 기술 정의서

> Forge 시스템에 적용되는 4개 엔지니어링 규율의 정의, 범위, 핵심 기법, 관계를 정리한다.
> 출처: 2025-2026 최신 학술/업계 자료 기반. 각 정의에 출처를 명시한다.

---

## 계층 관계

```
┌─────────────────────────────────────────────────────┐
│              Agentic Engineering                     │
│  (최상위: 에이전트 시스템 설계·운영 전체)              │
│                                                     │
│  ┌──────────────────┐ ┌──────────────────┐          │
│  │    Context        │ │    Harness        │          │
│  │    Engineering    │ │    Engineering    │          │
│  │  (정보 설계)      │ │  (제어·검증)      │          │
│  │                  │ │                  │          │
│  │  ┌────────────┐  │ │                  │          │
│  │  │  Prompt     │  │ │                  │          │
│  │  │  Eng.       │  │ │                  │          │
│  │  │ (입력 설계) │  │ │                  │          │
│  │  └────────────┘  │ │                  │          │
│  └──────────────────┘ └──────────────────┘          │
└─────────────────────────────────────────────────────┘
```

- **Prompt Engineering** ⊂ **Context Engineering** ⊂ **Agentic Engineering**
- **Harness Engineering** ⊂ **Agentic Engineering** (Context와 병렬)
- Prompt Engineering은 죽지 않았다 — Context Engineering의 하위 구성요소로 편입

---

## 1. Prompt Engineering (프롬프트 엔지니어링)

### 정의

> "LLM에 보내는 입력 텍스트의 내용과 구조를 정제하여, 모델 파라미터 변경 없이 성능을 향상시키는 기술."
> — The Prompt Report (Schulhoff et al., arXiv 2406.06608)

### 범위

**단일 입력-출력 쌍** 내에서 작동. 세션 간 지속성, 동적 맥락 구성은 범위 외.

### 핵심 기법

| 기법 | 설명 | 효과 |
|------|------|------|
| Zero/Few-Shot | 예시 없이 또는 소수 예시로 지시 | Few-shot: 30%+ 향상 |
| Chain-of-Thought (CoT) | "단계별로 생각해" 추론 유도 | 추론 벤치마크 30-50% 향상 |
| Role/Persona | "당신은 ~전문가입니다" 역할 지정 | 도메인 품질 향상 |
| Structured Output | JSON 스키마, 형식 제약 명시 | 출력 변동성 35% 감소, 오류 76% 감소 |
| Self-Refine | 출력 자기 비판 → 재생성 루프 | 반복 정제 |
| Decomposition | 복잡 문제를 하위 단계로 분해 | 복잡 태스크 정확도 향상 |

### 측정 가능한 결과

- 태스크 정확도 변화율 (프롬프트 A vs B)
- 출력 형식 준수율
- 할루시네이션 발생률
- 토큰 효율 (동일 결과에 필요한 토큰 수)

### 2025-2026 현재 위상

죽지 않았다. **Context Engineering의 하위 구성요소로 편입**. 단발성 작업에서는 여전히 핵심. 에이전트 시스템에서는 Context Engineering의 한 레이어.

### 출처

- Schulhoff et al. (2025). *The Prompt Report*. arXiv:2406.06608
- Lakera. (2026). *The Ultimate Guide to Prompt Engineering in 2026*
- IBM. (2026). *The 2026 Guide to Prompt Engineering*

---

## 2. Context Engineering (컨텍스트 엔지니어링)

### 정의

> "LLM이 태스크를 완수하는 데 필요한 모든 정보를 올바른 형식으로, 올바른 시점에 제공하는 동적 시스템을 설계하고 구축하는 규율."
> — Philipp Schmid (Hugging Face / Google DeepMind)

> "컨텍스트 윈도우에 딱 맞는 정보를 채우는 섬세한 예술이자 과학."
> — Andrej Karpathy

### 범위

단일 프롬프트가 아니라 **런타임 정보 환경 전체** — 시스템 프롬프트, 대화 이력, 메모리, RAG 결과, 도구 정의, 출력 형식까지.

### 핵심 기법

| # | 기법 | 설명 | 분류 |
|:-:|------|------|------|
| 1 | System Prompt Design | 행동 지침을 적절한 추상화 수준으로 작성 | 정적 |
| 2 | Short-Term Memory | 대화 이력 선택적 포함/압축 | 동적 |
| 3 | Long-Term Memory | 세션 간 지식 영속화 (learnings.jsonl, MEMORY.md) | 영속 |
| 4 | RAG (Just-in-Time) | 런타임에 관련 문서를 검색하여 주입 | 외부 |
| 5 | Tool Definition | 도구 설명을 LLM이 이해하기 쉽게 설계, 토큰 효율 반환 | 도구 |
| 6 | Context Compaction | 긴 대화의 핵심만 보존하여 압축 (/compact) | 토큰 관리 |
| 7 | Sub-Agent Architecture | 독립 컨텍스트로 태스크 위임 ("context firewall") | 아키텍처 |
| 8 | Structured Note-Taking | 에이전트가 외부 메모리에 중간 결과 지속 기록 | 상태 관리 |
| 9 | Progressive Disclosure | Passive→Active→Deep 3단계 점진적 로딩 (93% 토큰 절감) | 로딩 전략 |

### Prompt Engineering과의 구별

| 축 | Prompt Engineering | Context Engineering |
|----|-------------------|---------------------|
| 단위 | 단일 텍스트 문자열 | 런타임 정보 환경 전체 |
| 시점 | 정적 (사전 작성) | 동적 (추론 시점 조립) |
| 핵심 질문 | "어떻게 물어볼까?" | "어떤 정보 배치가 원하는 동작을 만드는가?" |
| 적용 대상 | 단발성 LLM 호출 | 멀티스텝 에이전트 파이프라인 |

### 핵심 인사이트

> "에이전트 실패의 대부분은 모델 실패가 아니라 컨텍스트 실패다."
> — Anthropic Engineering Blog

### 측정 가능한 결과

- 세션 시작 토큰 수 (낮을수록 효율적)
- Context Rot 발생 지점 (토큰 N 이상에서 recall 저하)
- 에이전트 자율 실행 시간 (중간 개입 없이)
- 압축 후 태스크 성공률 유지 여부

### 기원

Tobi Lutke (Shopify CEO, 2025.06) 명명 → Karpathy 공개 지지 → Philipp Schmid 체계화 → Anthropic 공식 문서화

### 출처

- Schmid, P. (2025). *The New Skill in AI is Not Prompting, It's Context Engineering*. philschmid.de
- Anthropic. (2025). *Effective Context Engineering for AI Agents*
- Karpathy, A. (2025). X post
- Gartner. (2025). *Context Engineering: Why it's Replacing Prompt Engineering for Enterprise AI*

---

## 3. Harness Engineering (하네스 엔지니어링)

### 정의

> "코딩 에이전트 = AI 모델 + 하네스. 하네스는 에이전트가 대규모 AI 워크로드를 일관되고 신뢰할 수 있게 실행하도록 구성하는 시스템 전체."
> — OpenAI / Ryan Lopopolo (2026.02)

> "AI 에이전트가 올바른 동작을 하도록 제약하고 검증하는 도구와 실천법 일체."
> — Martin Fowler (2026.02)

### 용어 확립 여부

**2026년 2월에 OpenAI가 도입한 신생 용어.** 학술 정의 없음. Martin Fowler: "The term is only 2 weeks old." 단, 하위 구성 기법(Guardrails, Evals, OWASP)은 각각 확립된 분야.

### 범위

Context Engineering이 "무엇을 보여줄까"라면, Harness Engineering은 **"올바르게 작동하는지 어떻게 보장할까"** — 테스트, 보안, 관측, 제약.

### 핵심 구성요소

| # | 구성요소 | 설명 | 확립 여부 |
|:-:|---------|------|:---------:|
| 1 | Check Chain | 코드 검증 단계 체인 (build→test→lint→type→review) | Forge 고유 |
| 2 | Guardrails | 5 Rail Types: Input/Dialog/Retrieval/Output/Execution | 확립 (NeMo) |
| 3 | OWASP Agentic Top 10 | ASI01-10 에이전트 보안 위협 대응 | 확립 (OWASP 2026) |
| 4 | Hooks | 에이전트 라이프사이클 이벤트에 트리거되는 스크립트 | 확립 (Claude Code) |
| 5 | AI Evals | LLM 출력 품질 평가 (LLM-as-Judge, 태스크 완수율) | 확립 |
| 6 | Observability | 구조화 로깅, requestId 추적, 토큰 사용량 | 확립 (OTel GenAI) |
| 7 | Rollback | L1 프롬프트→L2 모델 버전→L3 안전모드 | OpenAI 정의 |
| 8 | Maintenance Agents | 문서 불일치, 아키텍처 위반을 주기적으로 탐지하는 에이전트 | OpenAI 정의 |

### 핵심 공식

```
에이전트 = 모델 + 하네스
하네스 = Context Engineering + Architectural Constraints + Maintenance Agents
```

### 측정 가능한 결과

- Hook 커버리지 (보호된 위험 이벤트 / 전체 위험 이벤트)
- OWASP 커버리지 (대응 ASI 수 / 10)
- Check Chain 통과율
- 롤백 소요 시간

### 출처

- OpenAI / Lopopolo, R. (2026.02). *Harness Engineering: Leveraging Codex in an Agent-First World*
- Fowler, M. (2026.02). *Harness Engineering*. martinfowler.com
- HumanLayer / Trivedy, V. (2026). *Skill Issue: Harness Engineering for Coding Agents*
- OWASP. (2026). *Top 10 for Agentic Applications*

---

## 4. Agentic Engineering (에이전틱 엔지니어링)

### 정의

> "LLM 기반 에이전트가 코드 작성·실행·테스트·배포를 자율적으로 수행하는 환경에서, 인간이 목표 정의·아키텍처·품질 기준·최종 판단을 담당하는 소프트웨어 엔지니어링 규율."
> — ICSE AGENT 2026 + Karpathy (2026) 종합

> "AI가 구현하고, 인간이 아키텍처·품질·정확성을 소유한다 — 시간의 99%는 에이전트를 지휘하지, 코드를 작성하지 않는다."
> — Andrej Karpathy (2026)

### 용어 확립 여부

**2026년 확립 중.** Karpathy 명명, ICSE 2026(SE 최상위 학회)에서 AGENT 2026 전용 워크숍 채택. 이전 학술 용어 "AOSE", "MAS"를 대체 중.

### 범위

**최상위 규율**. Context Engineering, Harness Engineering, Prompt Engineering을 모두 포함하며, 에이전트 시스템의 설계·구축·운영·평가 전체를 다룬다.

### 핵심 기법

**Anthropic 5대 Composable Patterns (업계 표준)**:

| 패턴 | 설명 | 적합 상황 |
|------|------|----------|
| Prompt Chaining | LLM 호출 순차 연결 + 중간 검증 | 선형 분해 가능 태스크 |
| Routing | 입력 분류 → 전문 핸들러 분기 | 다양한 입력 유형 |
| Parallelization | 독립 서브태스크 병렬 실행 | 독립 병렬 + 투표 |
| Orchestrator-Workers | 중앙 LLM이 동적 태스크 분배 | 예측 불가 서브태스크 |
| Evaluator-Optimizer | 생성+평가 LLM 루프 | 명확 품질 기준 반복 정제 |

**핵심 엔지니어링 영역**:

| 영역 | 설명 |
|------|------|
| ACI (Agent-Computer Interface) | 도구 설명·스키마·출력 계약 표준화. HCI만큼 중요 |
| Agent Evals | 전통 테스팅과 구별. LLM-as-Judge, OOD 감지 |
| Multi-Agent Coordination | 에이전트 간 통신, 핸드오프, Wave 의존성 |
| Memory Architecture | 단기(대화) + 장기(세션 간) 메모리 설계 |
| AgentOps | 배포 후 모니터링, OOD 감지 — DevOps의 에이전트 확장 |
| Problem Specification | 에이전트에 목표·제약·품질 기준을 정확히 전달 (요구사항 공학 진화) |

### 전통 SE와의 구별

| 차원 | 전통 SE | Agentic Engineering |
|------|---------|---------------------|
| 코드 작성자 | 인간 | AI 에이전트 (인간은 감독) |
| 실행 흐름 | 결정론적 | 확률론적, 동적 의사결정 |
| 테스트 | 단위/통합 | Evals (태스크 완수율, LLM-as-Judge) |
| 주요 역할 | 코드 작성, 디버깅 | 목표 정의, 아키텍처, 품질 감독 |
| 실패 모드 | 로직 버그 | 컨텍스트 실패, 도구 오용, 에이전트 드리프트 |
| 핵심 인터페이스 | HCI | ACI (Agent-Computer Interface) |

### 측정 가능한 결과

- 에이전트 태스크 완수율
- 인간 개입 횟수 (Human-in-the-Loop 빈도)
- 도구 커버리지율 (사용 도구 / 등록 도구)
- 모델 계층화율 (적합 모델 사용 비율)
- OOD 동작 감지율

### 출처

- ICSE AGENT 2026 Workshop
- Karpathy, A. / Glide. (2026). *What is Agentic Engineering?*
- Willison, S. (2026-03-15). *What is Agentic Engineering?*
- Anthropic. (2024). *Building Effective Agents*
- IBM Think. (2026). *What is Agentic Engineering?*

---

## Forge 시스템 적용 현황

| 규율 | 적용 수준 | 근거 |
|------|:--------:|------|
| Prompt Engineering | GUIDED | soul-prompt-craft(이미지 전용), 스킬 프롬프트 표준 미정립 |
| Context Engineering | GUIDED (70%) | forge-context-engineering.md, Progressive Disclosure, /compact, Subagent 격리 |
| Harness Engineering | ENFORCED (40%) | Hook 5개 실제 차단, Check Chain, OWASP 50% 커버 |
| Agentic Engineering | GUIDED (30%) | Composable Patterns 사용 중이나 체계적 분류/평가 없음 |

### 갭 분석

| 갭 | 설명 | 우선순위 |
|----|------|:--------:|
| 프롬프트 구조 표준 | 스킬/에이전트 프롬프트 3요소(역할/컨텍스트/출력) 가이드 없음 | P1 |
| ACI 설계 표준 | 도구 설명 품질 가이드 없음 | P1 |
| Agent Evals | LLM-as-Judge, 태스크 완수율 측정 체계 없음 | P2 |
| AgentOps | 배포 후 에이전트 행동 모니터링 없음 | P2 |
| SLO 정의 | AI 품질 기준 (pass@k, 침묵 에러율) 미정의 | P2 |

---

*작성: 2026-03-30 | 출처: 23개 학술/업계 자료 기반 (본문 내 명시)*
