#!/usr/bin/env bash
# verify-all.sh — 통합 검증 래퍼
# Usage: bash scripts/verify-all.sh [rules|skills|sigil|all] [--project <name>] [--stage <S1-S4>]
#
# 분산된 검증 도구를 단일 진입점으로 통합한다.
# Agentic Verification 강화를 위한 P0 도구.

set -uo pipefail

BUSINESS_ROOT="${BUSINESS_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/business")}"
SCRIPTS_DIR="$BUSINESS_ROOT/scripts"

# Colors (기존 스크립트와 동일 패턴)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Counters
TOTAL_SECTIONS=0
PASSED_SECTIONS=0
FAILED_SECTIONS=0
WARNING_SECTIONS=0

usage() {
    cat <<'EOF'
Unified Verification Wrapper

Usage:
  verify-all.sh all                              Run all verification checks
  verify-all.sh rules                            Rules audit only
  verify-all.sh skills                           Skills audit only
  verify-all.sh sigil --project <name> --stage <S1-S4>   SIGIL gate check
  verify-all.sh trace --project <name>           SIGIL Wave 2 traceability check

Options:
  --project <name>    SIGIL project name (required for sigil/trace)
  --stage <S1-S4>     SIGIL stage (required for sigil)

Examples:
  verify-all.sh all
  verify-all.sh rules
  verify-all.sh sigil --project baduki --stage S4
  verify-all.sh trace --project portfolio-admin
EOF
}

# ─── SECTION RUNNER ───────────────────────────────────────────────────────
run_section() {
    local name="$1"
    local script="$2"
    shift 2
    local args=("$@")

    echo ""
    echo -e "${CYAN}━━━ [$name] ━━━${NC}"

    TOTAL_SECTIONS=$((TOTAL_SECTIONS + 1))

    if [[ ! -f "$script" ]]; then
        echo -e "  ${YELLOW}SKIP:${NC} $script not found"
        WARNING_SECTIONS=$((WARNING_SECTIONS + 1))
        return
    fi

    local output
    local exit_code
    output=$(bash "$script" "${args[@]}" 2>&1) || exit_code=$?
    exit_code=${exit_code:-0}

    echo "$output" | while IFS= read -r line; do
        echo "  $line"
    done

    if [[ $exit_code -eq 0 ]]; then
        echo -e "  ${GREEN}→ PASS${NC}"
        PASSED_SECTIONS=$((PASSED_SECTIONS + 1))
    elif [[ $exit_code -eq 1 ]]; then
        echo -e "  ${RED}→ FAIL${NC}"
        FAILED_SECTIONS=$((FAILED_SECTIONS + 1))
    else
        echo -e "  ${YELLOW}→ WARNING (exit $exit_code)${NC}"
        WARNING_SECTIONS=$((WARNING_SECTIONS + 1))
    fi
}

# ─── COMMANDS ─────────────────────────────────────────────────────────────
cmd_rules() {
    run_section "Rules Audit" "$SCRIPTS_DIR/manage-rules.sh" audit
}

cmd_skills() {
    run_section "Skills Audit" "$SCRIPTS_DIR/manage-skills.sh" audit
}

cmd_sigil() {
    local project="$1"
    local stage="$2"

    if [[ -z "$project" || -z "$stage" ]]; then
        echo -e "${RED}Error: --project and --stage required for sigil check${NC}"
        exit 1
    fi

    run_section "SIGIL Gate ($project / $stage)" "$SCRIPTS_DIR/sigil-gate-check.sh" "$project" "$stage"
}

cmd_trace() {
    local project="$1"

    if [[ -z "$project" ]]; then
        echo -e "${RED}Error: --project required for trace check${NC}"
        exit 1
    fi

    run_section "SIGIL Wave 2 Traceability ($project)" "$SCRIPTS_DIR/sigil-wave2-trace.sh" "$project"
}

cmd_all() {
    local project="${1:-}"
    local stage="${2:-}"

    cmd_rules
    cmd_skills

    if [[ -n "$project" ]]; then
        if [[ -n "$stage" ]]; then
            cmd_sigil "$project" "$stage"
        fi

        # Wave 2 trace는 S4 산출물이 있을 때만
        if [[ -f "$SCRIPTS_DIR/sigil-wave2-trace.sh" ]]; then
            cmd_trace "$project"
        fi
    fi
}

# ─── SUMMARY ──────────────────────────────────────────────────────────────
print_summary() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════${NC}"
    echo -e "${BOLD}  Verification Summary${NC}"
    echo -e "${BOLD}═══════════════════════════════════════${NC}"
    echo -e "  Total:   $TOTAL_SECTIONS sections"
    echo -e "  ${GREEN}PASS:${NC}    $PASSED_SECTIONS"
    echo -e "  ${RED}FAIL:${NC}    $FAILED_SECTIONS"
    echo -e "  ${YELLOW}WARN:${NC}    $WARNING_SECTIONS"
    echo ""

    if [[ $FAILED_SECTIONS -gt 0 ]]; then
        echo -e "  ${RED}${BOLD}STATUS: FAIL${NC} — $FAILED_SECTIONS section(s) failed"
        return 1
    elif [[ $WARNING_SECTIONS -gt 0 ]]; then
        echo -e "  ${YELLOW}${BOLD}STATUS: WARN${NC} — $WARNING_SECTIONS warning(s)"
        return 0
    else
        echo -e "  ${GREEN}${BOLD}STATUS: PASS${NC} — All checks passed"
        return 0
    fi
}

# ─── ARGUMENT PARSING ─────────────────────────────────────────────────────
main() {
    local cmd="${1:-help}"
    shift || true

    local project=""
    local stage=""

    # Parse named arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --project)
                project="${2:-}"
                shift 2
                ;;
            --stage)
                stage="${2:-}"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    echo -e "${BOLD}╔══════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  Unified Verification — verify-all   ║${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════╝${NC}"

    case "$cmd" in
        all)
            cmd_all "$project" "$stage"
            ;;
        rules)
            cmd_rules
            ;;
        skills)
            cmd_skills
            ;;
        sigil)
            cmd_sigil "$project" "$stage"
            ;;
        trace)
            cmd_trace "$project"
            ;;
        help|--help|-h)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown command: $cmd${NC}"
            usage
            exit 1
            ;;
    esac

    print_summary
}

main "$@"
