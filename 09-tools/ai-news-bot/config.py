"""AI News Bot 설정"""

import os
from datetime import datetime, timedelta, timezone

# Telegram
TELEGRAM_BOT_TOKEN = os.environ.get("TELEGRAM_BOT_TOKEN", "")
TELEGRAM_CHAT_ID = os.environ.get("TELEGRAM_CHAT_ID", "")

# Timezone: KST (UTC+9)
KST = timezone(timedelta(hours=9))

# 리포트 기간 (최근 7일)
REPORT_DAYS = 7

# 수집 설정
MAX_ITEMS_PER_SOURCE = 10
REQUEST_TIMEOUT = 15  # seconds
USER_AGENT = "AINewsBot/1.0 (weekly-digest; +https://github.com)"

# 뉴스 수집 키워드
TECH_KEYWORDS = [
    "artificial intelligence",
    "large language model",
    "LLM",
    "AI agent",
    "machine learning",
    "GPT",
    "Claude",
    "neural network",
    "transformer model",
    "open source AI",
]

BUSINESS_KEYWORDS = [
    "AI startup",
    "AI funding",
    "AI business",
    "AI product launch",
    "generative AI market",
    "AI SaaS",
    "AI acquisition",
]

# arXiv 카테고리
ARXIV_CATEGORIES = ["cs.AI", "cs.CL", "cs.LG"]

# Reddit 서브레딧
TECH_SUBREDDITS = ["MachineLearning", "LocalLLaMA"]
BUSINESS_SUBREDDITS = ["artificial", "singularity"]

# Telegram 메시지 길이 제한
TELEGRAM_MAX_LENGTH = 4096

# 아카이브 경로 (워크스페이스 루트 기준)
ARCHIVE_DIR = os.environ.get(
    "ARCHIVE_DIR",
    os.path.join(os.path.dirname(__file__), "..", "..", "01-research", "weekly"),
)


def get_report_period():
    """리포트 대상 기간 계산 (지난 7일)"""
    now = datetime.now(KST)
    end_date = now
    start_date = end_date - timedelta(days=REPORT_DAYS)
    week_number = now.isocalendar()[1]
    year = now.year
    return {
        "start": start_date,
        "end": end_date,
        "week": week_number,
        "year": year,
        "label": f"{year}-W{week_number:02d}",
        "range_str": f"{start_date.strftime('%Y-%m-%d')} ~ {end_date.strftime('%Y-%m-%d')}",
    }
