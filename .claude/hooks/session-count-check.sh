#!/bin/bash
# ELI16 멀티세션 감지 — gstack 패턴 도입
# 2시간 내 활성 세션 3개+ → 컨텍스트 재요약 힌트 제공
# SessionStart 훅으로 실행

SESSION_DIR="/tmp/claude-sessions"
mkdir -p "$SESSION_DIR"

# 현재 세션 등록
echo "$(date +%s)" > "$SESSION_DIR/$$"

# 2시간 내 세션 파일 카운트
ACTIVE=$(find "$SESSION_DIR" -mmin -120 -type f 2>/dev/null | wc -l)

# 오래된 세션 파일 정리 (4시간+)
find "$SESSION_DIR" -mmin +240 -type f -delete 2>/dev/null

if [ "$ACTIVE" -ge 3 ]; then
  if [ "${TELEGRAM_SESSION}" = "1" ]; then
    echo "🤖 Telegram 세션 (chat_id: ${TELEGRAM_CHAT_ID:-unknown}) — 활성 세션 ${ACTIVE}개"
  else
    echo "⚠️ 멀티세션 감지: ${ACTIVE}개 활성 세션. 컨텍스트 혼동 주의 — 작업 시작 시 현재 목표를 명확히 선언하세요."
  fi
fi
