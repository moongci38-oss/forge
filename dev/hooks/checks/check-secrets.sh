#!/usr/bin/env bash
# check-secrets.sh — Detect hardcoded secrets (language-agnostic)
# Trine Layer 1 Hook (pre-push). Deployed via forge-sync.
# Usage: bash check-secrets.sh [search_dir] (default: current directory)
#
# Strategy: Only scan files changed in commits being pushed (not entire repo).
# Fallback: If git diff fails (not in git repo), scan search_dir recursively.
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

SEARCH_DIR="${1:-.}"

PATTERNS=(
  'password\s*[:=]\s*["\x27][^"\x27]{4,}'
  'secret\s*[:=]\s*["\x27][^"\x27]{4,}'
  'api[_-]?key\s*[:=]\s*["\x27][^"\x27]{8,}'
  'Bearer\s+[A-Za-z0-9\-._~+/]+=*'
  'token\s*[:=]\s*["\x27][^"\x27]{8,}'
  'PRIVATE[_-]KEY'
  'sk-[A-Za-z0-9]{20,}'
  'ghp_[A-Za-z0-9]{36}'
  'aws_access_key_id\s*[:=]'
  'aws_secret_access_key\s*[:=]'
)

# Universal excludes (works across languages/frameworks)
EXCLUDE="node_modules|\.next|dist|\.pnpm|pnpm-lock\.yaml|package-lock\.json|\.lock|\.map|\.min\.|__mocks__|check-secrets\.sh|\.git/|Library/|Temp/|obj/|bin/"

# Exclude test files (test fixtures commonly contain fake credentials)
EXCLUDE_TESTS="\.test\.|\.spec\.|\.e2e-spec\.|/test/|/tests/|/__tests__/|/fixtures/|/mocks/"

# Source file extensions to check
SRC_EXTENSIONS="ts|tsx|js|jsx|cs|py|go|java|json|yaml|yml|env|toml|cfg"

# --- Determine files to scan ---
# Strategy: diff between local HEAD and remote tracking branch (only pushed changes)
CHANGED_FILES=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
  REMOTE_REF=""

  # Try to find the remote tracking ref
  if [ -n "$CURRENT_BRANCH" ]; then
    REMOTE_REF=$(git rev-parse --verify "origin/$CURRENT_BRANCH" 2>/dev/null || echo "")
  fi

  if [ -n "$REMOTE_REF" ]; then
    # Scan only files changed between remote and local (what's being pushed)
    CHANGED_FILES=$(git diff --name-only --diff-filter=ACMR "$REMOTE_REF"..HEAD 2>/dev/null | grep -iE "\.($SRC_EXTENSIONS)$" || true)
  else
    # No remote ref (new branch) — scan files changed from default branch
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    DEFAULT_REF=$(git rev-parse --verify "origin/$DEFAULT_BRANCH" 2>/dev/null || echo "")
    if [ -n "$DEFAULT_REF" ]; then
      CHANGED_FILES=$(git diff --name-only --diff-filter=ACMR "$DEFAULT_REF"..HEAD 2>/dev/null | grep -iE "\.($SRC_EXTENSIONS)$" || true)
    fi
  fi
fi

# If no changed files detected, nothing to scan
if [ -z "$CHANGED_FILES" ]; then
  echo -e "${GREEN}No source files changed — secret scan skipped.${NC}"
  exit 0
fi

FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l)
echo "  Scanning $FILE_COUNT changed file(s)..."

FOUND=0
for pattern in "${PATTERNS[@]}"; do
  MATCHES=""
  while IFS= read -r file; do
    [ -f "$file" ] || continue
    FILE_MATCHES=$(grep -niE "$pattern" "$file" 2>/dev/null | grep -vE "$EXCLUDE" | grep -vE "$EXCLUDE_TESTS" || true)
    if [ -n "$FILE_MATCHES" ]; then
      # Prefix with filename for context
      MATCHES+=$(echo "$FILE_MATCHES" | sed "s|^|$file:|")
      MATCHES+=$'\n'
    fi
  done <<< "$CHANGED_FILES"

  MATCHES=$(echo "$MATCHES" | sed '/^$/d')  # Remove empty lines
  if [ -n "$MATCHES" ]; then
    echo -e "${RED}[SECRET DETECTED]${NC} Pattern: $pattern"
    echo "$MATCHES"
    FOUND=1
  fi
done

if [ "$FOUND" -eq 1 ]; then
  echo ""
  echo -e "${RED}Hardcoded secrets detected! Move them to environment variables.${NC}"
  exit 1
fi

echo "No hardcoded secrets found."
exit 0
