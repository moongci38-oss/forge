#!/usr/bin/env bash
# reset-code-lines.sh — PostToolUse (Bash)
# 테스트 실행 감지 시 100줄 카운터 리셋

TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"

# Bash만 대상
[ "$TOOL_NAME" = "Bash" ] || exit 0

# stdin에서 커맨드 읽기
INPUT=""
if [ ! -t 0 ]; then
  INPUT=$(cat 2>/dev/null || true)
fi

# 테스트 실행 패턴 감지
if echo "$INPUT" | grep -qiE "(npm test|pytest|jest|vitest|go test|dotnet test|cargo test|unittest|mocha|rspec)" 2>/dev/null; then
  BUDGET_DIR="${PWD}/.claude/agent-budget"
  SESSION="${CLAUDE_SESSION_ID:-unknown}"
  CODE_COUNT_FILE="$BUDGET_DIR/${SESSION}.code-lines"

  # 카운터 리셋
  echo "0" > "$CODE_COUNT_FILE" 2>/dev/null
fi

exit 0
