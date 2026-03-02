# SIGIL Scope — Category Registry

> SIGIL 파이프라인 세션 전용 규칙.
> 의존성 순서: 구조 → 거버넌스 → Stage별 → 전환

| 순서 | 카테고리 | ID | Impact | 의존성 |
|:----:|---------|-----|:------:|--------|
| 1 | 파이프라인 구조 | sigil-structure | HIGH | — |
| 2 | 거버넌스 | sigil-governance | HIGH | sigil-structure |
| 3 | 산출물 경로 | sigil-outputs | MEDIUM | sigil-structure |
| 4 | S1 리서치 | sigil-s1-research | MEDIUM | sigil-structure |
| 5 | S2 컨셉 | sigil-s2-concept | HIGH | sigil-structure |
| 6 | S3 기획서 | sigil-s3-design | HIGH | sigil-structure |
| 7 | S4 기획 패키지 | sigil-s4-planning | HIGH | sigil-s3-design |
| 8 | Trine 전환 | trine-handoff | HIGH | sigil-s4-planning |
| 9 | Council 모드 | sigil-council-mode | MEDIUM | sigil-structure |
