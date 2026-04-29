#!/usr/bin/env bash
# post-pr-telegram.sh — gh pr create PostToolUse
# PR 생성 완료 시 Telegram Bot API로 PR URL 알림 발송
# PostToolUse → exit code 는 무시 (알림 실패가 작업을 막으면 안 됨)

set -uo pipefail

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')

# gh pr create 명령만 처리
if ! printf '%s' "$COMMAND" | grep -qE 'gh[[:space:]]+pr[[:space:]]+create'; then
  exit 0
fi

TOOL_RESPONSE=$(printf '%s' "$INPUT" | jq -r '.tool_response // ""')

# PR URL 추출
PR_URL=$(printf '%s' "$TOOL_RESPONSE" | grep -oE 'https://github\.com/[^[:space:]]+' | head -1)
if [[ -z "$PR_URL" ]]; then
  exit 0
fi

# .env 로드 (절대경로)
for ENV_FILE in \
  "/home/damools/forge/.env" \
  "/home/damools/forge-outputs/11-platform/telegram-workspace/.env"; do
  if [[ -f "$ENV_FILE" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
    break
  fi
done

BOT_TOKEN="${FORGE_AGENT_SERVER_BOT_TOKEN:-${TELEGRAM_BOT_TOKEN:-}}"
CHAT_ID="${FORGE_AGENT_SERVER_BOT_CHAT_ID:-${TELEGRAM_CHAT_ID:-}}"

if [[ -z "$BOT_TOKEN" || -z "$CHAT_ID" ]]; then
  exit 0
fi

TEXT="PR 생성 완료
${PR_URL}"

curl -sS --max-time 10 \
  "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  --data-urlencode "chat_id=${CHAT_ID}" \
  --data-urlencode "text=${TEXT}" \
  >/dev/null 2>&1 || true

exit 0
