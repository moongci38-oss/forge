# 웹 검색 도구 정책

## 핵심 규칙

**내장 `WebSearch` 도구 사용 금지.** 성능이 낮고 도구 간 오버랩을 유발함.

## 승인된 검색 도구 (우선순위순)

1. **`mcp__tavily__tavily_search`** — 일반 웹 검색, 뉴스, 도메인 필터링
2. **`mcp__tavily__tavily_research`** — 다중 소스 심층 리서치 (mini/pro/auto depth)
3. **`mcp__tavily__tavily_extract`** — 특정 URL 콘텐츠 추출
4. **`mcp__exa__search`** — 시맨틱/의미 기반 검색 (AI 에이전트 최적화)
5. **`mcp__brave-search__brave_web_search`** — fallback (Tavily/Exa 한도 소진 시)

## 도구 선택 기준

| 상황 | 사용 도구 |
|------|---------|
| 일반 키워드 검색 | tavily_search |
| 심층 주제 리서치 | tavily_research (pro) |
| 특정 URL 읽기 | tavily_extract 또는 WebFetch |
| 의미 기반 검색 | exa search |
| Tavily 한도 소진 | brave_web_search |

## 에러 처리

Tavily 리퀘스트 한도 소진 에러 발생 시 즉시 중단, Brave fallback으로 전환.
에러 메시지는 항상 컨텍스트에 유지 (억제 금지).
