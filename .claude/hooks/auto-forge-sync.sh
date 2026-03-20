#!/bin/bash
# auto-forge-sync.sh — forge/dev/ 파일 수정 시 자동 sync 실행
# PostToolUse(Edit|Write) 훅으로 실행
#
# 디바운스: 마지막 sync 후 30초 이내 재실행 방지
# 조건: forge 워크스페이스에서만 동작

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
SYNC_SCRIPT="$HOME/.claude/scripts/forge-sync.mjs"
LOCK_FILE="/tmp/forge-sync-last-run"
DEBOUNCE_SEC=30

# forge 워크스페이스가 아니면 스킵
if [[ "$PWD" != */forge* ]]; then
  exit 0
fi

# forge-sync.mjs 미설치면 스킵
if [[ ! -f "$SYNC_SCRIPT" ]]; then
  exit 0
fi

# 수정된 파일 경로 추출
FILE_PATH=""
if echo "$TOOL_INPUT" | grep -q '"file_path"'; then
  FILE_PATH=$(echo "$TOOL_INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"//')
fi

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# forge/dev/rules/ 또는 forge/dev/templates/ 수정인지 확인
if [[ "$FILE_PATH" == *"forge/dev/rules/"* ]] || \
   [[ "$FILE_PATH" == *"forge/dev/templates/"* ]] || \
   [[ "$FILE_PATH" == *".claude/forge/rules/"* ]] || \
   [[ "$FILE_PATH" == *".claude/forge/templates/"* ]]; then

  # 디바운스: 마지막 실행 후 30초 이내면 스킵
  if [[ -f "$LOCK_FILE" ]]; then
    LAST_RUN=$(cat "$LOCK_FILE" 2>/dev/null || echo 0)
    NOW=$(date +%s)
    ELAPSED=$((NOW - LAST_RUN))
    if [[ $ELAPSED -lt $DEBOUNCE_SEC ]]; then
      exit 0
    fi
  fi

  # 타임스탬프 기록
  date +%s > "$LOCK_FILE"

  CHANGED_FILE=$(basename "$FILE_PATH")

  # 실제 sync 실행 (타임아웃 10초)
  SYNC_OUTPUT=$(timeout 10 node "$SYNC_SCRIPT" sync 2>&1)
  SYNC_EXIT=$?

  if [[ $SYNC_EXIT -eq 0 ]]; then
    if echo "$SYNC_OUTPUT" | grep -q "copied"; then
      COPIED=$(echo "$SYNC_OUTPUT" | grep "Sync complete" | grep -o '[0-9]* copied' | head -1)
      echo "forge-sync: $CHANGED_FILE 수정 → 자동 동기화 완료 ($COPIED)"
    fi
  else
    echo "forge-sync: 일부 프로젝트 동기화 실패 → /forge-sync 수동 확인 권장"
  fi
fi

exit 0
