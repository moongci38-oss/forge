#!/usr/bin/env bash
# detect-injection.sh — 프롬프트 인젝션 패턴 모니터링 (차단 없음)
# PreToolUse 훅: 의심 패턴 감지 시 security.log에 기록

TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
LOG_FILE="${PWD}/.claude/security.log"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Only check text-input tools
case "$TOOL_NAME" in
  Bash|Write|Edit|Agent) ;; # check these
  *) exit 0 ;; # skip others
esac

# Read tool input from environment
INPUT="${CLAUDE_TOOL_INPUT:-}"
[ -z "$INPUT" ] && exit 0

# Pattern check (case insensitive)
PATTERNS=(
  "ignore previous instructions"
  "ignore all previous"
  "you are now"
  "new role:"
  "system:"
  "<system>"
  "</system>"
  "forget your instructions"
  "disregard your"
  "override your"
)

for pattern in "${PATTERNS[@]}"; do
  if echo "$INPUT" | grep -qi "$pattern"; then
    echo "{\"ts\":\"$TS\",\"event\":\"injection_suspect\",\"tool\":\"$TOOL_NAME\",\"pattern\":\"$pattern\"}" >> "$LOG_FILE"
    echo "[Security] Injection pattern detected: '$pattern' in $TOOL_NAME input" >&2
    exit 0  # monitor only, don't block
  fi
done

exit 0
