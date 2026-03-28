---
skill: pptx
version: 1
---

# Assessment: pptx

## 테스트 입력

각 입력에 대해 스킬을 실행하고 출력을 채점한다.

- input_1: "Create a 5-slide pitch deck about an AI code review SaaS product"
- input_2: "Create a 3-slide project status report with timeline and milestones"
- input_3: "Create a technical architecture presentation with 4 slides covering system overview, data flow, deployment, and monitoring"

## 평가 기준 (Yes/No)

1. 슬라이드 구조 명시: 출력이 슬라이드 수 또는 슬라이드별 구조(예: "Slide 1:", "슬라이드 1" 등)를 명시적으로 언급하는가?
2. 구현 완료 증거: .pptx 파일이 실제 생성/저장되었다는 증거(파일 경로, "saved", "generated", "ready" 등)가 출력에 있거나, python-pptx 코드가 포함되어 있는가?
3. 디자인 요소 참조: 출력이 색상(hex 코드 또는 색상명), 폰트, 레이아웃 중 하나 이상을 구체적으로 명시하는가?
4. 슬라이드별 콘텐츠 기술: 각 슬라이드에 들어갈 텍스트, 제목, 데이터, 또는 시각 요소가 슬라이드 단위로 구체적으로 서술되어 있는가?
5. .pptx 파일 출력 또는 생성 경로 기술: 출력 파일명(.pptx 확장자) 또는 저장 경로(예: `output.pptx`, `save()` 호출)가 포함되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상 달성
