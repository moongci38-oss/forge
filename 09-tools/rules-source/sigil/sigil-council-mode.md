---
title: "Agent Council 모드"
id: sigil-council-mode
impact: MEDIUM
scope: [sigil]
tags: [pipeline, council, tournament]
requires: [sigil-structure]
section: sigil-pipeline
audience: all
impactDescription: "Council 모드 무단 활성화 시 토큰 비용 500%+ 증가. Human 미승인 토너먼트는 리소스 낭비"
enforcement: flexible
---

# SIGIL Agent Council 모드 (5+2 토너먼트)

> sigil-pipeline.md의 선택적 확장. Human이 파이프라인 시작 시 **명시적으로 선택**해야 활성화된다.

## 적용 조건

- Human이 파이프라인 시작 시 **명시적으로 선택**
- **권장 상황**: 신규 시장 진입 / 방향이 불확실 / 기존 경험 없는 도메인
- 기본 모드와 양자택일 -- S1+S3를 통합하여 각 Councilor가 리서치부터 기획까지 독립 수행

## 토너먼트 구조

```
[라운드 1] 5명 독립 리서치+기획 (Fan-out)
    ├─ Councilor A: 시장/수익 관점
    ├─ Councilor B: 기술/실현성 관점
    ├─ Councilor C: 사용자/UX 관점
    ├─ Councilor D: 경쟁/차별화 관점
    └─ Councilor E: 리스크/규제 관점
         ↓
[평가] Judge가 5축 매트릭스로 상위 2개 선별
    - 실현성(25%) / 시장적합(25%) / 비용효율(20%) / 리스크(15%) / 혁신성(15%)
         ↓
[라운드 2] 상위 2개 정교화 + 상대안 강점 병합
         ↓
[최종] Judge가 최종안 선택 또는 병합안 생성
    - [STOP] Human 승인
```

## 평가 기록

평가 결과는 `09-tools/templates/council-evaluation-template.md` 기반으로 기록하여 프로젝트 폴더에 저장.

## Agent Teams 패턴

| 패턴 | 적용 시점 |
|------|----------|
| **Fan-out/Fan-in** | 라운드 1 (5명 독립 실행) |
| **Competing Hypotheses** | 라운드 2 (상위 2개 정교화) |

## 산출물

| 유형 | 경로 |
|------|------|
| Council 평가 기록 | `02-product/projects/{project}/YYYY-MM-DD-council-evaluation.md` |
