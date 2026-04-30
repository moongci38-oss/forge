#!/usr/bin/env bash
# check-diff-size.sh — PR/commit diff 크기 확인 및 ultrareview 권고
# 사용: bash ~/.claude/hooks/check-diff-size.sh [base_branch]
# git push 전 수동 실행 또는 CI에서 호출

THRESHOLD=300
BASE=${1:-main}

# 현재 diff 라인 수 계산
DIFF_LINES=$(git diff "${BASE}"...HEAD --stat 2>/dev/null | tail -1 | grep -oE '[0-9]+ insertion|[0-9]+ deletion' | grep -oE '[0-9]+' | awk '{sum+=$1} END {print sum}')

if [ -z "${DIFF_LINES}" ]; then
    DIFF_LINES=$(git diff --stat 2>/dev/null | tail -1 | grep -oE '[0-9]+' | head -1)
fi

DIFF_LINES=${DIFF_LINES:-0}

if [ "${DIFF_LINES}" -gt "${THRESHOLD}" ]; then
    echo "⚠️  [ultrareview 권고] diff 크기: ${DIFF_LINES}줄 (임계값: ${THRESHOLD}줄)"
    echo "   대규모 PR — 독립 검토자 관점에서 /ultrareview 실행 권장"
    echo "   실행: /ultrareview"
else
    echo "✅ diff 크기: ${DIFF_LINES}줄 (${THRESHOLD}줄 이하 — 정상)"
fi
