#!/usr/bin/env python3
"""daily-review collector — Tier 1/2/5 정형 소스 HTTP 수집 + 중간 JSON 저장

수집 대상:
- Tier 1: Anthropic 공식 뉴스·API 변경로그, OpenAI 블로그, DeepMind 블로그 (HTTP 직접 fetch)
- Tier 2: GitHub Trending (HTML 파싱), anthropics/claude-code 릴리즈 (GitHub API)
- Tier 5: arXiv cs.AI/cs.CL/cs.SE RSS 피드 (feedparser 또는 urllib 직접 파싱)

나머지 Tier (Tier 3 커뮤니티, Tier 4 YouTube, Tier 6 미디어)는 Claude가 런타임에 검색.

출력: 01-research/daily/{date}/raw-data.json
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

# 프로젝트 루트
BUSINESS_DIR = Path(__file__).resolve().parent.parent.parent
OUTPUT_BASE = BUSINESS_DIR / "01-research" / "daily"


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
USER_AGENT = "Mozilla/5.0 (compatible; daily-review-collector/1.0)"
TIMEOUT = 15


def http_get(url: str, headers: dict = None) -> str | None:
    """HTTP GET 요청. 실패 시 None 반환."""
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
# Tier 1: AI 기업 공식 소스
# ─────────────────────────────────────────────

def collect_anthropic(target_date: date) -> list[dict]:
    """Anthropic 공식 뉴스 RSS/Atom 파싱."""
    items = []
    feeds = [
        ("anthropic-news", "https://www.anthropic.com/rss.xml"),
        ("claude-api-changelog", "https://docs.anthropic.com/changelog.rss"),
    ]
    for source_id, url in feeds:
        html = http_get(url)
        if not html:
            continue
        try:
            root = ET.fromstring(html)
            ns = {"atom": "http://www.w3.org/2005/Atom"}
            # RSS 2.0
            for item in root.findall(".//item"):
                title = (item.findtext("title") or "").strip()
                link = (item.findtext("link") or "").strip()
                pub_date = (item.findtext("pubDate") or "").strip()
                desc = (item.findtext("description") or "").strip()
                items.append({
                    "source": source_id,
                    "tier": 1,
                    "title": title,
                    "url": link,
                    "published": pub_date,
                    "summary": desc[:300],
                })
            # Atom
            for entry in root.findall(".//atom:entry", ns):
                title = (entry.findtext("atom:title", namespaces=ns) or "").strip()
                link_el = entry.find("atom:link", ns)
                link = link_el.get("href", "") if link_el is not None else ""
                pub = (entry.findtext("atom:published", namespaces=ns) or
                       entry.findtext("atom:updated", namespaces=ns) or "").strip()
                summary = (entry.findtext("atom:summary", namespaces=ns) or "").strip()
                items.append({
                    "source": source_id,
                    "tier": 1,
                    "title": title,
                    "url": link,
                    "published": pub,
                    "summary": summary[:300],
                })
        except ET.ParseError as e:
            print(f"  [WARN] XML parse error for {source_id}: {e}", file=sys.stderr)

    return _filter_by_date(items, target_date, days=2)


def collect_github_releases(target_date: date) -> list[dict]:
    """Tier 1+2: Anthropic/Claude Code & MCP GitHub 릴리즈."""
    repos = [
        "anthropics/claude-code",
        "modelcontextprotocol/sdk",
        "modelcontextprotocol/servers",
    ]
    items = []
    for repo in repos:
        url = f"https://api.github.com/repos/{repo}/releases?per_page=10"
        data = http_get(url)
        if not data:
            continue
        try:
            releases = json.loads(data)
            for r in releases:
                pub = r.get("published_at", "")
                items.append({
                    "source": f"github-releases/{repo}",
                    "tier": 2,
                    "title": f"[{repo}] {r.get('name') or r.get('tag_name', '')}",
                    "url": r.get("html_url", ""),
                    "published": pub,
                    "summary": (r.get("body") or "")[:300],
                })
        except json.JSONDecodeError:
            pass
    return _filter_by_date(items, target_date, days=2)


def collect_github_trending(target_date: date) -> list[dict]:
    """Tier 2: GitHub Trending (daily, AI/ML 관련)."""
    url = "https://github.com/trending?since=daily&spoken_language_code=en"
    html = http_get(url)
    items = []
    if not html:
        return items

    # 간단한 패턴 추출 (정규표현식)
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
        # AI/ML 관련 필터링은 Claude가 판단하도록 전체 목록 전달
        items.append({
            "source": "github-trending",
            "tier": 2,
            "title": repo_path.strip(),
            "url": f"https://github.com/{repo_path.strip()}",
            "published": target_date.isoformat(),
            "summary": name,
        })
        count += 1
        if count >= 25:
            break
    return items


# ─────────────────────────────────────────────
# Tier 5: 학술/연구 (arXiv RSS)
# ─────────────────────────────────────────────

def collect_arxiv(target_date: date) -> list[dict]:
    """Tier 5: arXiv cs.AI, cs.CL, cs.SE, cs.MA 최신 논문."""
    categories = ["cs.AI", "cs.CL", "cs.SE", "cs.MA"]
    items = []
    for cat in categories:
        url = f"https://rss.arxiv.org/rss/{cat}"
        html = http_get(url)
        if not html:
            continue
        try:
            root = ET.fromstring(html)
            for item in root.findall(".//item"):
                title = (item.findtext("title") or "").strip()
                link = (item.findtext("link") or "").strip()
                pub = (item.findtext("pubDate") or target_date.isoformat()).strip()
                desc = (item.findtext("description") or "").strip()
                # HTML 태그 제거
                desc = re.sub(r"<[^>]+>", " ", desc)[:300]
                items.append({
                    "source": f"arxiv/{cat}",
                    "tier": 5,
                    "title": title,
                    "url": link,
                    "published": pub,
                    "summary": desc,
                })
        except ET.ParseError as e:
            print(f"  [WARN] arXiv XML parse error for {cat}: {e}", file=sys.stderr)

    return _filter_by_date(items, target_date, days=3)


# ─────────────────────────────────────────────
# 유틸리티
# ─────────────────────────────────────────────

def _filter_by_date(items: list[dict], target_date: date, days: int = 2) -> list[dict]:
    """target_date 기준 N일 이내 항목만 반환. 날짜 파싱 실패 시 포함."""
    cutoff = target_date - timedelta(days=days)
    result = []
    for item in items:
        pub_str = item.get("published", "")
        parsed = _parse_date(pub_str)
        if parsed is None or parsed >= cutoff:
            result.append(item)
    return result


def _parse_date(date_str: str) -> date | None:
    """다양한 날짜 포맷 파싱 시도."""
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
    # ISO 8601 partial
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
    """전체 수집 실행. raw-data.json 포맷으로 반환."""
    print(f"[collector] 수집 시작: {target_date}")

    print("  Tier 1: Anthropic 공식 소스...")
    anthropic_items = collect_anthropic(target_date)
    print(f"    → {len(anthropic_items)}건")

    print("  Tier 2: GitHub 릴리즈...")
    github_release_items = collect_github_releases(target_date)
    print(f"    → {len(github_release_items)}건")

    print("  Tier 2: GitHub Trending...")
    github_trending_items = collect_github_trending(target_date)
    print(f"    → {len(github_trending_items)}건")

    print("  Tier 5: arXiv 논문...")
    arxiv_items = collect_arxiv(target_date)
    print(f"    → {len(arxiv_items)}건")

    all_items = anthropic_items + github_release_items + github_trending_items + arxiv_items

    payload = {
        "schema_version": "1.0",
        "pipeline": "daily-review",
        "target_date": target_date.isoformat(),
        "collected_at": datetime.now(timezone.utc).isoformat(),
        "stats": {
            "tier1_count": len(anthropic_items),
            "tier2_releases_count": len(github_release_items),
            "tier2_trending_count": len(github_trending_items),
            "tier5_count": len(arxiv_items),
            "total": len(all_items),
        },
        "items": all_items,
        "claude_search_needed": [
            "Tier 3: HN, Reddit (r/MachineLearning, r/LocalLLaMA, r/ClaudeAI), Dev.to, Twitter/X",
            "Tier 4: YouTube (Fireship, AI Jason, Matt Wolfe, Yannic Kilcher) 최신 업로드",
            "Tier 6: TechCrunch AI, VentureBeat, Product Hunt AI, a16z AI Blog",
        ],
    }
    return payload


def save(payload: dict, target_date: date) -> Path:
    """raw-data.json 저장."""
    out_dir = OUTPUT_BASE / target_date.isoformat()
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / "raw-data.json"
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
    print(f"[collector] 저장 완료: {out_path}")
    return out_path


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Daily Review — 정형 소스 수집기")
    parser.add_argument("date", nargs="?", help="수집 기준 날짜 (YYYY-MM-DD). 미입력 시 전날.")
    parser.add_argument("--print", action="store_true", help="JSON을 stdout에도 출력")
    args = parser.parse_args()

    if args.date:
        try:
            target = date.fromisoformat(args.date)
        except ValueError:
            print(f"ERROR: 날짜 형식 오류: {args.date} (YYYY-MM-DD 필요)", file=sys.stderr)
            sys.exit(1)
    else:
        target = date.today() - timedelta(days=1)

    payload = collect(target)
    out_path = save(payload, target)

    if args.print:
        print(json.dumps(payload, ensure_ascii=False, indent=2))

    print(f"\n[collector] 완료. 총 {payload['stats']['total']}건 수집.")
    print(f"  저장: {out_path}")
    print(f"  Claude 검색 필요: Tier 3/4/6 ({len(payload['claude_search_needed'])}개 카테고리)")


if __name__ == "__main__":
    main()
