#!/usr/bin/env bash
# update-pptx-skill.sh — Pull latest official pptx skill from anthropics/skills
# Usage: bash shared/scripts/update-pptx-skill.sh
#
# Compares local pptx skill with the official Anthropic repository,
# shows diffs, and optionally applies updates.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORGE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$FORGE_ROOT/.claude/skills/pptx"
UPSTREAM_FILE="$SKILL_DIR/.upstream"
TEMP_DIR=""

cleanup() {
  if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

echo "=== PPTX Skill Upstream Update ==="
echo ""

# Check upstream file exists
if [[ ! -f "$UPSTREAM_FILE" ]]; then
  echo "ERROR: .upstream file not found at $UPSTREAM_FILE"
  echo "       Run this from the forge root directory."
  exit 1
fi

echo "Local skill: $SKILL_DIR"
echo ""

# Clone official repo (sparse checkout)
TEMP_DIR=$(mktemp -d)
echo "Fetching official skill from anthropics/skills..."
git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/anthropics/skills.git "$TEMP_DIR" 2>/dev/null

cd "$TEMP_DIR"
git sparse-checkout set skills/pptx 2>/dev/null
cd - > /dev/null

OFFICIAL_DIR="$TEMP_DIR/skills/pptx"

if [[ ! -d "$OFFICIAL_DIR" ]]; then
  echo "ERROR: Failed to fetch official pptx skill."
  exit 1
fi

echo "Official skill fetched."
echo ""

# Compare (exclude .upstream which is our own file)
echo "=== Comparing local vs official ==="
echo ""

DIFF_OUTPUT=$(diff -r "$OFFICIAL_DIR" "$SKILL_DIR" \
  --exclude='.upstream' \
  --exclude='__pycache__' \
  --exclude='.DS_Store' \
  2>&1 || true)

if [[ -z "$DIFF_OUTPUT" ]]; then
  echo "No differences found. Local skill matches official."
  # Update last-synced date
  sed -i "s/^last-synced:.*/last-synced: $(date +%Y-%m-%d)/" "$UPSTREAM_FILE"
  echo "Updated last-synced date in .upstream"
  exit 0
fi

echo "$DIFF_OUTPUT"
echo ""
echo "=== Differences detected ==="
echo ""

read -p "Apply official updates? (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Aborted. No changes made."
  exit 0
fi

# Apply updates (copy official files, preserving .upstream)
echo "Applying updates..."
rsync -av --exclude='.upstream' --exclude='__pycache__' \
  "$OFFICIAL_DIR/" "$SKILL_DIR/"

# Update last-synced date
sed -i "s/^last-synced:.*/last-synced: $(date +%Y-%m-%d)/" "$UPSTREAM_FILE"

echo ""
echo "Update complete. Changes applied to $SKILL_DIR"
echo "Remember: Company design system is in memory, NOT in SKILL.md."
