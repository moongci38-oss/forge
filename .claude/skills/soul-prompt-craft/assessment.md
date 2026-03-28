---
skill: soul-prompt-craft
version: 2
---

# Assessment: soul-prompt-craft

## 테스트 입력

- input_1: "Craft a soul-injected prompt for generating a dark fantasy game character sprite"
- input_2: "Build a 12-element image generation prompt for a Korean traditional pattern background"
- input_3: "Create a T1-tier soul prompt for the hero banner image of a mobile game landing page"

## 평가 기준 (Yes/No)

1. Output MUST include all 12 soul prompt elements (subject, style, mood, palette, composition, lighting, detail, medium, reference, negative, technical, context).
2. Output MUST extract context from style-guide.md and art-direction-brief.md if they exist in the project.
3. Output MUST apply Tier differentiation (T1=full depth, T2=standard, T3=minimal) based on asset importance.
4. Output MUST format the prompt for the target model (FLUX/Gemini/Replicate) with model-specific optimizations.
5. Output MUST include a negative prompt section and technical parameters (resolution, aspect ratio, seed strategy).

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
