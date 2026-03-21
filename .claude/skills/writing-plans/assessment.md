---
skill: writing-plans
version: 1
---

# Assessment: writing-plans

## 테스트 입력

- input_1: "Implement a comment system with nested replies for a blog. Spec: users can comment, reply to comments (max 3 depth), edit own comments, delete own comments."
- input_2: "Add email notification system. Spec: send welcome email on signup, password reset email, weekly digest of new posts."
- input_3: "Build a file upload service. Spec: accept images (jpg/png/webp, max 5MB), resize to 3 sizes (thumbnail/medium/large), store in S3, return CDN URLs."

## 평가 기준 (Yes/No)

1. 헤더 존재: 출력에 Goal, Architecture, Tech Stack 을 포함하는 헤더 섹션이 있는가?
2. Task 구조: "### Task N:" 형식의 태스크가 2개 이상 존재하는가?
3. 파일 경로 명시: 각 Task에 "Create:" 또는 "Modify:" 또는 "Test:" 뒤에 구체적 파일 경로가 있는가?
4. TDD 패턴: 최소 1개 Task에 "failing test" → "implement" → "test passes" 순서가 있는가?
5. 단계 세분화: 각 Task의 Step이 2-5분 단위의 작은 액션인가? (한 Step에 여러 파일 수정 = No)
6. 커밋 포인트: 최소 1곳에 커밋 단계("Commit" 또는 "git commit")가 명시되어 있는가?

## 채점

- 1건 pass = 6개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
