#!/bin/bash
# sync-to-windows.sh — WSL → Windows 단방향 동기화
# WSL이 원본, Windows가 사본. 변경 사항을 Windows로 전파한다.
# 사용: bash ~/.claude/scripts/sync-to-windows.sh

set -euo pipefail

WSL_BASE="/home/damools/.claude"
WIN_BASE="/mnt/c/Users/moongci/.claude"
DIRS=(agents commands rules skills prompts)

echo "=== WSL → Windows Sync ==="
echo "Source: $WSL_BASE"
echo "Target: $WIN_BASE"
echo ""

for dir in "${DIRS[@]}"; do
  src="$WSL_BASE/$dir/"
  dst="$WIN_BASE/$dir/"

  if [ ! -d "$src" ]; then
    echo "SKIP: $dir (WSL source not found)"
    continue
  fi

  # rsync: --delete removes files in dst that don't exist in src
  rsync -av --delete "$src" "$dst" 2>/dev/null
  echo "DONE: $dir"
  echo ""
done

echo "=== Sync Complete ==="
