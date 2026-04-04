#!/bin/bash
# workspace-build.sh — 워크스페이스 RAG 증분 빌드 (cron용)
# 사용: bash workspace-build.sh [--rebuild]
#
# cron 등록 예시 (4시간마다):
#   17 */4 * * * bash ~/forge/shared/scripts/rag/workspace-build.sh >> ~/.rag-workspace-index/build.log 2>&1

set -euo pipefail

FORGE_ROOT="${FORGE_ROOT:-$HOME/forge}"
SCRIPT_DIR="$FORGE_ROOT/shared/scripts/rag"
LOG_DIR="${HOME}/.rag-workspace-index"
LOG_FILE="$LOG_DIR/build.log"

# 로그 디렉토리 생성
mkdir -p "$LOG_DIR"

# 로그 로테이션: 5MB 초과 시 기존 로그 백업
if [ -f "$LOG_FILE" ] && [ "$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)" -gt 5242880 ]; then
    mv "$LOG_FILE" "${LOG_FILE}.bak"
fi

echo "========================================"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 워크스페이스 RAG 증분 빌드 시작"
echo "FORGE_ROOT: $FORGE_ROOT"
echo "========================================"

# .env 로드 (OpenAI 키 등)
if [ -f "$FORGE_ROOT/.env" ]; then
    set -a
    # shellcheck disable=SC1090
    source "$FORGE_ROOT/.env"
    set +a
fi

# Python 환경 확인
PYTHON="${PYTHON:-python3}"
if ! command -v "$PYTHON" &>/dev/null; then
    echo "❌ Python3 없음"
    exit 1
fi

# 증분 빌드 실행
if [ "${1:-}" = "--rebuild" ]; then
    echo "🔨 전체 재빌드 모드"
    "$PYTHON" "$SCRIPT_DIR/index.py" --workspace --rebuild
else
    "$PYTHON" "$SCRIPT_DIR/index.py" --workspace --incremental
fi

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ 완료"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ 실패 (exit: $EXIT_CODE)"
fi

exit $EXIT_CODE
