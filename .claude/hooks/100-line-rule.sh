#!/usr/bin/env bash
# 100-line-rule.sh — PostToolUse (Edit|Write)
# 테스트 없이 100줄 이상 코드 작성 시 경고
# agent-skills "100줄 규칙" 적용: 테스트 없이 100줄 이상 작성 금지

TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"

# Edit/Write만 대상
case "$TOOL_NAME" in
  Edit|Write) ;;
  *) exit 0 ;;
esac

# stdin에서 도구 결과 읽기
INPUT=""
if [ ! -t 0 ]; then
  INPUT=$(cat 2>/dev/null || true)
fi

# 파일 경로 추출 (file_path 파라미터)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')

# 파일 경로가 없으면 스킵
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# 테스트 파일, 설정 파일, 문서는 제외
case "$FILE_PATH" in
  *.test.*|*.spec.*|*_test.*|*__tests__/*) exit 0 ;;
  *.md|*.json|*.yaml|*.yml|*.toml|*.ini|*.cfg) exit 0 ;;
  *.sh) exit 0 ;;
  *CLAUDE.md|*AGENTS.md|*SKILL.md) exit 0 ;;
esac

# 세션별 비테스트 코드 줄 수 추적
BUDGET_DIR="${PWD}/.claude/agent-budget"
SESSION="${CLAUDE_SESSION_ID:-unknown}"
CODE_COUNT_FILE="$BUDGET_DIR/${SESSION}.code-lines"

mkdir -p "$BUDGET_DIR"

# 현재 카운트 읽기
if [ -f "$CODE_COUNT_FILE" ]; then
  CURRENT=$(cat "$CODE_COUNT_FILE")
else
  CURRENT=0
fi

# Write는 전체 파일 줄 수 추정, Edit는 new_string 줄 수 추정
if [ "$TOOL_NAME" = "Write" ]; then
  if [ -f "$FILE_PATH" ]; then
    LINES=$(wc -l < "$FILE_PATH" 2>/dev/null || echo 0)
  else
    LINES=0
  fi
elif [ "$TOOL_NAME" = "Edit" ]; then
  # Edit의 new_string 줄 수 대략 추정 (정확하지 않지만 합리적)
  LINES=$(echo "$INPUT" | grep -c "new_string" 2>/dev/null || echo 5)
  LINES=$((LINES * 5))  # 대략 추정
fi

CURRENT=$((CURRENT + LINES))
echo "$CURRENT" > "$CODE_COUNT_FILE"

# 100줄 초과 시 경고
if [ "$CURRENT" -ge 100 ]; then
  echo "⚠️ 100줄 규칙: 테스트 없이 코드 ${CURRENT}줄 작성됨. 테스트를 먼저 작성하거나 실행하세요." >&2
  # 테스트 실행 후 리셋할 수 있도록 카운트 유지
fi

exit 0
