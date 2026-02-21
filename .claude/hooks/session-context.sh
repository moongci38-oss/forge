#!/bin/bash
# session-context.sh
# SessionStart
# 세션 시작 시 배너 출력 + 멀티세션 상태 확인

TODAY=$(date +%Y-%m-%d)
WEEKDAY=$(date +%A)

echo "╔══════════════════════════════════════════════════╗"
echo "║  🏢 Business Workspace — Session Start           ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║  📅 $(date '+%Y-%m-%d %H:%M')  ($WEEKDAY)"
echo "╠══════════════════════════════════════════════════╣"
echo "║  📌 세션 시작 체크리스트                          ║"
echo "║    1. Memory MCP에서 이전 컨텍스트 확인           ║"
echo "║       → mcp__memory__search_nodes 호출            ║"
echo "║    2. Track A 우선 (제품사업) / B 접근 금지        ║"
echo "║    3. 새 파일: YYYY-MM-DD-{name}.md 형식          ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║  ⛔ 접근 제한: 06-finance  07-legal               ║"
echo "║                08-admin/insurance  /freelancers   ║"
echo "╠══════════════════════════════════════════════════╣"

# 멀티세션 상태 확인
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SESSIONS_DIR="$PROJECT_DIR/.claude/state/sessions"

if [ -d "$SESSIONS_DIR" ]; then
  COUNT=$(ls -1 "$SESSIONS_DIR"/*.json 2>/dev/null | wc -l)
  if [ "$COUNT" -gt 0 ]; then
    echo "║  📋 활성 세션 ${COUNT}개 발견:                       ║"
    for f in "$SESSIONS_DIR"/*.json; do
      NAME=$(basename "$f" .json)
      PHASE=$(jq -r '.currentPhase // "?"' "$f" 2>/dev/null)
      printf "║     %-20s %s\n" "$NAME" "$PHASE          ║"
    done
    echo "║     → /resume 으로 재개 가능                     ║"
  else
    echo "║  📋 이전 세션 없음 (신규 시작)                    ║"
  fi
else
  echo "║  📋 이전 세션 없음 (신규 시작)                    ║"
fi

echo "╚══════════════════════════════════════════════════╝"
