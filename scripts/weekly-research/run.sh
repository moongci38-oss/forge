#!/bin/bash
# ──────────────────────────────────────────────
# 주간 리서치 리포트 자동 생성 스크립트 (v2)
# Python 수집 계층 추가 버전
# cron: 0 0 * * 1 (매주 월요일 00:00 UTC = KST 09:00)
# ──────────────────────────────────────────────

set -euo pipefail

export HOME="${HOME:-$(getent passwd "$(whoami)" | cut -d: -f6)}"
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUSINESS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/$(date +%Y-W%V).log"
TARGET_DATE="$(date +%Y-%m-%d)"

mkdir -p "$LOG_DIR"

unset CLAUDECODE 2>/dev/null || true

cd "$BUSINESS_DIR"

echo "=== Weekly Research (v2) ===" | tee -a "$LOG_FILE"
echo "Started: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"
echo "Target date: $TARGET_DATE" | tee -a "$LOG_FILE"

# Step 1: Python 수집기 실행 → raw-data.json 생성
echo "--- Step 1: Python 수집기 ---" | tee -a "$LOG_FILE"
RAW_JSON="$BUSINESS_DIR/01-research/weekly/$TARGET_DATE/raw-data.json"

if [ -f "$RAW_JSON" ]; then
  echo "raw-data.json 이미 존재 — 수집 스킵" | tee -a "$LOG_FILE"
else
  python3 "$SCRIPT_DIR/collector.py" "$TARGET_DATE" 2>&1 | tee -a "$LOG_FILE" || {
    echo "WARN: collector.py 실패 — Claude가 런타임에 직접 검색" | tee -a "$LOG_FILE"
  }
fi

# Step 2: Claude Code CLI로 분석 실행
echo "--- Step 2: Claude 분석 ---" | tee -a "$LOG_FILE"
"$HOME/.local/bin/claude" << EOF 2>&1 | tee -a "$LOG_FILE"
/weekly-research $TARGET_DATE
EOF

EXIT_CODE=${PIPESTATUS[0]}
echo "Exit code: $EXIT_CODE" | tee -a "$LOG_FILE"
echo "Finished: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"

exit "$EXIT_CODE"
