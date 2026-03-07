#!/bin/bash
# block-sensitive-bash.sh
# PreToolUse: Bash
# Bash 명령에서 민감 경로로의 쓰기/삭제/이동 차단

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('command', ''))
" 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

SENSITIVE_PATTERNS=(
  "06-finance/"
  "07-legal/"
  "08-admin/insurance/"
  "08-admin/freelancers/"
)

# 쓰기/삭제/이동 패턴 검사
WRITE_PATTERNS=(">" ">>" "tee " "cp " "mv " "rm " "mkdir " "touch ")

for SENS in "${SENSITIVE_PATTERNS[@]}"; do
  if [[ "$COMMAND" == *"$SENS"* ]]; then
    for WP in "${WRITE_PATTERNS[@]}"; do
      if [[ "$COMMAND" == *"$WP"* ]]; then
        echo "BLOCKED: Bash command targets sensitive path: $SENS"
        exit 2
      fi
    done
  fi
done

exit 0
