#!/usr/bin/env bash
# cleanup-plans.sh — Stop hook
# .claude/plans/ 파일 정리:
#   - 7일 이상 된 파일 → 삭제
#   - 7일 미만 파일 → .claude/plans/done/ 이동

PLANS_DIR="${PWD}/.claude/plans"
DONE_DIR="${PLANS_DIR}/done"

# plans 디렉토리 없으면 스킵
[ -d "$PLANS_DIR" ] || exit 0

# 정리할 .md 파일이 없으면 스킵
FILES=$(find "$PLANS_DIR" -maxdepth 1 -name "*.md" 2>/dev/null)
[ -z "$FILES" ] && exit 0

mkdir -p "$DONE_DIR"

find "$PLANS_DIR" -maxdepth 1 -name "*.md" | while read -r f; do
  AGE_DAYS=$(( ( $(date +%s) - $(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f") ) / 86400 ))
  if [ "$AGE_DAYS" -ge 7 ]; then
    rm -f "$f"
  else
    mv "$f" "$DONE_DIR/"
  fi
done

# 글로벌 plans 정리 (~/.claude/plans/)
GLOBAL_PLANS="${HOME}/.claude/plans"
if [ -d "$GLOBAL_PLANS" ]; then
  GLOBAL_DONE="${GLOBAL_PLANS}/done"
  mkdir -p "$GLOBAL_DONE"
  find "$GLOBAL_PLANS" -maxdepth 1 -name "*.md" | while read -r f; do
    AGE_DAYS=$(( ( $(date +%s) - $(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f") ) / 86400 ))
    if [ "$AGE_DAYS" -ge 7 ]; then
      rm -f "$f"
    else
      mv "$f" "$GLOBAL_DONE/"
    fi
  done
fi

exit 0
