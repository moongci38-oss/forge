#!/usr/bin/env bash
# forge-tools MCP 서버 + cloudflared 터널 시작
# 용도: Managed Agents (Anthropic 클라우드)에서 로컬 forge-tools MCP에 접근할 때 사용
#
# 사전 조건:
#   - pip install fastmcp
#   - cloudflared 설치: https://github.com/cloudflare/cloudflared/releases
#   - FORGE_MCP_TOKEN 환경변수 설정 (선택, SSE 인증 토큰)
#
# 사용법:
#   ./start-mcp-tunnel.sh            # 기본 (포트 8765)
#   ./start-mcp-tunnel.sh 9000       # 커스텀 포트
#
# 환경변수:
#   FORGE_MCP_TOKEN    인증 토큰 (미설정 시 개발 모드)
#   FORGE_OUTPUTS      forge-outputs 경로 (기본: ~/forge-outputs)
#   FORGE_ROOT         forge 루트 경로 (기본: ~/forge)

set -e

# forge/.env에서 환경변수 로드
FORGE_ENV="${FORGE_ROOT:-$HOME/forge}/.env"
if [[ -f "$FORGE_ENV" ]]; then
    export $(grep -v '^#' "$FORGE_ENV" | grep -E '^(BRAVE_API_KEY|ANTHROPIC_API_KEY|TELEGRAM_BOT_TOKEN|TELEGRAM_CHAT_ID)=' | xargs)
fi

PORT=${1:-8765}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_SCRIPT="$SCRIPT_DIR/../mcp/forge-tools-server.py"
PID_FILE="/tmp/forge-mcp-server.pid"
TUNNEL_PID_FILE="/tmp/forge-mcp-tunnel.pid"

stop_all() {
    echo "종료 중..."
    [[ -f "$PID_FILE" ]] && kill "$(cat "$PID_FILE")" 2>/dev/null && rm -f "$PID_FILE"
    [[ -f "$TUNNEL_PID_FILE" ]] && kill "$(cat "$TUNNEL_PID_FILE")" 2>/dev/null && rm -f "$TUNNEL_PID_FILE"
    exit 0
}
trap stop_all SIGINT SIGTERM

# 이미 실행 중이면 중지
[[ -f "$PID_FILE" ]] && kill "$(cat "$PID_FILE")" 2>/dev/null; rm -f "$PID_FILE"
[[ -f "$TUNNEL_PID_FILE" ]] && kill "$(cat "$TUNNEL_PID_FILE")" 2>/dev/null; rm -f "$TUNNEL_PID_FILE"

# MCP 서버 시작 (백그라운드)
echo "forge-tools MCP 서버 시작 (포트 $PORT)..."
python3 "$SERVER_SCRIPT" &
echo $! > "$PID_FILE"
sleep 2

# 서버 기동 확인
if ! curl -sf "http://localhost:$PORT/health" > /dev/null 2>&1 && \
   ! curl -sf "http://localhost:$PORT/sse" > /dev/null 2>&1; then
    # SSE endpoint는 연결 유지라 curl로 확인 어려움 — 프로세스 존재 여부로 대체
    if ! kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo "❌ MCP 서버 기동 실패"
        exit 1
    fi
fi
echo "✅ MCP 서버 실행 중 (PID: $(cat "$PID_FILE"))"

# cloudflared 설치 확인
if ! command -v cloudflared &>/dev/null; then
    echo ""
    echo "⚠️  cloudflared 미설치. 터널 없이 서버만 실행합니다."
    echo "   설치: https://github.com/cloudflare/cloudflared/releases"
    echo "   또는: wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && dpkg -i cloudflared-linux-amd64.deb"
    echo ""
    echo "서버 주소 (로컬): http://localhost:$PORT/sse"
    echo "종료: Ctrl+C"
    wait
    exit 0
fi

# cloudflared 터널 시작
echo "cloudflared 터널 시작..."
cloudflared tunnel --url "http://localhost:$PORT" 2>&1 | tee /tmp/forge-mcp-cloudflared.log &
echo $! > "$TUNNEL_PID_FILE"
sleep 3

# 터널 URL 추출
TUNNEL_URL=$(grep -o 'https://[a-zA-Z0-9.-]*\.trycloudflare\.com' /tmp/forge-mcp-cloudflared.log | head -1)

echo ""
echo "════════════════════════════════════════"
echo "  forge-tools MCP 서버 실행 중"
echo "════════════════════════════════════════"
echo "  로컬 SSE: http://localhost:$PORT/sse"
if [[ -n "$TUNNEL_URL" ]]; then
    echo "  터널 SSE: $TUNNEL_URL/sse"
    echo ""
    echo "  Managed Agents에서 사용:"
    echo "    URL:   $TUNNEL_URL/sse"
    if [[ -n "$FORGE_MCP_TOKEN" ]]; then
        echo "    헤더:  X-Forge-Token: \$FORGE_MCP_TOKEN"
    fi
fi
echo "════════════════════════════════════════"
echo "  종료: Ctrl+C"
echo ""

wait
