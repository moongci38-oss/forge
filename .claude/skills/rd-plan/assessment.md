---
skill: rd-plan
version: 2
---

# Assessment: rd-plan

## 테스트 입력

- input_1: "Generate an R&D grant proposal for an AI content platform — run full pipeline including Phase 2.5 structure check"
- input_2: "Write section II (solution/technology) of a KOCCA R&D proposal with visual markers and section QA"
- input_3: "Run QA only on an existing grant document — check tables, spacing, span tags, and image paths"

## 평가 기준 (Yes/No)

1. Output MUST detect grant info from _grant-info.md and generate a customized TOC using section-rules.json conditions.
2. Output MUST produce section drafts with visual markers, color convention (파란=작성요령, 빨간=본문), and source tags.
3. Output MUST execute Phase 2.5 structure check (테이블 행열, 문단 간격, span 태그, 이미지 경로, 플레이스홀더) before Phase 3 QA.
4. Output MUST run Phase 3 QA with 5-axis rubric (일관성/커버리지/시각화/분량/준비도) scoring out of 100.
5. Output MUST save outputs to the correct forge-outputs/09-grants/ path structure (drafts/, assets/, qa/).

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
