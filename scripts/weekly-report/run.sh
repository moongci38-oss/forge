#!/bin/bash
# ──────────────────────────────────────────────
# 주간 리서치 리포트 + 뉴스레터 자동 생성 스크립트
# Claude Code CLI (Max 구독) 기반
# cron: 0 0 * * 1 (매주 월요일 00:00 UTC = KST 09:00)
# ──────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUSINESS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/$(date +%Y-W%V).log"
ALLOWED_TOOLS="WebSearch,WebFetch,Write,Read,Glob"

mkdir -p "$LOG_DIR"

# 중첩 세션 방지 변수 해제 (수동 테스트 시 필요)
unset CLAUDECODE 2>/dev/null || true

cd "$BUSINESS_DIR"

# ── Step 1: 주간 리서치 리포트 ──
echo "=== Step 1: Weekly Report ===" | tee -a "$LOG_FILE"
echo "Started: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"

claude -p "/weekly-report" \
  --allowedTools "$ALLOWED_TOOLS" \
  2>&1 | tee -a "$LOG_FILE"

REPORT_EXIT=${PIPESTATUS[0]}
echo "Report exit code: $REPORT_EXIT" | tee -a "$LOG_FILE"

# ── Step 2: 뉴스레터 (리포트 성공 시만) ──
if [ "$REPORT_EXIT" -eq 0 ]; then
  echo "" | tee -a "$LOG_FILE"
  echo "=== Step 2: Newsletter ===" | tee -a "$LOG_FILE"
  echo "Started: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"

  claude -p "/newsletter" \
    --allowedTools "$ALLOWED_TOOLS" \
    2>&1 | tee -a "$LOG_FILE"

  NEWSLETTER_EXIT=${PIPESTATUS[0]}
  echo "Newsletter exit code: $NEWSLETTER_EXIT" | tee -a "$LOG_FILE"
else
  echo "Skipping newsletter (report failed)" | tee -a "$LOG_FILE"
  NEWSLETTER_EXIT=1
fi

echo "" | tee -a "$LOG_FILE"
echo "Finished: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"
echo "Report: $REPORT_EXIT | Newsletter: $NEWSLETTER_EXIT" | tee -a "$LOG_FILE"

exit "$REPORT_EXIT"
