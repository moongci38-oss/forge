#!/usr/bin/env bash
# skill-assess-runner.sh — Run skill assessment with Yes/No criteria
# Called by: manage-skills.sh assess <skill-name> [--runs N]
#
# Supports TWO eval formats:
#   1. assessment.md (legacy) — input_N + 평가 기준
#   2. evals/evals.json (official) — evals[].prompt + expectations
#
# Optimized: Batch grading (1 Haiku call instead of N)

set -uo pipefail

SKILL_NAME="${1:-}"
ASSESSMENT_FILE="${2:-}"
RUNS="${3:-3}"
MAX_PARALLEL="${4:-6}"

# Auto-resolve assessment file if not provided
if [ -z "$ASSESSMENT_FILE" ] && [ -n "$SKILL_NAME" ]; then
    FORGE_ROOT_TMP="${FORGE_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/forge")}"
    SKILL_DIR_TMP="$FORGE_ROOT_TMP/.claude/skills/$SKILL_NAME"
    if [ -f "$SKILL_DIR_TMP/assessment.md" ]; then
        ASSESSMENT_FILE="$SKILL_DIR_TMP/assessment.md"
    fi
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

FORGE_ROOT="${FORGE_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/forge")}"
RESULTS_DIR="/tmp/skill-assess/$SKILL_NAME/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$RESULTS_DIR"

# ─── Background process cleanup ───────────────────────────────────────────
declare -a BG_PIDS=()
cleanup_bg() {
    for pid in "${BG_PIDS[@]}"; do
        kill "$pid" 2>/dev/null || true
    done
    wait 2>/dev/null || true
}
trap cleanup_bg EXIT INT TERM

# ─── Parse assessment.md (legacy) ─────────────────────────────────────────

parse_inputs() {
    grep -oP '^\- input_\d+: "(.+)"' "$ASSESSMENT_FILE" | sed 's/^- input_[0-9]*: "//' | sed 's/"$//'
}

parse_criteria() {
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

# ─── Parse evals.json (official) ──────────────────────────────────────────

parse_evals_json() {
    local evals_file="$1"
    python3 -c "
import json, sys
with open('$evals_file') as f:
    data = json.load(f)
for e in data['evals']:
    print(e['prompt'])
"
}

parse_expectations_json() {
    local evals_file="$1"
    python3 -c "
import json
with open('$evals_file') as f:
    data = json.load(f)
# Use expectations from first eval (all evals share same criteria)
for i, exp in enumerate(data['evals'][0]['expectations'], 1):
    print(f'{i}. {exp}')
"
}

# ─── Detect eval format ──────────────────────────────────────────────────

SKILL_DIR="$(dirname "$ASSESSMENT_FILE")"
EVALS_JSON="$SKILL_DIR/evals/evals.json"
EVAL_FORMAT="assessment"

if [ -f "$EVALS_JSON" ]; then
    EVAL_FORMAT="evals_json"
    echo -e "${CYAN}  Format: evals.json (official)${NC}"
fi

# ─── Single execution function (NO grading — grading is batched) ──────────

run_exec_only() {
    local input_num="$1"
    local run="$2"
    local input="$3"

    local output_file="$RESULTS_DIR/output-${input_num}-${run}.txt"
    local timing_file="$RESULTS_DIR/timing-${input_num}-${run}.json"

    local max_retries=2
    local attempt=0
    local valid_output=false
    local output_content=""

    local start_ts=$(date +%s%N)

    while [ $attempt -lt $max_retries ]; do
        attempt=$((attempt + 1))

        if ! timeout --signal=TERM --kill-after=10 180 claude -p --bare "${PROMPT_PREFIX}${input}" --model sonnet --output-format text \
            --no-session-persistence --permission-mode acceptEdits \
            > "$output_file" 2>/dev/null; then
            continue
        fi

        # Filter out task notifications and session artifacts
        if [ -f "$output_file" ]; then
            sed -i '/^Also empty/d; /^The task output is no longer/d; /killed before producing/d; /background.*search.*stopped/d; /plan remains valid/d' "$output_file"
        fi

        output_content=$(cat "$output_file" 2>/dev/null | tr -s '[:space:]')
        if [ ${#output_content} -ge 50 ]; then
            valid_output=true
            break
        fi
    done

    local end_ts=$(date +%s%N)
    local duration_ms=$(( (end_ts - start_ts) / 1000000 ))

    # Write timing
    echo "{\"input\":$input_num,\"run\":$run,\"duration_ms\":$duration_ms,\"valid\":$valid_output,\"attempts\":$attempt}" > "$timing_file"

    if [ "$valid_output" = false ]; then
        echo "EXEC_FAIL" > "$RESULTS_DIR/result-${input_num}-${run}.status"
    fi
}

# ─── Batch grading function (1 Haiku call for all outputs) ────────────────

batch_grade() {
    echo -e "\n${CYAN}── Batch Grading (1 Haiku call) ──${NC}"

    # Collect valid outputs
    local batch_prompt="아래 여러 출력을 평가하라. 각 출력마다 각 기준에 대해 YES 또는 NO만 답하라. 설명 불필요.

## 평가 기준
$CRITERIA

## 응답 형식 (정확히 이 형식으로)
각 출력마다:
Output N: 1=YES/NO, 2=YES/NO, 3=YES/NO, ...

"
    local output_count=0
    local output_keys=()

    for i in "${!INPUTS[@]}"; do
        local input_num=$((i + 1))
        for run in $(seq 1 "$RUNS"); do
            local output_file="$RESULTS_DIR/output-${input_num}-${run}.txt"
            local status_file="$RESULTS_DIR/result-${input_num}-${run}.status"

            # Skip EXEC_FAIL
            if [ -f "$status_file" ] && grep -q "EXEC_FAIL" "$status_file"; then
                continue
            fi

            if [ -f "$output_file" ] && [ -s "$output_file" ]; then
                output_count=$((output_count + 1))
                output_keys+=("${input_num}-${run}")
                local content
                content=$(head -c 3000 "$output_file" | tr -s '[:space:]')
                batch_prompt+="
## Output $output_count (Input ${input_num}, Run ${run})
$content

"
            fi
        done
    done

    if [ "$output_count" -eq 0 ]; then
        echo -e "${RED}No valid outputs to grade${NC}"
        return 1
    fi

    echo -e "  Grading $output_count outputs in 1 call..."

    local batch_grade_file="$RESULTS_DIR/batch-grade.txt"

    if ! echo "$batch_prompt" | timeout --signal=TERM --kill-after=10 180 claude -p --bare - --model haiku --output-format text \
        --no-session-persistence \
        > "$batch_grade_file" 2>/dev/null; then
        echo -e "${YELLOW}Batch grading failed, falling back to individual grading...${NC}"
        fallback_individual_grade
        return $?
    fi

    # Parse batch response
    local parse_success=true
    local idx=0

    for key in "${output_keys[@]}"; do
        idx=$((idx + 1))
        local grade_file="$RESULTS_DIR/grade-${key}.txt"
        local status_file="$RESULTS_DIR/result-${key}.status"

        # Extract line for this output: "Output N: 1=YES, 2=NO, ..."
        local grade_line
        grade_line=$(grep -iP "Output\s*$idx\s*:" "$batch_grade_file" 2>/dev/null | head -1)

        if [ -z "$grade_line" ]; then
            # Try alternate format: just numbered YES/NO after Output N header
            parse_success=false
            continue
        fi

        echo "$grade_line" > "$grade_file"

        # Count YES and NO
        local yes_count no_count
        yes_count=$(echo "$grade_line" | grep -oiP 'YES' | wc -l)
        no_count=$(echo "$grade_line" | grep -oiP 'NO' | wc -l)

        if [ "$no_count" -eq 0 ] && [ "$yes_count" -ge "$CRITERIA_COUNT" ]; then
            echo "PASS" > "$status_file"
        else
            echo "FAIL" > "$status_file"
        fi
    done

    if [ "$parse_success" = false ]; then
        echo -e "${YELLOW}Batch parse incomplete, falling back...${NC}"
        fallback_individual_grade
    fi
}

# ─── Fallback: individual grading (legacy) ────────────────────────────────

fallback_individual_grade() {
    for key in "${output_keys[@]}"; do
        local output_file="$RESULTS_DIR/output-${key}.txt"
        local grade_file="$RESULTS_DIR/grade-${key}.txt"
        local status_file="$RESULTS_DIR/result-${key}.status"

        # Skip already graded or EXEC_FAIL
        if [ -f "$status_file" ]; then
            continue
        fi

        if [ ! -f "$output_file" ] || [ ! -s "$output_file" ]; then
            echo "EXEC_FAIL" > "$status_file"
            continue
        fi

        local output_content
        output_content=$(head -c 3000 "$output_file" | tr -s '[:space:]')

        local grade_prompt
        grade_prompt=$(cat <<GRADE_EOF
아래 출력을 평가하라. 각 기준에 대해 YES 또는 NO만 답하라. 설명 불필요.

## 출력
$output_content

## 평가 기준
$CRITERIA

## 응답 형식 (정확히 이 형식으로, 번호: YES 또는 번호: NO)
GRADE_EOF
)

        if ! echo "$grade_prompt" | timeout --signal=TERM --kill-after=10 180 claude -p --bare - --model haiku --output-format text \
            --no-session-persistence \
            > "$grade_file" 2>/dev/null; then
            echo "ERROR" > "$status_file"
            continue
        fi

        local yes_count no_count
        yes_count=$(grep -cP '[.:)]\s*YES\s*$' "$grade_file" 2>/dev/null || echo "0")
        no_count=$(grep -cP '[.:)]\s*NO\s*$' "$grade_file" 2>/dev/null || echo "0")
        yes_count=$(echo "$yes_count" | tr -d '[:space:]')
        no_count=$(echo "$no_count" | tr -d '[:space:]')

        if [ "$no_count" -eq 0 ] && [ "$yes_count" -ge "$CRITERIA_COUNT" ]; then
            echo "PASS" > "$status_file"
        else
            echo "FAIL" > "$status_file"
        fi
    done
}

# ─── Main ──────────────────────────────────────────────────────────────────

echo -e "${CYAN}── Parsing eval source ──${NC}"

# Read inputs and criteria based on format
if [ "$EVAL_FORMAT" = "evals_json" ]; then
    mapfile -t INPUTS < <(parse_evals_json "$EVALS_JSON")
    CRITERIA=$(parse_expectations_json "$EVALS_JSON")
else
    mapfile -t INPUTS < <(parse_inputs)
    CRITERIA=$(parse_criteria)
fi

INPUT_COUNT=${#INPUTS[@]}

if [ "$INPUT_COUNT" -eq 0 ]; then
    echo -e "${RED}No test inputs found${NC}"
    exit 1
fi

CRITERIA_COUNT=$(echo "$CRITERIA" | wc -l)
echo -e "  Test inputs: $INPUT_COUNT"
echo -e "  Criteria: $CRITERIA_COUNT"
echo -e "  Parallel: $MAX_PARALLEL"

# Detect test-method from frontmatter
TEST_METHOD=$(grep -m1 'test-method:' "$ASSESSMENT_FILE" 2>/dev/null | sed 's/.*test-method:\s*//' | tr -d '[:space:]')
if [ "$TEST_METHOD" = "indirect-via-prompt" ]; then
    PROMPT_PREFIX=""
    echo -e "  Mode: indirect (no slash prefix)"
else
    PROMPT_PREFIX="/$SKILL_NAME "
fi
echo ""

# Export variables needed by run_exec_only
export RESULTS_DIR RUNS PROMPT_PREFIX

# ─── Phase 1: Execute all runs in parallel ─────────────────────────────────

echo -e "${BOLD}── Phase 1: Execution (parallel) ──${NC}"

declare -a all_pids=()

for i in "${!INPUTS[@]}"; do
    input="${INPUTS[$i]}"
    input_num=$((i + 1))

    for run in $(seq 1 "$RUNS"); do
        # Concurrency limiter
        while [ ${#all_pids[@]} -ge "$MAX_PARALLEL" ]; do
            local_finished=false
            for idx in "${!all_pids[@]}"; do
                if ! kill -0 "${all_pids[$idx]}" 2>/dev/null; then
                    wait "${all_pids[$idx]}" 2>/dev/null || true
                    unset 'all_pids[$idx]'
                    all_pids=("${all_pids[@]}")
                    local_finished=true
                    break
                fi
            done
            if [ "$local_finished" = false ]; then
                sleep 0.5
            fi
        done

        run_exec_only "$input_num" "$run" "$input" &
        pid=$!
        all_pids+=("$pid")
        BG_PIDS+=("$pid")
    done
done

# Wait for all executions to finish
for pid in "${all_pids[@]}"; do
    wait "$pid" 2>/dev/null || true
done

echo -e "  All $((INPUT_COUNT * RUNS)) executions complete."

# ─── Phase 2: Batch grade all outputs (1 Haiku call) ──────────────────────

echo -e "\n${BOLD}── Phase 2: Batch Grading ──${NC}"
batch_grade

# ─── Display results ──────────────────────────────────────────────────────

echo ""
for i in "${!INPUTS[@]}"; do
    input="${INPUTS[$i]}"
    input_num=$((i + 1))
    echo -e "${BOLD}── Input $input_num/$INPUT_COUNT ──${NC}"
    echo -e "  \"${input:0:80}...\""

    for run in $(seq 1 "$RUNS"); do
        status_file="$RESULTS_DIR/result-${input_num}-${run}.status"
        grade_file="$RESULTS_DIR/grade-${input_num}-${run}.txt"
        timing_file="$RESULTS_DIR/timing-${input_num}-${run}.json"

        status="UNKNOWN"
        [ -f "$status_file" ] && status=$(cat "$status_file")

        duration=""
        if [ -f "$timing_file" ]; then
            duration=$(grep -oP '"duration_ms":\s*\K[0-9]+' "$timing_file" 2>/dev/null)
            [ -n "$duration" ] && duration=" (${duration}ms)"
        fi

        case "$status" in
            PASS)
                echo -e "  Run $run/$RUNS: ${GREEN}PASS${NC} ($CRITERIA_COUNT/$CRITERIA_COUNT YES)$duration"
                ;;
            FAIL)
                grade_info=""
                if [ -f "$grade_file" ]; then
                    no_items=$(grep -oiP 'NO' "$grade_file" 2>/dev/null | wc -l)
                    yes_items=$(grep -oiP 'YES' "$grade_file" 2>/dev/null | wc -l)
                    grade_info=" ($yes_items/$CRITERIA_COUNT YES, $no_items NO)"
                fi
                echo -e "  Run $run/$RUNS: ${YELLOW}FAIL${NC}$grade_info$duration"
                ;;
            EXEC_FAIL)
                echo -e "  Run $run/$RUNS: ${RED}EXEC_FAIL${NC}$duration"
                ;;
            *)
                echo -e "  Run $run/$RUNS: ${RED}$status${NC}$duration"
                ;;
        esac
    done
    echo ""
done

# ─── Summary + benchmark.json ─────────────────────────────────────────────

total_runs=$(find "$RESULTS_DIR" -name "result-*.status" 2>/dev/null | wc -l)
total_runs=$(echo "$total_runs" | tr -d '[:space:]')
total_pass=$(grep -rl "^PASS$" "$RESULTS_DIR"/result-*.status 2>/dev/null | wc -l)
total_pass=$(echo "${total_pass:-0}" | tr -d '[:space:]')
total_fail=$(grep -rl "^FAIL$" "$RESULTS_DIR"/result-*.status 2>/dev/null | wc -l)
total_fail=$(echo "${total_fail:-0}" | tr -d '[:space:]')
total_error=$(grep -rl "^EXEC_FAIL\|^ERROR$" "$RESULTS_DIR"/result-*.status 2>/dev/null | wc -l)
total_error=$(echo "${total_error:-0}" | tr -d '[:space:]')
[ -z "$total_pass" ] && total_pass=0
[ -z "$total_fail" ] && total_fail=0
[ -z "$total_error" ] && total_error=0

if [ "$total_runs" -gt 0 ]; then
    pass_rate=$(awk "BEGIN {printf \"%.0f\", ($total_pass / $total_runs) * 100}")
else
    pass_rate=0
fi

# Calculate total timing
total_duration_ms=0
for tf in "$RESULTS_DIR"/timing-*.json; do
    [ -f "$tf" ] || continue
    d=$(grep -oP '"duration_ms":\s*\K[0-9]+' "$tf" 2>/dev/null || echo "0")
    total_duration_ms=$((total_duration_ms + d))
done
total_duration_s=$((total_duration_ms / 1000))

echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo -e "${BOLD}Assessment Result: $SKILL_NAME${NC}"
echo -e "  Total runs:  $total_runs"
echo -e "  Passed:      $total_pass"
echo -e "  Failed:      $total_fail"
echo -e "  Errors:      $total_error"
echo -e "  Pass rate:   ${BOLD}${pass_rate}%${NC}"
echo -e "  Total time:  ${total_duration_s}s"
echo -e "  Results dir: $RESULTS_DIR"
echo -e "${CYAN}══════════════════════════════════════════${NC}"

# Write summary TSV
echo -e "skill\tdate\truns\tpass\trate\ttime_s" > "$RESULTS_DIR/summary.tsv"
echo -e "$SKILL_NAME\t$(date +%Y-%m-%d)\t$total_runs\t$total_pass\t${pass_rate}%\t${total_duration_s}" >> "$RESULTS_DIR/summary.tsv"

# Write benchmark.json (official format)
cat > "$RESULTS_DIR/benchmark.json" <<BENCH_EOF
{
  "metadata": {
    "skill_name": "$SKILL_NAME",
    "eval_format": "$EVAL_FORMAT",
    "timestamp": "$(date -Iseconds)",
    "runs_per_input": $RUNS,
    "input_count": $INPUT_COUNT,
    "criteria_count": $CRITERIA_COUNT
  },
  "summary": {
    "total_runs": $total_runs,
    "passed": $total_pass,
    "failed": $total_fail,
    "errors": $total_error,
    "pass_rate": $(awk "BEGIN {printf \"%.4f\", $total_pass / ($total_runs > 0 ? $total_runs : 1)}"),
    "total_duration_ms": $total_duration_ms
  }
}
BENCH_EOF
