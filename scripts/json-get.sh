#!/bin/bash
# json-get.sh — Python3-based dot-path JSON parser (jq replacement)
# Usage: source scripts/json-get.sh
#        json_get <file> <dotpath>
# Example: json_get sigil-workspace.json folderMap.research
#          → "01-research/projects"

json_get() {
  local file="$1"
  local dotpath="$2"

  python3 -c "
import json, sys

with open('$file') as f:
    data = json.load(f)

keys = '$dotpath'.split('.')
val = data
for k in keys:
    if isinstance(val, dict) and k in val:
        val = val[k]
    else:
        sys.exit(0)  # key not found → empty output

if isinstance(val, (dict, list)):
    print(json.dumps(val, ensure_ascii=False))
else:
    print(val)
" 2>/dev/null
}
