#!/bin/bash
# PreToolUse hook: Block any attempt to edit .env files

INPUT=$(cat)

TOOL=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_name', ''))
except:
    print('')
" 2>/dev/null)

is_env_file() {
    local path="$1"
    local basename
    basename=$(basename "$path")
    echo "$basename" | grep -qE '^\.env($|\.(local|production|development|staging|test|prod|dev))$'
}

if [ "$TOOL" = "Edit" ] || [ "$TOOL" = "Write" ]; then
    FILE_PATH=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('file_path', ''))
except:
    print('')
" 2>/dev/null)

    if is_env_file "$FILE_PATH"; then
        echo "BLOCKED: .env file edit attempt"
        echo "File: $FILE_PATH"
        echo ".env files contain sensitive credentials (API keys, secrets)."
        echo "Direct editing is prohibited by SECURITY-IRON-1."
        echo "Use .env.example as reference or set system environment variables instead."
        exit 2
    fi
fi

if [ "$TOOL" = "Bash" ]; then
    CMD=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null)

    if echo "$CMD" | grep -qE '(>>?|tee|cp|mv)\s+[^\s]*\.env($|\.(local|production|development|staging|test|prod|dev))(\s|$)'; then
        echo "BLOCKED: Bash write to .env file"
        echo "Command: $(echo "$CMD" | head -c 80)"
        echo ".env write operations are prohibited by security rules."
        exit 2
    fi
fi

exit 0
