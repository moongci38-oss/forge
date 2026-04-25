#!/usr/bin/env bash
# agent-token-budget.sh — PostToolUse hook
# 에이전트별 도구 호출 횟수를 추적하고, 예산 초과 시 경고/Kill 신호 발생
#
# 동작:
# 1. 세션별 에이전트 도구 호출 횟수를 카운트 파일에 누적
# 2. 동일 오류 패턴 3회 반복 감지 → BLOCK
# 3. 도구 호출 횟수 상한 도달 → 경고 로그
#
# 환경변수:
#   CLAUDE_SESSION_ID — 세션 식별
#   CLAUDE_TOOL_NAME — 도구 이름
#   TOOL_USE_RESULT — 도구 실행 결과 (stdin)

BUDGET_DIR="${PWD}/.claude/agent-budget"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# stdin에서 Hook JSON 읽기 (session_id, tool_name, tool_response)
HOOK_JSON=""
if [ ! -t 0 ]; then
  HOOK_JSON=$(cat 2>/dev/null || true)
fi

# session_id 추출 (Hook JSON 우선, env fallback)
SESSION=$(echo "$HOOK_JSON" | jq -r '.session_id // empty' 2>/dev/null)
[ -z "$SESSION" ] && SESSION="${CLAUDE_SESSION_ID:-unknown}"

# 도구명 추출 (Hook JSON 우선, env fallback)
TOOL_NAME=$(echo "$HOOK_JSON" | jq -r '.tool_name // empty' 2>/dev/null)
[ -z "$TOOL_NAME" ] && TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"

# 예산 설정 (도구 호출 횟수 기준)
BUDGET_SEARCH=100      # 탐색/검색 에이전트
BUDGET_WRITE=400       # 문서 작성 에이전트
BUDGET_LEAD=600        # 리드/오케스트레이터
BUDGET_DEFAULT=300     # 기본
WARN_THRESHOLD=85      # 85% 도달 시 경고

# 반복 오류 Kill 기준
MAX_SAME_ERROR=3

# 디렉토리 생성
mkdir -p "$BUDGET_DIR"

# 세션별 카운트 파일
COUNT_FILE="$BUDGET_DIR/${SESSION}.count"
ERROR_FILE="$BUDGET_DIR/${SESSION}.errors"

# 카운트 증가
if [ -f "$COUNT_FILE" ]; then
  COUNT=$(cat "$COUNT_FILE")
  COUNT=$((COUNT + 1))
else
  COUNT=1
fi
echo "$COUNT" > "$COUNT_FILE"

# Hook JSON에서 tool_response 추출 (에러 감지용, 최대 500자)
RESULT=$(echo "$HOOK_JSON" | jq -r '.tool_response // .tool_input // empty' 2>/dev/null | head -c 500)

# 에러 패턴 감지
if echo "$RESULT" | grep -qiE "(error|failed|exception|traceback|FAIL)" 2>/dev/null; then
  # 에러 시그니처 (첫 80자)
  ERROR_SIG=$(echo "$RESULT" | head -c 80 | tr '\n' ' ')
  echo "$ERROR_SIG" >> "$ERROR_FILE"

  # 동일 에러 3회 반복 체크
  if [ -f "$ERROR_FILE" ]; then
    LAST_THREE=$(tail -3 "$ERROR_FILE" 2>/dev/null)
    UNIQUE_COUNT=$(echo "$LAST_THREE" | sort -u | wc -l)
    TOTAL_ERRORS=$(wc -l < "$ERROR_FILE")

    if [ "$TOTAL_ERRORS" -ge "$MAX_SAME_ERROR" ] && [ "$UNIQUE_COUNT" -le 1 ]; then
      # 동일 에러 3회 반복 → 경고 로그 (Hook은 BLOCK 불가하므로 로그로 에스컬레이션)
      LOG_FILE="${PWD}/.claude/usage.log"
      printf '{"ts":"%s","event":"agent_kill","reason":"same_error_3x","session":"%s","tool":"%s","error_sig":"%s","count":%d}\n' \
        "$TS" "$SESSION" "$TOOL_NAME" "$ERROR_SIG" "$COUNT" >> "$LOG_FILE"

      # stderr로 경고 출력 (에이전트에게 전달)
      echo "⚠️ AGENT BUDGET: 동일 오류 ${MAX_SAME_ERROR}회 반복 감지. 현재 접근 방식을 중단하고 다른 전략을 시도하세요." >&2
    fi
  fi
fi

# 예산 체크 (기본 예산 사용 — 에이전트 타입별 분류는 도구명으로 추론)
BUDGET=$BUDGET_DEFAULT
case "$TOOL_NAME" in
  Grep|Glob|Read|WebFetch|WebSearch) BUDGET=$BUDGET_SEARCH ;;
  Write|Edit|NotebookEdit) BUDGET=$BUDGET_WRITE ;;
  Agent|TaskCreate|TaskUpdate) BUDGET=$BUDGET_LEAD ;;
esac

WARN_AT=$(( BUDGET * WARN_THRESHOLD / 100 ))

if [ "$COUNT" -ge "$BUDGET" ]; then
  LOG_FILE="${PWD}/.claude/usage.log"
  printf '{"ts":"%s","event":"budget_exceeded","session":"%s","tool":"%s","count":%d,"budget":%d}\n' \
    "$TS" "$SESSION" "$TOOL_NAME" "$COUNT" "$BUDGET" >> "$LOG_FILE"
  echo "🛑 AGENT BUDGET: 도구 호출 ${COUNT}/${BUDGET} — 예산 초과. 작업을 정리하고 결과를 반환하세요." >&2
elif [ "$COUNT" -ge "$WARN_AT" ]; then
  if [ $(( COUNT % 20 )) -eq 0 ]; then
    # 20회마다 경고 (매번 출력하면 노이즈)
    echo "⚠️ AGENT BUDGET: 도구 호출 ${COUNT}/${BUDGET} (${WARN_THRESHOLD}% 초과). 작업 마무리를 준비하세요." >&2
  fi
fi

exit 0
