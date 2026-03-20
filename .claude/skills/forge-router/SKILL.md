---
name: forge-router
description: >
  자동 라우터: .specify/ 디렉토리가 있는 개발 프로젝트에서 코드 변경 요청(기능 구현, 버그 수정,
  리팩토링, API 개발, UI 구현)을 감지하여 Forge Dev 파이프라인을 자동 시작한다. Hotfix/Standard
  규모를 자동 분류하고, 기존 세션 재개 여부도 감지. user-invocable: false — 시스템 자동 실행 전용.
user-invocable: false
disable-model-invocation: true
---

# Forge Dev Auto-Router

코드 변경이 필요한 개발 요청을 감지하여 Forge Dev 파이프라인을 자동으로 시작한다.

## 라우팅 조건 (3-Signal Detection 강화)

| # | Signal | 판별 기준 |
|:-:|--------|----------|
| 1 | **프로젝트 컨텍스트** | `.specify/` 디렉토리 존재 (Forge Dev 설정이 있는 개발 프로젝트) |
| 2 | **코드 변경 의도** | 요청이 코드 수정/추가/삭제를 필요로 함 |
| 3 | **비제외 대상** | 아래 제외 목록에 해당하지 않음 |

## 라우팅 로직

| 조건 | 행동 |
|------|------|
| `.specify/` 존재 + 코드 변경 의도 | `/forge` 자동 호출 → Forge Dev Implicit Entry |
| `.specify/` 미존재 + 코드 변경 | 일반 개발 (Forge Dev 비적용) |
| 긴급/장애 키워드 ("긴급", "장애", "프로덕션 에러", "핫픽스") | Hotfix 분류 → 경량 Forge Dev |
| Forge Handoff 문서 존재 (`docs/planning/active/forge/handoff.md`) | 해당 세션 참조하여 Forge Dev 시작 |
| 기존 Forge Dev 세션 존재 | `/forge-resume` 안내 |

## 규모 자동 분류 Heuristic

| 분류 | Heuristic | 예시 |
|------|-----------|------|
| **Hotfix** | "긴급/장애/프로덕션 에러" 키워드, main 브랜치 수정, 단일 파일 | "로그인 500 에러 긴급 수정" |
| **Standard** | 새 기능, API 구현, 컴포넌트 생성, 리팩토링, 테스트 추가 | "채팅 기능 추가해줘" |

## 제외 대상 (이 스킬이 활성화되지 않아야 할 때)

- 코드 설명/분석만 요청 (구현 변경 없음)
- 문서(docs/, README)만 수정
- 파일 탐색/검색/코드 리뷰만 요청
- Business 워크스페이스 비개발 작업 (리서치, 마케팅, 콘텐츠) → `forge-router`가 처리
- `.specify/` 디렉토리가 없는 프로젝트

## 세션 재개 감지

기존 Forge Dev 세션이 있는 프로젝트에서 개발 요청이 오면:

1. `.claude/state/sessions/` 디렉토리에서 활성 세션 확인
2. 활성 세션 존재 → "기존 세션 재개할까요?" 안내 + `/forge-resume` 제안
3. 활성 세션 없음 → 새 Forge Dev 세션 시작
