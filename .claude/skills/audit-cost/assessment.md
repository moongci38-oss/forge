---
skill: audit-cost
version: 1
---

# Assessment: audit-cost

## 테스트 입력

- input_1: "Run an AI cost efficiency audit on the current Forge system"
- input_2: "Evaluate token usage optimization for a system making 1000+ API calls per day"
- input_3: "Assess cost efficiency of a multi-model routing system using GPT-4 and Claude"

## 평가 기준 (Yes/No)

1. 모델 라우팅 전략이 평가되어 있는가?
2. 프롬프트 캐싱 또는 토큰 최적화 현황이 분석되어 있는가?
3. 비용 절감 기회가 구체적으로 식별되어 있는가?
4. 정량적 비용 수치 또는 추정치가 포함되어 있는가?
5. ROI 또는 비용 효율 점수가 제시되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
