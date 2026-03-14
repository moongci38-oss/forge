#!/usr/bin/env python3
"""yt-analyzer — YouTube 영상 분석 & 카테고리 정리 도구

Usage:
    python3 yt-analyzer.py "https://youtu.be/xxxxx"
    python3 yt-analyzer.py "https://youtu.be/xxxxx" --format timeline
    python3 yt-analyzer.py "https://youtu.be/xxxxx" --format mindmap
    python3 yt-analyzer.py --urls urls.txt
    python3 yt-analyzer.py --search "AI agent 2026" --limit 10
    python3 yt-analyzer.py --playlist PLxxxxx --limit 20
"""

import argparse
import json
import sys
from datetime import date
from pathlib import Path

# 모듈 경로 추가
sys.path.insert(0, str(Path(__file__).parent))

from config import SUPPORTED_FORMATS, DEFAULT_FORMAT, ANALYSES_DIR
from transcript import extract_video_id, get_transcript
from fetcher import get_metadata, extract_metadata_from_page, search_videos, get_playlist_videos, get_video_comments
from reporter import (
    generate_intermediate_json,
    save_intermediate_json,
    generate_summary_report,
    generate_timeline_report,
    generate_mindmap_report,
    generate_full_report,
    generate_blog_report,
    generate_batch_report,
    save_report,
    save_batch_report,
    auto_categorize,
)


def analyze_single(url: str, fmt: str = DEFAULT_FORMAT, save: bool = True,
                    category_override: str = None) -> dict:
    """단일 영상 분석 파이프라인"""
    video_id = extract_video_id(url)
    print(f"[1/5] Video ID: {video_id}")

    # 메타데이터 추출
    print("[2/5] Fetching metadata...")
    metadata = get_metadata(video_id)

    # 추가 메타데이터 (조회수, 게시일, 영상길이)
    extra = extract_metadata_from_page(video_id)
    if extra:
        for k, v in extra.items():
            if v and not metadata.get(k):
                metadata[k] = v

    print(f"       Title: {metadata.get('title', 'Unknown')}")
    print(f"       Channel: {metadata.get('channel', 'Unknown')}")

    # 트랜스크립트 추출
    print("[3/5] Extracting transcript...")
    transcript_data = get_transcript(video_id)
    print(f"       Language: {transcript_data['language']} | "
          f"Segments: {len(transcript_data['segments'])} | "
          f"Source: {transcript_data['source']}")

    # 댓글 수집 (API 키 있으면, 없으면 조용히 스킵)
    print("[4/5] Collecting comments...")
    comments = get_video_comments(video_id)
    if comments:
        print(f"       Comments: {len(comments)}개 수집")
    else:
        print("       Comments: 스킵 (API 키 없음 또는 댓글 비활성화)")

    # 중간 JSON 생성
    print("[5/5] Generating output...")
    intermediate = generate_intermediate_json(video_id, transcript_data, metadata, comments)

    # 카테고리 자동 분류
    category = category_override or auto_categorize(intermediate)
    intermediate["category"] = category
    print(f"       Category: {category}")

    # JSON 저장 (AI 분석용)
    json_path = save_intermediate_json(intermediate)
    print(f"       JSON saved: {json_path}")

    # 리포트 생성
    format_map = {
        "summary": generate_summary_report,
        "timeline": generate_timeline_report,
        "mindmap": generate_mindmap_report,
        "full": generate_full_report,
        "blog": generate_blog_report,
    }
    report = format_map.get(fmt, generate_summary_report)(intermediate)

    if save:
        report_path = save_report(report, video_id, fmt)
        print(f"       Report saved: {report_path}")

    print(f"\n{'='*60}")
    print(f"AI 분석 실행: /yt-analyze {json_path}")
    print(f"{'='*60}")

    return {
        "video_id": video_id,
        "json_path": str(json_path),
        "report": report,
        "intermediate": intermediate,
        "category": category,
    }


def analyze_multiple(urls: list[str], fmt: str = DEFAULT_FORMAT,
                     category_override: str = None,
                     batch_name: str = "batch") -> list[dict]:
    """여러 URL 일괄 분석 + 배치 리포트"""
    print(f"Processing {len(urls)} videos\n")

    results = []
    for i, url in enumerate(urls, 1):
        print(f"\n--- [{i}/{len(urls)}] ---")
        try:
            result = analyze_single(url, fmt, category_override=category_override)
            results.append(result)
        except Exception as e:
            print(f"ERROR: {e}")
            results.append({"url": url, "error": str(e)})

    # 배치 리포트 생성
    if len(results) > 1:
        batch_report = generate_batch_report(results, f"{batch_name} ({len(results)}개 영상)")
        batch_path = save_batch_report(batch_report, batch_name)
        print(f"\n배치 리포트 저장: {batch_path}")

    return results


def analyze_urls_file(filepath: str, fmt: str = DEFAULT_FORMAT,
                      category_override: str = None) -> list[dict]:
    """URL 목록 파일에서 일괄 분석"""
    path = Path(filepath)
    if not path.exists():
        print(f"ERROR: File not found: {filepath}")
        sys.exit(1)

    urls = [line.strip() for line in path.read_text().splitlines()
            if line.strip() and not line.startswith("#")]
    return analyze_multiple(urls, fmt, category_override, batch_name=path.stem)


def handle_search(query: str, limit: int, fmt: str, category_override: str = None):
    """YouTube 검색 → 일괄 분석"""
    print(f"Searching YouTube: \"{query}\" (limit: {limit})")
    results = search_videos(query, limit)
    print(f"Found {len(results)} videos:\n")

    for i, r in enumerate(results, 1):
        print(f"  {i}. [{r['published']}] {r['title'][:60]}")
        print(f"     {r['channel']} — {r['url']}")
    print()

    urls = [r["url"] for r in results]
    safe_query = query.replace(" ", "-")[:30]
    return analyze_multiple(urls, fmt, category_override, batch_name=f"search-{safe_query}")


def handle_playlist(playlist_id: str, limit: int, fmt: str, category_override: str = None):
    """재생목록 → 일괄 분석"""
    print(f"Fetching playlist: {playlist_id} (limit: {limit})")
    results = get_playlist_videos(playlist_id, limit)
    print(f"Found {len(results)} videos:\n")

    for i, r in enumerate(results, 1):
        print(f"  {i}. {r['title'][:60]}")
        print(f"     {r['channel']} — {r['url']}")
    print()

    urls = [r["url"] for r in results]
    return analyze_multiple(urls, fmt, category_override, batch_name=f"playlist-{playlist_id[:20]}")


def main():
    parser = argparse.ArgumentParser(
        description="YouTube 영상 분석 & 카테고리 정리 도구",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
예시:
  python3 yt-analyzer.py "https://youtu.be/xxxxx"
  python3 yt-analyzer.py "https://youtu.be/xxxxx" --format timeline
  python3 yt-analyzer.py "https://youtu.be/xxxxx" --format mindmap
  python3 yt-analyzer.py --urls urls.txt
  python3 yt-analyzer.py --search "AI agent 2026" --limit 10
  python3 yt-analyzer.py --playlist PLxxxxx --limit 20
  python3 yt-analyzer.py "https://youtu.be/xxxxx" --category "tech/ai"
        """,
    )

    parser.add_argument("url", nargs="?", help="YouTube 영상 URL")
    parser.add_argument("--urls", help="URL 목록 파일 (줄바꿈 구분)")
    parser.add_argument("--format", "-f", choices=SUPPORTED_FORMATS, default=DEFAULT_FORMAT,
                        help=f"출력 포맷 (기본: {DEFAULT_FORMAT})")
    parser.add_argument("--json-only", action="store_true",
                        help="중간 JSON만 생성 (리포트 미생성)")
    parser.add_argument("--no-save", action="store_true",
                        help="파일 저장하지 않고 stdout 출력만")

    # 검색 & 재생목록
    parser.add_argument("--search", help="YouTube 검색 쿼리 (YOUTUBE_API_KEY 필요)")
    parser.add_argument("--playlist", help="재생목록 ID (YOUTUBE_API_KEY 필요)")
    parser.add_argument("--limit", type=int, default=10, help="검색/재생목록 결과 수 (기본: 10)")

    # 카테고리
    parser.add_argument("--category", help="카테고리 수동 지정 (예: tech/ai)")

    args = parser.parse_args()

    # 입력 모드 판단
    if args.search:
        handle_search(args.search, args.limit, args.format, args.category)
    elif args.playlist:
        handle_playlist(args.playlist, args.limit, args.format, args.category)
    elif args.urls:
        results = analyze_urls_file(args.urls, args.format, args.category)
        success = sum(1 for r in results if "error" not in r)
        print(f"\n완료: {success}/{len(results)} 성공")
    elif args.url:
        result = analyze_single(args.url, args.format, save=not args.no_save,
                                category_override=args.category)
        if args.no_save:
            print(result["report"])
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
