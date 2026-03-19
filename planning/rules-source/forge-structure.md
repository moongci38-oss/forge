---
title: "Forge 파이프라인 구조"
id: forge-structure
impact: HIGH
scope: [forge]
tags: [pipeline, structure, entry]
section: forge-pipeline
audience: all
impactDescription: "파이프라인 구조 미준수 시 Hard 의존성 위반 → S4 없이 Forge Dev 진입, 품질 미검증 기획서로 개발 시작"
enforcement: rigid
---

# Forge 파이프라인 구조

> **통합 파이프라인 Phase 매핑**: S1=Phase 1, S2=Phase 2, S3=Phase 3, S4=Phase 4, Handoff=Phase 5
> **통합 문서**: `forge/pipeline.md` (Phase 1~12)

## 파이프라인 구조

```
Phase 1 Research → Phase 2 Concept → Phase 3 Design Doc → Phase 4 Planning Package
     ↓                  ↓                  ↓                      ↓
 [AUTO-PASS]         [STOP]            [STOP]              [AUTO-PASS]
 DoD 자동 검증        비전 승인          기획서 승인          Wave 검증 → Phase 5 Handoff
```

## 파이프라인 유연성 (Soft/Hard 의존성)

### Soft 의존성 (스킵 가능)

```
S1(리서치) → S2(컨셉)     ← 기존 자료가 있으면 스킵 가능
S2(컨셉) → S3(기획서)     ← 컨셉이 확정되면 스킵 가능
```

### Hard 의존성 (반드시 순서 유지)

```
S3(기획서) → S4(기획 패키지)           ← S3 기획서 없이 S4 진입 불가
S4(기획 패키지) → Forge Dev(Spec 작성)     ← S4 개발 계획 없이 Forge Dev 진입 불가
S3 관리자 페이지 포함 → S4에도 반영     ← 관리자 기능 누락 방지
```

### 진입 경로 (4가지)

| 시나리오 | 시작 Stage | 필요 입력 | 스킵 |
|---------|:---------:|----------|------|
| 아이디어만 있음 | S1 | 아이디어 한 줄 | 없음 (전체 실행) |
| 자료/리서치 있음 | S2 | 기존 리서치 문서 or 참고 자료 | S1 스킵 |
| 컨셉 확정됨 | S3 | 컨셉 문서 or Lean Canvas | S1+S2 스킵 |
| 기획서 있음 | S4 | PRD/GDD 문서 | S1+S2+S3 스킵 |

## 프로젝트 유형

| 유형 | S3 산출물 | S4 산출물 | 다음 단계 |
|------|----------|----------|----------|
| 앱/웹 | PRD (.md + .pptx) | 기획 패키지 3종 | Forge Dev |
| 게임 | GDD (.md + .pptx) | 기획 패키지 3종 | Forge Dev |

## Do

- 파이프라인 시작 시 프로젝트 유형을 먼저 식별한다
- 진입 경로를 판단하여 기존 자료에 따른 Stage 스킵을 제안한다
- Hard 의존성(S3→S4→Forge Dev)은 반드시 순서를 유지한다

## Don't

- S3 기획서 없이 S4에 진입하지 않는다
- S4 개발 계획 없이 Forge Dev에 진입하지 않는다
- S3에 관리자 페이지가 포함되었는데 S4에서 누락하지 않는다

## AI 행동 규칙

1. 파이프라인 시작 시 프로젝트 유형을 먼저 식별한다
2. 진입 경로를 판단하여 기존 자료에 따른 Stage 스킵을 제안한다
3. [STOP] 게이트에서 Human 승인을 받고, [AUTO-PASS] 게이트는 자동 검증 후 알림한다

## Iron Laws

- **PIPELINE-IRON-1**: S3 기획서 없이 S4에 진입하지 않는다 (Hard 의존성)
- **PIPELINE-IRON-2**: S4 개발 계획 없이 Forge Dev에 진입하지 않는다 (Hard 의존성)

## Rationalization Table

| 합리화 (Thought) | 현실 (Reality) |
|-------------------|---------------|
| "기획서가 거의 완성이라 S4부터 시작해도 될 것 같다" | "거의 완성"은 미완성이다. S3 Gate를 통과하지 않은 기획서로 S4를 시작하면 S4 산출물이 불완전한 입력에 기반하게 된다 |
| "시간이 급하니 S4 없이 바로 개발을 시작하자" | S4 없이 시작한 개발은 기획-개발 단절로 재작업 비용이 2-3배 증가한다. 급할수록 기본을 지킨다 |

## Red Flags

- "이미 어느 정도 기획이 되어 있으니까..." → STOP. gate-log.md에서 해당 Stage PASS를 확인한다
- "개발하면서 기획을 보완하면..." → STOP. Hard 의존성 위반이다. S4 Gate를 먼저 통과한다
