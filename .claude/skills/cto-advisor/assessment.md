---
skill: cto-advisor
version: 1
---

# Assessment: cto-advisor

## 테스트 입력

- input_1: "Analyze tech debt in a Next.js monorepo with 50+ components and no test coverage"
- input_2: "Calculate team scaling needs for a startup going from 2 to 8 engineers"
- input_3: "Evaluate whether to adopt GraphQL vs REST for a new microservices architecture"

## 평가 기준 (Yes/No)

1. 기술적 분석 또는 권고사항이 구체적으로 제시되어 있는가?
2. 의사결정 프레임워크(ADR, 비교 매트릭스 등)가 사용되어 있는가?
3. 리스크 또는 트레이드오프가 명시적으로 언급되어 있는가?
4. 실행 가능한 액션 아이템이 포함되어 있는가?
5. 우선순위 또는 단계별 로드맵이 제시되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
