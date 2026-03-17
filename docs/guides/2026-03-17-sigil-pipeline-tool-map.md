# SIGIL Pipeline 전체 구조 + 도구 맵

> SIGIL (Strategy & Idea Generation Intelligent Loop) 파이프라인의 각 Stage별 흐름, 산출물, 게이트, 사용 도구(MCP/CLI/스킬/에이전트)를 통합 정리한 레퍼런스 문서.

---

## 파이프라인 전체 흐름

```
S1 Research → S2 Concept → S3 Design Document → S4 Planning Package → Trine (개발)
     ↓             ↓              ↓                      ↓
 [AUTO-PASS]    [STOP]         [STOP]              [AUTO-PASS]
 DoD 자동검증   비전 승인       기획서 승인          Wave 검증 → Handoff
```

### 의존성 규칙

| 유형 | 규칙 |
|------|------|
| **Soft** (스킵 가능) | S1→S2, S2→S3 |
| **Hard** (필수 순서) | S3→S4, S4→Trine |

### 진입 경로

| 시나리오 | 시작 Stage | 스킵 |
|---------|:---------:|------|
| 아이디어만 있음 | S1 | 없음 |
| 리서치/자료 있음 | S2 | S1 |
| 컨셉 확정됨 | S3 | S1+S2 |
| 기획서 있음 | S4 | S1+S2+S3 |

---

## S1. Research (시장조사)

### 개요

| 항목 | 내용 |
|------|------|
| **커맨드** | `/research` |
| **에이전트** | `research-coordinator` (Lead) → Fan-out 병렬 조율 |
| **필수 방법론** | AI-augmented Research, JTBD, Competitive Intelligence, Evidence-Based Mgmt |
| **선택 방법론** | SOAR, PESTLE |
| **산출물** | `01-research/projects/{project}/YYYY-MM-DD-s1-*.md` |
| **게이트** | **[AUTO-PASS]** — DoD 자동 검증 |

### 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| **Brave Search** | MCP | 실시간 웹 검색 (시장 데이터, 뉴스, 트렌드) |
| **WebSearch** | 내장 | 웹 검색 (Brave 보완/대체) |
| **WebFetch** | 내장 | 특정 URL 콘텐츠 수집 |
| **Context7** | MCP Plugin | 기술 문서/라이브러리 최신 정보 조회 |
| **Sequential Thinking** | MCP | 복잡한 리서치 전략 구조화 |
| **Notion** | MCP | 리서치 결과 Notion DB에 등록 |
| `/screenshot-analyze` | 스킬 (CLI) | 경쟁사 스크린샷 분석 (Gemini Vision CLI) |
| `/game-reference-collect` | 스킬 | 경쟁작 레퍼런스 통합 수집 (게임) |
| `academic-researcher` | 에이전트 | 학술 논문/피어리뷰 소스 조사 |
| `fact-checker` | 에이전트 | 수치/출처 교차 검증 |

### 모델 계층화

| 역할 | 모델 |
|------|------|
| research-coordinator (조율) | Opus 4.6 |
| 리서치 Teammate (검색/수집) | Haiku 4.5 |

---

## S2. Concept (컨셉 확정)

### 개요

| 항목 | 내용 |
|------|------|
| **커맨드** | `/lean-canvas` |
| **필수 방법론** | Pretotyping, Mom Test, Lean Validation, TAM/SAM/SOM, OKR |
| **선택 방법론** | OST (Opportunity Solution Tree), PR/FAQ |
| **산출물** | `02-product/projects/{project}/YYYY-MM-DD-s2-concept.md` |
| **게이트** | **[STOP]** — 비전/타겟/차별점 Human 승인 |

### Go/No-Go 스코어링

| 영역 | 가중치 | 평가 기준 |
|------|:-----:|---------|
| 시장 기회 | 30% | TAM/SAM/SOM, 성장률, 타이밍 |
| 기술 실현성 | 25% | 기술 스택 검증, 리소스 가용성 |
| 비즈니스 모델 | 25% | 수익화 경로, 유닛 이코노믹스 |
| 위험 관리 | 20% | 규제, 경쟁, 기술 리스크 |

- **80+** = Go → S3 진행
- **60-79** = 조건부 → 보완 후 재평가
- **60 미만** = No-Go → 피벗 또는 중단

### 기획 디렉션 5축

| # | 축 | 형식 요건 |
|:-:|---|---------|
| 1 | 전략 방향 | "A > B" 또는 "A, not B" (트레이드오프 필수) |
| 2 | 경험 원칙 | 측정 가능한 수치 포함 |
| 3 | 범위 경계 | Do 2개+ / Don't 2개+ (태그 형식) |
| 4 | 품질 기준 | 측정 가능한 NFR 값 |
| 5 | 벤치마크 | 레퍼런스 1-3개 + 참조 이유 |

### Pretotyping 3경로

| 경로 | 방법 | 소요 | 도구 |
|------|------|:----:|------|
| A | 클릭 가능 프로토타입 | 1-2h | **Replit Agent** (외부) |
| B | AI 목업 스크린샷 | 30min | **Stitch MCP** |
| C | 문서 Pretotype (Landing/PR/FAQ) | 1h | Markdown 직접 작성 |

### 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| **Brave Search** | MCP | TAM/SAM/SOM 시장 수치 검색 |
| **WebSearch** | 내장 | 시장 데이터 보완 검색 |
| **Stitch** | MCP | Pretotyping 경로 B — AI UI 목업 생성 |
| **Sequential Thinking** | MCP | Go/No-Go 스코어링 전략 구조화 |
| **Notion** | MCP | 컨셉 문서 Notion 등록 |
| `product-management:roadmap-management` | 플러그인 스킬 | RICE/ICE 자동 스코어링 보조 |
| `concept-map` | Playground 템플릿 | 컨셉 관계도, 핵심 가치 맵핑 (선택) |
| `data-explorer` | Playground 템플릿 | TAM/SAM/SOM 수치 시각 탐색 (선택) |

---

## S3. Design Document (기획서)

### 개요

| 항목 | 내용 |
|------|------|
| **커맨드** | `/prd` (앱/웹) · `gdd-writer` 에이전트 (게임) |
| **필수 방법론** | Shape Up Pitch, User Story Mapping, Modern PRD (앱/웹) |
|  | GDD 10섹션 + Core Loop + 밸런싱 수치 (게임) |
| **핵심 프로세스** | **에이전트 회의** (Competing Hypotheses) — 2~3명 독립 초안 → 비교 → 최적안 선택/병합 |
| **산출물** | PRD/GDD (**.md + .pptx 필수**) |
| **게이트** | **[STOP]** — 기획서 + PPT Human 승인 |

### 에이전트 회의 흐름

```
S2 디렉션 5축 요약 프롬프트 주입 (~5줄)
    ↓
에이전트 A/B/C 자유 초안 작성
    ↓
디렉션 탈락 필터 (Don't 태그 위반 → 탈락)
    ↓
생존 초안 비교 (아키텍처, 성능, UX)
    ↓
최적안 선택/병합 → Human 승인
```

### PPT 단계적 생성

1. **Step 1**: 소규모 시안 5-7슬라이드 → Human 확인
2. **Step 2**: 승인 후 전체 확장 + 시각 자료 삽입

### 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| **NanoBanana** | MCP | 컨셉 일러스트, PPT 배경 이미지, 캐릭터/마스코트 AI 생성 |
| **Stitch** | MCP | 핵심 화면 UI 목업 생성 + `generate_variants`로 변형 비교 |
| **Draw.io** | MCP | 복잡한 아키텍처/상태도 (15+ 노드), C4 Model |
| **Notion** | MCP | 기획서 Notion 등록, 에이전트 회의 결과 기록 |
| `/pptx` | 스킬 | .md → .pptx 변환 (PptxGenJS 기반) |
| `/screenshot-analyze` | 스킬 (CLI) | 경쟁사 UI 스크린샷 분석 (Gemini Vision) |
| `/game-logic-visualize` | 스킬 | FSM/확률/경제 시각화 + 시뮬레이터 (게임) |
| `/game-reference-collect` | 스킬 | 경쟁작 레퍼런스 통합 수집·분석 (게임) |
| `/video-reference-guide` | 스킬 (CLI) | 게임 연출 영상 프레임 분석 (Gemini Video CLI) |
| `analyze-screenshot.sh` | CLI | Gemini Vision 이미지 분석 (스킬 내부 호출) |
| `analyze-video.sh` | CLI | Gemini 프레임 분석 (스킬 내부 호출) |
| Mermaid | 인라인 | 간단한 플로우/시퀀스/ER (≤15 노드) |
| `product-management:stakeholder-comms` | 플러그인 스킬 | PRD 승인 후 이해관계자 업데이트 (선택) |
| `marketing:competitive-analysis` | 플러그인 스킬 | 배틀카드 생성 보조 (선택) |
| `gdd-writer` | 에이전트 | GDD 전문 작성 (게임 프로젝트) |
| `design-playground` | Playground 템플릿 | UI 레이아웃/디자인 토큰 탐색 (선택) |

### 프로젝트 유형별 필수 시각 자료

| 시각 자료 | 게임 | 웹/앱 | 도구 |
|----------|:----:|:----:|------|
| UI 목업 | 필수 | 필수 | Stitch MCP |
| 컨셉 일러스트 | 필수 | 권장 | NanoBanana MCP |
| 플로우 다이어그램 | 필수 | 필수 | Mermaid / Draw.io MCP |
| 경쟁사 UI 분석 | 필수 | 필수 | `/screenshot-analyze` |
| 이펙트/연출 레퍼런스 | 필수 | 선택 | `/video-reference-guide` |
| FSM/로직 시각화 | 필수 | 선택 | `/game-logic-visualize` |
| 반응형 레이아웃 | N/A | 필수(Large) | Stitch `generate_variants` |

### 모델 계층화

| 역할 | 모델 |
|------|------|
| pipeline-orchestrator (회의 심판) | Opus 4.6 |
| 기획 에이전트 A/B/C (초안 작성) | Sonnet 4.6 |
| gdd-writer (GDD 작성) | Sonnet 4.6 |

---

## S4. Planning Package (기획 패키지)

### 개요

| 항목 | 내용 |
|------|------|
| **에이전트** | `technical-writer` (작성) + `cto-advisor` (기술 검토) + `ux-researcher` (UX 검증) |
| **필수 방법론** | Now/Next/Later, RICE/ICE Scoring, C4 Model, ADR |
| **게이트** | **[AUTO-PASS]** — Wave 2+3 자동 검증 → Trine 진입 |

### 3대 산출물

| # | 산출물 | 파일명 | 내용 |
|:-:|--------|--------|------|
| 1 | **상세 기획서** | `s4-detailed-plan.md` | 화면별 동작 + 데이터 흐름 + 사이트맵 |
| 2 | **개발 계획** | `s4-development-plan.md` | 기술 스택 + 아키텍처 + ADR + 세션 로드맵 + WBS + 테스트 전략 |
| 3 | **UI/UX 기획서** | `s4-uiux-spec.md` | 와이어프레임 + 컴포넌트 스펙 + 인터랙션 패턴 + 디자인 가이드 |

> 관리자 기능이 S3에 포함된 경우 → 관리자 산출물도 별도 작성 (s4-admin-detailed-plan.md, s4-admin-uiux-spec.md)

### Wave Protocol

```
Wave 1 (순차): technical-writer → 3대 산출물 초안
    ↓
Wave 2A (검증): S3 FR/NFR → S4 반영 체크 (누락 0건)
Wave 2B (검증): S2 디렉션 5축 일관성 검증 (Don't 태그 위반 = CRITICAL)
    ↓
Wave 3 (병렬):
  ├─ cto-advisor → 기술 검토 (아키텍처, ADR)
  └─ ux-researcher → UX 검증 (와이어프레임, 인터랙션)
    ↓
Wave 4: technical-writer → 리뷰 반영 최종본
```

### AUTO-PASS 조건 (모두 충족)

1. `sigil-gate-check.sh S4` → PASS
2. Wave 2A: 누락 FR/NFR 0건
3. Wave 2B: CRITICAL 이슈 0건 (Don't 태그 위반 없음)
4. Wave 3: CRITICAL 이슈 0건

### 사용 도구

| 도구 | 유형 | 용도 | Wave |
|------|:----:|------|:----:|
| **Stitch** | MCP | 상세 화면 목업, 반응형 변형 (Desktop+Mobile) | W1 |
| **NanoBanana** | MCP | 히어로 이미지, 컨셉 일러스트, 아이콘 | W1 |
| **Draw.io** | MCP | C4 아키텍처 (Level 1-4), 복잡한 플로우 (15+ 노드) | W1 |
| **Notion** | MCP | S4 산출물 + Gate 결과 Notion 등록 | W4 |
| `/screenshot-analyze` | 스킬 (CLI) | 경쟁사 UI 비교, 구현 레퍼런스 분석 | W1 |
| `/game-logic-visualize` | 스킬 | FSM/확률/경제 시각화 (게임 — 상세화) | W1 |
| `/video-reference-guide` | 스킬 (CLI) | 핵심 연출 레퍼런스 분석 (게임 Large) | W1 |
| `sigil-gate-check.sh` | CLI | S4 DoD 8항목 자동 검증 | Gate |
| Mermaid | 인라인 | 간단한 플로우/시퀀스/ER (≤15 노드) | W1 |
| `technical-writer` | 에이전트 | 3대 산출물 작성 (MCP 도구 직접 호출 포함) | W1, W4 |
| `cto-advisor` | 에이전트 | 기술 검토 — 개발 계획, 아키텍처, ADR | W3 |
| `ux-researcher` | 에이전트 | UX 검증 — UI/UX 기획서, 와이어프레임 | W3 |
| `data:interactive-dashboard-builder` | 플러그인 스킬 | 지표 대시보드 HTML (선택) | W1 |
| `code-map` | Playground 템플릿 | 아키텍처 시각화, 모듈 관계도 (선택) | W1 |
| `document-critique` | Playground 템플릿 | [STOP] Gate 구조화 문서 리뷰 (선택) | Gate |

### S4 산출물별 시각 자료 기준 (프로젝트 유형별)

| S4 산출물 | 게임 | 웹/앱 | 도구 |
|----------|------|-------|------|
| 상세 기획서 | FSM + UI 목업 + 플로우 | UI 목업 + 사이트맵 + 유저 플로우 | Stitch + `/game-logic-visualize` + Mermaid/Draw.io |
| 개발 계획 | C4 다이어그램 + 테스트 구조도 | C4 다이어그램 + 테스트 구조도 | Draw.io MCP |
| UI/UX 기획서 | 전체 목업 + 레퍼런스 비교 + 인터랙션 | 전체 목업(Desktop+Mobile) + 경쟁사 비교 + 인터랙션 | Stitch + `/screenshot-analyze` |

### 모델 계층화

| 역할 | 모델 |
|------|------|
| pipeline-orchestrator (Lead) | Opus 4.6 |
| technical-writer (산출물 작성) | Sonnet 4.6 |
| cto-advisor (기술 검토) | Sonnet 4.6 |
| ux-researcher (UX 검증) | Sonnet 4.6 |

---

## S4 → Trine Handoff (전환)

### 흐름

```
S4 Gate PASS
    ↓
Handoff 문서 자동 생성 (산출물 인덱스, 기술 스택, 세션 로드맵)
    ↓
개발 프로젝트에 symlink 생성 (SIGIL = Source of Truth)
    ↓
todo.md에 Spec 칸반 행 추가
    ↓
Human이 개발 프로젝트로 이동 → Trine 자동 발동 (.specify/ 감지)
```

### 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| **Notion** | MCP | Trine 세션 태스크 Notion DB 등록 (Tier 1) |
| `sigil-workspace.json` | 설정 파일 | 경로 해석, 프로젝트 매핑, symlink 대상 |
| `ln -s` | CLI | 개발 프로젝트에 SIGIL 산출물 symlink 생성 |

---

## 리소스 파이프라인 (Diamond Architecture)

> S3/S4의 시각 자료 및 게임/웹 에셋 생성 시 적용되는 하위 파이프라인.

### 5단계 흐름

```
P0 (수렴): 스타일 정의 → style-guide.md 생성
    ↓
P1 (수렴): 방향 설정 → Art Direction Brief 확정
    ↓
P2 (확산): 프로토타입 → 3-5개 시험 생성 → Human 피드백
    ↓
P3 (확산): 대량 생산 → 승인 스타일로 전체 에셋 생성
    ↓
P4 (수렴): 품질 검증 → 일관성 + 크리틱 루프 → 최종 확정
```

### 단계별 도구

| 단계 | 도구 | 유형 | 용도 |
|:----:|------|:----:|------|
| **P0** | `/style-train` | 스킬 | 기존 에셋에서 스타일 추출 → style-guide.md |
| **P0** | **Replicate** | MCP | LoRA 학습 오케스트레이션 (스타일 모델 학습) |
| **P0** | `/screenshot-analyze` | 스킬 (CLI) | 기존 에셋 컬러/스타일 분석 |
| **P1** | Art Direction Brief | 템플릿 | 감성 키워드, 안티패턴, 무드보드 정의 |
| **P2** | **NanoBanana** | MCP | 2D 이미지 시험 생성 (Gemini AI) |
| **P2** | **Ludo.ai** | MCP | 스프라이트/3D/사운드 시험 생성 |
| **P2** | **Replicate** | MCP | LoRA 모델 기반 시험 생성 |
| **P3** | `/game-asset-generate` | 스킬 | 에셋 유형별 MCP 도구 라우팅 오케스트레이터 |
| **P3** | **NanoBanana** | MCP | 2D 이미지 대량 생성 (배경, UI, 아이콘) |
| **P3** | **Ludo.ai** | MCP | 스프라이트 애니메이션 (`animateSprite`), 3D 모델 (`create3DModel`), 사운드 (`createSoundEffect`, `createMusic`), 모션 (`transferMotion`) |
| **P3** | **Replicate** | MCP | LoRA 모델 기반 일관된 스타일 대량 생성 |
| **P4** | `/screenshot-analyze` | 스킬 (CLI) | 크로스 에셋 일관성 검증 |
| **P4** | `resource-manifest.md` | 문서 | 에셋 인벤토리 관리 |

### 3-Tier 에셋 분류

| Tier | 분류 | 생성 방식 |
|:----:|------|----------|
| T1 | 핵심 브랜딩 (로고, 메인 캐릭터) | Human 디자인 또는 Human 밀착 감독 |
| T2 | 주요 에셋 (UI, 배경, 아이콘) | AI 생성 + Human 승인 (1장씩 순차) |
| T3 | 대량 에셋 (필러, 패턴, 변형) | AI 배치 생성 + 샘플링 검증 |

### MCP 폴백 체인

| 1차 도구 | 폴백 | 비고 |
|---------|------|------|
| Replicate (LoRA) | NanoBanana MCP | 85% 일관성 허용 |
| Ludo.ai (스프라이트) | NanoBanana + 수동 슬라이싱 | 시트 분리 필요 |
| Ludo.ai (3D) | Asset Store 구매 대체 | 3D는 구매 |
| Stitch MCP | NanoBanana + 수동 목업 | 목업 기능 축소 |

---

## 전체 도구 인벤토리 (MCP/CLI/스킬/에이전트)

### MCP 서버

| MCP 서버 | 사용 Stage | 핵심 용도 |
|---------|-----------|----------|
| **Brave Search** | S1, S2 | 실시간 웹 검색 (시장 데이터, 뉴스) |
| **Sequential Thinking** | S1, S2 | 복잡한 전략/리서치 구조화 |
| **Notion** | S1~Handoff | 산출물 DB 등록, 태스크 관리, 리포트 업로드 |
| **Stitch** | S2, S3, S4 | AI UI 목업 생성 + 변형 비교 |
| **NanoBanana** | S3, S4, P2, P3 | AI 이미지 생성/편집 (Gemini) |
| **Draw.io** | S3, S4 | 복잡한 아키텍처/C4/상태도 다이어그램 (15+ 노드) |
| **Replicate** | P0, P2, P3 | LoRA 학습 + 일관된 스타일 이미지 생성 |
| **Ludo.ai** | P2, P3 | 스프라이트/3D/사운드/음악 생성 (게임 에셋) |
| **Lighthouse** | (Trine 연계) | 웹 성능/접근성/SEO 감사 |
| **Sentry** | (Trine 연계) | 프로덕션 에러 추적 |
| **Context7** | S1 | 기술 문서/라이브러리 최신 정보 |

### CLI 도구

| CLI 도구 | 사용 Stage | 핵심 용도 |
|---------|-----------|----------|
| `analyze-screenshot.sh` | S1, S3, S4, P0, P4 | Gemini Vision 이미지 분석 |
| `analyze-video.sh` | S3, S4 | Gemini 영상 프레임 분석 |
| `sigil-gate-check.sh` | S4 Gate | DoD 자동 검증 스크립트 |
| `ln -s` | Handoff | symlink 생성 |
| Mermaid | S3, S4 | 마크다운 인라인 다이어그램 (≤15 노드) |

### 스킬

| 스킬 | 사용 Stage | 핵심 용도 |
|------|-----------|----------|
| `/research` | S1 | 리서치 파이프라인 시작 |
| `/lean-canvas` | S2 | 린 캔버스 작성 |
| `/prd` | S3 | PRD 작성 (앱/웹) |
| `/gdd` | S3 | GDD 작성 (게임) |
| `/pptx` | S3 | .md → .pptx 변환 |
| `/screenshot-analyze` | S1, S3, S4, P0, P4 | 스크린샷 분석 (경쟁사, 구현 검증) |
| `/game-logic-visualize` | S3, S4 | FSM/확률/경제 시각화 + 시뮬레이터 |
| `/game-reference-collect` | S1, S3 | 경쟁작 레퍼런스 통합 수집 |
| `/video-reference-guide` | S3, S4 | 게임 연출 영상 분석 → 구현 가이드 |
| `/style-train` | P0 | 스타일 추출 + LoRA 학습 오케스트레이션 |
| `/game-asset-generate` | P3 | 에셋 유형별 MCP 도구 라우팅 |
| `sigil-router` | 진입 | 비개발 업무 → SIGIL 파이프라인 라우팅 |

### 에이전트

| 에이전트 | 사용 Stage | 모델 | 핵심 역할 |
|---------|-----------|------|----------|
| `pipeline-orchestrator` | 전체 | Opus 4.6 | 파이프라인 조율, 게이트 관리, 회의 심판 |
| `research-coordinator` | S1 | Opus 4.6 | 리서치 Fan-out 병렬 조율 |
| `gdd-writer` | S3 | Sonnet 4.6 | GDD 전문 작성 (게임) |
| `technical-writer` | S4 W1, W4 | Sonnet 4.6 | 3대 산출물 작성 |
| `cto-advisor` | S4 W3 | Sonnet 4.6 | 기술 검토 (아키텍처, ADR) |
| `ux-researcher` | S4 W3 | Sonnet 4.6 | UX 검증 (와이어프레임, 인터랙션) |
| `academic-researcher` | S1 | Haiku 4.5 | 학술 논문/소스 조사 |
| `fact-checker` | S1, S2 | Haiku 4.5 | 수치/출처 교차 검증 |
| `spec-writer` | S4→Trine | Sonnet 4.6 | Spec 문서 작성 |
| `trine-pm-updater` | Handoff | Haiku 4.5 | PM 문서 자동 갱신 |

### Playground 템플릿 (선택적)

| 템플릿 | 사용 Stage | 용도 |
|--------|-----------|------|
| `concept-map` | S1, S2 | 시장 구조, 컨셉 관계도 시각 탐색 |
| `data-explorer` | S1 | TAM/SAM/SOM 수치 시각 탐색 |
| `design-playground` | S3, S4 | UI 레이아웃, 디자인 토큰 탐색 |
| `code-map` | S4 | 아키텍처 시각화, 모듈 관계도 |
| `document-critique` | 모든 Gate | 구조화된 문서 리뷰 |

---

## 모델 계층화 요약

| 계층 | 모델 | 역할 | 비용 |
|------|------|------|:----:|
| **Lead** | Opus 4.6 | 판단, 종합, 오케스트레이션, 회의 심판 | 높음 |
| **작성/분석** | Sonnet 4.6 | 문서 작성, 기획, 기술 분석, 코드 작성 | 중간 |
| **탐색/검색** | Haiku 4.5 | 검색, 팩트체크, 트렌드 수집, 파일 조사 | 낮음 |

---

## 게이트 유형 요약

| Stage | 게이트 | 동작 |
|:-----:|:------:|------|
| S1 | **[AUTO-PASS]** | AI DoD 자동 검증 → 알림 출력 → 자동 진행 |
| S2 | **[STOP]** | AI 검증 → 파이프라인 중단 → Human 승인 대기 |
| S3 | **[STOP]** | AI 검증 → 파이프라인 중단 → Human 승인 대기 |
| S4 | **[AUTO-PASS]** | Wave 2+3 자동 검증 → 알림 출력 → Trine 진입 |

> [AUTO-PASS]에서도 Human은 언제든 "잠깐, 다시 봐줘"로 소급 개입 가능.
> 자동 검증 FAIL 시 → [STOP]으로 에스컬레이션.

---

*Last Updated: 2026-03-17*
*Source: sigil-compiled.md, business-core.md, trine-handoff.md*
