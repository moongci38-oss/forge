#!/bin/bash
# git-commit-notify.sh
# PostToolUse hook: Sends desktop notification when a git commit is made
# Registered in ~/.claude/settings.json → PostToolUse → Bash

INPUT=$(cat)

# Extract bash command from hook input
CMD=$(echo "$INPUT" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('command', ''))
" 2>/dev/null)

# Only proceed for git commit commands (not status/log/etc.)
if ! echo "$CMD" | grep -qE '^\s*git\s+commit'; then
    exit 0
fi

# Skip dry runs
if echo "$CMD" | grep -q '\-\-dry-run'; then
    exit 0
fi

# Extract commit message from -m flag
MSG=$(echo "$CMD" | python3 -c "
import sys, re
cmd = sys.stdin.read().strip()
m = re.search(r'-m\s+[\"\'](.*?)[\"\']', cmd, re.DOTALL)
if m:
    print(m.group(1)[:80])
else:
    print('Commit completed')
" 2>/dev/null)
[ -z "$MSG" ] && MSG="Commit completed"

# Delegate to claude-notify.sh (handles BurntToast + sound)
NOTIFY_SCRIPT="/home/damools/.claude/hooks/claude-notify.sh"
if [ -f "$NOTIFY_SCRIPT" ]; then
    bash "$NOTIFY_SCRIPT" "complete" "$MSG" 2>/dev/null
elif command -v notify-send &>/dev/null && [ -n "${DISPLAY:-}" ]; then
    notify-send "Git Commit" "$MSG" 2>/dev/null
elif command -v powershell.exe &>/dev/null; then
    SAFE_MSG=$(echo "$MSG" | sed "s/'/''/g")
    powershell.exe -NoProfile -NonInteractive -Command "
\$ErrorActionPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Windows.Forms
\$n = New-Object System.Windows.Forms.NotifyIcon
\$n.Icon = [System.Drawing.SystemIcons]::Information
\$n.Visible = \$true
\$n.ShowBalloonTip(5000, 'Git Commit', '$SAFE_MSG', 'Info')
Start-Sleep -Milliseconds 2000
\$n.Dispose()
" 2>/dev/null &
fi

exit 0
