#!/bin/bash
# require-date-prefix.sh
# PreToolUse: Write | Edit
# docs/ 및 SIGIL 산출물 경로 하위 .md 파일 생성 시 날짜 prefix (YYYY-MM-DD-) 규칙 강제

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('file_path', '') or data.get('tool_input', {}).get('path', ''))
" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# 대상 경로: docs/, 01-research/, 02-product/, 04-content/, 05-design/ 하위 .md 파일
IN_TARGET_PATH=false
for DIR in "/docs/" "/01-research/" "/02-product/" "/04-content/" "/05-design/"; do
  if [[ "$FILE_PATH" == *"$DIR"* ]]; then
    IN_TARGET_PATH=true
    break
  fi
done

if [[ "$IN_TARGET_PATH" != "true" ]] || [[ "$FILE_PATH" != *.md ]]; then
  exit 0
fi

FILENAME=$(basename "$FILE_PATH")

# YYYY-MM-DD- 또는 YYYY-WW- 또는 YYYY-Q 형식 허용
if [[ "$FILENAME" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-.+ ]] || \
   [[ "$FILENAME" =~ ^[0-9]{4}-W[0-9]{2}-.+ ]] || \
   [[ "$FILENAME" =~ ^[0-9]{4}-Q[1-4]-.+ ]]; then
  exit 0
fi

# 예외: CLAUDE.md, README.md, index.md, gate-log.md 등
EXCEPTIONS=("CLAUDE.md" "README.md" "index.md" "subscriptions.md" "domains.md" "terms-of-service.md" "privacy-policy.md" "gate-log.md")
for EX in "${EXCEPTIONS[@]}"; do
  if [[ "$FILENAME" == "$EX" ]]; then
    exit 0
  fi
done

echo "⚠️  파일명 규칙 위반: docs/ 하위 .md 파일은 날짜 prefix가 필요합니다."
echo "   현재: $FILENAME"
echo "   올바른 형식: YYYY-MM-DD-{description}.md  (예: $(date +%Y-%m-%d)-my-doc.md)"
exit 2
