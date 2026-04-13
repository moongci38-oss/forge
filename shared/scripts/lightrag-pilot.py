#!/usr/bin/env python3
"""
LightRAG Pilot — forge weekly-research / 정부과제 도메인
Claude Haiku (LLM) + Gemini embedding-001 (임베딩)

사용법:
  python3 lightrag-pilot.py index                        # 문서 인덱싱 (weekly)
  python3 lightrag-pilot.py index --context grants       # 정부과제 문서 인덱싱
  python3 lightrag-pilot.py index --context wiki         # 20-wiki 노트 인덱싱
  python3 lightrag-pilot.py query "질문"                 # 단일 쿼리 (hybrid, weekly)
  python3 lightrag-pilot.py query "질문" hybrid --context grants  # 정부과제 쿼리
  python3 lightrag-pilot.py query "질문" hybrid --context wiki    # 위키 노트 쿼리
  python3 lightrag-pilot.py check                        # 한국어 품질 검증 (5개 쿼리)
  python3 lightrag-pilot.py report                       # 전체 리포트 생성

컨텍스트 (--context):
  weekly  — weekly-research 도메인 (기본)
  grants  — 정부과제 문서 도메인 (forge-outputs/09-grants/)
  wiki    — 개인 지식 위키 (forge-outputs/20-wiki/, Karpathy 3-layer)

환경변수:
  ANTHROPIC_API_KEY — Claude Haiku 호출용
  GEMINI_API_KEY    — Gemini Embedding용
  FORGE_OUTPUTS     — forge-outputs 경로 (기본: ~/forge-outputs)
"""

import asyncio
import json
import os
import sys
import time
from pathlib import Path
from datetime import datetime

# ── 경로 설정 ──────────────────────────────────────────────────────────────
FORGE_ROOT = Path(os.environ.get("FORGE_ROOT", Path.home() / "forge"))
FORGE_OUTPUTS = Path(os.environ.get("FORGE_OUTPUTS", Path.home() / "forge-outputs"))
RESEARCH_DIR = FORGE_OUTPUTS / "01-research"

# weekly-research 컨텍스트
PILOT_DIR = FORGE_ROOT / "shared/lightrag-pilot-data"
WORKING_DIR = PILOT_DIR / "index"

# grants 컨텍스트
GRANTS_PILOT_DIR = FORGE_ROOT / "shared/lightrag-grants-data"
GRANTS_WORKING_DIR = GRANTS_PILOT_DIR / "index"
GRANTS_DIR = FORGE_OUTPUTS / "09-grants"

# wiki 컨텍스트 (Karpathy 3-layer 개인 지식 체계)
WIKI_PILOT_DIR = FORGE_ROOT / "shared/lightrag-wiki-data"
WIKI_WORKING_DIR = WIKI_PILOT_DIR / "index"
WIKI_DIR = FORGE_OUTPUTS / "20-wiki"

# archive 컨텍스트 (D/E 드라이브 10년 카탈로그)
ARCHIVE_PILOT_DIR = FORGE_ROOT / "shared/lightrag-archive-data"
ARCHIVE_WORKING_DIR = ARCHIVE_PILOT_DIR / "index"
ARCHIVE_DIR = FORGE_OUTPUTS / "20-wiki" / "30-archive"

PILOT_DIR.mkdir(parents=True, exist_ok=True)
WORKING_DIR.mkdir(parents=True, exist_ok=True)
GRANTS_PILOT_DIR.mkdir(parents=True, exist_ok=True)
GRANTS_WORKING_DIR.mkdir(parents=True, exist_ok=True)
WIKI_PILOT_DIR.mkdir(parents=True, exist_ok=True)
WIKI_WORKING_DIR.mkdir(parents=True, exist_ok=True)
ARCHIVE_PILOT_DIR.mkdir(parents=True, exist_ok=True)
ARCHIVE_WORKING_DIR.mkdir(parents=True, exist_ok=True)


def get_context_paths(context: str) -> tuple[Path, Path]:
    """컨텍스트별 (pilot_dir, working_dir) 반환"""
    if context == "grants":
        return GRANTS_PILOT_DIR, GRANTS_WORKING_DIR
    if context == "wiki":
        return WIKI_PILOT_DIR, WIKI_WORKING_DIR
    if context == "archive":
        return ARCHIVE_PILOT_DIR, ARCHIVE_WORKING_DIR
    return PILOT_DIR, WORKING_DIR

# ── API 키 로드 ────────────────────────────────────────────────────────────
def load_env():
    env_file = FORGE_ROOT / ".env"
    if env_file.exists():
        for line in env_file.read_text().splitlines():
            if "=" in line and not line.startswith("#"):
                k, v = line.split("=", 1)
                os.environ[k.strip()] = v.strip()  # force override (키 갱신 반영)

load_env()

ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY")
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

# ── 품질 검증 쿼리 (한국어 5개) ────────────────────────────────────────────
QUALITY_QUERIES = [
    ("local",   "AI 에이전트 관련 최신 기술 동향은 무엇인가요?"),
    ("global",  "리서치 문서들에서 반복적으로 등장하는 핵심 기술 키워드를 정리해주세요."),
    ("hybrid",  "Claude와 GPT를 비교했을 때 각각의 강점은?"),
    ("local",   "RAG 시스템 구축 시 고려해야 할 핵심 요소는?"),
    ("hybrid",  "2026년 AI 시장에서 주목할 오픈소스 프로젝트는?"),
]


# ── LightRAG 초기화 ────────────────────────────────────────────────────────
async def get_rag(working_dir: Path = WORKING_DIR):
    from functools import partial
    from lightrag import LightRAG
    from lightrag.llm.anthropic import anthropic_complete_if_cache
    from lightrag.llm.gemini import gemini_embed
    from lightrag.utils import EmbeddingFunc

    # anthropic_complete_if_cache는 async generator를 반환 — LightRAG는 str을 기대하므로 수집 필요
    async def llm_func(prompt, system_prompt=None, history_messages=None, **kwargs):
        # LightRAG 내부 파라미터 + 충돌 파라미터 제거
        kwargs.pop("hashing_kv", None)
        kwargs.pop("keyword_extraction", None)
        kwargs.pop("stream", None)          # LightRAG가 stream=False 주입 → 제거
        kwargs.setdefault("max_tokens", 512)   # entity extraction은 짧은 응답으로 충분
        gen = await anthropic_complete_if_cache(
            "claude-haiku-4-5-20251001",
            prompt,
            system_prompt=system_prompt,
            history_messages=history_messages or [],
            api_key=ANTHROPIC_API_KEY,
            **kwargs
        )
        # async generator → 문자열 수집
        result = ""
        async for chunk in gen:
            result += chunk
        return result

    # gemini_embed는 @wrap_embedding_func_with_attrs(embedding_dim=1536)으로 이미 래핑됨
    # .func로 내부 raw 함수를 꺼내서 768차원으로 재래핑
    embed_fn = partial(
        gemini_embed.func,      # EmbeddingFunc 언래핑 → raw retry-decorated async 함수
        model="gemini-embedding-001",
        api_key=GEMINI_API_KEY,
    )

    embedding_func = EmbeddingFunc(
        embedding_dim=768,
        max_token_size=8192,
        send_dimensions=True,   # embedding_dim=768 자동 주입
        func=embed_fn,
    )

    rag = LightRAG(
        working_dir=str(working_dir),
        llm_model_func=llm_func,
        embedding_func=embedding_func,
    )
    await rag.initialize_storages()
    return rag


# ── 문서 수집 ──────────────────────────────────────────────────────────────
def collect_docs(max_docs=50) -> list[dict]:
    """weekly + project + daily 연구 문서에서 최대 max_docs개 수집"""
    docs = []

    # 우선순위: weekly → project → daily
    patterns = [
        RESEARCH_DIR / "weekly",
        RESEARCH_DIR / "projects",
        RESEARCH_DIR / "daily",
        RESEARCH_DIR / "ai-report",
    ]

    for base in patterns:
        if not base.exists():
            continue
        for md in sorted(base.rglob("*.md"), reverse=True):
            if "gate-log" in md.name or "CLAUDE" in md.name:
                continue
            text = md.read_text(errors="ignore").strip()
            if len(text) < 200:  # 너무 짧은 파일 제외
                continue
            docs.append({"path": str(md), "text": text})
            if len(docs) >= max_docs:
                break
        if len(docs) >= max_docs:
            break

    return docs


def collect_grants_docs(grants_dir: Path, max_docs=20) -> list[dict]:
    """정부과제 디렉토리에서 분석 문서 수집 (목차/인수인계 제외)"""
    docs = []
    exclude_patterns = {"gate-log", "CLAUDE", "indexed", "NORTH-STAR", "인수인계", "검수자-피드백"}

    for md in sorted(grants_dir.rglob("*.md"), reverse=True):
        if any(p in md.name for p in exclude_patterns):
            continue
        text = md.read_text(errors="ignore").strip()
        if len(text) < 200:
            continue
        docs.append({"path": str(md), "text": text})
        if len(docs) >= max_docs:
            break

    return docs


def collect_wiki_docs(wiki_dir: Path, max_docs=200) -> list[dict]:
    """20-wiki 디렉토리에서 모든 노트 수집 (Karpathy 3-layer 개인 지식 체계)
    짧은 노트도 의미 있을 수 있어 min length를 100자로 완화.
    mtime 포함 — 수정된 파일도 재인덱싱 가능.
    30-archive/ 는 별도 archive context에서 처리 — wiki에서 제외."""
    docs = []
    exclude_patterns = {"indexed"}

    for md in sorted(wiki_dir.rglob("*.md"), reverse=True):
        if any(p in md.name for p in exclude_patterns):
            continue
        s = str(md)
        # _meta/reviews/는 회고 문서 — 인덱싱 대상에서 제외 (개인적 감상)
        if "_meta/reviews/" in s:
            continue
        # 30-archive/ 는 archive context 전담
        if "/30-archive/" in s:
            continue
        text = md.read_text(errors="ignore").strip()
        if len(text) < 100:
            continue
        docs.append({"path": str(md), "text": text, "mtime": md.stat().st_mtime})
        if len(docs) >= max_docs:
            break

    return docs


def collect_archive_docs(archive_dir: Path, max_docs=500) -> list[dict]:
    """30-archive 카탈로그 카드 수집. 카드는 짧아도(~50자) 의미 있음(경로/카테고리)."""
    docs = []
    for md in sorted(archive_dir.rglob("*.md"), reverse=True):
        if md.name == "exclusions.md":
            continue
        text = md.read_text(errors="ignore").strip()
        if len(text) < 30:
            continue
        docs.append({"path": str(md), "text": text, "mtime": md.stat().st_mtime})
        if len(docs) >= max_docs:
            break
    return docs


# ── 커맨드: index ──────────────────────────────────────────────────────────
async def cmd_index(context: str = "weekly"):
    pilot_dir, working_dir = get_context_paths(context)

    if context == "grants":
        print(f"[{datetime.now().strftime('%H:%M:%S')}] [GRANTS] 정부과제 문서 수집 중...")
        docs = collect_grants_docs(GRANTS_DIR, max_docs=20)
    elif context == "wiki":
        print(f"[{datetime.now().strftime('%H:%M:%S')}] [WIKI] 20-wiki 노트 수집 중...")
        docs = collect_wiki_docs(WIKI_DIR, max_docs=200)
    elif context == "archive":
        print(f"[{datetime.now().strftime('%H:%M:%S')}] [ARCHIVE] 30-archive 카탈로그 카드 수집 중...")
        docs = collect_archive_docs(ARCHIVE_DIR, max_docs=500)
    else:
        print(f"[{datetime.now().strftime('%H:%M:%S')}] 문서 수집 중...")
        docs = collect_docs(max_docs=10)  # 파일럿: 10개로 충분 (rate limit 대응)
    print(f"  → {len(docs)}개 문서 수집완료")

    # indexed.json 스키마: {"path": mtime} (신규) 또는 ["path", ...] (구버전, 자동 마이그레이션)
    indexed_file = pilot_dir / "indexed.json"
    already_indexed: dict[str, float] = {}
    if indexed_file.exists():
        try:
            data = json.loads(indexed_file.read_text())
            if isinstance(data, list):
                # 구버전 → 마이그레이션 (mtime=0으로 처리하여 다음 인덱싱에 모두 재처리)
                already_indexed = {p: 0.0 for p in data}
                print("  → 구버전 indexed.json 감지 — mtime 추적으로 마이그레이션")
            elif isinstance(data, dict):
                already_indexed = {k: float(v) for k, v in data.items()}
        except (json.JSONDecodeError, ValueError) as e:
            print(f"  → indexed.json 파싱 실패 ({e}) — 빈 셋에서 시작")

    # 신규 또는 수정된 파일만 처리 (mtime 비교)
    new_docs = []
    modified_docs = []
    for d in docs:
        doc_mtime = d.get("mtime", 0.0)
        if d["path"] not in already_indexed:
            new_docs.append(d)
        elif doc_mtime > already_indexed[d["path"]] + 1.0:  # 1초 마진
            modified_docs.append(d)

    todo = new_docs + modified_docs
    if not todo:
        print("  → 모든 문서가 최신 상태")
        return

    if new_docs:
        print(f"  → {len(new_docs)}개 신규 문서 인덱싱")
    if modified_docs:
        print(f"  → {len(modified_docs)}개 수정 문서 재인덱싱")
    rag = await get_rag(working_dir)

    t0 = time.time()
    mem_before = _get_mem_mb()

    for i, doc in enumerate(todo, 1):
        path_short = Path(doc["path"]).name
        kind = "(modified)" if doc in modified_docs else "(new)"
        print(f"  [{i:02d}/{len(todo)}] {path_short} {kind}")
        try:
            await rag.ainsert(doc["text"])
            already_indexed[doc["path"]] = doc.get("mtime", time.time())
        except Exception as e:
            print(f"    WARNING: 인덱싱 실패: {e}")

    elapsed = time.time() - t0
    mem_after = _get_mem_mb()

    indexed_file.write_text(json.dumps(already_indexed, indent=2))
    print(f"\nOK 인덱싱 완료: {len(todo)}개 / {elapsed:.1f}s / RAM {mem_before}→{mem_after}MB")


# ── 커맨드: query ──────────────────────────────────────────────────────────
async def cmd_query(question: str, mode: str = "hybrid", context: str = "weekly"):
    from lightrag import QueryParam

    _, working_dir = get_context_paths(context)
    rag = await get_rag(working_dir)
    t0 = time.time()
    result = await rag.aquery(question, param=QueryParam(mode=mode))
    elapsed = time.time() - t0

    ctx_label = f"[{context.upper()}]" if context != "weekly" else ""
    print(f"\n{ctx_label}[{mode.upper()} 모드] {question}")
    print(f"{'─'*60}")
    print(result)
    print(f"\n응답시간: {elapsed:.2f}s")
    return result


# ── 커맨드: check (품질 검증) ─────────────────────────────────────────────
async def cmd_check(context: str = "weekly"):
    from lightrag import QueryParam

    pilot_dir, working_dir = get_context_paths(context)
    rag = await get_rag(working_dir)
    results = []

    print(f"\n{'='*60}")
    print(f"LightRAG 한국어 품질 검증 [{context}] — {len(QUALITY_QUERIES)}개 쿼리")
    print(f"{'='*60}")

    for mode, query in QUALITY_QUERIES:
        print(f"\n[{mode.upper()}] {query}")
        t0 = time.time()
        try:
            result = await rag.aquery(query, param=QueryParam(mode=mode))
            elapsed = time.time() - t0
            korean_ratio = _korean_ratio(result)
            is_ok = len(result) > 100 and "죄송" not in result and "모릅니다" not in result
            results.append({
                "mode": mode,
                "query": query,
                "elapsed": elapsed,
                "length": len(result),
                "korean_ratio": korean_ratio,
                "ok": is_ok,
                "answer_preview": result[:200],
            })
            status = "PASS" if is_ok and korean_ratio > 0.3 else "WARN"
            print(f"  [{status}] {elapsed:.2f}s | {len(result)}자 | 한국어 {korean_ratio:.0%}")
            print(f"  → {result[:120]}...")
        except Exception as e:
            print(f"  FAIL: {e}")
            results.append({"mode": mode, "query": query, "error": str(e)})

    # 요약
    print(f"\n{'='*60}")
    ok_count = sum(1 for r in results if r.get("ok") and r.get("korean_ratio", 0) > 0.3)
    avg_time = sum(r.get("elapsed", 0) for r in results) / max(len(results), 1)
    print(f"결과: {ok_count}/{len(results)} PASS | 평균 {avg_time:.2f}s")

    out = pilot_dir / f"{datetime.now().strftime('%Y-%m-%d')}-check-results.json"
    out.write_text(json.dumps(results, ensure_ascii=False, indent=2))
    print(f"결과 저장: {out}")
    return results


# ── 커맨드: report ──────────────────────────────────────────────────────────
async def cmd_report(context: str = "weekly"):
    check_results = await cmd_check(context)

    pilot_dir, _ = get_context_paths(context)
    indexed_file = pilot_dir / "indexed.json"
    indexed = json.loads(indexed_file.read_text()) if indexed_file.exists() else []

    lines = [
        f"# LightRAG 파일럿 리포트",
        f"**생성**: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
        f"**환경**: WSL2 / RAM 7.8GB / Python 3.10",
        f"",
        f"## 인덱싱 현황",
        f"- 총 인덱싱 문서: {len(indexed)}개",
        f"- 도메인: weekly-research / project-research",
        f"",
        f"## 품질 검증 결과",
    ]

    ok_count = 0
    for r in check_results:
        if "error" in r:
            lines.append(f"- FAIL [{r['mode']}] {r['query'][:40]}... → {r['error']}")
        else:
            passed = r.get("ok") and r.get("korean_ratio", 0) > 0.3
            if passed:
                ok_count += 1
            status = "PASS" if passed else "WARN"
            lines.append(f"- [{status}] [{r['mode']}] {r['query'][:40]}...")
            lines.append(f"  - {r['elapsed']:.2f}s | {r['length']}자 | 한국어 {r.get('korean_ratio', 0):.0%}")

    lines += [
        f"",
        f"## 종합 판정",
        f"- PASS: {ok_count}/{len(check_results)}",
    ]

    if ok_count >= 4:
        lines.append("- **도입 권장** — 한국어 품질 검증 통과")
    elif ok_count >= 2:
        lines.append("- **조건부 도입** — 일부 모드 추가 튜닝 필요")
    else:
        lines.append("- **보류** — 한국어 품질 기준 미달")

    lines += [
        f"",
        f"## 다음 단계",
        f"1. weekly-research 스킬에 LightRAG 통합 PoC",
        f"2. Local/Global/Hybrid 모드별 use-case 정의",
        f"3. 비용 분석 (임베딩 호출 수 × Gemini API 단가)",
    ]

    report = "\n".join(lines)
    out_dir = FORGE_OUTPUTS / "docs/tech"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_file = out_dir / f"{datetime.now().strftime('%Y-%m-%d')}-lightrag-pilot-report.md"
    out_file.write_text(report)
    print(f"\nOK 리포트 저장: {out_file}")
    print(report)


# ── 유틸 ──────────────────────────────────────────────────────────────────
def _get_mem_mb() -> int:
    try:
        import psutil
        return psutil.Process().memory_info().rss // (1024 * 1024)
    except Exception:
        return 0


def _korean_ratio(text: str) -> float:
    if not text:
        return 0.0
    korean = sum(1 for c in text if '\uAC00' <= c <= '\uD7A3')
    return korean / len(text)


# ── 메인 ──────────────────────────────────────────────────────────────────
def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    cmd = sys.argv[1]

    if not ANTHROPIC_API_KEY:
        print("ANTHROPIC_API_KEY 없음")
        sys.exit(1)
    if not GEMINI_API_KEY:
        print("GEMINI_API_KEY 없음")
        sys.exit(1)

    # --context 파싱 (마지막 인자에서 추출)
    context = "weekly"
    args = sys.argv[2:]
    if "--context" in args:
        idx = args.index("--context")
        if idx + 1 < len(args):
            context = args[idx + 1]
            args = args[:idx] + args[idx + 2:]
    if context not in ("weekly", "grants", "wiki", "archive"):
        print(f"알 수 없는 context: {context} (weekly|grants|wiki|archive)")
        sys.exit(1)

    if cmd == "index":
        asyncio.run(cmd_index(context))
    elif cmd == "query":
        if not args:
            print("사용법: lightrag-pilot.py query \"질문\" [local|global|hybrid] [--context grants]")
            sys.exit(1)
        question = args[0]
        mode = args[1] if len(args) > 1 else "hybrid"
        asyncio.run(cmd_query(question, mode, context))
    elif cmd == "check":
        asyncio.run(cmd_check(context))
    elif cmd == "report":
        asyncio.run(cmd_report(context))
    else:
        print(f"알 수 없는 명령: {cmd}")
        sys.exit(1)


if __name__ == "__main__":
    main()
