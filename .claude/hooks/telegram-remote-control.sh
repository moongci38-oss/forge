#!/bin/bash
# Telegram Remote Control — Plan mode 원격 해제
# tmux 의존성 제거: plan 파일 직접 삭제 + tmux 키입력 병행

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

case "$ACTION" in
  unlock)
    RESULT=""
    
    # 방법 1: plan 파일 삭제 (tmux 불필요)
    PLAN_DIR="$HOME/.claude/plans"
    if [ -d "$PLAN_DIR" ]; then
      PLAN_COUNT=$(ls "$PLAN_DIR"/*.md 2>/dev/null | wc -l)
      if [ "$PLAN_COUNT" -gt 0 ]; then
        rm -f "$PLAN_DIR"/*.md
        RESULT="Plan 파일 ${PLAN_COUNT}개 삭제 완료."
      else
        RESULT="활성 Plan 파일 없음."
      fi
    fi
    
    # 방법 2: tmux pane에 Escape 전송 (있으면)
    PANES=$(tmux list-panes -a -F '#{pane_id} #{pane_current_command}' 2>/dev/null | grep -i claude | awk '{print $1}')
    if [ -n "$PANES" ]; then
      for pane in $PANES; do
        tmux send-keys -t "$pane" Escape 2>/dev/null
      done
      PANE_COUNT=$(echo "$PANES" | wc -w)
      RESULT="${RESULT} tmux ${PANE_COUNT}개 pane에 Escape 전송."
    fi
    
    [ -z "$RESULT" ] && RESULT="Plan 파일 없음, tmux pane 없음."
    echo "Unlock 완료: $RESULT"
    ;;
    
  lock)
    PANES=$(tmux list-panes -a -F '#{pane_id} #{pane_current_command}' 2>/dev/null | grep -i claude | awk '{print $1}')
    if [ -n "$PANES" ]; then
      for pane in $PANES; do
        tmux send-keys -t "$pane" "/plan" Enter 2>/dev/null
      done
      echo "Lock 완료: $(echo "$PANES" | wc -w)개 pane에 /plan 전송"
    else
      echo "Claude tmux pane 없음. 수동으로 /plan을 입력하세요."
    fi
    ;;
    
  status)
    PLAN_COUNT=$(ls "$HOME/.claude/plans/"*.md 2>/dev/null | wc -l)
    PANES=$(tmux list-panes -a -F '#{pane_id} #{pane_current_command}' 2>/dev/null | grep -i claude | wc -l)
    echo "Plan 파일: ${PLAN_COUNT}개 | Claude pane: ${PANES}개"
    ;;
    
  *)
    echo "Usage: $0 {unlock|lock|status} <PIN>"
    exit 1
    ;;
esac
