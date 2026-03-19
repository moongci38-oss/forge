---
title: "백엔드 성능 규칙"
id: forge-performance
impact: HIGH
scope: [forge]
tags: [performance, nestjs, typeorm, backend, n-plus-one, pagination, rate-limiting]
requires: []
section: forge-quality
audience: dev
impactDescription: "미준수 시 N+1 쿼리로 API 응답 10-100x 지연, 무제한 목록 반환으로 OOM, Rate Limiting 부재로 DDoS 취약"
enforcement: rigid
---

# Forge Dev Performance Rules

> 백엔드 API 성능 품질을 개발 단계에서 보장하기 위한 규칙.
> Check 3.7 (code-reviewer) 및 performance-checker 에이전트가 이 규칙을 검증한다.

## N+1 쿼리 금지

TypeORM에서 관계 엔티티에 접근할 때 반드시 `relations` 옵션 또는 `QueryBuilder` JOIN을 사용한다.

```text
[금지] 루프 내에서 개별 .find() / .findOne() 호출
[필수] relations 옵션, leftJoinAndSelect, 또는 QueryBuilder로 한 번에 조회
```

- `.find()` 호출에 관계 엔티티 접근이 필요하면 `relations` 배열에 명시
- 루프 내 Repository 호출은 N+1 패턴으로 간주하고 경고

## Pagination 필수

목록을 반환하는 API는 반드시 Pagination을 적용한다.

```text
[필수] 목록 API → take/skip 또는 cursor 기반 Pagination
[금지] 전체 레코드를 한 번에 반환 (제한 없는 .find())
```

- `.find()` 호출에 `take` 파라미터가 없으면 경고
- 기본 페이지 크기: 20 (최대 100)
- Spec에 명시되지 않은 목록 API도 이 규칙 적용

## DB 인덱스 검증

WHERE/ORDER BY에 사용되는 컬럼은 인덱스가 존재해야 한다.

```text
[필수] 자주 조회되는 컬럼에 @Index() 데코레이터
[권장] 복합 조건 → 복합 인덱스 (@Index(['col1', 'col2']))
```

- Entity에 `@Index()` 없이 WHERE 조건에 자주 사용되는 컬럼 → 경고
- `createdAt`, `updatedAt` 정렬 사용 시 인덱스 권장

## DTO 입력 크기 제한

모든 문자열 DTO 필드에 `@MaxLength()` 제한을 적용한다 (OWASP API4:2023 대응).

```text
[필수] string 타입 DTO 필드 → @MaxLength() 데코레이터
[필수] number 타입 DTO 필드 → @Max() 데코레이터 (합리적 상한)
[필수] 배열 타입 DTO 필드 → @ArrayMaxSize() 데코레이터
```

- `@IsString()`만 있고 `@MaxLength()`가 없는 필드 → Check 3.7 경고
- 권장 기본값: 일반 텍스트 255자, 설명/본문 5000자, 이메일 254자

## 응답 시간 NFR 검증

Spec NFR에 응답 시간이 명시된 경우, Integration Test에서 실측 검증한다.

```text
[필수] NFR 응답 시간 명시 → Integration Test에 duration assertion
[기본] NFR 미명시 → 5000ms 기본 임계값 적용
```

- supertest 응답에서 `x-response-time` 헤더 또는 테스트 내 시간 측정
- `performance.helper.ts`의 `expectPerformance()` 헬퍼 사용 권장

## 엔드포인트별 Rate Limiting

모든 공개 API 엔드포인트에 Rate Limiting을 적용한다 (OWASP API4:2023 대응).

```text
[필수] 전역 Rate Limiting → @nestjs/throttler 모듈 등록
[필수] 민감 엔드포인트 → @Throttle() 데코레이터로 개별 제한
[권장] 인증 관련 (login, register, forgot-password) → 엄격한 제한 (5-10 req/min)
```

- 전역 `ThrottlerGuard`만 적용하고 엔드포인트별 `@Throttle()`이 없으면 경고
- 인증/결제 등 민감 엔드포인트에 개별 Rate Limit 필수
- `@SkipThrottle()`은 내부 API 또는 헬스체크에만 허용

| 엔드포인트 유형 | 권장 제한 | 비고 |
|---------------|:----------:|------|
| 인증 (login, register) | 5-10 req/min | 브루트포스 방지 |
| 비밀번호 재설정 | 3 req/min | 이메일 폭탄 방지 |
| 일반 CRUD | 60 req/min | 전역 기본값 |
| 파일 업로드 | 10 req/min | 리소스 소비 제한 |
| 공개 조회 (비인증) | 30 req/min | 스크래핑 방지 |

## 캐싱 전략 명시

빈번하게 조회되는 데이터(설정, 목록)는 캐싱 전략을 Spec 또는 코드에 명시한다.

```text
[권장] 변경 빈도 낮은 데이터 → in-memory 캐시 또는 Redis
[권장] 캐시 TTL과 무효화 전략을 주석 또는 Spec에 명시
```

## AI 에이전트 행동 규칙

1. **Check 3.7**: 위 규칙을 정적 분석으로 검증한다
2. **Backend Teammate**: 구현 시 위 규칙을 준수한다
3. **Spec 작성 시**: NFR에 응답 시간, 페이지 크기, 캐싱 요구사항을 명시한다
4. **Integration Test**: `performance.helper.ts` 헬퍼를 import하여 성능 assertion 적용
