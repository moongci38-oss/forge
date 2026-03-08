#!/usr/bin/env bash
# SIGIL ADR Cross-Project Index — ADR 교차 참조 인덱스
# Usage: bash scripts/sigil-adr-index.sh {build|search <keyword>}
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$SCRIPT_DIR/.."

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

source "$SCRIPT_DIR/json-get.sh"

WS_JSON="$WORKSPACE/sigil-workspace.json"

if [ ! -f "$WS_JSON" ]; then
  echo -e "${RED}Error: sigil-workspace.json not found${NC}"
  exit 1
fi

PRODUCT_DIR="$(json_get "$WS_JSON" "folderMap.product")"
INDEX_FILE="$WORKSPACE/docs/tech/adr-index.md"

cmd_build() {
  echo -e "${CYAN}=== Building ADR Cross-Project Index ===${NC}"
  mkdir -p "$WORKSPACE/docs/tech"

  local counter=0

  {
    echo "# ADR Cross-Project Index"
    echo ""
    echo "> 생성일: $(date +%Y-%m-%d)"
    echo "> 소스: S4 development-plan.md 내 ADR 섹션"
    echo ""
    echo "| # | Project | ADR | Decision | Status |"
    echo "|:-:|---------|-----|----------|:------:|"

    for proj_dir in "$WORKSPACE/$PRODUCT_DIR"/*/; do
      [ ! -d "$proj_dir" ] && continue
      proj_name="$(basename "$proj_dir")"

      dev_plan=$(find "$proj_dir" -maxdepth 1 -name "*development-plan*.md" -type f 2>/dev/null | head -1 || echo "")
      [ -z "$dev_plan" ] && continue

      while IFS= read -r line; do
        adr_id=$(echo "$line" | grep -oE "ADR-[0-9]+" || echo "")
        adr_title=$(echo "$line" | sed 's/^###* *ADR-[0-9]*[.:] *//' | sed 's/ *$//')
        [ -z "$adr_id" ] && continue

        counter=$((counter + 1))

        decision=$(sed -n "/^###.*$adr_id/,/^###/p" "$dev_plan" \
          | grep -E "(결정|Decision|선택)" | head -1 \
          | sed 's/^.*[::] *//' | cut -c1-60 || echo "-")
        [ -z "$decision" ] && decision="-"

        echo "| $counter | $proj_name | $adr_id | $adr_title | Accepted |"
      done < <(grep -E "^###.*ADR-[0-9]+" "$dev_plan" 2>/dev/null || true)
    done

  } > "$INDEX_FILE"

  echo -e "${GREEN}  Index saved: $INDEX_FILE${NC}"
  echo "  Total ADRs: $counter"
}

cmd_search() {
  local keyword="${1:-}"
  if [ -z "$keyword" ]; then
    echo -e "${RED}Usage: sigil adr <keyword>${NC}"
    exit 1
  fi

  if [ ! -f "$INDEX_FILE" ]; then
    echo "Index not found. Building..."
    cmd_build
  fi

  echo -e "${CYAN}=== ADR Search: $keyword ===${NC}"
  grep -i "$keyword" "$INDEX_FILE" | grep "^|" || echo "  No results"
}

case "${1:-help}" in
  build)  cmd_build ;;
  search) shift; cmd_search "$@" ;;
  *)      echo "Usage: sigil-adr-index.sh {build|search <keyword>}" ;;
esac
