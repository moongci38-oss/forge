---
skill: screenshot-analyze
version: 1
---

# Assessment: screenshot-analyze

## 테스트 입력

- input_1: "Analyze this game screenshot for UI layout and color palette extraction"
- input_2: "Compare this competitor app screenshot with our current design"
- input_3: "Verify implementation matches the design spec by analyzing this screenshot"

## 평가 기준 (Yes/No)

1. 분석 유형(UI 구조, 컬러 팔레트, 경쟁작 비교, 구현 검증)이 식별되어 있는가?
2. UI 요소 또는 레이아웃 구조가 식별/설명되어 있는가?
3. 색상 코드(Hex) 또는 디자인 토큰이 추출되어 있는가?
4. 구현 가이드 또는 개선 제안이 포함되어 있는가?
5. 구조화된 출력(테이블, 목록)으로 정리되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
