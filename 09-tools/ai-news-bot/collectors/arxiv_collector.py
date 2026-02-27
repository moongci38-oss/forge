"""arXiv API 수집기 — 최신 AI 논문 수집"""

import httpx
import xml.etree.ElementTree as ET
from datetime import datetime

from config import ARXIV_CATEGORIES, MAX_ITEMS_PER_SOURCE, REQUEST_TIMEOUT

ARXIV_API_URL = "http://export.arxiv.org/api/query"


def _parse_arxiv_entry(entry, ns):
    """arXiv XML 엔트리를 파싱"""
    title = entry.findtext(f"{ns}title", "").replace("\n", " ").strip()
    summary = entry.findtext(f"{ns}summary", "").replace("\n", " ").strip()
    published = entry.findtext(f"{ns}published", "")
    arxiv_id = entry.findtext(f"{ns}id", "")

    # 대표 저자 (최대 3명)
    authors = []
    for author in entry.findall(f"{ns}author"):
        name = author.findtext(f"{ns}name", "")
        if name:
            authors.append(name)
    authors_str = ", ".join(authors[:3])
    if len(authors) > 3:
        authors_str += f" 외 {len(authors) - 3}명"

    # 카테고리 태그
    categories = []
    for cat in entry.findall("{http://www.w3.org/2005/Atom}category"):
        term = cat.get("term", "")
        if term:
            categories.append(term)

    # 요약 (첫 150자)
    short_summary = summary[:150] + "..." if len(summary) > 150 else summary

    return {
        "title": title,
        "url": arxiv_id,
        "authors": authors_str,
        "summary": short_summary,
        "date": published[:10] if published else "",
        "categories": categories,
        "source": "arXiv",
    }


def collect_arxiv() -> dict:
    """arXiv에서 최신 AI/ML 논문 수집

    Returns:
        {"tech": [...]} — 논문은 모두 tech 카테고리
    """
    items = []

    try:
        cat_query = " OR ".join(f"cat:{cat}" for cat in ARXIV_CATEGORIES)
        resp = httpx.get(
            ARXIV_API_URL,
            params={
                "search_query": cat_query,
                "sortBy": "submittedDate",
                "sortOrder": "descending",
                "max_results": MAX_ITEMS_PER_SOURCE * 2,
            },
            timeout=REQUEST_TIMEOUT,
        )
        resp.raise_for_status()

        root = ET.fromstring(resp.text)
        ns = "{http://www.w3.org/2005/Atom}"

        for entry in root.findall(f"{ns}entry"):
            item = _parse_arxiv_entry(entry, ns)
            if item["title"]:
                items.append(item)

    except Exception as e:
        print(f"[arXiv] 수집 실패: {e}")

    return {"tech": items[:MAX_ITEMS_PER_SOURCE]}
