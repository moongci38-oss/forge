#!/bin/bash
# ──────────────────────────────────────────────
# 주간 리서치 리포트 자동 생성 스크립트
# Claude Code CLI (Max 구독) 기반
# cron: 0 0 * * 1 (매주 월요일 00:00 UTC = KST 09:00)
# ──────────────────────────────────────────────

set -euo pipefail

# cron 환경에서 HOME/PATH가 미설정될 수 있으므로 명시적으로 설정
# HOME이 이미 설정된 경우 그대로 사용, 미설정 시 현재 사용자 홈 디렉토리 사용
export HOME="${HOME:-$(getent passwd "$(whoami)" | cut -d: -f6)}"
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUSINESS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/$(date +%Y-W%V).log"
ALLOWED_TOOLS="WebSearch,WebFetch,Write,Read,Glob,Grep,Agent"

mkdir -p "$LOG_DIR"

# 중첩 세션 방지 변수 해제 (수동 테스트 시 필요)
unset CLAUDECODE 2>/dev/null || true

cd "$BUSINESS_DIR"

echo "=== Weekly Research Report ===" | tee -a "$LOG_FILE"
echo "Started: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"

"$HOME/.local/bin/claude" -p "/weekly-research $(date +%Y-%m-%d)" \
  --allowedTools "$ALLOWED_TOOLS" \
  2>&1 | tee -a "$LOG_FILE"

EXIT_CODE=${PIPESTATUS[0]}
echo "Exit code: $EXIT_CODE" | tee -a "$LOG_FILE"
echo "Finished: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" | tee -a "$LOG_FILE"

exit "$EXIT_CODE"
