---
name: design-handoff
description: Create comprehensive developer handoff documentation from designs. Trigger with "handoff to engineering", "developer specs", "implementation notes", "design specs for developers", or when a design needs to be translated into detailed implementation guidance.
---

# Design Handoff

Create clear, complete handoff documentation so developers can implement designs accurately.

## What to Include

### Visual Specifications
- Exact measurements (padding, margins, widths)
- Design token references (colors, typography, spacing)
- Responsive breakpoints and behavior
- Component variants and states

### Interaction Specifications
- Click/tap behavior
- Hover states
- Transitions and animations (duration, easing)
- Gesture support (swipe, pinch, long-press)

### Content Specifications
- Character limits
- Truncation behavior
- Empty states
- Loading states
- Error states

### Edge Cases
- Minimum/maximum content
- International text (longer strings)
- Slow connections
- Missing data

### Accessibility
- Focus order
- ARIA labels and roles
- Keyboard interactions
- Screen reader announcements

## Principles

1. **Don't assume** — If it's not specified, the developer will guess. Specify everything.
2. **Use tokens, not values** — Reference `spacing-md` not `16px`.
3. **Show all states** — Default, hover, active, disabled, loading, error, empty.
4. **Describe the why** — "This collapses on mobile because users primarily use one-handed" helps developers make good judgment calls.


---

## 독립 Evaluator (하네스)

개발자 핸드오프 문서 완성 후 독립 Evaluator Subagent가 결과물 품질을 검증한다.

```python
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
당신은 독립 생성물 품질 검증자입니다. design-handoff 결과물을 검토하세요.

검증 항목:
- 구현 스펙에 측정값·간격·색상 코드가 포함됐는가?
- 인터랙션 상태(hover/active/disabled/error)가 모두 명시됐는가?
- 컴포넌트 재사용 가이드가 있는가?
- 접근성(a11y) 요구사항이 포함됐는가?

판정: PASS(기준 충족) / FAIL(재작업 필요)
피드백: [항목] — [이유] → [방법]
"""
)
```

피드백 루프:
- PASS → 파이프라인 계속
- FAIL → 재작업 후 Evaluator 재실행 (1회 한도)
- 2회 연속 FAIL → [STOP] Human 에스컬레이션
