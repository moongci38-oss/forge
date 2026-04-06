#!/bin/bash
# ──────────────────────────────────────────────
# Learnings 승격 후보 리포트 자동 생성 스크립트
# promote-learnings.sh 래퍼 — 출력을 forge-outputs/docs/reviews/ 에 저장
# cron: 3 9 * * 1 (매주 월요일 09:03 KST, weekly-research 직후)
# ──────────────────────────────────────────────

set -euo pipefail

export HOME="${HOME:-$(getent passwd "$(whoami)" | cut -d: -f6)}"
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:$PATH"
export FORGE_ROOT="$HOME/forge"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
RUN_DATE="$(date +%Y-%m-%d)"
LOG_FILE="$LOG_DIR/$RUN_DATE.log"
OUTPUT_DIR="$HOME/forge-outputs/docs/reviews"
OUTPUT_FILE="$OUTPUT_DIR/${RUN_DATE}-learnings-promotion-report.md"
PROMOTE_SCRIPT="$HOME/forge/.claude/scripts/promote-learnings.sh"

mkdir -p "$LOG_DIR" "$OUTPUT_DIR"

echo "=== Promote Learnings ===" | tee -a "$LOG_FILE"
echo "Started: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"
echo "Output: $OUTPUT_FILE" | tee -a "$LOG_FILE"

if [ ! -f "$PROMOTE_SCRIPT" ]; then
  echo "ERROR: promote-learnings.sh not found at $PROMOTE_SCRIPT" | tee -a "$LOG_FILE"
  exit 1
fi

bash "$PROMOTE_SCRIPT" > "$OUTPUT_FILE" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "SUCCESS: Report saved to $OUTPUT_FILE" | tee -a "$LOG_FILE"
  LINE_COUNT=$(wc -l < "$OUTPUT_FILE")
  echo "Report size: $LINE_COUNT lines" | tee -a "$LOG_FILE"
else
  echo "ERROR: promote-learnings.sh exited with code $EXIT_CODE" | tee -a "$LOG_FILE"
fi

echo "Finished: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"

exit "$EXIT_CODE"
