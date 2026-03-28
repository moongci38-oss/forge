---
skill: audit-human-ai
version: 1
---

# Assessment: audit-human-ai

## 테스트 입력

- input_1: "Run a Human-AI boundary design audit on the current Forge system"
- input_2: "Evaluate autonomy levels and escalation design for an AI writing assistant"
- input_3: "Assess gate patterns and trust calibration for an autonomous trading bot"

## 평가 기준 (Yes/No)

1. 5-Level Autonomy 기준의 현재 레벨이 명시되어 있는가?
2. 에스컬레이션 트리거 유형이 분석되어 있는가?
3. 게이트 패턴(STOP/AUTO-PASS 등)이 평가되어 있는가?
4. Override Rate 또는 신뢰 칼리브레이션 지표가 포함되어 있는가?
5. 자율성-감독 경계 최적화 권고가 제시되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
