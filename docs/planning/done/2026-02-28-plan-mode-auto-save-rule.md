# Plan: Plan Mode 플랜 → 프로젝트 자동 저장 규칙 추가

## Context

Claude Code plan mode는 `.claude/plans/`에 랜덤 이름(`dazzling-launching-cray.md` 등)으로 플랜을 저장한다. 이 파일은 프로젝트의 `docs/planning/` 구조와 연결되지 않아서:

- 어떤 계획으로 어떤 작업을 했는지 추적 불가
- `docs/planning/active/` → `docs/planning/done/` 라이프사이클에서 누락
- 프로젝트별 의사결정 이력이 끊김

기존에 `docs-structure.md`와 `file-naming.md` 규칙이 `docs/planning/active/`와 `docs/planning/done/` 구조를 정의하고 있으나, plan mode 플랜을 여기에 저장하라는 지시가 없다.

## 목표

plan mode 승인 후 플랜이 프로젝트의 `docs/planning/active/`에 날짜 prefix 파일로 자동 저장되고, 구현 완료 시 `done/`으로 이동되도록 `plan-mode.md` 규칙에 섹션을 추가한다.

## 변경 대상

**파일**: `C:\Users\moongci\.claude\rules\plan-mode.md`

추가할 규칙:

| 항목 | 내용 |
|------|------|
| **저장 시점** | Plan 승인 직후, 구현 시작 전 |
| **저장 경로** | `{project}/docs/planning/active/YYYY-MM-DD-{descriptive-name}.md` |
| **파일명** | 날짜 prefix + 작업 설명 kebab-case (`.claude/plans/`의 랜덤 이름이 아닌 의미 있는 이름) |
| **프로젝트 판별** | 현재 작업 디렉토리(Primary working directory) 기준 |
| **완료 시** | `docs/planning/active/` → `docs/planning/done/`으로 이동 |
| **예외** | `docs/planning/` 폴더가 없는 프로젝트는 스킵 |

## 일관성

- `docs-structure.md`: `planning/active/` → `planning/done/` 라이프사이클 이미 정의됨
- `file-naming.md`: `docs/planning/active/YYYY-MM-DD-{plan-name}.md` 형식 이미 정의됨
- 기존 plan-mode.md의 "What vs How" 원칙, 적용 범위에는 변경 없음

## 결과

- `plan-mode.md`에 "프로젝트 저장 규칙" 섹션 추가 완료
- 기존 What vs How 분리 원칙 유지
- docs-structure.md, file-naming.md와 형식 일관성 유지
