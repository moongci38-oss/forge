---
skill: playwright-cli
version: 1
---

# Assessment: playwright-cli

## 테스트 입력

- input_1: "Navigate to http://localhost:3000 and take a screenshot of the homepage"
- input_2: "Fill out the login form at /login with test credentials and submit"
- input_3: "Extract all product prices from the /products page"

## 평가 기준 (Yes/No)

1. Playwright CLI 명령어 또는 실행 계획이 제시되어 있는가?
2. 대상 URL 또는 페이지가 명시되어 있는가?
3. 수행할 액션(navigate, click, fill, screenshot)이 구체적으로 설명되어 있는가?
4. 결과물(스크린샷, 추출 데이터) 저장 방법이 안내되어 있는가?
5. 에러 처리 또는 대기 전략이 언급되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
