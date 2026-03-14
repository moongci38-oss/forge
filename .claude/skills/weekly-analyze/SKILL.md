---
name: weekly-analyze
description: >
  Weekly Research JSON → 심층 분석. raw-data.json이 존재할 때
  수집 단계를 스킵하고 분석만 실행하는 재분석 진입점.
argument-hint: "<YYYY-MM-DD>"
allowed-tools: "Read,Write,Glob,WebSearch,WebFetch,mcp__brave-search__brave_web_search"
user-invocable: true
---

# Weekly Research — 재분석 (JSON → 분석)

> raw-data.json이 이미 존재하는 날짜에 대해 수집 스킵 후 분석만 재실행한다.
> 분석 실패/중단 후 재시작, 또는 다른 관점으로 재분석할 때 사용.

## 인자

- `$ARGUMENTS` = 재분석 기준 날짜 (YYYY-MM-DD). 미입력 시 오늘 날짜 사용.

## Step 1: raw-data.json 로드

```
01-research/weekly/{date}/raw-data.json
```

파일 읽기 후:
- `stats` 섹션에서 수집 현황 확인 (카테고리별 수집 건수)
- `items` 배열에서 수집된 정형 데이터 확인 (tech 피드, GitHub 트렌딩, HN)
- `claude_search_needed` 배열에서 Claude가 추가로 검색해야 할 카테고리 확인

파일이 없으면: **[STOP]** — `/weekly-research {date}` 를 먼저 실행해야 한다.

## Step 2: Claude 검색 보강

raw-data.json의 `claude_search_needed` 항목에 대해 검색 수행:

**비즈니스 뉴스 (WebSearch):**
- SaaS/스타트업 주간 동향
- Product Hunt AI 카테고리 신규 제품 (지난 7일)
- 인디해커/1인기업 성공 사례, 과금 모델 변화

**사업 아이템 리서치 (WebSearch + WebFetch):**
- 시장 데이터 + 경쟁사 현황
- SIGIL S1 방법론: 경쟁 가설 3개 → TAM/SAM/SOM → JTBD → 최종 1개 선정
- 1인 개발자 기준 내달 1,000만원+ 수익 달성 가능성 평가

검색 도구 우선순위: `mcp__brave-search__brave_web_search` → WebSearch → WebFetch

## Step 3: 산출물 생성 (3종)

`weekly-research-analyst` 에이전트를 스폰하여 분석을 수행한다.

에이전트 프롬프트에 포함:
- raw-data.json 경로 + 수집 현황 요약
- Claude 검색 결과 (비즈니스 뉴스, 사업 아이템)
- 리포트 기준 날짜: `$ARGUMENTS`
- 산출물 저장 위치 3곳 (아래)

| # | 문서 | 저장 위치 | 파일명 |
|:-:|------|----------|--------|
| 1 | 일반 기술 뉴스 | `01-research/weekly/{date}/` | `tech-trends.md` |
| 2 | 비즈니스 뉴스 | `01-research/weekly/{date}/` | `biz-trends.md` |
| 3 | 사업 아이템 제안 | `01-research/projects/{project}/` | `{date}-s1-research.md` |

## Step 4: Wave 2 취합 검증

3종 파일 존재 확인:
- 누락 파일 있으면 해당 에이전트 재스폰
- 3종 모두 존재하면 주간 요약 보고 (파일 경로, 사업 아이템 제목, 신뢰도 분포)

## Step 5: Notion 자동 등록 + 블로그 발행

완료 후 순차 실행:
1. Portfolio 블로그 자동 발행 (tech-trends.md → `/api/v1/blog/auto-publish`)
2. Notion "Weekly Research" DB 자동 등록
   - Data Source ID: `d7ba2bc1-4c7b-400d-872f-8d78bfeea213`
   - Notion MCP 미연결 시 경고 후 스킵

## 신뢰도 등급

- `[신뢰도: High]` = 다중 소스에서 일관 확인
- `[신뢰도: Medium]` = 단일 신뢰 소스
- `[신뢰도: Low]` = AI 추정 또는 비공식 소스
