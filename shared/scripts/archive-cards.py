#!/usr/bin/env python3
"""archive-cards — deep-{drive}.jsonl을 읽어 forge-vault/30-archive/ 카드(.md)를 생성한다.

- 클러스터 1개 = 카드 1개
- 경로: {VAULT}/30-archive/{drive}/{category}/{slug}.md
- 프론트매터: source_path, drive, category, total_files, total_mb, oldest_date, newest_date, has_git, top_exts
- 본문: 대표 파일 리스트 + 승격 체크박스
- loose files는 드라이브별로 loose-files.md 한 장에 집계
- _meta/scan-log.json, _meta/promotion-queue.md, _meta/exclusions.md 동시 생성
"""

from __future__ import annotations
import json
import re
from datetime import datetime, timezone
from pathlib import Path

META = Path("/home/damools/forge-outputs/30-archive-meta")
VAULT = Path("/home/damools/forge-outputs/20-wiki")
ARCHIVE_ROOT = VAULT / "30-archive"
EXCLUSIONS_FILE = Path("/home/damools/forge/shared/scripts/archive-exclusions.txt")


def slugify(name: str) -> str:
    # keep hangul + latin + digit; replace others with -
    s = re.sub(r"[\s/\\:*?\"<>|]+", "-", name.strip())
    s = re.sub(r"-+", "-", s).strip("-")
    return s or "unnamed"


def front_matter(cluster: dict) -> str:
    tags = ["archive", f"drive/{cluster['drive']}", f"category/{cluster['category']}"]
    if cluster.get("has_project_marker"):
        tags.append("has-git")
    fm = [
        "---",
        f"source_path: {json_str(cluster['source_path'])}",
        f"drive: {cluster['drive']}",
        f"category: {cluster['category']}",
        f"total_files: {cluster['total_files']}",
        f"total_mb: {cluster['total_mb']}",
        f"oldest_date: {cluster['oldest_date']}",
        f"newest_date: {cluster['newest_date']}",
        f"has_git: {str(cluster.get('has_project_marker', False)).lower()}",
        "tags:",
    ]
    for t in tags:
        fm.append(f"  - {t}")
    fm.append("---")
    return "\n".join(fm)


def json_str(s: str) -> str:
    """YAML-safe string literal."""
    if ":" in s or "#" in s or s.startswith("-"):
        return '"' + s.replace('"', '\\"') + '"'
    return s


def cluster_card(cluster: dict) -> str:
    lines = [front_matter(cluster), "", f"# {cluster['name']}", ""]
    lines.append(f"**원본 경로**: `{cluster['source_path']}`  ")
    lines.append(f"**드라이브**: {cluster['drive']}  ")
    lines.append(f"**카테고리**: {cluster['category']}  ")
    lines.append(f"**파일 수**: {cluster['total_files']:,}  ")
    lines.append(f"**총 용량**: {cluster['total_mb']:,.1f} MB ({cluster['total_mb']/1024:.2f} GB)  ")
    lines.append(f"**기간**: {cluster['oldest_date']} → {cluster['newest_date']}  ")
    if cluster.get("has_project_marker"):
        lines.append("**Git/프로젝트 마커**: ✓")
    lines.append("")

    top_exts = cluster.get("top_exts", [])
    if top_exts:
        lines.append("## 파일 타입 분포")
        for ext, cnt in top_exts:
            lines.append(f"- `{ext or '(ext없음)'}`: {cnt:,}")
        lines.append("")

    samples = cluster.get("sample_files", [])
    if samples:
        lines.append("## 대표 파일 (최근 mtime top 5)")
        for s in samples:
            lines.append(f"- `{s}`")
        lines.append("")

    lines.append("## 승격 결정")
    lines.append("- [ ] 20-wiki로 승격 (concepts/tools/topics에 축약 노트 작성)")
    lines.append("- [ ] 보관만 유지 (이 카드로 충분)")
    lines.append("- [ ] 폐기 후보 (원본 삭제 검토)")
    lines.append("")
    lines.append("## 비고")
    lines.append("")
    return "\n".join(lines) + "\n"


def loose_card(drive: str, files: list[dict]) -> str:
    by_ext: dict[str, list[dict]] = {}
    for f in files:
        ext = Path(f["name"]).suffix.lower() or "(none)"
        by_ext.setdefault(ext, []).append(f)
    total = sum(f.get("size", 0) for f in files) / 1e6

    lines = [
        "---",
        f"source_path: /mnt/{drive}/",
        f"drive: {drive}",
        "category: loose",
        f"total_files: {len(files)}",
        f"total_mb: {total:.2f}",
        "tags:",
        "  - archive",
        f"  - drive/{drive}",
        "  - category/loose",
        "---",
        "",
        f"# Drive `{drive}` — Loose files at root",
        "",
        f"**총 파일 수**: {len(files):,}  ",
        f"**총 용량**: {total:,.1f} MB",
        "",
    ]
    for ext, lst in sorted(by_ext.items(), key=lambda kv: -sum(f.get("size", 0) for f in kv[1])):
        ext_total = sum(f.get("size", 0) for f in lst) / 1e6
        lines.append(f"## `{ext}` ({len(lst)} files, {ext_total:,.1f} MB)")
        for f in sorted(lst, key=lambda x: x.get("size", 0), reverse=True):
            size_mb = f.get("size", 0) / 1e6
            mt = datetime.fromtimestamp(f.get("mtime", 0), tz=timezone.utc).strftime("%Y-%m-%d")
            lines.append(f"- `{f['source_path']}` — {size_mb:,.2f} MB, {mt}")
        lines.append("")
    return "\n".join(lines) + "\n"


def drive_index_card(drive: str, clusters: list[dict], loose_count: int, errors: list[dict]) -> str:
    total_mb = sum(c["total_mb"] for c in clusters)
    total_files = sum(c["total_files"] for c in clusters)
    by_cat: dict[str, list[dict]] = {}
    for c in clusters:
        by_cat.setdefault(c["category"], []).append(c)

    lines = [
        "---",
        f"drive: {drive}",
        "category: _index",
        "tags:",
        "  - archive",
        f"  - drive/{drive}",
        "  - index",
        "---",
        "",
        f"# Drive `{drive}` 인덱스",
        "",
        f"**클러스터**: {len(clusters)}  ",
        f"**총 파일**: {total_files:,}  ",
        f"**총 용량**: {total_mb:,.1f} MB ({total_mb/1024:,.2f} GB)  ",
        f"**Loose 파일**: {loose_count}  ",
        f"**Timeout/Error**: {len(errors)}",
        "",
    ]
    for cat in ["projects", "documents", "media", "_orphan"]:
        lst = by_cat.get(cat, [])
        if not lst:
            continue
        cat_mb = sum(c["total_mb"] for c in lst)
        lines.append(f"## {cat} ({len(lst)}, {cat_mb:,.1f} MB)")
        for c in sorted(lst, key=lambda x: x["total_mb"], reverse=True):
            slug = slugify(c["name"])
            git = " 🔧" if c.get("has_project_marker") else ""
            lines.append(f"- [[{slug}|{c['name']}]] — {c['total_mb']:,.1f} MB, {c['total_files']} files{git}")
        lines.append("")
    if errors:
        lines.append("## 스캔 오류/타임아웃")
        for e in errors:
            lines.append(f"- `{e['name']}`: {e.get('status', 'error')} ({e.get('elapsed', 0)}s)")
        lines.append("")
    return "\n".join(lines) + "\n"


def main() -> int:
    ARCHIVE_ROOT.mkdir(parents=True, exist_ok=True)
    (ARCHIVE_ROOT / "_meta").mkdir(exist_ok=True)

    scan_log = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "drives": {},
    }
    promotion_queue: list[tuple[int, dict]] = []  # (heuristic_priority, cluster)

    for drive in ["d", "e"]:
        for sub in ["projects", "documents", "media", "_orphan", "loose"]:
            (ARCHIVE_ROOT / drive / sub).mkdir(parents=True, exist_ok=True)

        clusters: list[dict] = []
        files: list[dict] = []
        for line in (META / f"deep-{drive}.jsonl").read_text(encoding="utf-8").splitlines():
            if not line.strip():
                continue
            e = json.loads(line)
            if e.get("type") == "cluster":
                clusters.append(e)
            elif e.get("type") == "file":
                files.append(e)
        # Loose files were not processed in deep walk (orchestrator skipped non-dirs).
        # Load them from shallow-{drive}.jsonl to ensure root files are cataloged.
        shallow_file = META / f"shallow-{drive}.jsonl"
        if shallow_file.exists():
            for line in shallow_file.read_text(encoding="utf-8").splitlines():
                if not line.strip():
                    continue
                sh = json.loads(line)
                if sh.get("type") == "file":
                    files.append({
                        "type": "file",
                        "drive": drive,
                        "name": sh["name"],
                        "source_path": f"/mnt/{drive}/{sh['name']}",
                        "size": sh.get("size", 0),
                        "mtime": sh.get("mtime", 0),
                    })
        errors = []
        err_file = META / f"deep-{drive}-errors.jsonl"
        if err_file.exists():
            errors = [json.loads(l) for l in err_file.read_text(encoding="utf-8").splitlines() if l.strip()]

        # cluster cards
        written = 0
        for c in clusters:
            cat = c.get("category", "_orphan")
            if cat not in ("projects", "documents", "media", "_orphan"):
                cat = "_orphan"
            slug = slugify(c["name"])
            card_path = ARCHIVE_ROOT / drive / cat / f"{slug}.md"
            card_path.write_text(cluster_card(c), encoding="utf-8")
            written += 1

            # promotion heuristic: has_git OR (newest within last 3 years AND >5MB)
            now_yr = datetime.now().year
            try:
                newest_yr = int(c["newest_date"][:4]) if c["newest_date"] else 0
            except Exception:
                newest_yr = 0
            prio = 0
            if c.get("has_project_marker"):
                prio += 10
            if newest_yr >= now_yr - 3:
                prio += 5
            if c.get("total_mb", 0) > 5:
                prio += 2
            if prio >= 5:
                promotion_queue.append((prio, c))

        # loose files card
        if files:
            loose_path = ARCHIVE_ROOT / drive / "loose" / "loose-files.md"
            loose_path.write_text(loose_card(drive, files), encoding="utf-8")

        # timed-out clusters: placeholder cards so they show in Obsidian
        for e in errors:
            slug = slugify(e["name"])
            card_path = ARCHIVE_ROOT / drive / "_orphan" / f"{slug}-TIMEOUT.md"
            card_path.write_text(
                "---\n"
                f"drive: {drive}\n"
                "category: _timeout\n"
                f"status: {e.get('status', 'error')}\n"
                f"source_path: /mnt/{drive}/{e['name']}\n"
                "tags:\n  - archive\n  - timeout\n---\n\n"
                f"# {e['name']} (TIMEOUT)\n\n"
                f"Deep walk가 {e.get('elapsed', 0)}초 후 timeout됨. drvfs 9P 병목 또는 거대 캐시 디렉토리(Library/Temp/node_modules 등) 추정.\n\n"
                f"**원본 경로**: `/mnt/{drive}/{e['name']}`\n\n"
                "## 조치\n- [ ] 수동 스캔 필요 시 구체적 하위 경로를 지정해 archive-indexer scan-one 재실행\n"
                "- [ ] 대형 캐시 폴더는 제외 경로 추가 후 재시도\n",
                encoding="utf-8",
            )

        # drive index card
        index_path = ARCHIVE_ROOT / drive / "_INDEX.md"
        index_path.write_text(drive_index_card(drive, clusters, len(files), errors), encoding="utf-8")

        scan_log["drives"][drive] = {
            "clusters_ok": len(clusters),
            "loose_files": len(files),
            "timeouts": len(errors),
            "total_mb": sum(c["total_mb"] for c in clusters),
            "total_files": sum(c["total_files"] for c in clusters),
            "cards_written": written,
        }

    # _meta/scan-log.json
    (ARCHIVE_ROOT / "_meta" / "scan-log.json").write_text(
        json.dumps(scan_log, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    # _meta/promotion-queue.md
    promotion_queue.sort(key=lambda t: -t[0])
    pq_lines = [
        "# Promotion Queue — 20-wiki 승격 후보",
        "",
        f"_Generated: {scan_log['generated_at']}_",
        "",
        "Heuristic: git marker(+10), 최근 3년(+5), 5MB+(+2). 우선순위 높은 순.",
        "",
        "| 우선순위 | 드라이브 | 클러스터 | 카테고리 | MB | 기간 |",
        "|---:|:---:|---|---|---:|---|",
    ]
    for prio, c in promotion_queue[:50]:
        slug = slugify(c["name"])
        cat = c.get("category", "_orphan")
        pq_lines.append(
            f"| {prio} | {c['drive']} | [[{slug}|{c['name']}]] | {cat} | {c['total_mb']:,.1f} | {c['oldest_date']}→{c['newest_date']} |"
        )
    (ARCHIVE_ROOT / "_meta" / "promotion-queue.md").write_text("\n".join(pq_lines) + "\n", encoding="utf-8")

    # _meta/exclusions.md
    if EXCLUSIONS_FILE.exists():
        (ARCHIVE_ROOT / "_meta" / "exclusions.md").write_text(
            "# Archive Exclusions\n\n```\n" + EXCLUSIONS_FILE.read_text(encoding="utf-8") + "\n```\n",
            encoding="utf-8",
        )

    # summary output
    print(json.dumps(scan_log, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
