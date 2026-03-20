---
title: "S4 기획 패키지"
id: forge-s4-planning
impact: HIGH
scope: [forge]
tags: [pipeline, planning, s4, admin]
requires: [forge-structure, forge-s3-design]
section: forge-pipeline
audience: all
impactDescription: "필수 산출물 3종 미완료 시 Forge Dev 진입 불가. 관리자 산출물 누락 시 개발 단계에서 추가 기획 필요 → 일정 지연"
enforcement: rigid
---

# S4 기획 패키지

## S4. Planning Package

S3 기획서(PRD/GDD) 기반으로 Forge Dev 진입 전 종합 기획 문서를 작성한다.

| # | 산출물 | 파일명 | 내용 | Forge Dev 참조 |
|:-:|--------|--------|------|-----------|
| 1 | **상세 기획서** | s4-detailed-plan.md | 화면별 동작 + 데이터 흐름 + 사이트맵(페이지 계층/네비게이션) | Phase 2 Spec |
| 2 | **개발 계획** | s4-development-plan.md | 기술 스택 + 아키텍처 + ADR + 세션 로드맵 + 로드맵(Now/Next/Later) + WBS(태스크 분해/규모 추정) + **테스트 전략**(피라미드/커버리지 목표/도구/파일 구조) | Phase 1 컨텍스트 + Phase 3 Check |
| 3 | **UI/UX 기획서** | s4-uiux-spec.md | 와이어프레임 + 컴포넌트 스펙 + 인터랙션 패턴 + 디자인 가이드 | Phase 2 Spec UI |

> **흡수된 산출물**: 사이트맵 → 상세 기획서에 통합, 로드맵/WBS → 개발 계획에 통합, 테스트 전략서 → 개발 계획에 통합. S4 Gate 통과 시 todo.md 생성 후 `sync-notion-tasks.py register`로 Notion에 일괄 등록한다.
> **E2E 시나리오 상세**는 S4에서 제거 → Forge Dev Spec Section 10에서만 작성한다.

- **에이전트**: technical-writer (작성) + cto-advisor (기술 검토) + ux-researcher (UX 검증)
- **필수 방법론**: Now/Next/Later + RICE/ICE Scoring + C4 Model + ADR
- **시각화 도구** (선택적):
  - **Draw.io MCP** — C4 Model Level 1-4 시각화, 복잡한 아키텍처 다이어그램 (Mermaid 15+ 노드 초과 시)
- **플러그인 보강** (선택적):
  - `data:interactive-dashboard-builder` — 지표 대시보드 HTML 생성 시 활용

### 관리자 페이지 필수 포함 규칙

관리자 페이지는 서비스와 **동등 레벨**의 산출물이다. S3 기획서에 관리자 기능이 포함되면 S4에서 반드시 아래를 반영한다:

| 산출물 | 서비스 | 관리자 |
|--------|--------|--------|
| 상세 기획서 | s4-detailed-plan.md | s4-admin-detailed-plan.md |
| 개발 계획 (테스트 전략 포함) | s4-development-plan.md (통합 — 서비스+관리자 세션 포함) | |
| UI/UX 기획서 | s4-uiux-spec.md | s4-admin-uiux-spec.md |

**관리자 우선순위** (S2 컨셉 단계에서 결정):

| 유형 | 관리자 우선순위 | 예시 | 모바일 정책 |
|------|:-----------:|------|-----------|
| B2C 앱/게임 | 서비스 > 관리자 | 바둑이 게임, SNS 앱 | 운영툴 모바일 화면 필수 |
| B2B SaaS / 내부 도구 | **관리자 >= 서비스** | CMS, 대시보드, ERP | 관리자 Mobile-first 기본 |
| 플랫폼 (양면) | 관리자 = 서비스 | 마켓플레이스, 중개 플랫폼 | 관리자 Mobile-first 기본 |

> **모바일 정책**: 관리자/운영툴은 Mobile-first가 기본이다. Desktop-only 화면은 명시적으로 선언해야 한다.
> 게임 프로젝트(GodBlade 등)의 운영툴도 모바일 화면 기획 대상에 포함된다.

- **게이트**: **[AUTO-PASS]** Wave 2+3 자동 검증 + forge-gate-check.sh S4 → Forge Dev 진입

**AUTO-PASS 조건** (모두 충족 시):
1. `forge-gate-check.sh S4` → PASS (8개 DoD 항목)
2. Wave 2A 트레이서빌리티: 누락 FR/NFR 0건
3. Wave 2B 디렉션 일관성: CRITICAL 이슈 0건 (Don't 태그 위반 없음)
4. Wave 3: CRITICAL 이슈 0건

하나라도 FAIL → [STOP]으로 에스컬레이션.

### S3 시각 자료 재활용 정책

> S3에서 생성된 시각 자료(UI 목업, 컨셉 일러스트, FSM, 경쟁사 분석)은 S4에서 **재사용 우선**이다.
> 신규 생성이 필요한 경우(S4 전용 상세화, 반응형 추가 등)에만 도구를 호출한다.

| S3 시각 자료 | S4 처리 |
|------------|---------|
| Stitch 목업 | 재사용 또는 보강 (새 화면 추가만) |
| NanoBanana 일러스트 | 재사용 (동일 자료) |
| `/screenshot-analyze` 분석 결과 | 재사용 |
| FSM 다이어그램 | 재사용 또는 상세화 (새 시스템만) |

### S4 Wave Protocol

S4 기획 패키지를 4단계 Wave로 작성한다.

```
Wave 1 (순차): technical-writer → 3대 산출물 초안 작성
  - 관리자 포함 시 서비스 + 관리자 산출물 모두 작성
  - S3 시각 자료 재활용 정책 적용 (신규 생성 최소화)
  - MCP 도구(Stitch, NanoBanana, Draw.io) 호출 책임: technical-writer가 직접 호출

Wave 2A (Spec 검증 — 기존):
  - S3 기획서(PRD/GDD)의 기능/비기능 요구사항 목록 추출
  - S4 각 산출물에 해당 요구사항이 반영되었는지 체크리스트 검증
  - 누락 항목 식별 → Wave 1 에이전트에 보완 요청

Wave 2B (디렉션 일관성 검증 — 신규):
  - S2 기획 디렉션 5축과 S4 산출물의 일관성 검증
  - 전략 방향 정렬: 세션 로드맵 우선순위가 S2 전략 방향과 일치 (WARN)
  - 범위 경계 준수: S4 산출물에 S2 Don't 태그 항목 미포함 (**CRITICAL** — AUTO-PASS 차단)
  - 품질 기준 반영: 테스트 전략이 S2 NFR 원칙 반영 (WARN)
  - 검증 실패 → autoFix 불가 → [STOP] Human 에스컬레이션 + 불일치 목록 + 수정 옵션
  - 검증 주체: Lead 또는 cto-advisor (technical-writer self-review 불허)

Wave 3 (병렬):
  - cto-advisor → 기술 검토 (개발 계획, 아키텍처, ADR)
  - ux-researcher → UX 검증 (UI/UX 기획서, 와이어프레임)

Wave 4: technical-writer → Wave 2-3 리뷰 반영 최종본 작성
```

> Wave 2A는 "존재/누락"만 검증한다. Wave 2B는 "디렉션 일관성"을 검증한다. "품질"은 Wave 3에서 검증한다.

### S4 산출물 시각 자료 기준 (프로젝트 유형별)

S4 산출물에 포함해야 하는 시각 자료를 프로젝트 유형별로 명시한다.

| S4 산출물 | 게임 | 웹/앱 | 도구 |
|----------|------|-------|------|
| **상세 기획서** | FSM + UI 목업 + 플로우 다이어그램 | UI 목업 + 사이트맵 + 유저 플로우 | Stitch + `/game-logic-visualize` + Mermaid/Draw.io |
| **개발 계획** | C4 다이어그램 + 테스트 구조도 | C4 다이어그램 + 테스트 구조도 | Draw.io MCP |
| **UI/UX 기획서** | 전체 목업 + 레퍼런스 비교 + 인터랙션 시퀀스 | 전체 목업(Desktop+Mobile) + 경쟁사 UI 비교 + 인터랙션 패턴 | Stitch + `/screenshot-analyze` |

- 게임: `/game-logic-visualize`로 FSM/확률/경제 시각화, `/video-reference-guide`로 연출 레퍼런스
- 웹/앱: Stitch MCP로 반응형 목업(Desktop+Mobile), `/screenshot-analyze`로 경쟁사 UI 분석
- 공통: Draw.io MCP로 C4 아키텍처, NanoBanana로 컨셉 일러스트/히어로 이미지

## Do

- S3 기획서에 관리자 기능이 포함되면 S4 모든 산출물에 관리자 섹션을 반영한다
- S4 완료 후 Forge Dev Handoff 문서를 자동 생성하고 진입을 안내한다
- 필수 산출물 3종을 모두 작성한다
- 프로젝트 유형(게임/웹/앱)에 따라 S4 산출물별 시각 자료 기준을 충족한다

## Don't

- S3에 관리자 기능이 포함되었는데 S4에서 관리자 산출물을 누락하지 않는다
- 필수 산출물 3종 중 하나라도 빠진 상태로 게이트를 통과하지 않는다
- 관리자/운영툴의 모바일 화면 기획을 생략하지 않는다 (Desktop-only는 명시 선언 필요)
- 시각 자료 없이 S4 산출물을 텍스트만으로 완성하지 않는다 (유형별 시각 기준 준수)

## AI 행동 규칙

1. S3 기획서에 관리자 기능이 포함되면 S4 모든 산출물에 관리자 섹션을 반영한다
2. S4 완료 후 Forge Dev Handoff 문서를 자동 생성하고 진입을 안내한다
3. 각 Stage 산출물은 해당 폴더의 `projects/{project}/` 하위에 저장한다
4. 프로젝트 폴더 내 파일명에서 프로젝트명을 제거한다 (폴더가 이미 프로젝트를 나타냄)
5. **S4 Gate 통과 시 Tier 2 Todo Tracker를 자동 생성한다** (아래 참조)
6. 프로젝트 유형별 S4 산출물 시각 자료 기준을 Wave 1에서 적용한다 (게임: FSM+목업, 웹/앱: 반응형 목업+경쟁사 분석)
7. S4 시작 전 `forge-workspace.json`의 `projectScale` 필드를 확인한다. 미설정 시 `Small`을 기본값으로 적용한다. `projectType`(game/web)과 `projectScale`(Small/Large)은 독립 필드이며 둘 다 확인한다
8. 세션 로드맵 작성 시 **Spec 크기 가드레일 5원칙**을 적용한다. "Session N — Spec M: [제목] (N SP)" 형식으로 세션-Spec 매핑을 명시한다
9. 2개 기능을 1 Spec에 번들링할 때 분리 불가 사유를 세션 로드맵에 명시한다. SP 상한(10 SP)과 크기 상한(1,200줄) 초과 시 분리 필수
10. Wave 2B 디렉션 일관성 검증에서 CRITICAL (Don't 태그 위반) 발견 시 즉시 [STOP] Human 에스컬레이션한다
11. Wave 2B 검증은 technical-writer가 아닌 Lead 또는 cto-advisor가 수행한다 (self-review 불허)

## Tier 2 Todo 자동 생성 (S4 Gate 통과 시)

S4 Gate 통과 시 `{folderMap.product}/todo.md`에 해당 프로젝트 섹션을 추가한다. (파일 미존재 시 신규 생성)

### 생성 조건
- S4 Gate PASS 또는 AUTO 확인 후
- Notion MCP 미연결 시 (Tier 2 Fallback)

### 문서 구조
`{folderMap.templates}/notion-task-template.md`의 Tier 2 구조를 따른다:
- S1~S4 각 Stage의 태스크와 Gate 상태 기록
- Forge Dev 세션별 Todo (Spec 문서 단위): Spec 작성 → Plan 작성 → Task 분배 → 구현 + Check 3 → Walkthrough → PR 생성 → PR 리뷰 + Merge
- 참조 문서 인덱스

### Forge Dev 세션 Todo 생성 기준
S4 개발 계획의 "Forge Dev 세션 로드맵"에서 스펙 단위 칸반 행을 추출:
- **Standard 세션**: 세션 = Spec 1개 = 행 1개 (세션 이름, SP 표기)
- **Multi-Spec 세션**: 도메인별 Spec = 행 N개 (SP는 마지막 행에 세션 합계 표기)
- 상태 흐름: ⬜ Todo → 🔄 Doing (브랜치 생성) → 🧪 QA (Check 3 진입) → ✅ Done (PR Merge)

### Spec 크기 가드레일 5원칙

세션 로드맵 작성 시 아래 5원칙을 준수하여 AI가 한 세션에서 처리 가능한 크기를 보장한다.

| # | 원칙 | 기준 | 위반 시 |
|:-:|------|------|---------|
| 1 | **1 Spec = 1 Feature** | 하나의 사용자 가치를 전달하는 단위 | 분리 권고 |
| 2 | **Spec 크기 상한** | 700-900줄 적정, 1,200줄 경고, 1,500줄+ 분리 필수 | [STOP] 분리 |
| 3 | **SP 상한** | 5-8 SP 적정, 10 SP 경고, 12+ 분리 필수 | [STOP] 분리 |
| 4 | **세션-Spec 명시** | "Session N — Spec M: [제목] (N SP)" 형식 필수 | S4 Gate FAIL |
| 5 | **번들링 정당화** | 2개 기능 번들 시 "왜 분리 불가한지" 명시 | Spec 리뷰 시 확인 |

**세션 로드맵 형식 예시**:
```
Session 1 — Spec 1: Auth Enhancement (5 SP)
Session 2 — Spec 2: Admin API + Swagger (5 SP)
Session 3 — Spec 3: Admin Layout + Navigation (3 SP)
```

**번들링 허용 기준**: 2개 기능이 동일 Entity/모듈을 공유하고 분리 시 중복 구현이 불가피한 경우에만 허용. 번들 시에도 SP 상한(10 SP)과 크기 상한(1,200줄)을 초과할 수 없다.

## Iron Laws

- **S4-IRON-1**: 필수 산출물 3종이 모두 완성되기 전에 Gate를 통과하지 않는다
- **S4-IRON-2**: S3에 관리자 기능이 포함되었는데 S4에서 관리자 산출물을 누락하지 않는다
- **S4-IRON-3**: Wave 2A 트레이서빌리티 리포트, Wave 2B 디렉션 일관성 리포트, Wave 3 리뷰 리포트 없이 S4 Gate를 통과하지 않는다
- **S4-IRON-4**: 세션 로드맵에서 세션-Spec 매핑이 "Session N — Spec M: [제목] (N SP)" 형식으로 명시되지 않으면 S4 Gate FAIL

## Rationalization Table

| 합리화 (Thought) | 현실 (Reality) |
|-------------------|---------------|
| "테스트 전략은 나중에 작성해도 될 것 같다" | Forge Dev에서 테스트 전략 없이 개발을 시작하면 테스트 부채가 누적된다. 개발 계획 내 테스트 전략 섹션이 필수다 |
| "관리자 페이지는 서비스 후에 만들면 된다" | 관리자 산출물 누락은 개발 단계에서 추가 기획을 필요로 한다. S3에 포함되었으면 S4에도 반드시 포함한다 |

## Red Flags

- "이건 개발하면서 결정하면..." → STOP. S4에서 결정하고 문서화한다
- "관리자는 나중에..." → STOP. S3 기획서에서 관리자 포함 여부를 확인한다
- "이 기능들은 관련 있으니 한 Spec에..." → STOP. SP 상한(10)과 크기 상한(1,200줄) 확인 후 분리 필요 여부를 판단한다
- "세션 이름만 적으면 충분하지..." → STOP. "Session N — Spec M: [제목] (N SP)" 형식을 준수한다
