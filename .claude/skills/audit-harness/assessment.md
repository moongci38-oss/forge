---
skill: audit-harness
version: 1
---

# Assessment: audit-harness

## 테스트 입력

- input_1: "Run an AI harness engineering audit on the current Forge system"
- input_2: "Evaluate testing and guardrail coverage for an AI code review agent"
- input_3: "Assess observability and control mechanisms for a customer service chatbot"

## 평가 기준 (Yes/No)

1. CLEAR 프레임워크 기준의 평가가 포함되어 있는가?
2. 3-Layer 테스트 아키텍처(Unit/Integration/E2E) 커버리지가 평가되어 있는가?
3. OWASP Agentic Top 10 관련 보안 항목이 언급되어 있는가?
4. 가드레일 패턴 또는 안전장치 현황이 분석되어 있는가?
5. 점수 또는 등급이 정량적으로 제시되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
