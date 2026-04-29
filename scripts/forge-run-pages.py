#!/usr/bin/env python3
"""
forge-run-pages.py — 장기 구현 작업 페이지별 오케스트레이션

사용법:
  python3 /home/damools/forge/scripts/forge-run-pages.py \
    --task task.md --pages pages/ [--output output/] [--resume] [--dry-run]

구조:
  task.md       — 전체 작업 컨텍스트 (모든 페이지에 주입)
  pages/        — 001-create-schema.md, 002-add-api.md ... (정렬 순 실행)
  output/       — 페이지별 결과 저장
  progress.json — 완료 추적, --resume으로 재개
"""

import os
import sys
import json
import glob
import subprocess
import argparse
from datetime import datetime


def load_progress(path):
    if os.path.exists(path):
        return json.load(open(path, encoding='utf-8'))
    return {"completed": [], "failed": [], "started_at": datetime.now().isoformat()}


def save_progress(path, progress):
    progress["last_run"] = datetime.now().isoformat()
    json.dump(progress, open(path, 'w', encoding='utf-8'), indent=2, ensure_ascii=False)


def get_pages(pages_dir):
    return sorted(glob.glob(os.path.join(pages_dir, "*.md")))


def run_page(task_content, page_content, page_name, output_dir):
    prompt = f"""# 전체 작업 컨텍스트
{task_content}

---
# 현재 단계: {page_name}

{page_content}
"""
    output_file = os.path.join(output_dir, page_name.replace('.md', '-output.md'))

    try:
        result = subprocess.run(
            ['claude', '--print'],
            input=prompt,
            capture_output=True,
            text=True,
            timeout=300,
            encoding='utf-8',
        )
    except FileNotFoundError:
        return False, "claude CLI 미설치 — npm install -g @anthropic-ai/claude-code"
    except subprocess.TimeoutExpired:
        return False, "timeout (300s 초과)"

    if result.returncode != 0:
        return False, result.stderr.strip() or "non-zero exit"

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"# Output: {page_name}\n")
        f.write(f"Generated: {datetime.now().isoformat()}\n\n")
        f.write(result.stdout)

    return True, output_file


def main():
    parser = argparse.ArgumentParser(description='Forge 장기 작업 페이지별 오케스트레이션')
    parser.add_argument('--task',    required=True, help='전체 컨텍스트 파일 (task.md)')
    parser.add_argument('--pages',   required=True, help='페이지 디렉토리')
    parser.add_argument('--output',  default='output', help='결과 저장 디렉토리 (기본: output/)')
    parser.add_argument('--resume',  action='store_true', help='progress.json에서 재개')
    parser.add_argument('--dry-run', action='store_true', help='계획만 출력, 실행 없음')
    args = parser.parse_args()

    task_file    = os.path.abspath(args.task)
    pages_dir    = os.path.abspath(args.pages)
    output_dir   = os.path.abspath(args.output)
    progress_file = os.path.join(output_dir, 'progress.json')

    # 검증
    if not os.path.exists(task_file):
        print(f"ERROR: task 파일 없음: {task_file}", file=sys.stderr); sys.exit(1)
    if not os.path.exists(pages_dir):
        print(f"ERROR: pages 디렉토리 없음: {pages_dir}", file=sys.stderr); sys.exit(1)

    os.makedirs(output_dir, exist_ok=True)

    task_content = open(task_file, encoding='utf-8').read()
    pages = get_pages(pages_dir)

    if not pages:
        print(f"ERROR: {pages_dir}에 .md 파일 없음", file=sys.stderr); sys.exit(1)

    progress = load_progress(progress_file) if args.resume else {
        "completed": [], "failed": [], "started_at": datetime.now().isoformat()
    }

    print(f"=== forge-run-pages ===")
    print(f"task   : {task_file}")
    print(f"pages  : {len(pages)}개  ({pages_dir})")
    print(f"output : {output_dir}")
    print(f"resume : {args.resume}  (완료 {len(progress['completed'])}개 / 실패 {len(progress['failed'])}개)")
    print()

    if args.dry_run:
        for i, page in enumerate(pages, 1):
            name = os.path.basename(page)
            if name in progress["completed"]:
                status = "✅ 완료"
            elif name in progress["failed"]:
                status = "❌ 실패"
            else:
                status = "⏳ 대기"
            print(f"  {i:03d}. {name} — {status}")
        return

    total = len(pages)
    done  = len([p for p in pages if os.path.basename(p) in progress["completed"]])

    for page in pages:
        name = os.path.basename(page)

        if name in progress["completed"]:
            print(f"[SKIP] {name}")
            continue

        page_content = open(page, encoding='utf-8').read()
        idx = pages.index(page) + 1
        print(f"[{idx}/{total}] {name}", flush=True)

        success, result = run_page(task_content, page_content, name, output_dir)

        if success:
            if name in progress["failed"]:
                progress["failed"].remove(name)
            progress["completed"].append(name)
            save_progress(progress_file, progress)
            done += 1
            print(f"       → ✅ {result}")
        else:
            if name not in progress["failed"]:
                progress["failed"].append(name)
            save_progress(progress_file, progress)
            print(f"       → ❌ {result}", file=sys.stderr)
            print(f"재개: python3 {os.path.abspath(__file__)} --task {args.task} --pages {args.pages} --output {args.output} --resume")
            sys.exit(1)

    print()
    print(f"=== 완료: {done}/{total} ===")


if __name__ == '__main__':
    main()
