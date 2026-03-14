---
name: weekly-research
description: >
  매주 실행하는 주간 리서치 파이프라인. 기술 뉴스, 비즈니스 뉴스,
  사업 아이템 제안 3종을 Subagent 병렬로 생성한다.
argument-hint: "[YYYY-MM-DD]"
allowed-tools: "Agent,WebSearch,WebFetch,Write,Read,Glob,Grep,mcp__brave-search__brave_web_search"
user-invocable: true
---

# 주간 리서치 파이프라인

> SIGIL S1 정기 리서치 채널. 3개 산출물을 Subagent 병렬로 생성한다.

## 인자

- `$ARGUMENTS` = 리포트 기준 날짜 (YYYY-MM-DD). 미입력 시 오늘 날짜 사용.

## 산출물 (3종)

| # | 문서 | 저장 위치 | 파일명 |
|:-:|------|----------|--------|
| 1 | 일반 기술 뉴스 | `01-research/weekly/{date}/` | `tech-trends.md` |
| 2 | 비즈니스 뉴스 | `01-research/weekly/{date}/` | `biz-trends.md` |
| 3 | 사업 아이템 제안 | `01-research/projects/{project}/` | `{date}-s1-research.md` |

## 실행 흐름

### Wave 1 (Subagent 병렬 — 3개 동시 스폰)

Agent 도구로 3개 Subagent를 동시에 스폰한다. 의존성이 없으므로 단일 메시지에서 병렬 호출한다:

**Subagent A (model: haiku): 일반 기술 뉴스 수집**

프롬프트에 아래를 포함하여 스폰:
- 분석 기준 날짜: `$ARGUMENTS`
- WebSearch: 최근 7일 AI/게임/웹 개발 뉴스
- **Brave Search 활용**: 공식 소스 우선 검색 시 `brave_web_search` 사용 (도메인 필터 예: `site:anthropic.com`, `site:openai.com`)
- **필수 확인 소스** (WebFetch 직접 접속):
  - `https://www.anthropic.com/news` — Anthropic 공식 뉴스/블로그
  - `https://docs.anthropic.com/en/docs/changelog` — Claude API 변경 로그
  - `https://www.anthropic.com/engineering` — 엔지니어링 블로그
- 3개 카테고리별 뉴스 + 신뢰도 표기 + 출처 + 액션 아이템
- 파일 직접 저장: `01-research/weekly/{date}/tech-trends.md`
- 저장 완료 후 종료

**Subagent B (model: haiku): 비즈니스 뉴스 수집**

프롬프트에 아래를 포함하여 스폰:
- 분석 기준 날짜: `$ARGUMENTS`
- WebSearch: SaaS/스타트업, 인디해커/1인기업, Product Hunt
- **Brave Search 활용**: `brave_web_search`로 SaaS/스타트업 동향 검색. 예: `site:indiehackers.com`, `site:producthunt.com`, `site:techcrunch.com SaaS 2026`
- 시장 동향 + 과금 모델 변화 + 성공 사례 + 액션 아이템
- 파일 직접 저장: `01-research/weekly/{date}/biz-trends.md`
- 저장 완료 후 종료

**Subagent C (model: sonnet): 사업 아이템 조사 + 분석**

프롬프트에 아래를 포함하여 스폰:
- 분석 기준 날짜: `$ARGUMENTS`
- WebSearch: 시장 데이터, 경쟁사, 성공 사례
- **Brave Search 활용**: `brave_web_search`로 시장 데이터/경쟁사 검색. 예: `TAM SAM SOM {아이템}`, `site:crunchbase.com`, `{아이템} market size 2026`
- SIGIL S1 방법론 적용: 경쟁 가설 3개 → TAM/SAM/SOM → JTBD → 최종 1개 선정
- 실행 로드맵 (MVP, 기술 스택, 타임라인)
- 선정 기준: **1인 개발자가 내달 1,000만원+ 수익 달성 가능성**
- 프로젝트명 자동 결정 → `sigil-workspace.json` 등록 확인
- 파일 직접 저장: `01-research/projects/{project}/{date}-s1-research.md`
- `gate-log.md`에 S1 PASS 기록
- 저장 완료 후 종료

### Wave 2 (Lead 취합 — Wave 1 완료 후)

3개 Subagent 완료 확인 후:
1. 3종 파일 존재 여부 확인 (`01-research/weekly/{date}/`, `01-research/projects/`)
2. 주간 요약 보고: 파일 경로, 사업 아이템 제목, 신뢰도 분포
3. 누락 파일 있으면 해당 Subagent 재스폰

### Wave 3 (Notion 자동 등록 + Portfolio 블로그 발행 — Wave 2 완료 후)

3종 파일 작성 완료 후, 아래 2개를 순차 실행한다.

**Step 1: Portfolio 블로그 자동 발행**

tech-trends.md 내용을 Portfolio 블로그에 자동 발행한다.

- 엔드포인트: `POST {PORTFOLIO_API_URL}/api/v1/blog/auto-publish`
- 인증: `X-API-Key` 헤더 (환경변수 `AUTO_PUBLISH_API_KEY`)
- DTO:
  - `title`: "{date} 주간 기술 트렌드"
  - `content`: tech-trends.md 전체 내용
  - `category`: "tech" (또는 블로그 카테고리에 맞게)
  - `tags`: ["weekly", "tech-trends", "AI"]
  - `excerpt`: tech-trends.md 첫 2-3문장 요약
- 성공 시: 블로그 발행 = "발행완료"
- 실패 시: 경고 출력 후 블로그 발행 = "발행실패" (파이프라인 중단 안 함)

**⚠️ Portfolio API 서버 미기동 시**: 경고만 출력하고 스킵. 블로그 발행 = "미발행".

**Step 2: Notion DB 자동 등록**

Notion "Weekly Research" DB에 페이지를 자동 생성한다.

**Notion DB 정보:**
- Data Source ID: `d7ba2bc1-4c7b-400d-872f-8d78bfeea213`
- DB URL: `https://www.notion.so/8023d8cc603d48e3b6f99e95739457fd`

**`mcp__notion__notion-create-pages` 호출:**

```json
{
  "parent": { "data_source_id": "d7ba2bc1-4c7b-400d-872f-8d78bfeea213" },
  "pages": [{
    "properties": {
      "제목": "{date} 주간 리서치",
      "요약": "{tech-trends 핵심 3줄 + biz-trends 핵심 3줄}",
      "date:날짜:start": "{date}",
      "상태": "완료",
      "기술 트렌드": "{tech-trends.md 핵심 뉴스 Top 3 요약}",
      "비즈니스 트렌드": "{biz-trends.md 핵심 뉴스 Top 3 요약}",
      "사업 아이템": "{선정된 사업 아이템 제목}",
      "블로그 발행": "{Step 1 결과: 발행완료/발행실패/미발행}",
      "tech-trends 경로": "01-research/weekly/{date}/tech-trends.md",
      "biz-trends 경로": "01-research/weekly/{date}/biz-trends.md",
      "s1-research 경로": "01-research/projects/{project}/{date}-s1-research.md"
    },
    "content": "## 기술 트렌드 요약\n{tech-trends 핵심 항목}\n\n## 비즈니스 트렌드 요약\n{biz-trends 핵심 항목}\n\n## 사업 아이템\n{선정 아이템 1줄 요약 + 선정 근거}"
  }]
}
```

**속성 값 추출 규칙:**
- 요약: tech-trends + biz-trends 각 핵심 3줄 합산
- 기술/비즈니스 트렌드: 각 파일의 Top 3 뉴스 항목 1줄씩
- 사업 아이템: s1-research에서 최종 선정된 아이템명
- 블로그 발행: Step 1 결과 반영
- content: Notion에서 빠르게 읽을 수 있는 분량으로 핵심만 포함

**실패 처리:**
- Notion MCP 미연결 시 경고 출력 후 스킵 (리포트 파일은 이미 저장됨)
- 페이지 생성 실패 시 에러 로그 출력 후 스킵 (파이프라인 중단 안 함)

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
