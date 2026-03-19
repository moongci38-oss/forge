---
description: Resume previous session from last checkpoint
allowed-tools: Bash, Read, Write
argument-hint: [session-name] or --all to list sessions
model: sonnet
---

# /forge-resume — 세션 재개

세션 상태를 확인하고 마지막 중단 지점부터 재개합니다.

## 실행 순서

1. `node ~/.claude/scripts/session-state.mjs list` 실행하여 활성 세션 목록 확인
2. 세션이 없으면 "No previous session found" 출력 후 종료
3. 세션이 1개면 자동 선택, 2개 이상이면 목록 출력 후 사용자에게 선택 요청
4. 선택된 세션의 상태 출력:

```
세션 재개
- 세션 이름: {sessionName}
- 세션 ID: {sessionId}
- 작업 규모: {workSize}
- 현재 Phase: {currentPhase}
- 마지막 체크포인트: {lastCheckpoint.phase} ({timestamp})
- 미완료 Check: {failedChecks}
- autoFix 누적: {totalAttempts}회
- 순환 카운터: {check3CycleCount}/3
```

5. Git 상태 확인 (uncommitted changes)
6. 마지막 체크포인트 Phase부터 재개

## Phase별 재개 행동

| Phase | 행동 |
|-------|------|
| phase1_complete | Phase 1.5 진입 |
| phase1.5_complete | Phase 2 진입 |
| phase2_complete | Phase 3 진입 |
| phase3_complete | Phase 4 진입 |

## 규칙

- autoFix 카운터는 리셋하지 않고 이어서 사용
- 이미 PASS된 Check는 재실행하지 않음
- rollbackHistory를 확인하여 이전 롤백 사유 파악
- 이후 모든 커맨드에 `--session {선택된 이름}` 전달
