#!/bin/bash
# ──────────────────────────────────────────────
# yt-analyzer — YouTube 영상 분석 래퍼
# Usage: bash run.sh "https://youtu.be/xxxxx"
#        bash run.sh --urls urls.txt
# ──────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUSINESS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Python 경로
PYTHON="python3"

# 의존성 확인
if ! "$PYTHON" -c "import youtube_transcript_api" 2>/dev/null; then
    echo "Installing youtube-transcript-api..."
    pip3 install --user youtube-transcript-api
fi

# 실행
cd "$SCRIPT_DIR"
"$PYTHON" yt-analyzer.py "$@"
