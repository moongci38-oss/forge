---
skill: weekly-research
version: 1
---

# Assessment: weekly-research

## 테스트 입력

- input_1: "Run the weekly research pipeline for AI and business trends"
- input_2: "Execute weekly 3-subagent research collection and analysis"
- input_3: "Perform weekly technology and business intelligence scan"

## 평가 기준 (Yes/No)

1. 3개 서브에이전트(tech/biz/S1) 병렬 수집 계획이 있는가?
2. 기술 뉴스 수집 범위가 명시되어 있는가?
3. 비즈니스 뉴스 수집 범위가 명시되어 있는가?
4. 통합/검증(Wave 2) 단계가 계획되어 있는가?
5. 저장 경로(forge-outputs/01-research/)가 명시되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
