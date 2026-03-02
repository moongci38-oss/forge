#!/usr/bin/env python3
"""validate-rules.py — 규칙 스키마 + 의존성 검증

Usage:
    python3 validate-rules.py <rules-source-dir>
"""

import sys
import json
from pathlib import Path

# Import from sibling module
sys.path.insert(0, str(Path(__file__).parent))
from parse_frontmatter import parse_frontmatter, count_sections  # noqa: E402

VALID_IMPACTS = {"CRITICAL", "HIGH", "MEDIUM", "LOW"}
VALID_SCOPES = {"always", "sigil", "trine", "cowork"}
VALID_AUDIENCES = {"dev", "non-dev", "all"}
VALID_ENFORCEMENTS = {"rigid", "flexible"}

REQUIRED_FIELDS = ["title", "id", "impact", "scope"]


def validate_rule(filepath: str) -> list[dict]:
    """Validate a single rule file. Returns list of issues."""
    issues = []
    parsed = parse_frontmatter(filepath)

    if parsed is None:
        issues.append({"file": filepath, "severity": "error", "message": "No YAML frontmatter found"})
        return issues

    body = parsed.pop("_body", "")
    parsed.pop("_file", None)

    # Required fields
    for field in REQUIRED_FIELDS:
        if field not in parsed:
            issues.append({"file": filepath, "severity": "error", "message": f"Missing required field: {field}"})

    # ID format
    rule_id = parsed.get("id", "")
    if rule_id and not all(c.isalnum() or c == "-" for c in rule_id):
        issues.append({"file": filepath, "severity": "error", "message": f"Invalid ID format: {rule_id} (must be kebab-case)"})

    # Impact enum
    impact = parsed.get("impact", "")
    if impact and impact not in VALID_IMPACTS:
        issues.append({"file": filepath, "severity": "error", "message": f"Invalid impact: {impact} (must be one of {VALID_IMPACTS})"})

    # Scope array
    scopes = parsed.get("scope", [])
    if isinstance(scopes, str):
        scopes = [scopes]
    for scope in scopes:
        if scope not in VALID_SCOPES:
            issues.append({"file": filepath, "severity": "error", "message": f"Invalid scope: {scope} (must be one of {VALID_SCOPES})"})

    # Audience enum
    audience = parsed.get("audience", "all")
    if audience not in VALID_AUDIENCES:
        issues.append({"file": filepath, "severity": "warning", "message": f"Invalid audience: {audience}"})

    # impactDescription: if present, must be a non-empty string
    impact_desc = parsed.get("impactDescription")
    if impact_desc is not None and not isinstance(impact_desc, str):
        issues.append({"file": filepath, "severity": "error", "message": "impactDescription must be a string"})

    # enforcement: if present, must be "rigid" or "flexible"
    enforcement = parsed.get("enforcement")
    if enforcement is not None and enforcement not in VALID_ENFORCEMENTS:
        issues.append({"file": filepath, "severity": "error", "message": f"Invalid enforcement: {enforcement} (must be 'rigid' or 'flexible')"})

    # Warning if CRITICAL/HIGH lacks impactDescription
    if impact in {"CRITICAL", "HIGH"} and not impact_desc:
        issues.append({"file": filepath, "severity": "warning", "message": f"CRITICAL/HIGH rule missing impactDescription (recommended)"})

    # Warning if CRITICAL lacks enforcement
    if impact == "CRITICAL" and enforcement is None:
        issues.append({"file": filepath, "severity": "warning", "message": "CRITICAL rule missing enforcement (recommended: rigid)"})

    # Content sections check
    counts = count_sections(body)
    if counts["doCount"] == 0 and counts["dontCount"] == 0:
        issues.append({"file": filepath, "severity": "warning", "message": "No Do/Don't sections found (recommended for rules)"})

    return issues


def validate_dependencies(rules_dir: str) -> list[dict]:
    """Check for missing dependency references."""
    issues = []
    all_ids = set()
    all_requires = {}

    for md_file in Path(rules_dir).rglob("*.md"):
        if md_file.name.startswith("_") or md_file.name == "README.md":
            continue
        parsed = parse_frontmatter(str(md_file))
        if parsed:
            rule_id = parsed.get("id", "")
            if rule_id:
                all_ids.add(rule_id)
            requires = parsed.get("requires", [])
            if isinstance(requires, str):
                requires = [requires]
            if requires:
                all_requires[str(md_file)] = (rule_id, requires)

    # Check for missing dependencies
    for filepath, (rule_id, requires) in all_requires.items():
        for dep in requires:
            if dep not in all_ids:
                issues.append({
                    "file": filepath,
                    "severity": "error",
                    "message": f"Rule '{rule_id}' requires '{dep}' but it doesn't exist",
                })

    # Check for duplicate IDs
    seen_ids = {}
    for md_file in Path(rules_dir).rglob("*.md"):
        if md_file.name.startswith("_") or md_file.name == "README.md":
            continue
        parsed = parse_frontmatter(str(md_file))
        if parsed:
            rule_id = parsed.get("id", "")
            if rule_id:
                if rule_id in seen_ids:
                    issues.append({
                        "file": str(md_file),
                        "severity": "error",
                        "message": f"Duplicate ID '{rule_id}' (also in {seen_ids[rule_id]})",
                    })
                else:
                    seen_ids[rule_id] = str(md_file)

    return issues


def main():
    if len(sys.argv) < 2:
        print("Usage: validate-rules.py <rules-source-dir>")
        sys.exit(1)

    rules_dir = sys.argv[1]
    all_issues = []
    file_count = 0
    pass_count = 0

    print(f"Validating rules in: {rules_dir}\n")

    # Per-file validation
    for md_file in sorted(Path(rules_dir).rglob("*.md")):
        if md_file.name.startswith("_") or md_file.name == "README.md":
            continue
        file_count += 1
        issues = validate_rule(str(md_file))
        if issues:
            all_issues.extend(issues)
            errors = [i for i in issues if i["severity"] == "error"]
            warnings = [i for i in issues if i["severity"] == "warning"]
            status = "FAIL" if errors else "WARN"
            print(f"  [{status}] {md_file.name}")
            for issue in issues:
                icon = "x" if issue["severity"] == "error" else "!"
                print(f"    [{icon}] {issue['message']}")
        else:
            pass_count += 1
            print(f"  [PASS] {md_file.name}")

    # Dependency validation
    print("\nDependency check:")
    dep_issues = validate_dependencies(rules_dir)
    all_issues.extend(dep_issues)
    if dep_issues:
        for issue in dep_issues:
            filepath = Path(issue["file"]).name
            print(f"  [x] {filepath}: {issue['message']}")
    else:
        print("  [PASS] All dependencies resolved")

    # Summary
    errors = [i for i in all_issues if i["severity"] == "error"]
    warnings = [i for i in all_issues if i["severity"] == "warning"]

    print(f"\n{'=' * 50}")
    print(f"Files: {file_count} | Pass: {pass_count} | Errors: {len(errors)} | Warnings: {len(warnings)}")

    if errors:
        print("\nRESULT: FAIL")
        sys.exit(1)
    elif warnings:
        print("\nRESULT: PASS (with warnings)")
    else:
        print("\nRESULT: PASS")


if __name__ == "__main__":
    main()
