#!/usr/bin/env bash
# wiki-sync.sh — Bidirectional sync between Obsidian vault (E:\forge-vault) and forge-outputs/20-wiki
#                + 변경 감지 시 LightRAG wiki 자동 재인덱싱 (디바운스 30s)
#
# Strategy:
#   - Two-pass rsync with --update (skip files that are newer on the receiver)
#   - Excludes Obsidian internal folders (.obsidian, .trash) from going into forge-outputs
#   - No --delete: deletions must be done manually on both sides (safety)
#   - 변경 감지 → 30s 무변경 후 LightRAG indexer 트리거 (편집 중 반복 인덱싱 방지)
#
# Usage:
#   bash ~/forge/shared/scripts/wiki-sync.sh           # one-shot sync (no auto-index)
#   bash ~/forge/shared/scripts/wiki-sync.sh --watch   # poll loop (every 5s) + auto-index

set -euo pipefail

VAULT="/mnt/e/forge-vault"
WIKI="$HOME/forge-outputs/20-wiki"
PENDING_FLAG="/tmp/wiki-sync-pending.flag"
LOG_FILE="/tmp/wiki-sync.log"
INDEX_LOG="/tmp/wiki-index.log"
DEBOUNCE_SECONDS=30

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

# rsync --itemize-changes: detect any new/modified file on .md
detect_md_changes() {
  local out
  out=$(rsync -a --update --itemize-changes --no-perms --no-owner --no-group \
    "${EXCLUDES[@]}" "$1" "$2" 2>/dev/null \
    | grep -E '^[<>ch].*\.md$' || true)
  [ -n "$out" ]
}

sync_once() {
  local changed=0

  if detect_md_changes "$VAULT/" "$WIKI/"; then changed=1; fi
  if detect_md_changes "$WIKI/" "$VAULT/"; then changed=1; fi

  if [ "$changed" = "1" ]; then
    # 첫 변경 시점만 기록 (이후 추가 변경은 mtime 갱신 X)
    [ -f "$PENDING_FLAG" ] || { date '+%Y-%m-%d %H:%M:%S' > "$PENDING_FLAG"; echo "[wiki-sync] change detected"; }
  fi
}

# 디바운스: PENDING_FLAG가 30초 이상 묵으면 indexer 실행
maybe_reindex() {
  [ -f "$PENDING_FLAG" ] || return 0

  local age now flag_mtime
  now=$(date +%s)
  flag_mtime=$(stat -c %Y "$PENDING_FLAG" 2>/dev/null || echo "$now")
  age=$((now - flag_mtime))

  if [ "$age" -ge "$DEBOUNCE_SECONDS" ]; then
    echo "[wiki-sync] debounce elapsed (${age}s) → triggering LightRAG re-index"
    {
      echo "=== $(date '+%Y-%m-%d %H:%M:%S') wiki re-index trigger ==="
      python3 "$HOME/forge/shared/scripts/lightrag-pilot.py" index --context wiki 2>&1
    } >> "$INDEX_LOG"
    rm -f "$PENDING_FLAG"
  fi
}

if [ "${1:-}" = "--watch" ]; then
  echo "[wiki-sync] watch mode — poll 5s, debounce ${DEBOUNCE_SECONDS}s. Logs: $LOG_FILE / $INDEX_LOG"
  while true; do
    sync_once
    maybe_reindex
    sleep 5
  done
else
  sync_once
  echo "[wiki-sync] OK $(date '+%Y-%m-%d %H:%M:%S')"
fi
