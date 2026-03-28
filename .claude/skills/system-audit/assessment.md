---
skill: system-audit
version: 1
---

# Assessment: system-audit

## 테스트 입력

- input_1: "Run a full 5-axis ACHCE system audit on the Forge pipeline"
- input_2: "Execute unified audit covering Agentic, Context, Harness, Cost, and Human-AI axes"
- input_3: "Perform comprehensive AI system quality assessment"

## 평가 기준 (Yes/No)

1. 5개 축(Agentic/Context/Harness/Cost/Human-AI) 모두가 평가 대상으로 포함되어 있는가?
2. 병렬 서브에이전트 스폰 계획이 있는가?
3. 축간 트레이드오프 분석이 포함되어 있는가?
4. 통합 개선 로드맵이 제시되어 있는가?
5. 종합 점수 또는 등급이 산출되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
