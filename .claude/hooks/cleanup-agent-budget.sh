#!/usr/bin/env bash
# cleanup-agent-budget.sh — Stop hook
# 세션 종료 시 agent-budget 카운트/에러 파일을 정리하고 요약을 usage.log에 기록

BUDGET_DIR="${PWD}/.claude/agent-budget"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE="${PWD}/.claude/usage.log"

# stdin Hook JSON에서 session_id 추출
HOOK_JSON=""
if [ ! -t 0 ]; then
  HOOK_JSON=$(cat 2>/dev/null || true)
fi
SESSION=$(echo "$HOOK_JSON" | jq -r '.session_id // empty' 2>/dev/null)
[ -z "$SESSION" ] && SESSION="${CLAUDE_SESSION_ID:-unknown}"

if [ ! -d "$BUDGET_DIR" ]; then
  exit 0
fi

COUNT_FILE="$BUDGET_DIR/${SESSION}.count"
ERROR_FILE="$BUDGET_DIR/${SESSION}.errors"

# 세션 요약 기록
if [ -f "$COUNT_FILE" ]; then
  COUNT=$(cat "$COUNT_FILE")
  ERROR_COUNT=0
  if [ -f "$ERROR_FILE" ]; then
    ERROR_COUNT=$(wc -l < "$ERROR_FILE")
  fi

  printf '{"ts":"%s","event":"session_budget_summary","session":"%s","total_tool_calls":%d,"total_errors":%d}\n' \
    "$TS" "$SESSION" "$COUNT" "$ERROR_COUNT" >> "$LOG_FILE"
fi

# 현재 세션 파일 정리
rm -f "$COUNT_FILE" "$ERROR_FILE"

# 1일 이상 된 파일 정리
find "$BUDGET_DIR" -name "*.count" -mtime +1 -delete 2>/dev/null
find "$BUDGET_DIR" -name "*.errors" -mtime +1 -delete 2>/dev/null

# 디렉토리가 비었으면 삭제
rmdir "$BUDGET_DIR" 2>/dev/null

exit 0
