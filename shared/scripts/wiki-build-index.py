#!/usr/bin/env python3
"""wiki-build-index — 모든 wiki 페이지를 스캔해 _meta/index.md를 생성한다.

출력: 카테고리별로 정렬된 목록 (페이지명, 한 줄 요약, tags, source 수).
첫 H1 뒤의 첫 문단을 한 줄 요약으로 추출.
stub 페이지는 ⭐ 표시.
"""

from __future__ import annotations
import re
from pathlib import Path
from datetime import datetime, timezone

WIKI = Path("/home/damools/forge-outputs/20-wiki")
INDEX = WIKI / "_meta" / "index.md"


def parse_page(md: Path) -> dict:
    text = md.read_text(encoding="utf-8")
    info = {"slug": md.stem, "stub": False, "tags": [], "sources_count": 0, "title": md.stem, "summary": ""}

    # frontmatter
    if text.startswith("---"):
        end = text.find("\n---", 3)
        if end > 0:
            fm = text[3:end]
            for line in fm.splitlines():
                line = line.strip()
                if line.startswith("stub:") and "true" in line:
                    info["stub"] = True
                elif line.startswith("tags:"):
                    # inline form: tags: [a, b, c]
                    m = re.search(r'tags:\s*\[([^\]]+)\]', line)
                    if m:
                        info["tags"] = [t.strip().strip('"\'') for t in m.group(1).split(",")]
            # multiline sources/tags
            src_m = re.search(r'^sources:\s*\n((?:  -.*\n)+)', fm, re.MULTILINE)
            if src_m:
                info["sources_count"] = src_m.group(1).count("\n  -")  + (1 if src_m.group(1).startswith("  -") else 0)
                # simpler: count lines starting with `-`
                info["sources_count"] = len([l for l in src_m.group(1).splitlines() if l.strip().startswith("-")])
            tags_m = re.search(r'^tags:\s*\n((?:  -.*\n)+)', fm, re.MULTILINE)
            if tags_m:
                info["tags"] = [l.strip()[1:].strip().strip('"\'') for l in tags_m.group(1).splitlines() if l.strip().startswith("-")]
            body = text[end + 4:]
        else:
            body = text
    else:
        body = text

    # title = first H1
    h1 = re.search(r'^# (.+)$', body, re.MULTILINE)
    if h1:
        info["title"] = h1.group(1).strip()
        # one-line summary = first non-empty line after H1 that isn't another heading
        after = body[h1.end():].lstrip("\n")
        for line in after.splitlines():
            line = line.strip()
            if not line:
                continue
            if line.startswith("#"):
                break
            if line.startswith("---"):
                continue
            # strip markdown
            line = re.sub(r'\[\[([^\]|]+)(?:\|([^\]]+))?\]\]', r'\2' if r'\2' else r'\1', line)
            line = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', line)
            line = re.sub(r'\*\*([^*]+)\*\*', r'\1', line)
            line = re.sub(r'`([^`]+)`', r'\1', line)
            info["summary"] = line[:120]
            break

    return info


def main() -> int:
    categories = {
        "concepts": ("💡 Concepts", "개념·패턴·방법론"),
        "tools": ("🔧 Tools", "제품·도구·라이브러리·스킬"),
        "topics": ("📌 Topics", "프로젝트·주제·산업"),
        "people": ("👤 People", "인물·조직"),
    }

    now = datetime.now(timezone.utc).isoformat(timespec="minutes")
    lines = [
        "---",
        "type: index",
        f"generated: {now}",
        "auto-generated: true",
        "tags: [index, meta]",
        "---",
        "",
        "# Wiki Index",
        "",
        "> 본 vault의 **content catalog**. 자동 생성 — 수동 편집 금지.",
        "> 새 노트/변경 시 `python3 ~/forge/shared/scripts/wiki-build-index.py` 재실행.",
        "> Karpathy 철학: 쿼리 시 먼저 이 index를 읽고 → 관련 페이지로 drill-down.",
        "",
        "## 통계",
        "",
    ]

    total = 0
    stub_count = 0
    all_pages: dict[str, list[dict]] = {}
    for cat in categories:
        folder = WIKI / cat
        pages = []
        for md in sorted(folder.glob("*.md")):
            info = parse_page(md)
            pages.append(info)
            total += 1
            if info["stub"]:
                stub_count += 1
        all_pages[cat] = pages

    lines.append(f"- **총 노트**: {total}")
    lines.append(f"- **Stub (growth seeds)**: {stub_count} ⭐")
    for cat, pages in all_pages.items():
        emoji_name, _ = categories[cat]
        lines.append(f"- **{emoji_name}**: {len(pages)}")
    lines.append("")

    for cat, pages in all_pages.items():
        emoji_name, desc = categories[cat]
        lines.append(f"## {emoji_name}")
        lines.append(f"_{desc}_")
        lines.append("")
        if not pages:
            lines.append("_(없음)_")
            lines.append("")
            continue
        for p in pages:
            stub_mark = " ⭐" if p["stub"] else ""
            tags_str = " ".join(f"#{t}" for t in p["tags"][:3]) if p["tags"] else ""
            src_str = f" `[{p['sources_count']} sources]`" if p["sources_count"] else ""
            summary = p["summary"] or "_(요약 없음)_"
            lines.append(f"- [[{p['slug']}|{p['title']}]]{stub_mark}{src_str}")
            if p["summary"]:
                lines.append(f"   > {summary}")
            if tags_str:
                lines.append(f"   > {tags_str}")
        lines.append("")

    lines.append("---")
    lines.append("")
    lines.append("## 운영")
    lines.append("")
    lines.append("- 새 Raw ingest: [[karpathy-llm-wiki]] 패턴 참조")
    lines.append("- 월 1회 lint: `_meta/lint-log.md` 확인")
    lines.append("- 연대기: [[log|_meta/log.md]]")
    lines.append("- Schema: `CLAUDE.md` (vault 루트)")
    lines.append("")

    INDEX.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {INDEX}")
    print(f"total: {total}, stubs: {stub_count}")
    for cat, pages in all_pages.items():
        print(f"  {cat}: {len(pages)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
