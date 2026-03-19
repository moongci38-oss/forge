#!/bin/bash
# forge-paths.sh — 경로 해석 공통 헬퍼
# source 해서 사용: source "$(dirname "$0")/forge-paths.sh" 또는 source shared/scripts/forge-paths.sh

FORGE_ROOT="${FORGE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
FORGE_WORKSPACE="${FORGE_ROOT}/forge-workspace.json"

# forge-workspace.json에서 outputsRoot 읽기 (jq 없이 grep+sed)
if [ -f "$FORGE_WORKSPACE" ]; then
  OUTPUTS_ROOT=$(grep '"outputsRoot"' "$FORGE_WORKSPACE" | sed 's/.*: *"\(.*\)".*/\1/')
fi
# 상대경로면 FORGE_ROOT 기준으로 resolve
if [[ "$OUTPUTS_ROOT" == ../* ]] || [[ "$OUTPUTS_ROOT" == ./* ]]; then
  OUTPUTS_ROOT="$(cd "${FORGE_ROOT}/${OUTPUTS_ROOT}" 2>/dev/null && pwd)"
fi
OUTPUTS_ROOT="${OUTPUTS_ROOT:-$(cd "${FORGE_ROOT}/../forge-outputs" 2>/dev/null && pwd)}"

# folderMap 경로 해석: outputs/ 접두사 → OUTPUTS_ROOT 기준, 그 외 → FORGE_ROOT 기준
resolve_path() {
  local path="$1"
  local resolved
  if [[ "$path" == outputs/* ]]; then
    resolved="${OUTPUTS_ROOT}/${path#outputs/}"
  else
    resolved="${FORGE_ROOT}/${path}"
  fi
  echo "$resolved"
}

# folderMap에서 키로 경로 조회 + 자동 생성
get_folder() {
  local key="$1"
  local create="${2:-true}"  # 기본값: 자동 생성
  local raw=$(grep "\"${key}\"" "$FORGE_WORKSPACE" | head -1 | sed 's/.*: *"\(.*\)".*/\1/')
  local resolved=$(resolve_path "$raw")
  if [[ "$create" == "true" ]] && [ -n "$resolved" ] && [ ! -d "$resolved" ]; then
    mkdir -p "$resolved"
  fi
  echo "$resolved"
}

# forge-outputs 기본 폴더 구조 보장
ensure_outputs_structure() {
  local dirs=(
    "01-research/projects"
    "02-product/projects"
    "03-marketing/projects"
    "04-content/projects"
    "05-design/projects"
    "10-operations/handoff-to-dev"
    "10-operations/handoff-from-dev"
    "docs/planning/active/plans"
    "docs/planning/done"
    "docs/reviews"
    "docs/tech"
    "docs/guides"
    "docs/assets"
  )
  for d in "${dirs[@]}"; do
    mkdir -p "${OUTPUTS_ROOT}/${d}"
  done
}
