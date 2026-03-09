"""파일 기반 JSON 캐시"""

import json
import time
from pathlib import Path
from config import TRANSCRIPT_CACHE_DIR, METADATA_CACHE_DIR, CACHE_TTL_SECONDS


def _cache_path(video_id: str, cache_type: str) -> Path:
    cache_dir = TRANSCRIPT_CACHE_DIR if cache_type == "transcript" else METADATA_CACHE_DIR
    return cache_dir / f"{video_id}.json"


def is_fresh(video_id: str, cache_type: str = "transcript") -> bool:
    path = _cache_path(video_id, cache_type)
    if not path.exists():
        return False
    age = time.time() - path.stat().st_mtime
    return age < CACHE_TTL_SECONDS


def get(video_id: str, cache_type: str = "transcript") -> dict | None:
    path = _cache_path(video_id, cache_type)
    if not path.exists():
        return None
    if not is_fresh(video_id, cache_type):
        return None
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def put(video_id: str, data: dict, cache_type: str = "transcript") -> Path:
    path = _cache_path(video_id, cache_type)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    return path
