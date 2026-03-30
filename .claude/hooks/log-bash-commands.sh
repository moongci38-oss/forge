#!/bin/bash
# Log all Bash tool commands to ~/.claude/bash-history.log
CMD=$(jq -r '.tool_input.command // ""' 2>/dev/null)
if [ -n "$CMD" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $CMD" >> ~/.claude/bash-history.log
fi
