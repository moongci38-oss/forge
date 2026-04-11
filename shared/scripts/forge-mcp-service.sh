#!/usr/bin/env bash
# forge-tools MCP 서비스 관리
# tmux 세션으로 MCP 서버 + cloudflared 터널을 영구 실행하고 Managed Agent URL을 자동 갱신한다.
#
# 사용법:
#   forge-mcp-service.sh start    # 서비스 시작
#   forge-mcp-service.sh stop     # 서비스 중지
#   forge-mcp-service.sh status   # 상태 확인
#   forge-mcp-service.sh restart  # 재시작 (터널 URL 갱신 포함)
#
# WSL 자동시작: ~/.bashrc에 다음 추가
#   [ -z "$TMUX" ] && ~/forge/shared/scripts/forge-mcp-service.sh start --quiet

set -e

FORGE_ROOT="${FORGE_ROOT:-$HOME/forge}"
TMUX_SESSION="forge-mcp"
MCP_SCRIPT="$FORGE_ROOT/shared/mcp/forge-tools-server.py"
TUNNEL_URL_FILE="/tmp/forge-mcp-tunnel-url.txt"
AGENT_IDS_FILE="$FORGE_ROOT/shared/mcp/forge-agent-ids.json"
QUIET="${2:-}"

# forge/.env 로드
if [[ -f "$FORGE_ROOT/.env" ]]; then
    export $(grep -v '^#' "$FORGE_ROOT/.env" | grep -E '^(ANTHROPIC_API_KEY|BRAVE_API_KEY|TELEGRAM_BOT_TOKEN|TELEGRAM_CHAT_ID|NOTION_API_TOKEN|PERMANENT_MCP_URL)=' | xargs) 2>/dev/null || true
fi

log() { [[ "$QUIET" != "--quiet" ]] && echo "$@"; }

# ── 상태 확인 ──────────────────────────────────────────────────────────────

status() {
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        echo "✅ forge-mcp tmux 세션 실행 중"
        TUNNEL_URL=$(cat "$TUNNEL_URL_FILE" 2>/dev/null || echo "N/A")
        echo "   터널 URL: $TUNNEL_URL/mcp"

        # MCP 서버 응답 확인
        if curl -sf --max-time 3 "http://localhost:8765/mcp" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json, text/event-stream" \
            -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"check","version":"1"}}}' \
            > /dev/null 2>&1; then
            echo "   MCP 서버: ✅ 응답 중"
        else
            echo "   MCP 서버: ❌ 응답 없음"
        fi
        return 0
    else
        echo "❌ forge-mcp 서비스 중지됨"
        return 1
    fi
}

# ── 에이전트 URL 갱신 ───────────────────────────────────────────────────────

update_agents() {
    local tunnel_url="$1"
    [[ -z "$tunnel_url" ]] && return
    [[ ! -f "$AGENT_IDS_FILE" ]] && return

    log "에이전트 MCP URL 갱신 중: $tunnel_url/mcp"
    python3 << PYEOF
import json, anthropic, sys

with open('$AGENT_IDS_FILE') as f:
    ids = json.load(f)

try:
    ANTHROPIC_API_KEY = open('$FORGE_ROOT/.env').read()
    ANTHROPIC_API_KEY = [l.split('=',1)[1].strip() for l in ANTHROPIC_API_KEY.splitlines() if l.startswith('ANTHROPIC_API_KEY')][0]
except:
    print("ANTHROPIC_API_KEY 없음 — 에이전트 갱신 스킵")
    sys.exit(0)

client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)
tunnel_url = "$tunnel_url"

for skill, agent_id in ids.items():
    if skill == "environment_id": continue
    try:
        agent = client.beta.agents.retrieve(agent_id, betas=["managed-agents-2026-04-01"])
        current = agent.mcp_servers[0].url if agent.mcp_servers else ""
        if current == f"{tunnel_url}/mcp":
            print(f"  {skill}: 최신 (v{agent.version})")
            continue
        updated = client.beta.agents.update(
            agent_id=agent_id, version=str(agent.version),
            name=agent.name, model={"id": agent.model.id},
            system=agent.system,
            mcp_servers=[{"type": "url", "url": f"{tunnel_url}/mcp", "name": "forge-tools"}],
            tools=[{"type": "mcp_toolset", "mcp_server_name": "forge-tools",
                    "default_config": {"enabled": True, "permission_policy": {"type": "always_allow"}}}],
            betas=["managed-agents-2026-04-01"]
        )
        print(f"  {skill}: v{agent.version} → v{updated.version} 갱신")
    except Exception as e:
        print(f"  {skill}: 갱신 실패 - {e}")
PYEOF
}

# ── 시작 ───────────────────────────────────────────────────────────────────

start() {
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        [[ "$QUIET" != "--quiet" ]] && echo "이미 실행 중. 'restart'를 사용하세요."
        return 0
    fi

    log "forge-mcp 서비스 시작..."

    # tmux 세션 생성
    tmux new-session -d -s "$TMUX_SESSION" -x 220 -y 50

    # Window 0: MCP 서버
    tmux rename-window -t "$TMUX_SESSION:0" "mcp-server"
    tmux send-keys -t "$TMUX_SESSION:0" \
        "BRAVE_API_KEY=$BRAVE_API_KEY TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID=$TELEGRAM_CHAT_ID NOTION_API_TOKEN=$NOTION_API_TOKEN python3 $MCP_SCRIPT" Enter

    # Window 1: cloudflared 터널
    tmux new-window -t "$TMUX_SESSION" -n "tunnel"
    tmux send-keys -t "$TMUX_SESSION:tunnel" \
        "cloudflared tunnel --url http://localhost:8765 2>&1 | tee /tmp/forge-mcp-cloudflared.log" Enter

    log "MCP 서버 + 터널 시작 중 (8초 대기)..."
    sleep 8

    # 영구 URL이 설정된 경우 — 터널 URL 대신 사용
    if [[ -n "$PERMANENT_MCP_URL" ]]; then
        AGENT_URL="${PERMANENT_MCP_URL%/mcp}"  # trailing /mcp 제거
        echo "$AGENT_URL" > "$TUNNEL_URL_FILE"
        log "✅ 영구 URL 사용: $PERMANENT_MCP_URL"
        update_agents "$AGENT_URL"
    else
        # 터널 URL 추출 및 저장
        TUNNEL_URL=$(grep -o 'https://[a-zA-Z0-9.-]*\.trycloudflare\.com' /tmp/forge-mcp-cloudflared.log 2>/dev/null | head -1)
        if [[ -z "$TUNNEL_URL" ]]; then
            log "⚠️  터널 URL 추출 실패. 로그: /tmp/forge-mcp-cloudflared.log"
        else
            echo "$TUNNEL_URL" > "$TUNNEL_URL_FILE"
            log "✅ 터널 URL: $TUNNEL_URL/mcp"
            update_agents "$TUNNEL_URL"
        fi
    fi

    log "✅ forge-mcp 서비스 시작 완료"
    [[ "$QUIET" == "--quiet" ]] || tmux ls
}

# ── 중지 ───────────────────────────────────────────────────────────────────

stop() {
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        tmux kill-session -t "$TMUX_SESSION"
        rm -f "$TUNNEL_URL_FILE"
        echo "✅ forge-mcp 서비스 중지"
    else
        echo "서비스가 실행 중이 아닙니다"
    fi
}

# ── 메인 ───────────────────────────────────────────────────────────────────

case "${1:-status}" in
    start)   start ;;
    stop)    stop ;;
    restart) stop; sleep 1; start ;;
    status)  status ;;
    update-agents)
        TUNNEL_URL=$(cat "$TUNNEL_URL_FILE" 2>/dev/null || echo "")
        if [[ -z "$TUNNEL_URL" ]]; then echo "터널 URL 없음"; exit 1; fi
        update_agents "$TUNNEL_URL"
        ;;
    *)
        echo "사용법: $0 {start|stop|restart|status|update-agents}"
        exit 1
        ;;
esac
