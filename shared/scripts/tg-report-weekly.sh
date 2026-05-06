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
    --data-urlencode "text=$1" > /dev/null 2>&1
}

if [ "$EXIT_CODE" -ne 0 ]; then
  tg_send "❌ Weekly Research 실패 ($WEEK) — Exit: $EXIT_CODE"
  exit 0
fi

# 주간 리포트 파일 탐색 (tech-trends, biz-trends 중 하나)
REPORT=$(find "$HOME/forge-outputs" -path "*/weekly/$TARGET_DATE/*.md" \
  \( -name "tech-trends.md" -o -name "biz-trends.md" \) 2>/dev/null | head -1)

if [ -z "$REPORT" ]; then
  tg_send "✅ Weekly Research 완료 ($WEEK)
⚠️ 리포트 파일 미생성"
  exit 0
fi

# 제목 추출
TITLE=$(head -1 "$REPORT" | sed 's/^# //')

# Executive Summary/Overview 추출 (첫 번째 주요 섹션 앞까지)
SUMMARY=$(awk '/^##.*카테고리|^##.*트렌드|^## 1\./,/^##/' "$REPORT" | \
  grep -E "^\*\*핵심|^\*\*Forge|^-" | head -6 | sed 's/^\*\*//;s/\*\*$//')

# Top 3 주요 뉴스/카테고리 추출
TOP=$(awk '/^### [0-9]/{n++} n<=3' "$REPORT" | grep -E "^### " | sed 's/^### //;s/ \*\*\[신뢰도.*//;s/ — .*//')

# 통합 메시지
MSG="📈 Weekly Research — $WEEK

── $TITLE ──

── 주요 영역 ──
$(echo "$TOP" | head -3 | sed 's/^/• /')"

INSIGHTS=$(grep -A1 "^**Forge 적용 인사이트:**" "$REPORT" | grep "^-" | head -3 | sed 's/^- /• /')
if [ -n "$INSIGHTS" ]; then
  MSG="$MSG

── Forge 인사이트 ──
$INSIGHTS"
fi

RECS=$(awk '/^## .*추천|^## 주요 시사/' "$REPORT" | \
  grep -E "^### |^- " | head -5 | sed 's/^### //;s/^- /• /')
if [ -n "$RECS" ]; then
  MSG="$MSG

── 주요 액션 아이템 ──
$RECS"
fi

tg_send "$MSG"
