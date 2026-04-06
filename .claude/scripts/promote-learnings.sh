#!/bin/bash
# promote-learnings.sh — learnings.jsonl 태그 빈도 분석 → forge-core.md 승격 후보 리포트
# 사용: bash ~/.claude/scripts/promote-learnings.sh
#
# 동작:
#   1. learnings.jsonl에서 session_summary 제외
#   2. tags 추출 및 빈도 집계
#   3. 3회 이상 등장한 태그 → 관련 learning 내용 + 제안 규칙 출력 (Markdown)

set -euo pipefail

LEARNINGS_FILE="${FORGE_ROOT:-$HOME/forge}/.claude/learnings.jsonl"
MIN_OCCURRENCES=3

if [ ! -f "$LEARNINGS_FILE" ]; then
  echo "ERROR: learnings.jsonl not found at $LEARNINGS_FILE" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is required but not installed." >&2
  exit 1
fi

# session_summary 제외 유효 항목만 추출
VALID_ENTRIES=$(jq -c 'select(.type != "session_summary")' "$LEARNINGS_FILE" 2>/dev/null)

if [ -z "$VALID_ENTRIES" ]; then
  echo "No learnings ready for promotion."
  exit 0
fi

# 태그 빈도 집계
TAG_COUNTS=$(echo "$VALID_ENTRIES" \
  | jq -r 'select(.tags | type == "array") | .tags[]' \
  | sort | uniq -c | sort -rn)

if [ -z "$TAG_COUNTS" ]; then
  echo "No learnings ready for promotion."
  exit 0
fi

# MIN_OCCURRENCES 이상인 태그 추출
QUALIFYING_TAGS=$(echo "$TAG_COUNTS" \
  | awk -v min="$MIN_OCCURRENCES" '$1 >= min { print $2 }')

if [ -z "$QUALIFYING_TAGS" ]; then
  echo "No learnings ready for promotion."
  exit 0
fi

# 리포트 출력
echo "# Learnings Promotion Report"
echo ""
echo "> Generated: $(date '+%Y-%m-%d %H:%M:%S')"
echo "> Source: \`$LEARNINGS_FILE\`"
echo "> Threshold: ${MIN_OCCURRENCES}+ occurrences"
echo ""
echo "---"
echo ""

while IFS= read -r tag; do
  [ -z "$tag" ] && continue

  count=$(echo "$TAG_COUNTS" | awk -v t="$tag" '$2 == t { print $1 }')

  # 해당 태그를 포함하는 항목들의 날짜+내용 요약
  related_with_ts=$(echo "$VALID_ENTRIES" \
    | jq -r --arg tag "$tag" '
        select(.tags | type == "array") |
        select(.tags[] | . == $tag) |
        {
          ts: (if .ts then .ts elif .timestamp then .timestamp else "unknown" end),
          text: (if .content then .content elif .learning then .learning elif .solution then .solution else "(내용 없음)" end)
        } |
        "- **[\(.ts | split("T")[0])]** \(.text | gsub("\n"; " ") | .[0:200])\(if (.text | length) > 200 then "…" else "" end)"
      ')

  echo "## \`$tag\` — ${count}회"
  echo ""
  echo "**관련 Learnings:**"
  echo ""
  echo "$related_with_ts"
  echo ""
  echo "---"
  echo ""

done <<< "$QUALIFYING_TAGS"

echo ""
echo "> 위 태그들을 forge-core.md 규칙으로 승격할지 검토하세요."
