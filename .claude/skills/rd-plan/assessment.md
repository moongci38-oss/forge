---
skill: rd-plan
version: 2
---

# Assessment: rd-plan

## 테스트 입력

- input_1: "KOCCA 게임 콘텐츠 R&D 과제 사업계획서를 작성해줘. forge-outputs/09-grants/KOCCA/game-content/ 경로 사용."
- input_2: "정부과제 AI 플랫폼 제안서 작성. _source/에 HWP 양식 있음. 특허 2건 보유."
- input_3: "TIPS 프로그램 사업계획서 섹션 3만 재작성해줘. --section 3 플래그 사용."

## 평가 기준 (Yes/No)

1. Output MUST include Phase 0에서 _grant-info.md와 _source/ 스캔 결과를 기반으로 맞춤 목차를 자동 생성하고 사용자에게 확인을 요청하는가?
2. Output MUST include Phase 1 섹션별 작성 루프에서 section-qa.md 루브릭 3축 60점 기준으로 QA 점수를 산출하는가?
3. Output MUST include Phase 2.5 통합본 구조 검수 8개 항목(테이블 행열, span 태그, 색상 규칙, 이미지 경로 등)을 자동 점검하고 PASS/WARN/FAIL 결과를 출력하는가?
4. Output MUST include Phase 3에서 5축 100점 QA 루브릭을 독립 서브에이전트로 실행하는가?
5. Output MUST include Phase 4에서 양식 감지 후 exports/ 경로에 기입 완료본을 생성하고 CEO Sign-off [STOP] 게이트를 실행하는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
