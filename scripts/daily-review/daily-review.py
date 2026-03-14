#!/usr/bin/env python3
"""daily-review.py — 메인 오케스트레이터

역할: collector.py를 실행하여 raw-data.json을 생성하고,
Claude Code CLI에 /daily-system-review 커맨드를 전달할 준비를 한다.

실행 흐름:
1. collector.py → raw-data.json 생성 (또는 기존 파일 재사용)
2. 생성된 raw-data.json 경로를 stdout에 출력 (run.sh가 사용)
"""

import sys
import subprocess
from datetime import date, timedelta
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
BUSINESS_DIR = SCRIPT_DIR.parent.parent
COLLECTOR = SCRIPT_DIR / "collector.py"


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Daily Review 오케스트레이터")
    parser.add_argument("date", nargs="?", help="분석 기준 날짜 (YYYY-MM-DD). 미입력 시 전날.")
    parser.add_argument("--skip-collect", action="store_true",
                        help="collector.py 실행 스킵 (raw-data.json이 이미 존재할 때)")
    parser.add_argument("--force-collect", action="store_true",
                        help="raw-data.json이 이미 존재해도 재수집")
    args = parser.parse_args()

    if args.date:
        try:
            target = date.fromisoformat(args.date)
        except ValueError:
            print(f"ERROR: 날짜 형식 오류: {args.date}", file=sys.stderr)
            sys.exit(1)
    else:
        target = date.today() - timedelta(days=1)

    raw_json = BUSINESS_DIR / "01-research" / "daily" / target.isoformat() / "raw-data.json"

    # 수집 단계
    if raw_json.exists() and not args.force_collect:
        print(f"[orchestrator] raw-data.json 이미 존재 — 수집 스킵: {raw_json}")
    elif args.skip_collect:
        print("[orchestrator] --skip-collect 지정 — 수집 스킵")
    else:
        print(f"[orchestrator] collector.py 실행 중...")
        result = subprocess.run(
            [sys.executable, str(COLLECTOR), target.isoformat()],
            cwd=str(BUSINESS_DIR),
        )
        if result.returncode != 0:
            print(f"[orchestrator] WARN: collector.py 실패 (exit {result.returncode}). "
                  f"Claude가 런타임에 모든 Tier를 직접 검색합니다.", file=sys.stderr)

    # raw-data.json 경로 출력 (run.sh에서 활용)
    if raw_json.exists():
        print(f"[orchestrator] raw-data.json: {raw_json}")
    else:
        print(f"[orchestrator] raw-data.json 없음 — Claude가 전체 수집합니다.")

    print(f"[orchestrator] 분석 날짜: {target}")


if __name__ == "__main__":
    main()
