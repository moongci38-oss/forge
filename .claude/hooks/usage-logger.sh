#!/usr/bin/env bash
# usage-logger.sh — PostToolUse 도구 사용 로거
# JSONL 형식으로 .claude/usage.log에 기록
# stdin에서 Hook JSON을 파싱하여 session_id/도구명/파일경로/에러 추출
#
# 버전 2 (2026-04-20): unknown 34.6% 버그 수정
# - 빈 Hook JSON 입력 시 로깅 스킵 (unknown 쓰레기 방지)
# - tool_response.is_error 감지 → 별도 tool_error 이벤트 기록
# - debug 로그 옵션 (USAGE_LOGGER_DEBUG=1 설정 시 raw JSON 덤프)
# - jq 미설치/실패 시 python3 fallback

LOG_FILE="${PWD}/.claude/usage.log"
DEBUG_LOG="${PWD}/.claude/usage-logger-debug.log"
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

# 디버그 모드: 환경변수 USAGE_LOGGER_DEBUG=1이면 raw stdin 최근 50건만 회전 저장
if [ "${USAGE_LOGGER_DEBUG:-0}" = "1" ] && [ -n "$HOOK_JSON" ]; then
  mkdir -p "$(dirname "$DEBUG_LOG")"
  echo "---$TS---" >> "$DEBUG_LOG"
  echo "$HOOK_JSON" | head -c 2000 >> "$DEBUG_LOG"
  echo "" >> "$DEBUG_LOG"
  # Keep last 50 entries only
  if [ -f "$DEBUG_LOG" ]; then
    LINES=$(wc -l < "$DEBUG_LOG" 2>/dev/null || echo 0)
    if [ "$LINES" -gt 500 ]; then
      tail -400 "$DEBUG_LOG" > "${DEBUG_LOG}.tmp" && mv "${DEBUG_LOG}.tmp" "$DEBUG_LOG"
    fi
  fi
fi

# Hook JSON이 비어있으면 로깅 스킵 (unknown 쓰레기 방지)
# Hook 컨텍스트에 따라 stdin이 없을 수 있음 (예: 일부 정책 훅)
if [ -z "$HOOK_JSON" ]; then
  exit 0
fi

# jq 또는 python3 fallback 파서
parse_field() {
  local path="$1"
  local val=""
  if command -v jq >/dev/null 2>&1; then
    val=$(echo "$HOOK_JSON" | jq -r "$path // empty" 2>/dev/null)
  fi
  # jq 실패 시 python3 fallback
  if [ -z "$val" ] && command -v python3 >/dev/null 2>&1; then
    val=$(echo "$HOOK_JSON" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    # path를 JQ 표기에서 Python dict 접근으로 변환
    # e.g. '.session_id' → data.get('session_id')
    path = '$path'.lstrip('.')
    parts = path.split('.')
    result = data
    for part in parts:
        if isinstance(result, dict):
            result = result.get(part)
        else:
            result = None
            break
    print(result if result is not None else '')
except Exception:
    pass
" 2>/dev/null)
  fi
  echo "$val"
}

# session_id 추출
SESSION=$(parse_field ".session_id")
[ -z "$SESSION" ] && SESSION="${CLAUDE_SESSION_ID:-unknown}"

# 도구명 추출 — 더 많은 fallback 경로 시도
TOOL_NAME=$(parse_field ".tool_name")
[ -z "$TOOL_NAME" ] && TOOL_NAME=$(parse_field ".tool")
[ -z "$TOOL_NAME" ] && TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"

# 여전히 unknown이고 디버그 모드 아니면, 최소한 event type이라도 기록
if [ "$TOOL_NAME" = "unknown" ]; then
  EVENT_TYPE=$(parse_field ".hook_event_name")
  [ -z "$EVENT_TYPE" ] && EVENT_TYPE=$(parse_field ".event")
  if [ -n "$EVENT_TYPE" ]; then
    TOOL_NAME="event:${EVENT_TYPE}"
  fi
fi

# 파일 경로 추출 (있으면)
FILE_PATH=$(parse_field ".tool_input.file_path")
[ -z "$FILE_PATH" ] && FILE_PATH=$(parse_field ".tool_input.path")

# 서브타입 감지
SUBTYPE="tool"
case "$TOOL_NAME" in
  Agent) SUBTYPE="agent" ;;
  Skill) SUBTYPE="skill" ;;
  Read|Glob|Grep) SUBTYPE="search" ;;
  Write|Edit|NotebookEdit) SUBTYPE="write" ;;
  Bash) SUBTYPE="bash" ;;
  WebFetch|WebSearch) SUBTYPE="web" ;;
  mcp__*) SUBTYPE="mcp" ;;
  event:*) SUBTYPE="event" ;;
esac

# Bash 명령의 경우 명령 접두어 추출 (분류용)
BASH_CATEGORY=""
if [ "$TOOL_NAME" = "Bash" ]; then
  CMD=$(parse_field ".tool_input.command")
  if [ -n "$CMD" ]; then
    # 첫 토큰 추출 (예: "pm2 list" → "pm2")
    FIRST_TOKEN=$(echo "$CMD" | head -c 200 | awk '{print $1}' | tr -d '"'"'"'')
    # 파이프/리다이렉션 제거
    FIRST_TOKEN=$(echo "$FIRST_TOKEN" | sed 's/[|<>].*//' | head -c 40)
    if [ -n "$FIRST_TOKEN" ]; then
      BASH_CATEGORY="$FIRST_TOKEN"
    fi
  fi
fi

# 에러 감지 — tool_response.is_error
IS_ERROR=$(parse_field ".tool_response.is_error")
ERROR_MSG=""
if [ "$IS_ERROR" = "True" ] || [ "$IS_ERROR" = "true" ]; then
  ERROR_MSG=$(parse_field ".tool_response.content" | head -c 200 | tr -d '\n' | sed 's/"/\\"/g')
fi

# 메인 이벤트 기록
if [ -n "$FILE_PATH" ]; then
  echo "{\"ts\":\"$TS\",\"event\":\"tool_use\",\"tool\":\"$TOOL_NAME\",\"subtype\":\"$SUBTYPE\",\"file\":\"$FILE_PATH\",\"session\":\"$SESSION\"}" >> "$LOG_FILE"
elif [ -n "$BASH_CATEGORY" ]; then
  echo "{\"ts\":\"$TS\",\"event\":\"tool_use\",\"tool\":\"$TOOL_NAME\",\"subtype\":\"$SUBTYPE\",\"bash_cmd\":\"$BASH_CATEGORY\",\"session\":\"$SESSION\"}" >> "$LOG_FILE"
else
  echo "{\"ts\":\"$TS\",\"event\":\"tool_use\",\"tool\":\"$TOOL_NAME\",\"subtype\":\"$SUBTYPE\",\"session\":\"$SESSION\"}" >> "$LOG_FILE"
fi

# 에러 이벤트 별도 기록
if [ -n "$ERROR_MSG" ]; then
  echo "{\"ts\":\"$TS\",\"event\":\"tool_error\",\"tool\":\"$TOOL_NAME\",\"session\":\"$SESSION\",\"message\":\"$ERROR_MSG\"}" >> "$LOG_FILE"
fi

exit 0
