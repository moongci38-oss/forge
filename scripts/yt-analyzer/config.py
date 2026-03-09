"""yt-analyzer 설정 모듈"""

import os
from pathlib import Path

# 프로젝트 루트 (business/)
BUSINESS_DIR = Path(__file__).resolve().parent.parent.parent

# .env 파일에서 환경변수 로드 (python-dotenv 없이 직접 파싱)
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

# 출력 경로
OUTPUT_DIR = BUSINESS_DIR / "01-research" / "videos"
ANALYSES_DIR = OUTPUT_DIR / "analyses"
REPORTS_DIR = OUTPUT_DIR / "reports"
CACHE_DIR = OUTPUT_DIR / "cache"
TRANSCRIPT_CACHE_DIR = CACHE_DIR / "transcripts"
METADATA_CACHE_DIR = CACHE_DIR / "metadata"
CATEGORIES_FILE = OUTPUT_DIR / "categories.json"

# 캐시 TTL (초)
CACHE_TTL_DAYS = 30
CACHE_TTL_SECONDS = CACHE_TTL_DAYS * 86400

# YouTube Data API v3 (검색/재생목록용 — Phase 2)
YOUTUBE_API_KEY = os.environ.get("YOUTUBE_API_KEY", "")

# 트랜스크립트 언어 우선순위
TRANSCRIPT_LANG_PRIORITY = ["ko", "en", "ja"]

# 출력 포맷
SUPPORTED_FORMATS = ["summary", "timeline", "mindmap", "full", "blog"]
DEFAULT_FORMAT = "summary"

# 디렉토리 자동 생성
for d in [ANALYSES_DIR, REPORTS_DIR, TRANSCRIPT_CACHE_DIR, METADATA_CACHE_DIR]:
    d.mkdir(parents=True, exist_ok=True)
