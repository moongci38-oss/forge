#!/bin/bash
# learnings 자동 로드 — SessionStart 훅
# 현재 프로젝트의 .claude/learnings.jsonl에서 최근 5건 출력

# git 루트 또는 PWD 기준으로 learnings 파일 탐색
GIT_ROOT=$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)
SEARCH_DIR="${GIT_ROOT:-$PWD}"
LEARNINGS_FILE="$SEARCH_DIR/.claude/learnings.jsonl"

if [ ! -f "$LEARNINGS_FILE" ]; then
  exit 0
fi

LINE_COUNT=$(wc -l < "$LEARNINGS_FILE")
if [ "$LINE_COUNT" -eq 0 ]; then
  exit 0
fi

echo "📚 learnings 자동 로드 (${LEARNINGS_FILE}) — 최근 5건:"
echo ""

# 마지막 5줄 출력 (빈 줄 제외)
grep -v '^$' "$LEARNINGS_FILE" | tail -5 | while IFS= read -r line; do
  # content 또는 insight 필드 추출
  CONTENT=$(echo "$line" | python3 -c "
import json, sys
try:
    d = json.loads(sys.stdin.read())
    ts = d.get('ts', d.get('timestamp', ''))[:10]
    text = d.get('content', d.get('insight', d.get('title', '')))
    tags = ','.join(d.get('tags', [])[:3])
    print(f'[{ts}] {text[:120]}  #{tags}')
except:
    pass
" 2>/dev/null)
  [ -n "$CONTENT" ] && echo "• $CONTENT"
done

echo ""
