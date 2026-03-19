#!/usr/bin/env bash
# check-json-integrity.sh — Detect duplicate keys and syntax errors in JSON files
# Trine Layer 1 Hook (pre-push). Deployed via forge-sync.
# Usage: bash check-json-integrity.sh [search_dir] (default: current directory)
#
# Strategy: Only scan JSON files changed in commits being pushed (not entire repo).
# Fallback: If git diff fails (not in git repo), scan search_dir recursively.
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

SEARCH_DIR="${1:-.}"

# --- Determine files to scan ---
JSON_FILES=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
  REMOTE_REF=""

  # Try to find the remote tracking ref
  if [ -n "$CURRENT_BRANCH" ]; then
    REMOTE_REF=$(git rev-parse --verify "origin/$CURRENT_BRANCH" 2>/dev/null || echo "")
  fi

  if [ -n "$REMOTE_REF" ]; then
    # Scan only JSON files changed between remote and local (what's being pushed)
    JSON_FILES=$(git diff --name-only --diff-filter=ACMR "$REMOTE_REF"..HEAD 2>/dev/null | grep -iE '\.json$' || true)
  else
    # No remote ref (new branch) — scan files changed from default branch
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    DEFAULT_REF=$(git rev-parse --verify "origin/$DEFAULT_BRANCH" 2>/dev/null || echo "")
    if [ -n "$DEFAULT_REF" ]; then
      JSON_FILES=$(git diff --name-only --diff-filter=ACMR "$DEFAULT_REF"..HEAD 2>/dev/null | grep -iE '\.json$' || true)
    fi
  fi
fi

# If no changed JSON files detected, nothing to scan
if [ -z "$JSON_FILES" ]; then
  echo -e "${GREEN}No JSON files changed — integrity check skipped.${NC}"
  exit 0
fi

FILE_COUNT=$(echo "$JSON_FILES" | wc -l)
echo "  Scanning $FILE_COUNT changed JSON file(s)..."

# Universal excludes — filter out files that should not be checked
FILTERED_FILES=""
while IFS= read -r file; do
  [ -f "$file" ] || continue
  case "$file" in
    */node_modules/*|*/.next/*|*/dist/*|*/.turbo/*|*/Library/*|*/Temp/*|*/obj/*|*/bin/*|*/.git/*) continue ;;
    *tsconfig.tsbuildinfo|*pnpm-lock.yaml|*package-lock.json|*.meta) continue ;;
  esac
  FILTERED_FILES+="$file"$'\n'
done <<< "$JSON_FILES"

FILTERED_FILES=$(echo "$FILTERED_FILES" | sed '/^$/d')

if [ -z "$FILTERED_FILES" ]; then
  echo -e "${GREEN}No relevant JSON files changed — integrity check skipped.${NC}"
  exit 0
fi

# Validation script — try Node.js first, Python fallback
VALIDATE_NODE='
const fs = require("fs");
const files = process.argv.slice(1);
let found = 0;
for (const file of files) {
  try {
    const content = fs.readFileSync(file, "utf8");
    try { JSON.parse(content); } catch (e) {
      console.log("[JSON SYNTAX ERROR] " + file + ": " + e.message);
      found = 1;
      continue;
    }
    const lines = content.split("\n");
    const levelKeys = [new Set()];
    const dupes = [];
    for (const line of lines) {
      const trimmed = line.trim();
      if (trimmed.startsWith("{")) levelKeys.push(new Set());
      const m = trimmed.match(/^"([^"]+)"\s*:/);
      if (m) {
        const key = m[1];
        const cur = levelKeys[levelKeys.length - 1];
        if (cur.has(key)) dupes.push(key);
        cur.add(key);
      }
      if (trimmed.startsWith("}") || trimmed.endsWith("}") || trimmed.endsWith("},")) {
        levelKeys.pop();
        if (levelKeys.length === 0) levelKeys.push(new Set());
      }
    }
    if (dupes.length) {
      console.log("[DUPLICATE JSON KEY] " + file + ": " + dupes.join(", "));
      found = 1;
    }
  } catch (e) {
    console.log("[ERROR] " + file + ": " + e.message);
    found = 1;
  }
}
process.exit(found);
'

VALIDATE_PYTHON='
import json, sys
found = 0
for f in sys.argv[1:]:
    try:
        with open(f) as fh:
            json.load(fh)
    except json.JSONDecodeError as e:
        print(f"[JSON SYNTAX ERROR] {f}: {e}")
        found = 1
    except Exception as e:
        print(f"[ERROR] {f}: {e}")
        found = 1
sys.exit(found)
'

# Try Node.js first, fall back to Python (syntax check only for Python)
if command -v node &>/dev/null; then
  echo "$FILTERED_FILES" | xargs node -e "$VALIDATE_NODE"
  STATUS=$?
elif command -v python3 &>/dev/null; then
  echo "[INFO] Node.js not found, using Python (syntax check only, no duplicate key detection)"
  echo "$FILTERED_FILES" | xargs python3 -c "$VALIDATE_PYTHON"
  STATUS=$?
else
  echo "[WARN] Neither Node.js nor Python found. Skipping JSON integrity check."
  exit 0
fi

if [ "$STATUS" -ne 0 ]; then
  echo ""
  echo -e "${RED}JSON integrity issues found! Fix duplicate keys and syntax errors.${NC}"
  exit 1
fi

echo "All changed JSON files are valid with no duplicate keys."
exit 0
