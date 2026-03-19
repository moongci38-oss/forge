#!/usr/bin/env bash
# usage-logger.sh — PostToolUse 도구 사용 로거
# JSONL 형식으로 .claude/usage.log에 기록

LOG_FILE="${PWD}/.claude/usage.log"
TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION="${CLAUDE_SESSION_ID:-unknown}"

# Detect subtype
SUBTYPE="tool"
case "$TOOL_NAME" in
  Agent) SUBTYPE="agent" ;;
  Skill) SUBTYPE="skill" ;;
esac

echo "{\"ts\":\"$TS\",\"event\":\"tool_use\",\"tool\":\"$TOOL_NAME\",\"subtype\":\"$SUBTYPE\",\"session\":\"$SESSION\"}" >> "$LOG_FILE"
