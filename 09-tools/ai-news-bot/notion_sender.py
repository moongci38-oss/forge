"""Notion API 연동 모듈 — 데이터베이스 자동 생성 + 주간 리포트 페이지 추가"""

import httpx
from datetime import datetime

from config import (
    NOTION_API_KEY,
    NOTION_DATABASE_ID,
    NOTION_PARENT_PAGE_ID,
    REQUEST_TIMEOUT,
    get_report_period,
)

NOTION_API_URL = "https://api.notion.com/v1"
NOTION_VERSION = "2022-06-28"


def _headers() -> dict:
    """Notion API 공통 헤더"""
    if not NOTION_API_KEY:
        raise ValueError("NOTION_API_KEY 환경변수가 설정되지 않았습니다")
    return {
        "Authorization": f"Bearer {NOTION_API_KEY}",
        "Content-Type": "application/json",
        "Notion-Version": NOTION_VERSION,
    }


# ── 데이터베이스 생성 ──────────────────────────────────


def create_database(parent_page_id: str) -> str:
    """AI 주간 뉴스 데이터베이스를 Notion 페이지 하위에 생성

    Args:
        parent_page_id: 데이터베이스를 만들 상위 페이지 ID

    Returns:
        생성된 데이터베이스 ID
    """
    payload = {
        "parent": {"type": "page_id", "page_id": parent_page_id},
        "icon": {"type": "emoji", "emoji": "🤖"},
        "title": [{"type": "text", "text": {"content": "AI 주간 뉴스"}}],
        "properties": {
            "이름": {"title": {}},
            "기간": {"rich_text": {}},
            "날짜": {"date": {}},
            "Tech 건수": {"number": {"format": "number"}},
            "Business 건수": {"number": {"format": "number"}},
            "상태": {
                "select": {
                    "options": [
                        {"name": "Published", "color": "green"},
                        {"name": "Draft", "color": "yellow"},
                    ]
                }
            },
            "소스": {
                "multi_select": {
                    "options": [
                        {"name": "HackerNews", "color": "orange"},
                        {"name": "arXiv", "color": "red"},
                        {"name": "Google News", "color": "blue"},
                        {"name": "Reddit", "color": "purple"},
                    ]
                }
            },
        },
    }

    resp = httpx.post(
        f"{NOTION_API_URL}/databases",
        headers=_headers(),
        json=payload,
        timeout=REQUEST_TIMEOUT,
    )
    resp.raise_for_status()
    db_id = resp.json()["id"]
    print(f"[Notion] 데이터베이스 생성 완료: {db_id}")
    return db_id


# ── Notion Block 변환 ──────────────────────────────────


def _heading2(text: str) -> dict:
    return {
        "object": "block",
        "type": "heading_2",
        "heading_2": {
            "rich_text": [{"type": "text", "text": {"content": text}}]
        },
    }


def _heading3(text: str) -> dict:
    return {
        "object": "block",
        "type": "heading_3",
        "heading_3": {
            "rich_text": [{"type": "text", "text": {"content": text}}]
        },
    }


def _bookmark(url: str, caption: str = "") -> dict:
    block = {
        "object": "block",
        "type": "bookmark",
        "bookmark": {"url": url},
    }
    if caption:
        block["bookmark"]["caption"] = [
            {"type": "text", "text": {"content": caption}}
        ]
    return block


def _bulleted_item(text: str, url: str = "") -> dict:
    """링크가 있으면 텍스트+링크 조합, 없으면 텍스트만"""
    if url:
        rich_text = [
            {"type": "text", "text": {"content": text, "link": {"url": url}}}
        ]
    else:
        rich_text = [{"type": "text", "text": {"content": text}}]
    return {
        "object": "block",
        "type": "bulleted_list_item",
        "bulleted_list_item": {"rich_text": rich_text},
    }


def _numbered_item(text: str, url: str = "") -> dict:
    if url:
        rich_text = [
            {"type": "text", "text": {"content": text, "link": {"url": url}}}
        ]
    else:
        rich_text = [{"type": "text", "text": {"content": text}}]
    return {
        "object": "block",
        "type": "numbered_list_item",
        "numbered_list_item": {"rich_text": rich_text},
    }


def _divider() -> dict:
    return {"object": "block", "type": "divider", "divider": {}}


def _paragraph(text: str) -> dict:
    return {
        "object": "block",
        "type": "paragraph",
        "paragraph": {
            "rich_text": [{"type": "text", "text": {"content": text}}]
        },
    }


def _callout(text: str, emoji: str = "💡") -> dict:
    return {
        "object": "block",
        "type": "callout",
        "callout": {
            "rich_text": [{"type": "text", "text": {"content": text}}],
            "icon": {"type": "emoji", "emoji": emoji},
        },
    }


# ── 리포트 → Notion Blocks 변환 ──────────────────────


def _format_item_text(item: dict) -> str:
    """아이템을 한 줄 텍스트로 포맷"""
    title = item.get("title", "제목 없음")
    extras = []

    if item.get("source") and item["source"] not in ("HackerNews", "arXiv"):
        extras.append(item["source"])
    if item.get("authors"):
        extras.append(f"✍️ {item['authors']}")
    if item.get("score"):
        extras.append(f"⬆{item['score']}")
    if item.get("comments"):
        extras.append(f"💬{item['comments']}")

    suffix = f" — {', '.join(extras)}" if extras else ""
    return f"{title}{suffix}"


def build_notion_blocks(collected_data: dict) -> list:
    """수집 데이터를 Notion 블록 배열로 변환 (통합 리포트)"""
    period = get_report_period()
    blocks = []

    blocks.append(_callout(f"📅 {period['range_str']}", "📰"))

    # ── 기술 동향 ──
    blocks.append(_heading2("🔬 기술 동향"))

    arxiv_items = collected_data.get("arxiv", {}).get("tech", [])
    if arxiv_items:
        blocks.append(_heading3("📑 주요 논문 (arXiv)"))
        for item in arxiv_items[:5]:
            blocks.append(_numbered_item(_format_item_text(item), item.get("url", "")))

    hn_tech = collected_data.get("hackernews", {}).get("tech", [])
    if hn_tech:
        blocks.append(_heading3("💻 HackerNews 인기 AI 토픽"))
        for item in hn_tech[:5]:
            blocks.append(_numbered_item(_format_item_text(item), item.get("url", "")))

    gn_tech = collected_data.get("google_news", {}).get("tech", [])
    if gn_tech:
        blocks.append(_heading3("🔧 기술 뉴스"))
        for item in gn_tech[:5]:
            blocks.append(_numbered_item(_format_item_text(item), item.get("url", "")))

    reddit_tech = collected_data.get("reddit", {}).get("tech", [])
    if reddit_tech:
        blocks.append(_heading3("🧪 커뮤니티 (Reddit)"))
        for item in reddit_tech[:5]:
            blocks.append(_numbered_item(_format_item_text(item), item.get("url", "")))

    blocks.append(_divider())

    # ── 비즈니스 동향 ──
    blocks.append(_heading2("💼 비즈니스 동향"))

    gn_biz = collected_data.get("google_news", {}).get("business", [])
    if gn_biz:
        blocks.append(_heading3("📰 주요 비즈니스 뉴스"))
        for item in gn_biz[:5]:
            blocks.append(_numbered_item(_format_item_text(item), item.get("url", "")))

    hn_biz = collected_data.get("hackernews", {}).get("business", [])
    if hn_biz:
        blocks.append(_heading3("🚀 HackerNews 비즈니스 토픽"))
        for item in hn_biz[:5]:
            blocks.append(_numbered_item(_format_item_text(item), item.get("url", "")))

    reddit_biz = collected_data.get("reddit", {}).get("business", [])
    if reddit_biz:
        blocks.append(_heading3("💡 커뮤니티 비즈니스 토픽"))
        for item in reddit_biz[:5]:
            blocks.append(_numbered_item(_format_item_text(item), item.get("url", "")))

    # 데이터가 전혀 없는 경우
    if not any([gn_biz, hn_biz, reddit_biz]):
        blocks.append(_paragraph("이번 주 수집된 비즈니스 뉴스가 없습니다."))

    blocks.append(_divider())
    blocks.append(_paragraph("🤖 자동 생성: AI News Bot"))

    return blocks


# ── 페이지 추가 ──────────────────────────────────────


def _count_items(collected_data: dict, category: str) -> int:
    """특정 카테고리의 총 아이템 수 계산"""
    return sum(len(v.get(category, [])) for v in collected_data.values())


def _active_sources(collected_data: dict) -> list[str]:
    """실제 데이터가 있는 소스 이름 목록"""
    source_map = {
        "hackernews": "HackerNews",
        "arxiv": "arXiv",
        "google_news": "Google News",
        "reddit": "Reddit",
    }
    sources = []
    for key, name in source_map.items():
        data = collected_data.get(key, {})
        total = len(data.get("tech", [])) + len(data.get("business", []))
        if total > 0:
            sources.append(name)
    return sources


def add_report_to_database(database_id: str, collected_data: dict) -> str:
    """주간 리포트를 Notion 데이터베이스에 페이지로 추가

    Args:
        database_id: 대상 데이터베이스 ID
        collected_data: 수집된 뉴스 데이터

    Returns:
        생성된 페이지 URL
    """
    period = get_report_period()
    blocks = build_notion_blocks(collected_data)

    # Notion API는 한 번에 최대 100개 블록만 허용
    blocks_chunk = blocks[:100]

    tech_count = _count_items(collected_data, "tech")
    biz_count = _count_items(collected_data, "business")
    sources = _active_sources(collected_data)

    payload = {
        "parent": {"database_id": database_id},
        "icon": {"type": "emoji", "emoji": "📰"},
        "properties": {
            "이름": {
                "title": [
                    {
                        "type": "text",
                        "text": {"content": f"{period['label']} AI 주간 뉴스"},
                    }
                ]
            },
            "기간": {
                "rich_text": [
                    {"type": "text", "text": {"content": period["range_str"]}}
                ]
            },
            "날짜": {
                "date": {"start": period["end"].strftime("%Y-%m-%d")}
            },
            "Tech 건수": {"number": tech_count},
            "Business 건수": {"number": biz_count},
            "상태": {"select": {"name": "Published"}},
            "소스": {
                "multi_select": [{"name": s} for s in sources]
            },
        },
        "children": blocks_chunk,
    }

    print("[Notion] 페이지 생성 중...")
    resp = httpx.post(
        f"{NOTION_API_URL}/pages",
        headers=_headers(),
        json=payload,
        timeout=30,
    )

    if not resp.is_success:
        error_body = resp.text
        print(f"[Notion] 페이지 생성 실패 ({resp.status_code}): {error_body}")
        resp.raise_for_status()

    page = resp.json()
    page_url = page.get("url", "")
    print(f"[Notion] 페이지 생성 완료: {page_url}")

    # 100개 초과 블록이 있으면 추가 append
    if len(blocks) > 100:
        page_id = page["id"]
        remaining = blocks[100:]
        for i in range(0, len(remaining), 100):
            chunk = remaining[i : i + 100]
            httpx.patch(
                f"{NOTION_API_URL}/blocks/{page_id}/children",
                headers=_headers(),
                json={"children": chunk},
                timeout=30,
            ).raise_for_status()

    return page_url


# ── 초기 설정 (최초 1회) ──────────────────────────────


def setup_database() -> str:
    """데이터베이스 자동 생성 (NOTION_PARENT_PAGE_ID 필요)

    Returns:
        생성된 데이터베이스 ID
    """
    if not NOTION_PARENT_PAGE_ID:
        raise ValueError(
            "NOTION_PARENT_PAGE_ID 환경변수가 필요합니다.\n"
            "Notion에서 데이터베이스를 만들 페이지를 열고 URL에서 ID를 복사하세요.\n"
            "예: https://notion.so/My-Page-abc123def456 → abc123def456"
        )

    print("[Notion] 새 데이터베이스 생성 중...")
    db_id = create_database(NOTION_PARENT_PAGE_ID)
    print(f"\n✅ 데이터베이스가 생성되었습니다!")
    print(f"   DB ID: {db_id}")
    print(f"\n   .env 파일에 추가하세요:")
    print(f"   NOTION_DATABASE_ID={db_id}")
    return db_id
