#!/usr/bin/env bash
set -euo pipefail

# Trine Session Context — SessionStart Hook
# 마지막 세션 상태를 읽어 additional_context로 주입
# Graceful degradation: 에러 시 빈 출력 (세션 시작 차단 안 함)
# 토큰 예산: ≤500 tokens

PROJECT_ROOT="${PWD}"
SPECIFY_DIR="${PROJECT_ROOT}/.specify"
STATE_DIR="${SPECIFY_DIR}/sessions"

# .specify 디렉토리 없으면 Trine 프로젝트 아님 — 조용히 종료
if [[ ! -d "$SPECIFY_DIR" ]]; then
  exit 0
fi

# 최신 세션 상태 파일 탐색
LATEST_SESSION=""
if [[ -d "$STATE_DIR" ]]; then
  LATEST_SESSION=$(ls -t "$STATE_DIR"/*.json 2>/dev/null | head -1 || true)
fi

# 컨텍스트 조립
OUTPUT=""

if [[ -n "$LATEST_SESSION" ]]; then
  # 세션 상태에서 핵심 정보 추출 (jq 없으면 grep fallback)
  if command -v jq &>/dev/null; then
    SESSION_NAME=$(jq -r '.sessionName // "unknown"' "$LATEST_SESSION" 2>/dev/null || echo "unknown")
    CURRENT_PHASE=$(jq -r '.currentPhase // "unknown"' "$LATEST_SESSION" 2>/dev/null || echo "unknown")
    AUTOFIX_COUNT=$(jq -r '.autoFixCount // 0' "$LATEST_SESSION" 2>/dev/null || echo "0")
    LAST_CHECK=$(jq -r '.lastCheck // "none"' "$LATEST_SESSION" 2>/dev/null || echo "none")
    SCALE=$(jq -r '.scale // "unknown"' "$LATEST_SESSION" 2>/dev/null || echo "unknown")
  else
    # jq 미설치 시 기본 grep fallback
    SESSION_NAME=$(grep -o '"sessionName"[[:space:]]*:[[:space:]]*"[^"]*"' "$LATEST_SESSION" 2>/dev/null | head -1 | sed 's/.*: *"//;s/"//' || echo "unknown")
    CURRENT_PHASE=$(grep -o '"currentPhase"[[:space:]]*:[[:space:]]*"[^"]*"' "$LATEST_SESSION" 2>/dev/null | head -1 | sed 's/.*: *"//;s/"//' || echo "unknown")
    AUTOFIX_COUNT=$(grep -o '"autoFixCount"[[:space:]]*:[[:space:]]*[0-9]*' "$LATEST_SESSION" 2>/dev/null | head -1 | sed 's/.*: *//' || echo "0")
    LAST_CHECK=$(grep -o '"lastCheck"[[:space:]]*:[[:space:]]*"[^"]*"' "$LATEST_SESSION" 2>/dev/null | head -1 | sed 's/.*: *"//;s/"//' || echo "none")
    SCALE=$(grep -o '"scale"[[:space:]]*:[[:space:]]*"[^"]*"' "$LATEST_SESSION" 2>/dev/null | head -1 | sed 's/.*: *"//;s/"//' || echo "unknown")
  fi

  OUTPUT="[Trine 세션 복원] 세션: ${SESSION_NAME} | 규모: ${SCALE} | Phase: ${CURRENT_PHASE} | AutoFix: ${AUTOFIX_COUNT}/3 | 마지막 Check: ${LAST_CHECK}"

  # 미완료 Spec 확인
  if [[ -d "$SPECIFY_DIR/specs" ]]; then
    PENDING_SPECS=$(find "$SPECIFY_DIR/specs" -name "*.md" -newer "${SPECIFY_DIR}/.last-sync" 2>/dev/null | wc -l || echo "0")
    if [[ "$PENDING_SPECS" -gt 0 ]]; then
      OUTPUT="${OUTPUT} | 미동기화 Spec: ${PENDING_SPECS}개"
    fi
  fi
else
  OUTPUT="[Trine] 이전 세션 없음. /forge 또는 코드 변경 요청으로 시작하세요."
fi

# usage.log 기록 (측정 인프라)
USAGE_LOG="${PROJECT_ROOT}/.claude/usage.log"
mkdir -p "$(dirname "$USAGE_LOG")"
echo "{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"event\":\"session_start\",\"session\":\"${SESSION_NAME:-new}\",\"phase\":\"${CURRENT_PHASE:-unknown}\",\"scale\":\"${SCALE:-unknown}\"}" >> "$USAGE_LOG" 2>/dev/null || true

echo "$OUTPUT"
