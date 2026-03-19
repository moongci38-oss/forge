#!/usr/bin/env bash
# forge-telemetry.sh — usage.log JSONL 집계 CLI
# Usage: bash forge-telemetry.sh summary [--days N] [--log <path>]
#        bash forge-telemetry.sh checks  [--days N] [--log <path>]
#        bash forge-telemetry.sh raw     [--days N] [--log <path>]
#
# usage-logger.sh 훅이 기록한 JSONL 데이터를 집계하여
# 규칙/스킬 사용 현황과 Check 통과율을 측정한다.

set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Defaults
DAYS=7
LOG_FILE="${PWD}/.claude/usage.log"

# ─── USAGE ───────────────────────────────────────────────────────────────────

usage() {
    cat <<'EOF'
Forge Dev Telemetry — usage.log 집계 CLI

Usage:
  forge-telemetry.sh summary [--days N] [--log <path>]    도구 사용 빈도 + Check 통과율
  forge-telemetry.sh checks  [--days N] [--log <path>]    Check 결과(PASS/FAIL) 상세
  forge-telemetry.sh raw     [--days N] [--log <path>]    필터링된 JSONL 원본 출력

Options:
  --days N    기간 필터 (기본: 7일)
  --log PATH  로그 파일 경로 (기본: .claude/usage.log)
  --help      이 도움말 표시
EOF
}

# ─── HELPERS ─────────────────────────────────────────────────────────────────

# Date N days ago (GNU date)
date_cutoff() {
    local days="$1"
    if date -u -d "$days days ago" +%Y-%m-%d 2>/dev/null; then
        return
    fi
    # macOS fallback
    date -u -v-"${days}d" +%Y-%m-%d 2>/dev/null || date -u +%Y-%m-%d
}

# Filter JSONL lines by date cutoff
filter_by_date() {
    local cutoff="$1"
    local log="$2"
    while IFS= read -r line; do
        local ts
        ts=$(echo "$line" | grep -o '"ts":"[^"]*"' | head -1 | sed 's/"ts":"//;s/"$//')
        [[ -z "$ts" ]] && continue
        # Compare YYYY-MM-DD prefix
        local ts_date="${ts:0:10}"
        [[ "$ts_date" > "$cutoff" || "$ts_date" == "$cutoff" ]] && echo "$line"
    done < "$log"
}

# Draw bar chart
# Usage: bar_chart "label" count max_count
bar_chart() {
    local label="$1"
    local count="$2"
    local max_count="$3"
    local max_width=30

    local bar_len=0
    if [[ $max_count -gt 0 ]]; then
        bar_len=$(( count * max_width / max_count ))
        [[ $bar_len -lt 1 && $count -gt 0 ]] && bar_len=1
    fi

    local bar=""
    for (( i=0; i<bar_len; i++ )); do
        bar+="█"
    done

    printf "  %-22s ${GREEN}%-${max_width}s${NC}  %d\n" "$label" "$bar" "$count"
}

# ─── COMMANDS ────────────────────────────────────────────────────────────────

cmd_summary() {
    local cutoff
    cutoff=$(date_cutoff "$DAYS")
    local today
    today=$(date -u +%Y-%m-%d)

    echo -e "${BOLD}=== Forge Dev Usage Telemetry ===${NC}"
    echo -e "Period: ${CYAN}$cutoff${NC} ~ ${CYAN}$today${NC} ($DAYS days)"
    echo ""

    # Filter events
    local filtered
    filtered=$(filter_by_date "$cutoff" "$LOG_FILE")

    if [[ -z "$filtered" ]]; then
        echo -e "  ${YELLOW}No events in the specified period.${NC}"
        return
    fi

    local total
    total=$(echo "$filtered" | wc -l)

    # Tool usage counts
    local agent_count skill_count check_count
    agent_count=$(echo "$filtered" | grep -c '"tool":"Agent"' || true)
    skill_count=$(echo "$filtered" | grep -c '"tool":"Skill"' || true)
    check_count=$(echo "$filtered" | grep -c '"event":"check_run"' || true)

    local max_tool=$agent_count
    [[ $skill_count -gt $max_tool ]] && max_tool=$skill_count
    [[ $check_count -gt $max_tool ]] && max_tool=$check_count

    echo -e "${BOLD}[Tool Usage]${NC}"
    bar_chart "Agent" "$agent_count" "$max_tool"
    bar_chart "Skill" "$skill_count" "$max_tool"
    bar_chart "Check" "$check_count" "$max_tool"
    echo ""

    # Top skills/agents by name
    local names
    names=$(echo "$filtered" | grep -o '"name":"[^"]*"' | sed 's/"name":"//;s/"$//' | grep -v '^unknown$' | sort | uniq -c | sort -rn | head -10)

    if [[ -n "$names" ]]; then
        echo -e "${BOLD}[Top Skills/Agents]${NC}"
        while IFS= read -r line; do
            local cnt name
            cnt=$(echo "$line" | awk '{print $1}')
            name=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ *//')
            printf "  %-30s %d\n" "$name" "$cnt"
        done <<< "$names"
        echo ""
    fi

    # Check results
    if [[ $check_count -gt 0 ]]; then
        local pass_count fail_count
        pass_count=$(echo "$filtered" | grep '"event":"check_run"' | grep -ci 'pass' || true)
        fail_count=$(echo "$filtered" | grep '"event":"check_run"' | grep -ci 'fail' || true)

        local max_check=$pass_count
        [[ $fail_count -gt $max_check ]] && max_check=$fail_count

        echo -e "${BOLD}[Check Results]${NC}"
        printf "  %-22s " "PASS"
        local bar_len=0
        [[ $max_check -gt 0 ]] && bar_len=$(( pass_count * 30 / max_check ))
        local bar=""
        for (( i=0; i<bar_len; i++ )); do bar+="█"; done
        printf "${GREEN}%-30s${NC}  %d\n" "$bar" "$pass_count"

        printf "  %-22s " "FAIL"
        bar_len=0
        [[ $max_check -gt 0 ]] && bar_len=$(( fail_count * 30 / max_check ))
        bar=""
        for (( i=0; i<bar_len; i++ )); do bar+="█"; done
        printf "${RED}%-30s${NC}  %d\n" "$bar" "$fail_count"
        echo ""
    fi

    echo -e "Total events: ${BOLD}$total${NC}"
}

cmd_checks() {
    local cutoff
    cutoff=$(date_cutoff "$DAYS")
    local today
    today=$(date -u +%Y-%m-%d)

    echo -e "${BOLD}=== Check Results ===${NC}"
    echo -e "Period: ${CYAN}$cutoff${NC} ~ ${CYAN}$today${NC}"
    echo ""

    local filtered
    filtered=$(filter_by_date "$cutoff" "$LOG_FILE")
    local checks
    checks=$(echo "$filtered" | grep '"event":"check_run"' || true)

    if [[ -z "$checks" ]]; then
        echo -e "  ${YELLOW}No check events in the specified period.${NC}"
        return
    fi

    local pass_count fail_count
    pass_count=$(echo "$checks" | grep -ci 'pass' || true)
    fail_count=$(echo "$checks" | grep -ci 'fail' || true)

    echo -e "  PASS: ${GREEN}${pass_count}${NC}    FAIL: ${RED}${fail_count}${NC}"
    echo ""

    echo -e "${BOLD}[Details]${NC}"
    echo "$checks" | while IFS= read -r line; do
        local ts tool result
        ts=$(echo "$line" | grep -o '"ts":"[^"]*"' | head -1 | sed 's/"ts":"//;s/"$//')
        tool=$(echo "$line" | grep -o '"tool":"[^"]*"' | head -1 | sed 's/"tool":"//;s/"$//')
        result=$(echo "$line" | grep -o '"result":"[^"]*"' | head -1 | sed 's/"result":"//;s/"$//')

        local result_color="$NC"
        if echo "$result" | grep -qi 'pass'; then
            result_color="$GREEN"
        elif echo "$result" | grep -qi 'fail'; then
            result_color="$RED"
        fi

        echo -e "  $ts  $tool  ${result_color}${result}${NC}"
    done
}

cmd_raw() {
    local cutoff
    cutoff=$(date_cutoff "$DAYS")

    local filtered
    filtered=$(filter_by_date "$cutoff" "$LOG_FILE")

    if [[ -z "$filtered" ]]; then
        echo -e "${YELLOW}No events in the specified period.${NC}"
        return
    fi

    echo "$filtered"
}

# ─── ARG PARSING ─────────────────────────────────────────────────────────────

COMMAND="${1:-}"
[[ -n "$COMMAND" ]] && shift

# Parse remaining args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --days)
            DAYS="${2:-7}"
            shift 2
            ;;
        --log)
            LOG_FILE="${2:-}"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option:${NC} $1"
            usage
            exit 1
            ;;
    esac
done

# Validate log file
if [[ ! -f "$LOG_FILE" ]]; then
    echo -e "${YELLOW}No usage data found at:${NC} $LOG_FILE"
    exit 0
fi

# ─── MAIN ────────────────────────────────────────────────────────────────────

case "$COMMAND" in
    summary)
        cmd_summary
        ;;
    checks)
        cmd_checks
        ;;
    raw)
        cmd_raw
        ;;
    --help|-h|"")
        usage
        ;;
    *)
        echo -e "${RED}Unknown command:${NC} $COMMAND"
        usage
        exit 1
        ;;
esac
