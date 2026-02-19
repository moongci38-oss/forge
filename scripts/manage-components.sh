#!/usr/bin/env bash
# manage-components.sh — Component library manager for business workspace
# Manages agents, commands, hooks, MCPs, settings (skills handled by manage-skills.sh)
# Usage: bash scripts/manage-components.sh <command> [args]

set -euo pipefail

BUSINESS_ROOT="${BUSINESS_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/business")}"
COMPONENTS_LIBRARY="$BUSINESS_ROOT/09-tools/components-library"
SKILLS_LIBRARY="$BUSINESS_ROOT/09-tools/skills-library"
CLAUDE_DIR="$BUSINESS_ROOT/.claude"

# Component type → library subdir mapping
declare -A LIBRARY_DIRS=(
    [agents]="$COMPONENTS_LIBRARY/agents"
    [commands]="$COMPONENTS_LIBRARY/commands"
    [hooks]="$COMPONENTS_LIBRARY/hooks"
    [mcps]="$COMPONENTS_LIBRARY/mcps"
    [settings]="$COMPONENTS_LIBRARY/settings"
)

# Component type → active location mapping
declare -A ACTIVE_DIRS=(
    [agents]="$CLAUDE_DIR/agents"
    [commands]="$CLAUDE_DIR/commands"
    [hooks]="$CLAUDE_DIR/hooks"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

usage() {
    cat <<'EOF'
Component Library Manager

Usage:
  manage-components.sh list [type]                          List components (all or by type)
  manage-components.sh enable <type> <name>                 Activate a component
  manage-components.sh disable <type> <name>                Deactivate a component
  manage-components.sh install <type> <slug>[,slug,...]     Download from aitmpl.com
  manage-components.sh info <type> <name>                   Show component details
  manage-components.sh sync <target-project-path>           Sync components to a project

Component Types:
  agents      Agent definitions (.md files)
  commands    Slash commands (.md files)
  hooks       Automation hooks (.sh files + settings.json)
  mcps        MCP server configs (JSON snippets)
  settings    Settings presets (JSON snippets)
  skills      (use manage-skills.sh for skill management)

Examples:
  manage-components.sh list
  manage-components.sh list agents
  manage-components.sh enable agents seo-analyzer
  manage-components.sh disable agents seo-analyzer
  manage-components.sh install agents web-tools/seo-analyzer
  manage-components.sh info agents academic-researcher
  manage-components.sh sync ~/mywsl_workspace/portfolio-project
EOF
}

# ─── LIST ──────────────────────────────────────────────────────────────────

cmd_list() {
    local filter_type="${1:-all}"

    echo -e "${CYAN}=== Component Library ===${NC}"
    echo ""

    local grand_total=0
    local grand_active=0

    for comp_type in agents commands hooks mcps settings; do
        if [ "$filter_type" != "all" ] && [ "$filter_type" != "$comp_type" ]; then
            continue
        fi

        local lib_dir="${LIBRARY_DIRS[$comp_type]}"
        local active_dir="${ACTIVE_DIRS[$comp_type]:-}"
        local total=0
        local active=0

        echo -e "${BLUE}[$comp_type]${NC}"

        if [ ! -d "$lib_dir" ] || [ -z "$(ls -A "$lib_dir" 2>/dev/null)" ]; then
            echo -e "  ${YELLOW}(empty)${NC}"
            echo ""
            continue
        fi

        # List files in library
        for item in "$lib_dir"/*; do
            [ -e "$item" ] || continue
            local name
            name=$(basename "$item")
            local base_name="${name%.*}"  # strip extension
            total=$((total + 1))

            # Check if active
            local is_active=false
            if [ -n "$active_dir" ] && [ -d "$active_dir" ]; then
                # Check for exact file match (with or without extension)
                if [ -f "$active_dir/$name" ] || [ -f "$active_dir/$base_name" ]; then
                    is_active=true
                fi
            fi

            if [ "$is_active" = true ]; then
                echo -e "  ${GREEN}* $name${NC} (active)"
                active=$((active + 1))
            else
                echo -e "    $name"
            fi
        done

        echo -e "  ${CYAN}Subtotal: $total items, $active active${NC}"
        echo ""

        grand_total=$((grand_total + total))
        grand_active=$((grand_active + active))
    done

    # Also show skills summary
    if [ "$filter_type" = "all" ] || [ "$filter_type" = "skills" ]; then
        echo -e "${BLUE}[skills]${NC}"
        local skill_count=0
        local skill_active=0
        if [ -d "$SKILLS_LIBRARY" ]; then
            skill_count=$(find "$SKILLS_LIBRARY" -name "SKILL.md" 2>/dev/null | wc -l)
        fi
        if [ -d "$CLAUDE_DIR/skills" ]; then
            skill_active=$(find "$CLAUDE_DIR/skills" -maxdepth 1 -type l 2>/dev/null | wc -l)
        fi
        echo -e "  ${CYAN}$skill_count skills, $skill_active active (use manage-skills.sh)${NC}"
        echo ""
        grand_total=$((grand_total + skill_count))
        grand_active=$((grand_active + skill_active))
    fi

    echo -e "${MAGENTA}Grand Total: $grand_total components, $grand_active active${NC}"
}

# ─── ENABLE ────────────────────────────────────────────────────────────────

cmd_enable() {
    local comp_type="$1"
    local name="$2"

    validate_type "$comp_type"

    if [ "$comp_type" = "mcps" ] || [ "$comp_type" = "settings" ]; then
        echo -e "${YELLOW}$comp_type require manual merge into config files.${NC}"
        echo -e "Library file: ${LIBRARY_DIRS[$comp_type]}/$name"
        echo ""
        echo -e "For MCPs: merge into ${BUSINESS_ROOT}/.mcp.json"
        echo -e "For Settings: merge into ${CLAUDE_DIR}/settings.json"
        return 0
    fi

    local lib_dir="${LIBRARY_DIRS[$comp_type]}"
    local active_dir="${ACTIVE_DIRS[$comp_type]}"

    # Find the file (with or without .md extension)
    local source_file=""
    if [ -f "$lib_dir/$name" ]; then
        source_file="$lib_dir/$name"
    elif [ -f "$lib_dir/$name.md" ]; then
        source_file="$lib_dir/$name.md"
    elif [ -f "$lib_dir/$name.sh" ]; then
        source_file="$lib_dir/$name.sh"
    else
        echo -e "${RED}Error: '$name' not found in $lib_dir${NC}"
        echo "Run 'manage-components.sh list $comp_type' to see available items."
        exit 1
    fi

    local filename
    filename=$(basename "$source_file")
    local target="$active_dir/$filename"

    if [ -f "$target" ]; then
        echo -e "${YELLOW}Already active: $filename${NC}"
        return 0
    fi

    mkdir -p "$active_dir"
    cp "$source_file" "$target"
    echo -e "${GREEN}Enabled: $filename${NC} -> $active_dir/"
}

# ─── DISABLE ───────────────────────────────────────────────────────────────

cmd_disable() {
    local comp_type="$1"
    local name="$2"

    validate_type "$comp_type"

    if [ "$comp_type" = "mcps" ] || [ "$comp_type" = "settings" ]; then
        echo -e "${YELLOW}$comp_type must be manually removed from config files.${NC}"
        return 0
    fi

    local active_dir="${ACTIVE_DIRS[$comp_type]}"

    # Find the file (with or without extension)
    local target=""
    if [ -f "$active_dir/$name" ]; then
        target="$active_dir/$name"
    elif [ -f "$active_dir/$name.md" ]; then
        target="$active_dir/$name.md"
    elif [ -f "$active_dir/$name.sh" ]; then
        target="$active_dir/$name.sh"
    else
        echo -e "${RED}Error: '$name' is not active in $active_dir${NC}"
        exit 1
    fi

    rm "$target"
    local filename
    filename=$(basename "$target")
    echo -e "${GREEN}Disabled: $filename${NC}"
}

# ─── INSTALL ───────────────────────────────────────────────────────────────

cmd_install() {
    local comp_type="$1"
    local slugs="$2"

    validate_type "$comp_type"

    local aitmpl_flag=""
    case "$comp_type" in
        agents)   aitmpl_flag="--agent" ;;
        commands) aitmpl_flag="--command" ;;
        hooks)    aitmpl_flag="--hook" ;;
        mcps)     aitmpl_flag="--mcp" ;;
        settings) aitmpl_flag="--setting" ;;
        skills)
            echo -e "${YELLOW}Use manage-skills.sh install-aitmpl for skills.${NC}"
            exit 1
            ;;
    esac

    local tmpdir
    tmpdir=$(mktemp -d /tmp/aitmpl-install-XXXXXX)

    echo -e "${CYAN}Downloading $comp_type from aitmpl.com: $slugs${NC}"
    echo ""

    if npx claude-code-templates@latest $aitmpl_flag "$slugs" --directory "$tmpdir" --yes 2>&1; then
        echo ""

        # Move downloaded files to library
        local lib_dir="${LIBRARY_DIRS[$comp_type]}"
        mkdir -p "$lib_dir"

        local installed=0
        local search_dir=""

        case "$comp_type" in
            agents)   search_dir="$tmpdir/.claude/agents" ;;
            commands) search_dir="$tmpdir/.claude/commands" ;;
            hooks)    search_dir="$tmpdir/.claude/hooks" ;;
            mcps)     search_dir="$tmpdir" ;;
            settings) search_dir="$tmpdir" ;;
        esac

        if [ -d "$search_dir" ]; then
            for f in "$search_dir"/*; do
                [ -f "$f" ] || continue
                local fname
                fname=$(basename "$f")
                cp "$f" "$lib_dir/$fname"
                echo -e "  ${GREEN}saved${NC} $fname -> $lib_dir/"
                installed=$((installed + 1))
            done
        fi

        if [ "$installed" -gt 0 ]; then
            echo ""
            echo -e "${GREEN}Installed $installed $comp_type to library.${NC}"
            echo -e "Activate with: ${YELLOW}manage-components.sh enable $comp_type <name>${NC}"
        else
            echo -e "${YELLOW}No files found in download. Check aitmpl output above.${NC}"
        fi
    else
        echo -e "${RED}Download failed. Check the slug names and try again.${NC}"
    fi

    rm -rf "$tmpdir"
}

# ─── INFO ──────────────────────────────────────────────────────────────────

cmd_info() {
    local comp_type="$1"
    local name="$2"

    validate_type "$comp_type"

    local lib_dir="${LIBRARY_DIRS[$comp_type]}"

    # Find the file
    local source_file=""
    for ext in "" ".md" ".sh" ".json"; do
        if [ -f "$lib_dir/${name}${ext}" ]; then
            source_file="$lib_dir/${name}${ext}"
            break
        fi
    done

    if [ -z "$source_file" ]; then
        echo -e "${RED}Component '$name' not found in $comp_type library.${NC}"
        exit 1
    fi

    local filename
    filename=$(basename "$source_file")

    echo -e "${CYAN}=== $filename ($comp_type) ===${NC}"
    echo -e "Library: $source_file"

    # Check if active
    local active_dir="${ACTIVE_DIRS[$comp_type]:-}"
    if [ -n "$active_dir" ] && [ -f "$active_dir/$filename" ]; then
        echo -e "Status: ${GREEN}active${NC}"
    else
        echo -e "Status: inactive"
    fi

    echo ""
    echo -e "${YELLOW}--- Contents ---${NC}"
    head -40 "$source_file"

    local lines
    lines=$(wc -l < "$source_file")
    if [ "$lines" -gt 40 ]; then
        echo -e "\n${YELLOW}... ($((lines - 40)) more lines)${NC}"
    fi
}

# ─── SYNC ──────────────────────────────────────────────────────────────────

cmd_sync() {
    local target_project="$1"

    if [ ! -d "$target_project" ]; then
        echo -e "${RED}Error: Project directory not found: $target_project${NC}"
        exit 1
    fi

    echo -e "${CYAN}Syncing components to: $target_project${NC}"
    echo ""

    local synced=0

    # Sync agents
    local target_agents="$target_project/.claude/agents"
    if [ -d "$CLAUDE_DIR/agents" ] && [ -n "$(ls -A "$CLAUDE_DIR/agents" 2>/dev/null)" ]; then
        echo -e "${BLUE}[agents]${NC}"
        mkdir -p "$target_agents"
        for f in "$CLAUDE_DIR/agents"/*; do
            [ -f "$f" ] || continue
            local fname
            fname=$(basename "$f")
            if [ -f "$target_agents/$fname" ]; then
                echo -e "  ${YELLOW}skip${NC} $fname (already exists)"
            else
                cp "$f" "$target_agents/$fname"
                echo -e "  ${GREEN}copy${NC} $fname"
                synced=$((synced + 1))
            fi
        done
        echo ""
    fi

    # Sync commands
    local target_commands="$target_project/.claude/commands"
    if [ -d "$CLAUDE_DIR/commands" ] && [ -n "$(ls -A "$CLAUDE_DIR/commands" 2>/dev/null)" ]; then
        echo -e "${BLUE}[commands]${NC}"
        mkdir -p "$target_commands"
        for f in "$CLAUDE_DIR/commands"/*; do
            [ -f "$f" ] || continue
            local fname
            fname=$(basename "$f")
            if [ -f "$target_commands/$fname" ]; then
                echo -e "  ${YELLOW}skip${NC} $fname (already exists)"
            else
                cp "$f" "$target_commands/$fname"
                echo -e "  ${GREEN}copy${NC} $fname"
                synced=$((synced + 1))
            fi
        done
        echo ""
    fi

    # Skills sync is handled by manage-skills.sh
    echo -e "${YELLOW}Skills sync: use manage-skills.sh sync $target_project${NC}"
    echo ""

    echo -e "${CYAN}Synced $synced new components to $target_project${NC}"
}

# ─── HELPERS ───────────────────────────────────────────────────────────────

validate_type() {
    local comp_type="$1"
    case "$comp_type" in
        agents|commands|hooks|mcps|settings|skills) ;;
        *)
            echo -e "${RED}Invalid type: $comp_type${NC}"
            echo "Valid types: agents, commands, hooks, mcps, settings, skills"
            exit 1
            ;;
    esac
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
            cmd_list "${1:-all}"
            ;;
        enable)
            [ $# -ge 2 ] || { echo -e "${RED}Usage: manage-components.sh enable <type> <name>${NC}"; exit 1; }
            cmd_enable "$1" "$2"
            ;;
        disable)
            [ $# -ge 2 ] || { echo -e "${RED}Usage: manage-components.sh disable <type> <name>${NC}"; exit 1; }
            cmd_disable "$1" "$2"
            ;;
        install)
            [ $# -ge 2 ] || { echo -e "${RED}Usage: manage-components.sh install <type> <slug>${NC}"; exit 1; }
            cmd_install "$1" "$2"
            ;;
        info)
            [ $# -ge 2 ] || { echo -e "${RED}Usage: manage-components.sh info <type> <name>${NC}"; exit 1; }
            cmd_info "$1" "$2"
            ;;
        sync)
            [ $# -ge 1 ] || { echo -e "${RED}Usage: manage-components.sh sync <target-project-path>${NC}"; exit 1; }
            cmd_sync "$1"
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
