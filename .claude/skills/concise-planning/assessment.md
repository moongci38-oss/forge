---
skill: concise-planning
version: 1
---

# Assessment: concise-planning

## 테스트 입력

- input_1: "Add dark mode toggle to the settings page"
- input_2: "Refactor the authentication middleware to support JWT refresh tokens"
- input_3: "Create a REST API endpoint for user profile CRUD operations"

## 평가 기준 (Yes/No)

1. Approach 존재: 출력에 "Approach" 또는 고수준 접근법을 설명하는 1-3문장 섹션이 있는가?
2. Scope In/Out 분리: "Scope" 섹션에 "In"과 "Out" (또는 동등한 포함/제외) 항목이 모두 존재하는가?
3. Action Items 수량: Action Items(체크리스트 항목)가 6개 이상 10개 이하인가?
4. 동사 시작: Action Items의 80% 이상이 동사로 시작하는가? (Add, Create, Refactor, Verify, Update, Test, Write, Configure 등)
5. 파일 경로 포함: Action Items 중 최소 1개가 구체적 파일 경로(예: src/components/Settings.tsx)를 포함하는가?
6. Validation 존재: 테스트/검증 단계가 최소 1개 존재하는가? (Validation 섹션 또는 Action Items 내 검증 스텝)

## 채점

- 1건 pass = 6개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
