---
skill: game-asset-generate
version: 2
---

# Assessment: game-asset-generate

## 테스트 입력

- input_1: "Generate a set of fantasy RPG UI button sprites for GodBlade game with consistent style"
- input_2: "Create VFX particle effect sprites for a gacha card reveal animation"
- input_3: "Produce background art for a medieval castle interior game scene"

## 평가 기준 (Yes/No)

1. Output MUST execute Library-First search (/library-search) before generating any new asset.
2. Output MUST assemble a 12-element Soul prompt using /soul-prompt-craft with style-guide context.
3. Output MUST route to the correct MCP tool based on asset type (NanoBanana/Replicate/Stitch).
4. Output MUST run /asset-critic 6-axis quality check on generated assets with scores.
5. Output MUST save assets to the correct project path and propose Library registration for approved assets.

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
