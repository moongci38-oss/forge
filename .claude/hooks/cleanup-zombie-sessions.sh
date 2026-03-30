#!/bin/bash
# Cleanup zombie/stopped Claude Code sessions from previous VS Code closures
# Runs at session start — kills stopped claude processes (not the current one)

CURRENT_PID="$PPID"

# Find stopped (T state) claude processes, exclude current session
ps -eo pid,stat,comm | grep -E 'T.*claude' | while read -r pid stat comm; do
  if [ "$pid" != "$CURRENT_PID" ] && [ -n "$pid" ]; then
    kill -9 "$pid" 2>/dev/null
  fi
done

# Also reap any remaining zombie bun/node processes whose parent is gone
ps -eo pid,ppid,stat,comm | grep -E 'Z.*(bun|node)' | while read -r pid ppid stat comm; do
  # Check if parent still exists
  if ! ps -p "$ppid" > /dev/null 2>&1; then
    kill -9 "$pid" 2>/dev/null
  fi
done

# Kill duplicate telegram bot processes — only the --channels session should run one.
# Find the legitimate channel session's telegram bot (child of "claude --channels")
CHANNEL_PID=$(ps -eo pid,args | grep -F 'claude --channels' | grep -v grep | awk '{print $1}' | head -1)
if [ -n "$CHANNEL_PID" ]; then
  # Kill any telegram bun processes NOT parented by the channel session
  ps -eo pid,ppid,args | grep 'bun.*telegram.*start' | grep -v grep | while read -r pid ppid args; do
    if [ "$ppid" != "$CHANNEL_PID" ]; then
      kill "$pid" 2>/dev/null
    fi
  done
fi
