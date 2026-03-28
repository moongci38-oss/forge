---
skill: game-asset-generate
version: 1
---

# Assessment: game-asset-generate

## 테스트 입력

- input_1: "Generate a 64x64 warrior sprite with cel-shading style for a 2D RPG"
- input_2: "Create a fire VFX particle effect for a side-scrolling action game"
- input_3: "Generate UI button assets (normal/hover/pressed states) for a fantasy game menu"

## 평가 기준 (Yes/No)

1. Library-First 탐색이 먼저 수행되거나 언급되어 있는가?
2. 12요소 Soul 프롬프트 또는 프롬프트 구성이 설명되어 있는가?
3. MCP 도구 라우팅(FLUX/Gemini/Replicate)이 결정되어 있는가?
4. 에셋 생성 결과물 또는 생성 계획이 구체적으로 제시되어 있는가?
5. 크리틱(asset-critic) 평가 또는 품질 검증 단계가 포함되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
