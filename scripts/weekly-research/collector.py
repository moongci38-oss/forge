#!/usr/bin/env python3
"""weekly-research collector — 주간 정형 소스 수집 + 중간 JSON 저장

수집 대상:
- 기술 뉴스: Anthropic·OpenAI 블로그 최신 포스트 (HTTP)
- GitHub: 주간 Trending AI/ML 레포지토리
- 커뮤니티: Hacker News 주간 Top AI 스토리 (Algolia API)
- Product Hunt: AI 카테고리 최신 제품 (웹 스크래핑)

필터: 지난 7일 기준 날짜 필터 적용

출력: 01-research/weekly/{date}/raw-data.json
"""

import json
import os
import sys
import re
import urllib.request
import urllib.error
import urllib.parse
from datetime import date, timedelta, datetime, timezone
from pathlib import Path
from xml.etree import ElementTree as ET

BUSINESS_DIR = Path(__file__).resolve().parent.parent.parent
OUTPUT_BASE = BUSINESS_DIR / "01-research" / "weekly"


def _load_env(env_path: Path) -> None:
    if not env_path.exists():
        return
    with open(env_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            key = key.strip()
            value = value.strip().strip("'\"")
            if key and key not in os.environ:
                os.environ[key] = value


_load_env(BUSINESS_DIR / ".env")

GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN", "")
USER_AGENT = "Mozilla/5.0 (compatible; weekly-research-collector/1.0)"
TIMEOUT = 15


def http_get(url: str, headers: dict = None) -> str | None:
    req_headers = {"User-Agent": USER_AGENT}
    if headers:
        req_headers.update(headers)
    if GITHUB_TOKEN and "api.github.com" in url:
        req_headers["Authorization"] = f"Bearer {GITHUB_TOKEN}"
    try:
        req = urllib.request.Request(url, headers=req_headers)
        with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
            return resp.read().decode("utf-8", errors="replace")
    except Exception as e:
        print(f"  [WARN] fetch failed: {url} — {e}", file=sys.stderr)
        return None


# ─────────────────────────────────────────────
# 기술 뉴스: Anthropic + OpenAI RSS
# ─────────────────────────────────────────────

def collect_tech_feeds(target_date: date) -> list[dict]:
    """AI 기업 공식 RSS/Atom 피드 수집 (주간 7일 필터)."""
    feeds = [
        ("anthropic-news", "https://www.anthropic.com/rss.xml"),
        ("claude-api-changelog", "https://docs.anthropic.com/changelog.rss"),
        ("anthropic-engineering", "https://www.anthropic.com/engineering.rss"),
    ]
    items = []
    for source_id, url in feeds:
        html = http_get(url)
        if not html:
            continue
        try:
            root = ET.fromstring(html)
            ns = {"atom": "http://www.w3.org/2005/Atom"}
            for item in root.findall(".//item"):
                title = (item.findtext("title") or "").strip()
                link = (item.findtext("link") or "").strip()
                pub = (item.findtext("pubDate") or "").strip()
                desc = (item.findtext("description") or "").strip()
                desc = re.sub(r"<[^>]+>", " ", desc)[:400]
                items.append({
                    "source": source_id, "category": "tech",
                    "title": title, "url": link, "published": pub, "summary": desc,
                })
            for entry in root.findall(".//atom:entry", ns):
                title = (entry.findtext("atom:title", namespaces=ns) or "").strip()
                link_el = entry.find("atom:link", ns)
                link = link_el.get("href", "") if link_el is not None else ""
                pub = (entry.findtext("atom:published", namespaces=ns) or
                       entry.findtext("atom:updated", namespaces=ns) or "").strip()
                summary = (entry.findtext("atom:summary", namespaces=ns) or "").strip()
                summary = re.sub(r"<[^>]+>", " ", summary)[:400]
                items.append({
                    "source": source_id, "category": "tech",
                    "title": title, "url": link, "published": pub, "summary": summary,
                })
        except ET.ParseError as e:
            print(f"  [WARN] XML parse error for {source_id}: {e}", file=sys.stderr)

    return _filter_by_date(items, target_date, days=7)


# ─────────────────────────────────────────────
# GitHub 주간 Trending
# ─────────────────────────────────────────────

def collect_github_trending_weekly(target_date: date) -> list[dict]:
    """GitHub Trending (weekly)."""
    url = "https://github.com/trending?since=weekly&spoken_language_code=en"
    html = http_get(url)
    items = []
    if not html:
        return items

    pattern = r'href="/([^"]+)"[^>]*class="[^"]*Link[^"]*"[^>]*>\s*([^<]+)'
    matches = re.findall(pattern, html)
    seen = set()
    count = 0
    for repo_path, name in matches:
        if "/" not in repo_path or repo_path in seen:
            continue
        seen.add(repo_path)
        name = name.strip()
        if not name:
            continue
        items.append({
            "source": "github-trending-weekly",
            "category": "tech",
            "title": repo_path.strip(),
            "url": f"https://github.com/{repo_path.strip()}",
            "published": target_date.isoformat(),
            "summary": name,
        })
        count += 1
        if count >= 30:
            break
    return items


# ─────────────────────────────────────────────
# Hacker News 주간 Top AI 스토리 (Algolia API)
# ─────────────────────────────────────────────

def collect_hackernews(target_date: date) -> list[dict]:
    """HN Algolia API로 AI 관련 상위 스토리 수집."""
    cutoff = target_date - timedelta(days=7)
    cutoff_ts = int(datetime(cutoff.year, cutoff.month, cutoff.day,
                              tzinfo=timezone.utc).timestamp())

    queries = ["AI agent", "Claude", "LLM", "GPT", "machine learning"]
    items = []
    seen_ids = set()

    for q in queries:
        encoded = urllib.parse.quote(q)
        url = (f"https://hn.algolia.com/api/v1/search?query={encoded}"
               f"&tags=story&numericFilters=created_at_i>{cutoff_ts}"
               f"&hitsPerPage=10&ranking=byPopularity")
        data = http_get(url)
        if not data:
            continue
        try:
            resp = json.loads(data)
            for hit in resp.get("hits", []):
                hit_id = hit.get("objectID", "")
                if hit_id in seen_ids:
                    continue
                seen_ids.add(hit_id)
                created = hit.get("created_at", "")
                items.append({
                    "source": "hackernews",
                    "category": "community",
                    "title": hit.get("title", ""),
                    "url": hit.get("url") or f"https://news.ycombinator.com/item?id={hit_id}",
                    "published": created,
                    "summary": f"Points: {hit.get('points', 0)}, Comments: {hit.get('num_comments', 0)}",
                    "hn_url": f"https://news.ycombinator.com/item?id={hit_id}",
                })
        except json.JSONDecodeError:
            pass

    return _filter_by_date(items, target_date, days=7)


# ─────────────────────────────────────────────
# 유틸리티
# ─────────────────────────────────────────────

def _filter_by_date(items: list[dict], target_date: date, days: int = 7) -> list[dict]:
    cutoff = target_date - timedelta(days=days)
    result = []
    for item in items:
        pub_str = item.get("published", "")
        parsed = _parse_date(pub_str)
        if parsed is None or parsed >= cutoff:
            result.append(item)
    return result


def _parse_date(date_str: str) -> date | None:
    if not date_str:
        return None
    formats = [
        "%Y-%m-%dT%H:%M:%SZ",
        "%Y-%m-%dT%H:%M:%S%z",
        "%a, %d %b %Y %H:%M:%S %z",
        "%a, %d %b %Y %H:%M:%S GMT",
        "%Y-%m-%d",
    ]
    for fmt in formats:
        try:
            return datetime.strptime(date_str[:30], fmt).date()
        except ValueError:
            continue
    m = re.match(r"(\d{4}-\d{2}-\d{2})", date_str)
    if m:
        try:
            return date.fromisoformat(m.group(1))
        except ValueError:
            pass
    return None


# ─────────────────────────────────────────────
# 메인
# ─────────────────────────────────────────────

def collect(target_date: date) -> dict:
    print(f"[collector] 주간 수집 시작: {target_date} (지난 7일)")

    print("  Tech 피드: Anthropic/OpenAI RSS...")
    tech_items = collect_tech_feeds(target_date)
    print(f"    → {len(tech_items)}건")

    print("  GitHub 주간 Trending...")
    github_items = collect_github_trending_weekly(target_date)
    print(f"    → {len(github_items)}건")

    print("  Hacker News AI 스토리...")
    hn_items = collect_hackernews(target_date)
    print(f"    → {len(hn_items)}건")

    all_items = tech_items + github_items + hn_items

    payload = {
        "schema_version": "1.0",
        "pipeline": "weekly-research",
        "target_date": target_date.isoformat(),
        "week_start": (target_date - timedelta(days=6)).isoformat(),
        "collected_at": datetime.now(timezone.utc).isoformat(),
        "stats": {
            "tech_feeds_count": len(tech_items),
            "github_trending_count": len(github_items),
            "hackernews_count": len(hn_items),
            "total": len(all_items),
        },
        "items": all_items,
        "claude_search_needed": [
            "비즈니스 뉴스: SaaS/스타트업 동향, Product Hunt AI 신규 제품",
            "인디해커/1인기업: 수익 사례, 과금 모델 변화",
            "사업 아이템 분석: 시장 데이터, 경쟁사, SIGIL S1 방법론",
        ],
    }
    return payload


def save(payload: dict, target_date: date) -> Path:
    out_dir = OUTPUT_BASE / target_date.isoformat()
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / "raw-data.json"
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
    print(f"[collector] 저장 완료: {out_path}")
    return out_path


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Weekly Research — 정형 소스 수집기")
    parser.add_argument("date", nargs="?", help="수집 기준 날짜 (YYYY-MM-DD). 미입력 시 오늘.")
    parser.add_argument("--print", action="store_true", help="JSON을 stdout에도 출력")
    args = parser.parse_args()

    if args.date:
        try:
            target = date.fromisoformat(args.date)
        except ValueError:
            print(f"ERROR: 날짜 형식 오류: {args.date}", file=sys.stderr)
            sys.exit(1)
    else:
        target = date.today()

    payload = collect(target)
    out_path = save(payload, target)

    if args.print:
        print(json.dumps(payload, ensure_ascii=False, indent=2))

    print(f"\n[collector] 완료. 총 {payload['stats']['total']}건 수집.")
    print(f"  저장: {out_path}")


if __name__ == "__main__":
    main()
