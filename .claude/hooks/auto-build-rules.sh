#!/bin/bash
# auto-build-rules.sh
# PostToolUse: Edit | Write
# 09-tools/rules-source/ 파일 편집 시 자동으로 manage-rules.sh build 실행

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('file_path', '') or data.get('tool_input', {}).get('path', ''))
" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# rules-source 경로가 아니면 무시
case "$FILE_PATH" in
  *09-tools/rules-source/*)
    ;;
  *)
    exit 0
    ;;
esac

BUSINESS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MANAGE_RULES="$BUSINESS_ROOT/scripts/manage-rules.sh"

if [ ! -f "$MANAGE_RULES" ]; then
  exit 0
fi

# scope 판단
case "$FILE_PATH" in
  *rules-source/sigil/*)
    echo "auto-build-rules: sigil scope detected"
    bash "$MANAGE_RULES" build --scope sigil 2>&1
    ;;
  *rules-source/always/*|*rules-source/cross-project/*)
    echo "auto-build-rules: business scope detected"
    bash "$MANAGE_RULES" build --scope business 2>&1
    ;;
  *rules-source/cowork/*)
    echo "auto-build-rules: cowork scope detected"
    bash "$MANAGE_RULES" build --scope cowork 2>&1
    ;;
  *)
    echo "auto-build-rules: full build"
    bash "$MANAGE_RULES" build --all 2>&1
    ;;
esac
