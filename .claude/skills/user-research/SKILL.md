---
name: user-research
description: Plan, conduct, and synthesize user research. Trigger with "user research plan", "interview guide", "usability test", "survey design", "research questions", or when the user needs help with any aspect of understanding their users through research.
---

# User Research

Help plan, execute, and synthesize user research studies.

## Research Methods

| Method | Best For | Sample Size | Time |
|--------|----------|-------------|------|
| User interviews | Deep understanding of needs and motivations | 5-8 | 2-4 weeks |
| Usability testing | Evaluating a specific design or flow | 5-8 | 1-2 weeks |
| Surveys | Quantifying attitudes and preferences | 100+ | 1-2 weeks |
| Card sorting | Information architecture decisions | 15-30 | 1 week |
| Diary studies | Understanding behavior over time | 10-15 | 2-8 weeks |
| A/B testing | Comparing specific design choices | Statistical significance | 1-4 weeks |

## Interview Guide Structure

1. **Warm-up** (5 min): Build rapport, explain the session
2. **Context** (10 min): Understand their current workflow
3. **Deep dive** (20 min): Explore the specific topic
4. **Reaction** (10 min): Show concepts or prototypes
5. **Wrap-up** (5 min): Anything we missed? Thank them.

## Analysis Framework

- **Affinity mapping**: Group observations into themes
- **Impact/effort matrix**: Prioritize findings
- **Journey mapping**: Visualize the user experience over time
- **Jobs to be done**: Understand what users are hiring your product to do

## Deliverables

- Research plan (objectives, methods, timeline, participants)
- Interview guide (questions, probes, activities)
- Synthesis report (themes, insights, recommendations)
- Highlight reel (key quotes and observations)


---

## 독립 Evaluator (하네스)

리서치 결과 보고서 완성 후 독립 Evaluator Subagent가 분석 품질을 검증한다.

```python
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
당신은 독립 분석 품질 검증자입니다. user-research (사용자 리서치) 결과물을 검토하세요.

검증 항목:
- 리서치 방법론이 목적에 적합한가?
- 인터뷰/설문 가이드가 유도 질문 없이 중립적인가?
- 인사이트가 데이터 기반인가, 인상 기반인가?
- 액션 가능한 권고사항이 포함됐는가?
- 표본 편향 가능성이 언급됐는가?

판정: PASS / FAIL
피드백: [파일명+섹션] — [이유] → [방법]
"""
)
```

피드백 루프:
- PASS → 파이프라인 계속 (저장/발행)
- FAIL → 지적 항목 보완 후 Evaluator 재실행 (1회 한도)
- 2회 연속 FAIL → [STOP] Human 에스컬레이션
