"""Google News RSS 수집기 — AI 관련 뉴스 수집

feedparser 대신 xml.etree.ElementTree 사용 (외부 의존성 제거)
"""

import httpx
import xml.etree.ElementTree as ET
from email.utils import parsedate_to_datetime

from config import MAX_ITEMS_PER_SOURCE, REQUEST_TIMEOUT, USER_AGENT

# Google News RSS 피드 URL
GOOGLE_NEWS_RSS = "https://news.google.com/rss/search?q={query}&hl=en-US&gl=US&ceid=US:en"

TECH_QUERIES = [
    "artificial intelligence technology",
    "LLM AI model release",
    "open source AI",
]

BUSINESS_QUERIES = [
    "AI startup funding",
    "AI business acquisition",
    "generative AI market",
    "AI SaaS product launch",
]


def _parse_rss_item(item_elem) -> dict:
    """RSS <item> XML 엘리먼트를 파싱"""
    title = (item_elem.findtext("title") or "").strip()
    link = (item_elem.findtext("link") or "").strip()
    pub_date = (item_elem.findtext("pubDate") or "").strip()

    # 소스 (Google News RSS에서 <source> 태그)
    source_elem = item_elem.find("source")
    source = source_elem.text.strip() if source_elem is not None and source_elem.text else "Google News"

    # 날짜 파싱
    date_str = ""
    if pub_date:
        try:
            dt = parsedate_to_datetime(pub_date)
            date_str = dt.strftime("%Y-%m-%d")
        except Exception:
            date_str = pub_date[:10]

    return {
        "title": title,
        "url": link,
        "date": date_str,
        "source": source,
    }


def _fetch_feed(query: str) -> list:
    """Google News RSS 피드에서 뉴스 수집"""
    items = []
    try:
        url = GOOGLE_NEWS_RSS.format(query=query.replace(" ", "+"))
        resp = httpx.get(
            url,
            headers={"User-Agent": USER_AGENT},
            timeout=REQUEST_TIMEOUT,
            follow_redirects=True,
        )
        resp.raise_for_status()

        root = ET.fromstring(resp.text)
        channel = root.find("channel")
        if channel is None:
            return items

        for item_elem in channel.findall("item")[:MAX_ITEMS_PER_SOURCE]:
            item = _parse_rss_item(item_elem)
            if item["title"]:
                items.append(item)

    except Exception as e:
        print(f"[GoogleNews] '{query}' 수집 실패: {e}")

    return items


def collect_google_news() -> dict:
    """Google News RSS에서 AI 뉴스 수집

    Returns:
        {"tech": [...], "business": [...]}
    """
    tech_items = []
    business_items = []
    seen_titles = set()

    # 기술 뉴스
    for query in TECH_QUERIES:
        for item in _fetch_feed(query):
            if item["title"] not in seen_titles:
                seen_titles.add(item["title"])
                tech_items.append(item)

    # 비즈니스 뉴스
    for query in BUSINESS_QUERIES:
        for item in _fetch_feed(query):
            if item["title"] not in seen_titles:
                seen_titles.add(item["title"])
                business_items.append(item)

    return {
        "tech": tech_items[:MAX_ITEMS_PER_SOURCE],
        "business": business_items[:MAX_ITEMS_PER_SOURCE],
    }
