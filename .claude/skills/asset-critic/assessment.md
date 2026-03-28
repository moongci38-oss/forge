---
skill: asset-critic
version: 1
---

# Assessment: asset-critic

## 테스트 입력

- input_1: "Evaluate this game sprite asset: a 64x64 pixel warrior character with sword, using cel-shading style on transparent background"
- input_2: "Evaluate this web UI mockup: a dashboard card component with gradient background, showing user stats with chart"
- input_3: "Evaluate this VFX asset: a fire explosion particle effect sequence, 8 frames, for 2D side-scroller game"

## 평가 기준 (Yes/No)

1. 6축 평가 항목(계층/일관성/안티패턴/브리프/서사/물성)이 모두 언급되어 있는가?
2. 각 항목에 1-5점 척도의 점수가 명시되어 있는가?
3. 평균 점수 또는 종합 점수가 계산되어 있는가?
4. PASS/BORDERLINE/FAIL 중 하나의 최종 판정이 있는가?
5. 개선 제안 또는 피드백이 구체적으로 제시되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
