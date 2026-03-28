---
skill: spec-compliance-checker
version: 1
---

# Assessment: spec-compliance-checker

## 테스트 입력

- input_1: "Check spec compliance for the comment-system.spec.md against src/modules/comments/"
- input_2: "Verify traceability between auth-middleware.spec.md and the implementation files"
- input_3: "Run spec compliance check on file-upload.spec.md"

## 평가 기준 (Yes/No)

1. FR(기능 요구사항)별 구현 파일 매핑이 수행되어 있는가?
2. 테스트 존재 여부가 확인되어 있는가?
3. API 계약 일치 또는 데이터 모델 일치가 검증되어 있는가?
4. PASS/WARN/FAIL 판정이 항목별로 제시되어 있는가?
5. JSON 또는 구조화된 출력 형식으로 결과가 정리되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
