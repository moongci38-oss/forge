#!/usr/bin/env bash
# Forge Research Index — S1 리서치 인덱스 빌드 + 검색
# Usage: bash scripts/forge-research-index.sh {build|search <keyword>}
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/forge-paths.sh"
WORKSPACE="$SCRIPT_DIR/.."

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

source "$SCRIPT_DIR/json-get.sh"

WS_JSON="$WORKSPACE/forge-workspace.json"

if [ ! -f "$WS_JSON" ]; then
  echo -e "${RED}Error: forge-workspace.json not found${NC}"
  exit 1
fi

RESEARCH_DIR="$(json_get "$WS_JSON" "folderMap.research")"
INDEX_FILE="$WORKSPACE/${RESEARCH_DIR%/*}/research-index.json"

cmd_build() {
  echo -e "${CYAN}=== Building Research Index ===${NC}"

  python3 - "$WORKSPACE/$RESEARCH_DIR" "$INDEX_FILE" << 'PYEOF'
import os, json, re, sys
from collections import defaultdict
import datetime

research_dir = sys.argv[1]
output_file = sys.argv[2]

projects = {}
cross_refs = defaultdict(list)

if not os.path.isdir(research_dir):
    print(f"  WARN: {research_dir} not found")
    sys.exit(0)

for proj_name in sorted(os.listdir(research_dir)):
    proj_path = os.path.join(research_dir, proj_name)
    if not os.path.isdir(proj_path):
        continue

    files = [f for f in os.listdir(proj_path) if f.endswith('.md')]
    if not files:
        continue

    topics = set()
    cred = {"high": 0, "medium": 0, "low": 0}
    last_updated = ""

    for fname in sorted(files):
        fpath = os.path.join(proj_path, fname)
        date_match = re.match(r'(\d{4}-\d{2}-\d{2})', fname)
        if date_match:
            d = date_match.group(1)
            if d > last_updated:
                last_updated = d

        with open(fpath, encoding='utf-8', errors='ignore') as f:
            content = f.read()

        cred["high"] += len(re.findall(r'\[신뢰도:\s*High\]', content, re.I))
        cred["medium"] += len(re.findall(r'\[신뢰도:\s*Medium\]', content, re.I))
        cred["low"] += len(re.findall(r'\[신뢰도:\s*Low\]', content, re.I))

        headings = re.findall(r'^##\s+(.+)$', content, re.M)
        for h in headings:
            clean = re.sub(r'[\d.]+\s*', '', h).strip()
            if 1 < len(clean) < 30:
                topics.add(clean)

    topic_list = sorted(topics)
    projects[proj_name] = {
        "topics": topic_list,
        "files": sorted(files),
        "credibility": cred,
        "lastUpdated": last_updated or "unknown"
    }

    for t in topic_list:
        cross_refs[t].append(proj_name)

    print(f"  {proj_name}: {len(files)} files, {len(topic_list)} topics")

filtered_refs = {k: sorted(set(v)) for k, v in cross_refs.items() if len(set(v)) >= 2}

index = {
    "generatedAt": datetime.datetime.now().strftime('%Y-%m-%d'),
    "projects": projects,
    "crossRefs": filtered_refs
}

os.makedirs(os.path.dirname(output_file), exist_ok=True)
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(index, f, ensure_ascii=False, indent=2)

print(f"\n  Index saved: {output_file}")
print(f"  Projects: {len(projects)}, Cross-refs: {len(filtered_refs)}")
PYEOF
}

cmd_search() {
  local keyword="${1:-}"
  if [ -z "$keyword" ]; then
    echo -e "${RED}Usage: forge research <keyword>${NC}"
    exit 1
  fi

  if [ ! -f "$INDEX_FILE" ]; then
    echo -e "${YELLOW}Index not found. Building...${NC}"
    cmd_build
  fi

  echo -e "${CYAN}=== Research Search: $keyword ===${NC}"

  python3 - "$INDEX_FILE" "$keyword" << 'PYEOF'
import json, sys

with open(sys.argv[1]) as f:
    index = json.load(f)
keyword = sys.argv[2].lower()

found = False
for proj, data in index["projects"].items():
    matches = [t for t in data["topics"] if keyword in t.lower()]
    if matches:
        found = True
        print(f"\n  {proj}:")
        print(f"    Topics: {', '.join(matches)}")
        print(f"    Files: {', '.join(data['files'][:5])}")
        cred = data["credibility"]
        print(f"    Credibility: H={cred['high']} M={cred['medium']} L={cred['low']}")

if not found:
    print(f"  No results for '{keyword}'")
PYEOF
}

case "${1:-help}" in
  build)  cmd_build ;;
  search) shift; cmd_search "$@" ;;
  *)      echo "Usage: forge-research-index.sh {build|search <keyword>}" ;;
esac
