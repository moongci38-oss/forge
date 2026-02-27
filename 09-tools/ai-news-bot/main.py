#!/usr/bin/env python3
"""AI News Telegram Bot — 주간 AI 뉴스 수집 및 텔레그램 발송

매주 월요일 10시(KST) 자동 실행.
기술/비즈니스 2개 리포트를 텔레그램 메시지로 발송하고,
01-research/weekly/에 아카이브를 저장한다.

사용법:
    python main.py              # 수집 + 텔레그램 발송 + 아카이브 저장
    python main.py --dry-run    # 수집 + 콘솔 출력만 (발송 안 함)
    python main.py --archive-only  # 수집 + 아카이브 저장만 (발송 안 함)
"""

import os
import sys
import argparse
from pathlib import Path

# .env 파일 로드 (로컬 실행 시)
try:
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).parent / ".env")
except ImportError:
    pass

# 프로젝트 루트를 sys.path에 추가
sys.path.insert(0, str(Path(__file__).parent))

from collectors import (
    collect_hackernews,
    collect_arxiv,
    collect_google_news,
    collect_reddit,
)
from formatter import format_tech_report, format_business_report, format_archive_report
from sender import send_reports
from config import ARCHIVE_DIR, get_report_period


def collect_all() -> dict:
    """모든 소스에서 뉴스 수집"""
    print("=" * 50)
    print("📡 뉴스 수집 시작")
    print("=" * 50)

    data = {}

    collectors = [
        ("hackernews", "HackerNews", collect_hackernews),
        ("arxiv", "arXiv", collect_arxiv),
        ("google_news", "Google News", collect_google_news),
        ("reddit", "Reddit", collect_reddit),
    ]

    for key, name, collector_fn in collectors:
        print(f"\n[{name}] 수집 중...")
        try:
            result = collector_fn()
            data[key] = result
            tech_count = len(result.get("tech", []))
            biz_count = len(result.get("business", []))
            print(f"[{name}] 완료 — Tech: {tech_count}건, Business: {biz_count}건")
        except Exception as e:
            print(f"[{name}] 실패: {e}")
            data[key] = {"tech": [], "business": []}

    # 총 수집량 요약
    total_tech = sum(len(v.get("tech", [])) for v in data.values())
    total_biz = sum(len(v.get("business", [])) for v in data.values())
    print(f"\n📊 총 수집: Tech {total_tech}건, Business {total_biz}건")

    return data


def save_archive(collected_data: dict) -> str:
    """아카이브 파일 저장"""
    period = get_report_period()
    archive_dir = Path(ARCHIVE_DIR)
    archive_dir.mkdir(parents=True, exist_ok=True)

    filename = f"{period['label']}-ai-news.md"
    filepath = archive_dir / filename

    content = format_archive_report(collected_data)
    filepath.write_text(content, encoding="utf-8")
    print(f"\n💾 아카이브 저장: {filepath}")
    return str(filepath)


def main():
    parser = argparse.ArgumentParser(description="AI News Telegram Bot")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="수집 + 콘솔 출력만 (텔레그램 발송 안 함)",
    )
    parser.add_argument(
        "--archive-only",
        action="store_true",
        help="수집 + 아카이브 저장만 (텔레그램 발송 안 함)",
    )
    args = parser.parse_args()

    # 1. 뉴스 수집
    collected_data = collect_all()

    # 2. 리포트 포맷팅
    print("\n📝 리포트 생성 중...")
    tech_msg = format_tech_report(collected_data)
    biz_msg = format_business_report(collected_data)

    # 3. 아카이브 저장
    save_archive(collected_data)

    # 4. dry-run 모드
    if args.dry_run:
        print("\n" + "=" * 50)
        print("🔬 기술 리포트 (미리보기)")
        print("=" * 50)
        # 이스케이프 제거해서 가독성 확보
        print(tech_msg.replace("\\", ""))
        print("\n" + "=" * 50)
        print("💼 비즈니스 리포트 (미리보기)")
        print("=" * 50)
        print(biz_msg.replace("\\", ""))
        print(f"\n✅ dry-run 완료 (텔레그램 발송 생략)")
        return

    if args.archive_only:
        print(f"\n✅ archive-only 완료 (텔레그램 발송 생략)")
        return

    # 5. 텔레그램 발송
    print("\n📤 텔레그램 발송 중...")
    try:
        tech_resp, biz_resp = send_reports(tech_msg, biz_msg)
        print("\n✅ 모든 리포트 발송 완료!")
    except Exception as e:
        print(f"\n❌ 텔레그램 발송 실패: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
