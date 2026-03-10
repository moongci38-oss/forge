#!/usr/bin/env python3
"""기존 영상 JSON 및 index.json의 메타데이터를 YouTube Data API v3로 보강하는 일회성 스크립트

Usage:
    cd /home/damools/business/scripts/yt-analyzer
    python3 backfill-metadata.py              # 전체 보강
    python3 backfill-metadata.py --dry-run    # 변경 없이 미리보기
"""

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from config import ANALYSES_DIR, YOUTUBE_API_KEY
from fetcher import get_video_details_batch
import cache

INDEX_PATH = Path(__file__).resolve().parent.parent.parent / "01-research" / "videos" / "index.json"


def load_index() -> list[dict]:
    if not INDEX_PATH.exists():
        print(f"index.json not found: {INDEX_PATH}")
        return []
    with open(INDEX_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def save_index(data: list[dict]) -> None:
    with open(INDEX_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"index.json saved: {INDEX_PATH}")


def backfill_json_files(details: dict[str, dict], dry_run: bool) -> int:
    """analyses/ 내 JSON 파일의 메타데이터 보강"""
    updated = 0
    for json_path in sorted(ANALYSES_DIR.glob("*.json")):
        with open(json_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        video_id = data.get("video_id", "")
        if video_id not in details:
            continue

        api_meta = details[video_id]
        changed = False

        # 메타데이터 필드 보강
        meta = data.get("metadata", {})
        for field in ["published", "duration", "view_count", "like_count", "comment_count"]:
            api_val = api_meta.get(field, "")
            cur_val = meta.get(field, "")
            if api_val and not cur_val:
                meta[field] = api_val
                changed = True

        # raw 수치 추가
        for field in ["view_count_raw", "like_count_raw", "comment_count_raw"]:
            if field not in meta and field in api_meta:
                meta[field] = api_meta[field]
                changed = True

        if changed:
            data["metadata"] = meta
            if not dry_run:
                with open(json_path, "w", encoding="utf-8") as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
                # 캐시도 업데이트
                cache.put(video_id, meta, "metadata")
            print(f"  {'[DRY]' if dry_run else '[OK]'} {json_path.name}: +{sum(1 for f in ['published','duration','view_count','like_count','comment_count'] if api_meta.get(f) and not data.get('metadata',{}).get(f))} fields")
            updated += 1

    return updated


def backfill_index(details: dict[str, dict], dry_run: bool) -> int:
    """index.json 레코드에 duration, view_count 필드 추가"""
    index = load_index()
    if not index:
        return 0

    updated = 0
    for record in index:
        video_id = record.get("video_id", "")
        if video_id not in details:
            continue

        api_meta = details[video_id]
        changed = False

        for field in ["duration", "view_count", "published", "like_count", "comment_count"]:
            api_val = api_meta.get(field, "")
            cur_val = record.get(field, "")
            if api_val and not cur_val:
                record[field] = api_val
                changed = True

        if changed:
            updated += 1
            print(f"  {'[DRY]' if dry_run else '[OK]'} index:{video_id}: duration={record.get('duration','')}, views={record.get('view_count','')}")

    if updated > 0 and not dry_run:
        save_index(index)

    return updated


def main():
    parser = argparse.ArgumentParser(description="기존 영상 메타데이터를 API로 보강")
    parser.add_argument("--dry-run", action="store_true", help="변경 없이 미리보기만")
    args = parser.parse_args()

    if not YOUTUBE_API_KEY:
        print("ERROR: YOUTUBE_API_KEY 환경변수가 설정되지 않았습니다.")
        print("  export YOUTUBE_API_KEY='your-key'")
        sys.exit(1)

    # 전체 video_id 수집
    index = load_index()
    video_ids = [r["video_id"] for r in index if r.get("video_id")]

    if not video_ids:
        print("No videos found in index.json")
        return

    print(f"Fetching metadata for {len(video_ids)} videos via YouTube Data API v3...")
    details = get_video_details_batch(video_ids)
    print(f"API returned details for {len(details)} videos\n")

    # JSON 파일 보강
    print("=== Backfilling analysis JSON files ===")
    json_updated = backfill_json_files(details, args.dry_run)

    # index.json 보강
    print("\n=== Backfilling index.json ===")
    index_updated = backfill_index(details, args.dry_run)

    print(f"\nDone: {json_updated} JSON files + {index_updated} index records updated"
          f"{' (dry run)' if args.dry_run else ''}")


if __name__ == "__main__":
    main()
