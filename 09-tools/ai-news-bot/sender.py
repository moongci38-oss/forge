"""텔레그램 메시지 발송 모듈"""

import httpx

from config import TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID, REQUEST_TIMEOUT

TELEGRAM_API_URL = "https://api.telegram.org/bot{token}/sendMessage"


def send_telegram_message(text: str, parse_mode: str = "MarkdownV2") -> dict:
    """텔레그램 봇으로 메시지 발송

    Args:
        text: 발송할 메시지 텍스트
        parse_mode: 파싱 모드 (MarkdownV2 / HTML)

    Returns:
        Telegram API 응답

    Raises:
        ValueError: 토큰 또는 채팅 ID 미설정
        httpx.HTTPStatusError: API 호출 실패
    """
    if not TELEGRAM_BOT_TOKEN:
        raise ValueError("TELEGRAM_BOT_TOKEN 환경변수가 설정되지 않았습니다")
    if not TELEGRAM_CHAT_ID:
        raise ValueError("TELEGRAM_CHAT_ID 환경변수가 설정되지 않았습니다")

    url = TELEGRAM_API_URL.format(token=TELEGRAM_BOT_TOKEN)

    payload = {
        "chat_id": TELEGRAM_CHAT_ID,
        "text": text,
        "parse_mode": parse_mode,
        "disable_web_page_preview": True,
    }

    resp = httpx.post(url, json=payload, timeout=REQUEST_TIMEOUT)

    if not resp.is_success:
        error_info = resp.json() if resp.headers.get("content-type", "").startswith("application/json") else resp.text
        print(f"[Telegram] 발송 실패 ({resp.status_code}): {error_info}")

        # MarkdownV2 파싱 실패 시 일반 텍스트로 재시도
        if resp.status_code == 400 and parse_mode == "MarkdownV2":
            print("[Telegram] 일반 텍스트로 재시도...")
            payload["parse_mode"] = ""
            # 마크다운 이스케이프 문자 제거
            payload["text"] = text.replace("\\", "")
            resp = httpx.post(url, json=payload, timeout=REQUEST_TIMEOUT)

    resp.raise_for_status()
    return resp.json()


def send_reports(tech_message: str, business_message: str) -> tuple[dict, dict]:
    """기술 + 비즈니스 리포트를 순차 발송

    Returns:
        (tech_response, business_response)
    """
    print("[Telegram] 기술 리포트 발송 중...")
    tech_resp = send_telegram_message(tech_message)
    print("[Telegram] 기술 리포트 발송 완료 ✓")

    print("[Telegram] 비즈니스 리포트 발송 중...")
    biz_resp = send_telegram_message(business_message)
    print("[Telegram] 비즈니스 리포트 발송 완료 ✓")

    return tech_resp, biz_resp
