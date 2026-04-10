#!/usr/bin/env python3
"""
Managed Agents 실행 래퍼
forge-tools MCP 서버 + cloudflared 터널 기반으로 Managed Agent 세션을 실행한다.

사용법:
  python3 run-managed-agent.py daily-system-review [YYYY-MM-DD]
  python3 run-managed-agent.py weekly-research [YYYY-MM-DD]

환경변수:
  ANTHROPIC_API_KEY  필수
  FORGE_AGENT_ID     에이전트 ID (기본: agent_011CZuxZ5KG6bFxctV9R2BpC)
  FORGE_ENV_ID       환경 ID (기본: env_01NmVREmA4Vek1kzNqRUKQxw)
  MCP_TUNNEL_URL     cloudflared 터널 URL (기본: /tmp/forge-mcp-tunnel-url.txt에서 로드)
"""

import os
import sys
import subprocess
import time
import threading
from pathlib import Path
from datetime import datetime, timedelta

import anthropic

# ── 설정 ──────────────────────────────────────────────────────────────────────

HOME = Path.home()
FORGE_ROOT = Path(os.environ.get("FORGE_ROOT", HOME / "forge"))
FORGE_OUTPUTS = Path(os.environ.get("FORGE_OUTPUTS", HOME / "forge-outputs"))
ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")
ENV_ID = os.environ.get("FORGE_ENV_ID", "env_01NmVREmA4Vek1kzNqRUKQxw")

# 에이전트 ID 맵 (forge-agent-ids.json 또는 하드코딩 폴백)
_AGENT_ID_FILE = FORGE_ROOT / "shared/mcp/forge-agent-ids.json"
_DEFAULT_AGENT_IDS = {
    "daily-system-review": "agent_011CZuxZ5KG6bFxctV9R2BpC",
    "weekly-research": "agent_011CZv2SDDmnTGdhTZS1k7dn",
}
def _load_agent_ids() -> dict:
    if _AGENT_ID_FILE.exists():
        import json
        return json.loads(_AGENT_ID_FILE.read_text())
    return _DEFAULT_AGENT_IDS

# API Key 로드 (forge/.env 폴백)
if not ANTHROPIC_API_KEY:
    env_file = FORGE_ROOT / ".env"
    if env_file.exists():
        for line in env_file.read_text().splitlines():
            if line.startswith("ANTHROPIC_API_KEY="):
                ANTHROPIC_API_KEY = line.split("=", 1)[1].strip()
                break

if not ANTHROPIC_API_KEY:
    print("❌ ANTHROPIC_API_KEY 미설정", file=sys.stderr)
    sys.exit(1)

SKILL_DIRS = {
    "daily-system-review": HOME / ".claude/skills/daily-system-review",
    "weekly-research":      HOME / ".claude/skills/weekly-research",
}


# ── MCP 서버 + 터널 관리 ────────────────────────────────────────────────────

def ensure_mcp_server() -> str:
    """MCP 서버와 cloudflared 터널이 실행 중인지 확인하고 URL 반환"""
    # 환경변수 또는 파일에서 URL 로드
    tunnel_url = os.environ.get("MCP_TUNNEL_URL", "")
    url_file = Path("/tmp/forge-mcp-tunnel-url.txt")
    if not tunnel_url and url_file.exists():
        tunnel_url = url_file.read_text().strip()

    if tunnel_url:
        # 살아있는지 확인
        try:
            import urllib.request
            req = urllib.request.Request(
                f"{tunnel_url}/mcp",
                data=b'{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"check","version":"1"}}}',
                headers={"Content-Type": "application/json", "Accept": "application/json, text/event-stream"}
            )
            with urllib.request.urlopen(req, timeout=5) as r:
                if r.status == 200:
                    print(f"✅ MCP 서버 연결됨: {tunnel_url}/mcp")
                    return tunnel_url
        except Exception:
            pass

    # 서버 시작
    print("MCP 서버 시작 중...")
    server_script = FORGE_ROOT / "shared/mcp/forge-tools-server.py"
    pid_file = Path("/tmp/forge-mcp-server.pid")

    # 기존 프로세스 정리
    if pid_file.exists():
        try:
            os.kill(int(pid_file.read_text()), 9)
        except Exception:
            pass

    import subprocess
    proc = subprocess.Popen(
        ["python3", str(server_script)],
        stdout=open("/tmp/forge-mcp.log", "a"),
        stderr=subprocess.STDOUT
    )
    pid_file.write_text(str(proc.pid))
    time.sleep(2)

    # cloudflared 터널
    print("cloudflared 터널 시작 중...")
    tunnel_log = Path("/tmp/forge-mcp-cloudflared.log")
    tunnel_proc = subprocess.Popen(
        ["cloudflared", "tunnel", "--url", "http://localhost:8765"],
        stdout=open(tunnel_log, "w"),
        stderr=subprocess.STDOUT
    )
    Path("/tmp/forge-mcp-tunnel.pid").write_text(str(tunnel_proc.pid))
    time.sleep(4)

    # URL 추출
    log_content = tunnel_log.read_text()
    import re
    m = re.search(r'https://[a-zA-Z0-9.-]+\.trycloudflare\.com', log_content)
    if not m:
        print("❌ 터널 URL 추출 실패", file=sys.stderr)
        sys.exit(1)

    url = m.group(0)
    url_file.write_text(url)
    print(f"✅ 터널 URL: {url}/mcp")
    return url


# ── 에이전트 업데이트 (MCP URL 갱신) ─────────────────────────────────────────

def update_agent_mcp_url(client: anthropic.Anthropic, agent_id: str, tunnel_url: str) -> int:
    """에이전트의 MCP URL을 현재 터널 URL로 업데이트"""
    agent = client.beta.agents.retrieve(agent_id, betas=["managed-agents-2026-04-01"])
    current_url = agent.mcp_servers[0].url if agent.mcp_servers else ""

    if current_url == f"{tunnel_url}/mcp":
        print(f"✅ 에이전트 MCP URL 최신 (v{agent.version})")
        return agent.version

    print(f"에이전트 MCP URL 업데이트 중...")
    updated = client.beta.agents.update(
        agent_id=agent_id,
        version=str(agent.version),
        name=agent.name,
        model={"id": agent.model.id},
        system=agent.system,
        mcp_servers=[{"type": "url", "url": f"{tunnel_url}/mcp", "name": "forge-tools"}],
        tools=[{
            "type": "mcp_toolset",
            "mcp_server_name": "forge-tools",
            "default_config": {"enabled": True, "permission_policy": {"type": "always_allow"}}
        }],
        betas=["managed-agents-2026-04-01"]
    )
    print(f"✅ 에이전트 v{updated.version}으로 업데이트")
    return updated.version


# ── 스킬 실행 ────────────────────────────────────────────────────────────────

def run_skill(skill_name: str, date_str: str, agent_id: str, agent_version: int):
    skill_dir = SKILL_DIRS.get(skill_name)
    if not skill_dir or not skill_dir.exists():
        print(f"❌ 스킬 없음: {skill_name}", file=sys.stderr)
        sys.exit(1)

    skill_md = (skill_dir / "SKILL.md").read_text(encoding="utf-8")

    client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)

    # 세션 생성
    session = client.beta.sessions.create(
        agent={"type": "agent", "id": agent_id, "version": agent_version},
        environment_id=ENV_ID,
        title=f"{skill_name} {date_str}",
        betas=["managed-agents-2026-04-01"]
    )
    SESSION_ID = session.id
    print(f"세션 생성: {SESSION_ID}")

    # 수집 버퍼
    output_lines = []

    def do_stream():
        try:
            with client.beta.sessions.events.stream(
                session_id=SESSION_ID,
                betas=["managed-agents-2026-04-01"]
            ) as stream:
                for event in stream:
                    etype = getattr(event, 'type', '')
                    if etype == 'agent.message' and hasattr(event, 'content'):
                        for b in event.content:
                            if hasattr(b, 'text'):
                                output_lines.append(b.text)
                                print(f"  [응답] {b.text[:200]}")
                    elif etype in ('agent.thinking', 'agent.mcp_tool_use', 'agent.mcp_tool_result', 'session.status_running', 'session.status_idle'):
                        print(f"  [{etype}]")
        except Exception as e:
            print(f"  STREAM ERR: {e}")

    t = threading.Thread(target=do_stream)
    t.daemon = True
    t.start()
    time.sleep(0.5)

    # 메시지 전송 (시스템 프롬프트에 SKILL.md가 있으면 간단하게, 없으면 전체 포함)
    agent_obj = client.beta.agents.retrieve(agent_id, betas=["managed-agents-2026-04-01"])
    if agent_obj.system and len(agent_obj.system) > 100:
        prompt = f"분석 날짜: {date_str}\n\nforge-tools MCP 도구를 사용하여 지침에 따라 작업을 실행하라."
    else:
        prompt = f"아래 SKILL.md 지침에 따라 {date_str} 분석을 실행하라.\nforge-tools MCP 도구를 사용하여 forge-outputs에 결과를 저장하라.\n분석 날짜: {date_str}\n\n---\n{skill_md}"
    client.beta.sessions.events.send(
        session_id=SESSION_ID,
        events=[{"type": "user.message", "content": [{"type": "text", "text": prompt}]}],
        betas=["managed-agents-2026-04-01"]
    )
    print(f"프롬프트 전송 완료. 에이전트 실행 중...")

    # 최대 30분 대기
    t.join(timeout=1800)

    final_session = client.beta.sessions.retrieve(SESSION_ID, betas=["managed-agents-2026-04-01"])
    print(f"\n✅ 완료: {final_session.status}, active_seconds: {final_session.stats.active_seconds:.1f}")
    print(f"   tokens: in={final_session.usage.input_tokens}, out={final_session.usage.output_tokens}")
    return "\n".join(output_lines)


# ── 메인 ─────────────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) < 2:
        print("사용법: run-managed-agent.py <skill-name> [YYYY-MM-DD]")
        print(f"  스킬 목록: {', '.join(SKILL_DIRS.keys())}")
        sys.exit(1)

    skill_name = sys.argv[1]
    date_str = sys.argv[2] if len(sys.argv) > 2 else (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")

    print(f"\n{'='*50}")
    print(f"  Managed Agent 실행: {skill_name}")
    print(f"  분석 날짜: {date_str}")
    print(f"{'='*50}\n")

    # 1. MCP 서버 + 터널 확인
    tunnel_url = ensure_mcp_server()

    # 2. 에이전트 ID 로드 및 URL 최신화
    client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)
    agent_ids = _load_agent_ids()
    agent_id = os.environ.get("FORGE_AGENT_ID", agent_ids.get(skill_name, ""))
    if not agent_id:
        print(f"❌ 에이전트 ID 없음: {skill_name}", file=sys.stderr)
        sys.exit(1)
    print(f"에이전트 ID: {agent_id}")
    agent_version = update_agent_mcp_url(client, agent_id, tunnel_url)

    # 3. 스킬 실행
    run_skill(skill_name, date_str, agent_id, agent_version)


if __name__ == "__main__":
    main()
