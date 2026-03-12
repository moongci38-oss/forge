#!/usr/bin/env bash
# deploy-symlinks.sh — SIGIL→Trine symlink 일괄 생성/상태 확인
# Usage: bash scripts/deploy-symlinks.sh list
#        bash scripts/deploy-symlinks.sh status <project>
#        bash scripts/deploy-symlinks.sh deploy <project>
#
# sigil-workspace.json의 프로젝트 설정을 읽어 개발 프로젝트에
# SIGIL 산출물 symlink를 일괄 생성한다.

set -uo pipefail

BUSINESS_ROOT="${BUSINESS_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/business")}"
WORKSPACE_JSON="$BUSINESS_ROOT/sigil-workspace.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Counters
OK_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
CREATED_COUNT=0

# ─── USAGE ───────────────────────────────────────────────────────────────────

usage() {
    cat <<'EOF'
SIGIL → Trine Symlink Deployer

Usage:
  deploy-symlinks.sh list                프로젝트 목록 출력
  deploy-symlinks.sh status <project>    symlink 상태 확인
  deploy-symlinks.sh deploy <project>    symlink 일괄 생성

Options:
  --help    이 도움말 표시
EOF
}

# ─── JSON HELPERS (no jq) ────────────────────────────────────────────────────

# Extract simple JSON string value by key
# Usage: json_value "$json" "key"
json_value() {
    local json="$1" key="$2"
    echo "$json" | grep -o "\"${key}\": *\"[^\"]*\"" | head -1 | sed "s/\"${key}\": *\"//;s/\"$//"
}

# Extract project names from projects object
# Usage: json_project_names "$json"
json_project_names() {
    local json="$1"
    # Find lines between "projects": { ... } that have project-level keys (indented with 4 spaces + quote)
    echo "$json" | sed -n '/"projects"/,/^  }/p' | grep -E '^ {4}"[a-zA-Z0-9_-]+":' | grep -o '"[a-zA-Z0-9_-]*"' | sed 's/"//g'
}

# ─── SYMLINK ARTIFACT MAP ───────────────────────────────────────────────────

# Define which artifacts come from which folderMap location
# Format: symlink_name|folderMap_key|is_admin|is_copy
# is_admin: "admin" means only deploy if admin files exist
# is_copy: "copy" means cp instead of ln -s (for todo.md)
ARTIFACTS=(
    "handoff.md|handoff|no|no"
    "s3-prd.md|product|no|no"
    "s3-gdd.md|product|no|no"
    "s4-detailed-plan.md|product|no|no"
    "s4-development-plan.md|product|no|no"
    "s4-roadmap.md|product|no|no"
    "s4-sitemap.md|product|no|no"
    "s4-wbs.md|product|no|no"
    "s4-uiux-spec.md|design|no|no"
    "todo.md|product|no|copy"
    "s4-admin-detailed-plan.md|product|admin|no"
    "s4-admin-sitemap.md|product|admin|no"
    "s4-admin-uiux-spec.md|design|admin|no"
)

# ─── RESOLVE SOURCE PATH ────────────────────────────────────────────────────

# Find the source file for a given artifact
# Returns: absolute path to the most recent matching file, or empty
resolve_source() {
    local artifact_name="$1"
    local folder_map_key="$2"
    local project="$3"
    local ws_json="$4"

    # Get folderMap path
    local folder_rel
    folder_rel=$(json_value "$ws_json" "$folder_map_key")
    [[ -z "$folder_rel" ]] && return

    local source_dir="$BUSINESS_ROOT/$folder_rel"

    # Special handling for handoff (different path structure)
    if [[ "$folder_map_key" == "handoff" ]]; then
        # handoff uses portfolio/ not portfolio-admin/
        local handoff_project
        handoff_project=$(echo "$project" | sed 's/-admin$//')
        source_dir="$source_dir/$handoff_project"
    else
        source_dir="$source_dir/$project"
    fi

    [[ ! -d "$source_dir" ]] && return

    # Strip date prefix from artifact name for matching
    # e.g., "s4-detailed-plan.md" → search for "*-s4-detailed-plan.md"
    local pattern="*-${artifact_name}"

    # Find most recent matching file
    local found
    found=$(ls -t "$source_dir"/$pattern 2>/dev/null | head -1)

    # Also try exact name (for handoff which might be named differently)
    if [[ -z "$found" ]]; then
        found=$(ls -t "$source_dir"/*"${artifact_name}" 2>/dev/null | head -1)
    fi

    [[ -n "$found" ]] && echo "$found"
}

# ─── NORMALIZE PATH ─────────────────────────────────────────────────────────

# Convert Windows path to WSL path if needed
normalize_path() {
    local path="$1"
    # {WIN_DRIVE}:/... → /mnt/{drive}/...
    if [[ "$path" =~ ^[A-Z]:/ ]]; then
        local drive
        drive=$(echo "${path:0:1}" | tr '[:upper:]' '[:lower:]')
        echo "/mnt/$drive/${path:3}"
    else
        echo "$path"
    fi
}

# Check if path is cross-filesystem (Windows drive from WSL)
is_cross_fs() {
    local path="$1"
    [[ "$path" =~ ^[A-Z]:/ ]] || [[ "$path" =~ ^/mnt/ ]]
}

# ─── COMMANDS ────────────────────────────────────────────────────────────────

cmd_list() {
    if [[ ! -f "$WORKSPACE_JSON" ]]; then
        echo -e "${RED}sigil-workspace.json not found:${NC} $WORKSPACE_JSON"
        exit 1
    fi

    local ws_json
    ws_json=$(cat "$WORKSPACE_JSON")

    echo -e "${BOLD}=== SIGIL Projects ===${NC}"
    echo ""

    local projects
    projects=$(json_project_names "$ws_json")

    if [[ -z "$projects" ]]; then
        echo -e "  ${YELLOW}No projects found in sigil-workspace.json${NC}"
        return
    fi

    while IFS= read -r project; do
        [[ -z "$project" ]] && continue
        local dev_target
        # Extract devTarget for this project
        dev_target=$(sed -n "/\"$project\"/,/}/p" "$WORKSPACE_JSON" | grep -o '"devTarget": *"[^"]*"' | head -1 | sed 's/"devTarget": *"//;s/"$//')
        local symlink_base
        symlink_base=$(sed -n "/\"$project\"/,/}/p" "$WORKSPACE_JSON" | grep -o '"symlinkBase": *"[^"]*"' | head -1 | sed 's/"symlinkBase": *"//;s/"$//')
        [[ -z "$symlink_base" ]] && symlink_base=$(json_value "$ws_json" "symlinkBase")

        local cross_warn=""
        if is_cross_fs "$dev_target"; then
            cross_warn=" ${YELLOW}(cross-filesystem)${NC}"
        fi

        echo -e "  ${BOLD}$project${NC}${cross_warn}"
        echo -e "    devTarget:    ${CYAN}$dev_target${NC}"
        echo -e "    symlinkBase:  $symlink_base"
        echo ""
    done <<< "$projects"
}

cmd_status() {
    local project="$1"

    if [[ ! -f "$WORKSPACE_JSON" ]]; then
        echo -e "${RED}sigil-workspace.json not found:${NC} $WORKSPACE_JSON"
        exit 1
    fi

    local ws_json
    ws_json=$(cat "$WORKSPACE_JSON")

    # Get project config
    local dev_target
    dev_target=$(sed -n "/\"$project\"/,/}/p" "$WORKSPACE_JSON" | grep -o '"devTarget": *"[^"]*"' | head -1 | sed 's/"devTarget": *"//;s/"$//')

    if [[ -z "$dev_target" ]]; then
        echo -e "${RED}Project not found:${NC} $project"
        exit 1
    fi

    local symlink_base
    symlink_base=$(sed -n "/\"$project\"/,/}/p" "$WORKSPACE_JSON" | grep -o '"symlinkBase": *"[^"]*"' | head -1 | sed 's/"symlinkBase": *"//;s/"$//')
    [[ -z "$symlink_base" ]] && symlink_base=$(json_value "$ws_json" "symlinkBase")

    local norm_target
    norm_target=$(normalize_path "$dev_target")
    local dest_dir="$norm_target/$symlink_base"

    echo -e "${BOLD}=== Symlink Status: $project ===${NC}"
    echo -e "devTarget: ${CYAN}$dev_target${NC}"

    if is_cross_fs "$dev_target"; then
        echo -e "${YELLOW}WARNING: Cross-filesystem target detected.${NC}"
        echo -e "${YELLOW}WSL→Windows symlinks may not work. Consider using copy mode.${NC}"
        echo ""
    fi

    echo -e "dest: ${CYAN}$dest_dir${NC}"
    echo ""

    OK_COUNT=0
    WARN_COUNT=0
    FAIL_COUNT=0
    SKIP_COUNT=0

    for artifact_def in "${ARTIFACTS[@]}"; do
        IFS='|' read -r name folder_key is_admin is_copy <<< "$artifact_def"

        # Find source
        local source
        source=$(resolve_source "$name" "$folder_key" "$project" "$ws_json")

        if [[ -z "$source" ]]; then
            if [[ "$is_admin" == "admin" ]]; then
                ((SKIP_COUNT++))
                continue  # admin artifacts are optional
            fi
            # s3-prd vs s3-gdd — only one should exist
            if [[ "$name" == "s3-prd.md" ]] || [[ "$name" == "s3-gdd.md" ]]; then
                ((SKIP_COUNT++))
                continue
            fi
            echo -e "  ${RED}MISSING${NC}  $name — source not found"
            ((FAIL_COUNT++))
            continue
        fi

        local dest="$dest_dir/$name"

        if [[ ! -e "$dest" && ! -L "$dest" ]]; then
            echo -e "  ${YELLOW}NOT DEPLOYED${NC}  $name"
            ((WARN_COUNT++))
        elif [[ "$is_copy" == "copy" ]]; then
            if [[ -f "$dest" && ! -L "$dest" ]]; then
                echo -e "  ${GREEN}OK${NC}  $name (copy)"
                ((OK_COUNT++))
            elif [[ -L "$dest" ]]; then
                echo -e "  ${YELLOW}WARN${NC}  $name — should be copy, not symlink"
                ((WARN_COUNT++))
            fi
        elif [[ -L "$dest" ]]; then
            local link_target
            link_target=$(readlink "$dest")
            if [[ -e "$dest" ]]; then
                echo -e "  ${GREEN}OK${NC}  $name → $(basename "$link_target")"
                ((OK_COUNT++))
            else
                echo -e "  ${RED}BROKEN${NC}  $name → $link_target"
                ((FAIL_COUNT++))
            fi
        else
            echo -e "  ${YELLOW}WARN${NC}  $name — exists but not a symlink"
            ((WARN_COUNT++))
        fi
    done

    echo ""
    echo -e "Results: ${GREEN}OK=$OK_COUNT${NC}  ${YELLOW}WARN=$WARN_COUNT${NC}  ${RED}FAIL=$FAIL_COUNT${NC}  SKIP=$SKIP_COUNT"
}

cmd_deploy() {
    local project="$1"

    if [[ ! -f "$WORKSPACE_JSON" ]]; then
        echo -e "${RED}sigil-workspace.json not found:${NC} $WORKSPACE_JSON"
        exit 1
    fi

    local ws_json
    ws_json=$(cat "$WORKSPACE_JSON")

    # Get project config
    local dev_target
    dev_target=$(sed -n "/\"$project\"/,/}/p" "$WORKSPACE_JSON" | grep -o '"devTarget": *"[^"]*"' | head -1 | sed 's/"devTarget": *"//;s/"$//')

    if [[ -z "$dev_target" ]]; then
        echo -e "${RED}Project not found:${NC} $project"
        exit 1
    fi

    local symlink_base
    symlink_base=$(sed -n "/\"$project\"/,/}/p" "$WORKSPACE_JSON" | grep -o '"symlinkBase": *"[^"]*"' | head -1 | sed 's/"symlinkBase": *"//;s/"$//')
    [[ -z "$symlink_base" ]] && symlink_base=$(json_value "$ws_json" "symlinkBase")

    local norm_target
    norm_target=$(normalize_path "$dev_target")
    local dest_dir="$norm_target/$symlink_base"

    echo -e "${BOLD}=== Deploy Symlinks: $project ===${NC}"
    echo -e "devTarget: ${CYAN}$dev_target${NC}"

    local use_copy=false
    if is_cross_fs "$dev_target"; then
        echo -e "${YELLOW}WARNING: Cross-filesystem target.${NC}"
        echo -e "${YELLOW}Using copy mode instead of symlinks.${NC}"
        use_copy=true
    fi

    echo -e "dest: ${CYAN}$dest_dir${NC}"
    echo ""

    # Ensure dest directory exists
    if [[ ! -d "$dest_dir" ]]; then
        echo -e "  Creating directory: $dest_dir"
        mkdir -p "$dest_dir"
    fi

    CREATED_COUNT=0
    SKIP_COUNT=0
    FAIL_COUNT=0

    for artifact_def in "${ARTIFACTS[@]}"; do
        IFS='|' read -r name folder_key is_admin is_copy_flag <<< "$artifact_def"

        # Find source
        local source
        source=$(resolve_source "$name" "$folder_key" "$project" "$ws_json")

        if [[ -z "$source" ]]; then
            if [[ "$is_admin" == "admin" ]] || [[ "$name" == "s3-prd.md" ]] || [[ "$name" == "s3-gdd.md" ]]; then
                continue  # optional, skip silently
            fi
            echo -e "  ${YELLOW}SKIP${NC}  $name — source not found"
            ((SKIP_COUNT++))
            continue
        fi

        local dest="$dest_dir/$name"

        # Check if already exists
        if [[ -e "$dest" || -L "$dest" ]]; then
            echo -e "  ${BLUE}EXISTS${NC}  $name (skipped)"
            ((SKIP_COUNT++))
            continue
        fi

        # Deploy
        if [[ "$is_copy_flag" == "copy" ]] || $use_copy; then
            if cp "$source" "$dest" 2>/dev/null; then
                echo -e "  ${GREEN}COPIED${NC}  $name"
                ((CREATED_COUNT++))
            else
                echo -e "  ${RED}FAIL${NC}  $name — copy failed"
                ((FAIL_COUNT++))
            fi
        else
            if ln -s "$source" "$dest" 2>/dev/null; then
                echo -e "  ${GREEN}LINKED${NC}  $name → $(basename "$source")"
                ((CREATED_COUNT++))
            else
                echo -e "  ${RED}FAIL${NC}  $name — symlink failed"
                ((FAIL_COUNT++))
            fi
        fi
    done

    echo ""
    echo -e "Results: ${GREEN}Created=$CREATED_COUNT${NC}  ${BLUE}Skipped=$SKIP_COUNT${NC}  ${RED}Failed=$FAIL_COUNT${NC}"
}

# ─── MAIN ────────────────────────────────────────────────────────────────────

case "${1:-}" in
    list)
        cmd_list
        ;;
    status)
        [[ -z "${2:-}" ]] && { echo -e "${RED}Usage:${NC} deploy-symlinks.sh status <project>"; exit 1; }
        cmd_status "$2"
        ;;
    deploy)
        [[ -z "${2:-}" ]] && { echo -e "${RED}Usage:${NC} deploy-symlinks.sh deploy <project>"; exit 1; }
        cmd_deploy "$2"
        ;;
    --help|-h|"")
        usage
        ;;
    *)
        echo -e "${RED}Unknown command:${NC} $1"
        usage
        exit 1
        ;;
esac
