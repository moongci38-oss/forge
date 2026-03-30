# 세션 재개 가이드

## 실행 순서

1. `.claude/state/sessions/` 디렉토리 확인
2. 활성 세션 목록 출력 (멀티세션 시 선택)
3. 현재 Phase 확인: `currentPhase` 필드
4. 마지막 체크포인트 출력: `checkpoints` 배열의 마지막 항목
5. 미완료 Check 결과 확인: `checkResults` 에서 FAIL인 항목
6. autoFix 이력 확인: 진행 중인 자동 수정 카운터

## 재개 시 출력 형식

```
세션 재개
- 세션명: {name}
- 세션 ID: {sessionId}
- 작업 규모: {workSize}
- 현재 Phase: {currentPhase}
- 마지막 체크포인트: {lastCheckpoint.phase} ({timestamp})
- 미완료 Check: {failedChecks}
- autoFix 누적: {totalAttempts}회
- 순환 카운터: {check3CycleCount}/3
```

## 주의사항
- autoFix 카운터는 리셋하지 않고 이어서 사용
- 이미 PASS된 Check는 재실행하지 않음
- rollbackHistory를 확인하여 이전 롤백 사유 파악
