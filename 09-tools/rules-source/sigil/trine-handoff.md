---
title: "SIGIL → Trine 전환"
id: trine-handoff
impact: HIGH
scope: [sigil, trine]
tags: [handoff, transition, trine]
requires: [sigil-s4-planning]
section: sigil-pipeline
audience: dev
impactDescription: "Handoff 문서 미생성 시 Trine에서 S4 산출물 참조 경로 불명 → 기획-개발 단절. 기술 스택/ADR 미전달 시 재의사결정 필요"
enforcement: rigid
---

# SIGIL → Trine 전환 규칙

## 전환 조건

Trine 진입은 아래 **모든 조건**을 충족해야 한다:

1. SIGIL S4 Gate가 `PASS`로 기록됨 (`gate-log.md`)
2. S4 필수 산출물 7종이 존재함
3. Human이 Trine 진입을 승인함

## Handoff 문서 구조

S4 완료 시 자동 생성하는 Handoff 문서:

- **경로**: `10-operations/handoff-to-dev/{project}/YYYY-MM-DD-sigil-handoff.md`
- **역할**: SIGIL(설계) → Trine(구현) 간 정보 전달 공식 문서
- **내용**: 산출물 인덱스, 기술 스택, 세션 로드맵, 개발 환경, ADR 요약, 우선순위

## SIGIL 산출물 → Trine 매핑

| SIGIL 산출물 | Trine 활용 시점 | 용도 |
|-------------|----------------|------|
| S1 리서치 | Phase 1 | 프로젝트 컨텍스트 이해 |
| S3 기획서 (PRD/GDD) | Phase 1.5 요구사항 분석 | 기능/비기능 요구사항 추출 |
| S4 상세 기획서 | Phase 2 Spec 작성 | 화면별 동작, 데이터 흐름 참조 |
| S4 사이트맵 | Phase 2 Spec 작성 | 네비게이션 흐름 참조 |
| S4 로드맵 | 세션 우선순위 결정 | Now/Next/Later 참조 |
| S4 개발 계획 | Phase 1 세션 이해 | 기술 스택, ADR, Trine 세션 로드맵 |
| S4 WBS | 세션 범위 설정 | 태스크별 규모 참조 |
| S4 UI/UX 기획서 | Phase 2 Spec UI 섹션 | 와이어프레임, 인터랙션 참조 |
| S4 테스트 전략서 | Phase 3 Check | 테스트 계층, 도구, 커버리지 목표 |

## 프로젝트 유형별 Trine 대상

| 프로젝트 유형 | Trine 대상 환경 | 비고 |
|-------------|---------------|------|
| 게임 (Unity) | GodBlade 또는 별도 Unity 프로젝트 | C# 개발 |
| 웹 서비스 | Portfolio (Next.js + NestJS) | TypeScript 개발 |
| 앱 개발 | 별도 앱 프로젝트 | 프레임워크에 따라 |

## Handoff 후 워크플로우

```
SIGIL S4 완료
    ↓
/trine 커맨드 실행 (BUSINESS 환경)
    ↓
Handoff 문서 자동 생성 (10-operations/handoff-to-dev/{project}/)
    ↓
개발 프로젝트 환경으로 이동 (Human)
    ↓
Trine Session 1부터 순차 진행
    ├─ Spec 작성 (S4 산출물 참조)
    ├─ Plan 작성
    ├─ 구현 + AI Check
    ├─ Walkthrough
    └─ PR
```

## 관리자 산출물 포함 규칙

S3 기획서에 관리자 기능이 포함된 경우, Handoff 문서에 관리자 산출물도 포함:
- 관리자 상세 기획서
- 관리자 사이트맵
- 관리자 UI/UX 기획서

## Do

- S4 Gate PASS 후 Handoff 문서를 자동 생성한다
- 산출물 인덱스에 모든 S4 산출물 경로를 포함한다
- S3에 관리자 기능이 포함된 경우 관리자 산출물도 Handoff에 포함한다

## Don't

- Handoff 문서 미생성으로 Trine에 진입하지 않는다
- 산출물 인덱스에 누락이 있는 상태로 Handoff를 완료하지 않는다
- Human 승인 없이 Trine 세션을 시작하지 않는다

## AI 행동 규칙

1. S4 Gate PASS 확인 후 Handoff 문서를 자동 생성한다
2. Handoff 문서에 산출물 인덱스, 기술 스택, 세션 로드맵을 포함한다
3. Human에게 Trine 진입 안내를 제공하고 승인을 기다린다

## Iron Laws

- **IRON-1**: Handoff 문서 미생성 상태로 Trine에 진입하지 않는다
- **IRON-2**: gate-log.md에 S4 PASS 기록이 없으면 Trine 진입을 거부한다

## Rationalization Table

| 합리화 (Thought) | 현실 (Reality) |
|-------------------|---------------|
| "Handoff는 형식적이니 스킵해도 개발 가능하다" | Handoff 없이 Trine에 진입하면 S4 산출물 참조 경로가 불명확하여 기획-개발 단절이 발생한다 |
| "어차피 같은 사람이 하니까 문서 없어도 된다" | 1인이라도 세션 간 컨텍스트가 유실된다. Handoff는 세션 독립성을 보장하는 공식 문서다 |

## Red Flags

- "바로 코딩부터 시작하자..." → STOP. gate-log.md에서 S4 PASS를 확인한다
- "Handoff 문서는 나중에 만들면..." → STOP. Trine 진입 전 Handoff 자동 생성을 실행한다
