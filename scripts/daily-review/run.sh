#!/bin/bash
# ──────────────────────────────────────────────
# AI 시스템 일일 분석 자동 실행 스크립트 (v2)
# Python 수집 계층 추가 버전
# cron: 0 0 * * 2-7,0 (화~일 00:00 UTC = KST 09:00)
# 월요일은 weekly-research가 커버하므로 제외
# ──────────────────────────────────────────────

set -euo pipefail

export HOME="${HOME:-$(getent passwd "$(whoami)" | cut -d: -f6)}"
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUSINESS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).log"
TARGET_DATE="$(date -d 'yesterday' +%Y-%m-%d)"

mkdir -p "$LOG_DIR"

unset CLAUDECODE 2>/dev/null || true

cd "$BUSINESS_DIR"

echo "=== Daily Review (v2) ===" | tee -a "$LOG_FILE"
echo "Started: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"
echo "Target date: $TARGET_DATE" | tee -a "$LOG_FILE"

# Step 1: Python 수집기 실행 → raw-data.json 생성
echo "--- Step 1: Python 수집기 ---" | tee -a "$LOG_FILE"
RAW_JSON="$BUSINESS_DIR/01-research/daily/$TARGET_DATE/raw-data.json"

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
/daily-system-review $TARGET_DATE
EOF

EXIT_CODE=${PIPESTATUS[0]}
echo "Exit code: $EXIT_CODE" | tee -a "$LOG_FILE"
echo "Finished: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"

exit "$EXIT_CODE"
