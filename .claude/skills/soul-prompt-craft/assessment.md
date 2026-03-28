---
skill: soul-prompt-craft
version: 2
---

# Assessment: soul-prompt-craft

## 테스트 입력

- input_1: "GodBlade 전사 캐릭터 히어로 이미지 T1 프롬프트를 Gemini 포맷으로 조립해줘."
- input_2: "판타지 배경 이미지 T2 프롬프트를 FLUX 포맷으로 만들어줘. style-guide 기반."
- input_3: "Legend 등급 검 아이콘 T3 프롬프트. 색상 #FFD700 기준으로 Replicate LoRA용."

## 평가 기준 (Yes/No)

1. Output MUST include style-guide.md와 art-direction-brief.md를 로드하여 Tier에 맞는 활성 슬롯을 결정하는가?
2. Output MUST include 12요소 슬롯을 Tier별 깊이 차등(T1:12요소, T2:8요소, T3:5요소)으로 채우는가?
3. Output MUST include 색상을 반드시 #RRGGBB Hex Code로 명시하고 자연어 색상명 단독 사용을 금지하는가?
4. Output MUST include 대상 모델(FLUX/Gemini/Replicate)에 맞는 포맷 변환과 구조화 뷰를 출력하는가?
5. Output MUST include negative prompt 섹션과 기술 파라미터(해상도, 종횡비)를 포함하는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
