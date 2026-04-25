#!/usr/bin/env bash
# filter-log-output.sh — PostToolUse (Bash)
# 빌드/테스트 출력에서 FAILED/ERROR/WARNING만 Claude에게 전달
# 성공한 테스트 목록, 빌드 진행 로그 등 불필요한 출력을 필터링

TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
[ "$TOOL_NAME" = "Bash" ] || exit 0

# stdin에서 도구 결과 읽기
INPUT=""
if [ ! -t 0 ]; then
  INPUT=$(cat 2>/dev/null || true)
fi

[ -z "$INPUT" ] && exit 0

# 빌드/테스트 커맨드인지 감지
IS_BUILD_TEST=false
if echo "$INPUT" | head -5 | grep -qiE "(npm (test|run build|run lint)|pytest|jest|vitest|go test|dotnet test|cargo test|msbuild|gradle|maven|make test|unity|xcodebuild)" 2>/dev/null; then
  IS_BUILD_TEST=true
fi

$IS_BUILD_TEST || exit 0

# 전체 줄 수 확인
TOTAL_LINES=$(echo "$INPUT" | wc -l)

# 50줄 이하면 필터링 불필요
[ "$TOTAL_LINES" -le 50 ] && exit 0

# 에러/실패/경고 줄만 추출 (전후 2줄 컨텍스트 포함)
FILTERED=$(echo "$INPUT" | grep -n -i -E "(error|fail|failed|exception|traceback|warning|WARN|ERR|panic|undefined|cannot find|not found|missing|denied|timeout|killed)" 2>/dev/null | head -50)

FILTERED_COUNT=$(echo "$FILTERED" | grep -c . 2>/dev/null || echo 0)

if [ "$FILTERED_COUNT" -gt 0 ] && [ "$TOTAL_LINES" -gt 100 ]; then
  # 요약 정보를 stderr로 출력 (Claude에게 전달)
  echo "📋 로그 필터링: 전체 ${TOTAL_LINES}줄 → 에러/경고 ${FILTERED_COUNT}줄 추출" >&2
  echo "---" >&2
  echo "$FILTERED" | head -30 >&2
  if [ "$FILTERED_COUNT" -gt 30 ]; then
    echo "... (${FILTERED_COUNT}줄 중 30줄만 표시)" >&2
  fi
fi

exit 0
