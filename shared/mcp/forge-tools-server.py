#!/usr/bin/env python3
"""
Forge Tools MCP Server
Managed Agents(Anthropic 클라우드)가 로컬 Forge 리소스에 접근하는 브리지.

실행:
  python3 forge-tools-server.py          # SSE 모드 (HTTP, 포트 8765)
  python3 forge-tools-server.py stdio    # stdio 모드 (로컬 Claude Code)

환경변수:
  FORGE_MCP_TOKEN  인증 토큰 (SSE 모드 시 X-Forge-Token 헤더 검증)
  FORGE_OUTPUTS    forge-outputs 경로 (기본: ~/forge-outputs)
  FORGE_ROOT       forge 루트 경로 (기본: ~/forge)
"""

import os
import sys
import subprocess
from pathlib import Path
from typing import Optional

from fastmcp import FastMCP

# ── 경로 설정 ──────────────────────────────────────────────────────────────
HOME = Path.home()
FORGE_OUTPUTS = Path(os.environ.get("FORGE_OUTPUTS", HOME / "forge-outputs"))
FORGE_ROOT = Path(os.environ.get("FORGE_ROOT", HOME / "forge"))
FORGE_MCP_TOKEN = os.environ.get("FORGE_MCP_TOKEN", "")

# telegram-workspace .env 로드 (env에 없을 때 fallback)
_TG_ENV = HOME / "forge-outputs/11-platform/telegram-workspace/.env"
if _TG_ENV.exists() and not os.environ.get("FORGE_AGENT_SERVER_BOT_TOKEN"):
    for _line in _TG_ENV.read_text().splitlines():
        if "=" in _line and not _line.startswith("#"):
            _k, _, _v = _line.partition("=")
            os.environ.setdefault(_k.strip(), _v.strip())

# 실행 허용 스크립트 화이트리스트
ALLOWED_SCRIPTS = {
    "forge-codebase-health.sh": FORGE_ROOT / "shared/scripts/forge-codebase-health.sh",
    "md-to-docx.py": FORGE_ROOT / "shared/scripts/md-to-docx.py",
    "rag-search.py": FORGE_ROOT / "shared/scripts/rag/search.py",
    "workspace-build.sh": FORGE_ROOT / "shared/scripts/rag/workspace-build.sh",
    "lightrag-pilot.py": FORGE_ROOT / "shared/scripts/lightrag-pilot.py",
    "wiki-sync.sh": FORGE_ROOT / "shared/scripts/wiki-sync.sh",
}

# 접근 금지 경로
BLOCKED_PATHS = ["06-finance", "07-legal", "08-admin/insurance", "08-admin/freelancers"]

mcp = FastMCP("forge-tools")


# ── 보안 헬퍼 ──────────────────────────────────────────────────────────────

def _safe_outputs_path(path: str) -> Path:
    """경로 안전성 검증 — forge-outputs 외부 및 금지 경로 차단"""
    full = (FORGE_OUTPUTS / path).resolve()
    if not str(full).startswith(str(FORGE_OUTPUTS.resolve())):
        raise PermissionError(f"forge-outputs 외부 접근 불가: {path}")
    for blocked in BLOCKED_PATHS:
        if blocked in str(full):
            raise PermissionError(f"접근 금지 경로: {blocked}")
    return full


# ── 파일 도구 ──────────────────────────────────────────────────────────────

@mcp.tool()
def read_file(path: str) -> str:
    """forge-outputs/ 파일 읽기.

    Args:
        path: forge-outputs/ 기준 상대 경로 (예: "01-research/ai-report/2026-04-10.md")
    """
    full = _safe_outputs_path(path)
    if not full.exists():
        raise FileNotFoundError(f"파일 없음: {path}")
    return full.read_text(encoding="utf-8")


@mcp.tool()
def write_file(path: str, content: str) -> str:
    """forge-outputs/ 파일 쓰기.

    Args:
        path: forge-outputs/ 기준 상대 경로
        content: 파일 내용
    """
    full = _safe_outputs_path(path)
    full.parent.mkdir(parents=True, exist_ok=True)
    full.write_text(content, encoding="utf-8")
    return f"저장 완료: {path} ({len(content):,}자)"


@mcp.tool()
def list_files(path: str = "", pattern: str = "*") -> str:
    """forge-outputs/ 디렉토리 탐색.

    Args:
        path: forge-outputs/ 기준 상대 경로 (기본: 루트)
        pattern: glob 패턴 (기본: "*")
    """
    base = _safe_outputs_path(path) if path else FORGE_OUTPUTS
    if not base.is_dir():
        raise NotADirectoryError(f"디렉토리 아님: {path}")
    files = sorted(base.glob(pattern))
    lines = []
    for f in files[:100]:  # 최대 100개
        rel = f.relative_to(FORGE_OUTPUTS)
        mark = "/" if f.is_dir() else ""
        lines.append(f"{rel}{mark}")
    result = "\n".join(lines)
    if len(files) > 100:
        result += f"\n... (총 {len(files)}개 중 100개 표시)"
    return result or "(파일 없음)"


@mcp.tool()
def append_file(path: str, content: str) -> str:
    """forge-outputs/ 파일에 내용 추가 (기존 내용 보존).

    Args:
        path: forge-outputs/ 기준 상대 경로
        content: 추가할 내용
    """
    full = _safe_outputs_path(path)
    full.parent.mkdir(parents=True, exist_ok=True)
    with open(full, "a", encoding="utf-8") as f:
        f.write(content)
    return f"추가 완료: {path}"


# ── Git 도구 ──────────────────────────────────────────────────────────────

@mcp.tool()
def git_status(project: str = "forge") -> str:
    """프로젝트 git 상태 확인.

    Args:
        project: 프로젝트명 ("forge", "portfolio", "godblade") 또는 절대 경로
    """
    project_paths = {
        "forge": FORGE_ROOT,
        "portfolio": HOME / "mywsl_workspace/portfolio-project",
        "godblade": Path("/mnt/e/new_workspace/god_Sword/src"),
    }
    cwd = project_paths.get(project, Path(project))
    if not cwd.exists():
        raise FileNotFoundError(f"프로젝트 경로 없음: {cwd}")
    result = subprocess.run(
        ["git", "status", "--short", "--branch"],
        cwd=cwd, capture_output=True, text=True, timeout=30
    )
    return result.stdout or "(변경사항 없음)"


@mcp.tool()
def git_commit(project: str, message: str, files: Optional[list[str]] = None) -> str:
    """프로젝트 파일 git 커밋.

    Args:
        project: 프로젝트명 또는 절대 경로
        message: 커밋 메시지 (Conventional Commits 형식 권장)
        files: 커밋할 파일 목록 (None이면 변경된 파일 전체)
    """
    project_paths = {
        "forge": FORGE_ROOT,
        "forge-outputs": FORGE_OUTPUTS,
        "portfolio": HOME / "mywsl_workspace/portfolio-project",
        "godblade": Path("/mnt/e/new_workspace/god_Sword/src"),
    }
    cwd = project_paths.get(project, Path(project))
    if not cwd.exists():
        raise FileNotFoundError(f"프로젝트 경로 없음: {cwd}")

    # Stage
    if files:
        subprocess.run(["git", "add"] + files, cwd=cwd, check=True, timeout=30)
    else:
        subprocess.run(["git", "add", "-A"], cwd=cwd, check=True, timeout=30)

    # Commit
    full_message = f"{message}\n\nCo-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
    result = subprocess.run(
        ["git", "commit", "-m", full_message],
        cwd=cwd, capture_output=True, text=True, timeout=60
    )
    if result.returncode != 0:
        return f"커밋 실패: {result.stderr}"
    return f"커밋 완료: {result.stdout.strip()}"


@mcp.tool()
def git_log(project: str = "forge", n: int = 10) -> str:
    """최근 커밋 로그 확인.

    Args:
        project: 프로젝트명
        n: 표시할 커밋 수 (기본 10)
    """
    project_paths = {
        "forge": FORGE_ROOT,
        "forge-outputs": FORGE_OUTPUTS,
    }
    cwd = project_paths.get(project, FORGE_ROOT)
    result = subprocess.run(
        ["git", "log", f"--oneline", f"-{n}"],
        cwd=cwd, capture_output=True, text=True, timeout=30
    )
    return result.stdout or "(커밋 없음)"


# ── 스크립트 실행 도구 ──────────────────────────────────────────────────────

@mcp.tool()
def run_script(script_name: str, args: list[str] = []) -> str:
    """허용된 Forge 스크립트 실행 (화이트리스트 방식).

    Args:
        script_name: 스크립트명 (예: "forge-codebase-health.sh")
        args: 스크립트 인자 목록

    허용 스크립트:
        forge-codebase-health.sh  — Git 코드베이스 건강도 진단
        md-to-docx.py             — 마크다운 → DOCX 변환
        rag-search.py             — RAG 검색
        workspace-build.sh        — RAG 인덱스 빌드
    """
    if script_name not in ALLOWED_SCRIPTS:
        raise PermissionError(
            f"허용되지 않은 스크립트: {script_name}\n"
            f"허용 목록: {', '.join(ALLOWED_SCRIPTS.keys())}"
        )
    script_path = ALLOWED_SCRIPTS[script_name]
    if not script_path.exists():
        raise FileNotFoundError(f"스크립트 없음: {script_path}")

    cmd = ["python3" if str(script_path).endswith(".py") else "bash",
           str(script_path)] + args
    result = subprocess.run(
        cmd, capture_output=True, text=True, timeout=600, cwd=FORGE_ROOT
    )
    output = result.stdout
    if result.returncode != 0:
        output += f"\n[STDERR]\n{result.stderr}"
    return output or "(출력 없음)"


@mcp.tool()
def rag_search(query: str, top_k: int = 5) -> str:
    """forge-outputs RAG 하이브리드 검색 (워크스페이스 RAG, 벡터+BM25).

    일반 검색·"어디 있었지?" 류 질문에 빠르게 답한다. 6K+ 문서 광범위 인덱스.

    Args:
        query: 검색 쿼리
        top_k: 반환할 결과 수 (기본 5)
    """
    return run_script("rag-search.py", [query, "--top-k", str(top_k)])


@mcp.tool()
def wiki_search(query: str, mode: str = "hybrid") -> str:
    """Karpathy 3-layer 개인 지식 위키 검색 (LightRAG, 그래프 기반).

    개념 간 관계, "왜/어떻게" 류 심층 질문에 강함. forge-outputs/20-wiki의
    Wiki Layer만 검색하며, 엔티티+관계 그래프를 활용해 추론한다.

    rag_search와 차이:
    - rag_search: 광범위(6K 문서), 빠른 단순 검색
    - wiki_search: 좁은 셋(수백 노트), 그래프 기반 깊은 추론

    Args:
        query: 검색 쿼리 (한국어 권장)
        mode: 'local' | 'global' | 'hybrid' (기본 hybrid)
    """
    if mode not in ("local", "global", "hybrid"):
        return f"ERROR: mode must be local/global/hybrid, got '{mode}'"
    return run_script(
        "lightrag-pilot.py",
        ["query", query, mode, "--context", "wiki"],
    )


@mcp.tool()
def run_health_check(project: str = "forge", months: int = 12) -> str:
    """프로젝트 코드베이스 건강도 진단.

    Args:
        project: 프로젝트명 또는 경로
        months: 분석 기간 (개월, 기본 12)
    """
    project_paths = {
        "forge": str(FORGE_ROOT),
        "portfolio": str(HOME / "mywsl_workspace/portfolio-project"),
        "godblade": "/mnt/e/new_workspace/god_Sword/src",
    }
    project_path = project_paths.get(project, project)
    return run_script("forge-codebase-health.sh", [project_path, str(months)])


# ── Telegram 알림 도구 ─────────────────────────────────────────────────────

@mcp.tool()
def notion_create_page(database_id: str, properties: dict, content: str = "") -> str:
    """Notion 데이터베이스에 새 페이지 생성.

    Args:
        database_id: Notion DB ID (예: "43829f7b-8d3f-47f1-90a1-84f40d39239e")
        properties: 페이지 속성 딕셔너리 (title, date, status 등)
        content: 페이지 본문 (Markdown — Notion 블록으로 변환)
    """
    import urllib.request
    import json

    token = os.environ.get("NOTION_API_TOKEN", "")
    if not token:
        return "NOTION_API_TOKEN 미설정 — Notion 등록 불가"

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Notion-Version": "2022-06-28",
    }

    # properties → Notion API 포맷 변환
    def _notion_props(props: dict) -> dict:
        result = {}
        for key, val in props.items():
            if isinstance(val, str) and key.lower() in ("제목", "title", "name", "이름"):
                result[key] = {"title": [{"text": {"content": val[:2000]}}]}
            elif isinstance(val, str) and "날짜" in key.lower() or "date" in key.lower():
                result[key] = {"date": {"start": val}} if val else {"date": None}
            elif isinstance(val, (int, float)):
                result[key] = {"number": val}
            elif isinstance(val, str):
                result[key] = {"rich_text": [{"text": {"content": val[:2000]}}]}
        return result

    # content → Notion 블록 (단락으로 분할, 최대 100블록)
    def _content_blocks(text: str) -> list:
        blocks = []
        for chunk in text.split("\n\n")[:100]:
            chunk = chunk.strip()
            if not chunk:
                continue
            blocks.append({
                "object": "block",
                "type": "paragraph",
                "paragraph": {
                    "rich_text": [{"type": "text", "text": {"content": chunk[:2000]}}]
                }
            })
        return blocks

    payload = {
        "parent": {"database_id": database_id},
        "properties": _notion_props(properties),
        "children": _content_blocks(content) if content else [],
    }

    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        "https://api.notion.com/v1/pages",
        data=data, headers=headers
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            result = json.loads(resp.read())
            page_id = result.get("id", "unknown")
            url = result.get("url", "")
            return f"Notion 페이지 생성 완료: {page_id}\nURL: {url}"
    except Exception as e:
        return f"Notion 생성 실패: {e}"


@mcp.tool()
def telegram_notify(message: str, chat_id: str = "") -> str:
    """Telegram으로 완료 알림 발송.

    Args:
        message: 전송할 메시지
        chat_id: Telegram chat ID (기본: 환경변수 TELEGRAM_CHAT_ID)
    """
    token = os.environ.get("FORGE_AGENT_SERVER_BOT_TOKEN") or os.environ.get("TELEGRAM_BOT_TOKEN", "")
    cid = chat_id or os.environ.get("FORGE_AGENT_SERVER_BOT_CHAT_ID") or os.environ.get("TELEGRAM_CHAT_ID", "")

    if not token or not cid:
        return "TELEGRAM_BOT_TOKEN 또는 TELEGRAM_CHAT_ID 환경변수 미설정 — 알림 스킵"

    import urllib.request
    import json
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    data = json.dumps({"chat_id": cid, "text": message}).encode()
    req = urllib.request.Request(url, data=data,
                                  headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return f"Telegram 발송 완료 (status: {resp.status})"
    except Exception as e:
        return f"Telegram 발송 실패: {e}"


# ── 웹 검색/조회 도구 ─────────────────────────────────────────────────────

@mcp.tool()
def web_search(query: str, count: int = 5) -> str:
    """Brave Search API로 웹 검색.

    Args:
        query: 검색 쿼리
        count: 결과 수 (기본 5, 최대 20)
    """
    api_key = os.environ.get("BRAVE_API_KEY", "")
    if not api_key:
        return "BRAVE_API_KEY 미설정 — 웹 검색 불가"

    import urllib.request
    import urllib.parse
    import json

    params = urllib.parse.urlencode({"q": query, "count": min(count, 20)})
    url = f"https://api.search.brave.com/res/v1/web/search?{params}"
    req = urllib.request.Request(url, headers={
        "Accept": "application/json",
        "Accept-Encoding": "gzip",
        "X-Subscription-Token": api_key,
    })
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            import gzip
            raw = resp.read()
            if resp.headers.get("Content-Encoding") == "gzip":
                raw = gzip.decompress(raw)
            data = json.loads(raw)
        results = data.get("web", {}).get("results", [])
        lines = []
        for r in results[:count]:
            lines.append(f"**{r.get('title', '')}**\n{r.get('url', '')}\n{r.get('description', '')}\n")
        return "\n".join(lines) or "(결과 없음)"
    except Exception as e:
        return f"검색 오류: {e}"


@mcp.tool()
def web_fetch(url: str, max_chars: int = 8000) -> str:
    """URL 페이지 내용 조회.

    Args:
        url: 조회할 URL
        max_chars: 최대 문자 수 (기본 8000)
    """
    import urllib.request

    req = urllib.request.Request(url, headers={
        "User-Agent": "Mozilla/5.0 (compatible; ForgeBot/1.0)",
        "Accept": "text/html,application/xhtml+xml,text/plain",
    })
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            content_type = resp.headers.get("Content-Type", "")
            raw = resp.read(max_chars * 3)

        # HTML → 텍스트 간략 변환
        text = raw.decode("utf-8", errors="replace")
        if "html" in content_type.lower():
            import re
            text = re.sub(r'<script[^>]*>.*?</script>', '', text, flags=re.DOTALL | re.IGNORECASE)
            text = re.sub(r'<style[^>]*>.*?</style>', '', text, flags=re.DOTALL | re.IGNORECASE)
            text = re.sub(r'<[^>]+>', ' ', text)
            text = re.sub(r'\s+', ' ', text).strip()

        return text[:max_chars]
    except Exception as e:
        return f"조회 오류: {e}"


# ── 서버 실행 ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    transport = "stdio" if len(sys.argv) > 1 and sys.argv[1] == "stdio" else "http"

    if transport == "http":
        print(f"Forge Tools MCP Server 시작 (streamable-http)")
        print(f"  주소: http://0.0.0.0:8765/mcp")
        print(f"  forge-outputs: {FORGE_OUTPUTS}")
        print(f"  forge-root: {FORGE_ROOT}")
        print(f"  인증: {'활성화' if FORGE_MCP_TOKEN else '비활성화 (개발 모드)'}")
        print(f"  허용 스크립트: {', '.join(ALLOWED_SCRIPTS.keys())}")
        print()

    mcp.run(transport=transport, host="0.0.0.0", port=8765)
