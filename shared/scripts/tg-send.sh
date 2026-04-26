#!/bin/bash
# tg-send.sh — Telegram 메시지 전송 헬퍼 (forge-agent-server-bot 사용)
# Usage: bash tg-send.sh "메시지 텍스트"
# Env: FORGE_AGENT_SERVER_BOT_TOKEN, OWNER_CHAT_ID (auto-sourced from telegram-workspace/.env)

TG_ENV="$HOME/forge-outputs/11-platform/telegram-workspace/.env"
if [ -f "$TG_ENV" ]; then
  export $(grep -v '^#' "$TG_ENV" | grep -E '^(FORGE_AGENT_SERVER_BOT_TOKEN|OWNER_CHAT_ID)=' | xargs) 2>/dev/null || true
fi

TOKEN="${FORGE_AGENT_SERVER_BOT_TOKEN:-}"
CHAT_ID="${OWNER_CHAT_ID:-}"
MSG="${1:-}"

if [ -z "$TOKEN" ] || [ -z "$CHAT_ID" ] || [ -z "$MSG" ]; then
  echo "[tg-send] SKIP: TOKEN/CHAT_ID/MSG missing" >&2
  exit 0
fi

curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}" \
  -d "text=${MSG}" \
  -d "parse_mode=Markdown" \
  > /dev/null 2>&1 || echo "[tg-send] WARN: send failed" >&2
