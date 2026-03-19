---
title: "DB 운영 규칙"
id: forge-database-operations
impact: HIGH
scope: [forge]
tags: [database, migration, rollback, seeding, typeorm, schema]
requires: []
section: forge-quality
---

# Database Operations Rules

> DB 마이그레이션, 스키마 버저닝, 롤백 절차를 표준화한다.
> Check 3.7 (code-reviewer)이 이 규칙을 검증한다.

## 마이그레이션 필수

스키마 변경은 반드시 마이그레이션 파일을 통해 수행한다.

```text
[필수] 스키마 변경 → TypeORM migration:generate 또는 수동 마이그레이션 파일 생성
[금지] synchronize: true 프로덕션 사용 (개발 환경에서만 허용)
[금지] Entity 변경 후 마이그레이션 파일 없이 커밋
```

## 마이그레이션 네이밍

```text
[필수] 타임스탬프 기반: YYYYMMDDHHMMSS-DescriptiveName.ts
[필수] 설명적 이름: CreateUsersTable, AddEmailIndex, DropLegacyColumn
[금지] 무의미한 이름: Migration1, fix, update
```

## 마이그레이션 안전 규칙

### 비파괴적 변경 우선

```text
[필수] 컬럼 추가 → nullable 또는 default 값 필수
[필수] 컬럼 삭제 → 2단계 (1. 코드에서 미사용 확인 2. 다음 릴리즈에서 삭제)
[필수] 테이블 이름 변경 → 2단계 (1. 새 테이블 + 뷰/별칭 2. 코드 이전 후 구 테이블 삭제)
[금지] 단일 마이그레이션에서 컬럼 삭제 + 데이터 이전 동시 수행
```

### 롤백 필수

```text
[필수] 모든 마이그레이션의 down() 메서드 구현
[필수] down()이 up()의 역연산인지 검증
[권장] CI에서 up() → down() → up() 왕복 테스트
```

### 대용량 테이블 주의

```text
[권장] 100만+ 행 테이블 ALTER → 온라인 DDL 또는 배치 처리
[권장] 인덱스 생성 → CONCURRENTLY 옵션 (PostgreSQL)
[금지] 프로덕션에서 락 대기 시간이 긴 DDL 직접 실행
```

## 시딩 규칙

```text
[필수] 시드 데이터는 idempotent (중복 실행 안전)
[필수] upsert 패턴 사용 (INSERT ... ON CONFLICT DO UPDATE)
[금지] 시드에서 truncate 사용 (기존 데이터 손실 위험)
[필수] 테스트 시드와 프로덕션 시드 분리
```

## AI 에이전트 행동 규칙

1. Entity 변경 시 마이그레이션 파일 생성 여부를 확인한다
2. `synchronize: true` 사용을 프로덕션 설정에서 감지하면 경고한다
3. 컬럼 삭제/이름 변경 시 2단계 접근을 제안한다
4. 마이그레이션의 down() 메서드 구현을 확인한다
5. 시드 파일에서 truncate 사용을 감지하면 경고한다

---

*Last Updated: 2026-03-08*
