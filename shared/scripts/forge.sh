#!/usr/bin/env bash
# Forge 통합 CLI — 기존 스크립트를 서브커맨드로 래핑
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

source "$SCRIPT_DIR/json-get.sh"
source "$SCRIPT_DIR/forge-paths.sh"

usage() {
  echo -e "${BOLD}Forge CLI — Strategy & Idea Generation Intelligent Loop${NC}"
  echo ""
  echo "Usage: forge <command> [options]"
  echo ""
  echo "Commands:"
  echo "  init                    Validate forge-workspace.json"
  echo "  gate <project> <stage>  Run DoD gate check (S1-S4)"
  echo "  trace <project>         Run S3→S4 traceability check"
  echo "  deploy <project>        Deploy symlinks to dev project"
  echo "  status [project]        Show all projects gate status"
  echo "  metrics [project]       Generate metrics report"
  echo "  research <keyword>      Search research index"
  echo "  adr [keyword]           Search ADR index"
  echo "  verify                  Run all Forge verifications"
}

cmd_status() {
  local target_project="${1:-}"
  if [ ! -f "$FORGE_WORKSPACE" ]; then
    echo -e "${RED}Error: forge-workspace.json not found${NC}"
    exit 1
  fi

  echo -e "${BOLD}=== Forge Project Status ===${NC}"
  echo ""

  local product_dir
  product_dir="$(get_folder "product")"

  for proj_dir in "$product_dir"/*/; do
    [ ! -d "$proj_dir" ] && continue
    local proj_name
    proj_name="$(basename "$proj_dir")"

    if [ -n "$target_project" ] && [ "$proj_name" != "$target_project" ]; then
      continue
    fi

    local gate_log="$proj_dir/gate-log.md"
    echo -e "  ${CYAN}$proj_name${NC}"

    if [ ! -f "$gate_log" ]; then
      echo -e "    ${YELLOW}gate-log.md 없음${NC}"
      echo ""
      continue
    fi

    for stage in S1 S2 S3 S4; do
      local result
      result=$(grep -E "^\| *$stage *\|" "$gate_log" 2>/dev/null | head -1 || true)
      if [ -z "$result" ]; then
        printf "    %-4s 미실행\n" "$stage"
      elif echo "$result" | grep -q "PASS"; then
        local date_str
        date_str=$(echo "$result" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" | head -1 || echo "")
        printf "    %-4s ${GREEN}PASS${NC}  %s\n" "$stage" "$date_str"
      elif echo "$result" | grep -q "SKIP"; then
        printf "    %-4s ${YELLOW}SKIP${NC}\n" "$stage"
      else
        printf "    %-4s ${RED}FAIL${NC}\n" "$stage"
      fi
    done
    echo ""
  done
}

main() {
  local cmd="${1:-help}"
  shift || true

  case "$cmd" in
    init)     bash "$SCRIPT_DIR/forge-validate-workspace.sh" "$@" ;;
    gate)     bash "$SCRIPT_DIR/forge-gate-check.sh" "$@" ;;
    trace)    bash "$SCRIPT_DIR/forge-wave2-trace.sh" "$@" ;;
    deploy)   bash "$SCRIPT_DIR/deploy-symlinks.sh" deploy "$@" ;;
    status)   cmd_status "$@" ;;
    metrics)  bash "$SCRIPT_DIR/forge-metrics.sh" "$@" ;;
    research) bash "$SCRIPT_DIR/forge-research-index.sh" search "$@" ;;
    adr)      bash "$SCRIPT_DIR/forge-adr-index.sh" search "$@" ;;
    verify)   bash "$SCRIPT_DIR/verify-all.sh" all --forge-only "$@" ;;
    --help|-h|help) usage ;;
    *)
      echo -e "${RED}Unknown command: $cmd${NC}"
      usage
      exit 1
      ;;
  esac
}

main "$@"
