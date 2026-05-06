#!/bin/bash
# opus-4.7-migration-check: Generator 직후 Opus 4.7 Breaking Changes 감지

# stdin: Hook JSON
# {
#   "tool_name": "Generate",
#   "tool_response": { ... files ... }
# }

input=$(cat)
files=$(echo "$input" | jq -r '.tool_response.files[]? // empty')

if [ -z "$files" ]; then
    exit 0
fi

# Opus 4.7 Breaking Changes pattern
patterns=(
    "temperature"
    "top_p"
    "top_k"
    "frequency_penalty"
)

has_break=0
for file in $files; do
    for pattern in "${patterns[@]}"; do
        if grep -E "\b${pattern}\b" "$file" 2>/dev/null; then
            has_break=1
            echo "⚠️ Opus 4.7 Breaking: '$pattern' found in $file"
        fi
    done
done

if [ $has_break -eq 1 ]; then
    cat << 'EOF_JSON' | jq .
{
  "systemMessage": "⚠️ Opus 4.7 Breaking Changes detected. Update parameters to thinking="adaptive" (if needed). Reference: ~/forge/docs/reference/claude-api-skill-quick-ref.md",
  "continue": true
}
EOF_JSON
fi

exit 0
