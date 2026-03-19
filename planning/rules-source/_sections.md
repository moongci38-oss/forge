# Forge Scope — Category Registry

> Forge 파이프라인 세션 전용 규칙.
> 의존성 순서: 구조 → 거버넌스 → Stage별 → 전환

| 순서 | 카테고리 | ID | Impact | 의존성 |
|:----:|---------|-----|:------:|--------|
| 1 | 파이프라인 구조 | forge-structure | HIGH | — |
| 2 | 거버넌스 | forge-governance | HIGH | forge-structure |
| 3 | 산출물 경로 | forge-outputs | MEDIUM | forge-structure |
| 4 | S1 리서치 | forge-s1-research | MEDIUM | forge-structure |
| 5 | S2 컨셉 | forge-s2-concept | HIGH | forge-structure |
| 6 | S3 기획서 | forge-s3-design | HIGH | forge-structure |
| 7 | S4 기획 패키지 | forge-s4-planning | HIGH | forge-s3-design |
| 8 | Forge Dev 전환 | forge-handoff | HIGH | forge-s4-planning |
