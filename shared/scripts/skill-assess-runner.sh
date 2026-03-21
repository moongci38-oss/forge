#!/usr/bin/env bash
# skill-assess-runner.sh — Run skill assessment with Yes/No criteria
# Called by: manage-skills.sh assess <skill-name> [--runs N]
#
# Reads assessment.md → extracts test inputs + criteria →
# runs skill via claude CLI → grades output with Haiku → reports pass_rate

set -euo pipefail

SKILL_NAME="${1:-}"
ASSESSMENT_FILE="${2:-}"
RUNS="${3:-3}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

FORGE_ROOT="${FORGE_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/forge")}"
RESULTS_DIR="/tmp/skill-assess/$SKILL_NAME/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RESULTS_DIR"

# ─── Parse assessment.md ───────────────────────────────────────────────────

parse_inputs() {
    # Extract input_N values from assessment.md
    grep -oP '^\- input_\d+: "(.+)"' "$ASSESSMENT_FILE" | sed 's/^- input_[0-9]*: "//' | sed 's/"$//'
}

parse_criteria() {
    # Extract numbered criteria lines
    local in_criteria=0
    while IFS= read -r line; do
        if [[ "$line" == "## 평가 기준"* ]]; then
            in_criteria=1
            continue
        fi
        if [[ $in_criteria -eq 1 && "$line" == "## "* ]]; then
            break
        fi
        if [[ $in_criteria -eq 1 && "$line" =~ ^[0-9]+\. ]]; then
            echo "$line"
        fi
    done < "$ASSESSMENT_FILE"
}

# ─── Main ──────────────────────────────────────────────────────────────────

echo -e "${CYAN}── Parsing assessment.md ──${NC}"

# Read inputs into array
mapfile -t INPUTS < <(parse_inputs)
INPUT_COUNT=${#INPUTS[@]}

if [ "$INPUT_COUNT" -eq 0 ]; then
    echo -e "${RED}No test inputs found in assessment.md${NC}"
    exit 1
fi

echo -e "  Test inputs: $INPUT_COUNT"

# Read criteria into string
CRITERIA=$(parse_criteria)
CRITERIA_COUNT=$(echo "$CRITERIA" | wc -l)
echo -e "  Criteria: $CRITERIA_COUNT"
echo ""

# ─── Run Assessment ────────────────────────────────────────────────────────

total_runs=0
total_pass=0

for i in "${!INPUTS[@]}"; do
    input="${INPUTS[$i]}"
    input_num=$((i + 1))
    echo -e "${BOLD}── Input $input_num/$INPUT_COUNT ──${NC}"
    echo -e "  \"${input:0:80}...\""

    for run in $(seq 1 "$RUNS"); do
        total_runs=$((total_runs + 1))
        echo -n "  Run $run/$RUNS: "

        output_file="$RESULTS_DIR/output-${input_num}-${run}.txt"
        grade_file="$RESULTS_DIR/grade-${input_num}-${run}.txt"

        # Step 1: Run skill via claude CLI (non-interactive, isolated)
        max_retries=2
        attempt=0
        valid_output=false

        while [ $attempt -lt $max_retries ]; do
            attempt=$((attempt + 1))

            if ! claude -p "/$SKILL_NAME $input" --model sonnet --output-format text \
                --no-session-persistence \
                > "$output_file" 2>/dev/null; then
                echo -e "${RED}EXEC_FAIL (attempt $attempt)${NC}"
                continue
            fi

            # Filter out task notifications and session artifacts
            if [ -f "$output_file" ]; then
                sed -i '/^Also empty/d; /^The task output is no longer/d; /killed before producing/d; /background.*search.*stopped/d; /plan remains valid/d' "$output_file"
            fi

            output_content=$(cat "$output_file" 2>/dev/null | tr -s '[:space:]')
            # Validate output has meaningful content (at least 50 chars, contains plan-like structure)
            if [ ${#output_content} -ge 50 ]; then
                valid_output=true
                break
            fi
        done

        if [ "$valid_output" = false ]; then
            echo -e "${RED}INVALID_OUTPUT (${#output_content} chars after $attempt attempts)${NC}"
            continue
        fi

        # Step 2: Grade with Haiku (assessor-generator separation)
        grade_prompt=$(cat <<GRADE_EOF
아래 출력을 평가하라. 각 기준에 대해 YES 또는 NO만 답하라. 설명 불필요.

## 출력
$output_content

## 평가 기준
$CRITERIA

## 응답 형식 (정확히 이 형식으로, 번호: YES 또는 번호: NO)
GRADE_EOF
)

        if ! echo "$grade_prompt" | claude -p - --model haiku --output-format text \
            --no-session-persistence \
            > "$grade_file" 2>/dev/null; then
            echo -e "${RED}GRADE_FAIL${NC}"
            continue
        fi

        # Step 3: Parse YES/NO results (match "N: YES" or "N: NO" pattern)
        yes_count=$(grep -cP ':\s*YES\s*$' "$grade_file" 2>/dev/null || echo "0")
        no_count=$(grep -cP ':\s*NO\s*$' "$grade_file" 2>/dev/null || echo "0")
        yes_count=$(echo "$yes_count" | tr -d '[:space:]')
        no_count=$(echo "$no_count" | tr -d '[:space:]')

        if [ "$no_count" -eq 0 ] && [ "$yes_count" -ge "$CRITERIA_COUNT" ]; then
            total_pass=$((total_pass + 1))
            echo -e "${GREEN}PASS${NC} ($yes_count/$CRITERIA_COUNT YES)"
        else
            echo -e "${YELLOW}FAIL${NC} ($yes_count/$CRITERIA_COUNT YES, $no_count NO)"
            # Show which criteria failed
            grep -P ':\s*NO\s*$' "$grade_file" 2>/dev/null | head -5 | while read -r line; do
                echo -e "    ${RED}$line${NC}"
            done
        fi
    done
    echo ""
done

# ─── Summary ───────────────────────────────────────────────────────────────

if [ "$total_runs" -gt 0 ]; then
    pass_rate=$(awk "BEGIN {printf \"%.0f\", ($total_pass / $total_runs) * 100}")
else
    pass_rate=0
fi

echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo -e "${BOLD}Assessment Result: $SKILL_NAME${NC}"
echo -e "  Total runs:  $total_runs"
echo -e "  Passed:      $total_pass"
echo -e "  Pass rate:   ${BOLD}${pass_rate}%${NC}"
echo -e "  Results dir: $RESULTS_DIR"
echo -e "${CYAN}══════════════════════════════════════════${NC}"

# Write summary TSV
echo -e "skill\tdate\truns\tpass\trate" > "$RESULTS_DIR/summary.tsv"
echo -e "$SKILL_NAME\t$(date +%Y-%m-%d)\t$total_runs\t$total_pass\t${pass_rate}%" >> "$RESULTS_DIR/summary.tsv"
