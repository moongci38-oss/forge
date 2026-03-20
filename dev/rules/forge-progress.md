---
title: "진행 관리 규칙"
id: forge-progress
impact: MEDIUM
scope: [forge]
tags: [progress, pm, auto-update, notion]
requires: [forge-session-state]
section: forge-process
audience: dev
impactDescription: "미준수 시 PM 문서와 실제 진행상태 불일치, Notion 갱신 누락"
enforcement: flexible
---

# Progress Auto-Management Rules

## 개요

Notion Tasks DB가 작업 추적의 **유일한 Source of Truth**이다.
`forge-pm-updater` 에이전트가 Phase 전환 시 development-plan.md 갱신 + Notion 상태 동기화를 수행한다.

> **실행 주체**: `forge-pm-updater` 에이전트 (Haiku). AI가 Phase 전환/세션 이벤트 시 수동으로 스폰한다.

## 등록 기준

**Spec 문서가 등록과 브랜치 생성의 전제 조건이다.** 예외 없음.

```
Spec 작성 → Notion 등록 → 브랜치 생성 → 진행중 → PR → 완료
```

- Spec 없이 브랜치 생성 금지
- Spec 없이 Notion 등록 금지
- Hotfix도 Spec 작성 후 진행

## 상태 전환

```
할 일 ──[브랜치 생성]──▶ 진행중 ──[Check 3 진입]──▶ QA ──[PR Merge]──▶ 완료
  ▲                                                            │
  └────────────── Human 언제든 수동 override 가능 ──────────────┘
```

## AI 에이전트 트리거

| 이벤트 | 행동 | Notion 상태 변경 |
|--------|------|:----------------:|
| 브랜치 생성 (`feat/*`, `fix/*`, `hotfix/*`) | GitHub Actions → `sync-notion-tasks.py doing` | 할 일 → 진행중 |
| Check 3 진입 | AI → Notion MCP 직접 호출 | 진행중 → QA |
| PR Merge 완료 | GitHub Actions → `sync-notion-tasks.py done` | QA → 완료 |
| 재작업 (같은 브랜치 재생성) | GitHub Actions | → 진행중 |

## GitHub Actions 자동 갱신

`todo-tracker.yml` 워크플로가 브랜치 생성/PR merge 시 Notion Tasks DB를 직접 갱신한다.

- **Source of Truth**: `forge/dev/github-spec-kit/workflows/todo-tracker.yml`
- **의존 스크립트**: `forge/dev/github-spec-kit/scripts/sync-notion-tasks.py`
- **배포 위치**: 프로젝트의 `.github/workflows/todo-tracker.yml` + `scripts/sync-notion-tasks.py`

### 초기 등록

S4 Gate PASS 시 todo.md에서 Notion으로 일괄 등록:

```bash
python3 scripts/sync-notion-tasks.py register docs/planning/active/forge/todo.md
```

이후 todo.md는 자동 갱신하지 않음. Notion이 라이브 추적.

## Phase Checkpoint 연동

| Checkpoint | Notion 상태 영향 |
|-----------|:----------------:|
| `phase1_complete` | 관련 Task → 진행중 |
| `phase2_complete` | — |
| `phase3_complete` | — |
| `session_complete` | 관련 Task → 완료 |

## PM 문서 자동 갱신

`forge-pm-updater` 에이전트가 Phase 전환 시 development-plan.md를 갱신한다:

| 이벤트 | development-plan.md |
|--------|:-------------------:|
| 세션 시작 (init) | 새 세션 항목 추가 |
| Phase 전환 (checkpoint) | Phase 상태 업데이트 |
| 세션 완료 (complete) | 완료 상태 + 소요 시간 + Changelog + 회고 |

## Human Override 원칙

- Notion UI에서 언제든 상태 직접 변경 가능
- `last_edited_by.type == "person"`이고 상태가 AI 예상값과 다르면 → 스킵 (PM-IRON-1)

## AI 에이전트 행동 규칙

1. **브랜치 생성 직후**: GitHub Actions가 Notion 자동 갱신 (AI 개입 불필요)
2. **Check 3 진입**: AI가 Notion MCP로 직접 상태 변경 (진행중 → QA)
3. **PR merge 후**: GitHub Actions가 Notion 자동 갱신 + `forge-pm-updater` 스폰 → development-plan.md 완료 처리
4. **재작업 시**: `forge-pm-updater` 스폰 → 진행중으로 복귀
5. **Notion 갱신 실패 시**: 경고만 출력하고 파이프라인을 중단하지 않는다
