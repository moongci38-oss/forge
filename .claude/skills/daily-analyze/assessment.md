---
skill: daily-analyze
version: 1
---

# Assessment: daily-analyze

## 테스트 입력

- input_1: "Analyze today's AI system scan results from raw-data.json"
- input_2: "Re-analyze the daily system review data focusing on breaking changes"
- input_3: "Generate improvement plan from daily scan findings"

## 평가 기준 (Yes/No)

1. AI 동향 분석 결과가 구조화되어 있는가?
2. 우리 시스템과의 갭 분석이 포함되어 있는가?
3. Critical/Breaking/Deprecated 변경 분류가 있는가?
4. 적용 계획 또는 개선 제안이 포함되어 있는가?
5. 출처(URL, 날짜)가 명시되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
