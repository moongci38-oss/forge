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
    --data-urlencode "text=$1" > /dev/null 2>&1
}

# 실패 시 간단 알림만
if [ "$EXIT_CODE" -ne 0 ]; then
  tg_send "❌ Daily Review 실패 ($TARGET_DATE) — Exit: $EXIT_CODE"
  exit 0
fi

# 리포트 파일 탐색
REPORT=$(find "$HOME/forge-outputs" -path "*/daily/$TARGET_DATE/ai-system-analysis.md" 2>/dev/null | head -1)

if [ -z "$REPORT" ]; then
  tg_send "✅ Daily Review 완료 ($TARGET_DATE)
⚠️ 리포트 파일 미생성"
  exit 0
fi

# Executive Summary 추출
EXEC=$(awk '/^## Executive Summary/,/^---/' "$REPORT" | sed '1d;$d' | sed '/^$/d' | head -1)

# Critical/High/P0 액션 추출 (여러 형식 지원)
CRITICAL=$(awk '/^### Critical|^## .*P0/,/^### High|^## .*P1/' "$REPORT" | grep -E "^\*\*\[GAP-C|^- \[C|^- P0-" | head -3 | sed "s/^\*\*\[//;s/\]\*\*/: /;s/^- //")
if [ -z "$CRITICAL" ]; then
  CRITICAL=$(awk '/^### Critical|^## .*P0/,/^### High|^## .*P1/' "$REPORT" | grep -v "^###\|^##\|^---" | grep -E "^\-|^•" | head -3)
fi

# 평가 스코어 추출 (여러 형식 지원)
SCORE=$(grep -m1 -E '평가:|^평가 ' "$REPORT" | head -1)

# 주요 갭/액션 추출
SUMMARY=$(awk '/^##.*갭 분석|^## 4./,/^##/' "$REPORT" | grep "^\*\*\[GAP-" | head -2 | sed "s/^\*\*\[//;s/\]\*\*/: /;s/ — / → /")

# 통합 메시지
MSG="📊 Daily Review — $TARGET_DATE

── Executive Summary ──
$EXEC"

if [ -n "$SCORE" ]; then
  MSG="$MSG

── 평가 ──
$SCORE"
fi

if [ -n "$CRITICAL" ]; then
  MSG="$MSG

── Critical 즉시 대응 ──
$(echo "$CRITICAL" | sed 's/^/• /')"
fi

if [ -n "$SUMMARY" ]; then
  MSG="$MSG

── 주요 갭 분석 ──
$(echo "$SUMMARY" | sed 's/^/• /')"
fi

tg_send "$MSG"
