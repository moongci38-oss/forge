---
skill: video-reference-guide
version: 1
---

# Assessment: video-reference-guide

## 테스트 입력

- input_1: "Analyze this game trailer video for combat animation sequences and timing"
- input_2: "Extract UI transition effects from a mobile game walkthrough video"
- input_3: "Generate implementation guide from a boss fight cutscene video"

## 평가 기준 (Yes/No)

1. 영상 분석 방법(Gemini 프레임 분석)이 설명되어 있는가?
2. 타임라인 시퀀스 테이블이 생성되어 있는가?
3. DOTween/Tween 파라미터 추정이 포함되어 있는가?
4. Unity 구현 가이드 또는 코드 스니펫이 제시되어 있는가?
5. 프레임별 분석 결과가 구조화되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
