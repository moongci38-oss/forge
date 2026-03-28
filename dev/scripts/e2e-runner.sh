#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# e2e-runner.sh - Universal E2E Pipeline Runner
# =============================================================================
# Forge Dev-independent runner. Works standalone or via verify.sh e2e.
#
# Usage:
#   bash ${FORGE_ROOT:-$HOME/forge}/dev/scripts/e2e-runner.sh                    # local env
#   bash ${FORGE_ROOT:-$HOME/forge}/dev/scripts/e2e-runner.sh --env staging      # staging env
#   bash ${FORGE_ROOT:-$HOME/forge}/dev/scripts/e2e-runner.sh --grep "login"     # filter tests
#   bash ${FORGE_ROOT:-$HOME/forge}/dev/scripts/e2e-runner.sh --project-root /x  # explicit root
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=e2e-lib.sh
source "$SCRIPT_DIR/e2e-lib.sh"

# ── Argument parsing ──
ENV_NAME="local"
PROJECT_ROOT=""
EXTRA_ARGS=()

while [ $# -gt 0 ]; do
    case "$1" in
        --env)        ENV_NAME="$2"; shift 2 ;;
        --project-root) PROJECT_ROOT="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: $(basename "$0") [--env local|staging] [--project-root <path>] [--grep <pattern>] [playwright args...]"
            echo ""
            echo "Options:"
            echo "  --env <name>          Environment profile (default: local)"
            echo "  --project-root <path> Project root directory (default: auto-detect)"
            echo "  --grep <pattern>      Pass through to Playwright for test filtering"
            echo "  --help                Show this help"
            exit 0
            ;;
        *)            EXTRA_ARGS+=("$1"); shift ;;
    esac
done

# ── Phase 0: Init ──
echo -e "${BOLD}${CYAN}========================================${NC}"
echo -e "${BOLD}${CYAN}  E2E Pipeline Runner (env: $ENV_NAME)${NC}"
echo -e "${BOLD}${CYAN}========================================${NC}"
echo ""

# Auto-detect project root
if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT="$(pwd)"
    # Walk up to find e2e-pipeline.json
    while [ "$PROJECT_ROOT" != "/" ]; do
        [ -f "$PROJECT_ROOT/e2e-pipeline.json" ] && break
        PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
    done
    if [ "$PROJECT_ROOT" = "/" ]; then
        echo -e "${RED}e2e-pipeline.json not found. Run from project root or use --project-root.${NC}"
        exit 1
    fi
fi

cd "$PROJECT_ROOT"
CONFIG_FILE="$PROJECT_ROOT/e2e-pipeline.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Config not found: $CONFIG_FILE${NC}"
    exit 1
fi

echo -e "${CYAN}[Phase 0]${NC} Init"
echo "  Project root: $PROJECT_ROOT"
echo "  Config: $CONFIG_FILE"
echo "  Environment: $ENV_NAME"

# Parse config using python3
read_config() {
    python3 -c "
import json, sys
with open('$CONFIG_FILE') as f:
    data = json.load(f)
keys = sys.argv[1].split('.')
val = data
for k in keys:
    if val is None or not isinstance(val, dict):
        print('')
        sys.exit(0)
    val = val.get(k)
if val is None:
    print('null')
elif isinstance(val, (dict, list)):
    print(json.dumps(val))
elif isinstance(val, bool):
    print('true' if val else 'false')
else:
    print(val)
" "$1" 2>/dev/null
}

# Load config values
PROJECT_NAME=$(read_config "project.name")
PKG_MANAGER=$(read_config "project.packageManager")

BACKEND_CFG=$(read_config "environments.$ENV_NAME.backend")
CACHE_CFG=$(read_config "environments.$ENV_NAME.cache")
E2E_RUN_CMD=$(read_config "environments.$ENV_NAME.e2e.runCommand")
E2E_BASE_URL=$(read_config "environments.$ENV_NAME.e2e.baseURL")
ENV_FILE=$(read_config "envFile")

echo "  Project: $PROJECT_NAME ($PKG_MANAGER)"
echo ""

# NVM init
nvm_init

# Load env file
if [ -n "$ENV_FILE" ] && [ "$ENV_FILE" != "null" ]; then
    load_env_file "$PROJECT_ROOT/$ENV_FILE"
fi

# ── Tracking variables ──
API_PID=""
HOOKS_DIR="$PROJECT_ROOT/scripts/e2e-hooks"

cleanup() {
    echo ""
    echo -e "${YELLOW}[CLEANUP]${NC} Stopping background processes..."
    if [ -n "$API_PID" ] && ps -p "$API_PID" > /dev/null 2>&1; then
        kill -- -"$API_PID" 2>/dev/null || kill "$API_PID" 2>/dev/null || true
        echo "  API server (PID $API_PID) stopped"
    fi
    # Clean up backend port if configured
    if [ "$BACKEND_CFG" != "null" ] && [ -n "$BACKEND_CFG" ]; then
        local port
        port=$(read_config "environments.$ENV_NAME.backend.port")
        if [ -n "$port" ] && [ "$port" != "null" ]; then
            cleanup_port "$port"
        fi
    fi
}

trap cleanup EXIT

# ── Phase 1: Hooks (pre-infra) ──
echo -e "${CYAN}[Phase 1]${NC} Pre-infrastructure hooks"
run_hook "pre-infra" "$HOOKS_DIR"
echo ""

# ── Phase 2: Prerequisites ──
echo -e "${CYAN}[Phase 2]${NC} Prerequisites"

# Package manager check
if ! command -v "$PKG_MANAGER" > /dev/null 2>&1; then
    echo -e "  ${RED}$PKG_MANAGER not found${NC}"
    exit 1
fi
echo -e "  $PKG_MANAGER: $(${PKG_MANAGER} --version 2>/dev/null || echo 'unknown')"
echo -e "  node: $(node --version 2>/dev/null || echo 'not found')"

# Staging health check (if backend is null but e2e has healthEndpoint)
if [ "$BACKEND_CFG" = "null" ] || [ -z "$BACKEND_CFG" ]; then
    local_health=$(read_config "environments.$ENV_NAME.e2e.healthEndpoint")
    if [ -n "$local_health" ] && [ "$local_health" != "null" ]; then
        health_check_http "$local_health" 10 || {
            echo -e "  ${RED}Remote endpoint not reachable${NC}"
            exit 1
        }
    fi
fi
echo ""

# ── Phase 3: Backend ──
if [ "$BACKEND_CFG" != "null" ] && [ -n "$BACKEND_CFG" ]; then
    echo -e "${CYAN}[Phase 3]${NC} Backend server"

    BACKEND_CMD=$(read_config "environments.$ENV_NAME.backend.startCommand")
    BACKEND_PORT=$(read_config "environments.$ENV_NAME.backend.port")
    HEALTH_EP=$(read_config "environments.$ENV_NAME.backend.healthEndpoint")
    HEALTH_TIMEOUT=$(read_config "environments.$ENV_NAME.backend.healthTimeout")
    HEALTH_TIMEOUT="${HEALTH_TIMEOUT:-60}"

    HEALTH_URL="http://localhost:${BACKEND_PORT}${HEALTH_EP}"

    # Check if already running
    if curl -sf "$HEALTH_URL" > /dev/null 2>&1; then
        echo -e "  ${GREEN}Backend already running (healthy)${NC}"
    else
        # Clean zombie processes on the port
        if lsof -i :"$BACKEND_PORT" > /dev/null 2>&1; then
            echo -e "  ${YELLOW}Stale process on port $BACKEND_PORT — cleaning...${NC}"
            cleanup_port "$BACKEND_PORT"
        fi

        # Start backend
        echo "  Starting: $BACKEND_CMD"
        (eval "$BACKEND_CMD") > /tmp/e2e-backend-${PROJECT_NAME}.log 2>&1 &
        API_PID=$!
        echo "  PID: $API_PID"

        # Wait for health
        health_check_http "$HEALTH_URL" "$HEALTH_TIMEOUT" || {
            echo -e "  ${RED}Backend start failed${NC}"
            echo "  Last 20 lines of log:"
            tail -20 "/tmp/e2e-backend-${PROJECT_NAME}.log" 2>/dev/null || true
            exit 1
        }
    fi
else
    echo -e "${CYAN}[Phase 3]${NC} Backend: ${YELLOW}skipped${NC} (null in config)"
fi
echo ""

# ── Phase 4: Cache ──
if [ "$CACHE_CFG" != "null" ] && [ -n "$CACHE_CFG" ]; then
    echo -e "${CYAN}[Phase 4]${NC} Cache cleanup"

    # Parse cache steps
    CACHE_STEPS=$(read_config "environments.$ENV_NAME.cache.steps")
    if [ "$CACHE_STEPS" != "null" ] && [ "$CACHE_STEPS" != "[]" ]; then
        # Iterate through cache steps using python3
        python3 -c "
import json
steps = json.loads('$CACHE_STEPS')
for i, step in enumerate(steps):
    print(f\"{i}|{step.get('type', '')}|{step.get('name', '')}|{step.get('path', '')}\")
" 2>/dev/null | while IFS='|' read -r idx step_type step_name step_path; do
            echo "  Step: $step_name ($step_type)"
            case "$step_type" in
                redis)
                    REDIS_HOST="${REDIS_HOST_LOCAL:-127.0.0.1}"
                    REDIS_PORT="${REDIS_LOCAL_PORT:-16379}"
                    REDIS_PW="${REDIS_PASSWORD:-}"
                    if redis_flush "$REDIS_HOST" "$REDIS_PORT" "$REDIS_PW"; then
                        echo -e "  ${GREEN}Redis FLUSHDB completed${NC}"
                    else
                        echo -e "  ${YELLOW}Redis flush failed (non-fatal)${NC}"
                    fi
                    ;;
                directory-clean)
                    dir_clean "$PROJECT_ROOT/$step_path"
                    ;;
                *)
                    echo -e "  ${YELLOW}Unknown cache step type: $step_type${NC}"
                    ;;
            esac
        done
    fi
else
    echo -e "${CYAN}[Phase 4]${NC} Cache: ${YELLOW}skipped${NC} (null in config)"
fi
echo ""

# ── Phase 4.5: Post-backend hooks ──
run_hook "post-backend" "$HOOKS_DIR"

# ── Phase 5: E2E Run ──
echo -e "${CYAN}[Phase 5]${NC} E2E execution"

run_hook "pre-e2e" "$HOOKS_DIR"

echo "  Command: $E2E_RUN_CMD"
echo "  Base URL: $E2E_BASE_URL"
echo ""

# Set BASE_URL for Playwright
export BASE_URL="$E2E_BASE_URL"

# Build run command with extra args
E2E_CMD="$E2E_RUN_CMD"
if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
    for arg in "${EXTRA_ARGS[@]}"; do
        E2E_CMD="$E2E_CMD $arg"
    done
fi

# Execute
eval "$E2E_CMD" 2>&1
E2E_EXIT=$?

run_hook "post-e2e" "$HOOKS_DIR" || true

echo ""
echo -e "${BOLD}${CYAN}========================================${NC}"
if [ $E2E_EXIT -eq 0 ]; then
    echo -e "  E2E Result: ${GREEN}${BOLD}PASS${NC}"
else
    echo -e "  E2E Result: ${RED}${BOLD}FAIL${NC} (exit code: $E2E_EXIT)"
fi
echo -e "${BOLD}${CYAN}========================================${NC}"

exit $E2E_EXIT
