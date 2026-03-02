---
title: "S3 기획서"
id: sigil-s3-design
impact: HIGH
scope: [sigil]
tags: [pipeline, design, s3, prd, gdd]
requires: [sigil-structure]
section: sigil-pipeline
audience: all
impactDescription: "단일 에이전트 초안만으로 기획 확정 시 품질 저하 30-50%. PPT 미생성 시 이해관계자 커뮤니케이션 실패"
enforcement: rigid
---

# S3 기획서

## S3. Design Document (기획서)

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

## Do

- 개발 트랙 S3 기획서는 **.md + .pptx** 모두 생성한다
- 기획 에이전트 2~3명의 독립 초안을 Competing Hypotheses로 비교한다
- 필수 방법론(Shape Up Pitch, User Story Mapping, Modern PRD)을 적용한다

## Don't

- 개발 트랙에서 .pptx 없이 기획서 승인을 진행하지 않는다
- 단일 에이전트 초안만으로 기획서를 확정하지 않는다 (에이전트 회의 필수)
- [STOP] 게이트 없이 S4로 진행하지 않는다

## AI 행동 규칙

1. 에이전트 회의 결과는 비교표 + 선택 근거를 명시한다
2. 개발 트랙 S3 기획서는 **.md + .pptx** 모두 생성한다
3. 각 Stage 산출물은 해당 폴더의 `projects/{project}/` 하위에 저장한다
4. 프로젝트 폴더 내 파일명에서 프로젝트명을 제거한다 (폴더가 이미 프로젝트를 나타냄)

## Iron Laws

- **IRON-1**: 단일 에이전트 초안만으로 기획서를 확정하지 않는다 (에이전트 회의 필수)
- **IRON-2**: 개발 트랙에서 .pptx 없이 기획서 승인을 진행하지 않는다

## Rationalization Table

| 합리화 (Thought) | 현실 (Reality) |
|-------------------|---------------|
| "시간이 부족하니 에이전트 회의 없이 진행하자" | 단일 관점 기획은 30-50% 품질 저하를 유발한다. Competing Hypotheses 비교에 소요되는 시간이 재작업 비용보다 훨씬 적다 |
| "PPT는 나중에 만들어도 된다" | [STOP] Gate는 .md + .pptx 모두를 요구한다. PPT 없는 기획서는 이해관계자 커뮤니케이션에서 실패한다 |

## Red Flags

- "한 명이 잘 작성했으니 비교 안 해도..." → STOP. 에이전트 회의를 실행한다
- "PPT는 형식적이니까..." → STOP. /pptx 스킬로 PPT를 생성한다
