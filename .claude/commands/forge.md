---
description: Forge Dev 워크플로우 시작 — Phase 1→4 파이프라인 실행
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task, TodoWrite, WebSearch, WebFetch
argument-hint: <작업 설명> or --size <hotfix|small|standard|multi-spec>
model: sonnet
---
> **⚠️ 실행 모드 확인**: 이 커맨드는 쓰기 모드에서만 정상 동작합니다. Plan mode 감지 시 즉시 [STOP] — "Escape로 plan mode 해제 후 재실행하세요. 내부 [STOP] 게이트가 승인 지점입니다."


# /forge — Forge Dev 워크플로우 시작

Forge Dev SDD+DDD+TDD 파이프라인을 시작합니다.

## 실행 순서

1. 세션 초기화:
   ```bash
   node ~/.claude/scripts/session-state.mjs init --name <작업명>
   ```

2. 작업 규모 분류 (자동 또는 `--size` 인자):
   - **hotfix**: 긴급 수정 (Phase 1.5/2 스킵 가능)
   - **small**: 소규모 기능 (간소화된 Spec)
   - **standard**: 표준 기능 (전체 Phase)
   - **multi-spec**: 대규모 (Plan/Task 분할 필수)

3. `forge/pipeline.md`를 기반으로 Phase 6부터 순차 진행

## Phase 흐름 (Part B: Phase 6~9)

| Phase | 작업 | Check |
|-------|------|-------|
| 6 | 세션 이해 + 요구사항 분석 | - |
| 7 | Spec/Plan 작성 + Human 승인 | - |
| 8 | 구현 + 검증 | Check 6→6.5→6.7 |
| 9 | PR 생성 | Check 7 |

## 규칙

- Phase 전환 시 자동 체크포인트 생성
- Check 6 실패 시 최대 3회 autoFix 순환
- Human 승인 게이트: Phase 7 완료 시 필수
- 세션 재개: `/forge-resume` 사용
- 통합 파이프라인: `forge/pipeline.md` 참조
