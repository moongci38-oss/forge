#!/usr/bin/env python3
"""wiki-fix-dangling-refs — 큐레이터가 생성한 wiki 노트의 dangling [[YYYY-MM-DD-XXX-analysis]]
wikilink를 읽기 가능한 형태(제목 + YouTube 링크 + 원본 경로)로 교체한다.

배경:
- Curator 에이전트가 `[[2026-03-10-fkqXQOjj8cA-analysis]]` 같은 wikilink를 작성
- 실제 파일은 vault 밖(forge-outputs/01-research/videos/analyses/)에 있어 Obsidian에서
  빈 그래프 노드로 표시 + 크립틱한 video ID만 보여 무엇인지 알 수 없음

해결:
- 파일명에서 날짜+video_id 추출
- 원본 md의 첫 H1에서 한국어 제목 추출
- `[[...]]` → `**YYYY-MM-DD** 제목 — [영상](https://youtu.be/ID)` 로 교체
- frontmatter sources는 경로 문자열 리스트로 단순화
"""

from __future__ import annotations
import re
from pathlib import Path

WIKI = Path("/home/damools/forge-outputs/20-wiki")
RAW_ANALYSES = Path("/home/damools/forge-outputs/01-research/videos/analyses")

# [[YYYY-MM-DD-VIDEOID-(analysis|summary)]]
BODY_PATTERN = re.compile(r'\[\[(\d{4}-\d{2}-\d{2})-([A-Za-z0-9_-]+?)-(analysis|summary)\]\]')
# frontmatter quoted wikilink entry
FM_PATTERN = re.compile(r'^(\s*-\s*)"?\[\[(\d{4}-\d{2}-\d{2})-([A-Za-z0-9_-]+?)-(analysis|summary)\]\]"?\s*$')


def extract_title(raw_path: Path) -> str | None:
    if not raw_path.exists():
        return None
    try:
        with raw_path.open(encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line.startswith("# "):
                    return line[2:].strip()
    except Exception:
        return None
    return None


def find_raw_file(date: str, video_id: str, kind: str) -> Path | None:
    """Find /01-research/videos/analyses/{date}-{video_id}-{kind}.md or match by prefix."""
    candidates = [
        RAW_ANALYSES / f"{date}-{video_id}-{kind}.md",
        RAW_ANALYSES / f"{date}-{video_id}-analysis.md",  # prefer analysis
        RAW_ANALYSES / f"{date}-{video_id}.md",
    ]
    for c in candidates:
        if c.exists():
            return c
    # fallback: glob prefix match
    for p in RAW_ANALYSES.glob(f"{date}-{video_id}*.md"):
        if not p.name.endswith(".json"):
            return p
    return None


def youtube_url(video_id: str) -> str:
    # video_id may contain - or _; YouTube IDs are 11 chars typically
    return f"https://youtu.be/{video_id}"


def fix_body(text: str) -> tuple[str, int]:
    count = 0

    def repl(m: re.Match) -> str:
        nonlocal count
        date, vid, kind = m.group(1), m.group(2), m.group(3)
        raw = find_raw_file(date, vid, kind)
        title = extract_title(raw) if raw else None
        count += 1
        if title:
            return f"**{date}** {title} — [영상]({youtube_url(vid)})"
        return f"**{date}** `{vid}` — [영상]({youtube_url(vid)})"

    new_text = BODY_PATTERN.sub(repl, text)
    return new_text, count


def fix_frontmatter(text: str) -> tuple[str, int]:
    """Replace YAML list entries '- [[YYYY-MM-DD-ID-kind]]' with readable strings."""
    lines = text.splitlines()
    in_fm = False
    fm_end = False
    count = 0
    new_lines = []
    for i, line in enumerate(lines):
        if not fm_end:
            if i == 0 and line.strip() == "---":
                in_fm = True
                new_lines.append(line)
                continue
            if in_fm and line.strip() == "---":
                fm_end = True
                new_lines.append(line)
                continue
            if in_fm:
                m = FM_PATTERN.match(line)
                if m:
                    indent, date, vid, kind = m.group(1), m.group(2), m.group(3), m.group(4)
                    raw = find_raw_file(date, vid, kind)
                    title = extract_title(raw) if raw else None
                    if title:
                        # escape quotes in title
                        safe = title.replace('"', '\\"')
                        new_lines.append(f'{indent}"{date} — {safe}"')
                    else:
                        new_lines.append(f'{indent}"{date} — {vid}"')
                    count += 1
                    continue
        new_lines.append(line)
    return "\n".join(new_lines) + ("\n" if text.endswith("\n") else ""), count


def main() -> int:
    total_body = 0
    total_fm = 0
    files_changed = 0
    for sub in ("concepts", "tools", "topics", "people"):
        for md in (WIKI / sub).glob("*.md"):
            orig = md.read_text(encoding="utf-8")
            # frontmatter first (structural), then body
            step1, fm_count = fix_frontmatter(orig)
            step2, body_count = fix_body(step1)
            if fm_count or body_count:
                md.write_text(step2, encoding="utf-8")
                files_changed += 1
                total_fm += fm_count
                total_body += body_count
                print(f"  {md.relative_to(WIKI)}: fm={fm_count}, body={body_count}")
    print()
    print(f"Files changed: {files_changed}")
    print(f"Frontmatter refs replaced: {total_fm}")
    print(f"Body refs replaced: {total_body}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
