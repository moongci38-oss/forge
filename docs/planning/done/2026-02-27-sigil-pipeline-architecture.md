# SIGIL 파이프라인 아키텍처 설계

## 파이프라인 이름: SIGIL (시질)

> **SIGIL (Strategy & Idea Generation Intelligent Loop)**
> **마법 인장(印章)** — 프로젝트에 생명을 불어넣는 설계 문양.
> 각 Stage가 인장의 한 획. 완성된 Sigil이 Trine에 전달되면 프로젝트가 "소환"된다.
> **Sigil(설계) → Trine(구현)** = 마법진 완성 → 삼위일체 소환

## Context

**목표**: 앱/웹/게임 개발 + 유튜브 방송/쇼폼/롱폼 콘텐츠 제작을 아우르는 **기획서 자동화 AI 멀티 에이전트 파이프라인**을 구축한다.

- **개발 프로젝트**: 파이프라인 산출물(기획 패키지)이 기존 **Trine 개발 파이프라인의 입력**이 되어 기획→개발이 하나의 흐름으로 연결
- **콘텐츠 프로젝트**: 파이프라인 산출물(대본/기획안/콘텐츠 캘린더)이 직접 제작/배포 단계로 연결
- **병렬 실행**: 여러 프로젝트(게임 기획 + 앱 기획 + 유튜브 기획)를 Agent Teams로 동시 진행
- **에이전트 회의**: Competing Hypotheses 패턴 + **Agent Council 토너먼트** (5+2)로 최적 기획안을 도출

## 전체 흐름

```
[파이프라인 — 개발 트랙]                                    [Trine 파이프라인]
S1 리서치 → S2 컨셉 → S3 기획서 → S4 기획 패키지 ──────→ Phase 1 → 1.5 → 2 → 3 → 4
                                                                ↑
                                                           기획 패키지 → Trine Phase 1

[파이프라인 — 콘텐츠 트랙]
S1 리서치 → S2 컨셉 → S3 콘텐츠 기획서 → S4 제작 가이드 ──→ 촬영/편집/배포
                          ↑                    ↑
                     대본/구성안          채널 전략/SEO

[병렬 실행 — Agent Teams]
┌─ 프로젝트 A (게임 S1~S4) ─────────────────→ Trine
├─ 프로젝트 B (앱 S1~S4) ──────────────────→ Trine
├─ 프로젝트 C (유튜브 시리즈 S1~S4) ────────→ 제작
└─ 프로젝트 D (쇼폼 콘텐츠 S1~S3) ──────────→ 제작
    ↑ 각 프로젝트가 독립 Agent Team으로 병렬 실행
```

---

## Part 1: 파이프라인 아키텍처

### 실행 모드 (2가지)

| 모드 | 설명 | 적용 |
|------|------|------|
| **기본 모드** | S1→S2→S3→S4 순차 진행 | 기본값. 대부분의 프로젝트 |
| **카운슬 모드** | 5+2 Agent Council 토너먼트 | Human 명시 선택. 신규 시장/불확실한 방향 |

### 파이프라인 유연성 (Soft/Hard 의존성)

| 유형 | 의존성 | 스킵 |
|------|--------|------|
| **Soft** | S1→S2, S2→S3 | 기존 자료가 있으면 스킵 가능 |
| **Hard** | S3→S4, S4→Trine | 반드시 순서 유지 (기획서 없이 기획패키지 불가) |

**진입 경로 (4가지)**:

| 시나리오 | 시작 Stage | 필요 입력 |
|---------|:---------:|----------|
| 아이디어만 있음 | S1 | 아이디어 한 줄 |
| 자료/리서치 있음 | S2 | 기존 리서치 문서 |
| 컨셉 확정됨 | S3 | 컨셉 문서 or Lean Canvas |
| 기획서 있음 | S4 | PRD/GDD 문서 |

### 프로젝트 유형별 문서 매핑 (5유형)

| Stage | 앱 개발 | 웹 서비스 | 게임 개발 | 유튜브/롱폼 | 쇼폼 콘텐츠 |
|:-----:|---------|----------|----------|------------|-----------|
| S1 리서치 | 시장+기술 조사 | 시장+기술 조사 | 시장+기술 조사 | 트렌드+채널 분석 | 트렌드+바이럴 분석 |
| S2 컨셉 | 린 캔버스 + 컨셉 | 린 캔버스 + 컨셉 | 린 캔버스 + 게임 컨셉 | 채널 전략 + 시리즈 컨셉 | 콘텐츠 포맷 컨셉 |
| S3 기획서 | PRD (.md+.pptx) | PRD + API (.md+.pptx) | GDD (.md+.pptx) | 대본 + 구성안 | 쇼폼 대본 (배치) |
| S4 기획 패키지 | 기획 패키지 (6대 산출물) | 기획 패키지 (6대 산출물) | 기획 패키지 (6대 산출물) | 제작 가이드 + SEO | 배포 캘린더 |
| → 연결 | Trine Phase 1 | Trine Phase 1 | Trine Phase 1 | 촬영/편집/배포 | 편집/배포 |

### 방법론 기반

> **필수**: 모든 프로젝트에 적용. **선택**: 프로젝트 특성에 따라 선별 적용.

| 영역 | 방법론 | 적용 Stage | 설명 | 우선순위 |
|------|--------|:----------:|------|:--------:|
| **자료조사** | AI-augmented Research | S1 | AI 에이전트 병렬 리서치 + 자동 팩트체크 | **필수** |
| | JTBD (Jobs To Be Done) | S1 | 사용자 니즈를 "해결해야 할 과업" 관점으로 분석 | **필수** |
| | Competitive Intelligence 자동화 | S1 | 경쟁사 제품/기능/가격 자동 수집·비교 | **필수** |
| | SOAR | S1 | SWOT 대체 — 강점/기회/열망/결과 (액션 지향) | 선택 |
| | PESTLE | S1 | 거시 환경 체크리스트 (Political~Environmental) | 선택 |
| | Evidence-Based Management | S1 | High/Medium/Low 신뢰도 등급 기반 의사결정 | **필수** |
| **컨셉 검증** | Pretotyping | S2 | Landing page 50명+, 20%+ 전환 목표로 시장 반응 검증 | **필수** |
| | Mom Test | S2 | 과거 행동만 질문, 15명+ 인터뷰 — 편향 없는 검증 | **필수** |
| | Lean Validation | S2 | 가설-실험-학습 사이클로 Go/No-Go 판단 | **필수** |
| | TAM/SAM/SOM | S2 | AI 기반 시장 규모 자동 추정, TAM<$1M = Kill 신호 | **필수** |
| | OKR | S2 | Objective + Key Results → S3 기획서의 측정 기준 | **필수** |
| | OST (Opportunity Solution Tree) | S2 | 비즈니스 목표에서 역추적 → 기회→솔루션 매핑 | 선택 |
| **기획서 작성** | Shape Up Pitch | S3 | 문제-해법-범위를 한 문서로 압축하는 기획 포맷 | **필수** |
| | User Story Mapping | S3 | 사용자 여정 기반 기능 우선순위 시각화 | **필수** |
| | Modern PRD | S3 | User Problem + Success Metrics + AC — AI 40-60% 생성 | **필수** |
| | Outcome-based Roadmap | S3 | 기능 나열이 아닌 비즈니스 성과 기반 로드맵 | 선택 |
| | Event Storming | S3 | 비즈니스 프로세스 → User Story 추출 (DDD 연계) | 선택 |
| **기획 패키지** | Now/Next/Later | S4 | 의도 중심 유연 로드맵 (58% 팀 채택) | **필수** |
| | RICE/ICE Scoring | S4 | 기능별 영향도·자신감·노력 정량 평가 | **필수** |
| | Agile WBS | S4 | 에픽→스토리→태스크 계층적 작업 분해 | **필수** |
| | C4 Model | S4 | Context→Container→Component→Code 아키텍처 시각화 | **필수** |
| | ADR (Architecture Decision Record) | S4 | Status/Context/Decision/Consequences 기술 결정 문서화 | **필수** |
| | WSJF | S4 | 비용 대비 가치 기반 작업 우선순위 결정 | 선택 |
| **파이프라인 거버넌스** | Stage-Gate + Dual-Track Agile | 전체 | [STOP] 게이트 품질 보증 + Discovery/Delivery 병행 | **필수** |
| | Go/No-Go 스코어링 | S2 Gate | 4영역(시장/기술/비즈니스/위험) 가중 평가, 80점+ = Go | **필수** |
| | Kill Criteria | S2 Gate | TAM<$1M / 경쟁사 70%+ / 기술 불가 / 규제 장벽 → No-Go | **필수** |
| | DACI | 각 [STOP] Gate | Driver/Approver/Contributors/Informed 역할 명확화 | **필수** |
| | Double Diamond | 전체 | S1(Discover)→S2(Define)→S3(Develop)→S4(Deliver) 매핑 | **필수** |
| **프로젝트 관리** | Personal Kanban | 전체 | 1인 기업에 최적화된 WIP 제한 작업 관리 | **필수** |
| | Decision Log | 전체 | 주요 의사결정 사유와 맥락 기록 | **필수** |
| | Pre-mortem | S3-S4 | 프로젝트 시작 전 실패 시나리오 사전 분석 | 선택 |
| | PR/FAQ | S2-S3 | Amazon Working Backwards — 제품 필요성 재확인 + 이견 발견 | 선택 |

### 파이프라인 4단계 상세

**S1. Research (리서치)**

| 개발 트랙 | 콘텐츠 트랙 |
|----------|-----------|
| research-coordinator → market/academic/fact-checker (병렬) | research-coordinator → market-researcher + 트렌드 분석 |
| 시장 규모, 경쟁사, 기술 스택 | 트렌드 키워드, 채널 분석, 바이럴 패턴 |

- 산출물: `01-research/projects/{project}/YYYY-MM-DD-s1-{topic}.md`
- **방법론**: AI-augmented Research + JTBD + Competitive Intelligence 자동화
- **에이전트 회의 (Competing Hypotheses)**: 리서치 에이전트 3명이 독립 분석 → 결과 비교 → 최적 방향 도출
- 게이트: **[STOP]** 리서치 결과 리뷰 + 방향 확정

**S2. Concept (컨셉 확정)**

| 개발 트랙 | 콘텐츠 트랙 |
|----------|-----------|
| 린 캔버스 + 제품 컨셉 | 채널 전략 + 시리즈/포맷 컨셉 |
| `/lean-canvas` 스킬 활용 | content-calendar + marketing 플러그인 |

- 산출물: `02-product/projects/{project}/YYYY-MM-DD-s2-concept.md`
- 콘텐츠 추가 산출물: `04-content/projects/{project}/YYYY-MM-DD-s2-channel-strategy.md`
- **방법론**: Pretotyping + Mom Test + Lean Validation
- 게이트: **[STOP]** 비전/타겟/차별점 승인

**S3. Design Document (기획서)**

| 유형 | 에이전트/스킬 | 산출물 |
|------|-------------|--------|
| 앱/웹 | `/prd` 커맨드 | PRD (.md + **.pptx 필수**) |
| 게임 | gdd-writer (신규) | GDD (.md + **.pptx 필수**) — 아래 GDD 구조 참조 |
| 유튜브/롱폼 | content-planner (신규) | 대본 + 구성안 (.md) |
| 쇼폼 | content-planner (신규) | 쇼폼 대본 배치 (.md) |

- **방법론**: Shape Up Pitch + User Story Mapping + Outcome-based Roadmap
- **에이전트 회의**: 기획 에이전트 2~3명이 독립적으로 기획서 초안 작성 → Competing Hypotheses → 최적안 선택/병합
- **PPT 변환 (개발 트랙 필수)**: S3 기획서 .md 완성 후 `/pptx` 스킬로 .pptx 파일 생성
- 게이트: **[STOP]** 기획서 승인 (PPT 포함)

**GDD 10개 섹션 (게임 전용)**:

| # | 섹션 | 내용 | AI 자동화 |
|:-:|------|------|:--------:|
| 1 | Game Overview | 컨셉, 핵심 루프, 플레이어 감정, 장르, USP | 높음 |
| 2 | Core Mechanics | 게임플레이 메커닉, 규칙, 상호작용 시스템 | 높음 |
| 3 | System Design | 유저 플로우, 화면 구성, 네트워크/AI/데이터 구조 | 매우 높음 |
| 4 | Content Design | 캐릭터/아이템, 스테이지/레벨, 밸런싱 수치, 소셜 기능 | 높음 |
| 5 | Monetization | 수익 구조, 인앱 구매, 광고 전략, 시즌/이벤트 | 높음 |
| 6 | Art Direction | 시각 스타일, 컬러 팔레트, 애셋 가이드, 애니메이션 | 중간 |
| 7 | Audio Design | 음향 가이드, BGM 톤, SFX 목록, 음성/내레이션 | 중간 |
| 8 | Technical Requirements | 엔진/플랫폼, 사양, 서버, AI 시스템, 제3자 서비스 | 높음 |
| 9 | Risk & Legal | 기술/시장 리스크, 법률/심의, 개인정보보호 | 높음 |
| 10 | Appendix | 참고 게임 분석, 용어 정의, 변경 이력 | 중간 |

**GDD 작성 흐름**: One-Page 게임 컨셉 → Full GDD 자동 확장 → PPT 변환

**S4. Planning Package / Production Guide**

#### 개발 트랙 — 기획 패키지

S3 기획서(PRD/GDD) 기반으로 Trine 진입 전 종합 기획 문서를 작성한다.

| 산출물 | 설명 | 필수 |
|--------|------|:----:|
| 상세 기획서 | S3 기획서를 구현 관점에서 상세화 (화면별 동작, 데이터 흐름) | **필수** |
| 사이트맵 | 페이지/화면 계층 구조 + 네비게이션 흐름 | **필수** |
| 로드맵 | Now/Next/Later + 마일스톤별 기능 배치 + RICE/ICE 우선순위 | **필수** |
| 상세 개발 계획 | 기술 스택, 아키텍처 방향(C4 Model), 개발 환경, ADR + **Trine 세션 로드맵** | **필수** |
| WBS | 작업 분해 구조 (태스크별 예상 규모) | **필수** |
| UI/UX 기획서 | 와이어프레임, 컴포넌트 스펙, 인터랙션 패턴, 디자인 가이드 | **필수** |

- **에이전트**: technical-writer (작성, Sonnet) + cto-advisor (기술 검토) + ux-researcher (UX 검증)
- **S4 Wave 프로토콜**: Wave 1(technical-writer 초안) → Wave 2(cto-advisor + ux-researcher 병렬 검토) → Wave 3(technical-writer 최종본)
- **방법론**: Now/Next/Later + RICE/ICE Scoring + Agile WBS + C4 Model

**관리자 페이지**: S3에 관리자 기능이 포함되면 S4에서 서비스+관리자 산출물을 동등 레벨로 작성한다.
관리자 우선순위는 S2 컨셉 단계에서 결정 (B2C: 서비스>관리자 / B2B: 관리자≥서비스 / 플랫폼: 동등).

**Trine 세션 로드맵**: 상세 개발 계획(s4-development-plan.md)에 세션별 범위, Spec/Plan/Task 문서명을 명시한다.

#### 콘텐츠 트랙

| 유형 | 에이전트 | 산출물 | 다음 단계 |
|------|---------|--------|----------|
| 유튜브/롱폼 | content-planner | 제작 가이드 + SEO 전략 | → 촬영/편집 |
| 쇼폼 | content-planner | 배포 캘린더 + 해시태그 전략 | → 편집/배포 |

- **에이전트 회의 (Debate)**: 기술 결정마다 옹호/비판/중재 패턴 (ADR 초안 자동 생성)
- 게이트: **[STOP]** 승인 → 개발은 Trine 진입, 콘텐츠는 제작 진입

### Stage별 완료 기준 (Definition of Done)

> 상세 체크리스트: `09-tools/templates/dod-checklist.md`
> `[AI]` = AI 자동 완료 / `[Human]` = Human 직접 실행 (AI는 계획서까지)

**S1 Research DoD**
- [ ] `[AI]` 시장 조사 보고서 (TAM/SAM/SOM 포함)
- [ ] `[AI]` 경쟁사 분석 5개사 이상 (장단점 비교표)
- [ ] `[AI]` 출처 3개 이상 다중 검증 + 신뢰도 등급 표기 (High/Medium/Low)
- [ ] `[AI]` 경쟁 가설 3개 이상 수립

**S2 Concept DoD**
- [ ] `[AI]` Lean Canvas 완성 (9개 블록) + TAM/SAM/SOM 추정
- [ ] `[AI]` Go/No-Go 스코어링 80점+ 통과
- [ ] `[AI]` Kill Criteria 해당 사항 없음 확인
- [ ] `[Human]` Mom Test 인터뷰 15명+ (AI가 가이드 작성)
- [ ] `[Human]` Pretotype 실행 (AI가 계획서 작성)

**S3 Design Document DoD**
- [ ] `[AI]` User Story 10개+ (Acceptance Criteria 포함)
- [ ] `[AI]` User Flow Diagram 완성
- [ ] `[AI]` 기술 스택 선정 + 정당화
- [ ] `[AI]` KPI + Success Criteria 정의
- [ ] `[AI]` **PPT 버전 생성** (.pptx, 개발 트랙 필수)
- [ ] `[AI]` 관리자 기능 포함 여부 확인
- [ ] `[Human]` 이해관계자 리뷰 + 승인

**S4 Planning Package DoD**
- [ ] `[AI]` 상세 기획서 완성 (화면별 동작, 데이터 흐름)
- [ ] `[AI]` 사이트맵 완성 (계층 구조 + 네비게이션)
- [ ] `[AI]` 로드맵 완성 (Now/Next/Later + RICE 우선순위)
- [ ] `[AI]` 상세 개발 계획 완성 (기술 스택, C4 아키텍처, ADR + **Trine 세션 로드맵**)
- [ ] `[AI]` WBS 완성 (Story Point 기반 작업 분해)
- [ ] `[AI]` UI/UX 기획서 완성 (와이어프레임 + 컴포넌트 스펙 + 인터랙션 패턴 + 디자인 가이드)
- [ ] `[AI]` 관리자 산출물 완성 (해당 시)

### Agent Council 토너먼트 모드 (5+2)

기존 Competing Hypotheses(2~3명)를 확장한 **5+2 토너먼트** 시스템.

**적용 조건**: Human이 명시적으로 선택. 신규 시장 진입 / 방향 불확실 / 기존 경험 없는 도메인에서 권장.

```
[라운드 1] 5명 독립 리서치+기획 (Fan-out)
    ├─ Councilor A: 시장/수익 관점 (market-researcher 기반)
    ├─ Councilor B: 기술/실현성 관점 (cto-advisor 기반)
    ├─ Councilor C: 사용자/UX 관점 (ux-researcher 기반)
    ├─ Councilor D: 경쟁/차별화 관점 (academic-researcher 기반)
    └─ Councilor E: 리스크/규제 관점 (fact-checker 기반)
         ↓
[평가] Judge가 5축 매트릭스로 상위 2개 선별
    - 실현성(25%) / 시장적합(25%) / 비용효율(20%) / 리스크(15%) / 혁신성(15%)
         ↓
[라운드 2] 상위 2개 정교화 + 상대안 강점 병합
         ↓
[최종] 최종안 선택 또는 병합안 → [STOP] Human 승인
```

평가 기록: `09-tools/templates/council-evaluation-template.md`

### PM 도구 연동

각 [STOP] 게이트 통과 시 다음 Stage 태스크를 외부 PM 도구 또는 내부 문서에 자동 등록한다.

| Tier | 조건 | 도구 |
|:----:|------|------|
| 1 | Notion MCP 연결 가능 | Notion Database 자동 등록 |
| 2 | 연결 불가 (Fallback) | 프로젝트 폴더 내 Markdown Todo 문서 |

상세 구조: `09-tools/templates/notion-task-template.md`

### AI 멀티 에이전트 구성

| 역할 | 에이전트/스킬 | Stage | 트랙 | 신규/기존 |
|------|-------------|:-----:|:----:|:---------:|
| 리서치 총괄 | research-coordinator | S1 | 공통 | 기존 |
| 시장조사 | market-researcher | S1 | 공통 | 기존 |
| 학술조사 | academic-researcher | S1 | 개발 | 기존 |
| 팩트체크 | fact-checker | S1 | 공통 | 기존 |
| SEO 분석 | seo-analyzer | S1,S4 | 콘텐츠 | 기존 |
| 컨셉 작성 | `/lean-canvas` 커맨드 | S2 | 개발 | 기존 |
| 채널 전략 | `/content-calendar` 커맨드 | S2 | 콘텐츠 | 기존 |
| PRD 작성 | `/prd` 커맨드 | S3 | 앱/웹 | 기존 |
| GDD 작성 | gdd-writer | S3 | 게임 | **신규** |
| 콘텐츠 기획 | content-planner | S3,S4 | 콘텐츠 | **신규** |
| PPT 변환 | pptx 스킬 | S3 | 개발 | 기존 |
| 기획 패키지 작성 | technical-writer | S4 | 개발 | 기존 (model: sonnet) |
| 기술 검토 | cto-advisor | S4 | 개발 | 기존 |
| UX 검증 | ux-researcher | S4 | 개발 | 기존 |
| 오케스트레이터 | pipeline-orchestrator | 전체 | 공통 | **신규** |

**신규 에이전트 3개**:
1. `gdd-writer` — 게임 디자인 문서(GDD) 전문 작성
2. `content-planner` — 유튜브/쇼폼/롱폼 대본 + 구성안 + 제작 가이드 작성
3. `pipeline-orchestrator` — S1→S4 파이프라인 자동 진행 + 게이트 관리 + 병렬 프로젝트 조율

### Agent Teams 활용 패턴

| 패턴 | 적용 시점 | 예시 |
|------|----------|------|
| **Fan-out/Fan-in** | S1 리서치 (독립 영역 병렬 조사) | 시장+기술+트렌드 에이전트 3명 동시 투입 |
| **Fan-out/Fan-in** | 멀티 프로젝트 병렬 (게임+앱+콘텐츠 동시) | 각 프로젝트별 독립 Team 스폰 |
| **Fan-out/Fan-in** | Agent Council 라운드 1 (5명 독립 리서치+기획) | 5개 관점의 Councilor 동시 스폰 |
| **Competing Hypotheses** | S3 기획서 에이전트 회의 (기본 모드) | 에이전트 2~3명이 독립 기획 → 최적안 선택 |
| **Pipeline** | S1→S2→S3→S4 순차 의존 | 리서치 완료 후 컨셉, 컨셉 완료 후 기획서 |

### 모델 계층화 (비용 절감)

```
pipeline-orchestrator (Lead)  → Opus 4.6   (판단, 종합, 에이전트 회의 심판)
기획서 작성 (gdd/prd/content) → Sonnet 4.6 (문서 작성, 분석)
기획 패키지 (technical-writer) → Sonnet 4.6 (S4 산출물 작성)
리서치/검색 Teammates          → Haiku 4.5  (검색, 팩트체크, 트렌드 수집)
```

### Trine 연동 (개발 트랙 전용)

```
[파이프라인 S4 산출물]                      [Trine 입력]
S4 기획 패키지 (6대 산출물)       →    Phase 1 (세션 이해 — 기획 패키지 기반 컨텍스트)
S4 Trine 세션 로드맵              →    세션별 범위/Spec/Plan 문서명 가이드
S3 기획서 (PRD/GDD)              →    Phase 1.5 (요구사항 분석 — FR/NFR 추출)
                                       Phase 2 (spec-writer가 SDD 작성)
                                       Phase 3 (구현)
                                       Phase 4 (PR)
```

**S4 완료 시 자동 액션**:
1. 기획 패키지 산출물 존재 확인
2. Handoff 요약 문서 자동 생성: `10-operations/handoff-to-dev/{target-project}/YYYY-MM-DD-sigil-handoff.md`
3. Trine 진입 안내 메시지 → Human
4. 실제 Trine 세션 시작은 Human 승인 후 수동 (`/trine`)

### 콘텐츠 제작 흐름 (콘텐츠 트랙 전용)

```
[파이프라인 S4 산출물]                        [제작 단계]
제작 가이드 + 대본 ─────────→ 촬영 (카메라/OBS/스크린캡처)
SEO 전략 + 썸네일 가이드 ──→ 편집 (Premiere/DaVinci/CapCut)
배포 캘린더 ─────────────→ 업로드 + SEO 적용 + 배포
```

| 콘텐츠 유형 | 파이프라인 산출물 | 제작 도구 |
|-----------|----------------|----------|
| 유튜브 롱폼 (10~30분) | 대본 + 구성안 + 촬영 체크리스트 + 썸네일 가이드 | OBS/카메라 + Premiere |
| 유튜브 쇼폼 (60초) | 쇼폼 대본 배치 (5~10개) + 해시태그 전략 | CapCut/Premiere |
| 유튜브 방송 (라이브) | 방송 구성안 + 토크 포인트 + 인터랙션 가이드 | OBS + 스트리밍 |

### 게이트 로그

각 [STOP] 게이트 통과 시 프로젝트 폴더의 `gate-log.md`에 자동 기록한다.
기록 항목: Stage, 결과(PASS/수정/반려), 일자, 조건, 비고.

### 산출물 저장 경로

| 유형 | 경로 |
|------|------|
| 리서치 | `01-research/projects/{project}/YYYY-MM-DD-s1-{topic}.md` |
| 컨셉 (개발) | `02-product/projects/{project}/YYYY-MM-DD-s2-concept.md` |
| 컨셉 (콘텐츠) | `04-content/projects/{project}/YYYY-MM-DD-s2-channel-strategy.md` |
| PRD | `02-product/projects/{project}/YYYY-MM-DD-s3-prd.md` + `.pptx` |
| GDD | `02-product/projects/{project}/YYYY-MM-DD-s3-gdd.md` + `.pptx` |
| 관리자 PRD | `02-product/projects/{project}/YYYY-MM-DD-s3-admin-prd.md` |
| 콘텐츠 기획 | `04-content/projects/{project}/YYYY-MM-DD-s3-script.md` |
| 상세 기획서 | `02-product/projects/{project}/YYYY-MM-DD-s4-detailed-plan.md` |
| 관리자 상세 기획서 | `02-product/projects/{project}/YYYY-MM-DD-s4-admin-detailed-plan.md` |
| 사이트맵 | `02-product/projects/{project}/YYYY-MM-DD-s4-sitemap.md` |
| 관리자 사이트맵 | `02-product/projects/{project}/YYYY-MM-DD-s4-admin-sitemap.md` |
| 로드맵 | `02-product/projects/{project}/YYYY-MM-DD-s4-roadmap.md` |
| 개발 계획 | `02-product/projects/{project}/YYYY-MM-DD-s4-development-plan.md` |
| WBS | `02-product/projects/{project}/YYYY-MM-DD-s4-wbs.md` |
| UI/UX 기획서 | `05-design/projects/{project}/YYYY-MM-DD-s4-uiux-spec.md` |
| 관리자 UI/UX 기획서 | `05-design/projects/{project}/YYYY-MM-DD-s4-admin-uiux-spec.md` |
| 제작 가이드 | `04-content/projects/{project}/YYYY-MM-DD-s4-production-guide.md` |
| 배포 캘린더 (쇼폼) | `04-content/projects/{project}/YYYY-MM-DD-s4-deployment-calendar.md` |
| PPT | `02-product/projects/{project}/YYYY-MM-DD-s3-*.pptx` |
| 게이트 로그 | `02-product/projects/{project}/gate-log.md` |
| Todo (Tier 2) | `02-product/projects/{project}/YYYY-MM-DD-todo.md` |
| Council 평가 | `02-product/projects/{project}/YYYY-MM-DD-council-evaluation.md` |
| Handoff 문서 | `10-operations/handoff-to-dev/{target-project}/YYYY-MM-DD-sigil-handoff.md` |

### AI 행동 규칙

1. 파이프라인 시작 시 프로젝트 유형을 먼저 식별한다
2. 진입 경로를 판단하여 기존 자료에 따른 Stage 스킵을 제안한다
3. 각 [STOP] 게이트에서 Human 승인을 반드시 받는다
4. 에이전트 회의 결과는 비교표 + 선택 근거를 명시한다
5. 개발 트랙 S3 기획서는 .md + .pptx 모두 생성한다
6. 개발 트랙 S4 완료 후 Trine Handoff 문서를 자동 생성하고 진입을 안내한다
7. 콘텐츠 트랙 S4 완료 후 제작 체크리스트를 제공한다
8. 각 Stage 산출물은 해당 폴더의 `projects/{project}/` 하위에 저장한다
9. 프로젝트 폴더 내 파일명에서 프로젝트명을 제거한다 (폴더가 이미 프로젝트를 나타냄)
10. Stage별 DoD 체크리스트를 게이트 판단 전 확인한다
11. Go/No-Go 스코어링은 DACI 역할 배분 후 실행한다
12. 게이트 통과 시 gate-log.md를 자동 업데이트한다
13. PM 도구 Tier를 파이프라인 시작 시 자동 판단하고, 게이트 통과 시 태스크를 등록한다
14. S3 기획서에 관리자 기능이 포함되면 S4 모든 산출물에 관리자 섹션을 반영한다

---

## Part 2: 구현 항목

### 신규 생성 파일

| 파일 | 위치 | 설명 |
|------|------|------|
| `sigil-pipeline.md` | `.claude/rules/` | SIGIL 파이프라인 규칙 (S1→S4 Stage 정의, Gate 규칙, Agent Teams 패턴) |
| `gdd-writer.md` | `.claude/agents/` | GDD 전문 작성 에이전트 (10섹션 프롬프트 + Mermaid Flow) |
| `content-planner.md` | `.claude/agents/` | 유튜브/쇼폼 대본 + 구성안 + 제작 가이드 에이전트 |
| `pipeline-orchestrator.md` | `.claude/agents/` | S1→S4 오케스트레이션 + Gate 관리 + Agent Council + 병렬 프로젝트 조율 |
| `gdd-template.md` | `09-tools/templates/` | GDD 템플릿 (10개 섹션 + 게임 유형별 확장) |
| `planning-package-template.md` | `09-tools/templates/` | 기획 패키지 템플릿 (6대 산출물 + 관리자 + Trine 세션 로드맵) |
| `uiux-spec-template.md` | `09-tools/templates/` | UI/UX 기획서 템플릿 (와이어프레임 + 컴포넌트 + 인터랙션) |
| `dod-checklist.md` | `09-tools/templates/` | Stage별 DoD 체크리스트 (AI/Human 태깅 + 게이트 로그 + PPT) |
| `production-guide-template.md` | `09-tools/templates/` | 콘텐츠 S4 제작 가이드 템플릿 |
| `council-evaluation-template.md` | `09-tools/templates/` | Agent Council 5축 평가 매트릭스 |
| `notion-task-template.md` | `09-tools/templates/` | PM 도구 연동 (Notion/Markdown) Todo 구조 |

### Trine 재사용 인프라 (기존 자산)

| 자산 | 원본 경로 | 재사용 위치 |
|------|----------|-----------|
| session-state.mjs | `~/.claude/scripts/` | 기획 세션 상태 추적 + 체크포인트 |
| trine-pm-updater | `~/.claude/trine/agents/` | Stage별 진행 상태 자동 갱신 |
| spec-writer 에이전트 | `~/.claude/trine/agents/spec-writer-base.md` | Trine Phase 2에서 SDD 작성 (SIGIL에서는 미사용) |
| spec-template-base.md | `~/.claude/trine/templates/` | Trine Phase 2 Spec 형식 (FR/NFR ID) |
| validate-spec.js | `~/.claude/trine/github-spec-kit/scripts/` | Trine Phase 2 Spec 구조 검증 |

### Business 워크스페이스 재사용 (기존 자산)

| 자산 | 재사용 위치 |
|------|-----------|
| research-coordinator 에이전트 | S1 리서치 총괄 |
| market-researcher / academic-researcher / fact-checker | S1 병렬 리서치, Council Councilor A/D/E |
| `/lean-canvas` 커맨드 | S2 린 캔버스 |
| product-manager-toolkit 스킬 | S2 RICE 우선순위 |
| `/prd` 커맨드 + requirements-clarity 스킬 | S3 앱/웹 PRD |
| technical-writer 에이전트 | S4 기획 패키지 작성 (model: sonnet) |
| cto-advisor 스킬 | S4 기술 검토, Council Councilor B |
| ux-researcher 에이전트 | S4 UX 검증, Council Councilor C |
| `/pptx` 스킬 | S3 PPT 변환 (필수) |
| seo-analyzer 에이전트 | S1 콘텐츠 트랙 + S4 SEO |
| orchestrator 에이전트 패턴 | 병렬 Task 관리 참고 |

---

## 검증

**파이프라인 아키텍처**:
- 5유형(앱/웹/게임/롱폼/쇼폼) 모두 S1→S4 흐름 커버 확인
- 신규 에이전트 3개(gdd-writer, content-planner, pipeline-orchestrator) 설계 완성도
- Trine 연동: S4 기획 패키지 + S3 기획서 → Trine Phase 1~2 입력 흐름 무결
- Agent Teams: Fan-out/Competing Hypotheses/Council 패턴 적용 확인
- 병렬 멀티 프로젝트 실행 가능 여부 확인
- 방법론: Stage별 최신 방법론 매핑 + 필수/선택 분류 완비
- 거버넌스: Go/No-Go 스코어링 + Kill Criteria + DACI 프레임워크 도입
- DoD: Stage별 완료 기준 체크리스트 완비 (AI/Human 구분)
- AI 행동 규칙: 14개 항목 정의 (sigil-pipeline.md 규칙과 일치)

**고도화 (v2)**:
- Agent Council 5+2 토너먼트: 5축 매트릭스 + 라운드 2 정교화 + 최종 선택
- PPT 변환: S3 개발 트랙 필수 산출물
- S4 Wave 프로토콜: technical-writer → cto-advisor/ux-researcher → technical-writer
- 파이프라인 유연성: Soft/Hard 의존성 + 4가지 진입 경로
- 관리자 페이지: S3/S4 동등 레벨 산출물 + 우선순위 결정
- Trine 세션 로드맵: 세션별 Spec/Plan/Task 문서명 명시
- PM 도구 연동: Notion MCP / Markdown Fallback 2-Tier
- 게이트 로그: 게이트 통과 기록 메커니즘

**콘텐츠 파이프라인**:
- 유튜브 롱폼: 대본 + 구성안 + 썸네일 가이드 완성도
- 유튜브 쇼폼: 배치 대본 + 해시태그 전략
- 라이브 방송: 구성안 + 토크 포인트
- SEO: 키워드 전략 + 메타데이터 최적화
- 제작 가이드 템플릿: production-guide-template.md
