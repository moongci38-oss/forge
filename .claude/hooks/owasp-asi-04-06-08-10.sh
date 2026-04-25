#!/usr/bin/env bash
# owasp-asi-04-06-08-10.sh — OWASP Agentic Security Top 10 잔여 4개 대응
# PreToolUse + PostToolUse 훅 (settings.json에서 이벤트별로 호출)
#
# ASI-04: Memory Poisoning   — learnings.jsonl 쓰기 시 의심 패턴 검사
# ASI-06: Excessive Perms    — Bash에서 과도한 권한 요청 감지
# ASI-08: Vector/RAG Poison  — RAG 검색 결과 길이/인코딩 이상 감지
# ASI-10: Model DoS          — 세션 내 반복 루프 감지 + 속도 제한
#
# 환경변수:
#   OWASP_MODE: "pre" (PreToolUse) | "post" (PostToolUse)

LOG_FILE="${PWD}/.claude/security.log"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
MODE="${OWASP_MODE:-pre}"

# stdin에서 Hook JSON 읽기
HOOK_JSON=""
if [ ! -t 0 ]; then
  HOOK_JSON=$(cat 2>/dev/null || true)
fi

TOOL_NAME=$(echo "$HOOK_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)
[ -z "$TOOL_NAME" ] && exit 0

# ── ASI-06: Excessive Permissions (PreToolUse) ────────────────────────────
# Bash 명령에서 과도한 권한 요청 패턴 감지

if [ "$MODE" = "pre" ] && [ "$TOOL_NAME" = "Bash" ]; then
  CMD=$(echo "$HOOK_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

  # chmod 777 / 권한 최대화 패턴
  if echo "$CMD" | grep -qE "chmod\s+(777|a\+rwx|ugo\+rwx|o\+rwx)"; then
    MSG="[ASI-06] WARN: 과도한 파일 권한 부여 감지: ${CMD:0:80}"
    echo "$TS WARN $MSG" >> "$LOG_FILE"
    echo "⚠️  $MSG" >&2
  fi

  # sudo + 민감 명령
  if echo "$CMD" | grep -qE "sudo\s+(rm|chmod|chown|passwd|visudo|crontab)\s"; then
    MSG="[ASI-06] WARN: sudo + 민감 명령 감지: ${CMD:0:80}"
    echo "$TS WARN $MSG" >> "$LOG_FILE"
    echo "⚠️  $MSG" >&2
  fi

  # /etc, /sys, /proc 쓰기
  if echo "$CMD" | grep -qE ">\s*/etc/|tee\s*/etc/|>\s*/sys/|>\s*/proc/"; then
    MSG="[ASI-06] BLOCK: 시스템 디렉토리 직접 쓰기 시도: ${CMD:0:80}"
    echo "$TS BLOCK $MSG" >> "$LOG_FILE"
    echo "⛔ $MSG" >&2
    exit 2
  fi
fi

# ── ASI-04: Memory Poisoning (PreToolUse - Write) ─────────────────────────
# learnings.jsonl 또는 메모리 파일 쓰기 시 의심 패턴 검사

if [ "$MODE" = "pre" ] && [ "$TOOL_NAME" = "Write" ]; then
  FILE_PATH=$(echo "$HOOK_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)
  CONTENT=$(echo "$HOOK_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('content','')[:500])" 2>/dev/null)

  if echo "$FILE_PATH" | grep -qE "(learnings\.jsonl|memory/|MEMORY\.md)"; then
    # 의심 패턴: 프롬프트 인젝션을 learnings에 심으려는 시도
    INJECTION_PATTERNS=(
      "ignore previous"
      "override your"
      "new instructions"
      "forget your rules"
      "DAN mode"
    )
    for pat in "${INJECTION_PATTERNS[@]}"; do
      if echo "$CONTENT" | grep -qi "$pat"; then
        MSG="[ASI-04] BLOCK: 메모리 파일에 인젝션 패턴 감지 (${pat}): $FILE_PATH"
        echo "$TS BLOCK $MSG" >> "$LOG_FILE"
        echo "⛔ $MSG" >&2
        exit 2
      fi
    done

    # JSON 구조 검증 (learnings.jsonl)
    if echo "$FILE_PATH" | grep -q "learnings.jsonl"; then
      # 각 줄이 유효한 JSON인지 샘플 체크
      if echo "$CONTENT" | head -5 | grep -v "^{" | grep -v "^$" | grep -q "."; then
        MSG="[ASI-04] WARN: learnings.jsonl에 비JSON 형식 데이터 감지"
        echo "$TS WARN $MSG" >> "$LOG_FILE"
        echo "⚠️  $MSG" >&2
      fi
    fi
  fi
fi

# ── ASI-08: Vector/RAG Poisoning (PostToolUse) ───────────────────────────
# RAG 검색 결과 이상 감지 (비정상적으로 긴 결과, 인코딩 혼합)

if [ "$MODE" = "post" ] && [ "$TOOL_NAME" = "mcp__brave-search__brave_web_search" ]; then
  RESULT=$(echo "$HOOK_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(str(d.get('tool_result',''))[:1000])" 2>/dev/null)
  RESULT_LEN=${#RESULT}

  # 비정상적으로 긴 단일 결과 (RAG poisoning 지표)
  if [ "$RESULT_LEN" -gt 900 ]; then
    MSG="[ASI-08] WARN: 웹 검색 결과 비정상적으로 큼 (${RESULT_LEN}자)"
    echo "$TS WARN $MSG" >> "$LOG_FILE"
    # WARN만 (차단 안 함 — 합법적인 긴 결과도 있음)
  fi

  # Base64 또는 인코딩된 데이터 삽입 감지
  if echo "$RESULT" | grep -qE "[A-Za-z0-9+/]{60,}={0,2}"; then
    MSG="[ASI-08] WARN: 웹 검색 결과에 Base64 인코딩 데이터 감지"
    echo "$TS WARN $MSG" >> "$LOG_FILE"
    echo "⚠️  $MSG" >&2
  fi
fi

# ── ASI-10: Model DoS (PostToolUse) ──────────────────────────────────────
# 세션 내 동일 도구 반복 호출 감지 (루프 방지 보완)

if [ "$MODE" = "post" ]; then
  RATE_DIR="${PWD}/.claude/agent-budget"
  SESSION="${CLAUDE_SESSION_ID:-unknown}"
  RATE_FILE="$RATE_DIR/${SESSION}.rate"

  mkdir -p "$RATE_DIR"

  # 현재 분(minute) 내 호출 수 추적
  CURRENT_MINUTE=$(date +"%H%M")
  RATE_KEY="${CURRENT_MINUTE}:${TOOL_NAME}"

  if [ -f "$RATE_FILE" ]; then
    LAST_KEY=$(head -1 "$RATE_FILE" 2>/dev/null)
    LAST_COUNT=$(tail -1 "$RATE_FILE" 2>/dev/null)
    LAST_COUNT="${LAST_COUNT:-0}"

    if [ "$LAST_KEY" = "$RATE_KEY" ]; then
      NEW_COUNT=$((LAST_COUNT + 1))
      # 같은 분에 동일 도구 30회 초과 → DoS 경고
      if [ "$NEW_COUNT" -gt 30 ]; then
        MSG="[ASI-10] WARN: ${TOOL_NAME} 분당 ${NEW_COUNT}회 호출 (DoS 위험)"
        echo "$TS WARN $MSG" >> "$LOG_FILE"
        echo "⚠️  $MSG" >&2
      fi
      printf "%s\n%d" "$RATE_KEY" "$NEW_COUNT" > "$RATE_FILE"
    else
      # 새 분 또는 다른 도구 — 리셋
      printf "%s\n1" "$RATE_KEY" > "$RATE_FILE"
    fi
  else
    printf "%s\n1" "$RATE_KEY" > "$RATE_FILE"
  fi
fi

exit 0
