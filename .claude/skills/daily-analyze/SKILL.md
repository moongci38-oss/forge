---
name: daily-analyze
description: >
  Daily Review JSON → 심층 AI 분석. raw-data.json이 존재할 때
  수집 단계를 스킵하고 분석만 실행하는 재분석 진입점.
argument-hint: "<YYYY-MM-DD>"
allowed-tools: "Read,Write,Glob,WebSearch,WebFetch,mcp__brave-search__brave_web_search"
user-invocable: true
---

# Daily System Review — 재분석 (JSON → 분석)

> raw-data.json이 이미 존재하는 날짜에 대해 수집 스킵 후 분석만 재실행한다.
> 분석 실패/중단 후 재시작, 또는 다른 관점으로 재분석할 때 사용.

## 인자

- `$ARGUMENTS` = 재분석 기준 날짜 (YYYY-MM-DD). 미입력 시 전날 날짜 사용.

## Step 1: raw-data.json 로드

```
01-research/daily/{date}/raw-data.json
```

파일 읽기 후:
- `stats` 섹션에서 수집 현황 확인 (Tier별 수집 건수)
- `items` 배열에서 수집된 정형 데이터 확인
- `claude_search_needed` 배열에서 Claude가 추가로 검색해야 할 카테고리 확인

파일이 없으면: **[STOP]** — `/daily-system-review {date}` 를 먼저 실행해야 한다.

## Step 2: Claude 검색 보강

raw-data.json의 `claude_search_needed` 항목에 대해 검색 수행:

**Tier 3 커뮤니티 (WebSearch):**
- Hacker News AI 탑 스토리: `site:news.ycombinator.com AI after:{date}`
- Reddit r/MachineLearning, r/LocalLLaMA, r/ClaudeAI 최신 글
- Dev.to AI 태그 최신 포스트

**Tier 4 YouTube (WebSearch):**
- 주요 채널 최신 업로드: Fireship, AI Jason, Matt Wolfe, Yannic Kilcher
- `"Claude Code" site:youtube.com`, `"MCP server" site:youtube.com`
- 비즈니스 관련성 4점+ 예상 영상 별도 목록화

**Tier 6 미디어 (WebSearch):**
- TechCrunch AI, VentureBeat, Product Hunt AI 카테고리
- a16z AI Blog

검색 도구 우선순위: `mcp__brave-search__brave_web_search` → WebSearch → WebFetch

## Step 3: 우리 시스템 현황 스냅샷

**인프라 레이어:**
- Read: `~/.claude/forge/rules/` (최근 수정 파일)
- Read: `.claude/skills/`, `.claude/agents/`
- Read: `docs/planning/active/plans/` (미처리 액션 확인)

**Forge 파이프라인 현황 (필수):**
- Read: `forge-workspace.json` → 활성 프로젝트 목록 + folderMap 경로 확인
- 각 프로젝트의 `gate-log.md` Read → 현재 Gate 위치 (S1/S2/S3/S4) 확인
- Read: `02-product/projects/todo.md` (있으면) → Forge 전체 프로젝트 진행 현황

**Forge Dev 파이프라인 현황 (필수):**
- Glob: `**/.claude/state/sessions/*.json` → 활성/미완료 세션 목록
- Read: `docs/planning/active/forge/todo.md` → Spec별 진행 상태 (⬜/🔄/🧪/✅)
- Glob: `docs/walkthroughs/` → 최근 작성된 walkthrough (완료 Spec 파악)

## Step 4: 분석 + 산출물 생성

`daily-system-analyst` 에이전트를 스폰하여 수집 데이터를 종합 분석한다.

에이전트 프롬프트에 포함:
- raw-data.json 경로 + 수집 현황 요약
- Claude 검색 결과 (Tier 3/4/6)
- 시스템 현황 스냅샷
- 분석 기준 날짜: `$ARGUMENTS`
- 산출물 저장 위치: `01-research/daily/{date}/`

산출물 (2종):
1. `ai-system-analysis.md` — AI 시스템 분석 리포트
2. `system-improvement-plan.md` — 적용 계획서

이전 날짜의 `system-improvement-plan.md`가 있으면 미처리 액션을 이월한다.

## Step 5: Notion 자동 등록

분석 완료 후, 두 파일의 **전체 내용**을 Notion 페이지 본문에 직접 기록한다.

**Notion DB 정보:**
- Data Source ID: `43829f7b-8d3f-47f1-90a1-84f40d39239e`
- DB URL: `https://www.notion.so/b3a833acdc1644c99acf81e7da25a268`

**실행 순서:**

1. `Read("01-research/daily/{date}/ai-system-analysis.md")` → 전체 내용 변수 저장
2. `Read("01-research/daily/{date}/system-improvement-plan.md")` → 전체 내용 변수 저장
3. 두 파일 내용을 구분선(`---`)으로 이어 붙여 `content` 구성
4. `mcp__notion__notion-create-pages` 호출:

```json
{
  "parent": { "data_source_id": "43829f7b-8d3f-47f1-90a1-84f40d39239e" },
  "pages": [{
    "properties": {
      "제목": "{date} AI 시스템 분석",
      "Executive Summary": "{리포트의 ## Executive Summary 섹션 전문}",
      "date:날짜:start": "{date}",
      "상태": "완료",
      "Critical 갭": {Critical 갭 개수},
      "High 갭": {High 갭 개수},
      "Medium 갭": {Medium 갭 개수},
      "P0 액션": {P0 액션 개수},
      "P1 액션": {P1 액션 개수},
      "리포트 경로": "01-research/daily/{date}/ai-system-analysis.md",
      "적용계획 경로": "01-research/daily/{date}/system-improvement-plan.md"
    },
    "content": "{ai-system-analysis.md 전체 내용}\n\n---\n\n{system-improvement-plan.md 전체 내용}"
  }]
}
```

**실패 처리:**
- Notion MCP 미연결 시 경고 출력 후 스킵 (파이프라인 중단 안 함)
- 페이지 생성 실패 시 에러 로그 출력 후 스킵

## 신뢰도 등급

- `[신뢰도: High]` = 공식 소스 (Tier 1) 또는 다중 소스 교차 확인
- `[신뢰도: Medium]` = 단일 신뢰 소스 (Tier 2-3) 또는 커뮤니티 합의
- `[신뢰도: Low]` = 단일 비공식 소스, 루머, AI 추정
