#!/usr/bin/env bash
# track-override-rate.sh — Stop/SubagentStop 훅
# 세션 종료 시 override 관련 키워드 발생 횟수를 집계하여 override-rate.log에 기록
#
# Override 정의: 사용자가 AI의 결정/계획/코드를 수정/거부한 경우
# 감지 방법: 세션 내 usage.log의 Bash 실행 중 "deny" 패턴 + 학습 항목 수

FORGE_ROOT="${PWD}"
LOG_DIR="${FORGE_ROOT}/.claude"
OVERRIDE_LOG="${LOG_DIR}/override-rate.log"
USAGE_LOG="${LOG_DIR}/usage.log"

TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION="${CLAUDE_SESSION_ID:-unknown}"
DATE=$(date +"%Y-%m-%d")

# stdin에서 Hook JSON 읽기
HOOK_JSON=""
if [ ! -t 0 ]; then
  HOOK_JSON=$(cat 2>/dev/null || true)
fi

# 세션의 총 tool 호출 수 (usage.log에서)
TOTAL_TOOLS=0
SESSION_OVERRIDES=0

if [ -f "$USAGE_LOG" ]; then
  # 오늘 날짜의 usage.log에서 tool 호출 수 계산
  TOTAL_TOOLS=$(grep -c "\"session\":\"${SESSION}\"" "$USAGE_LOG" 2>/dev/null || echo "0")
fi

# learnings.jsonl에서 이 세션의 신규 학습 수 (override 간접 지표)
LEARNINGS_TODAY=0
LEARNINGS_FILE="${FORGE_ROOT}/.claude/learnings.jsonl"
if [ -f "$LEARNINGS_FILE" ]; then
  LEARNINGS_TODAY=$(grep -c "\"date\":\"${DATE}\"" "$LEARNINGS_FILE" 2>/dev/null || echo "0")
fi

# override-rate.log가 없으면 헤더 생성
if [ ! -f "$OVERRIDE_LOG" ]; then
  echo "timestamp,session,date,total_tools,learnings_added,override_rate_pct,note" > "$OVERRIDE_LOG"
fi

# Override rate 계산 (학습 항목 수 / 총 tool 호출 수 × 100)
# 학습 = AI 행동 교정 지표. 비율이 높으면 override 빈도 높음
if [ "$TOTAL_TOOLS" -gt 0 ] 2>/dev/null; then
  RATE=$(echo "scale=1; ${LEARNINGS_TODAY} * 100 / ${TOTAL_TOOLS}" | bc 2>/dev/null || echo "0")
else
  RATE="0"
fi

# 로그 기록
echo "${TS},${SESSION},${DATE},${TOTAL_TOOLS},${LEARNINGS_TODAY},${RATE},session_end" >> "$OVERRIDE_LOG"

exit 0
