#!/bin/bash
# sigil-validate-workspace.sh — sigil-workspace.json 스키마 검증
# Usage: bash scripts/sigil-validate-workspace.sh [path]

set -uo pipefail

WORKSPACE_JSON="${1:-./sigil-workspace.json}"

if [[ ! -f "$WORKSPACE_JSON" ]]; then
  echo -e "\033[0;31m[FAIL]\033[0m sigil-workspace.json not found: $WORKSPACE_JSON"
  exit 1
fi

echo "=== SIGIL Workspace Validation: $WORKSPACE_JSON ==="
echo ""

python3 << 'PYEOF'
import json, os, sys

workspace_json = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("WS_JSON", "./sigil-workspace.json")

RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
NC = "\033[0m"

pass_count = 0
warn_count = 0
fail_count = 0

def p(tag, msg):
    global pass_count, warn_count, fail_count
    if tag == "PASS":
        print(f"  {GREEN}[PASS]{NC} {msg}")
        pass_count += 1
    elif tag == "WARN":
        print(f"  {YELLOW}[WARN]{NC} {msg}")
        warn_count += 1
    elif tag == "FAIL":
        print(f"  {RED}[FAIL]{NC} {msg}")
        fail_count += 1

try:
    with open(workspace_json) as f:
        data = json.load(f)
except Exception as e:
    p("FAIL", f"JSON parse error: {e}")
    sys.exit(1)

# 1. 필수 필드
for field in ["version", "folderMap"]:
    if field in data:
        p("PASS", f"Required field '{field}' exists")
    else:
        p("FAIL", f"Required field '{field}' missing")

# 2. folderMap 필수 키
folder_map = data.get("folderMap", {})
for key in ["research", "product", "design", "handoff"]:
    if key in folder_map:
        p("PASS", f"folderMap.{key} exists")
    else:
        p("FAIL", f"folderMap.{key} missing")

# 3. 디렉토리 존재 확인
ws_dir = os.path.dirname(os.path.abspath(workspace_json))
for key, path in folder_map.items():
    full_path = os.path.join(ws_dir, path)
    if os.path.isdir(full_path):
        p("PASS", f"Directory exists: {path}")
    else:
        p("WARN", f"Directory not found: {path}")

# 4. projects 검증
projects = data.get("projects", {})
if projects:
    for proj_name, proj_conf in projects.items():
        if "symlinkBase" in proj_conf:
            p("PASS", f"projects.{proj_name}.symlinkBase exists")
        else:
            p("FAIL", f"projects.{proj_name}.symlinkBase missing")

        if "devTarget" in proj_conf:
            dev_target = proj_conf["devTarget"]
            if os.path.isdir(dev_target):
                p("PASS", f"projects.{proj_name}.devTarget reachable: {dev_target}")
            else:
                p("WARN", f"projects.{proj_name}.devTarget not reachable: {dev_target} (may be on another filesystem)")
        else:
            p("FAIL", f"projects.{proj_name}.devTarget missing")

print()
print(f"=== Result: {pass_count} PASS / {warn_count} WARN / {fail_count} FAIL ===")
if fail_count > 0:
    print("STATUS: FAIL")
    sys.exit(1)
elif warn_count > 0:
    print("STATUS: WARN")
else:
    print("STATUS: PASS")
PYEOF
