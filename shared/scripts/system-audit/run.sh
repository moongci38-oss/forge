#!/bin/bash
# ──────────────────────────────────────────────
# 월간 시스템 감사 자동 실행 스크립트
# cron: 0 0 1 * * (매월 1일 00:00 UTC = KST 09:00)
# ──────────────────────────────────────────────

set -euo pipefail

export HOME="${HOME:-$(getent passwd "$(whoami)" | cut -d: -f6)}"
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORGE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).log"
AUDIT_DATE="$(date +%Y-%m-%d)"

mkdir -p "$LOG_DIR"

unset CLAUDECODE 2>/dev/null || true

cd "$FORGE_DIR"

echo "=== Monthly System Audit ===" | tee -a "$LOG_FILE"
echo "Started: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"
echo "Audit date: $AUDIT_DATE" | tee -a "$LOG_FILE"

# Claude Code CLI로 감사 실행
echo "--- Claude 감사 실행 ---" | tee -a "$LOG_FILE"
"$HOME/.local/bin/claude" -p "/system-audit" \
  --allowedTools "Agent,Read,Write,Glob,Grep,WebSearch" \
  --model sonnet \
  2>&1 | tee -a "$LOG_FILE" || {
    EXIT_CODE=$?
    echo "ERROR: Claude 감사 실패 (exit code: $EXIT_CODE)" | tee -a "$LOG_FILE"
    echo "Finished: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"
    exit "$EXIT_CODE"
  }

echo "Finished: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"
exit 0
