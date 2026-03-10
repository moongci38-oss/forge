---
name: weekly-research
description: >
  매주 실행하는 주간 리서치 파이프라인. 기술 뉴스, 비즈니스 뉴스,
  사업 아이템 제안 3종을 Subagent 병렬로 생성한다.
argument-hint: "[YYYY-MM-DD]"
allowed-tools: "Agent,WebSearch,WebFetch,mcp__brave-search__brave_web_search,mcp__brave-search__brave_news_search,Write,Read,Glob,Grep"
user-invocable: true
---

# 주간 리서치 파이프라인

> SIGIL S1 정기 리서치 채널. 3개 산출물을 Subagent 병렬로 생성한다.

## 인자

- `$ARGUMENTS` = 리포트 기준 날짜 (YYYY-MM-DD). 미입력 시 오늘 날짜 사용.

## 산출물 (3종)

| # | 문서 | 저장 위치 | 파일명 |
|:-:|------|----------|--------|
| 1 | 일반 기술 뉴스 | `01-research/weekly/` | `{date}-tech-trends.md` |
| 2 | 비즈니스 뉴스 | `01-research/weekly/` | `{date}-biz-trends.md` |
| 3 | 사업 아이템 제안 | `01-research/projects/{project}/` | `{date}-s1-research.md` |

## 실행 흐름

### Wave 1 (Subagent 병렬 — 3개 동시 스폰)

Agent 도구로 3개 Subagent를 동시에 스폰한다. 의존성이 없으므로 단일 메시지에서 병렬 호출한다:

**Subagent A (model: haiku): 일반 기술 뉴스 수집**

프롬프트에 아래를 포함하여 스폰:
- 분석 기준 날짜: `$ARGUMENTS`
- `mcp__brave-search__brave_news_search`: 최근 7일 AI/게임/웹 개발 뉴스 (WebSearch 대체)
- **필수 확인 소스** (WebFetch 직접 접속):
  - `https://www.anthropic.com/news` — Anthropic 공식 뉴스/블로그
  - `https://docs.anthropic.com/en/docs/changelog` — Claude API 변경 로그
  - `https://www.anthropic.com/engineering` — 엔지니어링 블로그
- 3개 카테고리별 뉴스 + 신뢰도 표기 + 출처 + 액션 아이템
- 파일 직접 저장: `01-research/weekly/{date}-tech-trends.md`
- 저장 완료 후 종료

**Subagent B (model: haiku): 비즈니스 뉴스 수집**

프롬프트에 아래를 포함하여 스폰:
- 분석 기준 날짜: `$ARGUMENTS`
- `mcp__brave-search__brave_news_search`: SaaS/스타트업, 인디해커/1인기업 뉴스 (WebSearch 대체)
- `mcp__brave-search__brave_web_search`: Product Hunt 신규 AI 제품 탐색
- 시장 동향 + 과금 모델 변화 + 성공 사례 + 액션 아이템
- 파일 직접 저장: `01-research/weekly/{date}-biz-trends.md`
- 저장 완료 후 종료

**Subagent C (model: sonnet): 사업 아이템 조사 + 분석**

프롬프트에 아래를 포함하여 스폰:
- 분석 기준 날짜: `$ARGUMENTS`
- `mcp__brave-search__brave_web_search`: 시장 데이터, 경쟁사, 성공 사례 (WebSearch 대체)
- SIGIL S1 방법론 적용: 경쟁 가설 3개 → TAM/SAM/SOM → JTBD → 최종 1개 선정
- 실행 로드맵 (MVP, 기술 스택, 타임라인)
- 선정 기준: **1인 개발자가 내달 1,000만원+ 수익 달성 가능성**
- 프로젝트명 자동 결정 → `sigil-workspace.json` 등록 확인
- 파일 직접 저장: `01-research/projects/{project}/{date}-s1-research.md`
- `gate-log.md`에 S1 PASS 기록
- 저장 완료 후 종료

### Wave 2 (Lead 취합 — Wave 1 완료 후)

3개 Subagent 완료 확인 후:
1. 3종 파일 존재 여부 확인 (`01-research/weekly/`, `01-research/projects/`)
2. 주간 요약 보고: 파일 경로, 사업 아이템 제목, 신뢰도 분포
3. 누락 파일 있으면 해당 Subagent 재스폰

## 신뢰도 등급

모든 뉴스/데이터에 신뢰도를 표기한다:
- `[신뢰도: High]` = 다중 소스에서 일관 확인
- `[신뢰도: Medium]` = 단일 신뢰 소스
- `[신뢰도: Low]` = AI 추정 또는 비공식 소스

## SIGIL 연동

- 사업 아이템은 SIGIL S1 형식으로 저장
- `sigil-workspace.json`에 프로젝트 등록 확인
- gate-log.md에 S1 게이트 기록
- Human 승인 시 S2(린 캔버스)로 진행 가능
