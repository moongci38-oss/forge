"""YouTube 트랜스크립트 추출 모듈

Primary: youtube-transcript-api (무료, API키 불필요)
Fallback: yt-dlp (설치된 경우)
"""

import re
import shutil
import subprocess
import json
from typing import Optional

import cache
from config import TRANSCRIPT_LANG_PRIORITY


def extract_video_id(url: str) -> str:
    """YouTube URL에서 video_id 추출"""
    patterns = [
        r"(?:v=|/v/|youtu\.be/|/embed/|/shorts/)([a-zA-Z0-9_-]{11})",
        r"^([a-zA-Z0-9_-]{11})$",  # bare video ID
    ]
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    raise ValueError(f"Cannot extract video ID from: {url}")


def get_transcript(video_id: str, languages: list[str] | None = None) -> dict:
    """트랜스크립트 추출 (캐시 → API → yt-dlp 폴백)

    Returns:
        {
            "video_id": str,
            "language": str,
            "segments": [{"start": float, "duration": float, "text": str}, ...],
            "source": "api" | "yt-dlp" | "cache"
        }
    """
    # 캐시 확인
    cached = cache.get(video_id, "transcript")
    if cached:
        cached["source"] = "cache"
        return cached

    langs = languages or TRANSCRIPT_LANG_PRIORITY

    # Primary: youtube-transcript-api
    result = _fetch_via_api(video_id, langs)
    if result:
        cache.put(video_id, result, "transcript")
        return result

    # Fallback: yt-dlp
    result = _fetch_via_ytdlp(video_id, langs)
    if result:
        cache.put(video_id, result, "transcript")
        return result

    raise RuntimeError(
        f"No transcript available for {video_id}. "
        "Try a video with captions or install yt-dlp for auto-generated subtitles."
    )


def _fetch_via_api(video_id: str, langs: list[str]) -> Optional[dict]:
    """youtube-transcript-api로 추출 (v1.2.x 인스턴스 기반 API)"""
    try:
        from youtube_transcript_api import YouTubeTranscriptApi
    except ImportError:
        print("WARNING: youtube-transcript-api not installed. Run: pip3 install youtube-transcript-api")
        return None

    api = YouTubeTranscriptApi()

    # 간편 API: fetch()로 언어 우선순위 시도
    try:
        result = api.fetch(video_id, languages=langs)
        segments = [
            {"start": s.start, "duration": s.duration, "text": s.text}
            for s in result
        ]
        # 언어 정보는 list()로 확인
        try:
            transcript_list = api.list(video_id)
            found = transcript_list.find_transcript(langs)
            lang = found.language_code
            is_generated = found.is_generated
        except Exception:
            lang = langs[0] if langs else "unknown"
            is_generated = False

        return {
            "video_id": video_id,
            "language": lang,
            "is_generated": is_generated,
            "segments": segments,
            "source": "api",
        }
    except Exception:
        pass

    # 폴백: list()로 사용 가능한 자막 탐색
    try:
        transcript_list = api.list(video_id)

        # 수동 자막 우선
        for lang in langs:
            try:
                transcript = transcript_list.find_transcript([lang])
                segments = transcript.fetch()
                return {
                    "video_id": video_id,
                    "language": transcript.language_code,
                    "is_generated": transcript.is_generated,
                    "segments": [
                        {"start": s.start, "duration": s.duration, "text": s.text}
                        for s in segments
                    ],
                    "source": "api",
                }
            except Exception:
                continue

        # 자동 생성 자막
        for lang in langs:
            try:
                transcript = transcript_list.find_generated_transcript([lang])
                segments = transcript.fetch()
                return {
                    "video_id": video_id,
                    "language": transcript.language_code,
                    "is_generated": True,
                    "segments": [
                        {"start": s.start, "duration": s.duration, "text": s.text}
                        for s in segments
                    ],
                    "source": "api",
                }
            except Exception:
                continue

        # 아무 언어라도 시도
        available = list(transcript_list)
        if available:
            transcript = available[0]
            segments = transcript.fetch()
            return {
                "video_id": video_id,
                "language": transcript.language_code,
                "is_generated": transcript.is_generated,
                "segments": [
                    {"start": s.start, "duration": s.duration, "text": s.text}
                    for s in segments
                ],
                "source": "api",
            }

    except Exception as e:
        print(f"youtube-transcript-api error: {e}")

    return None


def _fetch_via_ytdlp(video_id: str, langs: list[str]) -> Optional[dict]:
    """yt-dlp 폴백으로 자막 추출"""
    if not shutil.which("yt-dlp"):
        return None

    url = f"https://www.youtube.com/watch?v={video_id}"
    lang_str = ",".join(langs)

    try:
        result = subprocess.run(
            [
                "yt-dlp",
                "--skip-download",
                "--write-auto-sub",
                "--sub-lang", lang_str,
                "--sub-format", "json3",
                "--dump-json",
                url,
            ],
            capture_output=True, text=True, timeout=60,
        )

        if result.returncode != 0:
            return None

        info = json.loads(result.stdout)
        # yt-dlp JSON에서 자막 추출
        subtitles = info.get("subtitles", {})
        auto_subs = info.get("automatic_captions", {})

        for lang in langs:
            subs = subtitles.get(lang) or auto_subs.get(lang)
            if subs:
                # json3 포맷 찾기
                for sub in subs:
                    if sub.get("ext") == "json3":
                        # json3 URL에서 직접 다운로드
                        sub_url = sub.get("url")
                        if sub_url:
                            import urllib.request
                            with urllib.request.urlopen(sub_url, timeout=30) as resp:
                                sub_data = json.loads(resp.read())
                            events = sub_data.get("events", [])
                            segments = []
                            for event in events:
                                if "segs" in event:
                                    text = "".join(s.get("utf8", "") for s in event["segs"]).strip()
                                    if text:
                                        segments.append({
                                            "start": event.get("tStartMs", 0) / 1000,
                                            "duration": event.get("dDurationMs", 0) / 1000,
                                            "text": text,
                                        })
                            if segments:
                                return {
                                    "video_id": video_id,
                                    "language": lang,
                                    "is_generated": lang in auto_subs,
                                    "segments": segments,
                                    "source": "yt-dlp",
                                }
    except Exception as e:
        print(f"yt-dlp error: {e}")

    return None


def format_timestamp(seconds: float) -> str:
    """초를 HH:MM:SS 또는 MM:SS 형식으로 변환"""
    total = int(seconds)
    h, remainder = divmod(total, 3600)
    m, s = divmod(remainder, 60)
    if h > 0:
        return f"{h:02d}:{m:02d}:{s:02d}"
    return f"{m:02d}:{s:02d}"


def timestamp_url(video_id: str, seconds: float) -> str:
    """타임스탬프 링크 생성"""
    t = int(seconds)
    ts = format_timestamp(seconds)
    return f"[🕐 {ts}](https://youtu.be/{video_id}?t={t})"
