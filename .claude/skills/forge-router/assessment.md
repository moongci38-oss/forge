---
skill: forge-router
version: 1
---

# Assessment: forge-router

## 테스트 입력

- input_1: "Fix the login button not working on the dashboard page"
- input_2: "Add a new REST API endpoint for user preferences"
- input_3: "Refactor the authentication middleware to support JWT refresh tokens"

## 평가 기준 (Yes/No)

1. 코드 변경 요청이 올바르게 감지되어 있는가?
2. Hotfix vs Standard 분류가 수행되어 있는가?
3. Forge Dev 파이프라인 진입점이 결정되어 있는가?
4. 프로젝트 컨텍스트(.specify/ 존재 여부 등)가 확인되어 있는가?
5. 다음 단계(Spec 작성, 브랜치 생성 등)가 안내되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
