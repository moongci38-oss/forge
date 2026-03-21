#!/usr/bin/env bash
# skill-autoresearch.sh — Autonomous skill improvement loop
# Inspired by Karpathy's AutoResearch pattern
#
# Usage:
#   bash skill-autoresearch.sh <skill-name> [options]
#
# Options:
#   --iterations N     Max iterations (default: 10)
#   --budget N         Max cost in dollars (default: 5) — approximate
#   --target-rate N    Target pass rate 0-100 (default: 90)
#   --dry-run          Assess only, don't modify SKILL.md
#   --runs N           Runs per assessment (default: 3)

set -euo pipefail

FORGE_ROOT="${FORGE_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/forge")}"

# ─── Colors ────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Args ──────────────────────────────────────────────────────────────────
SKILL_NAME="${1:-}"
shift || true

MAX_ITERATIONS=10
BUDGET=5
TARGET_RATE=90
DRY_RUN=false
RUNS=3

while [[ $# -gt 0 ]]; do
    case "$1" in
        --iterations) MAX_ITERATIONS="$2"; shift 2 ;;
        --budget) BUDGET="$2"; shift 2 ;;
        --target-rate) TARGET_RATE="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --runs) RUNS="$2"; shift 2 ;;
        *) shift ;;
    esac
done

if [ -z "$SKILL_NAME" ]; then
    echo -e "${RED}Usage: skill-autoresearch.sh <skill-name> [--iterations N] [--budget N] [--target-rate N] [--dry-run]${NC}"
    exit 1
fi

# ─── Find skill ────────────────────────────────────────────────────────────
SKILL_DIR="$FORGE_ROOT/.claude/skills/$SKILL_NAME"
SKILL_MD="$SKILL_DIR/SKILL.md"
ASSESSMENT_MD="$SKILL_DIR/assessment.md"
LOG_FILE="$SKILL_DIR/autoresearch-log.tsv"

if [ ! -f "$SKILL_MD" ]; then
    echo -e "${RED}SKILL.md not found: $SKILL_MD${NC}"
    exit 1
fi

if [ ! -f "$ASSESSMENT_MD" ]; then
    echo -e "${RED}assessment.md not found: $ASSESSMENT_MD${NC}"
    echo -e "${YELLOW}Run: manage-skills.sh assess $SKILL_NAME first${NC}"
    exit 1
fi

# ─── Init log ──────────────────────────────────────────────────────────────
if [ ! -f "$LOG_FILE" ]; then
    echo -e "iteration\tdate\tpass_rate\tdelta\tstatus\tchange_description" > "$LOG_FILE"
fi

echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  AutoResearch: $SKILL_NAME${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║  Max iterations: $MAX_ITERATIONS${NC}"
echo -e "${CYAN}║  Budget: \$$BUDGET${NC}"
echo -e "${CYAN}║  Target rate: ${TARGET_RATE}%${NC}"
echo -e "${CYAN}║  Dry run: $DRY_RUN${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ─── Assess function ──────────────────────────────────────────────────────
run_assessment() {
    local output
    output=$(bash "$FORGE_ROOT/shared/scripts/manage-skills.sh" assess "$SKILL_NAME" --runs "$RUNS" 2>&1)
    echo "$output"
    # Extract pass rate from output
    echo "$output" | grep -oP '[0-9]+(?=%)' || echo "0"
}

get_pass_rate() {
    local output="$1"
    echo "$output" | grep -oP '[0-9]+(?=%)' || echo "0"
}

# ─── Estimate cost (rough) ─────────────────────────────────────────────────
# ~$0.05 per assessment run (Sonnet generate + Haiku grade)
# ~$0.03 per improvement request (Sonnet)
estimated_cost=0
cost_per_iteration=$(awk "BEGIN {printf \"%.2f\", ($RUNS * 3 * 0.05) + 0.03}")

# ─── Baseline ─────────────────────────────────────────────────────────────
echo -e "${BOLD}── Baseline Assessment ──${NC}"
baseline_output=$(bash "$FORGE_ROOT/shared/scripts/manage-skills.sh" assess "$SKILL_NAME" --runs "$RUNS" 2>&1 || true)
echo "$baseline_output"

baseline_rate=$(echo "$baseline_output" | grep -oP '[0-9]+(?=%)' || echo "0")
echo ""
echo -e "${BOLD}Baseline pass rate: ${baseline_rate}%${NC}"

# Log baseline
echo -e "0\t$(date +%Y-%m-%d)\t${baseline_rate}%\t0\tbaseline\tinitial measurement" >> "$LOG_FILE"

if [ "$baseline_rate" -ge "$TARGET_RATE" ]; then
    echo -e "${GREEN}Target ${TARGET_RATE}% already met! No improvement needed.${NC}"
    exit 0
fi

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Dry run mode — stopping after baseline assessment.${NC}"
    exit 0
fi

# ─── Improvement Loop ─────────────────────────────────────────────────────
current_rate="$baseline_rate"
best_rate="$baseline_rate"

for iteration in $(seq 1 "$MAX_ITERATIONS"); do
    echo ""
    echo -e "${CYAN}════ Iteration $iteration/$MAX_ITERATIONS ════${NC}"

    # Budget check
    estimated_cost=$(awk "BEGIN {printf \"%.2f\", $estimated_cost + $cost_per_iteration}")
    if (( $(awk "BEGIN {print ($estimated_cost > $BUDGET) ? 1 : 0}") )); then
        echo -e "${YELLOW}Budget limit \$$BUDGET reached (estimated: \$$estimated_cost). Stopping.${NC}"
        echo -e "$iteration\t$(date +%Y-%m-%d)\t${current_rate}%\t0\tbudget_stop\tbudget limit reached" >> "$LOG_FILE"
        break
    fi

    # Step 1: Read current SKILL.md + failed criteria from last assessment
    current_skill=$(cat "$SKILL_MD")
    criteria=$(grep -E '^[0-9]+\.' "$ASSESSMENT_MD" || true)

    # Collect failure info from last assessment results dir
    last_results_dir=$(ls -dt /tmp/skill-assess/"$SKILL_NAME"/*/ 2>/dev/null | head -1 || true)
    failure_info=""
    if [ -n "$last_results_dir" ]; then
        for grade_file in "$last_results_dir"/grade-*.txt; do
            [ -f "$grade_file" ] || continue
            no_lines=$(grep -i "NO" "$grade_file" 2>/dev/null || true)
            if [ -n "$no_lines" ]; then
                failure_info="${failure_info}\n--- $(basename "$grade_file") ---\n${no_lines}"
            fi
        done
    fi

    # Step 2: Ask Claude for ONE improvement
    echo -e "  Requesting improvement suggestion..."
    improvement_prompt=$(cat <<IMPROVE_EOF
당신은 Claude Code 스킬 프롬프트 최적화 전문가입니다.

아래 스킬의 SKILL.md를 분석하고, 평가 기준에서 실패한 패턴을 해결하기 위해 **정확히 1가지 변경**만 제안하세요.

## 현재 SKILL.md
$current_skill

## 평가 기준 (이 기준으로 채점됨)
$criteria

## 최근 실패 패턴
$failure_info

## 규칙
- 정확히 1가지 변경만 제안 (여러 변경 금지)
- SKILL.md 전체를 출력하되, 변경된 부분을 명확히 표시
- frontmatter(---로 감싼 부분)의 name, description은 수정하지 않음
- 변경 이유를 1줄로 설명

## 출력 형식
CHANGE_REASON: {1줄 변경 이유}
---MODIFIED_SKILL_START---
{수정된 SKILL.md 전체 내용}
---MODIFIED_SKILL_END---
IMPROVE_EOF
)

    improvement_file="$SKILL_DIR/.autoresearch-suggestion.tmp"
    if ! echo "$improvement_prompt" | claude -p - --model sonnet --output-format text \
        > "$improvement_file" 2>/dev/null; then
        echo -e "  ${RED}Improvement request failed. Skipping iteration.${NC}"
        echo -e "$iteration\t$(date +%Y-%m-%d)\t${current_rate}%\t0\terror\timprovement request failed" >> "$LOG_FILE"
        continue
    fi

    # Step 3: Extract change reason and modified SKILL.md
    change_reason=$(grep "^CHANGE_REASON:" "$improvement_file" | sed 's/^CHANGE_REASON: //' | head -1 || echo "unknown")
    modified_skill=$(sed -n '/---MODIFIED_SKILL_START---/,/---MODIFIED_SKILL_END---/p' "$improvement_file" \
        | grep -v "MODIFIED_SKILL" || true)

    if [ -z "$modified_skill" ]; then
        echo -e "  ${YELLOW}Could not extract modified SKILL.md. Skipping.${NC}"
        echo -e "$iteration\t$(date +%Y-%m-%d)\t${current_rate}%\t0\tparse_error\tcould not extract suggestion" >> "$LOG_FILE"
        continue
    fi

    echo -e "  Change: $change_reason"

    # Step 4: Backup + Apply
    cp "$SKILL_MD" "$SKILL_MD.bak"
    echo "$modified_skill" > "$SKILL_MD"

    # Step 5: Re-assess
    echo -e "  Re-assessing..."
    new_output=$(bash "$FORGE_ROOT/shared/scripts/manage-skills.sh" assess "$SKILL_NAME" --runs "$RUNS" 2>&1 || true)
    new_rate=$(echo "$new_output" | grep -oP '[0-9]+(?=%)' || echo "0")
    delta=$((new_rate - current_rate))

    # Step 6: Keep or Revert
    if [ "$new_rate" -gt "$current_rate" ]; then
        echo -e "  ${GREEN}KEEP: ${current_rate}% → ${new_rate}% (+${delta}%)${NC}"
        current_rate="$new_rate"
        if [ "$new_rate" -gt "$best_rate" ]; then
            best_rate="$new_rate"
        fi
        rm -f "$SKILL_MD.bak"
        echo -e "$iteration\t$(date +%Y-%m-%d)\t${new_rate}%\t+${delta}\tkeep\t$change_reason" >> "$LOG_FILE"
    else
        echo -e "  ${RED}REVERT: ${new_rate}% (no improvement, delta=${delta})${NC}"
        cp "$SKILL_MD.bak" "$SKILL_MD"
        rm -f "$SKILL_MD.bak"
        echo -e "$iteration\t$(date +%Y-%m-%d)\t${new_rate}%\t${delta}\trevert\t$change_reason" >> "$LOG_FILE"
    fi

    # Step 7: Check target
    if [ "$current_rate" -ge "$TARGET_RATE" ]; then
        echo -e ""
        echo -e "${GREEN}Target ${TARGET_RATE}% reached! Current: ${current_rate}%${NC}"
        echo -e "$iteration\t$(date +%Y-%m-%d)\t${current_rate}%\t0\ttarget_reached\ttarget pass rate met" >> "$LOG_FILE"
        break
    fi

    # Cleanup temp
    rm -f "$improvement_file"
done

# ─── Final Summary ────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  AutoResearch Complete: $SKILL_NAME${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║  Baseline:     ${baseline_rate}%${NC}"
echo -e "${CYAN}║  Final:        ${current_rate}%${NC}"
echo -e "${CYAN}║  Best:         ${best_rate}%${NC}"
echo -e "${CYAN}║  Improvement:  $((current_rate - baseline_rate))%${NC}"
echo -e "${CYAN}║  Est. cost:    \$$estimated_cost${NC}"
echo -e "${CYAN}║  Log:          $LOG_FILE${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
