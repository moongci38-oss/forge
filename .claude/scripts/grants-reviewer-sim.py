#!/usr/bin/env python3
"""
grants-reviewer-sim.py — Ollama gemma3 기반 심사위원 페르소나 시뮬레이션
Usage: python3 ~/.claude/scripts/grants-reviewer-sim.py <grants_doc.md>
       cat grants.md | python3 ~/.claude/scripts/grants-reviewer-sim.py

심사위원 역할: 한국 정부과제 R&D 심사위원 (IITP/NIPA/NRF 기준)
평가 항목: 필요성·목표·추진전략·연구팀·기대성과·사업화 가능성
"""
import sys
import json
import urllib.request
import urllib.error
import os

OLLAMA_URL = "http://localhost:11434/api/generate"
# gemma3가 없으면 사용 가능한 모델로 fallback
PREFERRED_MODELS = ["gemma3:latest", "gemma3:1b", "llama3.2:latest", "llama3.2:1b", "mistral:latest"]

PERSONA_PROMPT = """당신은 한국 정부 R&D 과제 심사위원입니다. IITP(정보통신기획평가원)/NIPA/NRF 기준으로 다음 사업계획서를 평가하세요.

평가 기준 (100점 만점):
- 연구개발의 필요성 및 목표 명확성 (20점)
- 연구개발 내용 및 추진전략 구체성 (25점)
- 연구팀 역량 및 실현 가능성 (20점)
- 기대성과 및 활용방안 (20점)
- 사업화/파급효과 (15점)

제출된 사업계획서:
---
{document}
---

아래 JSON 형식으로만 응답하세요:
{{
  "total_score": 0-100,
  "breakdown": {{
    "필요성_목표": 0-20,
    "연구내용_전략": 0-25,
    "연구팀_실현가능성": 0-20,
    "기대성과_활용": 0-20,
    "사업화_파급효과": 0-15
  }},
  "strengths": ["강점1", "강점2"],
  "weaknesses": ["약점1", "약점2"],
  "critical_issues": ["치명적 문제1 (있을 경우)"],
  "recommendations": ["개선 권고1", "개선 권고2", "개선 권고3"],
  "decision": "선정" or "수정 후 재심" or "탈락",
  "decision_reason": "판단 근거 2-3문장"
}}"""

def get_available_model():
    try:
        req = urllib.request.Request("http://localhost:11434/api/tags")
        with urllib.request.urlopen(req, timeout=3) as resp:
            data = json.loads(resp.read())
            available = [m["name"] for m in data.get("models", [])]
            for model in PREFERRED_MODELS:
                if any(model in a or a.startswith(model.split(":")[0]) for a in available):
                    return next(a for a in available if model.split(":")[0] in a)
            return available[0] if available else None
    except Exception:
        return None

def evaluate(document: str, model: str) -> dict:
    prompt = PERSONA_PROMPT.format(document=document[:3000])
    payload = json.dumps({
        "model": model,
        "prompt": prompt,
        "stream": False,
        "options": {"temperature": 0.2, "num_predict": 600}
    }).encode()

    req = urllib.request.Request(OLLAMA_URL, data=payload,
                                  headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=120) as resp:
        result = json.loads(resp.read())
        raw = result.get("response", "{}").strip()
        if "```" in raw:
            raw = raw.split("```")[1].replace("json", "").strip()
        return json.loads(raw)

def print_report(result: dict, model: str):
    score = result.get("total_score", "N/A")
    decision = result.get("decision", "N/A")
    print(f"\n{'='*60}")
    print(f"  심사위원 페르소나 시뮬레이션 결과 (모델: {model})")
    print(f"{'='*60}")
    print(f"  종합 점수: {score}/100  |  판정: {decision}")
    print(f"{'='*60}")

    bd = result.get("breakdown", {})
    if bd:
        print("\n[항목별 점수]")
        for k, v in bd.items():
            print(f"  {k}: {v}")

    for section, items in [
        ("강점", result.get("strengths", [])),
        ("약점", result.get("weaknesses", [])),
        ("치명적 문제", result.get("critical_issues", [])),
        ("개선 권고", result.get("recommendations", [])),
    ]:
        if items:
            print(f"\n[{section}]")
            for item in items:
                print(f"  - {item}")

    print(f"\n[판단 근거] {result.get('decision_reason', '')}")
    print()

def main():
    if len(sys.argv) > 1:
        with open(sys.argv[1], encoding="utf-8") as f:
            document = f.read()
    elif not sys.stdin.isatty():
        document = sys.stdin.read()
    else:
        print("Usage: python3 grants-reviewer-sim.py <file.md>")
        print("       cat grants.md | python3 grants-reviewer-sim.py")
        sys.exit(1)

    model = get_available_model()
    if not model:
        print("ERROR: Ollama not running or no models available.")
        print("Install: ollama pull gemma3:1b")
        sys.exit(1)

    print(f"모델 '{model}'로 심사 시뮬레이션 중...")
    try:
        result = evaluate(document, model)
        print_report(result, model)
        # Save JSON result
        out_path = "grants-reviewer-result.json"
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        print(f"JSON 저장: {out_path}")
    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
