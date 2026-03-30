#!/usr/bin/env bash
# auto-learn-save.sh — SessionStop
# 세션 종료 시 usage.log 기반으로 세션 활동을 learnings.jsonl에 자동 저장
# 세션이 5분 미만이면 스킵

LEARNINGS_FILE="${PWD}/.claude/learnings.jsonl"
USAGE_LOG="${PWD}/.claude/usage.log"
MIN_SESSION_SECONDS=300  # 5분

# usage.log가 없으면 스킵
if [ ! -f "$USAGE_LOG" ]; then
  exit 0
fi

SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
NOW_EPOCH=$(date +%s)

# 현재 세션의 첫 번째 이벤트 타임스탬프 추출
if [ "$SESSION_ID" != "unknown" ]; then
  FIRST_TS=$(grep "\"session\":\"$SESSION_ID\"" "$USAGE_LOG" 2>/dev/null | head -1 | grep -o '"ts":"[^"]*"' | cut -d'"' -f4)
else
  # 세션 ID 없으면 오늘 날짜의 첫 이벤트 사용
  TODAY=$(date -u +%Y-%m-%d)
  FIRST_TS=$(grep "\"ts\":\"${TODAY}" "$USAGE_LOG" 2>/dev/null | head -1 | grep -o '"ts":"[^"]*"' | cut -d'"' -f4)
fi

if [ -z "$FIRST_TS" ]; then
  exit 0
fi

# 세션 시작 epoch 계산 (GNU date / BSD date 호환)
FIRST_EPOCH=$(date -u -d "$FIRST_TS" +%s 2>/dev/null || date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$FIRST_TS" +%s 2>/dev/null)
if [ -z "$FIRST_EPOCH" ]; then
  exit 0
fi

SESSION_DURATION=$(( NOW_EPOCH - FIRST_EPOCH ))

# 5분 미만이면 스킵
if [ "$SESSION_DURATION" -lt "$MIN_SESSION_SECONDS" ]; then
  exit 0
fi

# 현재 세션에서 사용된 도구 집계 (도구명만 추출, 따옴표 제거)
if [ "$SESSION_ID" != "unknown" ]; then
  TOOL_COUNTS=$(grep "\"session\":\"$SESSION_ID\"" "$USAGE_LOG" 2>/dev/null \
    | grep -o '"tool":"[^"]*"' | sed 's/"tool":"//;s/"//' \
    | sort | uniq -c | sort -rn | head -5 \
    | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
  EVENT_COUNT=$(grep -c "\"session\":\"$SESSION_ID\"" "$USAGE_LOG" 2>/dev/null || echo 0)
else
  TODAY=$(date -u +%Y-%m-%d)
  TOOL_COUNTS=$(grep "\"ts\":\"${TODAY}" "$USAGE_LOG" 2>/dev/null \
    | grep -o '"tool":"[^"]*"' | sed 's/"tool":"//;s/"//' \
    | sort | uniq -c | sort -rn | head -5 \
    | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
  EVENT_COUNT=$(grep -c "\"ts\":\"${TODAY}" "$USAGE_LOG" 2>/dev/null || echo 0)
fi

# 세션 요약 생성
DURATION_MIN=$(( SESSION_DURATION / 60 ))
PROJECT=$(basename "${PWD}")
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# learnings.jsonl 파일이 없으면 생성
touch "$LEARNINGS_FILE"

# 유효한 JSON으로 세션 활동 저장
printf '{"timestamp":"%s","pattern":"session_activity","solution":"session=%s duration=%dmin events=%d top_tools=[%s]","project":"%s","type":"session_summary"}\n' \
  "$TS" "$SESSION_ID" "$DURATION_MIN" "$EVENT_COUNT" "$TOOL_COUNTS" "$PROJECT" \
  >> "$LEARNINGS_FILE"

exit 0
