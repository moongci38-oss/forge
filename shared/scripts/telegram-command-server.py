#!/usr/bin/env python3
"""
Forge Telegram Command Server
서버에서 독립 실행 — Claude Code 없이도 Telegram 명령을 처리한다.

지원 명령:
  run <agent>        - Managed Agent 실행
  status             - 서비스 상태 확인
  help               - 명령어 목록

실행:
  python3 telegram-command-server.py

환경변수 (~/forge/.env 에서 로드):
  TELEGRAM_BOT_TOKEN  - Telegram Bot Token
  TELEGRAM_CHAT_ID    - 허용된 chat ID (콤마 구분 멀티유저 가능)
  ANTHROPIC_API_KEY   - Anthropic API 키
  FORGE_ROOT          - forge 경로 (기본: ~/forge)
"""

import os
import sys
import json
import time
import subprocess
import threading
import urllib.request
import urllib.parse
from pathlib import Path
from datetime import datetime

HOME = Path.home()
FORGE_ROOT = Path(os.environ.get("FORGE_ROOT", HOME / "forge"))

# .env 로드
def load_env():
    env_file = FORGE_ROOT / ".env"
    if env_file.exists():
        for line in env_file.read_text().splitlines():
            line = line.strip()
            if "=" in line and not line.startswith("#"):
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip())

load_env()

# 서버 전용 봇 토큰 우선, 없으면 기본 봇 토큰 사용
TELEGRAM_BOT_TOKEN = os.environ.get("FORGE_AGENT_SERVER_BOT_TOKEN", "") or os.environ.get("TELEGRAM_BOT_TOKEN", "")
ALLOWED_CHAT_IDS = set(os.environ.get("TELEGRAM_CHAT_ID", "").split(","))
ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")
FORGE_OUTPUTS = Path(os.environ.get("FORGE_OUTPUTS", HOME / "forge-outputs"))

if not TELEGRAM_BOT_TOKEN:
    print("❌ TELEGRAM_BOT_TOKEN 미설정", file=sys.stderr)
    sys.exit(1)

TELEGRAM_API = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}"

# 실행 가능한 에이전트 목록
AVAILABLE_AGENTS = [
    "daily-system-review",
    "weekly-research",
    "system-audit",
    "audit-agentic",
    "audit-context",
    "audit-harness",
    "audit-cost",
    "audit-human-ai",
]

# 실행 중인 작업 추적
running_jobs = {}


def tg_request(method: str, params: dict) -> dict:
    """Telegram API 호출"""
    data = json.dumps(params).encode()
    req = urllib.request.Request(
        f"{TELEGRAM_API}/{method}",
        data=data,
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return json.loads(resp.read())
    except Exception as e:
        print(f"[TG] {method} 실패: {e}")
        return {}


def send_message(chat_id: str, text: str, reply_to: int = None):
    params = {"chat_id": chat_id, "text": text}
    if reply_to:
        params["reply_to_message_id"] = reply_to
    tg_request("sendMessage", params)


def get_updates(offset: int = 0) -> list:
    result = tg_request("getUpdates", {"offset": offset, "timeout": 30, "limit": 10})
    return result.get("result", [])


def ensure_mcp_server() -> str:
    """MCP 서버 + 터널이 실행 중인지 확인하고 URL 반환"""
    url_file = Path("/tmp/forge-mcp-tunnel-url.txt")
    if url_file.exists():
        url = url_file.read_text().strip()
        # 살아있는지 확인
        try:
            req = urllib.request.Request(
                f"{url}/mcp",
                data=b'{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"check","version":"1"}}}',
                headers={"Content-Type": "application/json", "Accept": "application/json, text/event-stream"}
            )
            with urllib.request.urlopen(req, timeout=5) as r:
                if r.status == 200:
                    return url
        except Exception:
            pass

    # 서버 재시작
    script = FORGE_ROOT / "shared/scripts/forge-mcp-service.sh"
    if script.exists():
        subprocess.run(["bash", str(script), "restart"],
                      capture_output=True, timeout=30)
        time.sleep(10)
        if url_file.exists():
            return url_file.read_text().strip()

    return ""


def run_agent_background(agent_name: str, chat_id: str, message_id: int):
    """백그라운드에서 에이전트 실행"""
    job_key = f"{chat_id}:{agent_name}"
    if job_key in running_jobs:
        send_message(chat_id, f"⚠️ {agent_name} 이미 실행 중입니다.", reply_to=message_id)
        return

    running_jobs[job_key] = True
    send_message(chat_id, f"▶️ {agent_name} 시작...", reply_to=message_id)

    try:
        # MCP 서버 확인
        tunnel_url = ensure_mcp_server()
        if not tunnel_url:
            send_message(chat_id, f"❌ MCP 서버 연결 실패", reply_to=message_id)
            return

        # run-managed-agent.py 실행
        runner = FORGE_ROOT / "shared/scripts/run-managed-agent.py"
        today = datetime.now().strftime("%Y-%m-%d")

        env = os.environ.copy()
        env["FORGE_ROOT"] = str(FORGE_ROOT)
        env["FORGE_OUTPUTS"] = str(FORGE_OUTPUTS)

        result = subprocess.run(
            [sys.executable, str(runner), agent_name, today],
            capture_output=True, text=True, timeout=1800, env=env
        )

        if result.returncode == 0:
            output = result.stdout.strip()
            # 마지막 3줄만 요약
            lines = [l for l in output.splitlines() if l.strip()]
            summary = "\n".join(lines[-3:]) if lines else "(출력 없음)"
            send_message(chat_id, f"✅ {agent_name} 완료\n{summary}")
        else:
            err = result.stderr.strip()[-300:] if result.stderr else "알 수 없는 오류"
            send_message(chat_id, f"❌ {agent_name} 실패\n{err}")

    except subprocess.TimeoutExpired:
        send_message(chat_id, f"⏱️ {agent_name} 타임아웃 (30분 초과)")
    except Exception as e:
        send_message(chat_id, f"❌ {agent_name} 오류: {e}")
    finally:
        running_jobs.pop(job_key, None)


def handle_command(text: str, chat_id: str, message_id: int):
    """명령어 처리"""
    text = text.strip()
    parts = text.split()
    cmd = parts[0].lower() if parts else ""

    if cmd == "help" or cmd == "/help":
        msg = (
            "📋 Forge 명령어\n\n"
            "run <에이전트>  — 에이전트 실행\n"
            "status          — 서비스 상태\n"
            "agents          — 에이전트 목록\n"
            "help            — 이 메시지\n\n"
            "에이전트 목록:\n" + "\n".join(f"  • {a}" for a in AVAILABLE_AGENTS)
        )
        send_message(chat_id, msg, reply_to=message_id)

    elif cmd == "agents":
        msg = "🤖 사용 가능한 에이전트:\n" + "\n".join(f"  • {a}" for a in AVAILABLE_AGENTS)
        send_message(chat_id, msg, reply_to=message_id)

    elif cmd == "status":
        url_file = Path("/tmp/forge-mcp-tunnel-url.txt")
        tunnel_url = url_file.read_text().strip() if url_file.exists() else "없음"
        jobs = list(running_jobs.keys()) or ["없음"]
        msg = (
            f"📊 Forge 서버 상태\n\n"
            f"MCP 터널: {tunnel_url[:50]}...\n"
            f"실행 중: {', '.join(jobs)}"
        )
        send_message(chat_id, msg, reply_to=message_id)

    elif cmd == "run":
        if len(parts) < 2:
            send_message(chat_id, "사용법: run <에이전트명>", reply_to=message_id)
            return
        agent_name = parts[1].lower()
        if agent_name not in AVAILABLE_AGENTS:
            send_message(chat_id,
                f"❌ 알 수 없는 에이전트: {agent_name}\n"
                f"목록: {', '.join(AVAILABLE_AGENTS)}",
                reply_to=message_id)
            return
        # 백그라운드 실행
        t = threading.Thread(target=run_agent_background, args=(agent_name, chat_id, message_id))
        t.daemon = True
        t.start()

    else:
        # 알 수 없는 명령어는 무시 (다른 봇 메시지 등)
        pass


def main():
    print(f"🤖 Forge Telegram Command Server 시작")
    print(f"   허용 chat ID: {ALLOWED_CHAT_IDS}")
    print(f"   에이전트: {', '.join(AVAILABLE_AGENTS)}")

    offset = 0
    while True:
        try:
            updates = get_updates(offset)
            for update in updates:
                offset = update["update_id"] + 1
                msg = update.get("message", {})
                if not msg:
                    continue

                chat_id = str(msg.get("chat", {}).get("id", ""))
                message_id = msg.get("message_id")
                text = msg.get("text", "").strip()

                if not text or chat_id not in ALLOWED_CHAT_IDS:
                    continue

                print(f"[{datetime.now().strftime('%H:%M:%S')}] {chat_id}: {text[:80]}")
                handle_command(text, chat_id, message_id)

        except KeyboardInterrupt:
            print("\n종료")
            break
        except Exception as e:
            print(f"[오류] {e}")
            time.sleep(5)


if __name__ == "__main__":
    main()
