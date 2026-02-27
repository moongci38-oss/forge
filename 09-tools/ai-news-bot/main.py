#!/usr/bin/env python3
"""AI News Bot — 주간 AI 뉴스 수집 및 Notion/텔레그램 발송

매주 월요일 10시(KST) 자동 실행.
기술+비즈니스 통합 리포트를 Notion 데이터베이스에 추가하고,
01-research/weekly/에 아카이브를 저장한다.

사용법:
    python main.py                    # Notion 발송 + 아카이브 저장 (기본)
    python main.py --dry-run          # 수집 + 콘솔 출력만
    python main.py --telegram         # Notion + 텔레그램 동시 발송
    python main.py --telegram-only    # 텔레그램만 발송
    python main.py --archive-only     # 아카이브 저장만
    python main.py --setup-db         # Notion 데이터베이스 최초 생성
"""

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
from config import ARCHIVE_DIR, NOTION_DATABASE_ID, get_report_period


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


def send_to_notion(collected_data: dict) -> str:
    """Notion 데이터베이스에 리포트 추가"""
    from notion_sender import add_report_to_database

    db_id = NOTION_DATABASE_ID
    if not db_id:
        print("❌ NOTION_DATABASE_ID가 설정되지 않았습니다.")
        print("   먼저 `python main.py --setup-db`를 실행하세요.")
        sys.exit(1)

    print("\n📤 Notion 발송 중...")
    page_url = add_report_to_database(db_id, collected_data)
    print(f"✅ Notion 페이지 생성: {page_url}")
    return page_url


def send_to_telegram(collected_data: dict):
    """텔레그램으로 리포트 발송"""
    from sender import send_reports

    print("\n📤 텔레그램 발송 중...")
    tech_msg = format_tech_report(collected_data)
    biz_msg = format_business_report(collected_data)
    send_reports(tech_msg, biz_msg)
    print("✅ 텔레그램 발송 완료!")


def setup_notion_db():
    """Notion 데이터베이스 최초 생성"""
    from notion_sender import setup_database
    setup_database()


def main():
    parser = argparse.ArgumentParser(description="AI News Bot")
    parser.add_argument(
        "--dry-run", action="store_true",
        help="수집 + 콘솔 출력만 (발송 안 함)",
    )
    parser.add_argument(
        "--archive-only", action="store_true",
        help="수집 + 아카이브 저장만",
    )
    parser.add_argument(
        "--telegram", action="store_true",
        help="Notion + 텔레그램 동시 발송",
    )
    parser.add_argument(
        "--telegram-only", action="store_true",
        help="텔레그램만 발송 (Notion 생략)",
    )
    parser.add_argument(
        "--setup-db", action="store_true",
        help="Notion 데이터베이스 최초 생성",
    )
    args = parser.parse_args()

    # DB 설정 모드
    if args.setup_db:
        setup_notion_db()
        return

    # 1. 뉴스 수집
    collected_data = collect_all()

    # 2. 아카이브 저장
    save_archive(collected_data)

    # 3. dry-run 모드
    if args.dry_run:
        archive_report = format_archive_report(collected_data)
        print("\n" + "=" * 50)
        print("📰 통합 리포트 미리보기")
        print("=" * 50)
        print(archive_report)
        print(f"\n✅ dry-run 완료 (발송 생략)")
        return

    if args.archive_only:
        print(f"\n✅ archive-only 완료 (발송 생략)")
        return

    # 4. 발송
    try:
        if args.telegram_only:
            send_to_telegram(collected_data)
        else:
            # 기본: Notion 발송
            send_to_notion(collected_data)
            # --telegram 플래그 있으면 텔레그램도
            if args.telegram:
                send_to_telegram(collected_data)
    except Exception as e:
        print(f"\n❌ 발송 실패: {e}")
        sys.exit(1)

    print("\n✅ 모든 작업 완료!")


if __name__ == "__main__":
    main()
