#!/bin/bash
# archive-deep-orchestrate.sh — per-cluster deep walk with timeout.
# Reads shallow-{drive}.jsonl, iterates dir clusters, calls archive-indexer.py scan-one for each.
# Hang-proof: each cluster gets `timeout TIMEOUT_SEC` wrapper. Failures/timeouts are recorded.
#
# Usage: archive-deep-orchestrate.sh <drive_label> <drive_root> [timeout_sec=300]
#
# Output:
#   forge-outputs/30-archive-meta/deep-{drive}.jsonl     ← success lines
#   forge-outputs/30-archive-meta/deep-{drive}-errors.jsonl ← timeout/error lines
#   stderr: per-cluster progress

set -u
DRIVE="${1:?drive label required}"
DRIVE_ROOT="${2:?drive root required}"
TIMEOUT_SEC="${3:-300}"

META_DIR="/home/damools/forge-outputs/30-archive-meta"
SHALLOW="$META_DIR/shallow-$DRIVE.jsonl"
OUT_OK="$META_DIR/deep-$DRIVE.jsonl"
OUT_ERR="$META_DIR/deep-$DRIVE-errors.jsonl"
INDEXER="/home/damools/forge/shared/scripts/archive-indexer.py"

[ -f "$SHALLOW" ] || { echo "missing $SHALLOW" >&2; exit 2; }
> "$OUT_OK"
> "$OUT_ERR"

# collect dir entries (skip files, skip excluded)
mapfile -t DIRS < <(python3 -c "
import json, sys
for line in open('$SHALLOW', encoding='utf-8'):
    e = json.loads(line)
    if e.get('type') == 'dir':
        print(e['name'])
")

TOTAL="${#DIRS[@]}"
echo "[orchestrate] $DRIVE: $TOTAL clusters, timeout=${TIMEOUT_SEC}s" >&2

i=0
for name in "${DIRS[@]}"; do
    i=$((i+1))
    full="$DRIVE_ROOT/$name"
    t_start=$(date +%s)
    echo "[start] $DRIVE ($i/$TOTAL) $name" >&2
    # run with timeout, capture stdout
    if out=$(timeout --kill-after=10 "$TIMEOUT_SEC" python3 "$INDEXER" scan-one --drive "$DRIVE" --path "$full" 2>/dev/null); then
        if [ -n "$out" ]; then
            echo "$out" >> "$OUT_OK"
            elapsed=$(($(date +%s) - t_start))
            # extract key fields via python for logging
            echo "[done]  $DRIVE ($i/$TOTAL) $name in ${elapsed}s" >&2
        else
            echo "[empty] $DRIVE ($i/$TOTAL) $name (no output)" >&2
            printf '{"drive":"%s","name":"%s","status":"empty"}\n' "$DRIVE" "$name" >> "$OUT_ERR"
        fi
    else
        rc=$?
        elapsed=$(($(date +%s) - t_start))
        if [ "$rc" = 124 ] || [ "$rc" = 137 ]; then
            echo "[TIMEOUT] $DRIVE ($i/$TOTAL) $name after ${elapsed}s" >&2
            printf '{"drive":"%s","name":"%s","status":"timeout","elapsed":%d}\n' "$DRIVE" "$name" "$elapsed" >> "$OUT_ERR"
        else
            echo "[ERROR rc=$rc] $DRIVE ($i/$TOTAL) $name" >&2
            printf '{"drive":"%s","name":"%s","status":"error","rc":%d}\n' "$DRIVE" "$name" "$rc" >> "$OUT_ERR"
        fi
    fi
done

echo "[orchestrate] $DRIVE: done. OK=$(wc -l < "$OUT_OK"), ERR=$(wc -l < "$OUT_ERR")" >&2
