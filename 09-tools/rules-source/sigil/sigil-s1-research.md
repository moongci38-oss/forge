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

- research-coordinator → 아래 실존 리소스를 Fan-out 병렬 조율:

| 리소스 | 유형 | 역할 |
|--------|------|------|
| **academic-researcher** | Agent | 학술 논문, 리뷰 논문, 인용 분석 |
| **fact-checker** | Agent | 수치 검증, 출처 신뢰도, 교차 검증 |
| **WebSearch** | Tool | 실시간 뉴스, 업계 동향, 일반 웹 |
| **`mcp__brave-search__brave_web_search`** | Tool | 웹 검색 (WebSearch 대체/보완, 풍부한 메타데이터) |
| **`mcp__brave-search__brave_news_search`** | Tool | 뉴스 전용 검색 (날짜 필터, freshness 파라미터 지원) |
| **`/competitor`** | Command | 경쟁사 심층 분석 (기능/가격/전략) |
| **`marketing:competitive-analysis`** | Plugin | 경쟁사 포지셔닝, 메시징 비교 |
| **`data:data-exploration`** | Plugin | 시장 데이터 정량 분석 (해당 시) |

- **에이전트 회의**: Competing Hypotheses — 리서치 에이전트 독립 분석 → 비교 → 방향 도출
- **필수 방법론**: AI-augmented Research + JTBD + Competitive Intelligence 자동화 + Evidence-Based Management
- **선택 방법론**: SOAR, PESTLE
- **방법론 구현 가이드**: `09-tools/prompts/sigil-methodologies.md` 참조
- **산출물**: `{folderMap.research}/{project}/YYYY-MM-DD-s{N}-{topic}.md`
- **게이트**: **[AUTO-PASS]** DoD 자동 검증 (sigil-gate-check.sh S1)

## Do

- 리서치 에이전트를 독립 분석 후 비교하는 Competing Hypotheses 패턴을 사용한다
- 필수 방법론(AI-augmented Research, JTBD, Competitive Intelligence, Evidence-Based Management)을 적용한다
- 산출물을 `{folderMap.research}/{project}/` 하위에 저장한다

## Don't

- 단일 소스에만 의존하여 리서치를 완료하지 않는다
- 검증 없는 시장 데이터를 사실로 단정하지 않는다
- DoD 자동 검증 없이 S2로 진행하지 않는다

## AI 행동 규칙

1. 에이전트 회의 결과는 비교표 + 선택 근거를 명시한다
2. 각 Stage 산출물은 해당 폴더의 `projects/{project}/` 하위에 저장한다
3. 프로젝트 폴더 내 파일명에서 프로젝트명을 제거한다 (폴더가 이미 프로젝트를 나타냄)
4. S1 Gate AUTO-PASS 알림을 출력하고 S2로 자동 진행한다. 검증 FAIL 시 [STOP]으로 에스컬레이션한다
