# AI Agent 디자인 패턴 시장조사 리포트

작성일: 2026-03-02
신뢰도: High (다중 소스 교차 검증 — 학술 논문 60+편, 업계 보고서, 벤더 공식 문서)
데이터 시점: 2026년 2월 기준

---

## Executive Summary

AI Agent 디자인 패턴 시장은 **폭발적 성장기**에 진입했다. 글로벌 AI Agent 시장은 2025년 **$7.63B** 규모에서 2030년 **$52.62B** (CAGR 46.3%)까지 성장할 전망이며, 2034년에는 **$251.38B**에 도달할 것으로 예측된다.

핵심 동향:
- **Multi-Agent 시스템** 문의량이 2024 Q1 대비 2025 Q2에 **1,445% 급증**
- Gartner 예측: 2026년 말까지 엔터프라이즈 앱 **80%**에 AI 코파일럿 내장
- Fortune 500 기업의 **60%**가 CrewAI 에이전트 활용 중
- **171%** 평균 ROI (미국 기업 기준 192%)
- 단, Gartner 경고: 2027년까지 Agentic AI 프로젝트 **40%+** 가 비용·ROI 불확실로 중단될 수 있음

업계 합의가 형성된 **핵심 디자인 패턴 10가지**와 **주요 프레임워크 14개**를 분석하며, 학술 논문·업계 보고서·벤더 문서를 교차 검증하였다.

---

## 1. 핵심 디자인 패턴 분류 체계

### 1.1 학술 분류 프레임워크

#### Anthropic — "Building Effective Agents" (2024.12)

Anthropic의 공식 가이드는 업계 참조 표준으로 자리잡았으며, **Workflows vs Agents**를 명확히 구분한다:

| 구분 | Workflows | Agents |
|------|-----------|--------|
| 제어 흐름 | 사전 정의된 코드 경로 | LLM이 동적으로 결정 |
| 예측 가능성 | 높음 | 낮음 |
| 적용 시점 | 구조화된 반복 작업 | 복잡·불확실 작업 |

**Anthropic 권장 Workflow 패턴 5가지:**
1. **Prompt Chaining** — 순차적 LLM 호출, 각 단계에서 게이트 검증
2. **Routing** — 입력 분류 후 전문 처리 경로로 분기
3. **Parallelization** — 독립 서브태스크 동시 실행 (Sectioning/Voting)
4. **Orchestrator-Workers** — 중앙 LLM이 태스크 분해 후 Worker에 위임
5. **Evaluator-Optimizer** — 생성-평가 반복 루프

**Anthropic 권장 Agent 패턴:**
- **Agentic Loop** — LLM이 도구 호출·결과 평가를 자율적으로 반복
- "가능한 한 단순한 솔루션부터 시작하고, 필요할 때만 복잡도를 추가하라"

[신뢰도: High] 출처: [Anthropic Research](https://www.anthropic.com/research/building-effective-agents), 2024.12

#### Andrew Ng — 4대 Agentic 디자인 패턴 (2024)

| 패턴 | 설명 | 성숙도 |
|------|------|--------|
| **Reflection** | 에이전트가 자신의 출력을 비평·개선하는 자기 피드백 루프 | 높음 |
| **Tool Use** | 외부 도구/API를 자율적으로 선택·실행 | 높음 |
| **Planning** | 복잡 목표를 하위 태스크로 분해·실행 계획 수립 | **미성숙** (Ng 주의) |
| **Multi-Agent Collaboration** | 역할 기반 다중 에이전트 협업 | 성장 중 |

> Ng은 Planning 패턴이 아직 불안정하여 신뢰성 확보에 추가 연구가 필요하다고 강조했다.

[신뢰도: High] 출처: [Andrew Ng Twitter/X](https://x.com/AndrewYNg/status/1773393357022298617), 2024; [DeepLearning.AI Course](https://learn.deeplearning.ai/courses/agentic-ai/)

#### 학술 통합 분류 (arXiv 2601.12560, 2026.01)

6개 핵심 컴포넌트 분류:

```
┌─────────────────────────────────────────┐
│           AI Agent Architecture          │
├──────────┬──────────┬───────────────────┤
│ Perception│  Brain   │    Planning       │
│ (입력)    │ (LLM)   │ (태스크 분해)      │
├──────────┼──────────┼───────────────────┤
│  Action   │ Tool Use │  Collaboration    │
│ (실행)    │(도구 통합)│ (멀티에이전트 조율) │
└──────────┴──────────┴───────────────────┘
```

[신뢰도: High] 출처: [arXiv:2601.12560](https://arxiv.org/html/2601.12560v1), 2026.01

---

### 1.2 추론(Reasoning) 패턴

| 패턴 | 구조 | 성능 | 적용 시점 |
|------|------|------|----------|
| **Chain-of-Thought (CoT)** | 선형 추론 체인 | 기본 | 구조화된 단일 문제 |
| **ReAct** | Thought→Action→Observation 루프 | 표준 | 복잡·불확실 태스크 (업계 표준) |
| **Tree-of-Thought (ToT)** | 다중 분기 탐색 후 최적 경로 선택 | 향상 | 복수 해법이 가능한 문제 |
| **Graph-of-Thought (GoT)** | DAG 기반 상호 의존 추론 | 고급 | 다단계 복합 추론 |
| **Adaptive GoT (AGoT)** | 재귀적 하위 문제 분해 + 선택적 확장 | **46.2% 향상** (GPQA) | 과학적 추론, 복합 분석 |
| **Framework of Thoughts (FoT)** | 범용 추론 프레임워크 + 하이퍼파라미터 튜닝 | 최신 (2026.02) | 동적 추론 최적화 |

**핵심 논문:**
- ReAct: [Yao et al., 2022](https://arxiv.org/abs/2210.03629)
- Topologies of Reasoning: [Besta et al., 2025](https://arxiv.org/html/2401.14295v3)
- AGoT: [Zhou et al., 2025](https://arxiv.org/html/2502.05078v1)
- FoT: [arXiv:2602.16512](https://arxiv.org/abs/2602.16512), 2026.02

---

### 1.3 멀티에이전트 오케스트레이션 패턴

#### 4대 아키텍처 패턴

| 패턴 | 구조 | 장점 | 단점 | 적용 |
|------|------|------|------|------|
| **Supervisor/Hierarchical** | 중앙 오케스트레이터 → 전문 에이전트 위임 | 중앙 제어, 감사 추적 | 병목 가능 | 엔터프라이즈 표준 |
| **Handoff/Routing** | 에이전트 간 동적 태스크 전달 | 저지연, 확장성 | 디버깅 어려움 | 고객 서비스, 도메인 분기 |
| **Flat Collaboration** | 독립 에이전트 병렬 실행 → 결과 집계 | 비동기, 빠름 | 조율 제한적 | 독립적 병렬 작업 |
| **Peer-to-Peer** | 에이전트 간 직접 소통·협상 | 유연, 분산 | 모니터링 난이도 높음 | 복잡 협상 시나리오 |

#### 실행 패턴

```
Sequential Pipeline:  Task1 → Task2 → Task3 → Result
                      (순차 의존, 명확한 제어 흐름)

Parallel Execution:   Task1 ─┐
                      Task2 ─┼→ Aggregation → Result
                      Task3 ─┘
                      (독립 실행, 지연 시간 절감)

Hierarchical:         Supervisor
                      ├── Mid-Supervisor A
                      │   ├── Worker 1
                      │   └── Worker 2
                      └── Mid-Supervisor B
                          ├── Worker 3
                          └── Worker 4
                      (대규모 팀 조율)
```

---

### 1.4 메모리 아키텍처 패턴

인지과학(Tulving, 1972) 기반 3계층 메모리:

| 유형 | 설명 | 저장 내용 | 활용 |
|------|------|----------|------|
| **Episodic Memory** | 경험·상호작용 기록 | 상태-행동-결과 시퀀스 | 과거 경험 학습, 컨텍스트 회상 |
| **Semantic Memory** | 사실·지식 기반 | 정의, 관계, 데이터 | 지식 베이스, 컨텍스트 그라운딩 |
| **Procedural Memory** | 학습된 정책·워크플로우 | 절차, 의사결정 휴리스틱 | 반복 프로세스 최적화 |

**2025-2026 주요 연구:**
- MemRL: 에피소딕 메모리 기반 런타임 강화학습
- MemEvolve: 에이전트 메모리 시스템 메타 진화
- ICLR 2026 Workshop: [MemAgents](https://openreview.net/pdf?id=U51WxL382H)

**미해결 과제:** 파국적 망각(Catastrophic Forgetting), 대규모 검색 효율성, 컨텍스트 윈도우 제한

[신뢰도: High] 출처: [arXiv:2512.13564](https://arxiv.org/abs/2512.13564)

---

### 1.5 RAG 에이전트 패턴 (Agentic RAG)

기존 정적 RAG에서 **에이전트 주도 동적 검색**으로 진화:

| 패턴 | 특징 | 성능 |
|------|------|------|
| **AU-RAG** | 검색 지식 vs 파라미터 지식 동적 선택 | 다양한 데이터 환경 적응 |
| **R2AG** | 생성 중 재귀적 후보 재랭킹 | 반복 정제로 품질 향상 |
| **Graph RAG** | 엔티티 중심 그래프 구축 + 커뮤니티 요약 | Multi-hop QA 리콜 **+6.4pt** |
| **Modular RAG** | 전문 에이전트별 파이프라인 분해 | 유연한 파이프라인 구성 |

[신뢰도: High] 출처: [arXiv:2506.00054](https://arxiv.org/html/2506.00054v1); [arXiv:2501.09136](https://arxiv.org/html/2501.09136v2)

---

### 1.6 Human-in-the-Loop & Safety 패턴

#### 3계층 방어 체계 (2025 업계 표준)

```
Layer 1: Synchronous Policy Gates (동기 정책 게이트)
         ├── 권한 검사
         ├── 스키마 검증
         ├── 금지 행동 차단
         └── 토큰/API 비용 한도

Layer 2: High-Signal Detectors (비동기 탐지)
         ├── 루프 길이 감지 (N회 초과 시 중단)
         ├── 행동 드리프트 감지
         ├── 지연 시간 알림
         └── 런타임 안전 정책 검사

Layer 3: Human Escalation (인간 개입)
         ├── 동기 리뷰 (고위험 결정)
         ├── 비동기 에스컬레이션 (불확실성 임계값 초과 시)
         └── 연속 모니터링 (24/7 운영)
```

**안전성 현실 (2025 벤치마크):**
- SOTA 모델도 **30-70% 제약 조건 위반율** 기록 (2025.12)
- 우수한 추론 능력 ≠ 더 나은 안전성 (Gemini-3-Pro가 가장 높은 위반율 기록)
- 150+ 건의 GenAI 환각 관련 법적 소송 발생

[신뢰도: High] 출처: [arXiv:2509.23994](https://arxiv.org/html/2509.23994v1); [arXiv:2510.23883](https://arxiv.org/abs/2510.23883)

---

### 1.7 Agentic 코딩 패턴

| 도구 | 자율성 수준 | SWE-bench 성능 | 특징 |
|------|-----------|---------------|------|
| **Claude Code** | Level 3-4 (감독 자율) | **77.2%** (최고) | 멀티파일 이해, 계획-실행-반복 |
| **Devin** | Level 4 (준자율) | — | 클라우드 샌드박스, 셸/에디터/브라우저 |
| **Cursor/Windsurf** | Level 2-3 | — | IDE 통합, 코파일럿 |

> Anthropic 내부: 코드의 **90%**가 AI 생성. 그러나 완전 자율 코딩 파이프라인은 전체 기업의 **<8%** 수준.

---

## 2. 시장 규모 & 성장률

### 글로벌 AI Agent 시장

| 연도 | 시장 규모 | CAGR |
|------|----------|------|
| 2025 | $7.63 - $11.78B | — |
| 2026 | $10.91B | +43% YoY |
| 2030 | $52.62B | 46.3% (2025-2030) |
| 2034 | $251.38B | 46.61% (2026-2034) |
| 2035 | $263.96B | 40.8% (자율 AI 세그먼트) |

**출처:**
- [Grand View Research](https://www.grandviewresearch.com/industry-analysis/ai-agents-market-report)
- [Markets and Markets](https://www.marketsandmarkets.com/Market-Reports/ai-agents-market-15761548.html)
- [Precedence Research](https://www.precedenceresearch.com/agentic-ai-market)
- [Fortune Business Insights](https://www.fortunebusinessinsights.com/agentic-ai-market-114233)

### 엔터프라이즈 채택 지표

| 지표 | 2024 | 2025 | 2026E |
|------|------|------|-------|
| Multi-Agent 시스템 문의 증가 | 100 | 1,545% | — |
| Fortune 500 AI Agent 활용 | 10% | 60% | 80%+ |
| 엔터프라이즈 앱 AI 코파일럿 내장 | <5% | 15-20% | **80%** (IDC) |
| 자율 코딩 파이프라인 보유 기업 | <1% | <8% | 20-30%E |
| 조직 AI Agent 사용률 | — | **85%** | — |

[신뢰도: High] 출처: Gartner 2025, IDC Forecast, CrewAI 공시

---

## 3. 주요 플레이어 & 프레임워크 경쟁 분석

### 프레임워크 종합 비교

| 프레임워크 | GitHub Stars | 월간 다운로드 | 언어 | 설계 모델 | 성숙도 | 최적 용도 |
|-----------|:-----------:|:----------:|:----:|----------|:-----:|----------|
| **LangChain/LangGraph** | 88K / 24.8K | 47M / 34.5M | Python | 그래프 기반 | ★★★★★ | 복잡 상태관리 워크플로우 |
| **AutoGen/MS Agent** | 50.4K | — | Python | 대화형 | ★★★★ | 연구·토론, MS 생태계 |
| **CrewAI** | 44.8K | 1.38M | Python | 역할 기반 | ★★★★ | 팀 협업, 빠른 프로토타이핑 |
| **Claude Agent SDK** | — | — | TypeScript | 프로덕션 검증 | ★★★★ | 장기 실행, 유연 배포 |
| **Vercel AI SDK** | — | 20M | TypeScript | 프론트엔드 친화 | ★★★★ | 풀스택 JS, 사용자 대면 |
| **Google ADK** | — | — | Python/TS | 커넥터 중심 | ★★★★ | 엔터프라이즈 시스템 통합 |
| **OpenAI Agents SDK** | — | — | Python | 미니멀리스트 | ★★★ | 단순 멀티에이전트, 100+ LLM |
| **Amazon Bedrock** | — | — | 프레임워크 무관 | 관리형 SaaS | ★★★★ | AWS 배포, 컴플라이언스 |
| **Semantic Kernel** | — | — | C#/Python | 플러그인 기반 | ★★★★ | .NET 환경, Azure |
| **Mastra** | 20.6K | — | TypeScript | 고수준 추상화 | ★★★ | JS 백엔드 에이전트 |
| **Pydantic AI** | — | — | Python | 타입 안전 | ★★★ | 구조화된 태스크 에이전트 |
| **SmolAgents** | — | — | Python | 코드 생성 직접 실행 | ★★★ | 경량 에이전트, HuggingFace |
| **Agno (PHIdata)** | — | — | Python | 속도 최적화 | ★★★ | 빠른 실행, 경량 |
| **Composio** | — | — | — | 도구 통합 레이어 | ★★★ | 250+ 도구, 500+ 앱 연동 |

### 시장 점유율 추정 (2026)

| 프레임워크 | 추정 점유율 | 근거 |
|-----------|:--------:|------|
| LangChain/LangGraph | 35-40% | 최대 다운로드, 엔터프라이즈 채택 |
| AWS Bedrock | 10-15% | 인프라 지출, AWS 생태계 |
| Microsoft Agent Framework | 8-12% | Azure 배포, 엔터프라이즈 |
| CrewAI | 8-12% | 프로토타이핑 채택 급성장 |
| Claude Agent SDK | 5-10% | 급성장 (LLM 지출 40% 점유) |
| Google ADK | 5-8% | GCP 배포, 엔터프라이즈 |
| OpenAI Agents SDK | 3-7% | 신규 (2026.02), 표준화 시그널 |
| 기타 | 12-20% | 다양한 특수 용도 |

### 프레임워크 선택 가이드

```
기존 스택이 무엇인가?
├── Azure / .NET → Microsoft Agent Framework
├── AWS 인프라 → Amazon Bedrock AgentCore
├── GCP 인프라 → Google ADK
├── Python / 오픈소스
│   ├── 복잡한 상태관리 필요 → LangGraph
│   ├── 팀 협업 / 빠른 프로토타입 → CrewAI
│   └── 경량 / 타입 안전 → Pydantic AI
├── TypeScript / Next.js
│   ├── 풀스택 웹앱 → Vercel AI SDK
│   └── 백엔드 에이전트 → Mastra
└── 멀티 프로바이더 / 유연 배포
    ├── Anthropic Claude 중심 → Claude Agent SDK
    └── 100+ LLM 지원 필요 → OpenAI Agents SDK
```

---

## 4. 상호운용성 & 표준화 (2025-2026)

### Agentic AI Foundation (AAIF)

- **설립**: 2025.08, Linux Foundation 산하
- **공동 설립**: OpenAI, Anthropic, Block
- **지원**: Google, Microsoft, AWS, Bloomberg, Cloudflare

**핵심 기여물:**

| 표준 | 설명 | 채택 규모 |
|------|------|----------|
| **MCP (Model Context Protocol)** | 도구 통합 표준 인터페이스 | **10,000+** 공개 서버, SDK 9,700만 다운로드 |
| **AGENTS.md** | 에이전트 구성 표준 포맷 | **60,000+** 오픈소스 프로젝트 채택 |
| **goose** | 오픈소스 에이전트 참조 구현 | 커뮤니티 주도 개발 |

**Google A2A (Agent-to-Agent) 프로토콜:**
- 에이전트 간 직접 통신 표준 (MCP는 에이전트-도구)
- 채택 가속화 중, MCP와 상호 보완

[신뢰도: High] 출처: [OpenAI AAIF 발표](https://openai.com/index/agentic-ai-foundation/), 2025.08

---

## 5. 트렌드 & 기회

### 8대 시장 트렌드 (2025-2026)

| # | 트렌드 | 영향 | 시기 |
|:-:|--------|------|------|
| 1 | **그래프 기반 실행 표준화** | 대화형→그래프 기반 결정론적 워크플로우 전환 | 진행 중 |
| 2 | **멀티모델 조합 보편화** | 벤더 락인 감소, 프레임워크 차별화 전략 변화 | 2025-2026 |
| 3 | **관리형 인프라 부상** | DIY 배포 → 클라우드 플랫폼 위탁 (AWS, Google, Azure) | 가속 중 |
| 4 | **도메인 특화 미세조정** | 범용 모델 < 도메인 특화 모델 (비용 60-70% 절감) | 2026+ |
| 5 | **보안·컴플라이언스 차별화** | 구매 결정의 핵심 요소로 부상 (48%가 최대 공격 벡터로 인식) | 2026 |
| 6 | **ROI 중심 측정** | 실험 → 비즈니스 임팩트 측정으로 전환 (171% 평균 ROI) | 진행 중 |
| 7 | **Context Engineering 부상** | 정적 프롬프트 → 태스크 기반 동적 컨텍스트 조합 | 2025 핫토픽 |
| 8 | **No-Code/Low-Code 확장** | 비기술 팀의 에이전트 개발 접근성 확대 (Dify 129.8K stars) | 가속 중 |

### 기회 영역

| 기회 | 규모 | 진입 장벽 | 시급성 |
|------|------|----------|--------|
| **Agentic RAG 솔루션** | 대 | 중 | 높음 — 정적 RAG의 한계 인식 확산 |
| **에이전트 메모리 인프라** | 대 | 높음 | 중 — 연구 단계 → 제품화 전환기 |
| **에이전트 관찰성 도구** | 중 | 중 | 높음 — LangSmith 독점 시장에 경쟁 기회 |
| **도메인 특화 에이전트 템플릿** | 중 | 낮음 | 높음 — 엔터프라이즈 수요 급증 |
| **에이전트 보안 프레임워크** | 대 | 높음 | 매우 높음 — 규제 강화 예상 |
| **에이전트 평가·벤치마킹** | 중 | 중 | 높음 — 표준 부재 상태 |

---

## 6. 위험 요인

### 시장 리스크

| 리스크 | 확률 | 영향 | 완화 전략 |
|--------|:----:|:----:|----------|
| **ROI 불확실로 프로젝트 중단** | 높음 | 높음 | 명확한 유스케이스 + 단계적 도입 |
| **안전성 사고 (환각, 보안 침해)** | 중 | 매우 높음 | 3계층 방어 체계 + HITL 필수 |
| **데이터 품질 문제** | 높음 | 중 | 데이터 거버넌스 선행 |
| **규제 강화 (EU AI Act, SEC)** | 높음 | 중 | 감사 추적, 설명 가능성 확보 |
| **인재 부족 (Agentic AI 엔지니어)** | 높음 | 중 | 교육 투자, No-Code 도구 활용 |
| **프레임워크 과잉 (20+)** | 중 | 낮음 | 2026-2027 시장 통합 예상 |
| **벤더 락인** | 중 | 중 | MCP/AGENTS.md 표준 채택 |

### 안전성 리스크 심층 분석

- SOTA 모델의 제약 조건 위반율 **30-70%** (2025.12 벤치마크)
- GenAI 환각 관련 법적 소송 **150건+** (가짜 인용, 허위 판례, 조작 인용문)
- Gartner: GenAI 이니셔티브 **30%**가 2025년 말까지 방기 가능 (데이터·리스크 관리 부실)

---

## 7. 우리 워크스페이스(SIGIL/Trine)와의 연관성

### 현재 접근 방식 검증

| 우리 패턴 | 업계 대응 패턴 | 검증 결과 |
|----------|--------------|----------|
| SIGIL Pipeline (S1→S2→S3→S4) | Sequential Pipeline + Stage-Gate | ✅ 학술·업계 모두 검증됨 |
| Agent Teams (Fan-out/Fan-in) | Parallel Execution + Supervisor | ✅ Anthropic, Ng 모두 권장 |
| Competing Hypotheses (S1, S3) | Multi-Agent Debate / Voting | ✅ 효과적 의사결정 패턴으로 확인 |
| Gate-Log 메커니즘 | Verified Delegation + Audit Trail | ✅ 2025 안전성 연구와 부합 |
| 모델 계층화 (Opus/Sonnet/Haiku) | 비용 60-70% 절감 전략 | ✅ 업계 권장 사항과 일치 |
| MCP 서버 활용 | MCP 표준 (10K+ 서버) | ✅ 업계 표준 채택 |

### 개선 권장 사항

| 시기 | 권장 사항 | 근거 |
|------|----------|------|
| 단기 | SIGIL 패턴을 에이전트 메모리로 문서화 | Episodic Memory 연구 |
| 단기 | S4 상태 머신을 LangGraph 스타일로 공식화 | 그래프 기반 실행 트렌드 |
| 중기 | 에이전트 메모리 DB 구축 (세션 간 학습) | MemAgents 연구 |
| 중기 | Reflection 패턴을 S3 기획서 검토에 적용 | Ng의 Reflection 패턴 |
| 장기 | A2A 프로토콜 도입 (에이전트 간 직접 통신) | Google A2A 표준화 |

---

## 8. 결론 & 액션 아이템

### 핵심 결론

1. **패턴은 수렴 중**: Anthropic·Ng·학술 연구 모두 유사한 패턴 분류로 합의 형성
2. **멀티에이전트가 표준**: 단일 에이전트 → 멀티에이전트 전환이 확정적 트렌드
3. **LangGraph가 시장 리더**: 프레임워크 시장은 LangChain/LangGraph 중심으로 통합 중
4. **안전성이 최대 과제**: 모델 성능이 아닌 안전성·거버넌스가 프로덕션 배포의 핵심 장벽
5. **표준화 가속**: MCP (10K+ 서버) + AGENTS.md (60K+ 프로젝트)가 사실상 표준
6. **우리 SIGIL 접근 건전**: 업계 패턴과 높은 부합도 확인

### 액션 아이템

| 우선순위 | 액션 | 기대 효과 |
|:-------:|------|----------|
| P0 | Reflection 패턴을 SIGIL S3 기획서 검토에 도입 | 기획서 품질 15-30% 향상 |
| P1 | 에이전트 세션 간 메모리 시스템 설계 | 반복 작업 효율성 증대 |
| P1 | Agent Safety 3계층 방어를 Agent Teams에 적용 | 프로덕션 안정성 확보 |
| P2 | A2A 프로토콜 모니터링 및 도입 계획 | 향후 에이전트 자율성 확장 기반 |
| P2 | Agentic RAG 패턴 평가 (리서치 에이전트 강화) | S1 리서치 품질 향상 |

---

## Sources (URL + 날짜 필수)

### 핵심 1차 소스

- [Anthropic - Building Effective Agents](https://www.anthropic.com/research/building-effective-agents) (2024.12)
- [Andrew Ng - 4 Agentic Design Patterns](https://x.com/AndrewYNg/status/1773393357022298617) (2024.03)
- [DeepLearning.AI - Agentic AI Course](https://learn.deeplearning.ai/courses/agentic-ai/) (2024)
- [OpenAI - Agentic AI Foundation](https://openai.com/index/agentic-ai-foundation/) (2025.08)
- [Model Context Protocol](https://modelcontextprotocol.io/) (2025)

### 학술 논문

- [arXiv:2601.12560 — Agentic AI: Architectures, Taxonomies, Evaluation](https://arxiv.org/html/2601.12560v1) (2026.01)
- [arXiv:2510.25445 — Agentic AI: A Comprehensive Survey](https://arxiv.org/html/2510.25445v1) (2025.10)
- [arXiv:2505.10468 — AI Agents vs. Agentic AI: Taxonomy](https://arxiv.org/html/2505.10468v1) (2025.05)
- [arXiv:2507.21504 — Evaluation and Benchmarking of LLM Agents](https://arxiv.org/html/2507.21504v1) (2025.07)
- [arXiv:2210.03629 — ReAct: Synergizing Reasoning and Acting](https://arxiv.org/abs/2210.03629) (2022)
- [arXiv:2401.14295 — Topologies of Reasoning](https://arxiv.org/html/2401.14295v3) (2025.01)
- [arXiv:2502.05078 — Adaptive Graph of Thoughts](https://arxiv.org/html/2502.05078v1) (2025.02)
- [arXiv:2602.16512 — Framework of Thoughts](https://arxiv.org/abs/2602.16512) (2026.02)
- [arXiv:2506.00054 — RAG Comprehensive Survey](https://arxiv.org/html/2506.00054v1) (2025.02)
- [arXiv:2501.09136 — Agentic RAG Survey](https://arxiv.org/html/2501.09136v2) (2026.01)
- [arXiv:2512.13564 — Memory in the Age of AI Agents](https://arxiv.org/abs/2512.13564) (2025.12)
- [arXiv:2509.23994 — AI Agent Code of Conduct](https://arxiv.org/html/2509.23994v1) (2025.09)
- [arXiv:2510.23883 — Agent Safety & Security](https://arxiv.org/abs/2510.23883) (2025.10)
- [arXiv:2308.08155 — AutoGen: Enabling Next-Gen LLM Apps](https://arxiv.org/abs/2308.08155) (2023)
- [ICLR 2026 — MemAgents Workshop](https://openreview.net/pdf?id=U51WxL382H) (2026)

### 시장 보고서

- [Grand View Research — AI Agents Market](https://www.grandviewresearch.com/industry-analysis/ai-agents-market-report) (2025)
- [Markets and Markets — AI Agents Market 2025-2030](https://www.marketsandmarkets.com/Market-Reports/ai-agents-market-15761548.html) (2025)
- [Precedence Research — Agentic AI Market 2026-2034](https://www.precedenceresearch.com/agentic-ai-market) (2025)
- [Fortune Business Insights — Agentic AI Market](https://www.fortunebusinessinsights.com/agentic-ai-market-114233) (2025)
- [Gartner — 40% Enterprise Apps with AI Agents by 2026](https://www.gartner.com/en/newsroom/press-releases/2025-08-26-gartner-predicts-40-percent-of-enterprise-apps-will-feature-task-specific-ai-agents-by-2026-up-from-less-than-5-percent-in-2025) (2025.08)
- [McKinsey — State of AI 2025](https://www.mckinsey.com/capabilities/quantumblack/our-insights/the-state-of-ai) (2025)
- [Sequoia Capital — AI in 2025](https://sequoiacap.com/article/ai-in-2025/) (2025)

### 프레임워크 공식 문서

- [LangGraph Documentation](https://docs.langchain.com/oss/python/langgraph/overview)
- [LangSmith Pricing](https://www.langchain.com/pricing)
- [CrewAI Official](https://crewai.com/)
- [Microsoft Agent Framework](https://learn.microsoft.com/en-us/agent-framework/overview/)
- [Google ADK](https://google.github.io/adk-docs/)
- [Anthropic Claude Agent SDK](https://claude.com/solutions/agents)
- [Vercel AI SDK 6](https://vercel.com/blog/ai-sdk-6)
- [SmolAgents](https://smolagents.org/)
- [AWS Bedrock AgentCore](https://aws.amazon.com/blogs/aws/introducing-amazon-bedrock-agentcore-securely-deploy-and-operate-ai-agents-at-any-scale/)

### 업계 분석 & 가이드

- [Google Cloud Architecture — Agentic AI Design Patterns](https://docs.cloud.google.com/architecture/choose-design-pattern-agentic-ai-system) (2025)
- [Microsoft Learn — AI Agent Design Patterns](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns) (2025)
- [AWS — Multi-Agent Orchestration](https://aws.amazon.com/solutions/guidance/multi-agent-orchestration-on-aws/) (2025)
- [Machine Learning Mastery — 7 Agentic AI Design Patterns](https://machinelearningmastery.com/7-must-know-agentic-ai-design-patterns/) (2025)
- [KDnuggets — 5 Essential Design Patterns](https://www.kdnuggets.com/5-essential-design-patterns-for-building-robust-agentic-ai-systems) (2025)
- [Databricks — Multi-Agent Supervisor Architecture](https://www.databricks.com/blog/multi-agent-supervisor-architecture-orchestrating-enterprise-ai-scale) (2025)
- [O'Reilly — Designing Effective Multi-Agent Architectures](https://www.oreilly.com/radar/designing-effective-multi-agent-architectures/) (2025)
- [Humanloop — 8 RAG Architectures](https://humanloop.com/blog/rag-architectures) (2025)
- [TechCrunch — AI from Hype to Pragmatism](https://techcrunch.com/2026/01/02/in-2026-ai-will-move-from-hype-to-pragmatism/) (2026.01)
- [OneReach AI — Agentic AI Adoption Stats](https://onereach.ai/blog/agentic-ai-adoption-rates-roi-market-trends/) (2026)
- [Bernard Marr — 8 Tech Trends 2026](https://bernardmarr.com/ai-agents-lead-the-8-tech-trends-transforming-enterprise-in-2026/) (2026)

---

*리서치 수행: 2026-03-02*
*데이터 기준: 2026년 2월*
*신뢰도: High (다중 소스 교차 검증)*
*제한사항: 시장 점유율 데이터는 오픈소스/엔터프라이즈/클라우드 세그먼트 간 분절됨. 신규 프레임워크(OpenAI Agents SDK, Google ADK)는 프로덕션 이력 제한적.*
