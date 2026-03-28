#!/usr/bin/env bash
# forge-knowledge-index.sh — 규칙 인덱스 빌드 + 검색 CLI
# Usage: bash forge-knowledge-index.sh build
#        bash forge-knowledge-index.sh search <query>
#        bash forge-knowledge-index.sh search --tag <tag>
#        bash forge-knowledge-index.sh search --impact <CRITICAL|HIGH|MEDIUM|LOW>
#        bash forge-knowledge-index.sh search --section <section>
#
# 3개 위치의 규칙 파일을 스캔하여 JSON 인덱스를 생성하고 검색한다.
# jq 없이 grep/sed/awk 기반으로 동작.

set -uo pipefail

FORGE_DEV_ROOT="${FORGE_DEV_ROOT:-$HOME/.claude/forge}"
FORGE_ROOT="${FORGE_ROOT:-$HOME/forge}"
GLOBAL_RULES="${GLOBAL_RULES:-$HOME/.claude/rules}"
INDEX_FILE="$FORGE_DEV_ROOT/knowledge-index.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── USAGE ───────────────────────────────────────────────────────────────────

usage() {
    cat <<'EOF'
Forge Dev Knowledge Index — 규칙 빌드 + 검색

Usage:
  forge-knowledge-index.sh build                     인덱스 빌드
  forge-knowledge-index.sh search <query>            제목/ID/태그 텍스트 검색
  forge-knowledge-index.sh search --tag <tag>        태그 필터
  forge-knowledge-index.sh search --impact <level>   임팩트 필터 (CRITICAL|HIGH|MEDIUM|LOW)
  forge-knowledge-index.sh search --section <sec>    섹션 필터

Options:
  --help    이 도움말 표시
EOF
}

# ─── FRONTMATTER PARSER ──────────────────────────────────────────────────────

# Extract field value from frontmatter text (stdin)
# Usage: echo "$frontmatter" | fm_field "title"
fm_field() {
    local field="$1"
    grep "^${field}:" | head -1 | sed "s/^${field}: *//;s/^\"//;s/\"$//"
}

# Extract frontmatter block from file (between --- markers)
get_frontmatter() {
    local file="$1"
    sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d'
}

# Check if file has frontmatter
has_frontmatter() {
    local file="$1"
    head -1 "$file" | grep -q '^---$'
}

# Parse tags "[tag1, tag2, tag3]" → JSON array string
tags_to_json() {
    local raw="$1"
    # Remove brackets
    raw=$(echo "$raw" | sed 's/^\[//;s/\]$//')
    if [[ -z "$raw" ]]; then
        echo "[]"
        return
    fi
    # Split by comma, trim, quote each
    local result="["
    local first=true
    IFS=',' read -ra items <<< "$raw"
    for item in "${items[@]}"; do
        item=$(echo "$item" | sed 's/^ *//;s/ *$//')
        [[ -z "$item" ]] && continue
        if $first; then
            first=false
        else
            result+=","
        fi
        result+="\"$item\""
    done
    result+="]"
    echo "$result"
}

# Escape string for JSON (handle quotes and backslashes)
json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    echo "$s"
}

# ─── BUILD ───────────────────────────────────────────────────────────────────

cmd_build() {
    echo -e "${BOLD}=== Forge Dev Knowledge Index — Build ===${NC}"
    echo ""

    local count=0
    local first=true

    echo "[" > "$INDEX_FILE"

    # Location 1: ${FORGE_ROOT:-$HOME/forge}/dev/rules/*.md
    local loc1_count=0
    if [[ -d "$FORGE_DEV_ROOT/rules" ]]; then
        for file in "$FORGE_DEV_ROOT/rules"/*.md; do
            [[ -f "$file" ]] || continue
            if has_frontmatter "$file"; then
                local fm
                fm=$(get_frontmatter "$file")
                local id title impact tags section
                id=$(echo "$fm" | fm_field "id")
                title=$(echo "$fm" | fm_field "title")
                impact=$(echo "$fm" | fm_field "impact")
                tags=$(echo "$fm" | fm_field "tags")
                section=$(echo "$fm" | fm_field "section")

                [[ -z "$id" ]] && id=$(basename "$file" .md)
                [[ -z "$title" ]] && title="$id"
                [[ -z "$impact" ]] && impact="UNKNOWN"
                [[ -z "$section" ]] && section="forge"

                local tags_json
                tags_json=$(tags_to_json "$tags")
                local esc_title
                esc_title=$(json_escape "$title")

                if $first; then first=false; else echo "," >> "$INDEX_FILE"; fi
                printf '  {"id":"%s","title":"%s","impact":"%s","tags":%s,"section":"%s","path":"%s","location":"forge-rules"}' \
                    "$id" "$esc_title" "$impact" "$tags_json" "$section" "$file" >> "$INDEX_FILE"
                ((count++))
                ((loc1_count++))
            fi
        done
        echo -e "  ${GREEN}forge-rules${NC}: $loc1_count files"
    else
        echo -e "  ${YELLOW}forge-rules${NC}: directory not found (skipped)"
    fi

    # Location 2: ~/forge/planning/rules-source/**/*.md
    local loc2_count=0
    local rules_source="$FORGE_ROOT/planning/rules-source"
    if [[ -d "$rules_source" ]]; then
        while IFS= read -r file; do
            [[ -f "$file" ]] || continue
            # Skip _sections.md and README.md
            local bname
            bname=$(basename "$file")
            [[ "$bname" == "_sections.md" ]] && continue
            [[ "$bname" == "README.md" ]] && continue

            if has_frontmatter "$file"; then
                local fm
                fm=$(get_frontmatter "$file")
                local id title impact tags section
                id=$(echo "$fm" | fm_field "id")
                title=$(echo "$fm" | fm_field "title")
                impact=$(echo "$fm" | fm_field "impact")
                tags=$(echo "$fm" | fm_field "tags")
                section=$(echo "$fm" | fm_field "section")

                [[ -z "$id" ]] && id=$(basename "$file" .md)
                [[ -z "$title" ]] && title="$id"
                [[ -z "$impact" ]] && impact="UNKNOWN"
                [[ -z "$section" ]] && section="business"

                local tags_json
                tags_json=$(tags_to_json "$tags")
                local esc_title
                esc_title=$(json_escape "$title")

                if $first; then first=false; else echo "," >> "$INDEX_FILE"; fi
                printf '  {"id":"%s","title":"%s","impact":"%s","tags":%s,"section":"%s","path":"%s","location":"business-rules-source"}' \
                    "$id" "$esc_title" "$impact" "$tags_json" "$section" "$file" >> "$INDEX_FILE"
                ((count++))
                ((loc2_count++))
            fi
        done < <(find "$rules_source" -name '*.md' -type f 2>/dev/null | sort)
        echo -e "  ${GREEN}business-rules-source${NC}: $loc2_count files"
    else
        echo -e "  ${YELLOW}business-rules-source${NC}: directory not found (skipped)"
    fi

    # Location 3: ~/.claude/rules/*.md (no frontmatter)
    local loc3_count=0
    if [[ -d "$GLOBAL_RULES" ]]; then
        for file in "$GLOBAL_RULES"/*.md; do
            [[ -f "$file" ]] || continue
            local id title
            id=$(basename "$file" .md)
            # Extract title from first # heading
            title=$(grep -m1 '^# ' "$file" | sed 's/^# //')
            [[ -z "$title" ]] && title="$id"

            local esc_title
            esc_title=$(json_escape "$title")

            if $first; then first=false; else echo "," >> "$INDEX_FILE"; fi
            printf '  {"id":"%s","title":"%s","impact":"UNKNOWN","tags":[],"section":"global","path":"%s","location":"global-rules"}' \
                "$id" "$esc_title" "$file" >> "$INDEX_FILE"
            ((count++))
            ((loc3_count++))
        done
        echo -e "  ${GREEN}global-rules${NC}: $loc3_count files"
    else
        echo -e "  ${YELLOW}global-rules${NC}: directory not found (skipped)"
    fi

    echo "" >> "$INDEX_FILE"
    echo "]" >> "$INDEX_FILE"

    echo ""

    # Validate JSON
    if python3 -c "import json; json.load(open('$INDEX_FILE'))" 2>/dev/null; then
        echo -e "${GREEN}${BOLD}Index built successfully${NC}: $count entries → $INDEX_FILE"
    else
        echo -e "${RED}${BOLD}JSON validation failed${NC}. Check $INDEX_FILE for syntax errors."
        return 1
    fi
}

# ─── SEARCH ──────────────────────────────────────────────────────────────────

cmd_search() {
    if [[ ! -f "$INDEX_FILE" ]]; then
        echo -e "${RED}Index not found.${NC} Run 'build' first."
        exit 1
    fi

    local mode="text"
    local query=""

    # Parse search args
    case "${1:-}" in
        --tag)
            mode="tag"
            query="${2:-}"
            [[ -z "$query" ]] && { echo "Usage: search --tag <tag>"; exit 1; }
            ;;
        --impact)
            mode="impact"
            query="${2:-}"
            [[ -z "$query" ]] && { echo "Usage: search --impact <CRITICAL|HIGH|MEDIUM|LOW>"; exit 1; }
            query=$(echo "$query" | tr '[:lower:]' '[:upper:]')
            ;;
        --section)
            mode="section"
            query="${2:-}"
            [[ -z "$query" ]] && { echo "Usage: search --section <section>"; exit 1; }
            ;;
        "")
            echo "Usage: search <query> | --tag <tag> | --impact <level> | --section <sec>"
            exit 1
            ;;
        *)
            mode="text"
            query="$1"
            ;;
    esac

    echo -e "${BOLD}=== Search: ${CYAN}$query${NC} ${BOLD}(mode: $mode) ===${NC}"
    echo ""

    local found=0

    # Read JSON line by line, parse each entry
    # Each entry is on one line (our build format)
    while IFS= read -r line; do
        # Skip non-entry lines
        [[ "$line" == "[" ]] && continue
        [[ "$line" == "]" ]] && continue
        [[ -z "$line" ]] && continue

        # Remove leading whitespace and trailing comma
        line=$(echo "$line" | sed 's/^ *//;s/,$//')

        # Extract fields with grep
        local id title impact tags_raw section path
        id=$(echo "$line" | grep -o '"id":"[^"]*"' | head -1 | sed 's/"id":"//;s/"$//')
        title=$(echo "$line" | grep -o '"title":"[^"]*"' | head -1 | sed 's/"title":"//;s/"$//')
        impact=$(echo "$line" | grep -o '"impact":"[^"]*"' | head -1 | sed 's/"impact":"//;s/"$//')
        section=$(echo "$line" | grep -o '"section":"[^"]*"' | head -1 | sed 's/"section":"//;s/"$//')
        path=$(echo "$line" | grep -o '"path":"[^"]*"' | head -1 | sed 's/"path":"//;s/"$//')
        tags_raw=$(echo "$line" | grep -o '"tags":\[[^]]*\]' | head -1 | sed 's/"tags":\[//;s/\]$//')

        [[ -z "$id" ]] && continue

        local match=false

        case "$mode" in
            text)
                local lq
                lq=$(echo "$query" | tr '[:upper:]' '[:lower:]')
                local lid ltitle ltags
                lid=$(echo "$id" | tr '[:upper:]' '[:lower:]')
                ltitle=$(echo "$title" | tr '[:upper:]' '[:lower:]')
                ltags=$(echo "$tags_raw" | tr '[:upper:]' '[:lower:]')
                if [[ "$lid" == *"$lq"* ]] || [[ "$ltitle" == *"$lq"* ]] || [[ "$ltags" == *"$lq"* ]]; then
                    match=true
                fi
                ;;
            tag)
                local lq
                lq=$(echo "$query" | tr '[:upper:]' '[:lower:]')
                local ltags
                ltags=$(echo "$tags_raw" | tr '[:upper:]' '[:lower:]' | sed 's/"//g')
                # Check each tag
                IFS=',' read -ra tag_items <<< "$ltags"
                for t in "${tag_items[@]}"; do
                    t=$(echo "$t" | sed 's/^ *//;s/ *$//')
                    if [[ "$t" == "$lq" ]]; then
                        match=true
                        break
                    fi
                done
                ;;
            impact)
                [[ "$impact" == "$query" ]] && match=true
                ;;
            section)
                local lq
                lq=$(echo "$query" | tr '[:upper:]' '[:lower:]')
                local lsec
                lsec=$(echo "$section" | tr '[:upper:]' '[:lower:]')
                [[ "$lsec" == *"$lq"* ]] && match=true
                ;;
        esac

        if $match; then
            # Color the impact level
            local impact_color="$NC"
            case "$impact" in
                CRITICAL) impact_color="$RED" ;;
                HIGH) impact_color="$YELLOW" ;;
                MEDIUM) impact_color="$BLUE" ;;
                LOW) impact_color="$GREEN" ;;
            esac

            # Display tags without quotes
            local display_tags
            display_tags=$(echo "$tags_raw" | sed 's/"//g')

            echo -e "  [${impact_color}${impact}${NC}] ${BOLD}${id}${NC} — $title"
            [[ -n "$display_tags" ]] && echo -e "    tags: $display_tags"
            echo -e "    path: ${CYAN}$path${NC}"
            echo ""
            ((found++))
        fi
    done < "$INDEX_FILE"

    if [[ $found -eq 0 ]]; then
        echo -e "  ${YELLOW}No rules found matching:${NC} $query"
    else
        echo -e "${GREEN}${found} rule(s) found.${NC}"
    fi
}

# ─── MAIN ────────────────────────────────────────────────────────────────────

case "${1:-}" in
    build)
        cmd_build
        ;;
    search)
        shift
        cmd_search "$@"
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
