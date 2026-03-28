---
skill: audit-agentic
version: 1
---

# Assessment: audit-agentic

## 테스트 입력

- input_1: "Run an agentic AI capability audit on the current Forge system"
- input_2: "Evaluate the agentic maturity level of a chatbot that uses tool calling for database queries and file operations"
- input_3: "Assess agentic capabilities of a multi-agent system with 3 specialized agents coordinated by a lead agent"

## 평가 기준 (Yes/No)

1. Sema4.ai 성숙도 레벨(L0-L5) 중 하나가 명시되어 있는가?
2. CLEAR 프레임워크 기준의 평가 항목이 포함되어 있는가?
3. 자율성, 도구 사용, 멀티에이전트 조정 중 최소 2개 축이 평가되어 있는가?
4. 점수 또는 등급이 정량적으로 제시되어 있는가?
5. 개선 로드맵 또는 권고사항이 포함되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
