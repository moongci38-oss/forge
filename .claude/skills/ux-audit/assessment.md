---
skill: ux-audit
version: 1
---

# Assessment: ux-audit

## 테스트 입력

- input_1: "Run UX quality audit on the frontend changes in src/components/Dashboard.tsx"
- input_2: "Validate 9-item UX checklist for the login page implementation"
- input_3: "Check color contrast, font sizes, and touch targets for the mobile navigation"

## 평가 기준 (Yes/No)

1. 9개 UX 기준(색상대비, 폰트크기, 터치타겟 등) 중 최소 5개가 평가되어 있는가?
2. PASS/WARN/FAIL 판정이 항목별로 제시되어 있는가?
3. WCAG 기준 또는 구체적 수치(대비율, px 등)가 참조되어 있는가?
4. 자동 수정 제안(auto-fix suggestions)이 포함되어 있는가?
5. JSON 또는 구조화된 리포트 형식으로 출력되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
