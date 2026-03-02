---
title: "SIGIL 파이프라인 구조"
id: sigil-structure
impact: HIGH
scope: [sigil]
tags: [pipeline, structure, entry]
section: sigil-pipeline
audience: all
impactDescription: "파이프라인 구조 미준수 시 Hard 의존성 위반 → S4 없이 Trine 진입, 품질 미검증 기획서로 개발 시작"
enforcement: rigid
---

# SIGIL 파이프라인 구조

> **SIGIL (Strategy & Idea Generation Intelligent Loop)**
> 마법 인장(印章) — 프로젝트에 생명을 불어넣는 설계 문양.
> 각 Stage가 인장의 한 획. 완성된 Sigil이 Trine에 전달되면 프로젝트가 "소환"된다.
> **Sigil(설계) → Trine(구현)** = 마법진 완성 → 삼위일체 소환

## 파이프라인 구조

```
S1 Research → S2 Concept → S3 Design Document → S4 Planning Package/Production Guide
     ↓             ↓              ↓                      ↓
  [STOP]        [STOP]         [STOP]                 [STOP]
  리서치 리뷰    비전 승인       기획서 승인              → Trine / 제작
```

## 실행 모드 (2가지)

| 모드 | 설명 | 적용 |
|------|------|------|
| **기본 모드** | S1→S2→S3→S4 순차 진행 | 기본값. 대부분의 프로젝트 |
| **카운슬 모드** | 5+2 Agent Council 토너먼트 | Human 명시 선택. S1+S3 통합 실행 |

## 파이프라인 유연성 (Soft/Hard 의존성)

### Soft 의존성 (스킵 가능)

```
S1(리서치) → S2(컨셉)     ← 기존 자료가 있으면 스킵 가능
S2(컨셉) → S3(기획서)     ← 컨셉이 확정되면 스킵 가능
```

### Hard 의존성 (반드시 순서 유지)

```
S3(기획서) → S4(기획 패키지)           ← S3 기획서 없이 S4 진입 불가
S4(기획 패키지) → Trine(Spec 작성)     ← S4 개발 계획 없이 Trine 진입 불가
S3 관리자 페이지 포함 → S4에도 반영     ← 관리자 기능 누락 방지
```

### 진입 경로 (4가지)

| 시나리오 | 시작 Stage | 필요 입력 | 스킵 |
|---------|:---------:|----------|------|
| 아이디어만 있음 | S1 | 아이디어 한 줄 | 없음 (전체 실행) |
| 자료/리서치 있음 | S2 | 기존 리서치 문서 or 참고 자료 | S1 스킵 |
| 컨셉 확정됨 | S3 | 컨셉 문서 or Lean Canvas | S1+S2 스킵 |
| 기획서 있음 | S4 | PRD/GDD 문서 | S1+S2+S3 스킵 |

## 프로젝트 유형 (5유형)

| 유형 | 트랙 | S3 산출물 | S4 산출물 | 다음 단계 |
|------|:----:|----------|----------|----------|
| 앱 개발 | 개발 | PRD (.md + .pptx) | 기획 패키지 (아래 참조) | Trine Phase 1 |
| 웹 서비스 | 개발 | PRD + API Spec (.md + .pptx) | 기획 패키지 (아래 참조) | Trine Phase 1 |
| 게임 개발 | 개발 | GDD (.md + .pptx) | 기획 패키지 (아래 참조) | Trine Phase 1 |
| 유튜브/롱폼 | 콘텐츠 | 대본 + 구성안 | 제작 가이드 + SEO | 촬영/편집/배포 |
| 쇼폼 콘텐츠 | 콘텐츠 | 쇼폼 대본 (배치) | 배포 캘린더 | 편집/배포 |

## Do

- 파이프라인 시작 시 프로젝트 유형을 먼저 식별한다
- 진입 경로를 판단하여 기존 자료에 따른 Stage 스킵을 제안한다
- Hard 의존성(S3→S4→Trine)은 반드시 순서를 유지한다

## Don't

- S3 기획서 없이 S4에 진입하지 않는다
- S4 개발 계획 없이 Trine에 진입하지 않는다
- S3에 관리자 페이지가 포함되었는데 S4에서 누락하지 않는다

## AI 행동 규칙

1. 파이프라인 시작 시 프로젝트 유형을 먼저 식별한다
2. 진입 경로를 판단하여 기존 자료에 따른 Stage 스킵을 제안한다
3. 각 [STOP] 게이트에서 Human 승인을 반드시 받는다

## Iron Laws

- **IRON-1**: S3 기획서 없이 S4에 진입하지 않는다 (Hard 의존성)
- **IRON-2**: S4 개발 계획 없이 Trine에 진입하지 않는다 (Hard 의존성)

## Rationalization Table

| 합리화 (Thought) | 현실 (Reality) |
|-------------------|---------------|
| "기획서가 거의 완성이라 S4부터 시작해도 될 것 같다" | "거의 완성"은 미완성이다. S3 Gate를 통과하지 않은 기획서로 S4를 시작하면 S4 산출물이 불완전한 입력에 기반하게 된다 |
| "시간이 급하니 S4 없이 바로 개발을 시작하자" | S4 없이 시작한 개발은 기획-개발 단절로 재작업 비용이 2-3배 증가한다. 급할수록 기본을 지킨다 |

## Red Flags

- "이미 어느 정도 기획이 되어 있으니까..." → STOP. gate-log.md에서 해당 Stage PASS를 확인한다
- "개발하면서 기획을 보완하면..." → STOP. Hard 의존성 위반이다. S4 Gate를 먼저 통과한다
