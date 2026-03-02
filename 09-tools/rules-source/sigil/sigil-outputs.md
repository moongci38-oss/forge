---
title: "SIGIL 산출물 경로"
id: sigil-outputs
impact: MEDIUM
scope: [sigil]
tags: [pipeline, outputs, templates, paths]
requires: [sigil-structure]
section: sigil-pipeline
audience: all
impactDescription: "산출물 경로 미준수 시 자동 빌드/관리 파이프라인 실패. 팀 간 산출물 공유 혼란"
enforcement: flexible
---

# SIGIL 산출물 경로

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
