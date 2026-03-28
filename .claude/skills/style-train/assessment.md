---
skill: style-train
version: 1
---

# Assessment: style-train

## 테스트 입력

- input_1: "Extract visual style from 5 reference game sprites in /tmp/style-refs/"
- input_2: "Create a style-guide.md from existing UI design assets"
- input_3: "Analyze art style consistency across 10 character illustrations"

## 평가 기준 (Yes/No)

1. 기존 에셋에서 스타일 요소(팔레트, 아트 키워드, 패턴)가 추출되어 있는가?
2. style-guide.md 생성 또는 업데이트 계획이 포함되어 있는가?
3. 컬러 팔레트(Hex 코드)가 구체적으로 나열되어 있는가?
4. 아트 디렉션 키워드 또는 스타일 특성이 정의되어 있는가?
5. Mode A(추출) 또는 Mode B(LoRA 학습) 중 적절한 모드가 선택되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
