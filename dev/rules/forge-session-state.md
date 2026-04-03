---
title: "세션 상태 관리 규칙"
id: forge-session-state
impact: HIGH
scope: [forge]
tags: [session, checkpoint, autofix, multi-session]
requires: [forge-workflow]
section: forge-core
audience: dev
impactDescription: "미준수 시 세션 재개 실패, autoFix 카운터 리셋으로 무한 루프, 체크포인트 누락으로 작업 유실"
enforcement: rigid
---

# Forge Dev Session State Rules

> 전역 규칙. 프로젝트별 Phase 정의는 각 프로젝트의 `.claude/rules/`에서 override한다.

## 멀티세션 구조

```
<project>/.claude/state/
└── sessions/
    ├── feature-auth.json    ← 세션별 독립 파일
    └── seo-audit.json
```

- 세션 이름(파일명) = 사람이 읽는 라벨 (rename 안전)
- `sessionId`(UUID) = 내부 불변 식별자
- 한 프로젝트에서 여러 세션 동시 운영 가능

## 세션 시작 프로토콜

1. `.claude/state/sessions/` 디렉토리에서 **신규/재개** 판단
2. 존재 → 마지막 체크포인트에서 재개
3. 미존재 → `node ~/.claude/forge/scripts/session-state.mjs init --name <name>` 실행
4. **learnings 자동 로드** → `.claude/learnings.jsonl` 존재 시 현재 작업 컨텍스트 관련 상위 3건 확인 (서버 실행법, 알려진 이슈, 디버깅 교훈 등)

> **MUST**: 4번은 Forge Phase 진입 여부와 무관하게 **모든 세션 시작(신규/재개/Implicit Entry/비파이프라인 재개)에서 실행**한다. Phase 6 트리거에만 의존하지 않는다.

## 스크립트 호출

```bash
node ~/.claude/forge/scripts/session-state.mjs init --name <name>     # 세션 생성
node ~/.claude/forge/scripts/session-state.mjs list                    # 세션 목록
node ~/.claude/forge/scripts/session-state.mjs rename <old> <new>      # 이름 변경
node ~/.claude/forge/scripts/session-state.mjs clean                   # 완료 세션 정리
node ~/.claude/forge/scripts/session-state.mjs status --session <name> # 상태 확인
node ~/.claude/forge/scripts/session-state.mjs checkpoint <phase> --session <name>
```

## --session 자동 선택

- 세션 1개 → `--session` 생략 가능 (자동 선택)
- 2개 이상 → 반드시 `--session <name>` 지정
- AI는 대화 시작 시 세션을 선택하고, 이후 모든 커맨드에 일관 전달

## 체크포인트

Phase 전환 시 반드시 체크포인트를 생성한다.

| Phase | checkpoint state |
|-------|-----------------|
| Phase 1 완료 | `phase1_complete` |
| Phase 1.5 완료 | `phase1.5_complete` |
| Phase 2 완료 | `phase2_complete` |
| Phase 3 완료 | `phase3_complete` |
| Phase 4 완료 | `session_complete` |

각 체크포인트에서:
- `node ~/.claude/forge/scripts/session-state.mjs checkpoint --phase {state}` 실행
- WIP git commit 생성 (중간 상태 영속화)

## 작업 규모 분류 (Phase 1 완료 시 결정)

| 분류 | 기준 | Phase 스킵 |
|------|------|-----------|
| **Hotfix** | 긴급 장애, main 기반, 단일 파일 수정 | Phase 1.5/2 스킵, Check 3만 |
| **Standard** | 일반 기능 구현, 리팩토링, 테스트 추가 | 전체 Phase 수행 |

## autoFix 규칙

- Check 실패 시 **1회 자동 수정** → 재실행
- 1회 실패 → **[STOP]** Human 에스컬레이션
- autoFix 카운터는 대화 컨텍스트에서 관리 (별도 파일 불필요)

## 세션 재개 규칙

- `/forge-resume`으로 세션 재개 (멀티세션 시 목록에서 선택)
- autoFix 카운터는 리셋하지 않고 이어서 사용
- 이미 PASS된 Check는 재실행하지 않음
- `rollbackHistory`를 확인하여 이전 롤백 사유 파악

## History 크기 제한

| 히스토리 | 최근 N개 유지 | 나머지 |
|---------|:-----------:|--------|
| `autoFixHistory` | **5개** | `autoFixArchive` (요약만) |
| `rollbackHistory` | **3개** | `rollbackArchive` |
| `timeoutHistory` | **3개** | `timeoutArchive` |
| `humanOverrides` | **3개** | `overrideArchive` |

## 자동 정리

완료된 세션은 아래 시점에서 자동으로 정리된다 (수동 실행 불필요):

| 트리거 | 정리 내용 |
|--------|----------|
| `checkpoint session_complete` | 해당 세션 파일 즉시 삭제 |
| `init` | 잔여 완료 세션 삭제 + event-log.jsonl 회전 (500줄 → 200줄) |
| `list` | 잔여 완료 세션 삭제 |

`clean` 명령은 하위 호환용으로 유지되나, 일반적으로 호출할 필요 없다.

## 레거시 마이그레이션

기존 `session-state.json` 파일은 첫 `init` 또는 `list` 시 자동으로
`sessions/` 디렉토리로 마이그레이션된다. 원본은 `.migrated` 확장자로 보존.
