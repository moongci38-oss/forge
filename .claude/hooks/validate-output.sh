#!/usr/bin/env bash
# validate-output.sh — PostToolUse 출력 민감 데이터 검증
# AI 생성 응답/도구 출력에 시크릿·민감 정보가 포함되면 차단

LOG_FILE="${PWD}/.claude/security.log"
TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

OUTPUT="${CLAUDE_TOOL_OUTPUT:-}"
[ -z "$OUTPUT" ] && exit 0

# 민감 출력 패턴 — exit 2로 차단
SENSITIVE_PATTERNS=(
  "AKIA[A-Z0-9]{16}"                    # AWS Access Key
  "-----BEGIN.*PRIVATE KEY-----"         # Private Key
  "-----BEGIN RSA PRIVATE KEY-----"      # RSA Key
  "sk-[A-Za-z0-9]{32,}"                 # OpenAI/Anthropic API Key
  "ghp_[A-Za-z0-9]{36}"                 # GitHub PAT
  "glpat-[A-Za-z0-9_-]{20}"            # GitLab PAT
  "[A-Za-z0-9+/]{40}={0,2}"            # Base64 encoded secret (generic)
)

# 경고 패턴 — 로깅만
WARN_PATTERNS=(
  "password.*=.*['\"][^'\"]{6,}['\"]"   # password = "..."
  "secret.*=.*['\"][^'\"]{6,}['\"]"     # secret = "..."
  "token.*=.*['\"][^'\"]{20,}['\"]"     # token = "..."
  "api_key.*=.*['\"][^'\"]{16,}['\"]"   # api_key = "..."
)

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
  if echo "$OUTPUT" | grep -qP "$pattern" 2>/dev/null; then
    echo "{\"ts\":\"$TS\",\"event\":\"output_blocked\",\"tool\":\"$TOOL_NAME\",\"pattern\":\"sensitive_data\"}" >> "$LOG_FILE"
    echo "[Security/OutputRail] BLOCKED: Sensitive data pattern detected in $TOOL_NAME output" >&2
    exit 2
  fi
done

for pattern in "${WARN_PATTERNS[@]}"; do
  if echo "$OUTPUT" | grep -qiP "$pattern" 2>/dev/null; then
    echo "{\"ts\":\"$TS\",\"event\":\"output_warn\",\"tool\":\"$TOOL_NAME\",\"pattern\":\"credential_like\"}" >> "$LOG_FILE"
    echo "[Security/OutputRail] WARNING: Credential-like pattern in $TOOL_NAME output" >&2
    exit 0
  fi
done

exit 0
