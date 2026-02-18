#!/bin/bash
# session-context.sh
# SessionStart
# 세션 시작 시 Memory MCP에서 이전 컨텍스트 로드 안내 출력

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
echo "╚══════════════════════════════════════════════════╝"
