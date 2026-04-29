#!/bin/bash
# tg-report-weekly.sh — Weekly Research 완료 시 Telegram 리포트 전송
# Usage: bash tg-report-weekly.sh <TARGET_DATE> <EXIT_CODE>

TARGET_DATE="${1:-$(date +%Y-%m-%d)}"
EXIT_CODE="${2:-0}"
WEEK=$(date -d "$TARGET_DATE" +%Y-W%V 2>/dev/null || date +%Y-W%V)

TG_ENV="$HOME/forge-outputs/11-platform/telegram-workspace/.env"
[ -f "$TG_ENV" ] && export $(grep -v '^#' "$TG_ENV" | grep -E '^(FORGE_AGENT_SERVER_BOT_TOKEN|OWNER_CHAT_ID)=' | xargs) 2>/dev/null || true

TOKEN="${FORGE_AGENT_SERVER_BOT_TOKEN:-}"
CHAT_ID="${OWNER_CHAT_ID:-}"

[ -z "$TOKEN" ] || [ -z "$CHAT_ID" ] && { echo "[tg-report] SKIP: no token/chat_id" >&2; exit 0; }

tg_send() {
  curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
    -d "chat_id=${CHAT_ID}" \
    -d "parse_mode=Markdown" \
    --data-urlencode "text=$1" > /dev/null 2>&1
}

if [ "$EXIT_CODE" -ne 0 ]; then
  tg_send "❌ *Weekly Research 실패* ($WEEK) — Exit: $EXIT_CODE"
  exit 0
fi

# 리포트 파일 탐색
REPORT=$(find "$HOME/forge-outputs" -path "*/weekly/$TARGET_DATE/*.md" ! -name "index.json" 2>/dev/null | head -1)

if [ -z "$REPORT" ]; then
  tg_send "✅ *Weekly Research 완료* ($WEEK)\n⚠️ 리포트 파일 미생성"
  exit 0
fi

# 파일 상위 60줄 요약 전송
CONTENT=$(head -60 "$REPORT" | grep -v "^---$" | head -40)

tg_send "📈 *Weekly Research — $WEEK*

$CONTENT"
