# SIGIL 파이프라인 워크플로우

> **SIGIL (Strategy & Idea Generation Intelligent Loop)**
> 마법 인장(印章) — 프로젝트에 생명을 불어넣는 설계 문양.
> 각 Stage가 인장의 한 획. 완성된 Sigil이 Trine에 전달되면 프로젝트가 "소환"된다.
> **운영 모델**: AI가 현재 Stage를 인지하고 완료 시 다음 Stage로 이동을 제안한다. Human이 [STOP] 게이트에서 승인한다.

## 파이프라인 구조

```
S1 Research → S2 Concept → S3 Design Document → S4 Planning Package → Trine
     ↓              ↓               ↓                      ↓
[AUTO-PASS]      [STOP]          [STOP]             [AUTO-PASS] → Trine 진입
```

### 진입 경로 (4가지)

| 시나리오 | 시작 Stage | 필요 입력 | 스킵 |
|---------|:---------:|----------|------|
| 아이디어만 있음 | S1 | 아이디어 한 줄 | 없음 |
| 자료/리서치 있음 | S2 | 기존 리서치 문서 | S1 스킵 |
| 컨셉 확정됨 | S3 | 컨셉 문서 or Lean Canvas | S1+S2 스킵 |
| 기획서 있음 | S4 | PRD/GDD 문서 | S1+S2+S3 스킵 |

> **Soft 의존성** (스킵 가능): S1→S2, S2→S3
> **Hard 의존성** (반드시 순서 유지): S3→S4, S4→Trine

### 모델 계층화

```
pipeline-orchestrator (Lead)       → Opus 4.6   (판단, 종합, 게이트 심판)
기획서 작성 (gdd/prd)               → Sonnet 4.6 (문서 작성, 분석)
기획 패키지 (technical-writer)      → Sonnet 4.6 (S4 산출물 작성)
리서치/검색 Teammates               → Haiku 4.5  (검색, 팩트체크, 트렌드 수집)
```

---

## S1. Research (리서치)

> S1 완료 기준: TAM/SAM/SOM 포함 시장 조사 + 경쟁사 5개사 이상 + 신뢰도 등급 표기
> 방법론: AI-augmented Research + JTBD + Competitive Intelligence + Evidence-Based Management

1. 프로젝트 유형 식별 (앱/웹/게임)
2. `sigil-workspace.json`에서 폴더 경로 확인 (`folderMap` 기준)
3. **research-coordinator** Subagent 스폰 (Fan-out 병렬):
   - market-researcher, academic-researcher, fact-checker 3명 동시 투입
   - 시장 규모(TAM/SAM/SOM), 경쟁사 분석, 기술 트렌드 독립 조사
   - 결과 병합 + 신뢰도 등급(High/Medium/Low) 표기
4. 산출물 저장: `{folderMap.research}/projects/{project}/YYYY-MM-DD-s1-{topic}.md`
5. gate-log.md 업데이트

### S1 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| Brave Search | MCP | 실시간 웹 검색 (시장 데이터, 뉴스) |
| WebSearch / WebFetch | 내장 | 웹 검색/콘텐츠 수집 |
| Context7 | MCP Plugin | 기술 문서/라이브러리 최신 정보 |
| Sequential Thinking | MCP | 리서치 전략 구조화 |
| Notion | MCP | 리서치 결과 DB 등록 |
| `/screenshot-analyze` | 스킬 (CLI) | 경쟁사 스크린샷 분석 |
| `/game-reference-collect` | 스킬 | 경쟁작 레퍼런스 수집 (게임) |

   ─── [AUTO-PASS] S1 Gate: DoD 자동 검증 → 알림 후 자동 진행 ───

---

## S2. Concept (컨셉 확정)

> 방법론: Pretotyping + Mom Test + Lean Validation + TAM/SAM/SOM + OKR

1. `/lean-canvas` 스킬로 Lean Canvas 작성 (9블록 완성)
2. TAM/SAM/SOM 자동 추정 — TAM < $1M 시 Kill 신호
3. **Go/No-Go 스코어링** (4영역 가중 평가):

   | 영역 | 가중치 | Kill Criteria |
   |------|:-----:|---------------|
   | 시장 기회 | 30% | TAM < $1M |
   | 기술 실현성 | 25% | 핵심 기술 불가 |
   | 비즈니스 모델 | 25% | 수익화 경로 없음 |
   | 위험 관리 | 20% | 규제 장벽 |

   - **80점+** = Go → S3 진행
   - **60-79점** = 조건부 → 보완 후 재평가
   - **60점 미만** = No-Go → 피벗 또는 중단

4. **기획 디렉션 5축** 수립:

   | # | 축 | 형식 요건 | PASS/FAIL |
   |:-:|---|---------|:---------:|
   | 1 | **전략 방향** | "A > B" 또는 "A, not B" 형식 필수 (트레이드오프) | ">" 또는 "not" 포함 |
   | 2 | **경험 원칙** | 측정 가능한 수치/시간/횟수 포함 필수 | 숫자 포함 |
   | 3 | **범위 경계** | Do 2개+ / Don't 2개+ (Don't는 `태그` 형식) | 최소 수량 |
   | 4 | **품질 기준** | 측정 가능한 NFR 값 포함 | 값 포함 |
   | 5 | **벤치마크** | 레퍼런스 1-3개 + 참조 이유 | 존재 |

   - AI가 축당 2-3개 후보 제시 → Human이 S2 [STOP]에서 최종 확정
   - **Iron Law**: Axis 1(전략 방향)과 Axis 3(범위 경계)은 Human 확인 없이 확정 불가

5. **Pretotyping** (3경로 중 선택):

   | 경로 | 방법 | 소요 | 도구 | 적합 상황 |
   |------|------|:----:|------|----------|
   | A | 클릭 가능 프로토타입 | 1-2h | Replit Agent (외부) | UI/UX 검증 핵심 |
   | B | AI UI 목업 스크린샷 | 30min | **Stitch MCP** | 빠른 시각 검증 |
   | C | 문서 Pretotype (Landing/PR/FAQ) | 1h | Markdown 직접 | 콘텐츠/가격 검증 |

6. OKR 정의 (S3 기획서 측정 기준으로 연결)
7. 산출물 저장: `{folderMap.product}/{project}/YYYY-MM-DD-s2-concept.md`
8. gate-log.md 업데이트

### S2 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| Brave Search | MCP | TAM/SAM/SOM 시장 수치 검색 |
| Stitch | MCP | Pretotyping 경로 B — AI UI 목업 |
| Sequential Thinking | MCP | Go/No-Go 전략 구조화 |
| Notion | MCP | 컨셉 문서 DB 등록 |
| `concept-map` | Playground (선택) | 컨셉 관계도, 핵심 가치 맵핑 |

   ─── **[STOP]** S2 Gate: 비전/타겟/차별점 + 기획 디렉션 5축 Human 승인 ───

---

## S3. Design Document (기획서)

> **에이전트 회의 필수**: 기획 에이전트 2~3명 독립 초안 → Competing Hypotheses → 최적안 선택/병합
> **PPT 변환 필수**: .md 완성 후 `/pptx` 스킬로 .pptx 생성

### 프로젝트 유형별 산출물

| 유형 | 에이전트/스킬 | 산출물 |
|------|-------------|--------|
| 앱/웹 | `/prd` 커맨드 | PRD (.md + .pptx 필수) |
| 게임 | `gdd-writer` 에이전트 | GDD (.md + .pptx 필수) |

### 에이전트 회의 흐름 (디렉션 탈락 필터 포함)

```
S2 디렉션 5축 요약 프롬프트 주입 (~5줄)
    ↓
에이전트 A/B/C 자유 초안 작성
    ↓
디렉션 탈락 필터 (Don't 태그 매칭)
  ├─ Don't 위반 없음 → 비교 대상 유지
  └─ Don't 위반 발견 → 해당 초안 탈락 (비교에서 제외)
    ↓
생존 초안만 기존 기준으로 비교 (아키텍처, 성능, UX)
    ↓
최적안 선택/병합 → Human 승인
```

### 진행 흐름

1. S2 디렉션 5축 요약을 에이전트 프롬프트에 인라인 주입
2. 에이전트 2~3명 병렬 스폰 → 독립 기획서 초안 작성
3. **디렉션 탈락 필터**: Don't 태그 위반 초안 → 비교에서 제외
4. Competing Hypotheses: 생존 초안 비교표 + 선택 근거 작성
5. 최적안 선택/병합 → 완성 기획서 작성
6. 시각 자료 포함 필수:
   - .md: Mermaid 다이어그램, 비교 테이블, Stitch UI 목업
   - .pptx: NanoBanana 배경/일러스트, BAR/PIE/LINE 차트, 플로우 다이어그램
7. **도메인 용어 정의(Glossary)** 섹션 필수 포함 — 한국어↔영어↔정의↔관계 4열 테이블
8. 관리자 기능 포함 여부 확인 → 포함 시 관리자 기획서도 동등 작성
9. `/pptx` 스킬로 .pptx 변환 (PPT 단계적 생성: 시안 5-7슬라이드 → Human 확인 → 전체 확장)
10. 산출물 저장 + gate-log.md 업데이트

### 프로젝트 유형별 필수 시각 자료

| 시각 자료 | 게임 | 웹/앱 | 도구 |
|----------|:----:|:----:|------|
| UI 목업 | 필수 | 필수 | **Stitch MCP** |
| 컨셉 일러스트 | 필수 | 권장 | **NanoBanana MCP** |
| 플로우 다이어그램 | 필수 | 필수 | Mermaid / **Draw.io MCP** |
| 경쟁사 UI 분석 | 필수 | 필수 | `/screenshot-analyze` (CLI) |
| 이펙트/연출 레퍼런스 | 필수 | 선택 | `/video-reference-guide` (CLI) |
| FSM/로직 시각화 | 필수 | 선택 | `/game-logic-visualize` |
| 반응형 레이아웃 | N/A | 필수(Large) | Stitch `generate_variants` |

### S3 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| NanoBanana | MCP | 컨셉 일러스트, PPT 배경, 캐릭터 AI 생성 |
| Stitch | MCP | 핵심 화면 UI 목업 + 변형 비교 |
| Draw.io | MCP | 복잡한 아키텍처/상태도 (15+ 노드), C4 |
| Notion | MCP | 기획서/회의 결과 등록 |
| `/pptx` | 스킬 | .md → .pptx 변환 |
| `/screenshot-analyze` | 스킬 (CLI) | 경쟁사 UI 분석 (Gemini Vision) |
| `/game-logic-visualize` | 스킬 | FSM/확률/경제 시각화 (게임) |
| `/game-reference-collect` | 스킬 | 경쟁작 레퍼런스 수집 (게임) |
| `/video-reference-guide` | 스킬 (CLI) | 게임 연출 영상 분석 (Gemini) |
| `analyze-screenshot.sh` | CLI | Gemini Vision 이미지 분석 |
| `analyze-video.sh` | CLI | Gemini 영상 프레임 분석 |
| Mermaid | 인라인 | 간단한 플로우/시퀀스 (≤15 노드) |

   ─── **[STOP]** S3 Gate: 기획서(.md + .pptx) Human 승인 ───

---

## S4. Planning Package (기획 패키지)

> S4 완료 시 → Handoff 문서 자동 생성 → 개발 프로젝트 symlink 생성 → Trine 진입 안내
> 방법론: Now/Next/Later + RICE/ICE + C4 Model + ADR + 테스트 전략

### 필수 산출물 3종

| # | 산출물 | 파일명 | 내용 |
|:-:|--------|--------|------|
| 1 | **상세 기획서** | s4-detailed-plan.md | 화면별 동작 + 데이터 흐름 + 사이트맵 |
| 2 | **개발 계획** | s4-development-plan.md | 기술 스택 + 아키텍처(C4) + ADR + Trine 세션 로드맵 + 로드맵 + WBS + **테스트 전략** |
| 3 | **UI/UX 기획서** | s4-uiux-spec.md | 와이어프레임 + 컴포넌트 스펙 + 인터랙션 패턴 |

> S3에 관리자 기능 포함 시: `s4-admin-detailed-plan.md`, `s4-admin-uiux-spec.md` 추가 필수

### Spec 크기 가드레일 5원칙 (세션 로드맵 작성 시)

| # | 원칙 | 기준 | 위반 시 |
|:-:|------|------|---------|
| 1 | 1 Spec = 1 Feature | 하나의 사용자 가치 단위 | 분리 권고 |
| 2 | Spec 크기 상한 | 700-900줄 적정, 1,200줄 경고, 1,500줄+ 분리 필수 | [STOP] 분리 |
| 3 | SP 상한 | 5-8 SP 적정, 10 SP 경고, 12+ 분리 필수 | [STOP] 분리 |
| 4 | 세션-Spec 명시 | "Session N — Spec M: [제목] (N SP)" 형식 필수 | S4 Gate FAIL |
| 5 | 번들링 정당화 | 2개 기능 번들 시 분리 불가 사유 명시 | Spec 리뷰 시 확인 |

### Wave 프로토콜

```
Wave 1 (순차): technical-writer → 3종 산출물 초안 작성
  - S3 시각 자료 재활용 정책 적용 (신규 생성 최소화)
  - MCP 도구 (Stitch, NanoBanana, Draw.io) technical-writer가 직접 호출

Wave 2A (트레이서빌리티 검증):
  - S3 FR/NFR 목록 추출 → S4 산출물 반영 체크 → 누락 항목 보완

Wave 2B (디렉션 일관성 검증 — Lead 또는 cto-advisor, self-review 불허):
  - S2 디렉션 5축과 S4 산출물의 일관성 검증
  - 전략 방향 정렬: 세션 로드맵 우선순위가 S2 전략과 일치 (WARN)
  - 범위 경계 준수: Don't 태그 항목 미포함 확인 (CRITICAL — AUTO-PASS 차단)
  - 품질 기준 반영: 테스트 전략이 S2 NFR 반영 (WARN)
  - CRITICAL 발견 → [STOP] Human 에스컬레이션

Wave 3 (병렬):
  - cto-advisor    → 개발 계획 기술 검토 (아키텍처, ADR)
  - ux-researcher  → UI/UX 기획서 UX 검증 (와이어프레임, 인터랙션)

Wave 4 (최종): technical-writer → Wave 2-3 리뷰 반영 최종본
```

### AUTO-PASS 조건 (모두 충족 시 자동 진행)

1. `sigil-gate-check.sh S4` → PASS (8개 DoD 항목)
2. Wave 2A: 누락 FR/NFR 0건
3. Wave 2B: CRITICAL 이슈 0건 (Don't 태그 위반 없음)
4. Wave 3: CRITICAL 이슈 0건

하나라도 FAIL → [STOP]으로 에스컬레이션.

### S4 사용 도구

| 도구 | 유형 | 용도 | Wave |
|------|:----:|------|:----:|
| Stitch | MCP | 상세 화면 목업, 반응형 변형 | W1 |
| NanoBanana | MCP | 히어로 이미지, 컨셉 일러스트 | W1 |
| Draw.io | MCP | C4 아키텍처, 복잡한 플로우 (15+ 노드) | W1 |
| Notion | MCP | S4 산출물 + Gate 결과 등록 | W4 |
| `/screenshot-analyze` | 스킬 (CLI) | 경쟁사 UI 비교 | W1 |
| `/game-logic-visualize` | 스킬 | FSM/확률/경제 상세화 (게임) | W1 |
| `sigil-gate-check.sh` | CLI | S4 DoD 자동 검증 | Gate |
| Mermaid | 인라인 | 간단한 플로우/시퀀스 | W1 |

   ─── [AUTO-PASS] S4 Gate: Wave 검증 자동 통과 시 → Trine 진입 준비 ───
   ─── AUTO-PASS 실패 시 [STOP]으로 에스컬레이션 ───

---

## S4 완료 → Trine 진입

1. **Handoff 문서 자동 생성**:
   - 경로: `{folderMap.handoff}/{project}/YYYY-MM-DD-sigil-handoff.md`
   - 내용: 산출물 인덱스, 기술 스택, Trine 세션 로드맵, ADR 요약
2. **symlink 일괄 생성** (`sigil-workspace.json`의 `devTarget` + `symlinkBase` 기준):
   - 개발 프로젝트의 `docs/planning/active/sigil/{domain}/` 에 S3/S4 산출물 symlink
   - `todo.md`는 실제 파일로 생성 (symlink 아님 — GitHub Actions 호환 필수)
3. **Tier 2 Todo 자동 생성** (Notion MCP 미연결 시):
   - `{folderMap.product}/todo.md`에 Spec 칸반 행 추가
4. Human에게 Trine 진입 안내 메시지 제공

### SIGIL 산출물 → Trine 매핑

| SIGIL 산출물 | Trine 활용 시점 |
|-------------|----------------|
| S1 리서치 | Phase 1 — 프로젝트 컨텍스트 |
| S3 PRD/GDD | Phase 1.5 — FR/NFR 추출 + Phase 2 Spec 입력 |
| S4 상세 기획서 | Phase 2 — 화면별 동작, 데이터 흐름, 사이트맵 참조 |
| S4 개발 계획 | Phase 1 — 기술 스택, ADR, 세션 로드맵 + Phase 3 테스트 전략 |
| S4 UI/UX 기획서 | Phase 2 — Spec UI 섹션 참조 |

---

## 리소스 파이프라인 (Diamond Architecture)

S3/S4 시각 자료 및 게임/웹 에셋 생성 시 적용:

```
P0 (수렴): 스타일 정의 → style-guide.md       도구: /style-train (Replicate LoRA)
P1 (수렴): 방향 설정 → Art Direction Brief     도구: 수동 작성
P2 (확산): 프로토타입 → 3-5개 시험 생성        도구: NanoBanana / Ludo.ai / Replicate
P3 (확산): 대량 생산 → 전체 에셋 생성          도구: /game-asset-generate (라우팅)
P4 (수렴): 품질 검증 → 일관성 + 크리틱 루프    도구: /screenshot-analyze
```

### MCP 폴백 체인

| 1차 도구 | 폴백 |
|---------|------|
| Replicate (LoRA) | NanoBanana MCP |
| Ludo.ai (스프라이트) | NanoBanana + 수동 슬라이싱 |
| Ludo.ai (3D) | Asset Store 구매 |
| Stitch MCP | NanoBanana + 수동 목업 |

---

## 게이트 로그 형식 (gate-log.md)

```markdown
## Gate Log — {프로젝트명}

| Stage | 결과 | 일자 | 조건 | 비고 |
|:-----:|:----:|------|------|------|
| S1 | ✅ AUTO | YYYY-MM-DD | DoD 자동 검증 통과 | 신뢰도 High 72% |
| S2 | ✅ PASS | YYYY-MM-DD | Go/No-Go 85점 | 5축 v1 확정 |
| S3 | — | — | — | |
| S4 | — | — | — | |
```

---

## 산출물 저장 경로 요약

| 유형 | 경로 |
|------|------|
| 리서치 | `{folderMap.research}/projects/{project}/YYYY-MM-DD-s1-{topic}.md` |
| 컨셉 | `{folderMap.product}/{project}/YYYY-MM-DD-s2-concept.md` |
| PRD/GDD | `{folderMap.product}/{project}/YYYY-MM-DD-s3-prd.md` + `.pptx` |
| 상세 기획서 | `{folderMap.product}/{project}/YYYY-MM-DD-s4-detailed-plan.md` |
| 개발 계획 | `{folderMap.product}/{project}/YYYY-MM-DD-s4-development-plan.md` |
| UI/UX 기획서 | `{folderMap.design}/{project}/YYYY-MM-DD-s4-uiux-spec.md` |
| Handoff 문서 | `{folderMap.handoff}/{project}/YYYY-MM-DD-sigil-handoff.md` |
| 게이트 로그 | `{folderMap.product}/{project}/gate-log.md` |

> 모든 경로는 `sigil-workspace.json`의 `folderMap`에서 해석한다. 파일 없으면 [STOP].

---

## AI 행동 규칙

1. 파이프라인 시작 시 `sigil-workspace.json` 먼저 읽고 경로 해석
2. 진입 경로 판단 → 기존 자료에 따른 Stage 스킵 제안
3. 각 Stage 산출물은 해당 폴더의 `projects/{project}/` 하위에 저장 (파일명에서 프로젝트명 제거)
4. [AUTO-PASS] 게이트: 자동 검증 후 알림 + 자동 진행 (Human 소급 개입 가능)
5. [STOP] 게이트: Human 승인 없이 다음 Stage 진행 금지
6. S2에서 기획 디렉션 5축 수립 + Axis 1/3은 Human 확인 없이 확정 금지
7. S3 에이전트 프롬프트에 S2 디렉션 5축 요약 주입 + Don't 태그 탈락 필터 실행
8. S3 기획서는 .md + .pptx 모두 생성
9. S3에 관리자 기능 포함 시 S4 모든 산출물에 관리자 버전 추가
10. S4 Wave 2B 디렉션 일관성 검증에서 CRITICAL 발견 시 [STOP]
11. S4 세션 로드맵은 Spec 크기 가드레일 5원칙 적용
12. S4 완료 후 Handoff 문서 자동 생성 + symlink 일괄 생성
13. gate-log.md를 각 게이트 통과 시 반드시 업데이트
