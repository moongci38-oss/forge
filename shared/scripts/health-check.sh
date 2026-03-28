#!/usr/bin/env bash
# health-check.sh — Forge 전체 시스템 헬스체크
# Usage: bash shared/scripts/health-check.sh [--quiet]

QUIET=false
[[ "$1" == "--quiet" ]] && QUIET=true

FORGE_ROOT="${FORGE_ROOT:-$HOME/forge}"
WORKSPACE_JSON="$FORGE_ROOT/forge-workspace.json"

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m"
BOLD="\033[1m"

PASS=0; WARN=0; FAIL=0

pass() { echo -e "  ${GREEN}✅${NC} $1"; PASS=$((PASS+1)); }
warn() { echo -e "  ${YELLOW}⚠️ ${NC} $1"; WARN=$((WARN+1)); }
fail() { echo -e "  ${RED}❌${NC} $1"; FAIL=$((FAIL+1)); }
header() { echo -e "\n${CYAN}${BOLD}[$1]${NC}"; }

quiet_pass() { [[ "$QUIET" == "false" ]] && pass "$1" || PASS=$((PASS+1)); }

echo -e "${BOLD}=== Forge System Health Check ($(date +%Y-%m-%d)) ===${NC}"

# ─── 1. 도구 ───────────────────────────────────────────────
header "Tools"

check_tool() {
  local name="$1" cmd="$2"
  local ver
  ver=$(eval "$cmd" 2>/dev/null | head -1)
  if [[ -n "$ver" ]]; then
    quiet_pass "$name  $ver"
  else
    warn "$name  not found"
  fi
}

check_tool "git    " "git --version"
check_tool "node   " "node --version"
check_tool "python3" "python3 --version"
check_tool "glab   " "glab version"

# ─── 2. Forge 워크스페이스 ─────────────────────────────────
header "Forge Workspace"

if [[ ! -f "$WORKSPACE_JSON" ]]; then
  fail "forge-workspace.json not found: $WORKSPACE_JSON"
else
  if python3 -c "import json,sys; json.load(open('$WORKSPACE_JSON'))" 2>/dev/null; then
    quiet_pass "forge-workspace.json 파싱 성공"

    # 프로젝트 경로 확인
    while IFS= read -r line; do
      proj=$(echo "$line" | cut -d'|' -f1)
      path=$(echo "$line" | cut -d'|' -f2)
      if [[ "$path" == "null" || -z "$path" ]]; then
        warn "$proj devTarget: 미설정"
      elif [[ -d "$path" ]]; then
        quiet_pass "$proj devTarget: $path"
      else
        warn "$proj devTarget: $path (접근 불가 — WSL/원격 경로일 수 있음)"
      fi
    done < <(python3 - <<'PYEOF'
import json, sys
data = json.load(open(os.environ.get("FORGE_ROOT", os.path.expanduser("~/forge")) + "/forge-workspace.json"))
for name, conf in data.get("projects", {}).items():
    target = conf.get("devTarget", "null")
    print(f"{name}|{target}")
PYEOF
)
  else
    fail "forge-workspace.json JSON 파싱 실패"
  fi
fi

# ─── 3. Git 상태 ───────────────────────────────────────────
header "Git"

if git -C "$FORGE_ROOT" rev-parse --git-dir &>/dev/null; then
  branch=$(git -C "$FORGE_ROOT" branch --show-current 2>/dev/null)
  quiet_pass "forge: $branch 브랜치"

  changed=$(git -C "$FORGE_ROOT" status --porcelain 2>/dev/null | wc -l)
  if [[ "$changed" -eq 0 ]]; then
    quiet_pass "forge: 워킹 트리 깨끗함"
  else
    warn "forge: 미커밋/미트래킹 변경 ${changed}개"
  fi
else
  fail "forge: Git 레포지토리 아님"
fi

# ─── 4. Forge Sync ──────────────────────────────────────────
header "Forge Sync"

SYNC_SCRIPT="$HOME/.claude/scripts/forge-sync.mjs"
if [[ -f "$SYNC_SCRIPT" ]]; then
  sync_out=$(node "$SYNC_SCRIPT" status --quiet 2>&1)
  if echo "$sync_out" | grep -q "불일치\|mismatch\|WARN"; then
    warn "동기화 불일치 발견 — /forge-sync 실행 권장"
  elif echo "$sync_out" | grep -q "error\|Error"; then
    warn "forge-sync 상태 확인 실패: $(echo "$sync_out" | head -1)"
  else
    quiet_pass "모든 프로젝트 동기화 정상"
  fi
else
  warn "forge-sync.mjs 없음 ($SYNC_SCRIPT)"
fi

# ─── 5. MCP 설정 ───────────────────────────────────────────
header "MCP"

MCP_JSON="$FORGE_ROOT/.mcp.json"
if [[ -f "$MCP_JSON" ]]; then
  if python3 -c "import json; d=json.load(open('$MCP_JSON')); print(len(d.get('mcpServers',{})))" 2>/dev/null | grep -q "^[0-9]"; then
    srv_count=$(python3 -c "import json; d=json.load(open('$MCP_JSON')); print(len(d.get('mcpServers',{})))")
    quiet_pass ".mcp.json 유효 (${srv_count}개 서버)"
  else
    fail ".mcp.json JSON 파싱 실패"
  fi
else
  warn ".mcp.json 없음"
fi

ENV_FILE="$FORGE_ROOT/.env"
if [[ -f "$ENV_FILE" ]]; then
  key_count=$(grep -c "^[A-Z_]*=" "$ENV_FILE" 2>/dev/null || echo 0)
  quiet_pass ".env 존재 (${key_count}개 키)"
else
  warn ".env 없음 — MCP 인증 키 누락 가능"
fi

# ─── 6. Claude 설정 ────────────────────────────────────────
header "Claude"

SETTINGS_JSON="$FORGE_ROOT/.claude/settings.json"
if [[ -f "$SETTINGS_JSON" ]]; then
  if python3 -c "import json; json.load(open('$SETTINGS_JSON'))" 2>/dev/null; then
    quiet_pass ".claude/settings.json 유효"
  else
    fail ".claude/settings.json JSON 파싱 실패"
  fi
else
  warn ".claude/settings.json 없음"
fi

HOOKS_DIR="$FORGE_ROOT/.claude/hooks"
if [[ -d "$HOOKS_DIR" ]]; then
  exec_hooks=$(find "$HOOKS_DIR" -name "*.sh" -perm /111 2>/dev/null | wc -l)
  total_hooks=$(find "$HOOKS_DIR" -name "*.sh" 2>/dev/null | wc -l)
  if [[ "$exec_hooks" -eq "$total_hooks" && "$total_hooks" -gt 0 ]]; then
    quiet_pass "훅 스크립트 실행 가능 (${total_hooks}개)"
  elif [[ "$total_hooks" -eq 0 ]]; then
    warn "훅 스크립트 없음"
  else
    warn "훅 스크립트 실행 권한 없음 ($((total_hooks-exec_hooks))/${total_hooks}개)"
  fi
else
  warn ".claude/hooks 디렉토리 없음"
fi

# ─── 요약 ───────────────────────────────────────────────────
echo ""
echo -e "${BOLD}=== 결과: ${GREEN}${PASS} PASS${NC} / ${YELLOW}${WARN} WARN${NC} / ${RED}${FAIL} FAIL${NC} ===${NC}"

if [[ "$FAIL" -gt 0 ]]; then
  echo -e "STATUS: ${RED}FAIL${NC} — 즉시 조치 필요"
  exit 1
elif [[ "$WARN" -gt 0 ]]; then
  echo -e "STATUS: ${YELLOW}WARN${NC} — /forge-status 또는 /forge-sync 로 세부 확인"
  exit 0
else
  echo -e "STATUS: ${GREEN}ALL PASS${NC}"
  exit 0
fi
