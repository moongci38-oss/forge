#!/usr/bin/env bash
# wiki-sync.sh — Bidirectional sync between Obsidian vault (E:\forge-vault) and forge-outputs/20-wiki
#                + 변경 감지 시 LightRAG wiki 자동 재인덱싱 (30s 디바운스)
#                + vault → GitHub 자동 git push (5분 디바운스, 모바일 동기화용)
#
# Strategy:
#   - Two-pass rsync with --update (skip files that are newer on the receiver)
#   - Excludes Obsidian internal folders (.obsidian, .trash) from going into forge-outputs
#   - No --delete: deletions must be done manually on both sides (safety)
#   - 변경 감지 → 30s 무변경 후 LightRAG indexer 트리거 (편집 중 반복 인덱싱 방지)
#   - 변경 감지 → 5분 무변경 후 vault git add+commit+push (모바일 동기화)
#
# Usage:
#   bash ~/forge/shared/scripts/wiki-sync.sh           # one-shot sync (no auto-index/push)
#   bash ~/forge/shared/scripts/wiki-sync.sh --watch   # poll loop + auto-index + auto-push

set -euo pipefail

VAULT="/mnt/e/forge-vault"
WIKI="$HOME/forge-outputs/20-wiki"
PENDING_FLAG="/tmp/wiki-sync-pending.flag"
PUSH_PENDING_FLAG="/tmp/wiki-sync-push-pending.flag"
LOG_FILE="/tmp/wiki-sync.log"
INDEX_LOG="/tmp/wiki-index.log"
PUSH_LOG="/tmp/wiki-push.log"
DEBOUNCE_SECONDS=30
PUSH_DEBOUNCE_SECONDS=300  # 5분

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
    [ -f "$PUSH_PENDING_FLAG" ] || date '+%Y-%m-%d %H:%M:%S' > "$PUSH_PENDING_FLAG"
  fi
}

# 디바운스: PENDING_FLAG가 30초 이상 묵으면 LightRAG indexer 실행
maybe_reindex() {
  [ -f "$PENDING_FLAG" ] || return 0

  local age now flag_mtime
  now=$(date +%s)
  flag_mtime=$(stat -c %Y "$PENDING_FLAG" 2>/dev/null || echo "$now")
  age=$((now - flag_mtime))

  if [ "$age" -ge "$DEBOUNCE_SECONDS" ]; then
    echo "[wiki-sync] reindex debounce elapsed (${age}s) → LightRAG re-index"
    {
      echo "=== $(date '+%Y-%m-%d %H:%M:%S') wiki re-index trigger ==="
      python3 "$HOME/forge/shared/scripts/lightrag-pilot.py" index --context wiki 2>&1
    } >> "$INDEX_LOG"
    rm -f "$PENDING_FLAG"
  fi
}

# 디바운스: PUSH_PENDING_FLAG가 5분 이상 묵으면 vault git add+commit+push
maybe_git_push() {
  [ -f "$PUSH_PENDING_FLAG" ] || return 0

  local age now flag_mtime
  now=$(date +%s)
  flag_mtime=$(stat -c %Y "$PUSH_PENDING_FLAG" 2>/dev/null || echo "$now")
  age=$((now - flag_mtime))

  if [ "$age" -ge "$PUSH_DEBOUNCE_SECONDS" ]; then
    echo "[wiki-sync] push debounce elapsed (${age}s) → git push to forge-vault"
    {
      echo "=== $(date '+%Y-%m-%d %H:%M:%S') vault auto-push trigger ==="
      cd "$VAULT" || { echo "ERROR: vault dir gone"; exit 1; }

      # 실제 변경이 있을 때만 commit/push
      if [ -z "$(git status --porcelain)" ]; then
        echo "no git changes — skipping commit"
      else
        git add -A
        git -c user.email="damools@users.noreply.github.com" \
            -c user.name="damools" \
            commit -m "auto-sync: $(date '+%Y-%m-%d %H:%M:%S')" 2>&1
        git push origin main 2>&1
      fi
    } >> "$PUSH_LOG" 2>&1
    rm -f "$PUSH_PENDING_FLAG"
  fi
}

if [ "${1:-}" = "--watch" ]; then
  echo "[wiki-sync] watch mode — poll 5s, reindex ${DEBOUNCE_SECONDS}s, push ${PUSH_DEBOUNCE_SECONDS}s"
  echo "[wiki-sync] Logs: $LOG_FILE / $INDEX_LOG / $PUSH_LOG"
  while true; do
    sync_once
    maybe_reindex
    maybe_git_push
    sleep 5
  done
else
  sync_once
  echo "[wiki-sync] OK $(date '+%Y-%m-%d %H:%M:%S')"
  bash "$(dirname "$0")/tg-send.sh" "✅ *Wiki-sync 완료* ($(date '+%Y-%m-%d %H:%M KST'))" 2>/dev/null || true
fi
