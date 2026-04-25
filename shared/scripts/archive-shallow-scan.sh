#!/bin/bash
# archive-shallow-scan.sh — drvfs-friendly depth-1 inventory for STOP gate preview.
# Lists top-level clusters per drive with: name, mtime, direct child count, direct file samples.
# Does NOT recurse — designed to finish in seconds even on slow 9P drvfs.
#
# Usage: archive-shallow-scan.sh <drive_label> <drive_root>
#   archive-shallow-scan.sh d /mnt/d
#
# Output: one JSON object per top-level entry on stdout (jsonl).

set -u
DRIVE_LABEL="${1:?drive label required}"
DRIVE_ROOT="${2:?drive root required}"
EXCLUSIONS_FILE="$(dirname "$0")/archive-exclusions.txt"

is_excluded() {
    local name="$1"
    while IFS= read -r pat; do
        # skip comments and empty
        [[ -z "$pat" || "$pat" == \#* ]] && continue
        [[ "$pat" == path:* ]] && continue
        # fnmatch via bash [[ ]] with extglob
        if [[ "$name" == $pat ]]; then
            return 0
        fi
    done < "$EXCLUSIONS_FILE"
    return 1
}

shopt -s nullglob extglob

# top-level entries (sorted)
mapfile -t ENTRIES < <(cd "$DRIVE_ROOT" && ls -A 2>/dev/null | sort)

for name in "${ENTRIES[@]}"; do
    full="$DRIVE_ROOT/$name"
    if is_excluded "$name"; then
        printf '{"drive":"%s","name":%s,"status":"excluded"}\n' \
            "$DRIVE_LABEL" "$(printf '%s' "$name" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))')"
        continue
    fi
    # get stat (size, mtime, type)
    if ! stat_out=$(stat -c '%Y|%s|%F' "$full" 2>/dev/null); then
        printf '{"drive":"%s","name":%s,"status":"error"}\n' \
            "$DRIVE_LABEL" "$(printf '%s' "$name" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))')"
        continue
    fi
    IFS='|' read -r mtime size ftype <<< "$stat_out"

    if [[ "$ftype" == "directory" ]]; then
        # direct child count (no recursion)
        child_count=$(ls -A "$full" 2>/dev/null | wc -l)
        # check for project markers
        has_git=0
        [[ -e "$full/.git" ]] && has_git=1
        has_pkg=0
        for marker in package.json pom.xml build.gradle Cargo.toml pyproject.toml composer.json go.mod; do
            [[ -e "$full/$marker" ]] && { has_pkg=1; break; }
        done
        # sample first 5 direct children
        samples=$(ls -A "$full" 2>/dev/null | head -5 | python3 -c '
import json, sys
print(json.dumps([l.rstrip() for l in sys.stdin]))
' 2>/dev/null || echo '[]')
        python3 -c "
import json
print(json.dumps({
    'drive': '$DRIVE_LABEL',
    'name': '''$name'''.replace(chr(10),' '),
    'type': 'dir',
    'mtime': int('$mtime'),
    'child_count': int('$child_count'),
    'has_git': bool($has_git),
    'has_pkg_marker': bool($has_pkg),
    'samples': $samples,
}, ensure_ascii=False))
" 2>/dev/null
    else
        # file at top-level
        python3 -c "
import json
print(json.dumps({
    'drive': '$DRIVE_LABEL',
    'name': '''$name'''.replace(chr(10),' '),
    'type': 'file',
    'mtime': int('$mtime'),
    'size': int('$size'),
}, ensure_ascii=False))
" 2>/dev/null
    fi
done
