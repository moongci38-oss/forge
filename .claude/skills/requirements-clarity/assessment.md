---
skill: requirements-clarity
version: 1
---

# Assessment: requirements-clarity

## 테스트 입력

- input_1: "Add user analytics tracking to the dashboard"
- input_2: "Make the search faster"
- input_3: "Add social login support"

## 평가 기준 (Yes/No)

1. Clarifying question 존재: 출력에 사용자에게 답변을 요청하는 질문이 최소 1개 포함되어 있는가? (물음표로 끝나는 문장 또는 명시적인 질문 형식)
2. Why/YAGNI 확인: "왜 필요한가", "어떤 문제를 해결하는가", "비즈니스 목적" 또는 이에 상응하는 YAGNI 관점의 질문이나 언급이 있는가?
3. Simpler/KISS 확인: 더 단순한 접근법, 기존 도구 활용, MVP 범위 축소 또는 이에 상응하는 KISS 관점의 제안이나 질문이 있는가?
4. 구체적 모호성 식별: 요청에서 모호한 부분(예: "어떤 이벤트를 추적할지", "어느 정도 빠른지", "어떤 소셜 플랫폼인지")을 구체적으로 명시하는가?
5. 단순 대안 또는 범위 축소 제안: 원래 요청보다 작은 범위의 대안 구현이나 단계적 접근법(예: "우선 X만 먼저")을 제안하는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상 달성
