# Portfolio Project — SIGIL 통합 Todo Tracker

**최종 업데이트**: 2026-03-09
**devTarget**: `/home/damools/mywsl_workspace/portfolio-project`

---

## S1 Research
| # | 태스크 | 담당 | 상태 | 비고 |
|:-:|--------|:----:|:----:|------|
| — | (스킵) | — | ⏭️ | 기존 프로젝트 기능 확장, 외부 시장조사 불필요 |

**게이트**: ⏭️ SKIP (2026-03-03) — 기술 현황 분석을 S2에 포함

## S2 Concept
| # | 태스크 | 담당 | 상태 | 비고 |
|:-:|--------|:----:|:----:|------|
| 1 | Lean Canvas 작성 | AI | ✅ | 완료일: 2026-03-03 |
| 2 | Go/No-Go 스코어링 | AI | ✅ | 87점 (Go) |
| 3 | OKR 2개 정의 | AI | ✅ | |
| 4 | Phase 1 범위 확정 | AI+Human | ✅ | Human 승인 완료 |

**게이트**: ✅ PASS (2026-03-03) — Go/No-Go 87점, Human 승인 완료

## S3 Design Document
| # | 태스크 | 담당 | 상태 | 비고 |
|:-:|--------|:----:|:----:|------|
| 1 | PRD 초안 (Draft A/B) | AI | ✅ | 에이전트 회의 2팀 |
| 2 | Draft 비교·병합 | AI | ✅ | 최적안 선택 |
| 3 | PRD .md 완성 | AI | ✅ | 704 lines |
| 4 | PRD .pptx 변환 | AI | ✅ | IRON-2 충족 |
| 5 | 기획서 리뷰 | Human | ✅ | 승인일: 2026-03-03 |

**게이트**: ✅ PASS (2026-03-03) — PRD(.md+.pptx), 에이전트 회의 완료, IRON-1/2 충족

## S4 Planning Package
| # | 태스크 | 담당 | 상태 | 비고 |
|:-:|--------|:----:|:----:|------|
| 1 | Wave 1: 산출물 초안 | AI | ✅ | technical-writer |
| 2 | Wave 2: Spec 트레이서빌리티 검증 | AI | ✅ | 97.1% (67/69) |
| 3 | Wave 3: CTO 기술 검토 | AI | ✅ | CRITICAL+HIGH 전건 해결 |
| 4 | Wave 3: UX 검증 | AI | ✅ | CRITICAL+HIGH 전건 해결 |
| 5 | Wave 4: 최종본 반영 | AI | ✅ | |
| 6 | 기획 패키지 최종 리뷰 | Human | ✅ | 승인일: 2026-03-03 |
| 7 | Handoff 문서 생성 | AI | ✅ | `10-operations/handoff-to-dev/portfolio/` |

**게이트**: ✅ PASS (2026-03-03) — 산출물 완성, 트레이서빌리티 97.1%, Human 승인 완료

**잔여 GAP (Wave 2)**:
- GAP-01: Swagger RBAC 접근 제한 방식 미결정 (basicAuth vs JwtAuthGuard)
- GAP-02: 모바일 Bottom Sheet 네비게이션 상세 스펙 미작성

---

**선행 결정** (Trine 진입 전):
- [x] localStorage → HttpOnly Cookie 전환 확정 (ADR-002 Dual Storage 패턴 — Accepted)
- [x] EDITOR 역할 세부 권한 범위 최종 확인 (PRD 3.1절 — CRU only, 삭제/공개/순서/팀관리 제외)
- [ ] Cloudinary 계정/API Key 준비 (ADR-004 Cloudinary 확정 — Session 1 구현 시 셋업)

## Trine 개발 진행

| # | Spec | Session | SP | Status | PR | 완료일 |
|:-:|------|:-------:|:--:|:------:|:--:|:------:|
| 1 | Auth + Core Admin API + Swagger | S1 | 78 | ✅ Done | [#82](https://github.com/ljw7555-rgb/portfolio-project/pull/82) | 2026-03-05 |
| 2 | Layout + Auth UI | S2 | — | ✅ Done | [#83](https://github.com/ljw7555-rgb/portfolio-project/pull/83) | 2026-03-05 |
| 3 | Project UI | S2 | — | ✅ Done | [#84](https://github.com/ljw7555-rgb/portfolio-project/pull/84) | 2026-03-05 |
| 4 | Team UI | S2 | 54 | ✅ Done | [#85](https://github.com/ljw7555-rgb/portfolio-project/pull/85) | 2026-03-05 |
| 5 | Dashboard + E2E + Mobile | S3 | 29 | ✅ Done | [#86](https://github.com/ljw7555-rgb/portfolio-project/pull/86) | 2026-03-05 |

**상태 흐름**: ⬜ Todo → 🔄 Doing → 🧪 QA → ✅ Done
**SP 합계**: 161 (S1: 78 + S2: 54 + S3: 29)

---

## Admin Gap Fix (2026-03-06)

> 갭 분석(`docs/reviews/2026-03-06-admin-gap-analysis.md`) 기반 11개 이슈 해결
> 구현 순서: A → C → B → D (의존성 기반)

| # | Spec | 심각도 | Spec 문서 | Plan 문서 | 승인 | Status | PR | 완료일 |
|:-:|------|--------|:---------:|:---------:|:----:|:------:|:--:|:------:|
| 6 | A: Auth Security Hardening | CRITICAL x3 + MAJOR + MINOR | ✅ | ✅ | ⬜ | ⬜ Todo | - | - |
| 7 | C: Guard/Swagger Hardening | MAJOR x3 + MINOR | ✅ | ✅ | ⬜ | ⬜ Todo | - | - |
| 8 | B: Image Upload Pipeline | MAJOR | ✅ | ✅ | ⬜ | ⬜ Todo | - | - |
| 9 | D: Project Permission Fix | MINOR | ✅ | N/A | ⬜ | ⬜ Todo | - | - |

---

## portfolio-blog — Trine 개발 진행

| # | Spec | Session | SP | Status | PR | 완료일 |
|:-:|------|:-------:|:--:|:------:|:--:|:------:|
| 10 | 카테고리 재구성 + 공지(isPinned) | S1 | — | ⬜ Todo | — | — |
| 11 | 댓글 시스템 | S2 | — | ⬜ Todo | — | — |
| 12 | 검색 + 태그 페이지 + RSS | S3 | — | ⬜ Todo | — | — |
| 13 | 에디터 고도화 + 자동저장 | S4 | — | ⬜ Todo | — | — |
| 14 | 주간 리포트 자동 발행 파이프라인 | S5 | — | ⬜ Todo | — | — |
| 15 | 분석 대시보드 + E2E | S6 | — | ⬜ Todo | — | — |

**상태 흐름**: ⬜ Todo → 🔄 Doing → 🧪 QA → ✅ Done

---

## 참조 문서 인덱스

### portfolio-admin

| 문서 | 경로 | 용도 |
|------|------|------|
| S3 PRD | `02-product/projects/portfolio-admin/2026-03-03-s3-prd.md` | 마스터 요구사항 |
| S4 상세 기획서 (Admin) | `02-product/projects/portfolio-admin/2026-03-03-s4-admin-detailed-plan.md` | 화면별 스펙 (사이트맵 포함) |
| S4 UI/UX 기획서 (Admin) | `05-design/projects/portfolio-admin/2026-03-03-s4-admin-uiux-spec.md` | 디자인 토큰, 와이어프레임 |
| S4 개발 계획 | `02-product/projects/portfolio-admin/2026-03-03-s4-development-plan.md` | 기술 스택, ADR, 세션 로드맵 (로드맵+WBS 포함) |
| S4 테스트 전략서 | `02-product/projects/portfolio-admin/2026-03-03-s4-test-strategy.md` | 테스트 피라미드, 커버리지 목표 |
| Handoff | `10-operations/handoff-to-dev/portfolio/2026-03-03-sigil-handoff.md` | SIGIL→Trine 전환 문서 |
| Gate Log | `02-product/projects/portfolio-admin/gate-log.md` | S1 SKIP → S2 PASS → S3 PASS → S4 PASS |

### portfolio-blog

| 문서 | 경로 | 용도 |
|------|------|------|
| S3 PRD | `02-product/projects/portfolio-blog/2026-03-09-s3-prd.md` | 마스터 요구사항 |
| S4 상세 기획서 | `02-product/projects/portfolio-blog/2026-03-09-s4-detailed-plan.md` | 화면별 스펙 (사이트맵 포함) |
| S4 개발 계획 | `02-product/projects/portfolio-blog/2026-03-09-s4-development-plan.md` | 기술 스택, ADR, 세션 로드맵 (로드맵+WBS 포함) |
| S4 UI/UX 기획서 | `05-design/projects/portfolio-blog/2026-03-09-s4-uiux-spec.md` | 와이어프레임, 인터랙션 |
| S4 테스트 전략서 | `02-product/projects/portfolio-blog/2026-03-09-s4-test-strategy.md` | 테스트 피라미드, 커버리지 목표 |
| Gate Log | `02-product/projects/portfolio-blog/gate-log.md` | S2 SKIP → S3 PASS → S4 (대기) |
