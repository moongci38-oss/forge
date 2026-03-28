---
skill: game-asset-generate
version: 2
---

# Assessment: game-asset-generate

## 테스트 입력

- input_1: "GodBlade 전사 캐릭터 스프라이트 시트 생성. T1 에셋. style-guide.md 기준."
- input_2: "불꽃 VFX 파티클 이펙트 시트를 T2로 생성해줘. 에픽 등급 아이템용."
- input_3: "UI 버튼 에셋 세트(normal/hover/pressed) 배리에이션 Common→Legend 4종 생성."

## 평가 기준 (Yes/No)

1. Output MUST include Library-First 탐색을 먼저 수행하고 완전매칭/부분매칭/없음 3분기에 따라 다음 단계를 결정하는가?
2. Output MUST include style-guide.md와 art-direction-brief.md에서 컨텍스트를 추출하여 Tier별 12요소 Soul 프롬프트를 조립하는가?
3. Output MUST include 에셋 유형에 따라 Gemini/FLUX/LoRA 중 모델을 선택하고 모델 포맷으로 변환하는가?
4. Output MUST include asset-critic 6항목 평균 3.5+ 기준으로 자동 평가하며 FAIL 시 최대 3회 재시도하는가?
5. Output MUST include 승인 후 resource-manifest.md와 prompt-log.md를 업데이트하는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
