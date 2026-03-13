---
title: "스킬 생성 도구 선택 기준"
id: skill-creation
impact: LOW
scope: [cross-project]
tags: [skills, tools, workflow]
requires: []
section: cross-project
audience: all
impactDescription: "스킬 생성 도구 미선택 시 품질 저하 또는 비효율적 수동 작업"
enforcement: flexible
---

# 스킬 생성 도구 선택 기준

## 도구

| 도구 | 용도 | 강점 |
|------|------|------|
| **skill-creator** (Plugin) | 스킬 자동 생성, 품질 평가, 개선, 벤치마크 | Create/Eval/Improve/Benchmark 4단계 자동화 |
| **writing-skills** (Superpowers) | 스킬 설계 원칙, 구조 가이드 | 스킬 아키텍처 원칙 참조 |

## 선택 기준

| 상황 | 도구 | 이유 |
|------|------|------|
| 새 스킬 생성 | **skill-creator** (기본) | 자동 스캐폴딩 + 품질 평가 |
| 기존 스킬 개선/리팩토링 | **skill-creator** (Improve) | 자동 분석 + 개선안 |
| 스킬 품질 평가 | **skill-creator** (Eval) | 정량 스코어링 |
| 스킬 설계 원칙 참조 | **writing-skills** | 아키텍처 가이드 |
| 스킬 구조 검토/학습 | **writing-skills** | 설계 원칙 이해 |

## AI 행동 규칙

1. 스킬 생성/수정 요청 시 `skill-creator` 플러그인을 기본 도구로 사용한다
2. 설계 원칙 확인이 필요하면 `writing-skills`를 병용한다
3. 이미 안정화된 스킬은 불필요하게 수정하지 않는다
4. 일회용 간단 스킬은 skill-creator 없이 직접 작성해도 무방하다
