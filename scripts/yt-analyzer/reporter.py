"""Markdown 리포트 생성 모듈"""

import json
import re
from datetime import date
from pathlib import Path
from typing import Optional

from config import ANALYSES_DIR, REPORTS_DIR, CATEGORIES_FILE
from transcript import format_timestamp, timestamp_url


def generate_intermediate_json(
    video_id: str,
    transcript_data: dict,
    metadata: Optional[dict] = None,
    comments: Optional[list] = None,
) -> dict:
    """AI 분석용 중간 JSON 생성"""
    meta = metadata or {}

    # 전체 텍스트 결합 (AI 분석용)
    full_text = " ".join(s["text"] for s in transcript_data["segments"])

    # 타임스탬프 텍스트 (섹션별 구분용)
    timestamped_text = []
    for seg in transcript_data["segments"]:
        ts = format_timestamp(seg["start"])
        timestamped_text.append(f"[{ts}] {seg['text']}")

    return {
        "video_id": video_id,
        "url": f"https://youtu.be/{video_id}",
        "title": meta.get("title", "Unknown"),
        "channel": meta.get("channel", "Unknown"),
        "published": meta.get("published", ""),
        "duration": meta.get("duration", ""),
        "view_count": meta.get("view_count", ""),
        "language": transcript_data["language"],
        "is_generated_subtitle": transcript_data.get("is_generated", False),
        "transcript_source": transcript_data["source"],
        "description": meta.get("description", ""),
        "description_links": meta.get("description_links", []),
        "tags": meta.get("tags", []),
        "comments": comments or [],
        "full_text": full_text,
        "timestamped_text": "\n".join(timestamped_text),
        "segment_count": len(transcript_data["segments"]),
        "segments": transcript_data["segments"][:500],  # 첫 500개 세그먼트만 포함
    }


def save_intermediate_json(data: dict) -> Path:
    """중간 JSON을 파일로 저장"""
    video_id = data["video_id"]
    today = date.today().isoformat()
    filename = f"{today}-{video_id}.json"
    path = ANALYSES_DIR / filename

    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    return path


def generate_summary_report(data: dict, analysis: Optional[dict] = None) -> str:
    """Summary 포맷 Markdown 리포트 생성

    analysis: AI 분석 결과 (없으면 트랜스크립트만 포함)
    """
    vid = data["video_id"]
    title = data.get("title", "Unknown")
    channel = data.get("channel", "Unknown")
    published = data.get("published", "")
    view_count = data.get("view_count", "")
    duration = data.get("duration", "")

    meta_parts = [channel]
    if published:
        meta_parts.append(published)
    if view_count:
        meta_parts.append(f"{view_count} views")
    if duration:
        meta_parts.append(duration)
    meta_line = " | ".join(meta_parts)

    lines = [
        f"# {title}",
        f"> {meta_line}",
        f"> 원본: https://youtu.be/{vid}",
        "",
    ]

    if analysis:
        if analysis.get("tldr"):
            lines.extend(["## TL;DR", analysis["tldr"], ""])

        if analysis.get("category"):
            lines.extend(["## 카테고리", analysis["category"], ""])

        if analysis.get("key_points"):
            lines.append("## 핵심 포인트")
            for i, point in enumerate(analysis["key_points"], 1):
                text = point.get("text", point) if isinstance(point, dict) else point
                ts_link = ""
                if isinstance(point, dict) and point.get("timestamp"):
                    ts_link = f" {timestamp_url(vid, point['timestamp'])}"
                lines.append(f"{i}. **{text}**{ts_link}")
            lines.append("")

        if analysis.get("action_items"):
            lines.append("## 실행 가능 항목")
            for item in analysis["action_items"]:
                lines.append(f"- [ ] {item}")
            lines.append("")

        if analysis.get("relevance"):
            lines.extend(["## 관련성", analysis["relevance"], ""])
    else:
        # AI 분석 없이 트랜스크립트만 제공
        lines.extend([
            "## 트랜스크립트 (AI 분석 대기)",
            "",
            f"총 {data['segment_count']}개 세그먼트 | 언어: {data['language']}",
            f"{'(자동 생성 자막)' if data.get('is_generated_subtitle') else '(수동 자막)'}",
            "",
            "### 첫 10개 세그먼트 미리보기",
            "",
        ])
        for seg in data.get("segments", [])[:10]:
            ts = format_timestamp(seg["start"])
            lines.append(f"- [{ts}] {seg['text']}")
        lines.append("")
        lines.append(f"> AI 분석을 실행하려면: `/yt-analyze {ANALYSES_DIR / (date.today().isoformat() + '-' + vid + '.json')}`")

    return "\n".join(lines)


def generate_timeline_report(data: dict) -> str:
    """Timeline 포맷 — 시간순 섹션별 노트"""
    vid = data["video_id"]
    title = data.get("title", "Unknown")
    segments = data.get("segments", [])

    lines = [
        f"# {title} — Timeline",
        f"> 원본: https://youtu.be/{vid}",
        "",
    ]

    # 세그먼트를 5분 단위로 그룹핑
    current_group_start = 0
    group_size = 300  # 5 minutes
    current_texts = []

    for seg in segments:
        group_idx = int(seg["start"] // group_size)
        expected_start = group_idx * group_size

        if expected_start != current_group_start and current_texts:
            ts = format_timestamp(current_group_start)
            ts_link = timestamp_url(vid, current_group_start)
            lines.append(f"### {ts_link}")
            lines.append(" ".join(current_texts))
            lines.append("")
            current_texts = []
            current_group_start = expected_start

        current_texts.append(seg["text"])

    # 마지막 그룹
    if current_texts:
        ts_link = timestamp_url(vid, current_group_start)
        lines.append(f"### {ts_link}")
        lines.append(" ".join(current_texts))
        lines.append("")

    return "\n".join(lines)


def generate_mindmap_report(data: dict) -> str:
    """MindMap 포맷 — Mermaid 마인드맵"""
    vid = data["video_id"]
    title = data.get("title", "Unknown")
    segments = data.get("segments", [])

    # 트랜스크립트를 3분 단위 블록으로 나누고 첫 문장을 노드로 사용
    block_size = 180  # 3 minutes
    blocks = {}
    for seg in segments:
        block_idx = int(seg["start"] // block_size)
        if block_idx not in blocks:
            blocks[block_idx] = []
        blocks[block_idx].append(seg["text"])

    # Mermaid 마인드맵 문법에서 특수문자 이스케이프
    def sanitize(text: str) -> str:
        return re.sub(r'[(){}[\]"\'`#]', '', text).strip()[:60]

    # 제목 산정화
    safe_title = sanitize(title) or "Video"

    lines = [
        f"# {title} — MindMap",
        f"> 원본: https://youtu.be/{vid}",
        "",
        "```mermaid",
        "mindmap",
        f"  root(({safe_title}))",
    ]

    for block_idx in sorted(blocks.keys()):
        ts = format_timestamp(block_idx * block_size)
        texts = blocks[block_idx]
        # 블록의 첫 문장을 노드 제목으로
        node_title = sanitize(texts[0]) if texts else f"Section {block_idx}"
        lines.append(f"    {ts}")

        # 핵심 문장 추출 (블록에서 가장 긴 3개)
        sorted_texts = sorted(texts, key=len, reverse=True)[:3]
        for t in sorted_texts:
            clean = sanitize(t)
            if clean and len(clean) > 5:
                lines.append(f"      {clean}")

    lines.extend(["```", ""])
    return "\n".join(lines)


def generate_batch_report(results: list[dict], title: str = "배치 분석 리포트") -> str:
    """여러 영상의 배치 종합 리포트"""
    today = date.today().isoformat()

    lines = [
        f"# {title}",
        f"> 생성일: {today} | 영상 {len(results)}개",
        "",
        "## 영상 목록",
        "",
        "| # | 제목 | 채널 | 조회수 | 길이 | 언어 |",
        "|:-:|------|------|:------:|:----:|:----:|",
    ]

    for i, r in enumerate(results, 1):
        if "error" in r:
            lines.append(f"| {i} | ❌ {r.get('url', 'unknown')} | — | — | — | ERROR |")
            continue
        data = r.get("intermediate", {})
        vid = data.get("video_id", "")
        t = data.get("title", "Unknown")[:40]
        ch = data.get("channel", "")[:20]
        vc = data.get("view_count", "—")
        dur = data.get("duration", "—")
        lang = data.get("language", "—")
        link = f"[{t}](https://youtu.be/{vid})"
        lines.append(f"| {i} | {link} | {ch} | {vc} | {dur} | {lang} |")

    lines.extend(["", "## 개별 분석 파일", ""])
    for r in results:
        if "json_path" in r:
            lines.append(f"- `{r['json_path']}`")

    lines.extend([
        "",
        "## AI 종합 분석",
        "",
        "> 개별 JSON 파일을 `/yt-analyze`로 분석한 뒤, 종합 인사이트를 여기에 추가하세요.",
        "",
    ])

    return "\n".join(lines)


def auto_categorize(data: dict) -> str:
    """제목+트랜스크립트 키워드로 카테고리 자동 분류"""
    try:
        with open(CATEGORIES_FILE, "r", encoding="utf-8") as f:
            cat_data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return "uncategorized"

    categories = cat_data.get("categories", {})
    text = (
        data.get("title", "").lower() + " " +
        data.get("full_text", "")[:2000].lower()
    )

    scores = {}
    for cat_id, cat_info in categories.items():
        score = 0
        for kw in cat_info.get("keywords", []):
            if kw.lower() in text:
                score += 1
        if score > 0:
            scores[cat_id] = score

    if not scores:
        return "uncategorized"

    return max(scores, key=scores.get)


def generate_full_report(data: dict) -> str:
    """Full 포맷 — 강화 트랜스크립트 (소제목 + 강조)"""
    vid = data["video_id"]
    title = data.get("title", "Unknown")
    channel = data.get("channel", "Unknown")
    segments = data.get("segments", [])

    meta_parts = [channel]
    for key in ["published", "view_count", "duration"]:
        v = data.get(key, "")
        if v:
            if key == "view_count":
                meta_parts.append(f"{v} views")
            else:
                meta_parts.append(v)

    lines = [
        f"# {title}",
        f"> {' | '.join(meta_parts)}",
        f"> 원본: https://youtu.be/{vid}",
        "",
    ]

    if data.get("category") and data["category"] != "uncategorized":
        lines.extend([f"**카테고리**: {data['category']}", ""])

    lines.extend(["---", ""])

    # 세그먼트를 2분 단위로 그룹핑, 각 그룹에 소제목 부여
    block_size = 120  # 2 minutes
    blocks = {}
    for seg in segments:
        block_idx = int(seg["start"] // block_size)
        if block_idx not in blocks:
            blocks[block_idx] = []
        blocks[block_idx].append(seg)

    for block_idx in sorted(blocks.keys()):
        block_segs = blocks[block_idx]
        start_time = block_idx * block_size
        ts_link = timestamp_url(vid, start_time)
        lines.append(f"### {ts_link}")
        lines.append("")

        for seg in block_segs:
            text = seg["text"].strip()
            if text:
                lines.append(f"{text}")
        lines.extend(["", ""])

    return "\n".join(lines)


def generate_blog_report(data: dict) -> str:
    """Blog 포맷 — SEO 블로그 글 변환용 초안"""
    vid = data["video_id"]
    title = data.get("title", "Unknown")
    channel = data.get("channel", "Unknown")
    full_text = data.get("full_text", "")

    # 트랜스크립트를 단락으로 재구성
    segments = data.get("segments", [])
    paragraphs = []
    current_para = []
    last_end = 0

    for seg in segments:
        # 3초 이상 간격이면 새 단락
        if seg["start"] - last_end > 3 and current_para:
            paragraphs.append(" ".join(current_para))
            current_para = []
        current_para.append(seg["text"].strip())
        last_end = seg["start"] + seg.get("duration", 0)

    if current_para:
        paragraphs.append(" ".join(current_para))

    lines = [
        f"# {title}",
        "",
        f"*이 글은 [{channel}](https://youtu.be/{vid})의 영상 내용을 기반으로 작성되었습니다.*",
        "",
        "---",
        "",
        "## 들어가며",
        "",
        f"> 이 글은 YouTube 영상 \"{title}\"의 트랜스크립트를 기반으로 한 초안입니다.",
        "> `/yt-analyze`로 AI 분석 후 편집하면 완성도 높은 블로그 글이 됩니다.",
        "",
        "---",
        "",
        "## 본문",
        "",
    ]

    for i, para in enumerate(paragraphs):
        if para.strip():
            lines.append(para)
            lines.append("")

    lines.extend([
        "---",
        "",
        "## 마무리",
        "",
        f"원본 영상: [YouTube에서 보기](https://youtu.be/{vid})",
        "",
    ])

    if data.get("category") and data["category"] != "uncategorized":
        try:
            with open(CATEGORIES_FILE, "r", encoding="utf-8") as f:
                cat_data = json.load(f)
            cat_info = cat_data.get("categories", {}).get(data["category"], {})
            tags = cat_info.get("tags", [])
            if tags:
                lines.append(f"**태그**: {' '.join(tags)}")
                lines.append("")
        except Exception:
            pass

    return "\n".join(lines)


def save_report(content: str, video_id: str, fmt: str = "summary") -> Path:
    """리포트를 파일로 저장"""
    today = date.today().isoformat()
    filename = f"{today}-{video_id}-{fmt}.md"
    path = ANALYSES_DIR / filename

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

    return path


def save_batch_report(content: str, name: str = "batch") -> Path:
    """배치 리포트를 reports/ 폴더에 저장"""
    today = date.today().isoformat()
    filename = f"{today}-{name}-report.md"
    path = REPORTS_DIR / filename

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

    return path
