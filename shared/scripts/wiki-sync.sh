#!/usr/bin/env bash
# wiki-sync.sh — Bidirectional sync between Obsidian vault (E:\forge-vault) and forge-outputs/20-wiki
#
# Strategy:
#   - Two-pass rsync with --update (skip files that are newer on the receiver)
#   - Excludes Obsidian internal folders (.obsidian, .trash) from going into forge-outputs
#   - No --delete: deletions must be done manually on both sides (safety)
#
# Usage:
#   bash ~/forge/shared/scripts/wiki-sync.sh           # one-shot sync
#   bash ~/forge/shared/scripts/wiki-sync.sh --watch   # poll loop (every 5s)
#
# Cron example (every 1 min):
#   * * * * * /usr/bin/bash /home/damools/forge/shared/scripts/wiki-sync.sh >> /tmp/wiki-sync.log 2>&1

set -euo pipefail

VAULT="/mnt/e/forge-vault"
WIKI="$HOME/forge-outputs/20-wiki"

if [ ! -d "$VAULT" ]; then
  echo "[wiki-sync] ERROR: vault dir not found: $VAULT" >&2
  exit 1
fi

if [ ! -d "$WIKI" ]; then
  echo "[wiki-sync] ERROR: wiki dir not found: $WIKI" >&2
  exit 1
fi

EXCLUDES=(
  --exclude='.obsidian/'
  --exclude='.obsidian.vimrc'
  --exclude='.trash/'
  --exclude='.DS_Store'
  --exclude='Thumbs.db'
  --exclude='*.swp'
  --exclude='*~'
)

sync_once() {
  # Direction 1: vault → wiki (newer files only)
  rsync -a --update --no-perms --no-owner --no-group "${EXCLUDES[@]}" \
    "$VAULT/" "$WIKI/"

  # Direction 2: wiki → vault (newer files only)
  rsync -a --update --no-perms --no-owner --no-group "${EXCLUDES[@]}" \
    "$WIKI/" "$VAULT/"
}

if [ "${1:-}" = "--watch" ]; then
  echo "[wiki-sync] watch mode — polling every 5s. Ctrl+C to stop."
  while true; do
    sync_once
    sleep 5
  done
else
  sync_once
  echo "[wiki-sync] OK $(date '+%Y-%m-%d %H:%M:%S')"
fi
