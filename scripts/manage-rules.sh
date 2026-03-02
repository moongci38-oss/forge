#!/usr/bin/env bash
# manage-rules.sh — Rules-as-Code 관리 CLI
# Usage: bash scripts/manage-rules.sh <command> [args]

set -euo pipefail

BUSINESS_ROOT="${BUSINESS_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/business")}"
RULES_SOURCE="$BUSINESS_ROOT/09-tools/rules-source"
BUILD_OUTPUT="$BUSINESS_ROOT/09-tools/build-output"
ACTIVE_RULES="$BUSINESS_ROOT/.claude/rules"
SCRIPTS_DIR="$BUSINESS_ROOT/09-tools/scripts"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

usage() {
    cat <<'EOF'
Rules-as-Code Manager

Usage:
  manage-rules.sh list                          List all rules with scope/impact
  manage-rules.sh validate                      Validate schema + dependencies
  manage-rules.sh build --scope <scope>         Compile rules for a scope
  manage-rules.sh build --all                   Compile all scopes
  manage-rules.sh stats                         Token estimates + scope statistics
  manage-rules.sh sync <project-path>           Deploy scope-filtered rules to project
  manage-rules.sh manifest                      Generate rules-manifest.json + test-cases.json

Scopes: always, sigil, trine, cowork

Examples:
  manage-rules.sh list
  manage-rules.sh validate
  manage-rules.sh build --scope business
  manage-rules.sh build --all
  manage-rules.sh stats
  manage-rules.sh sync ~/mywsl_workspace/portfolio-project
  manage-rules.sh manifest
EOF
}

# ─── LIST ──────────────────────────────────────────────────────────────────
cmd_list() {
    echo -e "${CYAN}=== Rules-as-Code Registry ===${NC}"
    echo ""

    local total=0
    local by_scope_always=0
    local by_scope_sigil=0
    local by_scope_trine=0
    local by_scope_cowork=0

    for scope_dir in "$RULES_SOURCE"/*/; do
        [ -d "$scope_dir" ] || continue
        local scope
        scope=$(basename "$scope_dir")
        echo -e "${BLUE}[$scope]${NC}"

        for md_file in "$scope_dir"*.md; do
            [ -f "$md_file" ] || continue
            local name
            name=$(basename "$md_file" .md)
            [ "$name" = "README" ] && continue

            # Extract frontmatter fields
            local title impact scopes
            title=$(sed -n '/^---$/,/^---$/{ /^title:/{ s/^title: *"*//; s/"*$//; p; } }' "$md_file")
            impact=$(sed -n '/^---$/,/^---$/{ /^impact:/{ s/^impact: *//; p; } }' "$md_file")
            scopes=$(sed -n '/^---$/,/^---$/{ /^scope:/{ s/^scope: *\[//; s/\]//; p; } }' "$md_file")

            # Color by impact
            local impact_color="$NC"
            case "$impact" in
                CRITICAL) impact_color="$RED" ;;
                HIGH) impact_color="$YELLOW" ;;
                MEDIUM) impact_color="$BLUE" ;;
                LOW) impact_color="$NC" ;;
            esac

            printf "  %-35s ${impact_color}%-10s${NC} [%s]\n" "$name" "$impact" "$scopes"
            total=$((total + 1))
        done
        echo ""
    done

    echo -e "${BOLD}Total: $total rules${NC}"
}

# ─── VALIDATE ──────────────────────────────────────────────────────────────
cmd_validate() {
    echo -e "${CYAN}=== Validating Rules ===${NC}"
    echo ""

    if command -v python3 &>/dev/null; then
        python3 "$SCRIPTS_DIR/validate-rules.py" "$RULES_SOURCE"
    else
        echo -e "${RED}Error: python3 required for validation${NC}"
        exit 1
    fi
}

# ─── BUILD ─────────────────────────────────────────────────────────────────
cmd_build() {
    local target_scope="$1"
    echo -e "${CYAN}=== Building Rules (scope: $target_scope) ===${NC}"
    echo ""

    if [ "$target_scope" = "--all" ] || [ "$target_scope" = "all" ]; then
        _build_scope "business"
        echo ""
        _build_scope "sigil"
        echo ""
        _build_scope "trine"
        return
    fi

    _build_scope "$target_scope"
}

_build_scope() {
    local scope="$1"
    local output_file

    case "$scope" in
        business)
            # always + cross-project rules → business-core.md
            output_file="$ACTIVE_RULES/business-core.md"
            echo -e "${BLUE}Compiling: always + cross-project → business-core.md${NC}"
            _compile_files "$output_file" "always" "cross-project"
            ;;
        sigil)
            # sigil rules → sigil-compiled.md (progressive disclosure)
            output_file="$ACTIVE_RULES/sigil-compiled.md"
            echo -e "${BLUE}Compiling: sigil → sigil-compiled.md (progressive disclosure)${NC}"
            _compile_progressive "$output_file" "sigil"
            ;;
        trine)
            echo -e "${BLUE}Trine rules are managed at ~/.claude/trine/rules/${NC}"
            echo -e "Use 'manage-rules.sh sync <project>' to deploy to dev projects"
            return
            ;;
        cowork)
            output_file="$ACTIVE_RULES/cowork-rules.md"
            echo -e "${BLUE}Compiling: cowork → cowork-rules.md${NC}"
            _compile_files "$output_file" "cowork"
            ;;
        *)
            echo -e "${RED}Unknown scope: $scope${NC}"
            echo "Valid scopes: business, sigil, trine, cowork"
            exit 1
            ;;
    esac

    if [ -f "$output_file" ]; then
        local size
        size=$(wc -c < "$output_file")
        local tokens=$((size / 4))
        echo -e "${GREEN}Output: $output_file ($size bytes, ~$tokens tokens)${NC}"
    fi
}

_compile_files() {
    local output="$1"
    shift
    local scopes=("$@")

    {
        echo "# Compiled Rules ($(date +%Y-%m-%d))"
        echo ""
        echo "> Auto-generated by manage-rules.sh build. Do not edit directly."
        echo "> Source: 09-tools/rules-source/"
        echo ""

        for scope in "${scopes[@]}"; do
            local scope_dir="$RULES_SOURCE/$scope"
            [ -d "$scope_dir" ] || continue

            for md_file in "$scope_dir"/*.md; do
                [ -f "$md_file" ] || continue
                local name
                name=$(basename "$md_file" .md)
                [ "$name" = "README" ] && continue

                echo "---"
                echo ""
                # Strip frontmatter, keep content
                sed '1{/^---$/!q}; 1,/^---$/d' "$md_file"
                echo ""
            done
        done
    } > "$output"
}

_compile_progressive() {
    local output="$1"
    local scope="$2"
    local scope_dir="$RULES_SOURCE/$scope"

    {
        echo "# SIGIL Pipeline Rules (Compiled $(date +%Y-%m-%d))"
        echo ""
        echo "> Auto-generated by manage-rules.sh build --scope sigil"
        echo "> Progressive Disclosure: CRITICAL/HIGH=전문, MEDIUM/LOW=요약+참조"
        echo "> Source: 09-tools/rules-source/sigil/"
        echo ""

        for md_file in "$scope_dir"/*.md; do
            [ -f "$md_file" ] || continue
            local name
            name=$(basename "$md_file" .md)
            [ "$name" = "README" ] && continue

            local impact
            impact=$(sed -n '/^---$/,/^---$/{ /^impact:/{ s/^impact: *//; p; } }' "$md_file")
            local title
            title=$(sed -n '/^---$/,/^---$/{ /^title:/{ s/^title: *"*//; s/"*$//; p; } }' "$md_file")

            case "$impact" in
                CRITICAL|HIGH)
                    # Full content
                    echo "---"
                    echo ""
                    sed '1{/^---$/!q}; 1,/^---$/d' "$md_file"
                    echo ""
                    ;;
                MEDIUM|LOW)
                    # Summary only
                    echo "---"
                    echo ""
                    echo "## $title"
                    echo ""
                    # Extract first paragraph after frontmatter as summary
                    local summary
                    summary=$(sed '1{/^---$/!q}; 1,/^---$/d' "$md_file" | sed -n '/^[^#]/{ p; q }')
                    echo "$summary"
                    echo ""
                    echo "> 상세: \`09-tools/rules-source/sigil/$name.md\` 참조"
                    echo ""
                    ;;
            esac
        done
    } > "$output"
}

# ─── STATS ─────────────────────────────────────────────────────────────────
cmd_stats() {
    echo -e "${CYAN}=== Rules Token Statistics ===${NC}"
    echo ""

    local total_bytes=0
    local total_files=0

    for scope_dir in "$RULES_SOURCE"/*/; do
        [ -d "$scope_dir" ] || continue
        local scope
        scope=$(basename "$scope_dir")
        local scope_bytes=0
        local scope_files=0

        for md_file in "$scope_dir"*.md; do
            [ -f "$md_file" ] || continue
            [ "$(basename "$md_file")" = "README.md" ] && continue
            local size
            size=$(wc -c < "$md_file")
            scope_bytes=$((scope_bytes + size))
            scope_files=$((scope_files + 1))
        done

        local scope_tokens=$((scope_bytes / 4))
        printf "  %-20s %3d files  %'8d bytes  ~%'6d tokens\n" "[$scope]" "$scope_files" "$scope_bytes" "$scope_tokens"
        total_bytes=$((total_bytes + scope_bytes))
        total_files=$((total_files + scope_files))
    done

    echo ""
    local total_tokens=$((total_bytes / 4))
    echo -e "${BOLD}Total: $total_files files, $total_bytes bytes, ~$total_tokens tokens${NC}"

    # Compare with active rules
    echo ""
    echo -e "${BLUE}Active rules (.claude/rules/):${NC}"
    local active_bytes=0
    local active_files=0
    for f in "$ACTIVE_RULES"/*.md; do
        [ -f "$f" ] || continue
        local size
        size=$(wc -c < "$f")
        active_bytes=$((active_bytes + size))
        active_files=$((active_files + 1))
        printf "  %-35s %'6d bytes\n" "$(basename "$f")" "$size"
    done
    local active_tokens=$((active_bytes / 4))
    echo -e "${BOLD}Active total: $active_files files, $active_bytes bytes, ~$active_tokens tokens${NC}"

    # Global rules
    echo ""
    echo -e "${BLUE}Global rules (~/.claude/rules/):${NC}"
    local global_bytes=0
    local global_files=0
    local global_dir
    global_dir="$(eval echo '~/.claude/rules')"
    if [ -d "$global_dir" ]; then
        for f in "$global_dir"/*.md; do
            [ -f "$f" ] || continue
            local size
            size=$(wc -c < "$f")
            global_bytes=$((global_bytes + size))
            global_files=$((global_files + 1))
            printf "  %-35s %'6d bytes\n" "$(basename "$f")" "$size"
        done
    fi
    local global_tokens=$((global_bytes / 4))
    echo -e "${BOLD}Global total: $global_files files, $global_bytes bytes, ~$global_tokens tokens${NC}"

    echo ""
    local session_tokens=$((active_tokens + global_tokens))
    local pct=$((session_tokens * 100 / 200000))
    echo -e "${BOLD}Session start estimate: ~$session_tokens tokens (${pct}% of 200K)${NC}"
}

# ─── SYNC ──────────────────────────────────────────────────────────────────
cmd_sync() {
    local target_project="$1"
    local target_rules="$target_project/.claude/rules"

    if [ ! -d "$target_project" ]; then
        echo -e "${RED}Error: Project directory not found: $target_project${NC}"
        exit 1
    fi

    mkdir -p "$target_rules"

    echo -e "${CYAN}=== Syncing Rules to: $target_project ===${NC}"
    echo ""

    # Sync trine rules as symlinks
    local trine_source
    trine_source="$(eval echo '~/.claude/trine/rules')"
    if [ -d "$trine_source" ]; then
        echo -e "${BLUE}Syncing trine rules (symlinks):${NC}"
        for f in "$trine_source"/trine-*.md; do
            [ -f "$f" ] || continue
            local name
            name=$(basename "$f")
            local target="$target_rules/$name"

            if [ -L "$target" ]; then
                echo "  [skip] $name (symlink exists)"
            elif [ -f "$target" ]; then
                echo "  [skip] $name (file exists, not overwriting)"
            else
                ln -s "$f" "$target"
                echo -e "  ${GREEN}[link] $name${NC}"
            fi
        done
    fi

    echo ""
    echo -e "${GREEN}Sync complete.${NC}"
}

# ─── MANIFEST ──────────────────────────────────────────────────────────────
cmd_manifest() {
    echo -e "${CYAN}=== Generating Manifest ===${NC}"
    echo ""

    mkdir -p "$BUILD_OUTPUT"

    if command -v python3 &>/dev/null; then
        python3 "$SCRIPTS_DIR/parse-frontmatter.py" --manifest "$RULES_SOURCE" --test-cases \
            > "$BUILD_OUTPUT/rules-manifest.json"
        echo -e "${GREEN}Generated: $BUILD_OUTPUT/rules-manifest.json${NC}"

        if [ -f "$BUILD_OUTPUT/test-cases.json" ]; then
            local tc_count
            tc_count=$(python3 -c "import json; d=json.load(open('$BUILD_OUTPUT/test-cases.json')); print(len(d.get('testCases',[])))")
            echo -e "${GREEN}Generated: $BUILD_OUTPUT/test-cases.json ($tc_count test cases)${NC}"
        fi
    else
        echo -e "${RED}Error: python3 required for manifest generation${NC}"
        exit 1
    fi
}

# ─── MAIN ──────────────────────────────────────────────────────────────────
main() {
    local cmd="${1:-help}"
    shift || true

    case "$cmd" in
        list)
            cmd_list
            ;;
        validate)
            cmd_validate
            ;;
        build)
            local scope="${1:---all}"
            [ "$scope" = "--scope" ] && scope="${2:-business}"
            cmd_build "$scope"
            ;;
        stats)
            cmd_stats
            ;;
        sync)
            [ $# -ge 1 ] || { echo -e "${RED}Usage: manage-rules.sh sync <project-path>${NC}"; exit 1; }
            cmd_sync "$1"
            ;;
        manifest)
            cmd_manifest
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
