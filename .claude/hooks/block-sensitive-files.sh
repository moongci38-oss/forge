#!/bin/bash
# block-sensitive-files.sh
# PreToolUse: Edit | Write
# 06-finance, 07-legal, 08-admin 민감 파일 편집 차단

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('file_path', '') or data.get('tool_input', {}).get('path', ''))
" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

SENSITIVE_PATTERNS=(
  "06-finance/"
  "07-legal/"
  "08-admin/insurance/"
  "08-admin/freelancers/"
)

for PATTERN in "${SENSITIVE_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$PATTERN"* ]]; then
    echo "⛔ 접근 차단: 민감 영역 파일은 Claude Code에서 직접 편집할 수 없습니다."
    echo "   경로: $FILE_PATH"
    echo "   해당 파일은 직접 편집기로 관리하세요."
    exit 2
  fi
done

exit 0
