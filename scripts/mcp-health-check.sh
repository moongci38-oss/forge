#!/bin/bash
# mcp-health-check.sh — MCP 서버 Health-Check
# Usage: bash scripts/mcp-health-check.sh

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=== MCP Server Health Check ==="
echo ""

TOTAL=0
REACHABLE=0

check_command_server() {
  local name="$1"
  local package="$2"
  shift 2
  local dirs=("$@")

  TOTAL=$((TOTAL + 1))

  local pkg_ok=false
  if npm view "$package" version > /dev/null 2>&1; then
    pkg_ok=true
  fi

  local dirs_ok=true
  local missing_dirs=""
  for dir in "${dirs[@]}"; do
    if [[ -n "$dir" && ! -d "$dir" ]]; then
      dirs_ok=false
      missing_dirs="$missing_dirs $dir"
    fi
  done

  if $pkg_ok && $dirs_ok; then
    local dir_msg=""
    [[ ${#dirs[@]} -gt 0 && -n "${dirs[0]}" ]] && dir_msg=", dirs exist"
    echo -e "  ${GREEN}[PASS]${NC} $name — package ok${dir_msg}"
    REACHABLE=$((REACHABLE + 1))
  elif $pkg_ok; then
    echo -e "  ${YELLOW}[WARN]${NC} $name — package ok, missing dirs:$missing_dirs"
    REACHABLE=$((REACHABLE + 1))
  else
    echo -e "  ${RED}[FAIL]${NC} $name — package '$package' not found"
  fi
}

check_http_server() {
  local name="$1"
  local url="$2"

  TOTAL=$((TOTAL + 1))

  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null || echo "000")

  case "$http_code" in
    2*)
      echo -e "  ${GREEN}[PASS]${NC} $name — HTTP $http_code"
      REACHABLE=$((REACHABLE + 1))
      ;;
    401|403)
      echo -e "  ${YELLOW}[WARN]${NC} $name — HTTP $http_code (reachable, auth required)"
      REACHABLE=$((REACHABLE + 1))
      ;;
    000)
      echo -e "  ${RED}[FAIL]${NC} $name — connection timeout"
      ;;
    *)
      echo -e "  ${RED}[FAIL]${NC} $name — HTTP $http_code"
      ;;
  esac
}

parse_mcp_json() {
  local json_file="$1"
  python3 -c "
import json
with open('$json_file') as f:
    data = json.load(f)
servers = data.get('mcpServers', {})
for name, conf in servers.items():
    stype = conf.get('type', 'command')
    if stype == 'http':
        print(f'http|{name}|{conf.get(\"url\", \"\")}|')
    else:
        args = conf.get('args', [])
        pkg = ''
        dirs = []
        for a in args:
            if a == '-y':
                continue
            if not pkg and (a.startswith('@') or not a.startswith('-')):
                pkg = a
            elif pkg and not a.startswith('-'):
                dirs.append(a)
        print(f'command|{name}|{pkg}|{\";\".join(dirs)}')
" 2>/dev/null
}

process_servers() {
  local json_file="$1"
  while IFS='|' read -r stype name pkg_or_url dirs; do
    if [[ "$stype" == "http" ]]; then
      check_http_server "$name" "$pkg_or_url"
    elif [[ "$stype" == "command" ]]; then
      IFS=';' read -ra dir_arr <<< "$dirs"
      check_command_server "$name" "$pkg_or_url" "${dir_arr[@]}"
    fi
  done < <(parse_mcp_json "$json_file")
}

# Project scope (.mcp.json)
MCP_JSON=".mcp.json"
if [[ -f "$MCP_JSON" ]]; then
  echo "[Project scope: $MCP_JSON]"
  process_servers "$MCP_JSON"
  echo ""
fi

# User scope (~/.claude.json)
USER_MCP="$HOME/.claude.json"
if [[ -f "$USER_MCP" ]]; then
  has_servers=$(python3 -c "
import json
with open('$USER_MCP') as f:
    data = json.load(f)
print(len(data.get('mcpServers', {})))
" 2>/dev/null || echo "0")

  if [[ "$has_servers" != "0" ]]; then
    echo "[User scope: ~/.claude.json]"
    process_servers "$USER_MCP"
    echo ""
  fi
fi

echo "Result: $REACHABLE/$TOTAL reachable"
