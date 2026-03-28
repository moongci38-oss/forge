---
skill: rd-plan
version: 1
---

# Assessment: rd-plan

## 테스트 입력

- input_1: "Generate an R&D grant proposal outline for an AI-powered content creation platform"
- input_2: "Create a government grant application plan for a game development project using AI tools"
- input_3: "Draft a KOCCA grant proposal structure for an interactive media project"

## 평가 기준 (Yes/No)

1. 목차 또는 섹션 구조가 자동 생성되어 있는가?
2. 기관별 양식(KOCCA, TIPS 등) 또는 평가 기준이 반영되어 있는가?
3. 기술 설명 또는 사업 내용 섹션이 포함되어 있는가?
4. 작성 가이드(색상 컨벤션, 분량 기준)가 언급되어 있는가?
5. QA 루프 또는 품질 검증 단계가 계획되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
