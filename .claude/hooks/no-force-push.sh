#!/bin/bash
# no-force-push.sh
# PreToolUse: Bash
# git push --force / --force-with-lease to main/master 차단

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('command', ''))
" 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# git push --force 또는 -f 감지
if [[ "$COMMAND" =~ git[[:space:]]+push ]] && \
   [[ "$COMMAND" =~ (--force|-f|--force-with-lease) ]]; then

  # main/master 차단
  if [[ "$COMMAND" =~ [[:space:]](main|master)([[:space:]]|$) ]]; then
    echo "⛔ 차단: main/master 브랜치에 force push는 허용되지 않습니다."
    echo "   명령: $COMMAND"
    echo "   git.md 규칙: 'git push --force 금지 (main/master)'"
    exit 2
  fi
  # 허용: feature/fix/hotfix/release/chore/docs 브랜치 + staging (develop→staging 리셋)
  if ! [[ "$COMMAND" =~ (feature|fix|hotfix|release|chore|docs)/ ]] && \
     ! [[ "$COMMAND" =~ [[:space:]]staging([[:space:]]|$) ]]; then
    echo "⛔ 차단: 알 수 없는 브랜치에 force push 시도."
    echo "   허용: feature/*, fix/*, hotfix/*, release/*, chore/*, docs/*, staging"
    echo "   명령: $COMMAND"
    exit 2
  fi
fi

exit 0
