#!/usr/bin/env bash
# deep-rule-router.sh — 변경 파일 확장자/경로에 따라 로드할 Deep 룰 카테고리를 출력
# Usage: bash deep-rule-router.sh <file1> [file2] [file3] ...
# Usage: git diff --name-only HEAD~1 | bash deep-rule-router.sh --stdin
#
# Context Engineering Deep 단계 라우팅.
# Check 에이전트가 변경 파일에 따라 관련 룰만 선택 로드하도록 지원.

set -uo pipefail

TRINE_SKILLS="${TRINE_SKILLS:-$HOME/.claude/forge/skills}"
TRINE_RULES="${TRINE_RULES:-$HOME/.claude/forge/rules}"

# ─── ROUTING TABLE ────────────────────────────────────────────────────────
# 파일 패턴 → 로드할 룰 카테고리/파일
#
# Format: pattern|skill_or_rule|glob_or_file
# skill: $TRINE_SKILLS/{skill}/rules/{glob}
# rule:  $TRINE_RULES/{file}

ROUTES=(
    # React/Next.js Frontend
    '*.tsx|skill|react-best-practices/rules/async-*'
    '*.tsx|skill|react-best-practices/rules/bundle-*'
    '*.tsx|skill|react-best-practices/rules/rerender-*'
    '*.tsx|skill|react-best-practices/rules/composition-*'
    '*.jsx|skill|react-best-practices/rules/async-*'
    '*.jsx|skill|react-best-practices/rules/bundle-*'
    '*.jsx|skill|react-best-practices/rules/rerender-*'
    '*.jsx|skill|react-best-practices/rules/composition-*'

    # Page/Layout (Server Components)
    'page.tsx|skill|react-best-practices/rules/server-*'
    'page.tsx|skill|react-best-practices/rules/rendering-*'
    'layout.tsx|skill|react-best-practices/rules/server-*'
    'layout.tsx|skill|react-best-practices/rules/rendering-*'

    # NestJS Backend
    '*.service.ts|rule|forge-performance.md'
    '*.service.ts|rule|forge-observability.md'
    '*.controller.ts|rule|forge-performance.md'
    '*.controller.ts|rule|forge-observability.md'
    '*.module.ts|rule|forge-module-dependency.md'
    '*.entity.ts|rule|forge-performance.md'
    '*.entity.ts|rule|forge-database-operations.md'
    '*.migration.ts|rule|forge-database-operations.md'

    # Tests
    '*.spec.ts|rule|forge-test-quality.md'
    '*.test.ts|rule|forge-test-quality.md'
    '*.e2e-spec.ts|rule|forge-test-quality.md'

    # Code Quality (all code files)
    '*.ts|skill|code-quality-rules/rules/*'
    '*.tsx|skill|code-quality-rules/rules/*'
)

# ─── COLLECT CHANGED FILES ────────────────────────────────────────────────
files=()
if [[ "${1:-}" == "--stdin" ]]; then
    while IFS= read -r line; do
        [[ -n "$line" ]] && files+=("$line")
    done
elif [[ $# -gt 0 ]]; then
    files=("$@")
else
    echo "Usage: deep-rule-router.sh <file1> [file2] ..."
    echo "       git diff --name-only | deep-rule-router.sh --stdin"
    exit 1
fi

# ─── MATCH AND COLLECT ────────────────────────────────────────────────────
declare -A matched_rules=()  # deduplicate (explicit init for set -u)

for file in "${files[@]}"; do
    basename=$(basename "$file")

    for route in "${ROUTES[@]}"; do
        IFS='|' read -r pattern type target <<< "$route"

        # Match: exact basename or glob pattern
        # shellcheck disable=SC2254
        case "$basename" in
            $pattern)
                if [[ "$type" == "skill" ]]; then
                    # Expand glob
                    for rule_file in "$TRINE_SKILLS"/$target; do
                        [[ -f "$rule_file" ]] && matched_rules["$rule_file"]=1
                    done
                elif [[ "$type" == "rule" ]]; then
                    local_path="$TRINE_RULES/$target"
                    [[ -f "$local_path" ]] && matched_rules["$local_path"]=1
                fi
                ;;
        esac
    done
done

# ─── OUTPUT ───────────────────────────────────────────────────────────────
local_count=${#matched_rules[@]}
if [[ $local_count -eq 0 ]]; then
    echo "# No Deep rules matched for given files"
    exit 0
fi

echo "# Deep Rule Router — $local_count rules matched"
echo "# Input: ${#files[@]} changed files"
echo ""

# Group by category
declare -A categories
for rule_path in "${!matched_rules[@]}"; do
    # Extract category from path
    if [[ "$rule_path" == *"/skills/"* ]]; then
        skill=$(echo "$rule_path" | sed 's|.*/skills/||; s|/rules/.*||')
        prefix=$(basename "$rule_path" .md | sed 's/-[^-]*$//')
        cat_key="$skill/$prefix"
    else
        cat_key=$(basename "$rule_path" .md)
    fi
    categories["$cat_key"]="${categories[$cat_key]:-}$rule_path\n"
done

for cat in $(echo "${!categories[@]}" | tr ' ' '\n' | sort); do
    echo "## $cat"
    echo -e "${categories[$cat]}" | sort | while IFS= read -r path; do
        [[ -n "$path" ]] && echo "  $path"
    done
done

echo ""
echo "# Total: $local_count rule files to load"
