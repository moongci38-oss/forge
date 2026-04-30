# 심사위원 페르소나 시뮬레이션 (실험)

## 목적
Ollama 로컬 LLM(gemma3)으로 한국 정부과제 심사위원 페르소나 구현.
사업계획서 초안을 제출 전 자체 심사 → 약점 조기 발견.

평가 기준 및 프롬프트: `~/.claude/scripts/grants-reviewer-sim.py` PERSONA_PROMPT 섹션 참조.

## 사용법

```bash
python3 ~/.claude/scripts/grants-reviewer-sim.py ~/forge-outputs/09-grants/my-proposal.md
cat proposal.md | python3 ~/.claude/scripts/grants-reviewer-sim.py
```

## 활성화 요구사항

```bash
ollama pull gemma3:1b      # 경량 (권장)
ollama pull gemma3:latest  # 고품질
```

모델 없으면 llama3.2, mistral 자동 fallback.

## 한계
- 로컬 LLM 품질 한계 (실제 심사위원 대체 불가)
- 최신 정책/기준 미반영 가능
- 실험적 — 참고용으로만 사용
