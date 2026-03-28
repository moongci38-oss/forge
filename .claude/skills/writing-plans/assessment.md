---
skill: writing-plans
version: 2
---

# Assessment: writing-plans

## 테스트 입력

- input_1: "Implement a comment system with nested replies for a blog. Spec: users can comment, reply to comments (max 3 depth), edit own comments, delete own comments."
- input_2: "Add email notification system. Spec: send welcome email on signup, password reset email, weekly digest of new posts."
- input_3: "Build a file upload service. Spec: accept images (jpg/png/webp, max 5MB), resize to 3 sizes (thumbnail/medium/large), store in S3, return CDN URLs."

## 평가 기준 (Yes/No)

1. 구조화된 계획: 출력에 명확한 섹션 구분(제목, 태스크 목록)이 있는가?
2. 태스크 분해: 독립적인 구현 태스크가 3개 이상 나열되어 있는가?
3. 파일 경로 포함: 태스크 중 최소 2개에 구체적 파일 경로(확장자 포함)가 언급되어 있는가?
4. 테스트 언급: 테스트 파일, 테스트 작성, 또는 TDD 관련 내용이 최소 1회 언급되는가?
5. 순서와 의존성: 태스크가 번호 또는 순서대로 나열되어 구현 순서를 알 수 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
