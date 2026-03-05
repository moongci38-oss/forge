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

> 모든 경로는 `sigil-workspace.json`의 `folderMap`에서 해석한다.
> `{product}` = `folderMap.product`, `{design}` = `folderMap.design`, `{content}` = `folderMap.content` 등

## 산출물 저장 경로

| 유형 | folderMap 키 | 파일 패턴 |
|------|:-----------:|----------|
| 리서치 | `research` | `{project}/YYYY-MM-DD-s{N}-{topic}.md` |
| 컨셉 (개발) | `product` | `{project}/YYYY-MM-DD-s2-concept.md` |
| 컨셉 (콘텐츠) | `content` | `{project}/YYYY-MM-DD-s2-channel-strategy.md` |
| PRD | `product` | `{project}/YYYY-MM-DD-s3-prd.md` |
| PRD PPT | `product` | `{project}/YYYY-MM-DD-s3-prd.pptx` |
| GDD | `product` | `{project}/YYYY-MM-DD-s3-gdd.md` |
| GDD PPT | `product` | `{project}/YYYY-MM-DD-s3-gdd.pptx` |
| 관리자 PRD | `product` | `{project}/YYYY-MM-DD-s3-admin-prd.md` |
| 콘텐츠 기획 | `content` | `{project}/YYYY-MM-DD-s3-script.md` |
| 상세 기획서 | `product` | `{project}/YYYY-MM-DD-s4-detailed-plan.md` |
| 관리자 상세 기획서 | `product` | `{project}/YYYY-MM-DD-s4-admin-detailed-plan.md` |
| 사이트맵 | `product` | `{project}/YYYY-MM-DD-s4-sitemap.md` |
| 관리자 사이트맵 | `product` | `{project}/YYYY-MM-DD-s4-admin-sitemap.md` |
| 로드맵 | `product` | `{project}/YYYY-MM-DD-s4-roadmap.md` |
| 개발 계획 | `product` | `{project}/YYYY-MM-DD-s4-development-plan.md` |
| WBS | `product` | `{project}/YYYY-MM-DD-s4-wbs.md` |
| UI/UX 기획서 | `design` | `{project}/YYYY-MM-DD-s4-uiux-spec.md` |
| 관리자 UI/UX 기획서 | `design` | `{project}/YYYY-MM-DD-s4-admin-uiux-spec.md` |
| 테스트 전략서 | `product` | `{project}/YYYY-MM-DD-s4-test-strategy.md` |
| 제작 가이드 | `content` | `{project}/YYYY-MM-DD-s4-production-guide.md` |
| 배포 캘린더 (쇼폼) | `content` | `{project}/YYYY-MM-DD-s4-deployment-calendar.md` |
| 게이트 로그 | `product` | `{project}/gate-log.md` |
| Todo | `product` | `{project}/YYYY-MM-DD-todo.md` |
| Council 평가 기록 | `product` | `{project}/YYYY-MM-DD-council-evaluation.md` |
| Handoff 문서 | `handoff` | `{target-project}/YYYY-MM-DD-sigil-handoff.md` |

## 템플릿

| 템플릿 | folderMap 키 | 파일명 |
|--------|:-----------:|--------|
| GDD 템플릿 | `templates` | `gdd-template.md` |
| 기획 패키지 템플릿 | `templates` | `planning-package-template.md` |
| UI/UX 기획서 템플릿 | `templates` | `uiux-spec-template.md` |
| 제작 가이드 템플릿 | `templates` | `production-guide-template.md` |
| 테스트 전략서 템플릿 | `templates` | `test-strategy-template.md` |
| DoD 체크리스트 | `templates` | `dod-checklist.md` |
| Council 평가 매트릭스 | `templates` | `council-evaluation-template.md` |
| PM Todo 구조 | `templates` | `notion-task-template.md` |

## AI 행동 규칙

1. **파이프라인 시작 시 `sigil-workspace.json`을 읽어 경로를 해석한다** — 없으면 [STOP]
2. 파이프라인 시작 시 프로젝트 유형을 먼저 식별한다
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
