#!/bin/bash
# pingame-server pnpm audit — 주 1회 실행, Telegram 결과 전송
# cron: 0 10 * * 1 (월요일 10:00 KST)

set -euo pipefail
PINGAME_DIR="$HOME/mywsl_workspace/pingame-server"

RESULT=$(cd "$PINGAME_DIR" && pnpm audit --audit-level high 2>&1 | tail -8)
EXIT_CODE=$?

TG_MSG="🔍 *pingame-server audit* ($(date '+%Y-%m-%d'))

\`\`\`
$RESULT
\`\`\`"

bash "$(dirname "$0")/tg-send.sh" "$TG_MSG" 2>/dev/null || true
exit 0
