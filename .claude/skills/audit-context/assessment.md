---
skill: audit-context
version: 1
---

# Assessment: audit-context

## 테스트 입력

- input_1: "Run a context engineering audit on the current Forge system"
- input_2: "Evaluate RAG maturity and context window management for a document QA system"
- input_3: "Assess context architecture of a system using memory + vector DB + conversation history"

## 평가 기준 (Yes/No)

1. 7-Layer Context Architecture 기준의 레이어별 평가가 포함되어 있는가?
2. RAG 성숙도 평가가 포함되어 있는가?
3. 컨텍스트 실패 패턴(Poisoning/Distraction/Confusion/Clash/Rot) 중 하나 이상 언급되어 있는가?
4. 점수 또는 커버리지 비율이 정량적으로 제시되어 있는가?
5. 개선 권고사항이 구체적으로 제시되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
