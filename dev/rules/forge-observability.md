---
title: "관측성 규칙"
id: forge-observability
impact: MEDIUM
scope: [forge]
tags: [logging, metrics, error-tracking, health-check, request-id, observability]
requires: []
section: forge-quality
---

# Observability Rules

> 로깅, 메트릭, 에러 추적을 표준화한다.
> Check 3.7 (code-reviewer)이 이 규칙을 검증한다.

## 구조화 로깅 필수

```text
[필수] NestJS Logger 또는 구조화 로거 사용 (winston, pino)
[금지] console.log/warn/error를 프로덕션 코드에서 사용
[필수] 로그에 contextual 정보 포함 (userId, requestId, action)
[금지] 로그에 민감 정보 포함 — 아래 PII 패턴 전체 금지:
  - password, token, secret, api_key, 카드번호
  - 이메일 (user@domain 패턴)
  - 전화번호 (010-XXXX-XXXX, +82 패턴)
  - 주민등록번호 (XXXXXX-XXXXXXX 패턴)
  - IP 주소 (사용자 식별 목적)
```

## 로그 레벨 기준

| 레벨 | 사용 기준 | 예시 |
|------|----------|------|
| **error** | 즉각 대응 필요한 실패 | DB 연결 실패, 외부 API 다운 |
| **warn** | 잠재적 문제, 동작은 계속 | 재시도 성공, deprecated API 호출 |
| **log** | 주요 비즈니스 이벤트 | 사용자 가입, 결제 완료 |
| **debug** | 개발/디버깅용 상세 | 쿼리 파라미터, 캐시 히트/미스 |
| **verbose** | 매우 상세한 추적 | 함수 진입/퇴출 |

## Request ID 추적

```text
[필수] 모든 HTTP 요청에 고유 requestId 할당 (UUID v4 또는 nanoid)
[필수] requestId를 로그, 응답 헤더(X-Request-Id), 하위 서비스 호출에 전파
[권장] NestJS Interceptor로 자동 할당
```

## 에러 추적

```text
[필수] 예상치 못한 에러(500)는 스택 트레이스 포함하여 로깅
[필수] 에러에 contextual 정보 첨부 (어떤 작업 중 발생했는지)
[금지] 에러 메시지에 내부 구현 상세 노출 (사용자 응답)
[권장] 에러 분류 코드 체계 (ERR_AUTH_001, ERR_DB_001 등)
```

## 헬스체크

```text
[필수] GET /health 엔드포인트 — DB, Redis, 외부 서비스 연결 상태 반환
[필수] 헬스체크는 인증 불필요 (@Public() 데코레이터)
[권장] 상세 헬스체크 (GET /health/detailed) — 인증 필요, 개별 서비스 상태
```

## 성능 메트릭 (권장)

```text
[권장] 요청 처리 시간 측정 (Interceptor로 X-Response-Time 헤더)
[권장] 슬로우 쿼리 로깅 (임계값: 1000ms)
[권장] 캐시 히트율 로깅 (주기적 집계)
[권장] 외부 API 호출 시간 측정
```

## AI 에이전트 행동 규칙

1. `console.log` 사용을 프로덕션 코드에서 감지하면 NestJS Logger로 교체를 제안한다
2. 에러 핸들링에서 로그 누락을 감지하면 경고한다
3. GET /health 엔드포인트 부재를 감지하면 추가를 제안한다
4. 로그에 민감 정보(password, token 등 패턴) 포함을 감지하면 FAIL 처리한다
5. 출력/로그 작성 전 PII 패턴(이메일, 전화번호, 주민등록번호, IP 주소)을 검사하고 마스킹 또는 제거한다

---

*Last Updated: 2026-03-08*
