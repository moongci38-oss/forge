#!/usr/bin/env python3
"""wiki-sync-lint — Raw 레이어에서 아직 20-wiki로 승격되지 않은 문서를 **보고만** 하는 스크립트.

실제 sync는 수행하지 않는다(읽기 전용). cron으로 월 1회 호출해
_meta/lint-log.md 갱신 + 선택적 텔레그램 알림.

Scope 원칙:
- wiki-sync SKILL의 Step 1 스캔 로직 재현, 후속 단계(Read/Propose/Apply) 생략
- sync-tracking.json 기준으로 "not ingested" 판정
- 수정 권한: _meta/lint-log.md 쓰기만. 다른 파일 일체 변경 금지.
"""

from __future__ import annotations
import json
import sys
from datetime import datetime, timezone, timedelta
from pathlib import Path

FORGE_OUTPUTS = Path.home() / "forge-outputs"
WIKI = FORGE_OUTPUTS / "20-wiki"
TRACKING = WIKI / "_meta" / "sync-tracking.json"
LINT_LOG = WIKI / "_meta" / "lint-log.md"

RAW_DIRS = [
    FORGE_OUTPUTS / "01-research" / "videos" / "analyses",
    FORGE_OUTPUTS / "01-research" / "daily",
    FORGE_OUTPUTS / "01-research" / "weekly",
    FORGE_OUTPUTS / "01-research" / "projects",
    FORGE_OUTPUTS / "01-research" / "link-analyses",
    WIKI / "_clipper",  # Obsidian Web Clipper (P2-2)
]

RECENCY_DAYS = 90  # 90일 이내만 리포트


def main() -> int:
    if not TRACKING.exists():
        ingested: set[str] = set()
    else:
        try:
            data = json.loads(TRACKING.read_text(encoding="utf-8"))
            ingested = set(data.get("ingested", []))
        except Exception as e:
            print(f"sync-tracking.json parse error: {e}", file=sys.stderr)
            ingested = set()

    now = datetime.now(timezone.utc)
    cutoff = now - timedelta(days=RECENCY_DAYS)

    pending: dict[str, list[dict]] = {}
    for raw_dir in RAW_DIRS:
        if not raw_dir.exists():
            continue
        key = raw_dir.name
        for md in sorted(raw_dir.rglob("*.md")):
            if md.name.lower() == "readme.md":
                continue
            if str(md) in ingested:
                continue
            try:
                mtime = datetime.fromtimestamp(md.stat().st_mtime, tz=timezone.utc)
            except OSError:
                continue
            if mtime < cutoff:
                continue
            pending.setdefault(key, []).append({
                "path": str(md),
                "name": md.name,
                "mtime": mtime.strftime("%Y-%m-%d"),
                "size": md.stat().st_size,
            })

    total_pending = sum(len(v) for v in pending.values())
    total_ingested = len(ingested)

    # write lint log (append-ish — full rewrite with last 10 runs preserved)
    existing = LINT_LOG.read_text(encoding="utf-8") if LINT_LOG.exists() else ""

    header = (
        f"# wiki-sync Lint Log\n\n"
        f"Raw→Wiki 승격 대기 리포트. `/wiki-sync` 수동 호출 시점을 판단하는 용도.\n"
        f"스크립트: `forge/shared/scripts/wiki-sync-lint.py` (읽기 전용, 월 1회 cron)\n\n"
    )
    run_report = [
        f"## {now.strftime('%Y-%m-%d %H:%M UTC')}",
        "",
        f"- **Pending (최근 {RECENCY_DAYS}일 내 미승격)**: {total_pending}",
        f"- **Already ingested**: {total_ingested}",
        "",
    ]
    if total_pending == 0:
        run_report.append("_모든 Raw 문서가 이미 승격되었거나 cutoff 밖입니다._")
    else:
        for category, items in sorted(pending.items()):
            run_report.append(f"### `{category}` ({len(items)})")
            for it in sorted(items, key=lambda x: x["mtime"], reverse=True)[:10]:
                run_report.append(f"- {it['mtime']} `{it['name']}`")
            if len(items) > 10:
                run_report.append(f"- _... {len(items) - 10}개 더_")
            run_report.append("")
    run_report.append("---\n")

    # keep only last 10 runs — split existing by "## YYYY-" headings
    previous_runs = []
    if existing:
        parts = existing.split("## ")
        if parts and parts[0].startswith("# wiki-sync Lint Log"):
            parts = parts[1:]
        previous_runs = ["## " + p for p in parts if p.strip()]
    keep = previous_runs[:9]  # we'll prepend new run, keeping total at 10

    out = header + "\n".join(run_report) + "\n" + "".join(keep)
    LINT_LOG.write_text(out, encoding="utf-8")

    # stdout summary for cron / manual invocation
    print(f"wiki-sync lint: {total_pending} pending Raw docs (last {RECENCY_DAYS}d), {total_ingested} already ingested")
    for category, items in sorted(pending.items()):
        print(f"  {category}: {len(items)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
