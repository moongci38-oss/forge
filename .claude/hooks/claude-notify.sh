#!/bin/bash
# Claude Code 알림 스크립트
# Usage: claude-notify.sh <type> [message]
# type: "complete" | "attention"

TYPE="${1:-complete}"
MSG="${2:-Claude Code}"

case "$TYPE" in
  complete)
    SOUND='C:\Windows\Media\chimes.wav'
    TITLE="Claude - 작업 완료"
    ;;
  attention)
    SOUND='C:\Windows\Media\Windows Notify Calendar.wav'
    TITLE="Claude - 입력 필요"
    ;;
  *)
    SOUND='C:\Windows\Media\Windows Notify System Generic.wav'
    TITLE="Claude Code"
    ;;
esac

# 사운드 재생 + 토스트 팝업 (비동기, 블로킹 안 함)
powershell.exe -NoProfile -Command "
  (New-Object Media.SoundPlayer '$SOUND').PlaySync()
  if (Get-Module -ListAvailable -Name BurntToast) {
    Import-Module BurntToast
    New-BurntToastNotification -Text '$TITLE', '$MSG'
  }
" &>/dev/null &
