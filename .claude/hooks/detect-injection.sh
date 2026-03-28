#!/usr/bin/env bash
# detect-injection.sh — 프롬프트 인젝션 패턴 감지 + 차단
# PreToolUse 훅: BLOCK 패턴은 차단, WARN 패턴은 로깅만

TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
LOG_FILE="${PWD}/.claude/security.log"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Only check text-input tools
case "$TOOL_NAME" in
  Bash|Write|Edit|Agent|WebFetch) ;; # check these
  *) exit 0 ;; # skip others
esac

# Read tool input from environment
INPUT="${CLAUDE_TOOL_INPUT:-}"
[ -z "$INPUT" ] && exit 0

# BLOCK patterns — high-confidence injection, exit 2 to block
BLOCK_PATTERNS=(
  "ignore previous instructions"
  "ignore all previous"
  "forget your instructions"
  "disregard your"
  "override your instructions"
  "you are now an unrestricted"
  "jailbreak"
  "DAN mode"
)

# WARN patterns — suspicious but could be legitimate, log only
WARN_PATTERNS=(
  "you are now"
  "new role:"
  "system:"
  "<system>"
  "</system>"
  "override your"
  "act as if you have no restrictions"
)

# Check BLOCK patterns first
for pattern in "${BLOCK_PATTERNS[@]}"; do
  if echo "$INPUT" | grep -qi "$pattern"; then
    echo "{\"ts\":\"$TS\",\"event\":\"injection_blocked\",\"tool\":\"$TOOL_NAME\",\"pattern\":\"$pattern\"}" >> "$LOG_FILE"
    echo "[Security] BLOCKED: Injection pattern '$pattern' in $TOOL_NAME input" >&2
    exit 2  # block the tool call
  fi
done

# Check WARN patterns
for pattern in "${WARN_PATTERNS[@]}"; do
  if echo "$INPUT" | grep -qi "$pattern"; then
    echo "{\"ts\":\"$TS\",\"event\":\"injection_suspect\",\"tool\":\"$TOOL_NAME\",\"pattern\":\"$pattern\"}" >> "$LOG_FILE"
    echo "[Security] WARNING: Suspicious pattern '$pattern' in $TOOL_NAME input" >&2
    exit 0  # allow but log
  fi
done

exit 0
