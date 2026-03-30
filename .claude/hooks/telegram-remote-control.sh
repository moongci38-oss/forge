#!/bin/bash
# Telegram Remote Control — tmux 의존성 제거 버전
# plan 파일 + 세션 파일 기반으로 동작

ACTION="$1"
PIN="$2"

# PIN 검증
CONFIG="$HOME/.claude/telegram-remote.json"
if [ ! -f "$CONFIG" ]; then
  echo "설정 파일 없음"
  exit 1
fi

STORED_PIN=$(python3 -c "import json; print(json.load(open('$CONFIG'))['pin'])" 2>/dev/null)
if [ "$PIN" != "$STORED_PIN" ]; then
  echo "비밀번호가 틀렸습니다"
  exit 1
fi

SESSION_DIR="/tmp/claude-sessions"
PLAN_DIR="$HOME/.claude/plans"
# lock 신호 파일 — Claude Code 세션이 감지할 수 있는 마커
LOCK_FILE="/tmp/claude-remote-lock"

case "$ACTION" in
  unlock)
    RESULT=""

    # 1. Plan 파일 삭제
    if [ -d "$PLAN_DIR" ]; then
      PLAN_COUNT=$(ls "$PLAN_DIR"/*.md 2>/dev/null | wc -l)
      if [ "$PLAN_COUNT" -gt 0 ]; then
        rm -f "$PLAN_DIR"/*.md
        RESULT="Plan 파일 ${PLAN_COUNT}개 삭제."
      fi
    fi

    # 2. Lock 신호 파일 제거
    if [ -f "$LOCK_FILE" ]; then
      rm -f "$LOCK_FILE"
      RESULT="${RESULT} Lock 해제."
    fi

    # 3. tmux (있으면)
    PANES=$(tmux list-panes -a -F '#{pane_id} #{pane_current_command}' 2>/dev/null | grep -i claude | awk '{print $1}')
    if [ -n "$PANES" ]; then
      for pane in $PANES; do
        tmux send-keys -t "$pane" Escape 2>/dev/null
      done
      RESULT="${RESULT} tmux $(echo "$PANES" | wc -w)개 pane Escape."
    fi

    [ -z "$RESULT" ] && RESULT="이미 unlock 상태."
    echo "Unlock 완료: $RESULT"
    ;;

  lock)
    # 1. Lock 신호 파일 생성
    echo "$(date +%s)" > "$LOCK_FILE"
    RESULT="Lock 신호 설정."

    # 2. tmux (있으면)
    PANES=$(tmux list-panes -a -F '#{pane_id} #{pane_current_command}' 2>/dev/null | grep -i claude | awk '{print $1}')
    if [ -n "$PANES" ]; then
      for pane in $PANES; do
        tmux send-keys -t "$pane" "/plan" Enter 2>/dev/null
      done
      RESULT="${RESULT} tmux $(echo "$PANES" | wc -w)개 pane /plan 전송."
    fi

    echo "Lock 완료: $RESULT"
    ;;

  status)
    # 활성 세션 수 (2시간 내)
    SESSIONS=$(find "$SESSION_DIR" -mmin -120 -type f 2>/dev/null | wc -l)

    # Plan 파일 수
    PLAN_COUNT=$(ls "$PLAN_DIR"/*.md 2>/dev/null | wc -l)

    # Lock 상태
    if [ -f "$LOCK_FILE" ]; then
      LOCK_STATUS="LOCKED"
    else
      LOCK_STATUS="UNLOCKED"
    fi

    # tmux pane (있으면)
    TMUX_PANES=$(tmux list-panes -a -F '#{pane_id} #{pane_current_command}' 2>/dev/null | grep -i claude | wc -l)

    echo "상태: ${LOCK_STATUS} | 세션: ${SESSIONS}개 | Plan: ${PLAN_COUNT}개 | tmux: ${TMUX_PANES}개"
    ;;

  *)
    echo "Usage: $0 {unlock|lock|status} <PIN>"
    exit 1
    ;;
esac
