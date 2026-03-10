"""YouTube 메타데이터 추출 모듈

- oembed API (무료, API키 불필요) — 단일 영상 메타데이터
- YouTube Data API v3 (검색/재생목록) — YOUTUBE_API_KEY 환경변수 필요
"""

import json
import re
import urllib.error
import urllib.request
import urllib.parse
from typing import Optional

import cache
from config import YOUTUBE_API_KEY


def get_metadata(video_id: str) -> dict:
    """영상 메타데이터 추출 (캐시 → oembed → API → HTML 스크래핑)"""
    cached = cache.get(video_id, "metadata")
    if cached:
        return cached

    meta = _fetch_oembed(video_id)

    # API로 정확한 메타데이터 보강 (published, duration, view_count)
    if YOUTUBE_API_KEY:
        api_meta = get_video_details(video_id)
        if api_meta:
            if not meta:
                meta = api_meta
            else:
                for k, v in api_meta.items():
                    if v and not meta.get(k):
                        meta[k] = v

    if meta:
        cache.put(video_id, meta, "metadata")

    return meta or {
        "title": "Unknown",
        "channel": "Unknown",
        "published": "",
        "duration": "",
        "view_count": "",
    }


def _fetch_oembed(video_id: str) -> Optional[dict]:
    """oEmbed API로 기본 메타데이터 추출 (API키 불필요)"""
    url = f"https://www.youtube.com/oembed?url=https://youtu.be/{video_id}&format=json"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "yt-analyzer/1.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read())
            return {
                "title": data.get("title", "Unknown"),
                "channel": data.get("author_name", "Unknown"),
                "channel_url": data.get("author_url", ""),
                "thumbnail": data.get("thumbnail_url", ""),
                "published": "",  # oembed doesn't provide this
                "duration": "",   # oembed doesn't provide this
                "view_count": "",  # oembed doesn't provide this
            }
    except Exception as e:
        print(f"oEmbed error for {video_id}: {e}")
        return None


def _api_request(endpoint: str, params: dict) -> dict:
    """YouTube Data API v3 요청 (키 마스킹 + 에러 처리 중앙화)"""
    params["key"] = YOUTUBE_API_KEY
    url = f"https://www.googleapis.com/youtube/v3/{endpoint}?{urllib.parse.urlencode(params)}"

    try:
        req = urllib.request.Request(url, headers={"User-Agent": "yt-analyzer/1.0"})
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        # API 키가 에러 메시지에 노출되지 않도록 마스킹
        body = e.read().decode("utf-8", errors="ignore") if e.readable() else ""
        masked = body.replace(YOUTUBE_API_KEY, "***")
        raise RuntimeError(f"YouTube API error ({e.code}): {masked}") from None
    except Exception as e:
        # 일반 예외에서도 키 노출 방지
        msg = str(e).replace(YOUTUBE_API_KEY, "***") if YOUTUBE_API_KEY else str(e)
        raise RuntimeError(f"YouTube API request failed: {msg}") from None


def _parse_iso8601_duration(iso_duration: str) -> str:
    """ISO 8601 duration (PT1H2M3S) → 사람이 읽기 쉬운 형식 (1:02:03)"""
    match = re.match(r"PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?", iso_duration or "")
    if not match:
        return ""
    h = int(match.group(1) or 0)
    m = int(match.group(2) or 0)
    s = int(match.group(3) or 0)
    if h > 0:
        return f"{h}:{m:02d}:{s:02d}"
    return f"{m}:{s:02d}"


def _format_view_count(count: int) -> str:
    """조회수를 읽기 쉬운 형식으로 변환"""
    if count >= 1_000_000:
        return f"{count/1_000_000:.1f}M"
    elif count >= 1_000:
        return f"{count/1_000:.1f}K"
    return str(count)


def get_video_details(video_id: str) -> Optional[dict]:
    """YouTube Data API v3 videos.list로 정확한 메타데이터 추출

    Returns: {"published": str, "duration": str, "view_count": str,
              "like_count": str, "comment_count": str} or None
    """
    if not YOUTUBE_API_KEY:
        return None

    try:
        data = _api_request("videos", {
            "part": "snippet,contentDetails,statistics",
            "id": video_id,
        })
    except RuntimeError as e:
        print(f"API error for video details {video_id}: {e}")
        return None

    items = data.get("items", [])
    if not items:
        return None

    item = items[0]
    snippet = item.get("snippet", {})
    content = item.get("contentDetails", {})
    stats = item.get("statistics", {})

    view_count_raw = int(stats.get("viewCount", 0))
    like_count_raw = int(stats.get("likeCount", 0))
    comment_count_raw = int(stats.get("commentCount", 0))

    return {
        "published": snippet.get("publishedAt", "")[:10],
        "duration": _parse_iso8601_duration(content.get("duration", "")),
        "view_count": _format_view_count(view_count_raw),
        "view_count_raw": view_count_raw,
        "like_count": _format_view_count(like_count_raw),
        "like_count_raw": like_count_raw,
        "comment_count": _format_view_count(comment_count_raw),
        "comment_count_raw": comment_count_raw,
        "tags": snippet.get("tags", []),
        "description": snippet.get("description", "")[:500],
    }


def get_video_details_batch(video_ids: list[str]) -> dict[str, dict]:
    """여러 영상의 메타데이터를 한 번에 조회 (최대 50개씩)

    Returns: {video_id: details_dict, ...}
    """
    if not YOUTUBE_API_KEY:
        return {}

    results = {}
    for i in range(0, len(video_ids), 50):
        batch = video_ids[i:i+50]
        try:
            data = _api_request("videos", {
                "part": "snippet,contentDetails,statistics",
                "id": ",".join(batch),
            })
        except RuntimeError as e:
            print(f"Batch API error: {e}")
            continue

        for item in data.get("items", []):
            vid = item.get("id", "")
            snippet = item.get("snippet", {})
            content = item.get("contentDetails", {})
            stats = item.get("statistics", {})

            view_count_raw = int(stats.get("viewCount", 0))
            like_count_raw = int(stats.get("likeCount", 0))
            comment_count_raw = int(stats.get("commentCount", 0))

            results[vid] = {
                "published": snippet.get("publishedAt", "")[:10],
                "duration": _parse_iso8601_duration(content.get("duration", "")),
                "view_count": _format_view_count(view_count_raw),
                "view_count_raw": view_count_raw,
                "like_count": _format_view_count(like_count_raw),
                "like_count_raw": like_count_raw,
                "comment_count": _format_view_count(comment_count_raw),
                "comment_count_raw": comment_count_raw,
                "tags": snippet.get("tags", []),
                "description": snippet.get("description", "")[:500],
            }

    return results


def search_videos(query: str, limit: int = 10) -> list[dict]:
    """YouTube Data API v3로 영상 검색

    Returns: [{"video_id": str, "title": str, "channel": str, "published": str, "thumbnail": str}, ...]
    """
    if not YOUTUBE_API_KEY:
        raise RuntimeError(
            "YOUTUBE_API_KEY 환경변수가 설정되지 않았습니다.\n"
            "1. https://console.cloud.google.com/apis/credentials 에서 API 키 생성\n"
            "2. YouTube Data API v3 활성화\n"
            "3. export YOUTUBE_API_KEY='your-key'"
        )

    data = _api_request("search", {
        "part": "snippet",
        "q": query,
        "type": "video",
        "maxResults": min(limit, 50),
        "order": "relevance",
    })

    results = []
    for item in data.get("items", []):
        snippet = item.get("snippet", {})
        results.append({
            "video_id": item["id"]["videoId"],
            "title": snippet.get("title", ""),
            "channel": snippet.get("channelTitle", ""),
            "published": snippet.get("publishedAt", "")[:10],
            "thumbnail": snippet.get("thumbnails", {}).get("high", {}).get("url", ""),
            "url": f"https://youtu.be/{item['id']['videoId']}",
        })

    return results


def get_playlist_videos(playlist_id: str, limit: int = 50) -> list[dict]:
    """YouTube Data API v3로 재생목록 영상 추출

    Returns: [{"video_id": str, "title": str, "channel": str, "position": int}, ...]
    """
    if not YOUTUBE_API_KEY:
        raise RuntimeError(
            "YOUTUBE_API_KEY 환경변수가 설정되지 않았습니다.\n"
            "export YOUTUBE_API_KEY='your-key'"
        )

    results = []
    next_page = None

    while len(results) < limit:
        params = {
            "part": "snippet",
            "playlistId": playlist_id,
            "maxResults": min(50, limit - len(results)),
        }
        if next_page:
            params["pageToken"] = next_page

        data = _api_request("playlistItems", params)

        for item in data.get("items", []):
            snippet = item.get("snippet", {})
            vid = snippet.get("resourceId", {}).get("videoId")
            if vid:
                results.append({
                    "video_id": vid,
                    "title": snippet.get("title", ""),
                    "channel": snippet.get("channelTitle", ""),
                    "published": snippet.get("publishedAt", "")[:10],
                    "position": snippet.get("position", 0),
                    "url": f"https://youtu.be/{vid}",
                })

        next_page = data.get("nextPageToken")
        if not next_page:
            break

    return results[:limit]


def extract_metadata_from_page(video_id: str) -> Optional[dict]:
    """YouTube 페이지에서 메타데이터 추출 (oembed 보완)"""
    url = f"https://www.youtube.com/watch?v={video_id}"
    try:
        req = urllib.request.Request(url, headers={
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            "Accept-Language": "en-US,en;q=0.9",
        })
        with urllib.request.urlopen(req, timeout=15) as resp:
            html = resp.read().decode("utf-8", errors="ignore")

        meta = {}

        # 조회수
        view_match = re.search(r'"viewCount":"(\d+)"', html)
        if view_match:
            count = int(view_match.group(1))
            if count >= 1_000_000:
                meta["view_count"] = f"{count/1_000_000:.1f}M"
            elif count >= 1_000:
                meta["view_count"] = f"{count/1_000:.1f}K"
            else:
                meta["view_count"] = str(count)

        # 게시일
        date_match = re.search(r'"publishDate":"(\d{4}-\d{2}-\d{2})"', html)
        if date_match:
            meta["published"] = date_match.group(1)

        # 영상 길이
        length_match = re.search(r'"lengthSeconds":"(\d+)"', html)
        if length_match:
            total = int(length_match.group(1))
            h, remainder = divmod(total, 3600)
            m, s = divmod(remainder, 60)
            if h > 0:
                meta["duration"] = f"{h}:{m:02d}:{s:02d}"
            else:
                meta["duration"] = f"{m}:{s:02d}"

        return meta if meta else None

    except Exception as e:
        print(f"Page scrape error for {video_id}: {e}")
        return None
