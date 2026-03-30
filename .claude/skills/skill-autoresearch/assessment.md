---
skill: skill-autoresearch
version: 1
test-method: indirect-via-prompt
---

# Assessment: skill-autoresearch

## 테스트 입력

- input_1: "Run auto-evaluation and improvement loop on the kaizen skill"
- input_2: "Assess and improve the concise-planning skill using AutoResearch pattern"
- input_3: "Execute skill quality improvement cycle for the content-creator skill"

## 평가 기준 (Yes/No)

1. 대상 스킬의 현재 assessment 기준선이 측정되어 있는가?
2. 실패 분석(어떤 기준이 실패했는지)이 포함되어 있는가?
3. SKILL.md 개선 제안이 구체적으로 제시되어 있는가?
4. 개선 전후 비교(pass_rate 변화)가 계획되어 있는가?
5. autoresearch-log.tsv 기록 또는 이력 관리가 언급되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
