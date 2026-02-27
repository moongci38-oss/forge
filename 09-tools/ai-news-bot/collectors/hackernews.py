"""HackerNews API 수집기 — AI 관련 인기 스토리 수집"""

import httpx
from datetime import datetime, timezone

from config import (
    MAX_ITEMS_PER_SOURCE,
    REQUEST_TIMEOUT,
    TECH_KEYWORDS,
    BUSINESS_KEYWORDS,
)

HN_TOP_URL = "https://hacker-news.firebaseio.com/v0/topstories.json"
HN_ITEM_URL = "https://hacker-news.firebaseio.com/v0/item/{}.json"
HN_SEARCH_URL = "https://hn.algolia.com/api/v1/search_by_date"


def _is_ai_related(title: str) -> str | None:
    """제목이 AI 관련인지 확인하고 카테고리 반환 (tech/business/None)"""
    title_lower = title.lower()

    tech_matches = sum(1 for kw in TECH_KEYWORDS if kw.lower() in title_lower)
    biz_matches = sum(1 for kw in BUSINESS_KEYWORDS if kw.lower() in title_lower)

    # 비즈니스 키워드 우선 매칭
    if biz_matches > 0 and biz_matches >= tech_matches:
        return "business"
    if tech_matches > 0:
        return "tech"
    return None


def collect_hackernews() -> dict:
    """HackerNews에서 AI 관련 인기 스토리 수집

    Returns:
        {"tech": [...], "business": [...]} 형태의 딕셔너리
    """
    tech_items = []
    business_items = []

    try:
        # Algolia HN Search API 사용 (더 효율적)
        ai_queries = ["AI", "LLM", "GPT", "Claude", "machine learning", "artificial intelligence"]

        seen_ids = set()

        for query in ai_queries:
            if len(tech_items) + len(business_items) >= MAX_ITEMS_PER_SOURCE * 2:
                break

            resp = httpx.get(
                HN_SEARCH_URL,
                params={
                    "query": query,
                    "tags": "story",
                    "numericFilters": "points>20",
                    "hitsPerPage": 15,
                },
                timeout=REQUEST_TIMEOUT,
            )
            resp.raise_for_status()
            data = resp.json()

            for hit in data.get("hits", []):
                story_id = hit.get("objectID")
                if story_id in seen_ids:
                    continue
                seen_ids.add(story_id)

                title = hit.get("title", "")
                category = _is_ai_related(title)
                if not category:
                    # 검색 결과이므로 AI 관련이라고 간주, tech로 분류
                    category = "tech"

                item = {
                    "title": title,
                    "url": hit.get("url") or f"https://news.ycombinator.com/item?id={story_id}",
                    "score": hit.get("points", 0),
                    "comments": hit.get("num_comments", 0),
                    "source": "HackerNews",
                    "date": hit.get("created_at", ""),
                }

                if category == "business":
                    business_items.append(item)
                else:
                    tech_items.append(item)

        # 점수순 정렬 후 상위 항목만
        tech_items.sort(key=lambda x: x["score"], reverse=True)
        business_items.sort(key=lambda x: x["score"], reverse=True)

    except Exception as e:
        print(f"[HackerNews] 수집 실패: {e}")

    return {
        "tech": tech_items[:MAX_ITEMS_PER_SOURCE],
        "business": business_items[:MAX_ITEMS_PER_SOURCE],
    }
