---
title: "Walkthrough 작성 규칙"
id: forge-walkthrough
impact: MEDIUM
scope: [forge]
tags: [walkthrough, documentation, check-3.5, traceability, pr]
requires: [forge-workflow]
section: forge-process
audience: dev
impactDescription: "미준수 시 Check 3.5 입력 부재로 트레이서빌리티 검증 불가, Spec 대비 구현 누락 미발견, PR 리뷰어에게 변경 맥락 전달 실패"
enforcement: flexible
---

# Walkthrough Requirement

## 개요

모든 기능 구현 완료 후 **Walkthrough 문서**를 작성해야 한다.
Walkthrough는 구현 결과를 요약하고, Spec 대비 검증 결과를 기록하는 필수 산출물이다.
Walkthrough는 **AI 자동 검증(Check 3.5)의 입력 데이터**로 사용된다.

## 작성 시점

Phase 3 (구현) 완료 후, AI Check 3 (test/lint/build) **이전**에 작성한다.

```
구현 완료 → Spec 대비 자체 검증 → Walkthrough 작성 → Check 3 → Check 3.5 (자동 수정) → PR 생성
```

## 파일명 규칙

```
docs/walkthroughs/{spec-filename}[-phase{N}][-{suffix}]-walkthrough.md
```

## 필수 섹션

템플릿: `.specify/templates/walkthrough-template.md` (프로젝트별 오버라이드 가능)

| 섹션 | 설명 | 필수 |
|------|------|:----:|
| Overview | 작업 요약 (1-2문장) | **필수** |
| Spec/Plan 참조 | Spec, Plan 파일 경로 + 브랜치 | **필수** |
| Completed Work | Task별 구현 내용 상세 | **필수** |
| Files Changed | 변경 파일 목록 (변경 유형 포함) | **필수** |
| Verification Results | AI 검증 결과 (test/lint/build) | **필수** |
| Spec 대비 검증 | 요구사항별 구현 상태 표 | **필수** |
| AI 검증 3.5 결과 | Walkthrough 기반 자동 검증 결과 | **필수** |
| Known Issues | 알려진 문제/제한사항 | 권장 |
| Commits | 관련 커밋 목록 | 권장 |

## AI Check 3.5 연계

Walkthrough 작성 후 AI Check 3.5가 자동 실행된다:

1. **파일 전수 검증**: Files Changed 섹션의 모든 파일 존재 확인
2. **Spec FR 검증**: 기능 요구사항별 코드 구현 확인
3. **Spec NFR 검증**: 비기능 요구사항별 설정/구현 확인
4. **결함 자동 수정**: 발견된 문제를 코드 수정 → 테스트 재실행 → Walkthrough 업데이트

## 브랜치별 적용 수준

| Branch Prefix | 강제 수준 | 미작성 시 |
|---------------|:--------:|----------|
| `feat/*` | **필수** | FAIL |
| `fix/*` | 권장 | WARN |
| `hotfix/*` | 선택 | SKIP |
| `docs/*` | 불필요 | SKIP |
| `chore/*` | 불필요 | SKIP |

## AI 에이전트 행동 규칙

1. 구현 완료 후 반드시 Walkthrough를 작성한다
2. 프로젝트 템플릿(`.specify/templates/walkthrough-template.md`)을 기반으로 작성한다
3. 프로젝트 검증 스크립트가 Walkthrough 존재를 검증한다
4. Multi-Phase 작업 시, 각 Phase마다 별도 Walkthrough를 작성한다
5. Walkthrough 작성 후 AI Check 3.5가 자동으로 실행된다
6. Check 3.5에서 결함 발견 시 자동 수정 후 Walkthrough를 업데이트한다
7. PR 생성 전 Walkthrough 존재 + Check 3.5 통과를 확인한다
