#!/usr/bin/env bash
# session-index.sh — ~/.claude/projects/ 하위 세션 인덱스 출력
# 출력: 세션명 | 날짜 | 크기 | 작업 디렉토리

PROJECTS_DIR="${HOME}/.claude/projects"

echo "=== Claude Session Index ==="
echo "$(date '+%Y-%m-%d %H:%M:%S')"
echo ""
printf "%-55s %-12s %-8s %s\n" "SESSION" "MODIFIED" "SIZE" "PROJECT_DIR"
printf '%s\n' "$(printf '%.0s-' {1..110})"

find "${PROJECTS_DIR}" -name "*.jsonl" -not -path "*/offload/*" 2>/dev/null | while read -r f; do
    session=$(basename "${f}" .jsonl)
    proj_dir=$(basename "$(dirname "${f}")" | sed 's/^-home-[^-]*-/~\//' | sed 's/-/\//g')
    mod_date=$(stat -c '%y' "${f}" 2>/dev/null | cut -d' ' -f1)
    size=$(du -sh "${f}" 2>/dev/null | cut -f1)
    printf "%-55s %-12s %-8s %s\n" "${session:0:54}" "${mod_date}" "${size}" "${proj_dir:0:50}"
done | sort -k2 -r | head -30

echo ""
echo "--- Summary ---"
total=$(find "${PROJECTS_DIR}" -name "*.jsonl" -not -path "*/offload/*" 2>/dev/null | wc -l)
echo "Total sessions: ${total}"
