#!/bin/bash
# tg-report-daily.sh — Daily Review 완료 시 Telegram 리포트 전송
# Usage: bash tg-report-daily.sh <TARGET_DATE> <EXIT_CODE>

TARGET_DATE="${1:-$(date -d 'yesterday' +%Y-%m-%d)}"
EXIT_CODE="${2:-0}"

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

# 실패 시 간단 알림만
if [ "$EXIT_CODE" -ne 0 ]; then
  tg_send "❌ *Daily Review 실패* ($TARGET_DATE) — Exit: $EXIT_CODE"
  exit 0
fi

# 리포트 파일 탐색
REPORT=$(find "$HOME/forge-outputs" -path "*/daily/$TARGET_DATE/ai-system-analysis.md" 2>/dev/null | head -1)

if [ -z "$REPORT" ]; then
  tg_send "✅ *Daily Review 완료* ($TARGET_DATE)\n⚠️ 리포트 파일 미생성"
  exit 0
fi

# Executive Summary 추출 (## Executive Summary ~ 다음 --- 전까지)
EXEC=$(awk '/^## Executive Summary/,/^---/' "$REPORT" | grep -v "^##\|^---" | head -6 | sed 's/^[0-9]\+\. /• /')

# Critical/High 항목 추출
CRITICAL=$(grep -A2 "^### Critical\|^#### C-[0-9]:\|^#### H-[0-9]:" "$REPORT" | grep "^\*\*C-\|^\*\*H-\|^- 조치:" | head -8 | sed 's/^\*\*//' | sed 's/\*\*//')

# 메시지 1: Summary
tg_send "📊 *Daily Review — $TARGET_DATE*

*Executive Summary*
$EXEC"

# 메시지 2: P0 액션 (Critical 있을 때만)
if [ -n "$CRITICAL" ]; then
  P0_MSG=$(awk '/^### Critical/,/^### High/' "$REPORT" | grep -v "^### \|^---" | head -20 | sed 's/^\*\*C-[0-9]: /🚨 */' | sed 's/^- 배경:/배경:/' | sed 's/^- 위험:/⚠️ /' | sed 's/^- 조치:/→ /')
  tg_send "🚨 *P0 즉시 조치*

$P0_MSG"
fi

# 메시지 3: High + Medium 요약
HIGH_MED=$(awk '/^### High/,/^### Low/' "$REPORT" | grep "^\*\*H-\|^\*\*M-\|^- 조치:" | head -10 | sed 's/^\*\*[HM]-[0-9]: /• /' | sed 's/\*\*$//' | sed 's/^- 조치:/  →/')
if [ -n "$HIGH_MED" ]; then
  tg_send "⚠️ *High/Medium 항목*

$HIGH_MED"
fi
