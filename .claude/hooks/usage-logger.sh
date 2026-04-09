#!/usr/bin/env bash
# usage-logger.sh — PostToolUse 도구 사용 로거
# JSONL 형식으로 .claude/usage.log에 기록
# stdin에서 Hook JSON을 파싱하여 도구명/파일경로 추출

LOG_FILE="${PWD}/.claude/usage.log"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION="${CLAUDE_SESSION_ID:-unknown}"

# stdin에서 Hook JSON 읽기
HOOK_JSON=""
if [ ! -t 0 ]; then
  HOOK_JSON=$(cat 2>/dev/null || true)
fi

# 도구명 추출 (tool_name 또는 tool_input에서)
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
