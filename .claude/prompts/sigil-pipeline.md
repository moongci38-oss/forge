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

4. OKR 정의 (S3 기획서 측정 기준으로 연결)
5. 산출물 저장: `{folderMap.product}/{project}/YYYY-MM-DD-s2-concept.md`
6. gate-log.md 업데이트

   ─── **[STOP]** S2 Gate: 비전/타겟/차별점 Human 승인 ───

---

## S3. Design Document (기획서)

> **에이전트 회의 필수**: 기획 에이전트 2~3명 독립 초안 → Competing Hypotheses → 최적안 선택/병합
> **PPT 변환 필수**: .md 완성 후 `/pptx` 스킬로 .pptx 생성

### 프로젝트 유형별 산출물

| 유형 | 에이전트/스킬 | 산출물 |
|------|-------------|--------|
| 앱/웹 | `/prd` 커맨드 | PRD (.md + .pptx 필수) |
| 게임 | `gdd-writer` 에이전트 | GDD (.md + .pptx 필수) |

### 진행 흐름

1. 에이전트 2~3명 병렬 스폰 → 독립 기획서 초안 작성
2. Competing Hypotheses: 비교표 + 선택 근거 작성
3. 최적안 선택/병합 → 완성 기획서 작성
4. 시각 자료 포함 필수:
   - .md: Mermaid 다이어그램, 비교 테이블, Stitch UI 목업
   - .pptx: NanoBanana 배경/일러스트, BAR/PIE/LINE 차트, 플로우 다이어그램
5. **도메인 용어 정의(Glossary)** 섹션 필수 포함 — 한국어↔영어↔정의↔관계 4열 테이블
6. 관리자 기능 포함 여부 확인 → 포함 시 관리자 기획서도 동등 작성
7. `/pptx` 스킬로 .pptx 변환
8. 산출물 저장:
   - `{folderMap.product}/{project}/YYYY-MM-DD-s3-prd.md` (또는 gdd.md)
   - `{folderMap.product}/{project}/YYYY-MM-DD-s3-prd.pptx`
9. gate-log.md 업데이트

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

### Wave 프로토콜

```
Wave 1 (순차): technical-writer → 3종 산출물 초안 작성
Wave 2 (검증): S3 FR/NFR 목록 추출 → S4 산출물 반영 여부 체크 → 누락 항목 보완
Wave 3 (병렬):
  - cto-advisor    → 개발 계획 기술 검토 (아키텍처, ADR)
  - ux-researcher  → UI/UX 기획서 UX 검증 (와이어프레임, 인터랙션)
Wave 4 (최종): technical-writer → Wave 2-3 리뷰 반영 최종본
```

### 진행 흐름

1. Wave 1: `technical-writer` (Sonnet) — 3종 초안 작성
2. Wave 2: S3 기획서 FR/NFR 전수 체크 → 누락 항목 Wave 1 에이전트에 보완 요청
3. Wave 3: `cto-advisor` + `ux-researcher` 병렬 검토
4. Wave 4: `technical-writer` 최종본 확정
5. `sigil-gate-check.sh S4` 자동 검증 (8개 DoD 항목)
6. 산출물 저장: `{folderMap.product}/{project}/`, `{folderMap.design}/{project}/`
7. gate-log.md 업데이트

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

---

## 게이트 로그 형식 (gate-log.md)

```markdown
## Gate Log — {프로젝트명}

| Stage | 결과 | 일자 | 조건 | 비고 |
|:-----:|:----:|------|------|------|
| S1 | ✅ AUTO | YYYY-MM-DD | DoD 자동 검증 통과 | 신뢰도 High 72% |
| S2 | ✅ PASS | YYYY-MM-DD | Go/No-Go 85점 | |
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
6. 에이전트 회의 결과에 비교표 + 선택 근거 명시
7. 개발 트랙 S3: .md + .pptx 모두 생성
8. S3에 관리자 기능 포함 시 S4 모든 산출물에 관리자 버전 추가
9. S4 완료 후 Handoff 문서 자동 생성 + symlink 일괄 생성
10. gate-log.md를 각 게이트 통과 시 반드시 업데이트
