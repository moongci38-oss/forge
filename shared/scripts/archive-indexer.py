#!/usr/bin/env python3
"""archive-indexer — D/E/Z 드라이브를 스캔해 Obsidian vault의 색인 카드(.md)로 정리한다.

Subcommands:
  scan    드라이브 루트를 walk하고 클러스터별(top-level 폴더 + loose file 버킷) 집계 → scan-preview.json + summary.md
  cards   scan 결과를 기반으로 forge-vault/30-archive/<drive>/<category>/<slug>.md 카드 생성
  index   카드별 대표 파일을 LightRAG archive context에 임베딩 (Q3=c)

Iron Laws:
  - 원본 파일 이동·삭제·rename 금지. scan/cards/index 모두 read-only on source.
  - vault 쓰기는 cards/index 단계에서만. scan은 forge-outputs/30-archive-meta/에 JSON/MD만 쓴다.
  - 10MB 초과 단일 파일은 카드에 링크만 (복사 금지 — index 단계에서 임베딩 대상 제외).
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import sys
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

# ---------- Paths ----------
SCRIPT_DIR = Path(__file__).resolve().parent
EXCLUSIONS_FILE = SCRIPT_DIR / "archive-exclusions.txt"
FORGE_OUTPUTS = Path(os.environ.get("FORGE_OUTPUTS", str(Path.home() / "forge-outputs")))
META_DIR = FORGE_OUTPUTS / "30-archive-meta"

# ---------- Classification ----------
DOCUMENT_EXTS = {".pdf", ".docx", ".doc", ".pptx", ".ppt", ".hwp", ".hwpx", ".xlsx", ".xls", ".csv", ".md", ".txt", ".rtf", ".odt"}
MEDIA_EXTS = {".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".webp", ".psd", ".ai", ".svg", ".mp4", ".mov", ".avi", ".mkv", ".wmv", ".mp3", ".wav", ".flac"}
CODE_EXTS = {".py", ".js", ".ts", ".tsx", ".jsx", ".java", ".kt", ".cs", ".cpp", ".c", ".h", ".go", ".rs", ".rb", ".php", ".swift", ".m", ".sh", ".sql", ".html", ".css", ".scss", ".vue"}
ARCHIVE_EXTS = {".zip", ".tar", ".gz", ".rar", ".7z", ".iso"}

PROJECT_MARKERS = {".git", "package.json", "pom.xml", "build.gradle", "Cargo.toml", "pyproject.toml", "requirements.txt", "composer.json", "Gemfile", "go.mod", "Makefile", "CMakeLists.txt"}
PROJECT_MARKER_EXTS = {".sln", ".csproj", ".xcodeproj"}

LOOSE_BUCKET_LIMIT = 500  # 루트 loose file을 연도별 버킷으로 묶을 최대 파일 수

# ---------- Exclusion ----------

def load_exclusions() -> tuple[list[str], list[str]]:
    """Return (basename_patterns, path_substrings)."""
    if not EXCLUSIONS_FILE.exists():
        return [], []
    basename_pat: list[str] = []
    path_pat: list[str] = []
    for line in EXCLUSIONS_FILE.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("path:"):
            path_pat.append(line[len("path:"):])
        else:
            basename_pat.append(line)
    return basename_pat, path_pat


def is_excluded(path: Path, basename_pats: list[str], path_pats: list[str]) -> bool:
    name = path.name
    for pat in basename_pats:
        if fnmatch.fnmatch(name, pat):
            return True
    full = str(path)
    for sub in path_pats:
        if sub in full:
            return True
    return False


# ---------- Classification helpers ----------

def classify_cluster(root: Path, file_exts: dict[str, int], has_project_marker: bool) -> str:
    if has_project_marker:
        return "projects"
    # 전체 파일 수 기준 최대 카테고리
    totals = {"documents": 0, "media": 0, "code": 0, "other": 0}
    for ext, count in file_exts.items():
        if ext in DOCUMENT_EXTS:
            totals["documents"] += count
        elif ext in MEDIA_EXTS:
            totals["media"] += count
        elif ext in CODE_EXTS:
            totals["code"] += count
        else:
            totals["other"] += count
    # code 우세하면 projects로 승격 (marker 없어도)
    if totals["code"] > 0 and totals["code"] >= max(totals["documents"], totals["media"]):
        return "projects"
    if totals["documents"] >= max(totals["media"], totals["code"], totals["other"]):
        return "documents"
    if totals["media"] >= max(totals["documents"], totals["code"], totals["other"]):
        return "media"
    return "_orphan"


def classify_loose_file(path: Path) -> str:
    ext = path.suffix.lower()
    if ext in DOCUMENT_EXTS:
        return "documents"
    if ext in MEDIA_EXTS:
        return "media"
    if ext in CODE_EXTS:
        return "code"
    if ext in ARCHIVE_EXTS:
        return "archives"
    return "other"


# ---------- Walking ----------

@dataclass
class ClusterStat:
    source_path: str
    drive: str
    name: str
    category: str
    total_files: int = 0
    total_bytes: int = 0
    oldest_mtime: float = 0.0
    newest_mtime: float = 0.0
    has_project_marker: bool = False
    ext_counts: dict[str, int] = field(default_factory=dict)
    sample_files: list[str] = field(default_factory=list)  # 대표 파일 5개 (최근 mtime 우선)
    skipped: int = 0
    errors: int = 0

    def to_summary(self) -> dict:
        return {
            "source_path": self.source_path,
            "drive": self.drive,
            "name": self.name,
            "category": self.category,
            "total_files": self.total_files,
            "total_bytes": self.total_bytes,
            "total_mb": round(self.total_bytes / 1_000_000, 2),
            "oldest_date": fmt_date(self.oldest_mtime),
            "newest_date": fmt_date(self.newest_mtime),
            "has_project_marker": self.has_project_marker,
            "top_exts": top_exts(self.ext_counts, 5),
            "sample_files": self.sample_files,
            "skipped": self.skipped,
            "errors": self.errors,
        }


def fmt_date(ts: float) -> str:
    if ts <= 0:
        return ""
    return datetime.fromtimestamp(ts, tz=timezone.utc).strftime("%Y-%m-%d")


def top_exts(counts: dict[str, int], n: int) -> list[tuple[str, int]]:
    return sorted(counts.items(), key=lambda kv: kv[1], reverse=True)[:n]


def walk_cluster(root: Path, drive: str, basename_pats: list[str], path_pats: list[str]) -> ClusterStat:
    stat = ClusterStat(source_path=str(root), drive=drive, name=root.name, category="unknown")
    # quick check: project marker at root
    try:
        children = list(root.iterdir())
    except (PermissionError, OSError):
        stat.errors += 1
        return stat
    for child in children:
        if child.name in PROJECT_MARKERS or child.suffix.lower() in PROJECT_MARKER_EXTS:
            stat.has_project_marker = True
            break

    sample_candidates: list[tuple[float, str]] = []
    for current_root, dirs, files in os.walk(root, followlinks=False, onerror=lambda e: None):
        current_path = Path(current_root)
        # in-place filter dirs
        dirs[:] = [d for d in dirs if not is_excluded(current_path / d, basename_pats, path_pats)]
        for fname in files:
            fpath = current_path / fname
            if is_excluded(fpath, basename_pats, path_pats):
                stat.skipped += 1
                continue
            try:
                st = fpath.stat()
            except (PermissionError, OSError):
                stat.errors += 1
                continue
            stat.total_files += 1
            stat.total_bytes += st.st_size
            mtime = st.st_mtime
            if stat.oldest_mtime == 0 or mtime < stat.oldest_mtime:
                stat.oldest_mtime = mtime
            if mtime > stat.newest_mtime:
                stat.newest_mtime = mtime
            ext = fpath.suffix.lower()
            stat.ext_counts[ext] = stat.ext_counts.get(ext, 0) + 1
            sample_candidates.append((mtime, str(fpath)))

    # top 5 newest
    sample_candidates.sort(key=lambda t: t[0], reverse=True)
    stat.sample_files = [p for _, p in sample_candidates[:5]]
    stat.category = classify_cluster(root, stat.ext_counts, stat.has_project_marker)
    return stat


def walk_drive(drive_root: Path, drive_label: str, basename_pats: list[str], path_pats: list[str], incremental_out: Path | None = None) -> dict:
    """Return {'clusters': [...], 'loose_buckets': [...], 'summary': {...}}.

    If incremental_out is set, append each cluster to jsonl immediately so kill-resilient.
    """
    clusters: list[ClusterStat] = []
    loose_files: list[tuple[Path, os.stat_result]] = []
    summary = {"drive": drive_label, "root": str(drive_root), "top_level_errors": [], "excluded_top_level": []}

    try:
        entries = list(drive_root.iterdir())
    except (PermissionError, OSError) as e:
        summary["top_level_errors"].append(f"iterdir failed: {e}")
        return {"clusters": [], "loose_buckets": [], "summary": summary}

    print(f"[walk] {drive_label}: {len(entries)} top-level entries", file=sys.stderr, flush=True)
    t0 = datetime.now()
    for i, entry in enumerate(entries, 1):
        if is_excluded(entry, basename_pats, path_pats):
            summary["excluded_top_level"].append(entry.name)
            print(f"[skip] {drive_label} ({i}/{len(entries)}) {entry.name}", file=sys.stderr, flush=True)
            continue
        if entry.is_dir():
            t_start = datetime.now()
            stat = walk_cluster(entry, drive_label, basename_pats, path_pats)
            elapsed = (datetime.now() - t_start).total_seconds()
            clusters.append(stat)
            print(f"[done] {drive_label} ({i}/{len(entries)}) {entry.name}: {stat.total_files:,} files, {stat.total_bytes/1e6:,.1f}MB, cat={stat.category}, {elapsed:.1f}s", file=sys.stderr, flush=True)
            if incremental_out:
                with incremental_out.open("a", encoding="utf-8") as fh:
                    fh.write(json.dumps({"type": "cluster", "drive": drive_label, **stat.to_summary()}, ensure_ascii=False) + "\n")
        elif entry.is_file():
            try:
                st = entry.stat()
                loose_files.append((entry, st))
            except (PermissionError, OSError):
                summary["top_level_errors"].append(f"stat failed: {entry.name}")

    # loose_files → 연도 + 카테고리 버킷
    buckets: dict[tuple[str, str], dict] = {}
    for fpath, st in loose_files:
        year = datetime.fromtimestamp(st.st_mtime, tz=timezone.utc).strftime("%Y")
        cat = classify_loose_file(fpath)
        key = (year, cat)
        b = buckets.setdefault(key, {
            "drive": drive_label,
            "bucket": f"loose-{year}-{cat}",
            "category": cat,
            "year": year,
            "total_files": 0,
            "total_bytes": 0,
            "sample_files": [],
        })
        b["total_files"] += 1
        b["total_bytes"] += st.st_size
        if len(b["sample_files"]) < 5:
            b["sample_files"].append(str(fpath))

    loose_buckets = sorted(buckets.values(), key=lambda b: (b["year"], b["category"]))
    for lb in loose_buckets:
        lb["total_mb"] = round(lb["total_bytes"] / 1_000_000, 2)

    return {
        "clusters": [c.to_summary() for c in clusters],
        "loose_buckets": loose_buckets,
        "summary": summary,
    }


# ---------- Commands ----------

def cmd_scan(args: argparse.Namespace) -> int:
    basename_pats, path_pats = load_exclusions()
    META_DIR.mkdir(parents=True, exist_ok=True)

    drives = args.drives or ["/mnt/d:d", "/mnt/e:e"]
    result = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "exclusions": {"basename_patterns": basename_pats, "path_patterns": path_pats},
        "drives": [],
    }
    for spec in drives:
        if ":" in spec:
            root_str, label = spec.rsplit(":", 1)
        else:
            root_str, label = spec, Path(spec).name
        root = Path(root_str)
        if not root.exists():
            print(f"[skip] {root} not found", file=sys.stderr, flush=True)
            continue
        print(f"[scan] {label} = {root}", file=sys.stderr, flush=True)
        incr = META_DIR / f"scan-progress-{label}.jsonl"
        if incr.exists():
            incr.unlink()
        result["drives"].append(walk_drive(root, label, basename_pats, path_pats, incremental_out=incr))

    out_json = META_DIR / "scan-preview.json"
    out_json.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[write] {out_json}", file=sys.stderr)

    # human-readable summary
    md_lines = [f"# Archive Scan Preview\n\n_Generated: {result['generated_at']}_\n"]
    for d in result["drives"]:
        s = d["summary"]
        md_lines.append(f"\n## Drive `{s['drive']}` — `{s['root']}`\n")
        if s["excluded_top_level"]:
            md_lines.append(f"**Excluded (top-level)**: {', '.join(s['excluded_top_level'])}\n")
        if s["top_level_errors"]:
            md_lines.append(f"**Errors**: {len(s['top_level_errors'])}\n")

        clusters = d["clusters"]
        total_files = sum(c["total_files"] for c in clusters)
        total_mb = sum(c["total_mb"] for c in clusters)
        md_lines.append(f"\n### Clusters ({len(clusters)}) — {total_files:,} files, {total_mb:,.1f} MB\n")
        md_lines.append("| Name | Category | Files | MB | Oldest | Newest | Git |\n|---|---|---:|---:|---|---|:---:|\n")
        for c in sorted(clusters, key=lambda x: x["total_bytes"], reverse=True):
            git = "✓" if c["has_project_marker"] else ""
            md_lines.append(
                f"| {c['name']} | {c['category']} | {c['total_files']:,} | {c['total_mb']:,.1f} | "
                f"{c['oldest_date']} | {c['newest_date']} | {git} |\n"
            )

        lb = d["loose_buckets"]
        if lb:
            lb_files = sum(b["total_files"] for b in lb)
            lb_mb = sum(b["total_mb"] for b in lb)
            md_lines.append(f"\n### Loose-file buckets ({len(lb)}) — {lb_files:,} files, {lb_mb:,.1f} MB\n")
            md_lines.append("| Year | Category | Files | MB |\n|---|---|---:|---:|\n")
            for b in lb:
                md_lines.append(f"| {b['year']} | {b['category']} | {b['total_files']:,} | {b['total_mb']:,.1f} |\n")

    out_md = META_DIR / "scan-preview.md"
    out_md.write_text("".join(md_lines), encoding="utf-8")
    print(f"[write] {out_md}", file=sys.stderr)
    return 0


def cmd_scan_one(args: argparse.Namespace) -> int:
    """Walk a single top-level cluster and emit its summary as one JSON line to stdout."""
    basename_pats, path_pats = load_exclusions()
    root = Path(args.path)
    if not root.exists():
        print(json.dumps({"error": "not_found", "path": str(root)}), flush=True)
        return 2
    if root.is_file():
        # loose file: minimal info
        try:
            st = root.stat()
        except OSError as e:
            print(json.dumps({"error": str(e), "path": str(root)}), flush=True)
            return 2
        print(json.dumps({
            "type": "file", "drive": args.drive, "name": root.name,
            "source_path": str(root), "size": st.st_size, "mtime": st.st_mtime,
        }, ensure_ascii=False), flush=True)
        return 0
    stat = walk_cluster(root, args.drive, basename_pats, path_pats)
    payload = {"type": "cluster", "drive": args.drive, **stat.to_summary()}
    print(json.dumps(payload, ensure_ascii=False), flush=True)
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description="Archive indexer for D/E/Z drives → Obsidian vault")
    sub = p.add_subparsers(dest="command", required=True)

    p_scan = sub.add_parser("scan", help="Walk drives and produce scan-preview.json + .md")
    p_scan.add_argument("--drives", nargs="*", help="drive specs like /mnt/d:d (default: /mnt/d:d /mnt/e:e)")
    p_scan.set_defaults(func=cmd_scan)

    p_one = sub.add_parser("scan-one", help="Walk a single cluster and emit one JSON line")
    p_one.add_argument("--drive", required=True, help="drive label (d/e/z)")
    p_one.add_argument("--path", required=True, help="absolute path to cluster root")
    p_one.set_defaults(func=cmd_scan_one)

    args = p.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
