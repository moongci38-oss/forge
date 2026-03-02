#!/usr/bin/env bash
# manage-skills.sh — Skill library manager for business workspace
# Usage: bash scripts/manage-skills.sh <command> [args]

set -euo pipefail

BUSINESS_ROOT="${BUSINESS_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/business")}"
SKILLS_LIBRARY="$BUSINESS_ROOT/09-tools/skills-library"
ACTIVE_SKILLS="$BUSINESS_ROOT/.claude/skills"
ACTIVE_RULES="$BUSINESS_ROOT/.claude/rules"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
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
  manage-skills.sh audit                             Find unreferenced skills (disable candidates)
  manage-skills.sh validate [skill-name]             Validate SKILL.md frontmatter fields
  manage-skills.sh build <skill-name>                Generate AGENTS.md from rules/ subdirectory
  manage-skills.sh test <skill-name>                 Run subagent scenario test (placeholder)

Examples:
  manage-skills.sh enable aitmpl/business-marketing/product-strategist
  manage-skills.sh disable product-strategist
  manage-skills.sh install-aitmpl product-strategist
  manage-skills.sh sync ~/mywsl_workspace/portfolio-project
  manage-skills.sh validate
  manage-skills.sh validate nextjs-best-practices
  manage-skills.sh build my-skill
  manage-skills.sh test my-skill
EOF
}

# ─── LIST ──────────────────────────────────────────────────────────────────
cmd_list() {
    echo -e "${CYAN}=== Skill Library ===${NC}"
    echo ""

    # Collect active skill names (symlinks OR real directories)
    declare -A active_targets
    if [ -d "$ACTIVE_SKILLS" ]; then
        for item in "$ACTIVE_SKILLS"/*/; do
            [ -d "${item%/}" ] || continue
            local name
            name=$(basename "${item%/}")
            if [ -L "${item%/}" ]; then
                local target
                target=$(readlink -f "${item%/}" 2>/dev/null || echo "broken")
                active_targets["$name"]="symlink:$target"
            else
                active_targets["$name"]="directory"
            fi
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

                    if [ -d "$ACTIVE_SKILLS/$skill_name" ]; then
                        echo -e "    ${GREEN}* $skill_name${NC} (active)"
                        active=$((active + 1))
                    else
                        echo -e "      $skill_name"
                    fi
                done
            elif [ -f "$item/SKILL.md" ]; then
                # Direct skill (no category nesting)
                total=$((total + 1))
                if [ -d "$ACTIVE_SKILLS/$item_name" ]; then
                    echo -e "  ${GREEN}* $item_name${NC} (active)"
                    active=$((active + 1))
                else
                    echo -e "    $item_name"
                fi
            fi
        done
        echo ""
    done

    # Show active skills not in library
    local extra=0
    if [ -d "$ACTIVE_SKILLS" ]; then
        for item in "$ACTIVE_SKILLS"/*/; do
            [ -d "${item%/}" ] || continue
            local name
            name=$(basename "${item%/}")
            # Check if this skill was already counted from library
            local found_in_lib=false
            while IFS= read -r -d '' skill_md; do
                local dir
                dir=$(dirname "$skill_md")
                local lib_name
                lib_name=$(basename "$dir")
                if [ "$lib_name" = "$name" ]; then
                    found_in_lib=true
                    break
                fi
            done < <(find "$SKILLS_LIBRARY" -name "SKILL.md" -print0 2>/dev/null)

            if [ "$found_in_lib" = false ]; then
                if [ "$extra" -eq 0 ]; then
                    echo ""
                    echo -e "${BLUE}[active — not in library]${NC}"
                fi
                local kind="dir"
                [ -L "${item%/}" ] && kind="symlink"
                echo -e "  ${GREEN}* $name${NC} ($kind)"
                extra=$((extra + 1))
            fi
        done
    fi

    echo ""
    echo -e "${CYAN}Library: $total skills, $active linked to active${NC}"
    if [ "$extra" -gt 0 ]; then
        echo -e "${CYAN}Active (outside library): $extra skills${NC}"
    fi
    echo -e "${CYAN}Total active: $((active + extra))${NC}"
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

    if [ -L "$target" ]; then
        rm "$target"
        echo -e "${GREEN}Disabled (symlink removed): $skill_name${NC}"
    elif [ -d "$target" ]; then
        echo -e "${YELLOW}Warning: '$skill_name' is a real directory (not a symlink).${NC}"
        echo -e "This will permanently delete the skill directory."
        read -p "Continue? [y/N] " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            rm -rf "$target"
            echo -e "${GREEN}Disabled (directory removed): $skill_name${NC}"
        else
            echo -e "${YELLOW}Cancelled.${NC}"
        fi
    else
        echo -e "${RED}Error: '$skill_name' is not an active skill${NC}"
        exit 1
    fi
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

# ─── AUDIT ─────────────────────────────────────────────────────────────────
cmd_audit() {
    echo -e "${CYAN}=== Skill Audit: Unreferenced Skills ===${NC}"
    echo ""

    if [ ! -d "$ACTIVE_SKILLS" ]; then
        echo -e "${YELLOW}No active skills directory${NC}"
        return
    fi

    local total=0
    local unreferenced=0
    local referenced_by_pipeline=()
    local unreferenced_skills=()

    # Collect all active skill names
    for item in "$ACTIVE_SKILLS"/*/; do
        [ -d "${item%/}" ] || continue
        local name
        name=$(basename "${item%/}")
        total=$((total + 1))

        # Check if skill is referenced in commands, agents, or pipeline rules
        local found=false

        # Check .claude/commands/
        if [ -d "$BUSINESS_ROOT/.claude/commands" ]; then
            if grep -rql "$name" "$BUSINESS_ROOT/.claude/commands/" 2>/dev/null; then
                found=true
            fi
        fi

        # Check .claude/agents/
        if [ -d "$BUSINESS_ROOT/.claude/agents" ] && [ "$found" = "false" ]; then
            if grep -rql "$name" "$BUSINESS_ROOT/.claude/agents/" 2>/dev/null; then
                found=true
            fi
        fi

        # Check rules-source for pipeline references
        if [ -d "$BUSINESS_ROOT/09-tools/rules-source" ] && [ "$found" = "false" ]; then
            if grep -rql "$name" "$BUSINESS_ROOT/09-tools/rules-source/" 2>/dev/null; then
                found=true
            fi
        fi

        # Check active rules
        if [ "$found" = "false" ]; then
            if grep -rql "$name" "$ACTIVE_RULES/" 2>/dev/null; then
                found=true
            fi
        fi

        if [ "$found" = "true" ]; then
            referenced_by_pipeline+=("$name")
        else
            unreferenced_skills+=("$name")
            unreferenced=$((unreferenced + 1))
        fi
    done

    echo -e "${GREEN}Referenced by pipeline/commands/agents: ${#referenced_by_pipeline[@]}${NC}"
    for s in "${referenced_by_pipeline[@]}"; do
        echo "  [ok] $s"
    done

    echo ""
    if [ "$unreferenced" -gt 0 ]; then
        echo -e "${YELLOW}Unreferenced (disable candidates): $unreferenced${NC}"
        for s in "${unreferenced_skills[@]}"; do
            echo "  [?] $s"
        done
        echo ""
        echo -e "${YELLOW}Run 'manage-skills.sh disable <name>' to deactivate${NC}"
    else
        echo -e "${GREEN}All skills are referenced. No disable candidates.${NC}"
    fi

    echo ""
    echo -e "${BOLD}Total: $total active | $((total - unreferenced)) referenced | $unreferenced unreferenced${NC}"
}

# ─── VALIDATE ──────────────────────────────────────────────────────────────
cmd_validate() {
    local skill_filter="${1:-}"

    local required_fields=("name" "description")
    local recommended_fields=("version" "category" "domain" "enforcement")

    validate_one_skill() {
        local skill_dir="$1"
        local skill_name
        skill_name=$(basename "$skill_dir")
        local skill_md="$skill_dir/SKILL.md"

        if [ ! -f "$skill_md" ]; then
            echo -e "  ${RED}[ERROR]${NC} $skill_name: SKILL.md not found"
            return 1
        fi

        # Extract frontmatter (between --- markers)
        local frontmatter
        frontmatter=$(awk '/^---$/{if(++n==1){found=1; next} if(n==2){exit}} found{print}' "$skill_md")

        local errors=0
        local warnings=0

        # Check required fields
        for field in "${required_fields[@]}"; do
            if ! echo "$frontmatter" | grep -q "^${field}:"; then
                echo -e "  ${RED}[ERROR]${NC} $skill_name: missing required field '$field'"
                errors=$((errors + 1))
            fi
        done

        # Check recommended fields
        for field in "${recommended_fields[@]}"; do
            if ! echo "$frontmatter" | grep -q "^${field}:"; then
                echo -e "  ${YELLOW}[WARN]${NC}  $skill_name: missing recommended field '$field'"
                warnings=$((warnings + 1))
            fi
        done

        if [ "$errors" -eq 0 ] && [ "$warnings" -eq 0 ]; then
            echo -e "  ${GREEN}[OK]${NC}   $skill_name"
        elif [ "$errors" -eq 0 ]; then
            echo -e "  ${YELLOW}[WARN]${NC}  $skill_name ($warnings warning(s))"
        fi

        return "$errors"
    }

    echo -e "${CYAN}=== Skill Frontmatter Validation ===${NC}"
    echo ""

    local total=0
    local passed=0
    local failed=0

    if [ -n "$skill_filter" ]; then
        # Validate single skill — search in library and active
        local found_dir=""
        while IFS= read -r -d '' skill_md; do
            local dir
            dir=$(dirname "$skill_md")
            if [ "$(basename "$dir")" = "$skill_filter" ]; then
                found_dir="$dir"
                break
            fi
        done < <(find "$SKILLS_LIBRARY" "$ACTIVE_SKILLS" -name "SKILL.md" -print0 2>/dev/null)

        if [ -z "$found_dir" ]; then
            echo -e "${RED}Skill '$skill_filter' not found.${NC}"
            exit 1
        fi

        total=1
        if validate_one_skill "$found_dir"; then
            passed=1
        else
            failed=1
        fi
    else
        # Validate all active skills
        if [ ! -d "$ACTIVE_SKILLS" ]; then
            echo -e "${YELLOW}No active skills directory${NC}"
            return
        fi

        for item in "$ACTIVE_SKILLS"/*/; do
            [ -d "${item%/}" ] || continue
            total=$((total + 1))
            if validate_one_skill "${item%/}"; then
                passed=$((passed + 1))
            else
                failed=$((failed + 1))
            fi
        done
    fi

    echo ""
    echo -e "${BOLD}Total: $total | ${GREEN}Passed: $passed${NC}${BOLD} | ${RED}Failed: $failed${NC}"
    [ "$failed" -eq 0 ] || exit 1
}

# ─── BUILD ──────────────────────────────────────────────────────────────────
cmd_build() {
    local skill_name="${1:-}"
    [ -n "$skill_name" ] || { echo -e "${RED}Usage: manage-skills.sh build <skill-name>${NC}"; exit 1; }

    # Find skill directory in library or active
    local found_dir=""
    while IFS= read -r -d '' skill_md; do
        local dir
        dir=$(dirname "$skill_md")
        if [ "$(basename "$dir")" = "$skill_name" ]; then
            found_dir="$dir"
            break
        fi
    done < <(find "$SKILLS_LIBRARY" "$ACTIVE_SKILLS" -name "SKILL.md" -print0 2>/dev/null)

    if [ -z "$found_dir" ]; then
        echo -e "${RED}Skill '$skill_name' not found.${NC}"
        exit 1
    fi

    local rules_dir="$found_dir/rules"
    if [ ! -d "$rules_dir" ]; then
        echo -e "${YELLOW}No rules/ directory found in $found_dir${NC}"
        echo "Skipping AGENTS.md generation (no rule files to concatenate)."
        return 0
    fi

    local rule_files=()
    while IFS= read -r -d '' f; do
        rule_files+=("$f")
    done < <(find "$rules_dir" -name "*.md" -print0 2>/dev/null | sort -z)

    if [ "${#rule_files[@]}" -eq 0 ]; then
        echo -e "${YELLOW}rules/ directory is empty. No AGENTS.md generated.${NC}"
        return 0
    fi

    local agents_md="$found_dir/AGENTS.md"
    {
        echo "# AGENTS.md — $skill_name"
        echo ""
        echo "> Auto-generated by manage-skills.sh build. Do not edit directly."
        echo "> Source: rules/"
        echo ""
        echo "---"
        echo ""
        for rule_file in "${rule_files[@]}"; do
            local rule_name
            rule_name=$(basename "$rule_file" .md)
            echo "## $rule_name"
            echo ""
            cat "$rule_file"
            echo ""
            echo "---"
            echo ""
        done
    } > "$agents_md"

    echo -e "${GREEN}Built AGENTS.md for '$skill_name'${NC}"
    echo "  Source: $rules_dir (${#rule_files[@]} file(s))"
    echo "  Output: $agents_md"
}

# ─── TEST ───────────────────────────────────────────────────────────────────
cmd_test() {
    local skill_name="${1:-}"
    [ -n "$skill_name" ] || { echo -e "${RED}Usage: manage-skills.sh test <skill-name>${NC}"; exit 1; }

    # Find skill directory
    local found_dir=""
    while IFS= read -r -d '' skill_md; do
        local dir
        dir=$(dirname "$skill_md")
        if [ "$(basename "$dir")" = "$skill_name" ]; then
            found_dir="$dir"
            break
        fi
    done < <(find "$SKILLS_LIBRARY" "$ACTIVE_SKILLS" -name "SKILL.md" -print0 2>/dev/null)

    if [ -z "$found_dir" ]; then
        echo -e "${RED}Skill '$skill_name' not found.${NC}"
        exit 1
    fi

    echo -e "${CYAN}=== Skill Test: $skill_name ===${NC}"
    echo ""

    # Extract name and description from frontmatter for display
    local skill_md="$found_dir/SKILL.md"
    local frontmatter
    frontmatter=$(awk '/^---$/{if(++n==1){found=1; next} if(n==2){exit}} found{print}' "$skill_md")

    local name_val description_val
    name_val=$(echo "$frontmatter" | grep "^name:" | sed 's/^name:[[:space:]]*//' | tr -d '"')
    description_val=$(echo "$frontmatter" | grep "^description:" | sed 's/^description:[[:space:]]*//' | tr -d '"')

    echo -e "  ${BOLD}Name:${NC}        $name_val"
    echo -e "  ${BOLD}Description:${NC} $description_val"
    echo ""
    echo -e "${YELLOW}Subagent testing will be available in a future update.${NC}"
    echo ""
    echo "Planned behavior:"
    echo "  1. Load skill into a subagent context"
    echo "  2. Run TDD scenarios defined in the skill's test suite"
    echo "  3. Report pass/fail for each scenario"
    echo ""
    echo "For now, test manually by loading the skill in a Claude Code subagent"
    echo "and running the scenarios from the Rationalization Table / Red Flags sections."
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
        audit)
            cmd_audit
            ;;
        validate)
            cmd_validate "${1:-}"
            ;;
        build)
            [ $# -ge 1 ] || { echo -e "${RED}Usage: manage-skills.sh build <skill-name>${NC}"; exit 1; }
            cmd_build "$1"
            ;;
        test)
            [ $# -ge 1 ] || { echo -e "${RED}Usage: manage-skills.sh test <skill-name>${NC}"; exit 1; }
            cmd_test "$1"
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
