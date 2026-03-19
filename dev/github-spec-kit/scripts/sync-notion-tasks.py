#!/usr/bin/env python3
"""
Sync todo.md status changes to Notion Tasks DB.

Runs after update-todo.py in the same GitHub Actions workflow.
Also supports standalone 'register' action for initial bulk registration.

Actions:
  register  — Initial bulk registration (all todo.md rows → Notion)
  doing     — Branch created: find/create task, set status to 진행중
  done      — PR merged: update status to 완료 + PR URL + completion date

Env vars (all optional — graceful skip if missing):
  NOTION_API_TOKEN     — Notion Internal Integration token
  NOTION_TASKS_DB_ID   — Tasks database ID (UUID, no dashes OK)
  NOTION_PROJECT_NAME  — Project name matching Notion select (e.g., "GodBlade")

Config fallback:
  If NOTION_TASKS_DB_ID or NOTION_PROJECT_NAME are not set, reads from
  .specify/config.json -> notion.tasksDbId / notion.projectName

Usage:
  python3 sync-notion-tasks.py register <todo-file>
  python3 sync-notion-tasks.py doing <branch-name> <todo-file>
  python3 sync-notion-tasks.py done <branch-name> <pr-number> <pr-url> <todo-file>

Source of truth: ~/.claude/forge/github-spec-kit/scripts/sync-notion-tasks.py
Deployment: Copy to .github/scripts/sync-notion-tasks.py via forge-sync
"""
import json
import os
import re
import sys
import urllib.request
import urllib.error
from datetime import datetime, timezone

NOTION_API_URL = "https://api.notion.com/v1"
NOTION_VERSION = "2022-06-28"

# todo.md status emoji → Notion status value
STATUS_MAP = {
    "⬜": "할 일",
    "Todo": "할 일",
    "🔄": "진행중",
    "Doing": "진행중",
    "🧪": "QA",
    "QA": "QA",
    "✅": "완료",
    "Done": "완료",
}

# todo.md Type → Notion 유형
TYPE_MAP = {
    "feat": "신규기능",
    "fix": "버그",
    "hotfix": "핫픽스",
    "upgrade": "업그레이드",
}


def get_config(todo_file: str) -> tuple[str | None, str | None]:
    """Read Notion config from .specify/config.json as fallback."""
    # Walk up from todo_file to find .specify/config.json
    search = os.path.dirname(os.path.abspath(todo_file))
    for _ in range(10):
        config_path = os.path.join(search, ".specify", "config.json")
        if os.path.exists(config_path):
            try:
                with open(config_path) as f:
                    cfg = json.load(f)
                notion = cfg.get("notion", {})
                return notion.get("tasksDbId"), notion.get("projectName")
            except (json.JSONDecodeError, OSError):
                pass
        parent = os.path.dirname(search)
        if parent == search:
            break
        search = parent
    return None, None


def resolve_env(todo_file: str) -> tuple[str | None, str | None, str | None]:
    """Resolve NOTION_API_TOKEN, DB ID, and project name from env + config."""
    token = os.environ.get("NOTION_API_TOKEN")
    db_id = os.environ.get("NOTION_TASKS_DB_ID")
    project = os.environ.get("NOTION_PROJECT_NAME")

    if not db_id or not project:
        cfg_db, cfg_proj = get_config(todo_file)
        db_id = db_id or cfg_db
        project = project or cfg_proj

    # Normalize DB ID — remove dashes if present, then re-add
    if db_id:
        db_id = db_id.replace("-", "")
        if len(db_id) == 32:
            db_id = f"{db_id[:8]}-{db_id[8:12]}-{db_id[12:16]}-{db_id[16:20]}-{db_id[20:]}"

    return token, db_id, project


def get_headers(token: str) -> dict:
    return {
        "Authorization": f"Bearer {token}",
        "Notion-Version": NOTION_VERSION,
        "Content-Type": "application/json",
    }


def notion_request(method: str, url: str, headers: dict, payload: dict | None = None) -> dict | None:
    """Make a Notion API request, return parsed JSON or None on error."""
    data = json.dumps(payload).encode() if payload else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        print(f"  Notion API error {e.code}: {body[:200]}")
        return None


# ---------------------------------------------------------------------------
# todo.md parsing
# ---------------------------------------------------------------------------

def parse_todo_table(todo_file: str) -> list[dict]:
    """Parse the '## Trine 개발 진행' kanban table into list of row dicts."""
    with open(todo_file, "r", encoding="utf-8") as f:
        lines = f.readlines()

    rows: list[dict] = []
    headers: list[str] = []
    in_table = False

    for line in lines:
        stripped = line.strip()

        # Detect header row by presence of key columns
        if not in_table and "|" in stripped and "Spec" in stripped and "Status" in stripped:
            headers = [h.strip() for h in stripped.split("|") if h.strip()]
            in_table = True
            continue

        # Skip separator row
        if in_table and re.match(r"^\|[\s:-]+\|", stripped):
            continue

        # Data row
        if in_table and stripped.startswith("|") and "|" in stripped[1:]:
            cells = [c.strip() for c in stripped.split("|") if c.strip()]
            if len(cells) >= len(headers):
                row = dict(zip(headers, cells[: len(headers)]))
                rows.append(row)
            continue

        # End of table
        if in_table and not stripped.startswith("|"):
            in_table = False

    return rows


def extract_keywords(branch: str) -> list[str]:
    """Extract meaningful keywords from branch name."""
    spec = branch.split("/", 1)[-1] if "/" in branch else branch
    return [k.lower() for k in spec.split("-") if len(k) > 1]


def match_row(rows: list[dict], keywords: list[str], statuses: list[str] | None = None) -> dict | None:
    """Find the best matching row by keywords, optionally filtered by status."""
    best_row = None
    best_score = 0

    for row in rows:
        spec = row.get("Spec", "").lower()
        status = row.get("Status", "")

        if statuses:
            if not any(s in status for s in statuses):
                continue

        score = sum(1 for k in keywords if k in spec)
        if score > best_score:
            best_score = score
            best_row = row

    return best_row if best_score >= 1 else None


def status_to_notion(status_text: str) -> str:
    """Map todo.md Status cell to Notion status value."""
    for emoji, notion_val in STATUS_MAP.items():
        if emoji in status_text:
            return notion_val
    return "할 일"


def type_to_notion(type_text: str) -> str:
    """Map todo.md Type cell to Notion 유형 value."""
    return TYPE_MAP.get(type_text.lower().strip(), "기능추가")


def parse_sp(sp_text: str) -> int:
    """Parse SP number from cell text."""
    match = re.search(r"\d+", sp_text)
    return int(match.group()) if match else 0


# ---------------------------------------------------------------------------
# Notion CRUD
# ---------------------------------------------------------------------------

def query_tasks(db_id: str, spec_name: str, project_name: str, headers: dict) -> list[dict]:
    """Find existing tasks by Spec name and project."""
    payload = {
        "filter": {
            "and": [
                {"property": "Spec", "rich_text": {"contains": spec_name}},
                {"property": "프로젝트", "select": {"equals": project_name}},
            ]
        }
    }
    result = notion_request("POST", f"{NOTION_API_URL}/databases/{db_id}/query", headers, payload)
    return result.get("results", []) if result else []


def create_task(db_id: str, row: dict, project_name: str, headers: dict) -> dict | None:
    """Create a new task in Notion Tasks DB."""
    spec_name = row.get("Spec", "").strip()
    properties: dict = {
        "제목": {"title": [{"text": {"content": spec_name}}]},
        "Spec": {"rich_text": [{"text": {"content": spec_name}}]},
        "프로젝트": {"select": {"name": project_name}},
        "상태": {"select": {"name": status_to_notion(row.get("Status", "⬜"))}},
        "유형": {"select": {"name": type_to_notion(row.get("Type", "feat"))}},
        "등록자": {"select": {"name": "AI"}},
        "우선순위": {"select": {"name": "P2-보통"}},
    }

    sp = parse_sp(row.get("SP", "0"))
    if sp > 0:
        properties["SP"] = {"number": sp}

    session = row.get("Session", "").strip()
    if session:
        properties["설명"] = {"rich_text": [{"text": {"content": f"Session: {session}"}}]}

    payload = {"parent": {"database_id": db_id}, "properties": properties}
    result = notion_request("POST", f"{NOTION_API_URL}/pages", headers, payload)
    if result:
        print(f"  Created: {spec_name} → {result.get('id', '?')[:8]}...")
    return result


def update_task(page_id: str, updates: dict, headers: dict) -> dict | None:
    """Update an existing task's properties."""
    result = notion_request("PATCH", f"{NOTION_API_URL}/pages/{page_id}", headers, {"properties": updates})
    if result:
        print(f"  Updated: {page_id[:8]}...")
    return result


# ---------------------------------------------------------------------------
# Actions
# ---------------------------------------------------------------------------

def do_register(todo_file: str, db_id: str, project_name: str, headers: dict) -> None:
    """Register all todo.md rows in Notion (idempotent — skips existing)."""
    rows = parse_todo_table(todo_file)
    if not rows:
        print("No rows found in todo.md Trine table")
        return

    print(f"Registering {len(rows)} rows for project '{project_name}'...")

    for row in rows:
        spec_name = row.get("Spec", "").strip()
        if not spec_name or spec_name == "—":
            continue

        existing = query_tasks(db_id, spec_name, project_name, headers)
        if existing:
            print(f"  Exists: {spec_name} — syncing status")
            page_id = existing[0]["id"]
            updates: dict = {
                "상태": {"select": {"name": status_to_notion(row.get("Status", "⬜"))}},
            }
            # Sync PR if present
            pr = row.get("PR", "").strip()
            if pr and pr != "—":
                match = re.search(r"\((https?://[^)]+)\)", pr)
                if match:
                    updates["PR"] = {"url": match.group(1)}
            # Sync completion date
            done_date = row.get("완료일", "").strip()
            if done_date and done_date != "—":
                updates["완료일"] = {"date": {"start": done_date}}
            update_task(page_id, updates, headers)
        else:
            create_task(db_id, row, project_name, headers)

    print("Registration complete")


def do_doing(branch: str, todo_file: str, db_id: str, project_name: str, headers: dict) -> None:
    """Branch created → find matching task → set 진행중."""
    rows = parse_todo_table(todo_file)
    keywords = extract_keywords(branch)
    row = match_row(rows, keywords, statuses=["⬜", "Todo"])

    if not row:
        print(f"No matching Todo row for branch: {branch} (keywords: {keywords})")
        return

    spec_name = row.get("Spec", "").strip()
    print(f"Branch '{branch}' matched Spec: {spec_name}")

    existing = query_tasks(db_id, spec_name, project_name, headers)
    if existing:
        update_task(existing[0]["id"], {
            "상태": {"select": {"name": "진행중"}},
            "브랜치": {"rich_text": [{"text": {"content": branch}}]},
        }, headers)
    else:
        # Auto-create if not registered yet
        row["Status"] = "🔄 Doing"
        task = create_task(db_id, row, project_name, headers)
        if task:
            update_task(task["id"], {
                "브랜치": {"rich_text": [{"text": {"content": branch}}]},
            }, headers)


def do_done(branch: str, pr_num: str, pr_url: str, todo_file: str,
            db_id: str, project_name: str, headers: dict) -> None:
    """PR merged → find matching task → set 완료 + PR + date."""
    rows = parse_todo_table(todo_file)
    keywords = extract_keywords(branch)
    row = match_row(rows, keywords, statuses=["🔄", "Doing", "🧪", "QA"])

    if not row:
        # Fallback: if only one active row, use it
        active = [r for r in rows if any(s in r.get("Status", "") for s in ["🔄", "🧪"])]
        if len(active) == 1:
            row = active[0]
        else:
            print(f"No matching Doing/QA row for branch: {branch}")
            return

    spec_name = row.get("Spec", "").strip()
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    print(f"PR #{pr_num} merged for Spec: {spec_name}")

    existing = query_tasks(db_id, spec_name, project_name, headers)
    if existing:
        update_task(existing[0]["id"], {
            "상태": {"select": {"name": "완료"}},
            "PR": {"url": pr_url},
            "완료일": {"date": {"start": today}},
        }, headers)
    else:
        print(f"  Task not found in Notion for '{spec_name}', creating as Done")
        row["Status"] = "✅ Done"
        task = create_task(db_id, row, project_name, headers)
        if task:
            update_task(task["id"], {
                "PR": {"url": pr_url},
                "완료일": {"date": {"start": today}},
            }, headers)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    if len(sys.argv) < 3:
        print("Usage:")
        print("  sync-notion-tasks.py register <todo-file>")
        print("  sync-notion-tasks.py doing <branch> <todo-file>")
        print("  sync-notion-tasks.py done <branch> <pr-num> <pr-url> <todo-file>")
        sys.exit(1)

    action = sys.argv[1]

    # Determine todo_file based on action
    if action == "register":
        todo_file = sys.argv[2]
    elif action == "doing":
        todo_file = sys.argv[3]
    elif action == "done":
        todo_file = sys.argv[5]
    else:
        print(f"Unknown action: {action}")
        sys.exit(1)

    # Resolve config
    token, db_id, project_name = resolve_env(todo_file)

    if not token:
        print("NOTION_API_TOKEN not set — skipping Notion sync")
        sys.exit(0)
    if not db_id:
        print("NOTION_TASKS_DB_ID not set and not in .specify/config.json — skipping")
        sys.exit(0)
    if not project_name:
        print("NOTION_PROJECT_NAME not set and not in .specify/config.json — skipping")
        sys.exit(0)

    headers = get_headers(token)
    print(f"Notion sync: action={action} project={project_name} db={db_id[:8]}...")

    if action == "register":
        do_register(todo_file, db_id, project_name, headers)
    elif action == "doing":
        branch = sys.argv[2]
        do_doing(branch, todo_file, db_id, project_name, headers)
    elif action == "done":
        branch = sys.argv[2]
        pr_num = sys.argv[3]
        pr_url = sys.argv[4]
        do_done(branch, pr_num, pr_url, todo_file, db_id, project_name, headers)


if __name__ == "__main__":
    main()
