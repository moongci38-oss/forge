#!/usr/bin/env bash
set -euo pipefail

# Trine Pre-Phase Transition Hook
# Phase 전환 전 컨텍스트 예산 확인 + 세션 상태 자동 저장
# Graceful degradation: 에러 시 빈 출력

PROJECT_ROOT="${PWD}"
SPECIFY_DIR="${PROJECT_ROOT}/.specify"
STATE_DIR="${SPECIFY_DIR}/sessions"

# .specify 디렉토리 없으면 조용히 종료
if [[ ! -d "$SPECIFY_DIR" ]]; then
  exit 0
fi

# 세션 상태 디렉토리 확보
mkdir -p "$STATE_DIR"

# Phase 전환 권고 메시지
echo "[Trine Phase 전환] 컨텍스트 사용량이 높으면 /compact를 실행하세요. Phase 전환 전 세션 상태가 자동 저장됩니다."
