#!/usr/bin/env python3
"""index.json의 카테고리/태그 기반 영상 클러스터링

Usage:
    cd /path/to/business/scripts/yt-analyzer
    python3 cluster.py                    # 클러스터 분석 출력
    python3 cluster.py --output clusters.json  # JSON 파일 저장
"""

import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

INDEX_PATH = Path(__file__).resolve().parent.parent.parent / "01-research" / "videos" / "index.json"
ANALYSES_DIR = Path(__file__).resolve().parent.parent.parent / "01-research" / "videos" / "analyses"


def load_index() -> list[dict]:
    if not INDEX_PATH.exists():
        print(f"index.json not found: {INDEX_PATH}")
        return []
    with open(INDEX_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def extract_tags(record: dict) -> set[str]:
    """index.json 레코드 + analysis.md에서 태그 추출"""
    tags = set()

    # index.json의 category
    category = record.get("category", "")
    if category:
        tags.add(category)

    # analysis.md에서 태그 추출
    analysis_path = record.get("files", {}).get("analysis", "")
    if analysis_path:
        full_path = Path(__file__).resolve().parent.parent.parent / analysis_path
        if full_path.exists():
            content = full_path.read_text(encoding="utf-8")
            # 카테고리 라인에서 태그 추출 (예: tech/ai | #tag1 #tag2)
            tag_match = re.search(r"##\s*카테고리\s*\n(.+)", content)
            if tag_match:
                line = tag_match.group(1)
                tags.update(re.findall(r"#([\w-]+)", line))

    return tags


def extract_keywords_from_title(title: str) -> set[str]:
    """제목에서 주요 키워드 추출"""
    keywords = set()
    title_lower = title.lower()

    keyword_map = {
        "claude code": "claude-code",
        "claude": "claude",
        "mcp": "mcp",
        "skill": "skills",
        "skills": "skills",
        "agent": "agent",
        "subagent": "subagent",
        "sub-agent": "subagent",
        "playwright": "playwright",
        "n8n": "n8n",
        "자동화": "automation",
        "워크플로우": "workflow",
        "워크플로": "workflow",
        "hook": "hooks",
        "hooks": "hooks",
        "plugin": "plugin",
        "플러그인": "plugin",
        "loop": "loop",
        "playground": "playground",
        "seo": "seo",
        "gtm": "gtm",
        "디자인": "design",
        "ui": "ui",
        "prd": "prd",
        "notion": "notion",
        "obsidian": "obsidian",
        "claude.md": "claude-md",
        "agents.md": "agents-md",
    }

    for pattern, keyword in keyword_map.items():
        if pattern in title_lower:
            keywords.add(keyword)

    return keywords


def cluster_videos(records: list[dict]) -> dict[str, list[dict]]:
    """영상을 주제별 클러스터로 그룹화"""
    # 각 영상의 태그 + 키워드 수집
    video_features = {}
    for record in records:
        vid = record.get("video_id", "")
        tags = extract_tags(record)
        keywords = extract_keywords_from_title(record.get("title", ""))
        video_features[vid] = tags | keywords

    # 클러스터 정의 (주제 → 매칭 키워드)
    cluster_defs = {
        "Claude Code 세팅 & 워크플로우": {"claude-code", "claude-md", "agents-md", "workflow"},
        "MCP 활용": {"mcp"},
        "Skills & Plugins": {"skills", "plugin", "playground"},
        "에이전트 & 병렬 실행": {"agent", "subagent"},
        "자동화 (Loop/n8n/Hooks)": {"loop", "n8n", "automation", "hooks"},
        "마케팅 & GTM": {"gtm", "seo", "marketing"},
        "디자인 & UI": {"design", "ui", "playwright"},
    }

    clusters = defaultdict(list)
    unclustered = []

    for record in records:
        vid = record.get("video_id", "")
        features = video_features.get(vid, set())
        matched = False

        for cluster_name, cluster_keywords in cluster_defs.items():
            if features & cluster_keywords:
                clusters[cluster_name].append(record)
                matched = True

        if not matched:
            unclustered.append(record)

    if unclustered:
        clusters["기타"] = unclustered

    return dict(clusters)


def print_clusters(clusters: dict[str, list[dict]]) -> None:
    """클러스터 결과를 보기 좋게 출력"""
    print(f"\n{'='*60}")
    print(f"YouTube 영상 클러스터 분석 ({sum(len(v) for v in clusters.values())}개 영상)")
    print(f"{'='*60}\n")

    for name, videos in sorted(clusters.items(), key=lambda x: -len(x[1])):
        print(f"## {name} ({len(videos)}개)")
        for v in videos:
            relevance = v.get("relevance", {})
            max_rel = max(relevance.values()) if relevance else 0
            print(f"  - [{v.get('channel', '?')}] {v.get('title', '?')[:60]}")
            print(f"    비즈니스 관련성: {relevance.get('business', 0)}/5 | ID: {v.get('video_id', '?')}")
        print()


def main():
    parser = argparse.ArgumentParser(description="YouTube 영상 클러스터링")
    parser.add_argument("--output", "-o", help="클러스터 결과를 JSON 파일로 저장")
    args = parser.parse_args()

    records = load_index()
    if not records:
        print("No videos in index.json")
        return

    clusters = cluster_videos(records)
    print_clusters(clusters)

    if args.output:
        # JSON 저장 시 video_id 목록만 저장
        output_data = {}
        for name, videos in clusters.items():
            output_data[name] = {
                "count": len(videos),
                "video_ids": [v["video_id"] for v in videos],
                "titles": [v.get("title", "") for v in videos],
            }
        output_path = Path(args.output)
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(output_data, f, ensure_ascii=False, indent=2)
        print(f"\nCluster data saved: {output_path}")


if __name__ == "__main__":
    main()
