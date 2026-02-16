#!/usr/bin/env bash
# manage-skills.sh — Skill library manager for business workspace
# Usage: bash scripts/manage-skills.sh <command> [args]

set -euo pipefail

BUSINESS_ROOT="$HOME/business"
SKILLS_LIBRARY="$BUSINESS_ROOT/06-dev-tools/skills-library"
ACTIVE_SKILLS="$BUSINESS_ROOT/.claude/skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

usage() {
    cat <<'EOF'
Skill Library Manager

Usage:
  manage-skills.sh list                              List all skills + active status
  manage-skills.sh enable <source/category/skill>    Activate a skill (symlink)
  manage-skills.sh disable <skill-name>              Deactivate a skill (remove symlink)
  manage-skills.sh install-aitmpl <skill-slug>       Download skill from aitmpl.com
  manage-skills.sh sync <target-project-path>        Sync dev skills to a project
  manage-skills.sh info <skill-name>                 Show skill details

Examples:
  manage-skills.sh enable aitmpl/business-marketing/product-strategist
  manage-skills.sh disable product-strategist
  manage-skills.sh install-aitmpl product-strategist
  manage-skills.sh sync ~/mywsl_workspace/portfolio-project
EOF
}

# ─── LIST ──────────────────────────────────────────────────────────────────
cmd_list() {
    echo -e "${CYAN}=== Skill Library ===${NC}"
    echo ""

    # Collect active skill targets for comparison
    declare -A active_targets
    if [ -d "$ACTIVE_SKILLS" ]; then
        for link in "$ACTIVE_SKILLS"/*/; do
            [ -L "${link%/}" ] || continue
            local name
            name=$(basename "${link%/}")
            local target
            target=$(readlink -f "${link%/}" 2>/dev/null || echo "broken")
            active_targets["$name"]="$target"
        done
    fi

    # Walk skills-library
    local total=0
    local active=0

    for source_dir in "$SKILLS_LIBRARY"/*/; do
        [ -d "$source_dir" ] || continue
        local source
        source=$(basename "$source_dir")
        echo -e "${BLUE}[$source]${NC}"

        # Two-level: source/category/skill or source/skill
        for item in "$source_dir"*/; do
            [ -d "$item" ] || continue
            local item_name
            item_name=$(basename "$item")

            # Check if this is a category (has subdirectories with SKILL.md)
            local has_sub=false
            for sub in "$item"*/; do
                [ -d "$sub" ] && [ -f "$sub/SKILL.md" ] && has_sub=true && break
            done

            if [ "$has_sub" = true ]; then
                echo -e "  ${YELLOW}$item_name/${NC}"
                for sub in "$item"*/; do
                    [ -d "$sub" ] || continue
                    local skill_name
                    skill_name=$(basename "$sub")
                    total=$((total + 1))

                    if [ -L "$ACTIVE_SKILLS/$skill_name" ]; then
                        echo -e "    ${GREEN}* $skill_name${NC} (active)"
                        active=$((active + 1))
                    else
                        echo -e "      $skill_name"
                    fi
                done
            elif [ -f "$item/SKILL.md" ]; then
                # Direct skill (no category nesting)
                total=$((total + 1))
                if [ -L "$ACTIVE_SKILLS/$item_name" ]; then
                    echo -e "  ${GREEN}* $item_name${NC} (active)"
                    active=$((active + 1))
                else
                    echo -e "    $item_name"
                fi
            fi
        done
        echo ""
    done

    echo -e "${CYAN}Total: $total skills, $active active${NC}"
}

# ─── ENABLE ────────────────────────────────────────────────────────────────
cmd_enable() {
    local skill_path="$1"
    local full_path="$SKILLS_LIBRARY/$skill_path"

    if [ ! -d "$full_path" ]; then
        echo -e "${RED}Error: Skill not found at $full_path${NC}"
        echo "Run 'manage-skills.sh list' to see available skills."
        exit 1
    fi

    if [ ! -f "$full_path/SKILL.md" ]; then
        echo -e "${RED}Error: No SKILL.md found in $full_path${NC}"
        echo "This may be a category directory, not a skill."
        exit 1
    fi

    local skill_name
    skill_name=$(basename "$full_path")
    local target="$ACTIVE_SKILLS/$skill_name"

    if [ -L "$target" ]; then
        echo -e "${YELLOW}Already active: $skill_name${NC}"
        return 0
    fi

    mkdir -p "$ACTIVE_SKILLS"
    ln -s "$full_path" "$target"
    echo -e "${GREEN}Enabled: $skill_name${NC} -> $full_path"
}

# ─── DISABLE ───────────────────────────────────────────────────────────────
cmd_disable() {
    local skill_name="$1"
    local target="$ACTIVE_SKILLS/$skill_name"

    if [ ! -L "$target" ]; then
        echo -e "${RED}Error: '$skill_name' is not an active skill (no symlink found)${NC}"
        exit 1
    fi

    rm "$target"
    echo -e "${GREEN}Disabled: $skill_name${NC}"
}

# ─── INSTALL-AITMPL ───────────────────────────────────────────────────────
cmd_install_aitmpl() {
    local skill_slug="$1"
    local url="https://aitmpl.com/api/skills/${skill_slug}/download"

    echo -e "${CYAN}Downloading from aitmpl.com: $skill_slug${NC}"

    # Try to detect category from slug name
    local category="uncategorized"
    case "$skill_slug" in
        *nest*|*next*|*react*|*postgres*|*typescript*|*docker*|*git*)
            category="development" ;;
        *market*|*product*|*pricing*|*growth*|*brand*)
            category="business-marketing" ;;
        *security*|*pentest*|*vuln*)
            category="security" ;;
        *ai*|*ml*|*llm*|*prompt*)
            category="ai-research" ;;
    esac

    local dest="$SKILLS_LIBRARY/aitmpl/$category/$skill_slug"
    mkdir -p "$dest"

    # Download SKILL.md from aitmpl
    local http_code
    http_code=$(curl -s -o "$dest/SKILL.md" -w "%{http_code}" "$url" 2>/dev/null || echo "000")

    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}Downloaded: $dest/SKILL.md${NC}"
        echo -e "Activate with: ${YELLOW}manage-skills.sh enable aitmpl/$category/$skill_slug${NC}"
    else
        # Fallback: try the HTML page and extract skill content
        echo -e "${YELLOW}Direct API download failed (HTTP $http_code).${NC}"
        echo -e "Trying alternative download method..."

        local page_url="https://aitmpl.com/skills/${skill_slug}"
        http_code=$(curl -sL -o /tmp/aitmpl-skill.html -w "%{http_code}" "$page_url" 2>/dev/null || echo "000")

        if [ "$http_code" = "200" ]; then
            echo -e "${YELLOW}Page downloaded. Manual extraction may be needed.${NC}"
            echo -e "Page saved to: /tmp/aitmpl-skill.html"
            echo -e "Create SKILL.md manually at: $dest/SKILL.md"
        else
            rmdir "$dest" 2>/dev/null || true
            echo -e "${RED}Failed to download skill '$skill_slug' (HTTP $http_code).${NC}"
            echo -e "Check the skill slug at https://aitmpl.com and try again."
            exit 1
        fi
    fi
}

# ─── SYNC ──────────────────────────────────────────────────────────────────
cmd_sync() {
    local target_project="$1"
    local target_skills="$target_project/.claude/skills"

    if [ ! -d "$target_project" ]; then
        echo -e "${RED}Error: Project directory not found: $target_project${NC}"
        exit 1
    fi

    mkdir -p "$target_skills"

    echo -e "${CYAN}Syncing dev skills to: $target_project${NC}"
    echo ""

    local synced=0
    local dev_path="$SKILLS_LIBRARY/aitmpl/development"

    if [ ! -d "$dev_path" ]; then
        echo -e "${YELLOW}No development skills found in library.${NC}"
        return 0
    fi

    for skill_dir in "$dev_path"/*/; do
        [ -d "$skill_dir" ] || continue
        [ -f "$skill_dir/SKILL.md" ] || continue

        local skill_name
        skill_name=$(basename "$skill_dir")
        local link="$target_skills/$skill_name"

        if [ -L "$link" ]; then
            echo -e "  ${YELLOW}skip${NC} $skill_name (already linked)"
        elif [ -d "$link" ]; then
            echo -e "  ${YELLOW}skip${NC} $skill_name (directory exists, not a symlink)"
        else
            ln -s "$skill_dir" "$link"
            echo -e "  ${GREEN}link${NC} $skill_name -> $skill_dir"
            synced=$((synced + 1))
        fi
    done

    echo ""
    echo -e "${CYAN}Synced $synced new skills to $target_project${NC}"
}

# ─── INFO ──────────────────────────────────────────────────────────────────
cmd_info() {
    local skill_name="$1"

    # Search in library
    local found=""
    while IFS= read -r -d '' skill_md; do
        local dir
        dir=$(dirname "$skill_md")
        local name
        name=$(basename "$dir")
        if [ "$name" = "$skill_name" ]; then
            found="$dir"
            break
        fi
    done < <(find "$SKILLS_LIBRARY" -name "SKILL.md" -print0 2>/dev/null)

    if [ -z "$found" ]; then
        echo -e "${RED}Skill '$skill_name' not found in library.${NC}"
        exit 1
    fi

    echo -e "${CYAN}=== $skill_name ===${NC}"
    echo -e "Path: $found"

    if [ -L "$ACTIVE_SKILLS/$skill_name" ]; then
        echo -e "Status: ${GREEN}active${NC}"
    else
        echo -e "Status: inactive"
    fi

    echo ""
    echo -e "${YELLOW}--- SKILL.md ---${NC}"
    head -30 "$found/SKILL.md"

    local lines
    lines=$(wc -l < "$found/SKILL.md")
    if [ "$lines" -gt 30 ]; then
        echo -e "\n${YELLOW}... ($((lines - 30)) more lines)${NC}"
    fi
}

# ─── MAIN ──────────────────────────────────────────────────────────────────
main() {
    if [ $# -eq 0 ]; then
        usage
        exit 0
    fi

    local cmd="$1"
    shift

    case "$cmd" in
        list)
            cmd_list
            ;;
        enable)
            [ $# -ge 1 ] || { echo -e "${RED}Usage: manage-skills.sh enable <source/category/skill>${NC}"; exit 1; }
            cmd_enable "$1"
            ;;
        disable)
            [ $# -ge 1 ] || { echo -e "${RED}Usage: manage-skills.sh disable <skill-name>${NC}"; exit 1; }
            cmd_disable "$1"
            ;;
        install-aitmpl)
            [ $# -ge 1 ] || { echo -e "${RED}Usage: manage-skills.sh install-aitmpl <skill-slug>${NC}"; exit 1; }
            cmd_install_aitmpl "$1"
            ;;
        sync)
            [ $# -ge 1 ] || { echo -e "${RED}Usage: manage-skills.sh sync <target-project-path>${NC}"; exit 1; }
            cmd_sync "$1"
            ;;
        info)
            [ $# -ge 1 ] || { echo -e "${RED}Usage: manage-skills.sh info <skill-name>${NC}"; exit 1; }
            cmd_info "$1"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            echo -e "${RED}Unknown command: $cmd${NC}"
            usage
            exit 1
            ;;
    esac
}

main "$@"
