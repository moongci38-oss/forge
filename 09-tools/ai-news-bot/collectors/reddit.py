"""Reddit 수집기 — AI 관련 서브레딧 인기 포스트 수집"""

import httpx
from datetime import datetime, timezone

from config import (
    TECH_SUBREDDITS,
    BUSINESS_SUBREDDITS,
    MAX_ITEMS_PER_SOURCE,
    REQUEST_TIMEOUT,
    USER_AGENT,
)

REDDIT_URL = "https://www.reddit.com/r/{subreddit}/top.json"


def _fetch_subreddit(subreddit: str) -> list:
    """서브레딧에서 주간 인기 포스트 수집"""
    items = []
    try:
        resp = httpx.get(
            REDDIT_URL.format(subreddit=subreddit),
            params={"t": "week", "limit": MAX_ITEMS_PER_SOURCE},
            headers={"User-Agent": USER_AGENT},
            timeout=REQUEST_TIMEOUT,
            follow_redirects=True,
        )
        resp.raise_for_status()
        data = resp.json()

        for post in data.get("data", {}).get("children", []):
            post_data = post.get("data", {})

            # 셀프포스트이면 Reddit URL, 아니면 원본 URL
            url = post_data.get("url", "")
            if post_data.get("is_self"):
                url = f"https://reddit.com{post_data.get('permalink', '')}"

            created_utc = post_data.get("created_utc", 0)
            date_str = ""
            if created_utc:
                dt = datetime.fromtimestamp(created_utc, tz=timezone.utc)
                date_str = dt.strftime("%Y-%m-%d")

            items.append({
                "title": post_data.get("title", ""),
                "url": url,
                "score": post_data.get("score", 0),
                "comments": post_data.get("num_comments", 0),
                "subreddit": subreddit,
                "date": date_str,
                "source": f"r/{subreddit}",
            })

    except Exception as e:
        print(f"[Reddit] r/{subreddit} 수집 실패: {e}")

    return items


def collect_reddit() -> dict:
    """Reddit에서 AI 관련 인기 포스트 수집

    Returns:
        {"tech": [...], "business": [...]}
    """
    tech_items = []
    business_items = []

    for sub in TECH_SUBREDDITS:
        tech_items.extend(_fetch_subreddit(sub))

    for sub in BUSINESS_SUBREDDITS:
        business_items.extend(_fetch_subreddit(sub))

    # 점수순 정렬
    tech_items.sort(key=lambda x: x["score"], reverse=True)
    business_items.sort(key=lambda x: x["score"], reverse=True)

    return {
        "tech": tech_items[:MAX_ITEMS_PER_SOURCE],
        "business": business_items[:MAX_ITEMS_PER_SOURCE],
    }
