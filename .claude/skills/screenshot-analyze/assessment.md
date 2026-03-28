---
skill: screenshot-analyze
version: 2
---

# Assessment: screenshot-analyze

## 테스트 입력

- input_1: "Analyze this game screenshot for UI layout — decompose each element with position, component type, and Unity Anchor settings"
- input_2: "Compare this competitor app screenshot with our current design and extract UI element breakdown table"
- input_3: "Verify implementation matches the design spec by analyzing this screenshot in Task Doc mode"

## 평가 기준 (Yes/No)

1. Output MUST include a UI element decomposition table with rows for each identified component (버튼, 배경, 아이콘 등) listing position, size ratio, and implementation details.
2. Output MUST extract a color palette with Hex codes and assign semantic token names for each color.
3. Output MUST auto-detect and declare the analysis mode (기본 모드 / Task Doc 모드 / 시안 분석 모드 / 구현 검증 모드) before executing.
4. Output MUST include a Prefab hierarchy tree or Canvas structure table with Anchor/Pivot estimates when analyzing UI layout.
5. Output MUST provide a structured implementation guide with Canvas settings, Prefab structure notes, and (추정) or (확정) tags on all inferred values.

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
