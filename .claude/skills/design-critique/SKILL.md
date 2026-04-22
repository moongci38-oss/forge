---
name: design-critique
description: Evaluate designs for usability, visual hierarchy, consistency, and adherence to design principles. Trigger with "what do you think of this design", "give me feedback on", "critique this", "review this mockup", or when the user shares a design and asks for opinions.
---

# Design Critique

Provide structured, actionable design feedback.

## Critique Framework

### 1. First Impression (2 seconds)
- What draws the eye first? Is that correct?
- What's the emotional reaction?
- Is the purpose immediately clear?

### 2. Usability
- Can the user accomplish their goal?
- Is the navigation intuitive?
- Are interactive elements obvious?
- Are there unnecessary steps?

### 3. Visual Hierarchy
- Is there a clear reading order?
- Are the right elements emphasized?
- Is whitespace used effectively?
- Is typography creating the right hierarchy?

### 4. Consistency
- Does it follow the design system?
- Are spacing, colors, and typography consistent?
- Do similar elements behave similarly?

### 5. Accessibility
- Color contrast ratios
- Touch target sizes
- Text readability
- Alternative text for images

## How to Give Feedback

- **Be specific**: "The CTA competes with the navigation" not "the layout is confusing"
- **Explain why**: Connect feedback to design principles or user needs
- **Suggest alternatives**: Don't just identify problems, propose solutions
- **Acknowledge what works**: Good feedback includes positive observations
- **Match the stage**: Early exploration gets different feedback than final polish

---

## 독립 Evaluator (하네스)

design-critique 스킬 결과물 완성 후 독립 Evaluator Subagent가 품질을 2차 검증한다.

> **원칙**: 생성자 ≠ 평가자. 자기평가 편향 방지.

```python
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
당신은 design-critique 스킬 결과물의 독립 품질 검증자입니다.

아래 기준으로 결과물을 평가하세요:
1. 사용성(Usability), 시각 위계(Visual Hierarchy), 일관성(Consistency), 디자인 원칙(First Impression 포함) 4개 축이 모두 커버됐는지 확인한다. 하나라도 섹션이 없으면 FAIL.
2. 모든 피드백 항목이 위치(어느 요소/섹션), 이유(어떤 원칙에 위반), 방법(구체적 개선 방향) 3요소를 포함하는지 확인한다. 3요소 중 하나라도 빠진 항목이 있으면 FAIL.
3. "전반적으로 좋다", "깔끔하다", "잘 됐다" 등 구체성 없는 모호한 평가가 포함됐는지 확인한다. 모호한 평가가 1개 이상 있으면 FAIL.

판정: PASS(기준 충족) / FAIL(재작업 필요)
피드백 형식: [파일명+섹션] — [이유] → [방법]
"""
)
```

피드백 루프:
- PASS → 파이프라인 계속
- FAIL → 재작업 후 1회 재실행. 2회 연속 FAIL 시 [STOP] Human 에스컬레이션
