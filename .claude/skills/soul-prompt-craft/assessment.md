---
skill: soul-prompt-craft
version: 1
---

# Assessment: soul-prompt-craft

## 테스트 입력

- input_1: "Create a 12-element soul prompt for a warrior character sprite in cel-shading style"
- input_2: "Craft an image generation prompt for a fantasy forest background, Tier 2"
- input_3: "Generate a soul-injected prompt for UI button assets in Instagram design style"

## 평가 기준 (Yes/No)

1. 12요소 슬롯이 모두 채워져 있거나 구조가 설명되어 있는가?
2. style-guide.md 또는 art-direction-brief에서 컨텍스트 추출이 언급되어 있는가?
3. 모델별 포맷(FLUX/Gemini/Replicate) 변환이 포함되어 있는가?
4. Hex 색상 코드가 프롬프트에 포함되어 있는가?
5. Tier(T1/T2/T3)에 따른 프롬프트 깊이 차등이 적용되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
