---
skill: kaizen
version: 1
---

# Assessment: kaizen

## 테스트 입력

- input_1: "This function does too many things: it fetches user data from the API, formats the response, logs errors to console, and updates the local cache — all in one 80-line function called `handleUser`."
- input_2: "Our team has three different ways of writing API error handling: some files use try/catch with custom error classes, some use .catch() chains with console.error, and some silently swallow errors. New developers don't know which pattern to follow."
- input_3: "The checkout form accepts any string for the credit card field and only validates after the user submits. Invalid inputs cause a server error that exposes the raw exception message to the user."

## 평가 기준 (Yes/No)

1. 구체적 개선 식별: 출력이 "무엇이 문제인가"를 모호하게 서술하지 않고 코드/설계의 구체적 약점(예: 단일 책임 위반, 일관성 없는 패턴, 경계 검증 누락)을 명시적으로 지목하는가?
2. Before/After 제시: 개선 전 상태와 개선 후 상태를 코드 스니펫 또는 명확한 설명으로 대비하여 보여주는가?
3. 최소 변경 원칙 준수: 제안이 전면 재작성이나 과도한 추상화 없이 현재 문제를 해결하는 가장 작은 단위의 변경으로 범위가 제한되어 있는가?
4. Kaizen 4원칙 명시 적용: 출력이 네 기둥(Continuous Improvement, Poka-Yoke, Standardized Work, JIT) 중 해당 시나리오에 관련된 원칙을 명시적으로 인용하거나 적용하는가?
5. 즉시 실행 가능: 제안이 추가 설계 결정 없이 개발자가 바로 코드에 적용할 수 있을 만큼 구체적인가? (예: 파일명, 함수명, 타입 등 구체적 요소 포함)

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상 달성
