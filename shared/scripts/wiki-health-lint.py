#!/usr/bin/env python3
"""wiki-health-lint — Karpathy-style wiki 건강 검진.

wiki-sync-lint.py(미승격 Raw 카운트)와 보완 관계.
이 스크립트는 vault 내부 품질을 체크:

1. Orphan pages — 인바운드 링크 0개인 노트 (고립)
2. Broken inter-wiki links — 존재하지 않는 [[target]] 참조
3. Missing concepts — 본문에 자주 등장하지만 전용 페이지 없는 용어 (TODO: P2)
4. Stub pages — 30일 이상 stub 상태 유지 (우선순위 재검토 필요)
5. Stale claims — TODO/Growth Notes 섹션 누적 (TODO: P2)
6. Dangling Raw refs — [[YYYY-MM-DD-XXX-analysis]] 형태 외부 참조

출력: _meta/lint-log.md에 append (상위 10회 유지)
"""

from __future__ import annotations
import json
import re
import sys
from datetime import datetime, timezone, timedelta
from pathlib import Path
from collections import defaultdict

WIKI = Path.home() / "forge-outputs/20-wiki"
LINT_LOG = WIKI / "_meta" / "lint-log.md"
CATEGORIES = ("concepts", "tools", "topics", "people")

LINK = re.compile(r'\[\[([^\]|#]+?)(?:[|#][^\]]*)?\]\]')
RAW_REF = re.compile(r'\[\[\d{4}-\d{2}-\d{2}-[A-Za-z0-9_-]+?-(?:analysis|summary)\]\]')
STUB_PATTERN = re.compile(r'^\s*stub:\s*true', re.MULTILINE)


def parse_fm_dates(text: str) -> dict:
    """Extract created, updated from frontmatter."""
    result = {}
    if text.startswith("---"):
        end = text.find("\n---", 3)
        if end > 0:
            fm = text[3:end]
            m = re.search(r'^created:\s*(\S+)', fm, re.MULTILINE)
            if m:
                result["created"] = m.group(1)
            m = re.search(r'^updated:\s*(\S+)', fm, re.MULTILINE)
            if m:
                result["updated"] = m.group(1)
    return result


def main() -> int:
    # collect all pages
    pages: dict[str, Path] = {}
    texts: dict[str, str] = {}
    for cat in CATEGORIES:
        for md in (WIKI / cat).glob("*.md"):
            pages[md.stem] = md
            texts[md.stem] = md.read_text(encoding="utf-8")

    # build inbound map + detect issues
    inbound = defaultdict(set)
    outbound = defaultdict(set)
    broken_refs = []
    dangling_raw = []

    for name, text in texts.items():
        for m in LINK.finditer(text):
            target = m.group(1).strip()
            if re.match(r'^\d{4}-\d{2}-\d{2}', target):
                dangling_raw.append((name, target))
                continue
            outbound[name].add(target)
            if target in pages:
                inbound[target].add(name)
            else:
                broken_refs.append((name, target))

    orphans = [n for n in pages if not inbound[n]]

    now = datetime.now(timezone.utc)
    stale_stubs = []
    for name, text in texts.items():
        if not STUB_PATTERN.search(text):
            continue
        fm = parse_fm_dates(text)
        created_str = fm.get("created", "")
        if not created_str:
            continue
        try:
            created = datetime.fromisoformat(created_str).replace(tzinfo=timezone.utc)
        except Exception:
            continue
        age_days = (now - created).days
        if age_days >= 30:
            stale_stubs.append((name, age_days))

    # Growth Notes / TODO density
    growth_heavy = []
    for name, text in texts.items():
        todo_count = len(re.findall(r'\bTODO\b|예정|필요', text))
        if todo_count >= 5:
            growth_heavy.append((name, todo_count))

    # write report
    report_lines = [
        f"## {now.strftime('%Y-%m-%d %H:%M UTC')} — wiki-health-lint",
        "",
        f"**총 노트**: {len(pages)}",
        f"**총 내부 링크**: {sum(len(v) for v in outbound.values())}",
        "",
        f"### 🔴 Broken inter-wiki refs ({len(broken_refs)})",
    ]
    if not broken_refs:
        report_lines.append("_(없음 — healthy)_")
    else:
        agg = defaultdict(list)
        for src, tgt in broken_refs:
            agg[tgt].append(src)
        for tgt, srcs in sorted(agg.items(), key=lambda x: -len(x[1]))[:15]:
            report_lines.append(f"- `[[{tgt}]]` ← {len(srcs)}개 노트에서 참조")

    report_lines.extend(["", f"### 🟠 Orphan pages ({len(orphans)})"])
    if not orphans:
        report_lines.append("_(없음)_")
    else:
        for o in sorted(orphans):
            report_lines.append(f"- [[{o}]]")

    report_lines.extend(["", f"### 🟡 Stale stubs (30+일, {len(stale_stubs)})"])
    if not stale_stubs:
        report_lines.append("_(없음)_")
    else:
        for name, age in sorted(stale_stubs, key=lambda x: -x[1]):
            report_lines.append(f"- [[{name}]] — {age}일 경과")

    report_lines.extend(["", f"### 🟡 Growth-heavy notes (TODO≥5, {len(growth_heavy)})"])
    if not growth_heavy:
        report_lines.append("_(없음)_")
    else:
        for name, count in sorted(growth_heavy, key=lambda x: -x[1])[:10]:
            report_lines.append(f"- [[{name}]] — {count} TODO/예정/필요")

    report_lines.extend(["", f"### ⚪ Dangling Raw refs (외부 참조, {len(dangling_raw)})"])
    if not dangling_raw:
        report_lines.append("_(없음 — wiki-fix-dangling-refs.py 적용됨)_")
    else:
        report_lines.append(f"(wiki-fix-dangling-refs.py 재실행 권장)")

    report_lines.append("")
    report_lines.append("---")
    report_lines.append("")

    existing = LINT_LOG.read_text(encoding="utf-8") if LINT_LOG.exists() else ""

    header = (
        "# wiki-sync + health Lint Log\n\n"
        "Raw→Wiki 승격 대기 리포트 + Karpathy-style 건강 검진.\n"
        "- `wiki-sync-lint.py` — pending Raw 카운트\n"
        "- `wiki-health-lint.py` — broken refs, orphans, stubs, growth\n\n"
    )

    # split existing by "## " heading (keep previous runs)
    prev_runs = []
    if existing:
        parts = existing.split("## ")
        for p in parts[1:]:
            if p.strip():
                prev_runs.append("## " + p)
    keep = prev_runs[:9]
    out = header + "\n".join(report_lines) + "\n" + "".join(keep)
    LINT_LOG.write_text(out, encoding="utf-8")

    # stdout summary
    print(f"wiki-health-lint:")
    print(f"  Broken refs: {len(broken_refs)}")
    print(f"  Orphans: {len(orphans)}")
    print(f"  Stale stubs: {len(stale_stubs)}")
    print(f"  Growth-heavy: {len(growth_heavy)}")
    print(f"  Dangling Raw: {len(dangling_raw)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
