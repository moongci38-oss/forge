#!/usr/bin/env python3
"""
Forge Evals Validator — CI/CD용
두 가지 모드:
  1. structure  : evals.json 구조 검증 (빠름, 항상 실행)
  2. llm-judge  : LLM as Judge로 expectations 평가 (Haiku, 수동/스케줄 실행)

사용법:
  python3 validate-evals.py structure           # 구조 검증만
  python3 validate-evals.py llm-judge           # LLM 평가 (전체 중 1개/skill)
  python3 validate-evals.py llm-judge --skill system-audit  # 특정 스킬
  python3 validate-evals.py llm-judge --max 10  # 최대 10개 eval만
"""

import json
import os
import sys
import glob
import argparse
from pathlib import Path

FORGE_ROOT = Path(os.environ.get("FORGE_ROOT", Path.home() / "forge"))
SKILLS_DIR = FORGE_ROOT / ".claude/skills"

REQUIRED_FIELDS = ["skill_name", "evals"]
EVAL_REQUIRED = ["id", "prompt", "expected_output", "expectations"]


# ── 구조 검증 ──────────────────────────────────────────────────────────────

def validate_structure():
    """모든 evals.json 파일 구조 검증"""
    evals_files = list(SKILLS_DIR.glob("*/evals/evals.json"))
    if not evals_files:
        print("❌ evals.json 파일 없음")
        sys.exit(1)

    errors = []
    warnings = []
    total_evals = 0

    for path in sorted(evals_files):
        skill = path.parent.parent.name
        try:
            data = json.loads(path.read_text())
        except json.JSONDecodeError as e:
            errors.append(f"{skill}: JSON 파싱 실패 — {e}")
            continue

        # 필수 필드 확인
        for field in REQUIRED_FIELDS:
            if field not in data:
                errors.append(f"{skill}: 필수 필드 '{field}' 없음")

        evals = data.get("evals", [])
        if not evals:
            warnings.append(f"{skill}: evals 배열이 비어 있음")
            continue

        total_evals += len(evals)

        for i, ev in enumerate(evals):
            for field in ["id", "prompt", "expected_output"]:
                if field not in ev:
                    errors.append(f"{skill}[{i}]: 필수 필드 '{field}' 없음")
            # expectations 또는 assertions 중 하나 존재해야 함
            exps = ev.get("expectations", ev.get("assertions", []))
            if not exps:
                errors.append(f"{skill}[{i}]: expectations 또는 assertions 비어 있음")
            elif len(exps) < 3:
                warnings.append(f"{skill}[{i}]: check 항목 {len(exps)}개 (권장 3+)")
            # prompt 길이 검증
            if len(ev.get("prompt", "")) < 10:
                errors.append(f"{skill}[{i}]: prompt가 너무 짧음")

    # 결과 출력
    print(f"\n📋 Evals 구조 검증 결과")
    print(f"   스킬 수: {len(evals_files)}")
    print(f"   총 eval 수: {total_evals}")

    if warnings:
        print(f"\n⚠️  경고 {len(warnings)}건:")
        for w in warnings:
            print(f"   • {w}")

    if errors:
        print(f"\n❌ 오류 {len(errors)}건:")
        for e in errors:
            print(f"   • {e}")
        sys.exit(1)

    print(f"\n✅ 구조 검증 PASS ({len(evals_files)}개 스킬, {total_evals}개 eval)")


# ── LLM Judge ──────────────────────────────────────────────────────────────

def run_llm_judge(skill_filter=None, max_evals=None):
    """LLM(Haiku)으로 스킬별 대표 eval 1개 평가"""
    try:
        import anthropic
    except ImportError:
        print("❌ anthropic 패키지 필요: pip install anthropic")
        sys.exit(1)

    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        env_file = FORGE_ROOT / ".env"
        if env_file.exists():
            for line in env_file.read_text().splitlines():
                if "=" in line and line.startswith("ANTHROPIC_API_KEY"):
                    api_key = line.split("=", 1)[1].strip()
                    break
    if not api_key:
        print("❌ ANTHROPIC_API_KEY 없음")
        sys.exit(1)

    client = anthropic.Anthropic(api_key=api_key)

    evals_files = sorted(SKILLS_DIR.glob("*/evals/evals.json"))
    if skill_filter:
        evals_files = [f for f in evals_files if skill_filter in f.parent.parent.name]

    results = {"pass": 0, "fail": 0, "skip": 0}
    eval_count = 0

    print(f"\n🤖 LLM Judge 실행 (Haiku, 스킬당 1개)")
    print(f"{'='*60}")

    for path in evals_files:
        if max_evals and eval_count >= max_evals:
            break

        skill = path.parent.parent.name
        try:
            data = json.loads(path.read_text())
        except Exception:
            results["skip"] += 1
            continue

        evals = data.get("evals", [])
        if not evals:
            results["skip"] += 1
            continue

        # 스킬당 첫 번째 eval만 평가
        ev = evals[0]
        prompt = ev.get("prompt", "")
        expected = ev.get("expected_output", "")
        expectations = ev.get("expectations", [])

        # Haiku로 expectations 품질 평가
        judge_prompt = f"""다음은 AI 스킬의 Eval(평가 항목)입니다.
아래 기준으로 이 eval이 충분히 명확하고 측정 가능한지 판단하세요.

스킬: {skill}
프롬프트: {prompt}
기대 출력: {expected}
Expectations:
{chr(10).join(f'- {e}' for e in expectations)}

평가 기준:
1. expectations가 구체적이고 측정 가능한가?
2. 합격/불합격 판별이 명확히 가능한가?
3. 프롬프트와 expectations가 일관성 있는가?

판정: PASS 또는 FAIL로만 답하고, 한 줄 이유를 추가하세요.
형식: PASS|이유 또는 FAIL|이유"""

        try:
            resp = client.messages.create(
                model="claude-haiku-4-5-20251001",
                max_tokens=100,
                messages=[{"role": "user", "content": judge_prompt}]
            )
            verdict = resp.content[0].text.strip()
            is_pass = verdict.upper().startswith("PASS")
            status = "✅" if is_pass else "❌"
            results["pass" if is_pass else "fail"] += 1
            print(f"{status} {skill}: {verdict[:80]}")
        except Exception as e:
            print(f"⚠️  {skill}: 평가 실패 — {e}")
            results["skip"] += 1

        eval_count += 1

    print(f"\n{'='*60}")
    print(f"결과: PASS {results['pass']} / FAIL {results['fail']} / SKIP {results['skip']}")

    if results["fail"] > 0:
        print("❌ LLM Judge FAIL")
        sys.exit(1)
    else:
        print("✅ LLM Judge PASS")


# ── 메인 ──────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Forge Evals Validator")
    parser.add_argument("mode", choices=["structure", "llm-judge"],
                        help="검증 모드")
    parser.add_argument("--skill", help="특정 스킬만 평가 (llm-judge용)")
    parser.add_argument("--max", type=int, help="최대 eval 수 (llm-judge용)")
    args = parser.parse_args()

    if args.mode == "structure":
        validate_structure()
    elif args.mode == "llm-judge":
        run_llm_judge(skill_filter=args.skill, max_evals=args.max)


if __name__ == "__main__":
    main()
