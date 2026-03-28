---
skill: inspection-checklist
version: 1
---

# Assessment: inspection-checklist

## 테스트 입력

- input_1: "Generate a final inspection checklist for the current PR before merge"
- input_2: "Run pre-release inspection covering all Forge Dev checks"
- input_3: "Create unified quality checklist for Check 3, 3.5, 3.6, 3.7, 3.8"

## 평가 기준 (Yes/No)

1. 빌드/테스트 검수 항목이 포함되어 있는가?
2. Spec 추적성(traceability) 검수가 포함되어 있는가?
3. UI/UX 품질 검수가 포함되어 있는가?
4. 코드 리뷰 또는 보안 검수가 포함되어 있는가?
5. PASS/WARN/FAIL 판정 또는 체크리스트 형식으로 구조화되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
