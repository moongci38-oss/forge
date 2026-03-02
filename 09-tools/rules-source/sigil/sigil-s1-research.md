---
title: "S1 리서치"
id: sigil-s1-research
impact: MEDIUM
scope: [sigil]
tags: [pipeline, research, s1]
requires: [sigil-structure]
section: sigil-pipeline
audience: all
impactDescription: "리서치 병렬화 미적용 시 조사 시간 2-3배 증가. 팩트체크 누락 시 S2에서 잘못된 시장 데이터 기반 의사결정"
enforcement: flexible
---

# S1 리서치

## S1. Research (리서치)

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

## Do

- 리서치 에이전트를 독립 분석 후 비교하는 Competing Hypotheses 패턴을 사용한다
- 필수 방법론(AI-augmented Research, JTBD, Competitive Intelligence, Evidence-Based Management)을 적용한다
- 산출물을 `01-research/projects/{project}/` 하위에 저장한다

## Don't

- 단일 소스에만 의존하여 리서치를 완료하지 않는다
- 검증 없는 시장 데이터를 사실로 단정하지 않는다
- [STOP] 게이트 없이 S2로 진행하지 않는다

## AI 행동 규칙

1. 에이전트 회의 결과는 비교표 + 선택 근거를 명시한다
2. 각 Stage 산출물은 해당 폴더의 `projects/{project}/` 하위에 저장한다
3. 프로젝트 폴더 내 파일명에서 프로젝트명을 제거한다 (폴더가 이미 프로젝트를 나타냄)
