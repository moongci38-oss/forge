#!/usr/bin/env python3
"""parse-frontmatter.py — YAML Frontmatter 파서 for Rules-as-Code

규칙 원본 파일에서 YAML Frontmatter를 추출하고 파싱한다.
JSON 출력으로 다른 도구에서 소비 가능.

Usage:
    python3 parse-frontmatter.py <file.md>          # 단일 파일 파싱
    python3 parse-frontmatter.py --dir <directory>  # 디렉토리 전체 파싱
    python3 parse-frontmatter.py --manifest <dir>   # rules-manifest.json 생성
"""

import sys
import os
import json
import re
from pathlib import Path
from datetime import date


def parse_frontmatter(filepath: str) -> dict | None:
    """Parse YAML frontmatter from a markdown file.

    Returns dict with 'meta' (frontmatter) and 'content' (body) keys,
    or None if no frontmatter found.
    """
    with open(filepath, "r", encoding="utf-8") as f:
        text = f.read()

    # Match --- delimited frontmatter
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n(.*)", text, re.DOTALL)
    if not match:
        return None

    yaml_text = match.group(1)
    body = match.group(2)

    # Simple YAML parser (no PyYAML dependency)
    meta = _parse_simple_yaml(yaml_text)
    meta["_file"] = str(filepath)
    meta["_body"] = body

    return meta


def _parse_simple_yaml(text: str) -> dict:
    """Minimal YAML parser for frontmatter (handles strings, arrays, enums)."""
    result = {}
    current_key = None
    current_array = None

    for line in text.split("\n"):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue

        # Array item
        if stripped.startswith("- ") and current_key:
            value = stripped[2:].strip().strip('"').strip("'")
            if current_array is None:
                current_array = []
            current_array.append(value)
            result[current_key] = current_array
            continue

        # Key-value pair
        if ":" in stripped:
            # Save previous array
            if current_array is not None:
                current_array = None

            colon_idx = stripped.index(":")
            key = stripped[:colon_idx].strip()
            value = stripped[colon_idx + 1 :].strip()

            current_key = key

            if not value:
                # Might be start of array or multi-line
                continue

            # Handle inline array [a, b, c]
            if value.startswith("[") and value.endswith("]"):
                items = [
                    v.strip().strip('"').strip("'")
                    for v in value[1:-1].split(",")
                    if v.strip()
                ]
                result[key] = items
                current_array = None
                continue

            # Scalar value
            value = value.strip('"').strip("'")
            result[key] = value
            current_array = None

    return result


def count_sections(body: str) -> dict:
    """Count Do/Don't/AI 행동 규칙 items in the body."""
    counts = {"doCount": 0, "dontCount": 0, "aiRuleCount": 0}

    current_section = None
    for line in body.split("\n"):
        stripped = line.strip()
        if stripped.startswith("## Do") and not stripped.startswith("## Don't"):
            current_section = "do"
        elif stripped.startswith("## Don't"):
            current_section = "dont"
        elif stripped.startswith("## AI 행동 규칙"):
            current_section = "ai"
        elif stripped.startswith("## "):
            current_section = None

        if current_section and stripped.startswith("- "):
            if current_section == "do":
                counts["doCount"] += 1
            elif current_section == "dont":
                counts["dontCount"] += 1
            elif current_section == "ai":
                counts["aiRuleCount"] += 1

    return counts


def extract_test_cases(meta: dict, body: str) -> list:
    """Extract Do/Don't items as test cases."""
    cases = []
    rule_id = meta.get("id", "unknown")
    current_section = None

    for line in body.split("\n"):
        stripped = line.strip()
        if stripped.startswith("## Do") and not stripped.startswith("## Don't"):
            current_section = "do"
        elif stripped.startswith("## Don't"):
            current_section = "dont"
        elif stripped.startswith("## "):
            current_section = None

        if current_section and stripped.startswith("- "):
            description = stripped[2:].strip()
            cases.append(
                {
                    "ruleId": rule_id,
                    "type": current_section,
                    "description": description,
                    "verifiable": True,
                }
            )

    return cases


def estimate_tokens(text: str) -> int:
    """Rough token estimate: ~4 chars per token for mixed Korean/English."""
    return len(text.encode("utf-8")) // 4


def build_manifest(rules_dir: str) -> dict:
    """Build rules-manifest.json from all rule files in directory."""
    rules_path = Path(rules_dir)
    rules = []
    all_test_cases = []
    stats = {
        "totalRules": 0,
        "byScope": {},
        "byImpact": {},
        "totalTokens": 0,
    }

    for md_file in sorted(rules_path.rglob("*.md")):
        if md_file.name.startswith("_") or md_file.name == "README.md":
            continue

        parsed = parse_frontmatter(str(md_file))
        if not parsed:
            continue

        body = parsed.pop("_body", "")
        file_path = parsed.pop("_file", str(md_file))
        rel_path = str(md_file.relative_to(rules_path.parent.parent))

        counts = count_sections(body)
        tokens = estimate_tokens(body)
        test_cases = extract_test_cases(parsed, body)

        scopes = parsed.get("scope", [])
        if isinstance(scopes, str):
            scopes = [scopes]
        impact = parsed.get("impact", "LOW")

        rule_entry = {
            "id": parsed.get("id", md_file.stem),
            "title": parsed.get("title", md_file.stem),
            "file": rel_path,
            "impact": impact,
            "scope": scopes,
            "tags": parsed.get("tags", []),
            "requires": parsed.get("requires", []),
            "audience": parsed.get("audience", "all"),
            "tokens": tokens,
            **counts,
        }

        rules.append(rule_entry)
        all_test_cases.extend(test_cases)

        # Update stats
        stats["totalRules"] += 1
        stats["totalTokens"] += tokens
        for scope in scopes:
            stats["byScope"][scope] = stats["byScope"].get(scope, 0) + 1
        stats["byImpact"][impact] = stats["byImpact"].get(impact, 0) + 1

    manifest = {
        "version": "1.0.0",
        "buildDate": str(date.today()),
        "stats": stats,
        "rules": rules,
    }

    return manifest, all_test_cases


def main():
    if len(sys.argv) < 2:
        print("Usage: parse-frontmatter.py <file.md|--dir <dir>|--manifest <dir>>")
        sys.exit(1)

    if sys.argv[1] == "--dir":
        directory = sys.argv[2] if len(sys.argv) > 2 else "."
        results = []
        for md_file in sorted(Path(directory).rglob("*.md")):
            if md_file.name.startswith("_") or md_file.name == "README.md":
                continue
            parsed = parse_frontmatter(str(md_file))
            if parsed:
                parsed.pop("_body", None)
                results.append(parsed)
        print(json.dumps(results, ensure_ascii=False, indent=2))

    elif sys.argv[1] == "--manifest":
        directory = sys.argv[2] if len(sys.argv) > 2 else "."
        manifest, test_cases = build_manifest(directory)
        print(json.dumps(manifest, ensure_ascii=False, indent=2))

        # Also output test-cases if redirected
        if len(sys.argv) > 3 and sys.argv[3] == "--test-cases":
            tc_output = {"testCases": test_cases}
            tc_path = Path(directory).parent / "build-output" / "test-cases.json"
            tc_path.parent.mkdir(parents=True, exist_ok=True)
            with open(tc_path, "w", encoding="utf-8") as f:
                json.dump(tc_output, f, ensure_ascii=False, indent=2)
            print(f"\nTest cases written to: {tc_path}", file=sys.stderr)

    else:
        filepath = sys.argv[1]
        parsed = parse_frontmatter(filepath)
        if parsed:
            body = parsed.pop("_body", "")
            counts = count_sections(body)
            parsed.update(counts)
            parsed["tokens"] = estimate_tokens(body)
            print(json.dumps(parsed, ensure_ascii=False, indent=2))
        else:
            print(f"No frontmatter found in {filepath}", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()
