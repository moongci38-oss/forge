---
name: canary
description: develop/staging 통합 후 15분 헬스 모니터링을 수행하는 스킬. 에러율, 응답 시간, 메모리 사용량 추적. Phase 10 자동 트리거.
user-invocable: true
context: fork
---

# Canary — 배포 후 헬스 모니터링

develop/staging 통합 후 일정 시간 헬스 모니터링을 수행한다.

## 핵심 원칙

> **배포 후 침묵은 안전이 아니다.**
> 능동적으로 모니터링하여 문제를 조기 감지한다.

## 사용법

(manual)
/canary                         # 기본 15분
/canary --duration 30           # 30분 모니터링
/canary --env staging           # 스테이징 환경

(auto-trigger)
Phase 10 Check 8 PASS → canaryEnabled 시 자동 실행

## 모니터링 항목

| 항목 | 소스 | 임계값 |
|------|------|--------|
| 에러율 | 서버 로그 / 모니터링 API | > 1% → WARN, > 5% → FAIL |
| 응답 시간 | 헬스체크 엔드포인트 | > 500ms p95 → WARN |
| 메모리 사용량 | 프로세스 모니터링 | > 80% → WARN |
| HTTP 상태 | 헬스체크 엔드포인트 | non-200 → FAIL |

## 워크플로우

1. `release-config.json`에서 `canaryEnabled`, `healthCheckUrl`, `monitoringDuration` 확인
2. 모니터링 시작 (기본 15분, 1분 간격 폴링)
3. 각 체크포인트에서 메트릭 수집
4. 임계값 초과 시 즉시 알림
5. 모니터링 완료 → 리포트 생성

## 설정 (release-config.json)

```json
{
  "canaryEnabled": true,
  "healthCheckUrl": "http://localhost:3000/api/health",
  "monitoringDuration": 15,
  "alertThresholds": {
    "errorRate": 0.01,
    "p95Latency": 500,
    "memoryPercent": 80
  }
}
```

## 스킵 조건

- `canaryEnabled: false` 또는 미설정
- `healthCheckUrl` 미설정
- 서버 인프라 미구축 (Phase 11/12 미도달)

## 산출물

`docs/canary/YYYY-MM-DD-canary-report.md`
