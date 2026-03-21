---
skill: "{skill-name}"
version: 1
---

# Assessment: {skill-name}

## 테스트 입력

각 입력에 대해 스킬을 실행하고 출력을 채점한다.

- input_1: "{고정 입력 1}"
- input_2: "{고정 입력 2}"
- input_3: "{고정 입력 3}"

## 평가 기준 (Yes/No)

채점 모델(Haiku)이 출력을 읽고 각 기준에 Yes/No로 답한다.
기준 수: 4-6개 권장. 너무 많으면 테스트 해킹, 너무 적으면 품질 미포착.

1. {기준명}: {구체적 Yes/No 질문 — 모호한 "좋은가?" 대신 검증 가능한 조건}
2. ...

## 채점

- 1건 pass = 모든 기준 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 이상 달성
