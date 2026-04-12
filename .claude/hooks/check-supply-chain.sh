#!/usr/bin/env bash
# check-supply-chain.sh — OWASP ASI-03 Supply Chain 검사
# PreToolUse 훅: 의심스러운 패키지/의존성 설치 명령 감지
#
# 감지 대상:
# 1. npm/pip/gem 설치 시 알려진 typosquatting 패턴
# 2. 비공식 레지스트리 from-URL 설치
# 3. 스크립트 직접 curl | bash 패턴

LOG_FILE="${PWD}/.claude/security.log"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# stdin에서 Hook JSON 읽기
HOOK_JSON=""
if [ ! -t 0 ]; then
  HOOK_JSON=$(cat 2>/dev/null || true)
fi

# Bash 도구만 검사
TOOL_NAME=$(echo "$HOOK_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)
[ "$TOOL_NAME" != "Bash" ] && exit 0

COMMAND=$(echo "$HOOK_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)
[ -z "$COMMAND" ] && exit 0

# 1. curl|bash / wget|sh 직접 실행 패턴 (원격 스크립트 직접 실행) — HIGH RISK, BLOCK
if echo "$COMMAND" | grep -qE "curl.*\|.*bash|curl.*\|.*sh|wget.*\|.*bash|wget.*\|.*sh"; then
  MSG="[ASI-03] BLOCKED: 원격 스크립트 직접 실행 차단: ${COMMAND:0:100}"
  echo "$TS BLOCK $MSG" >> "$LOG_FILE"
  echo "$MSG" >&2
  exit 2
fi

# 2. 비공식 레지스트리 또는 Git URL에서 직접 패키지 설치 — WARN (합법 케이스 다수)
if echo "$COMMAND" | grep -qE "pip install.*(git\+http|git\+ssh|https?://(?!pypi))" || \
   echo "$COMMAND" | grep -qE "npm install.*(git\+|github:|gitlab:|bitbucket:|https?://(?!registry\.npmjs))" ; then
  MSG="[ASI-03] WARN: 비공식 소스 패키지 설치 감지: ${COMMAND:0:100}"
  echo "$TS WARN $MSG" >> "$LOG_FILE"
  echo "$MSG" >&2
fi

# 3. 알려진 typosquatting 패턴 — HIGH RISK, BLOCK
TYPO_PATTERNS=(
  "lodahs"
  "reacts"
  "expres "
  "requst"
  "mongoos"
  "axio "
  "expressjs"
  "npminstall"
)
for pattern in "${TYPO_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    MSG="[ASI-03] BLOCKED: 잠재적 typosquatting 패키지 차단: ${COMMAND:0:100}"
    echo "$TS BLOCK $MSG" >> "$LOG_FILE"
    echo "$MSG" >&2
    exit 2
  fi
done

# 4. 시스템 패키지 관리자로 검증되지 않은 PPA/레포 추가
if echo "$COMMAND" | grep -qE "add-apt-repository|ppa:|rpm --import|rpm -i http"; then
  MSG="[ASI-03] WARN: 외부 패키지 레포 추가 감지: ${COMMAND:0:100}"
  echo "$TS WARN $MSG" >> "$LOG_FILE"
  echo "$MSG" >&2
fi

exit 0
