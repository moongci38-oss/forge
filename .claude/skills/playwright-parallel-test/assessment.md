---
skill: playwright-parallel-test
version: 1
---

# Assessment: playwright-parallel-test

## 테스트 입력

- input_1: "Run parallel UI tests on http://localhost:3000 covering form validation, navigation, and responsive layout"
- input_2: "Execute 3-agent parallel test suite for the admin dashboard"
- input_3: "Test the checkout flow with parallel form, routing, and responsive agents"

## 평가 기준 (Yes/No)

1. 3개 에이전트(form validation, navigation, responsive layout) 병렬 실행이 계획되어 있는가?
2. 대상 URL 또는 테스트 대상이 명시되어 있는가?
3. 각 에이전트의 테스트 범위가 구분되어 있는가?
4. 테스트 결과 통합(PASS/FAIL 리포트)이 계획되어 있는가?
5. 스크린샷 또는 증거 수집이 포함되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
