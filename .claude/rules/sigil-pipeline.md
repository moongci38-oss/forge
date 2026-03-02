# SIGIL Pipeline Rules

> **SIGIL (Strategy & Idea Generation Intelligent Loop)**
> 마법 인장(印章) — 프로젝트에 생명을 불어넣는 설계 문양.
> 각 Stage가 인장의 한 획. 완성된 Sigil이 Trine에 전달되면 프로젝트가 "소환"된다.
> **Sigil(설계) → Trine(구현)** = 마법진 완성 → 삼위일체 소환

## 파이프라인 구조

```
S1 Research → S2 Concept → S3 Design Document → S4 Planning Package/Production Guide
     ↓             ↓              ↓                      ↓
  [STOP]        [STOP]         [STOP]                 [STOP]
  리서치 리뷰    비전 승인       기획서 승인              → Trine / 제작
```

## 실행 모드 (2가지)

| 모드 | 설명 | 적용 |
|------|------|------|
| **기본 모드** | S1→S2→S3→S4 순차 진행 | 기본값. 대부분의 프로젝트 |
| **카운슬 모드** | 5+2 Agent Council 토너먼트 | Human 명시 선택. S1+S3 통합 실행 |

## 파이프라인 유연성 (Soft/Hard 의존성)

### Soft 의존성 (스킵 가능)

```
S1(리서치) → S2(컨셉)     ← 기존 자료가 있으면 스킵 가능
S2(컨셉) → S3(기획서)     ← 컨셉이 확정되면 스킵 가능
```

### Hard 의존성 (반드시 순서 유지)

```
S3(기획서) → S4(기획 패키지)           ← S3 기획서 없이 S4 진입 불가
S4(기획 패키지) → Trine(Spec 작성)     ← S4 개발 계획 없이 Trine 진입 불가
S3 관리자 페이지 포함 → S4에도 반영     ← 관리자 기능 누락 방지
```

### 진입 경로 (4가지)

| 시나리오 | 시작 Stage | 필요 입력 | 스킵 |
|---------|:---------:|----------|------|
| 아이디어만 있음 | S1 | 아이디어 한 줄 | 없음 (전체 실행) |
| 자료/리서치 있음 | S2 | 기존 리서치 문서 or 참고 자료 | S1 스킵 |
| 컨셉 확정됨 | S3 | 컨셉 문서 or Lean Canvas | S1+S2 스킵 |
| 기획서 있음 | S4 | PRD/GDD 문서 | S1+S2+S3 스킵 |

## 프로젝트 유형 (5유형)

| 유형 | 트랙 | S3 산출물 | S4 산출물 | 다음 단계 |
|------|:----:|----------|----------|----------|
| 앱 개발 | 개발 | PRD (.md + .pptx) | 기획 패키지 (아래 참조) | Trine Phase 1 |
| 웹 서비스 | 개발 | PRD + API Spec (.md + .pptx) | 기획 패키지 (아래 참조) | Trine Phase 1 |
| 게임 개발 | 개발 | GDD (.md + .pptx) | 기획 패키지 (아래 참조) | Trine Phase 1 |
| 유튜브/롱폼 | 콘텐츠 | 대본 + 구성안 | 제작 가이드 + SEO | 촬영/편집/배포 |
| 쇼폼 콘텐츠 | 콘텐츠 | 쇼폼 대본 (배치) | 배포 캘린더 | 편집/배포 |

## Stage 상세

### S1. Research (리서치)

- **개발 트랙**: research-coordinator → market/academic/fact-checker (병렬)
- **콘텐츠 트랙**: research-coordinator → market-researcher + 트렌드 분석
- **에이전트 회의**: Competing Hypotheses — 리서치 에이전트 독립 분석 → 비교 → 방향 도출
- **필수 방법론**: AI-augmented Research + JTBD + Competitive Intelligence 자동화 + Evidence-Based Management
- **선택 방법론**: SOAR, PESTLE
- **플러그인 보강** (선택적):
  - `enterprise-search` — 크로스 소스 통합 검색 (Slack/이메일/위키 등 내부 데이터 소스 연결 시)
  - `data:data-exploration` + `data:statistical-analysis` — 시장 데이터 정량 분석이 필요할 때
- **산출물**: `01-research/projects/{project}/YYYY-MM-DD-s{N}-{topic}.md`
- **게이트**: **[STOP]** 리서치 결과 리뷰 + 방향 확정

### S2. Concept (컨셉 확정)

- **개발 트랙**: `/lean-canvas` + 제품/게임 컨셉
- **콘텐츠 트랙**: `/content-calendar` + 채널 전략
- **필수 방법론**: Pretotyping + Mom Test + Lean Validation + TAM/SAM/SOM + OKR
- **선택 방법론**: OST (Opportunity Solution Tree), PR/FAQ
- **플러그인 보강** (선택적):
  - `product-management:roadmap-management` — 로드맵 우선순위 결정 시 RICE/ICE 자동 스코어링 보조
- **산출물 (개발)**: `02-product/projects/{project}/YYYY-MM-DD-s2-concept.md`
- **산출물 (콘텐츠)**: `04-content/projects/{project}/YYYY-MM-DD-s2-channel-strategy.md`
- **게이트**: **[STOP]** 비전/타겟/차별점 승인

### S3. Design Document (기획서)

| 유형 | 에이전트/커맨드 | 산출물 |
|------|---------------|--------|
| 앱/웹 | `/prd` 커맨드 | PRD (.md + **.pptx 필수**) |
| 게임 | gdd-writer 에이전트 | GDD (.md + **.pptx 필수**) |
| 유튜브/롱폼 | content-planner 에이전트 | 대본 + 구성안 (.md) |
| 쇼폼 | content-planner 에이전트 | 쇼폼 대본 배치 (.md) |

- **에이전트 회의**: Competing Hypotheses — 기획 에이전트 2~3명 독립 초안 → 최적안 선택/병합
- **필수 방법론**: Shape Up Pitch + User Story Mapping + Modern PRD
- **선택 방법론**: Outcome-based Roadmap, Event Storming
- **플러그인 보강** (선택적):
  - `product-management:stakeholder-comms` — PRD 승인 후 이해관계자 업데이트 생성 (커스텀에 없는 기능)
  - `marketing:content-creation` — 보도자료/케이스스터디 작성 시 활용 (content-planner가 커버하지 않는 유형)
  - `marketing:competitive-analysis` — 배틀카드 생성 기능 보조 (커스텀에 없는 기능)
- **PPT 변환 (개발 트랙 필수)**: S3 기획서 .md 완성 후 `/pptx` 스킬로 .pptx 생성 필수
- **게이트**: **[STOP]** 기획서 승인 (PPT 포함)

### S4. Planning Package / Production Guide

#### 개발 트랙 — 기획 패키지

S3 기획서(PRD/GDD) 기반으로 Trine 진입 전 종합 기획 문서를 작성한다.

| 산출물 | 설명 | 필수 |
|--------|------|:----:|
| 상세 기획서 | S3 기획서를 구현 관점에서 상세화 (화면별 동작, 데이터 흐름) | **필수** |
| 사이트맵 | 페이지/화면 계층 구조 + 네비게이션 흐름 | **필수** |
| 로드맵 | 마일스톤별 기능 배치 + 우선순위 | **필수** |
| 상세 개발 계획 | 기술 스택, 아키텍처 방향, 개발 환경 + **Trine 세션 로드맵** | **필수** |
| WBS | 작업 분해 구조 (태스크별 예상 규모) | **필수** |
| UI/UX 기획서 | 와이어프레임, 컴포넌트 스펙, 인터랙션 패턴, 디자인 가이드 | **필수** |
| 테스트 전략서 | 테스트 계층/비율, FE/BE 테스트 도구, 시딩 전략, 환경 설정, 커버리지 목표 | **필수** |

- **에이전트**: technical-writer (작성) + cto-advisor (기술 검토) + ux-researcher (UX 검증)
- **필수 방법론**: Now/Next/Later + RICE/ICE Scoring + Agile WBS + C4 Model + ADR
- **플러그인 보강** (선택적):
  - `data:interactive-dashboard-builder` — 지표 대시보드 HTML 생성 시 활용

#### 관리자 페이지 필수 포함 규칙

관리자 페이지는 서비스와 **동등 레벨**의 산출물이다. S3 기획서에 관리자 기능이 포함되면 S4에서 반드시 아래를 반영한다:

| 산출물 | 서비스 | 관리자 |
|--------|--------|--------|
| 상세 기획서 | s4-detailed-plan.md | s4-admin-detailed-plan.md |
| 사이트맵 | s4-sitemap.md | s4-admin-sitemap.md |
| 로드맵 | s4-roadmap.md (통합 — 서비스+관리자 마일스톤 병기) | |
| 개발 계획 | s4-development-plan.md (통합 — 서비스+관리자 세션 포함) | |
| WBS | s4-wbs.md (통합 — 서비스+관리자 에픽 병기) | |
| UI/UX 기획서 | s4-uiux-spec.md | s4-admin-uiux-spec.md |
| 테스트 전략서 | s4-test-strategy.md (통합 — 서비스+관리자 공통) | |

**관리자 우선순위** (S2 컨셉 단계에서 결정):

| 유형 | 관리자 우선순위 | 예시 | 모바일 정책 |
|------|:-----------:|------|-----------|
| B2C 앱/게임 | 서비스 > 관리자 | 바둑이 게임, SNS 앱 | 운영툴 모바일 화면 필수 |
| B2B SaaS / 내부 도구 | **관리자 ≥ 서비스** | CMS, 대시보드, ERP | 관리자 Mobile-first 기본 |
| 플랫폼 (양면) | 관리자 = 서비스 | 마켓플레이스, 중개 플랫폼 | 관리자 Mobile-first 기본 |

> **모바일 정책**: 관리자/운영툴은 Mobile-first가 기본이다. Desktop-only 화면은 명시적으로 선언해야 한다.
> 게임 프로젝트(GodBlade 등)의 운영툴도 모바일 화면 기획 대상에 포함된다.

#### 콘텐츠 트랙

| 유형 | 에이전트 | 산출물 | 다음 단계 |
|------|---------|--------|----------|
| 유튜브/롱폼 | content-planner | 제작 가이드 + SEO 전략 | → 촬영/편집 |
| 쇼폼 | content-planner | 배포 캘린더 + 해시태그 전략 | → 편집/배포 |

- **게이트**: **[STOP]** 승인 → 개발은 Trine 진입, 콘텐츠는 제작 진입

## Agent Council 모드 (선택적)

> 상세: `.claude/rules/sigil-council-mode.md` 참조
> Human이 명시적으로 선택 시에만 활성화. 기본 모드와 양자택일.

## Agent Teams 활용

| 패턴 | 적용 시점 |
|------|----------|
| **Fan-out/Fan-in** | S1 리서치 (독립 영역 병렬), 멀티 프로젝트 병렬, Agent Council 라운드 1 |
| **Competing Hypotheses** | S3 기획서 에이전트 회의 (기본 모드) |
| **Pipeline** | S1→S2→S3→S4 순차 의존 |

## 모델 계층화

```
pipeline-orchestrator (Lead)    → Opus 4.6   (판단, 종합, 회의 심판)
기획서 작성 (gdd/prd/content)   → Sonnet 4.6 (문서 작성, 분석)
기획 패키지 작성 (technical-writer) → Sonnet 4.6 (S4 산출물 작성)
리서치/검색 Teammates            → Haiku 4.5  (검색, 팩트체크, 트렌드 수집)
```

## PM 도구 연동

### 2-Tier Fallback

| Tier | 조건 | 도구 |
|:----:|------|------|
| Tier 1 | Notion MCP 연결 가능 | Notion 자동 등록 |
| Tier 2 | Notion 연결 불가 | 내부 Markdown Todo 문서 |

- pipeline-orchestrator가 파이프라인 시작 시 Tier 자동 선택
- 각 [STOP] 게이트 통과 시 다음 Stage 태스크를 자동 등록
- 상세 구조: `09-tools/templates/notion-task-template.md` 참조

## Trine 연동 (개발 트랙)

### S4 완료 시 자동 액션

1. 기획 패키지 산출물 존재 확인
2. **Handoff 요약 문서 자동 생성**: `10-operations/handoff-to-dev/{target-project}/YYYY-MM-DD-sigil-handoff.md`
3. Trine 진입 안내 메시지 Human에게 제공
4. **실제 Trine 세션 시작은 Human 승인 후 수동 실행** (`/trine` 커맨드)

### SIGIL 산출물 → Trine 매핑

| SIGIL 산출물 | Trine 활용 시점 |
|-------------|----------------|
| S1 리서치 | Phase 1 컨텍스트 참고 |
| S3 기획서 (PRD/GDD) | Phase 1.5 요구사항 분석, Phase 2 Spec 작성 입력 |
| S4 기획 패키지 | Phase 1 세션 이해, Phase 2 Spec 작성 입력 |
| S4 Trine 세션 로드맵 | Trine 세션별 범위/산출물 가이드 |

## 게이트 로그 메커니즘

각 [STOP] 게이트 통과 시 프로젝트 폴더에 `gate-log.md`를 자동 생성/업데이트한다.

```markdown
## Gate Log — {프로젝트명}

| Stage | 결과 | 일자 | 조건 | 비고 |
|:-----:|:----:|------|------|------|
| S1 | ✅ PASS | YYYY-MM-DD | DoD 전항목 충족 | |
| S2 | ✅ PASS | YYYY-MM-DD | Go/No-Go 85점 | |
| S3 | — | — | — | |
| S4 | — | — | — | |
```

## 산출물 저장 경로

| 유형 | 경로 |
|------|------|
| 리서치 | `01-research/projects/{project}/YYYY-MM-DD-s{N}-{topic}.md` |
| 컨셉 (개발) | `02-product/projects/{project}/YYYY-MM-DD-s2-concept.md` |
| 컨셉 (콘텐츠) | `04-content/projects/{project}/YYYY-MM-DD-s2-channel-strategy.md` |
| PRD | `02-product/projects/{project}/YYYY-MM-DD-s3-prd.md` |
| PRD PPT | `02-product/projects/{project}/YYYY-MM-DD-s3-prd.pptx` |
| GDD | `02-product/projects/{project}/YYYY-MM-DD-s3-gdd.md` |
| GDD PPT | `02-product/projects/{project}/YYYY-MM-DD-s3-gdd.pptx` |
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
| 테스트 전략서 | `02-product/projects/{project}/YYYY-MM-DD-s4-test-strategy.md` |
| 제작 가이드 | `04-content/projects/{project}/YYYY-MM-DD-s4-production-guide.md` |
| 배포 캘린더 (쇼폼) | `04-content/projects/{project}/YYYY-MM-DD-s4-deployment-calendar.md` |
| 게이트 로그 | `02-product/projects/{project}/gate-log.md` |
| Todo (Tier 2) | `02-product/projects/{project}/YYYY-MM-DD-todo.md` |
| Council 평가 기록 | `02-product/projects/{project}/YYYY-MM-DD-council-evaluation.md` |
| Handoff 문서 | `10-operations/handoff-to-dev/{target-project}/YYYY-MM-DD-sigil-handoff.md` |

## 병렬 멀티 프로젝트

각 프로젝트가 독립 Agent Team으로 병렬 실행 가능:

```
Project A (게임 S1~S4) ────→ Trine
Project B (앱 S1~S4) ──────→ Trine
Project C (유튜브 S1~S4) ──→ 제작
Project D (쇼폼 S1~S3) ────→ 제작
```

## S2 Gate: Go/No-Go 스코어링

S2 [STOP] 게이트에서 프로젝트 진행 여부를 정량 평가한다.

| 영역 | 가중치 | 평가 기준 |
|------|:-----:|---------|
| 시장 기회 | 30% | TAM/SAM/SOM, 성장률, 타이밍 |
| 기술 실현성 | 25% | 기술 스택 검증, 리소스 가용성 |
| 비즈니스 모델 | 25% | 수익화 경로, 유닛 이코노믹스 |
| 위험 관리 | 20% | 규제, 경쟁, 기술 리스크 |

- **80점+ = Go** → S3 진행
- **60-79점 = 조건부** → 보완 후 재평가
- **60점 미만 = No-Go** → 피벗 또는 중단

### Kill Criteria (하나라도 해당 시 즉시 No-Go)

- TAM < $1M (시장 규모 부족)
- 경쟁사 70%+ 시장 점유 (진입 장벽)
- 핵심 기술 불가 (현재 기술로 구현 불가)
- 규제 장벽 (법적으로 출시 불가)

## Stage별 DoD (Definition of Done)

각 [STOP] 게이트 통과 전 DoD 체크리스트를 검증한다.
상세 체크리스트: `09-tools/templates/dod-checklist.md`

## Stage별 방법론 참조

> 상세 방법론 설명은 `docs/planning/done/2026-02-27-sigil-pipeline-architecture.md` 참조

| Stage | 필수 방법론 | 선택 방법론 |
|:-----:|-----------|-----------|
| S1 | AI-augmented Research, JTBD, Competitive Intelligence, Evidence-Based Mgmt | SOAR, PESTLE |
| S2 | Pretotyping, Mom Test, Lean Validation, TAM/SAM/SOM, OKR | OST, PR/FAQ |
| S3 | Shape Up Pitch, User Story Mapping, Modern PRD | Outcome-based Roadmap, Event Storming |
| S4 | Now/Next/Later, RICE/ICE, Agile WBS, C4 Model, ADR | WSJF |
| 거버넌스 | Stage-Gate, Go/No-Go, DACI, Double Diamond | Pre-mortem |
| 관리 | Personal Kanban, Decision Log | — |

## 템플릿

| 템플릿 | 경로 | 용도 |
|--------|------|------|
| GDD 템플릿 | `09-tools/templates/gdd-template.md` | S3 게임 기획서 |
| 기획 패키지 템플릿 | `09-tools/templates/planning-package-template.md` | S4 개발 트랙 |
| UI/UX 기획서 템플릿 | `09-tools/templates/uiux-spec-template.md` | S4 UI/UX |
| 제작 가이드 템플릿 | `09-tools/templates/production-guide-template.md` | S4 콘텐츠 트랙 |
| 테스트 전략서 템플릿 | `09-tools/templates/test-strategy-template.md` | S4 테스트 전략 |
| DoD 체크리스트 | `09-tools/templates/dod-checklist.md` | 전 Stage 검증 |
| Council 평가 매트릭스 | `09-tools/templates/council-evaluation-template.md` | Agent Council 모드 |
| PM Todo 구조 | `09-tools/templates/notion-task-template.md` | PM 도구 연동 |

## AI 행동 규칙

1. 파이프라인 시작 시 프로젝트 유형을 먼저 식별한다
2. 진입 경로를 판단하여 기존 자료에 따른 Stage 스킵을 제안한다
3. 각 [STOP] 게이트에서 Human 승인을 반드시 받는다
4. 에이전트 회의 결과는 비교표 + 선택 근거를 명시한다
5. 개발 트랙 S3 기획서는 **.md + .pptx** 모두 생성한다
6. 개발 트랙 S4 완료 후 Trine Handoff 문서를 자동 생성하고 진입을 안내한다
7. 콘텐츠 트랙 S4 완료 후 제작 체크리스트를 제공한다
8. 각 Stage 산출물은 해당 폴더의 `projects/{project}/` 하위에 저장한다
9. 프로젝트 폴더 내 파일명에서 프로젝트명을 제거한다 (폴더가 이미 프로젝트를 나타냄)
10. Stage별 DoD 체크리스트를 게이트 판단 전 확인한다
11. S2 Go/No-Go 스코어링은 Kill Criteria 검토 후 실행한다
12. 게이트 통과 시 gate-log.md를 자동 업데이트한다
13. PM 도구 Tier를 파이프라인 시작 시 자동 판단하고, 게이트 통과 시 태스크를 등록한다
14. S3 기획서에 관리자 기능이 포함되면 S4 모든 산출물에 관리자 섹션을 반영한다
