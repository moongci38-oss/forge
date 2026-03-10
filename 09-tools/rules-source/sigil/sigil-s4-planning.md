---
title: "S4 기획 패키지"
id: sigil-s4-planning
impact: HIGH
scope: [sigil]
tags: [pipeline, planning, s4, admin]
requires: [sigil-structure, sigil-s3-design]
section: sigil-pipeline
audience: all
impactDescription: "필수 산출물 3종 미완료 시 Trine 진입 불가. 관리자 산출물 누락 시 개발 단계에서 추가 기획 필요 → 일정 지연"
enforcement: rigid
---

# S4 기획 패키지

## S4. Planning Package

S3 기획서(PRD/GDD) 기반으로 Trine 진입 전 종합 기획 문서를 작성한다.

| # | 산출물 | 파일명 | 내용 | Trine 참조 |
|:-:|--------|--------|------|-----------|
| 1 | **상세 기획서** | s4-detailed-plan.md | 화면별 동작 + 데이터 흐름 + 사이트맵(페이지 계층/네비게이션) | Phase 2 Spec |
| 2 | **개발 계획** | s4-development-plan.md | 기술 스택 + 아키텍처 + ADR + 세션 로드맵 + 로드맵(Now/Next/Later) + WBS(태스크 분해/규모 추정) + **테스트 전략**(피라미드/커버리지 목표/도구/파일 구조) | Phase 1 컨텍스트 + Phase 3 Check |
| 3 | **UI/UX 기획서** | s4-uiux-spec.md | 와이어프레임 + 컴포넌트 스펙 + 인터랙션 패턴 + 디자인 가이드 | Phase 2 Spec UI |

> **흡수된 산출물**: 사이트맵 → 상세 기획서에 통합, 로드맵/WBS → 개발 계획에 통합, 테스트 전략서 → 개발 계획에 통합. S4 Gate 통과 시 todo.md도 자동 생성된다.
> **E2E 시나리오 상세**는 S4에서 제거 → Trine Spec Section 10에서만 작성한다.

- **에이전트**: technical-writer (작성) + cto-advisor (기술 검토) + ux-researcher (UX 검증)
- **필수 방법론**: Now/Next/Later + RICE/ICE Scoring + C4 Model + ADR
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

- **게이트**: **[STOP]** 승인 → Trine 진입

### S4 Wave Protocol

S4 기획 패키지를 4단계 Wave로 작성한다.

```
Wave 1 (순차): technical-writer → 3대 산출물 초안 작성
  - 관리자 포함 시 서비스 + 관리자 산출물 모두 작성

Wave 2 (Spec 검증):
  - S3 기획서(PRD/GDD)의 기능/비기능 요구사항 목록 추출
  - S4 각 산출물에 해당 요구사항이 반영되었는지 체크리스트 검증
  - 누락 항목 식별 → Wave 1 에이전트에 보완 요청

Wave 3 (병렬):
  - cto-advisor → 기술 검토 (개발 계획, 아키텍처, ADR)
  - ux-researcher → UX 검증 (UI/UX 기획서, 와이어프레임)

Wave 4: technical-writer → Wave 2-3 리뷰 반영 최종본 작성
```

> Wave 2는 "존재/누락"만 검증한다. "품질"은 Wave 3에서 검증한다.

## Do

- S3 기획서에 관리자 기능이 포함되면 S4 모든 산출물에 관리자 섹션을 반영한다
- S4 완료 후 Trine Handoff 문서를 자동 생성하고 진입을 안내한다
- 필수 산출물 3종을 모두 작성한다

## Don't

- S3에 관리자 기능이 포함되었는데 S4에서 관리자 산출물을 누락하지 않는다
- 필수 산출물 3종 중 하나라도 빠진 상태로 게이트를 통과하지 않는다
- 관리자/운영툴의 모바일 화면 기획을 생략하지 않는다 (Desktop-only는 명시 선언 필요)

## AI 행동 규칙

1. S3 기획서에 관리자 기능이 포함되면 S4 모든 산출물에 관리자 섹션을 반영한다
2. S4 완료 후 Trine Handoff 문서를 자동 생성하고 진입을 안내한다
3. 각 Stage 산출물은 해당 폴더의 `projects/{project}/` 하위에 저장한다
5. 프로젝트 폴더 내 파일명에서 프로젝트명을 제거한다 (폴더가 이미 프로젝트를 나타냄)
5. **S4 Gate 통과 시 Tier 2 Todo Tracker를 자동 생성한다** (아래 참조)

## Tier 2 Todo 자동 생성 (S4 Gate 통과 시)

S4 [STOP] Gate 통과 시 `{folderMap.product}/todo.md`에 해당 프로젝트 섹션을 추가한다. (파일 미존재 시 신규 생성)

### 생성 조건
- S4 Gate PASS 확인 후
- Notion MCP 미연결 시 (Tier 2 Fallback)

### 문서 구조
`{folderMap.templates}/notion-task-template.md`의 Tier 2 구조를 따른다:
- S1~S4 각 Stage의 태스크와 Gate 상태 기록
- Trine 세션별 Todo (Spec 문서 단위): Spec 작성 → Plan 작성 → Task 분배 → 구현 + Check 3 → Walkthrough → PR 생성 → PR 리뷰 + Merge
- 참조 문서 인덱스

### Trine 세션 Todo 생성 기준
S4 개발 계획의 "Trine 세션 로드맵"에서 스펙 단위 칸반 행을 추출:
- **Standard 세션**: 세션 = Spec 1개 = 행 1개 (세션 이름, SP 표기)
- **Multi-Spec 세션**: 도메인별 Spec = 행 N개 (SP는 마지막 행에 세션 합계 표기)
- 상태 흐름: ⬜ Todo → 🔄 Doing (브랜치 생성) → 🧪 QA (Check 3 진입) → ✅ Done (PR Merge)

## Iron Laws

- **IRON-1**: 필수 산출물 3종이 모두 완성되기 전에 [STOP] Gate를 통과하지 않는다
- **IRON-2**: S3에 관리자 기능이 포함되었는데 S4에서 관리자 산출물을 누락하지 않는다
- **IRON-3**: Wave 2 트레이서빌리티 리포트와 Wave 3 리뷰 리포트 없이 S4 Gate를 통과하지 않는다

## Rationalization Table

| 합리화 (Thought) | 현실 (Reality) |
|-------------------|---------------|
| "테스트 전략은 나중에 작성해도 될 것 같다" | Trine에서 테스트 전략 없이 개발을 시작하면 테스트 부채가 누적된다. 개발 계획 내 테스트 전략 섹션이 필수다 |
| "관리자 페이지는 서비스 후에 만들면 된다" | 관리자 산출물 누락은 개발 단계에서 추가 기획을 필요로 한다. S3에 포함되었으면 S4에도 반드시 포함한다 |

## Red Flags

- "이건 개발하면서 결정하면..." → STOP. S4에서 결정하고 문서화한다
- "관리자는 나중에..." → STOP. S3 기획서에서 관리자 포함 여부를 확인한다
