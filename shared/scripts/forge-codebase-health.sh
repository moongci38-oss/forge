#!/bin/bash
# Forge Codebase Health Check
# Usage: bash forge-codebase-health.sh [project_path] [months=12]
# Example: bash forge-codebase-health.sh ~/mywsl_workspace/portfolio-project 6

PROJECT="${1:-.}"
MONTHS="${2:-12}"
SINCE="${MONTHS} months ago"

# Validate git repo
if ! git -C "$PROJECT" rev-parse --git-dir > /dev/null 2>&1; then
  echo "ERROR: $PROJECT 는 git 저장소가 아닙니다."
  exit 1
fi

echo "========================================"
echo "  Forge Codebase Health Check"
echo "  프로젝트: $PROJECT"
echo "  기간: 최근 ${MONTHS}개월"
echo "========================================"

echo ""
echo "=== 1. 변경 빈도 Top 20 (Hot Files) ==="
git -C "$PROJECT" log --format=format: --name-only \
  --since="$SINCE" | grep -v '^$' | sort | uniq -c | sort -nr | head -20

echo ""
echo "=== 2. 기여자 분포 (최근 6개월, AI 커밋 제외) ==="
git -C "$PROJECT" shortlog -sn --no-merges --since="6 months ago" \
  | grep -v -i "claude\|anthropic\|noreply" || echo "(커밋 없음)"

echo ""
echo "=== 3. 버그 집중 파일 Top 20 ==="
git -C "$PROJECT" log -i -E --grep="^fix|^bug|broken" \
  --name-only --format='' --since="$SINCE" \
  | grep -v '^$' | sort | uniq -c | sort -nr | head -20

echo ""
echo "=== 4. 월별 커밋 속도 (AI 커밋 포함) ==="
git -C "$PROJECT" log --format='%ad' \
  --date=format:'%Y-%m' --since="$SINCE" | sort | uniq -c

echo ""
echo "=== 4-B. 월별 커밋 속도 (Human 커밋만) ==="
git -C "$PROJECT" log --format='%ad %ae' \
  --date=format:'%Y-%m' --since="$SINCE" \
  | grep -v -i "claude\|anthropic\|noreply" \
  | awk '{print $1}' | sort | uniq -c

echo ""
echo "=== 5. 소방(Revert/Hotfix) 빈도 ==="
git -C "$PROJECT" log --oneline --since="$SINCE" \
  | grep -iE 'revert|hotfix|emergency|rollback' || echo "(없음)"

echo ""
echo "=== 요약 ==="
TOTAL_COMMITS=$(git -C "$PROJECT" log --oneline --since="$SINCE" | wc -l)
HUMAN_COMMITS=$(git -C "$PROJECT" log --oneline --since="$SINCE" \
  --author-date-is-committer-date \
  | xargs -I{} git -C "$PROJECT" log --format='%ae' -1 {} 2>/dev/null \
  | grep -v -ic "claude\|anthropic\|noreply" 2>/dev/null || echo "N/A")
TOTAL_FILES=$(git -C "$PROJECT" log --format=format: --name-only \
  --since="$SINCE" | grep -v '^$' | sort -u | wc -l)
echo "총 커밋: ${TOTAL_COMMITS}건 (기간: 최근 ${MONTHS}개월)"
echo "변경된 파일 수: ${TOTAL_FILES}개"
