---
skill: game-logic-visualize
version: 2
---

# Assessment: game-logic-visualize

## 테스트 입력

- input_1: "Visualize a player state machine with states: Idle, Running, Jumping, Attacking, Dead and transitions between them"
- input_2: "Create a gacha probability table visualization with 5-star (1%), 4-star (10%), 3-star (89%) rates and pity system at 90 pulls"
- input_3: "Draw a skill tree with 3 branches: Warrior (5 skills), Mage (5 skills), Rogue (5 skills) showing prerequisites"

## 평가 기준 (Yes/No)

1. 시각화 출력 존재: Mermaid 코드 블록, HTML 코드, 또는 시각화 파일 생성/저장 경로가 출력에 포함되어 있는가?
2. 핵심 요소 포함: 입력에서 명시된 주요 요소(상태명, 등급명, 스킬 분기명)가 출력에 최소 3개 이상 언급되어 있는가?
3. 수치/확률 반영: 입력에 수치(확률, 개수, 조건)가 있을 경우 해당 수치가 출력에 반영되어 있는가?
4. 관계/구조 표현: 요소 간의 관계(전이, 선행조건, 확률 분기)가 표현되어 있는가?
5. 실행 가능한 산출물: Mermaid 다이어그램, HTML 파일, 또는 python 스크립트 등 실행/렌더링 가능한 코드가 포함되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
