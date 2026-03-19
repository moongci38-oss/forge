#!/usr/bin/env bash
# e2e-lib.sh - Shared functions for E2E pipeline
# Part of Forge Dev universal tooling (no Forge Dev dependency)

# ── ANSI Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# ── JSON value extractor (no jq dependency) ──
# Usage: json_value "key" < file.json
#        json_value "nested.key" < file.json
json_value() {
    local key="$1"
    # Handle nested keys: split on '.' and drill down
    local IFS='.'
    read -ra parts <<< "$key"
    local pattern="${parts[0]}"

    # Extract top-level value
    local result
    result=$(grep -o "\"${pattern}\"[[:space:]]*:[[:space:]]*[^,}]*" | head -1 | sed 's/.*:[[:space:]]*//' | sed 's/^"//' | sed 's/"$//' | sed 's/[[:space:]]*$//')

    # If the value is an object/array start, we need a different approach
    if [ "${#parts[@]}" -gt 1 ]; then
        # For nested access, use python3 if available, else grep chain
        if command -v python3 > /dev/null 2>&1; then
            python3 -c "
import json, sys
data = json.load(sys.stdin)
keys = '${key}'.split('.')
val = data
for k in keys:
    if val is None:
        print('')
        sys.exit(0)
    val = val.get(k) if isinstance(val, dict) else None
if val is None:
    print('')
else:
    print(val if not isinstance(val, (dict, list)) else json.dumps(val))
" 2>/dev/null
        else
            echo "$result"
        fi
    else
        echo "$result"
    fi
}

# ── JSON object extractor (returns sub-object as JSON) ──
# Usage: json_object "environments.local.backend" < file.json
json_object() {
    local key="$1"
    python3 -c "
import json, sys
data = json.load(sys.stdin)
keys = '${key}'.split('.')
val = data
for k in keys:
    if val is None: break
    val = val.get(k) if isinstance(val, dict) else None
if val is None:
    print('null')
else:
    print(json.dumps(val))
" 2>/dev/null
}

# ── NVM initialization ──
nvm_init() {
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        # nvm.sh uses unbound vars and invokes manpath which can fail with locale errors
        set +eu
        source "$NVM_DIR/nvm.sh" 2>/dev/null
        nvm use 2>/dev/null
        set -eu
    fi
    # Fallback: extract PATH from .bashrc
    if ! command -v node > /dev/null 2>&1; then
        if [ -f "$HOME/.bashrc" ]; then
            eval "$(grep 'export PATH' "$HOME/.bashrc" 2>/dev/null || true)"
        fi
    fi
}

# ── Health check (HTTP) ──
# Usage: health_check_http "http://localhost:4000/api/v1/health" 60
health_check_http() {
    local url="$1"
    local timeout_sec="${2:-60}"
    local interval=2
    local attempts=$(( timeout_sec / interval ))

    echo -n "  Health check: $url"
    for i in $(seq 1 "$attempts"); do
        if curl -sf "$url" > /dev/null 2>&1; then
            echo ""
            echo -e "  ${GREEN}Healthy${NC}"
            return 0
        fi
        echo -n "."
        sleep "$interval"
    done
    echo ""
    echo -e "  ${RED}Health check failed (${timeout_sec}s timeout)${NC}"
    return 1
}

# ── Health check (TCP port) ──
# Usage: health_check_tcp "127.0.0.1" 5432 15
health_check_tcp() {
    local host="$1"
    local port="$2"
    local timeout_sec="${3:-15}"
    local interval=3
    local attempts=$(( timeout_sec / interval ))

    echo -n "  TCP check: $host:$port"
    for i in $(seq 1 "$attempts"); do
        if nc -z "$host" "$port" 2>/dev/null; then
            echo ""
            echo -e "  ${GREEN}Connected${NC}"
            return 0
        fi
        echo -n "."
        sleep "$interval"
    done
    echo ""
    echo -e "  ${RED}TCP check failed (${timeout_sec}s timeout)${NC}"
    return 1
}

# ── Port cleanup ──
# Usage: cleanup_port 4000
cleanup_port() {
    local port="$1"
    local pids
    pids=$(lsof -t -i:"$port" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        echo "$pids" | xargs kill 2>/dev/null || true
        echo -e "  Port $port processes cleaned up"
        sleep 1
    fi
}

# ── Hook runner ──
# Usage: run_hook "pre-infra" "/path/to/project/scripts/e2e-hooks"
run_hook() {
    local hook_name="$1"
    local hooks_dir="$2"
    local hook_file="$hooks_dir/${hook_name}.sh"

    if [ -f "$hook_file" ]; then
        echo -e "${CYAN}[Hook]${NC} Running ${hook_name}..."
        if bash "$hook_file"; then
            echo -e "  ${GREEN}${hook_name} completed${NC}"
        else
            echo -e "  ${RED}${hook_name} failed${NC}"
            return 1
        fi
    fi
    return 0
}

# ── Env file loader ──
# Usage: load_env_file "/path/to/.env.local"
load_env_file() {
    local env_file="$1"
    if [ -f "$env_file" ]; then
        set -a
        # shellcheck source=/dev/null
        source "$env_file"
        set +a
    fi
}

# ── Redis flush ──
# Usage: redis_flush "127.0.0.1" 6379 "password"
redis_flush() {
    local host="${1:-127.0.0.1}"
    local port="${2:-6379}"
    local password="${3:-}"

    if command -v redis-cli > /dev/null 2>&1; then
        if [ -n "$password" ]; then
            redis-cli -h "$host" -p "$port" -a "$password" --no-auth-warning FLUSHDB > /dev/null 2>&1
        else
            redis-cli -h "$host" -p "$port" FLUSHDB > /dev/null 2>&1
        fi
    else
        # Node.js fallback with ioredis
        node -e "
const Redis = require('ioredis');
const redis = new Redis({ host: '$host', port: $port, password: '$password' || undefined });
(async () => { try { await redis.flushdb(); } finally { await redis.quit(); } })();
" 2>/dev/null
    fi
}

# ── Directory clean ──
# Usage: dir_clean "/path/to/cache"
dir_clean() {
    local dir="$1"
    if [ -d "$dir" ]; then
        rm -rf "$dir"
        echo -e "  ${GREEN}Cleaned: $dir${NC}"
    else
        echo -e "  Skipped (not found): $dir"
    fi
}
