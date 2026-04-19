#!/usr/bin/env python3
"""
Forge Advisor Utility — Opus를 Sonnet/Haiku의 조언자(advisor)로 활용

Anthropic Messages API의 `advisor_20260301` tool을 사용하여
실행자(Sonnet/Haiku)가 작업을 주도하고, 판단이 어려운 순간에만 Opus 조언자를 호출.

- Executor: 전체 토큰의 90%+ 처리
- Advisor (Opus): 400~700 토큰 조언만 소비 → Opus 단독 대비 비용 30~85% 절감

## 사용법

```bash
# 1. stdin으로 입력
echo "검토 대상 내용" | advisor-assist.py --task "이 코드의 잠재적 버그 3가지 지적"

# 2. 파일 입력
advisor-assist.py --task "전략 프레이밍 조언" --input draft.md

# 3. 모델/조언 횟수 조정
advisor-assist.py --task "판정" --executor haiku --advisor opus-4-7 --max-uses 2

# 4. JSON 출력
advisor-assist.py --task "검토" --input file.md --format json > result.json

# 5. Forge 스킬 내부에서 Bash 호출
# (예: grants-write.md, pge.md 등에서)
cat draft.md | python3 ~/forge/shared/scripts/advisor-assist.py \
  --task "이 계약 조항의 을 측 리스크 3개 지적" \
  --max-uses 2
```

## 환경변수

- `ANTHROPIC_API_KEY`: 필수. API 크레딧 필요 (Max 구독과 별개).

## 종료 코드

- 0: 성공
- 1: 인자 오류
- 2: API 호출 실패
- 3: 크레딧 부족 (HTTP 400 invalid_request_error)

## 출력

- stdout: Executor의 최종 응답 (text 또는 json)
- stderr: Usage 통계 (executor/advisor 토큰, 비용 추정, 조언 호출 횟수)

출처: forge-outputs/01-research/ai-report/2026-04-10-advisor-strategy-detailed.md
"""
import argparse
import json
import os
import sys
from pathlib import Path

try:
    import anthropic
except ImportError:
    print("ERROR: anthropic SDK not installed. Run: pip install anthropic", file=sys.stderr)
    sys.exit(2)

# ── 기본 설정 ──
DEFAULT_EXECUTOR = "claude-sonnet-4-6"
DEFAULT_ADVISOR = "claude-opus-4-7"
DEFAULT_MAX_USES = 3
DEFAULT_MAX_TOKENS = 4096
ADVISOR_BETA_HEADER = "advisor-2026-03-01"
ADVISOR_TOOL_TYPE = "advisor_20260301"

# 2026-04 기준 토큰당 요금 ($/1M tokens)
PRICING = {
    "claude-haiku-4-5-20251001": {"in": 0.25, "out": 1.25},
    "claude-sonnet-4-6":         {"in": 3.00, "out": 15.00},
    "claude-opus-4-7":           {"in": 15.00, "out": 75.00},
}


def estimate_cost(model, in_tok, out_tok):
    p = PRICING.get(model, {"in": 3.0, "out": 15.0})
    return (in_tok * p["in"] + out_tok * p["out"]) / 1_000_000


def main():
    parser = argparse.ArgumentParser(
        description="Opus를 advisor로 활용하는 Forge 범용 유틸리티",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--task", required=True, help="핵심 프롬프트 (필수)")
    parser.add_argument("--input", help="입력 파일 경로 (미지정 시 stdin)")
    parser.add_argument("--executor", default=DEFAULT_EXECUTOR,
                        help=f"실행자 모델 (기본: {DEFAULT_EXECUTOR})")
    parser.add_argument("--advisor", default=DEFAULT_ADVISOR,
                        help=f"조언자 모델 (기본: {DEFAULT_ADVISOR})")
    parser.add_argument("--max-uses", type=int, default=DEFAULT_MAX_USES,
                        help=f"조언자 최대 호출 횟수 (기본: {DEFAULT_MAX_USES})")
    parser.add_argument("--max-tokens", type=int, default=DEFAULT_MAX_TOKENS,
                        help=f"응답 최대 토큰 (기본: {DEFAULT_MAX_TOKENS})")
    parser.add_argument("--format", choices=["text", "json"], default="text",
                        help="출력 형식 (기본: text)")
    parser.add_argument("--system", default=None, help="system 프롬프트 (선택)")
    parser.add_argument("--dry-run", action="store_true",
                        help="API 호출 없이 요청 payload만 stderr에 출력")
    args = parser.parse_args()

    # 입력 읽기
    if args.input:
        path = Path(args.input)
        if not path.is_file():
            print(f"ERROR: input file not found: {args.input}", file=sys.stderr)
            sys.exit(1)
        content = path.read_text(encoding="utf-8")
    elif not sys.stdin.isatty():
        content = sys.stdin.read()
    else:
        print("ERROR: --input 또는 stdin 둘 중 하나 필요", file=sys.stderr)
        sys.exit(1)

    # 프롬프트 조립
    full_prompt = f"{args.task}\n\n---\n\n{content}"

    # API 키 확인
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print("ERROR: ANTHROPIC_API_KEY 환경변수 미설정", file=sys.stderr)
        sys.exit(1)

    # 요청 payload
    request = {
        "model": args.executor,
        "max_tokens": args.max_tokens,
        "tools": [{
            "type": ADVISOR_TOOL_TYPE,
            "name": "advisor",
            "model": args.advisor,
            "max_uses": args.max_uses,
        }],
        "messages": [{"role": "user", "content": full_prompt}],
    }
    if args.system:
        request["system"] = args.system

    if args.dry_run:
        print("=== DRY RUN ===", file=sys.stderr)
        print(json.dumps(request, ensure_ascii=False, indent=2)[:2000], file=sys.stderr)
        return

    # API 호출
    client = anthropic.Anthropic(api_key=api_key)
    try:
        resp = client.messages.create(
            **request,
            extra_headers={"anthropic-beta": ADVISOR_BETA_HEADER},
        )
    except anthropic.BadRequestError as e:
        msg = str(e)
        if "credit balance is too low" in msg.lower():
            print("ERROR: Anthropic API 크레딧 부족. 충전 필요:", file=sys.stderr)
            print("       https://console.anthropic.com/settings/billing", file=sys.stderr)
            sys.exit(3)
        print(f"ERROR: BadRequest: {msg}", file=sys.stderr)
        sys.exit(2)
    except Exception as e:
        print(f"ERROR: API 호출 실패: {type(e).__name__}: {e}", file=sys.stderr)
        sys.exit(2)

    # 본문 추출
    text_parts = [b.text for b in resp.content if hasattr(b, "text")]
    output_text = "".join(text_parts)

    # 출력
    if args.format == "json":
        result = {
            "text": output_text,
            "stop_reason": resp.stop_reason,
            "executor_model": args.executor,
            "advisor_model": args.advisor,
            "usage": {
                "input_tokens": resp.usage.input_tokens,
                "output_tokens": resp.usage.output_tokens,
            },
        }
        # advisor usage가 별도 필드로 있으면 추가
        if hasattr(resp.usage, "advisor_input_tokens"):
            result["usage"]["advisor_input_tokens"] = resp.usage.advisor_input_tokens
            result["usage"]["advisor_output_tokens"] = resp.usage.advisor_output_tokens
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print(output_text)

    # 비용 요약 (stderr)
    in_tok = resp.usage.input_tokens
    out_tok = resp.usage.output_tokens
    executor_cost = estimate_cost(args.executor, in_tok, out_tok)

    advisor_in = getattr(resp.usage, "advisor_input_tokens", 0) or 0
    advisor_out = getattr(resp.usage, "advisor_output_tokens", 0) or 0
    advisor_cost = estimate_cost(args.advisor, advisor_in, advisor_out)

    total = executor_cost + advisor_cost

    print(
        f"[advisor] executor={args.executor} "
        f"in={in_tok} out={out_tok} cost=${executor_cost:.4f} | "
        f"advisor={args.advisor} in={advisor_in} out={advisor_out} "
        f"cost=${advisor_cost:.4f} | total=${total:.4f}",
        file=sys.stderr,
    )


if __name__ == "__main__":
    main()
