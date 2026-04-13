#!/usr/bin/env bash
# usage-logger.sh — PostToolUse 도구 사용 로거
# JSONL 형식으로 .claude/usage.log에 기록
# stdin에서 Hook JSON을 파싱하여 session_id/도구명/파일경로 추출

LOG_FILE="${PWD}/.claude/usage.log"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Log rotation: 5MB 초과 시 .1로 회전 (보존 1세대)
MAX_SIZE=$((5 * 1024 * 1024))
if [ -f "$LOG_FILE" ]; then
  SIZE=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
  if [ "$SIZE" -gt "$MAX_SIZE" ]; then
    mv "$LOG_FILE" "${LOG_FILE}.1" 2>/dev/null || true
  fi
fi

# stdin에서 Hook JSON 읽기
HOOK_JSON=""
if [ ! -t 0 ]; then
  HOOK_JSON=$(cat 2>/dev/null || true)
fi

# session_id 추출 (Hook JSON 우선, env fallback)
SESSION=$(echo "$HOOK_JSON" | jq -r '.session_id // empty' 2>/dev/null)
[ -z "$SESSION" ] && SESSION="${CLAUDE_SESSION_ID:-unknown}"

# 도구명 추출
TOOL_NAME=$(echo "$HOOK_JSON" | jq -r '.tool_name // .tool // "unknown"' 2>/dev/null)
[ -z "$TOOL_NAME" ] && TOOL_NAME="unknown"

# 파일 경로 추출 (있으면)
FILE_PATH=$(echo "$HOOK_JSON" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null)

# 서브타입 감지
SUBTYPE="tool"
case "$TOOL_NAME" in
  Agent) SUBTYPE="agent" ;;
  Skill) SUBTYPE="skill" ;;
  Read|Glob|Grep) SUBTYPE="search" ;;
  Write|Edit) SUBTYPE="write" ;;
  Bash) SUBTYPE="bash" ;;
  WebFetch|WebSearch) SUBTYPE="web" ;;
esac

# 파일 경로가 있으면 포함, 없으면 생략
if [ -n "$FILE_PATH" ]; then
  echo "{\"ts\":\"$TS\",\"event\":\"tool_use\",\"tool\":\"$TOOL_NAME\",\"subtype\":\"$SUBTYPE\",\"file\":\"$FILE_PATH\",\"session\":\"$SESSION\"}" >> "$LOG_FILE"
else
  echo "{\"ts\":\"$TS\",\"event\":\"tool_use\",\"tool\":\"$TOOL_NAME\",\"subtype\":\"$SUBTYPE\",\"session\":\"$SESSION\"}" >> "$LOG_FILE"
fi
