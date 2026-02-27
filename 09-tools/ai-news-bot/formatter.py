"""텔레그램 리포트 포맷터 — 수집된 뉴스를 한국어 Telegram 메시지로 변환"""

from config import TELEGRAM_MAX_LENGTH, get_report_period


def _escape_markdown(text: str) -> str:
    """Telegram MarkdownV2 특수문자 이스케이프"""
    special_chars = r"_*[]()~`>#+-=|{}.!"
    result = ""
    for char in text:
        if char in special_chars:
            result += f"\\{char}"
        else:
            result += char
    return result


def _truncate_title(title: str, max_len: int = 80) -> str:
    """제목 길이 제한"""
    if len(title) <= max_len:
        return title
    return title[: max_len - 3] + "..."


def _format_hn_item(item: dict, idx: int) -> str:
    """HackerNews 아이템 포맷"""
    title = _escape_markdown(_truncate_title(item["title"]))
    url = item["url"]
    score = item.get("score", 0)
    comments = item.get("comments", 0)
    return f"{idx}\\. [{title}]({url})\n   ⬆ {score} \\| 💬 {comments}"


def _format_arxiv_item(item: dict, idx: int) -> str:
    """arXiv 논문 아이템 포맷"""
    title = _escape_markdown(_truncate_title(item["title"]))
    url = item["url"]
    authors = _escape_markdown(item.get("authors", ""))
    return f"{idx}\\. [{title}]({url})\n   ✍️ {authors}"


def _format_news_item(item: dict, idx: int) -> str:
    """일반 뉴스 아이템 포맷"""
    title = _escape_markdown(_truncate_title(item["title"]))
    url = item["url"]
    source = _escape_markdown(item.get("source", ""))
    return f"{idx}\\. [{title}]({url})\n   📰 {source}"


def _format_reddit_item(item: dict, idx: int) -> str:
    """Reddit 아이템 포맷"""
    title = _escape_markdown(_truncate_title(item["title"]))
    url = item["url"]
    score = item.get("score", 0)
    sub = _escape_markdown(item.get("source", ""))
    return f"{idx}\\. [{title}]({url})\n   ⬆ {score} \\| {sub}"


def format_tech_report(collected_data: dict) -> str:
    """기술 리포트 텔레그램 메시지 생성

    Args:
        collected_data: {
            "hackernews": {"tech": [...]},
            "arxiv": {"tech": [...]},
            "google_news": {"tech": [...]},
            "reddit": {"tech": [...]}
        }
    """
    period = get_report_period()
    lines = []

    # 헤더
    lines.append(f"🔬 *AI 기술 위클리 — {_escape_markdown(period['label'])}*")
    lines.append(f"📅 {_escape_markdown(period['range_str'])}")
    lines.append("")

    # arXiv 논문
    arxiv_items = collected_data.get("arxiv", {}).get("tech", [])
    if arxiv_items:
        lines.append("📑 *주요 논문 \\(arXiv\\)*")
        for i, item in enumerate(arxiv_items[:5], 1):
            lines.append(_format_arxiv_item(item, i))
        lines.append("")

    # HackerNews
    hn_items = collected_data.get("hackernews", {}).get("tech", [])
    if hn_items:
        lines.append("💻 *HackerNews 인기 AI 토픽*")
        for i, item in enumerate(hn_items[:5], 1):
            lines.append(_format_hn_item(item, i))
        lines.append("")

    # Google News (Tech)
    gn_items = collected_data.get("google_news", {}).get("tech", [])
    if gn_items:
        lines.append("🔧 *기술 뉴스*")
        for i, item in enumerate(gn_items[:5], 1):
            lines.append(_format_news_item(item, i))
        lines.append("")

    # Reddit
    reddit_items = collected_data.get("reddit", {}).get("tech", [])
    if reddit_items:
        lines.append("🧪 *커뮤니티 인기 토픽*")
        for i, item in enumerate(reddit_items[:5], 1):
            lines.append(_format_reddit_item(item, i))
        lines.append("")

    # 푸터
    lines.append("─" * 20)
    lines.append("🤖 _AI News Bot \\| 매주 월요일 자동 발송_")

    message = "\n".join(lines)

    # 길이 제한 처리
    if len(message) > TELEGRAM_MAX_LENGTH:
        message = message[: TELEGRAM_MAX_LENGTH - 50] + "\n\n\\.\\.\\. _\\(일부 생략\\)_"

    return message


def format_business_report(collected_data: dict) -> str:
    """비즈니스 리포트 텔레그램 메시지 생성"""
    period = get_report_period()
    lines = []

    # 헤더
    lines.append(f"💼 *AI 비즈니스 위클리 — {_escape_markdown(period['label'])}*")
    lines.append(f"📅 {_escape_markdown(period['range_str'])}")
    lines.append("")

    # Google News (Business)
    gn_items = collected_data.get("google_news", {}).get("business", [])
    if gn_items:
        lines.append("📰 *주요 비즈니스 뉴스*")
        for i, item in enumerate(gn_items[:5], 1):
            lines.append(_format_news_item(item, i))
        lines.append("")

    # HackerNews (Business)
    hn_items = collected_data.get("hackernews", {}).get("business", [])
    if hn_items:
        lines.append("🚀 *HackerNews 비즈니스 토픽*")
        for i, item in enumerate(hn_items[:5], 1):
            lines.append(_format_hn_item(item, i))
        lines.append("")

    # Reddit (Business)
    reddit_items = collected_data.get("reddit", {}).get("business", [])
    if reddit_items:
        lines.append("💡 *커뮤니티 비즈니스 토픽*")
        for i, item in enumerate(reddit_items[:5], 1):
            lines.append(_format_reddit_item(item, i))
        lines.append("")

    # 데이터가 전혀 없는 경우
    if not any([gn_items, hn_items, reddit_items]):
        lines.append("_이번 주 수집된 비즈니스 뉴스가 없습니다\\._")
        lines.append("")

    # 푸터
    lines.append("─" * 20)
    lines.append("🤖 _AI News Bot \\| 매주 월요일 자동 발송_")

    message = "\n".join(lines)

    if len(message) > TELEGRAM_MAX_LENGTH:
        message = message[: TELEGRAM_MAX_LENGTH - 50] + "\n\n\\.\\.\\. _\\(일부 생략\\)_"

    return message


def format_archive_report(collected_data: dict) -> str:
    """아카이브용 Markdown 리포트 (01-research/weekly/ 저장용)

    Telegram 마크다운이 아닌 일반 Markdown 형식
    """
    period = get_report_period()
    lines = []

    lines.append(f"# {period['label']} AI 주간 리포트")
    lines.append(f"기간: {period['range_str']}")
    lines.append("")

    # --- Tech Section ---
    lines.append("## 🔬 기술 동향")
    lines.append("")

    arxiv_items = collected_data.get("arxiv", {}).get("tech", [])
    if arxiv_items:
        lines.append("### 주요 논문 (arXiv)")
        for i, item in enumerate(arxiv_items[:5], 1):
            lines.append(f"{i}. [{item['title']}]({item['url']})")
            if item.get("authors"):
                lines.append(f"   - 저자: {item['authors']}")
        lines.append("")

    hn_tech = collected_data.get("hackernews", {}).get("tech", [])
    if hn_tech:
        lines.append("### HackerNews 인기 AI 토픽")
        for i, item in enumerate(hn_tech[:5], 1):
            lines.append(f"{i}. [{item['title']}]({item['url']}) — ⬆{item.get('score', 0)}")
        lines.append("")

    gn_tech = collected_data.get("google_news", {}).get("tech", [])
    if gn_tech:
        lines.append("### 기술 뉴스")
        for i, item in enumerate(gn_tech[:5], 1):
            lines.append(f"{i}. [{item['title']}]({item['url']}) — {item.get('source', '')}")
        lines.append("")

    reddit_tech = collected_data.get("reddit", {}).get("tech", [])
    if reddit_tech:
        lines.append("### 커뮤니티 (Reddit)")
        for i, item in enumerate(reddit_tech[:5], 1):
            lines.append(f"{i}. [{item['title']}]({item['url']}) — {item.get('source', '')}")
        lines.append("")

    # --- Business Section ---
    lines.append("## 💼 비즈니스 동향")
    lines.append("")

    gn_biz = collected_data.get("google_news", {}).get("business", [])
    if gn_biz:
        lines.append("### 주요 비즈니스 뉴스")
        for i, item in enumerate(gn_biz[:5], 1):
            lines.append(f"{i}. [{item['title']}]({item['url']}) — {item.get('source', '')}")
        lines.append("")

    hn_biz = collected_data.get("hackernews", {}).get("business", [])
    if hn_biz:
        lines.append("### HackerNews 비즈니스 토픽")
        for i, item in enumerate(hn_biz[:5], 1):
            lines.append(f"{i}. [{item['title']}]({item['url']}) — ⬆{item.get('score', 0)}")
        lines.append("")

    reddit_biz = collected_data.get("reddit", {}).get("business", [])
    if reddit_biz:
        lines.append("### 커뮤니티 비즈니스 토픽")
        for i, item in enumerate(reddit_biz[:5], 1):
            lines.append(f"{i}. [{item['title']}]({item['url']}) — {item.get('source', '')}")
        lines.append("")

    # 메타 정보
    lines.append("---")
    lines.append(f"*자동 생성: AI News Bot | {period['end'].strftime('%Y-%m-%d %H:%M')} KST*")

    return "\n".join(lines)
