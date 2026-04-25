#!/usr/bin/env python3
"""
Auto-update todo.md on branch create (Doing) and PR merge (Done).

Universal script — works with any project that has a todo.md with
a kanban-style table using status emojis (⬜/🔄/🧪/✅).

Usage:
  python3 update-todo.py doing <branch-name> <todo-file>
  python3 update-todo.py done  <branch-name> <pr-number> <pr-url> <todo-file>

Deployment: Copy to scripts/update-todo.py in your project.
Source of truth: ~/.claude/forge/github-spec-kit/scripts/update-todo.py
"""
import json
import os
import sys
import re
from datetime import datetime, timezone


def extract_keywords(branch: str) -> list[str]:
    """Extract meaningful keywords from branch name."""
    spec = branch.split("/", 1)[-1] if "/" in branch else branch
    return [k.lower() for k in spec.split("-") if len(k) > 1]


def load_mapping(todo_file: str, branch: str) -> dict | None:
    """Load todo-mapping.json and find mapping for this branch."""
    project_root = os.path.dirname(os.path.dirname(os.path.dirname(todo_file)))
    mapping_path = os.path.join(project_root, ".claude", "todo-mapping.json")
    if not os.path.exists(mapping_path):
        print(f"Warning: {mapping_path} not found — falling back to keyword fuzzy match")
        return None
    try:
        with open(mapping_path, "r") as f:
            mappings = json.load(f)
        # Strip branch prefix (feat/, fix/, hotfix/)
        key = branch.split("/", 1)[-1] if "/" in branch else branch
        return mappings.get(key)
    except (json.JSONDecodeError, OSError):
        return None


def find_row_by_mapping(lines: list[str], status: str, spec_name: str) -> int:
    """Find row by exact spec name from todo-mapping.json."""
    for i, line in enumerate(lines):
        if status not in line or "|" not in line:
            continue
        if spec_name.lower() in line.lower():
            return i
    return -1


def find_todo_table_row(lines: list[str], status: str, keywords: list[str]) -> int:
    """Find the best matching row with given status emoji."""
    best_idx = -1
    best_score = 0

    for i, line in enumerate(lines):
        if status not in line or "|" not in line:
            continue
        line_lower = line.lower()
        score = sum(1 for k in keywords if k in line_lower)
        if score > best_score:
            best_score = score
            best_idx = i

    return best_idx if best_score >= 1 else -1


def mark_doing(lines: list[str], branch: str, todo_file: str) -> bool:
    keywords = extract_keywords(branch)

    # Try mapping first for precise match
    mapping = load_mapping(todo_file, branch)
    idx = -1
    if mapping and mapping.get("description"):
        idx = find_row_by_mapping(lines, "\u2b1c", mapping["description"])
        if idx >= 0:
            print(f"Matched via todo-mapping.json: {mapping['description']}")

    if idx < 0:
        idx = find_todo_table_row(lines, "\u2b1c", keywords)  # ⬜
    if idx < 0:
        print(f"No matching Todo row found for keywords={keywords}")
        return False

    lines[idx] = lines[idx].replace("\u2b1c Todo", "\U0001f504 Doing")
    print(f"Row {idx}: Todo -> Doing | {lines[idx].strip()}")
    return True


def mark_done(lines: list[str], branch: str, pr_num: str, pr_url: str, todo_file: str) -> bool:
    keywords = extract_keywords(branch)
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")

    # Try mapping first for precise match
    mapping = load_mapping(todo_file, branch)
    idx = -1
    if mapping and mapping.get("description"):
        for status_emoji in ["\U0001f504", "\U0001f9ea"]:  # 🔄, 🧪
            idx = find_row_by_mapping(lines, status_emoji, mapping["description"])
            if idx >= 0:
                print(f"Matched via todo-mapping.json: {mapping['description']}")
                break

    # Fallback to keyword matching: first Doing (🔄), then QA (🧪)
    if idx < 0:
        idx = find_todo_table_row(lines, "\U0001f504", keywords)  # 🔄
    if idx < 0:
        idx = find_todo_table_row(lines, "\U0001f9ea", keywords)  # 🧪
    if idx < 0:
        # Last fallback: if only one active row (Doing or QA), use it
        active_rows = [i for i, l in enumerate(lines)
                       if ("\U0001f504" in l or "\U0001f9ea" in l) and "|" in l]
        if len(active_rows) == 1:
            idx = active_rows[0]
        else:
            print(f"No matching Doing/QA row found for keywords={keywords}")
            return False

    line = lines[idx]
    cells = line.split("|")

    # Find Status cell by emoji (works regardless of column position)
    for j, cell in enumerate(cells):
        if "\U0001f504" in cell or "\U0001f9ea" in cell:
            cells[j] = cell.replace("\U0001f504 Doing", "\u2705 Done").replace("\U0001f9ea QA", "\u2705 Done")
            # PR cell is next, Date cell after that
            if j + 1 < len(cells):
                cells[j + 1] = f" [#{pr_num}]({pr_url}) "
            if j + 2 < len(cells):
                cells[j + 2] = f" {today} "
            break

    lines[idx] = "|".join(cells)
    print(f"Row {idx}: -> Done | {lines[idx].strip()}")
    return True


def main():
    action = sys.argv[1]
    branch = sys.argv[2]

    if action == "doing":
        todo_file = sys.argv[3]
    elif action == "done":
        pr_num = sys.argv[3]
        pr_url = sys.argv[4]
        todo_file = sys.argv[5]
    else:
        print(f"Unknown action: {action}")
        sys.exit(1)

    with open(todo_file, "r") as f:
        lines = f.readlines()

    if action == "doing":
        updated = mark_doing(lines, branch, todo_file)
    else:
        updated = mark_done(lines, branch, pr_num, pr_url, todo_file)

    if updated:
        with open(todo_file, "w") as f:
            f.writelines(lines)
        print("todo.md updated")
    else:
        print("No changes made")

    sys.exit(0 if updated else 0)  # Don't fail workflow if no match


if __name__ == "__main__":
    main()
