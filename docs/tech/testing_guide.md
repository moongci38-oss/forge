# 소프트웨어 테스트 완전 정리

## 테스트 피라미드

```
        /\
       /E2E\        ← 적게, 느림, 비쌈
      /------\
     /통합테스트\     ← 중간
    /----------\
   /  단위테스트  \   ← 많이, 빠름, 저렴
  /--------------\
```

권장 비율: **Unit 70% : Integration 20% : E2E 10%**

---

## 테스트 종류

### 1. Unit Test (단위 테스트)

함수 하나, 클래스 하나를 독립적으로 테스트한다. 외부 의존성(DB, API)은 Mock으로 대체한다.

**특징**
- 가장 빠르고 가장 많이 작성
- 즉각적인 피드백
- 유지보수 비용이 낮음

**예시**
```js
expect(add(1, 2)).toBe(3)
expect(user.isValid()).toBeTruthy()
```

**도구**: Jest, Vitest, JUnit, pytest

---

### 2. Integration Test (통합 테스트)

여러 모듈이 함께 잘 동작하는지 테스트한다. 외부 의존성(DB, Redis, 외부 API)을 **Mock 기본, 필요 시 실제 연동**으로 처리한다.

**특징**
- 모듈 간 인터페이스 검증
- 외부 의존성: Mock 기본, 필요 시 실제 연동
- Unit보다 느리지만 E2E보다 빠름
- 로컬(Phase 3)에서 선택적 실행

**Mock vs 실제 연동 선택 기준**

| 상황 | 전략 | 이유 |
|------|------|------|
| 비즈니스 로직 중심 (서비스 계층) | **Mock** | 빠른 피드백, 외부 의존성 불필요 |
| ORM 쿼리·트랜잭션 검증 | **실제 DB** | Mock으로는 SQL/트랜잭션 동작 검증 불가 |
| Redis 캐시 만료·pub/sub 동작 | **실제 Redis** | TTL, 이벤트 순서 등 Mock으로 재현 어려움 |
| 외부 API 연동 (결제, 알림 등) | **Mock** | 외부 서비스 의존성 제거, 비용 방지 |

**실제 연동 시 도구**

```bash
# Testcontainers — 테스트 코드에서 컨테이너를 직접 관리
# 테스트 시작 시 DB/Redis 컨테이너 자동 생성 → 종료 시 자동 삭제
# Jest/Vitest/JUnit/pytest 등과 통합

# Docker Compose — 로컬 테스트 환경 일괄 구성
docker compose -f docker-compose.test.yml up -d   # 테스트 DB·Redis 기동
npm run test:integration                           # 통합 테스트 실행
docker compose -f docker-compose.test.yml down     # 정리
```

**예시**
```js
// Mock 방식: 서비스 계층 테스트
const mockUserRepo = { findById: jest.fn().mockResolvedValue(mockUser) }
const service = new UserService(mockUserRepo)
expect(await service.getUser('1')).toEqual(mockUser)

// 실제 연동 방식: DB 쿼리 검증 (Testcontainers)
const container = await new PostgreSqlContainer().start()
const repo = new UserRepository(container.getConnectionUri())
await repo.save({ name: 'test' })
expect(await repo.findById(1)).toMatchObject({ name: 'test' })
```

**도구**: Supertest, RestAssured, **Testcontainers**, **Docker Compose**

---

### 3. E2E Test (엔드투엔드 테스트)

실제 사용자처럼 브라우저를 직접 조작해서 전체 흐름을 테스트한다.

**특징**
- 실제 사용자 경험 검증
- 시스템 전체 연동 확인
- 느리고 유지비용이 높음 (flaky test 주의)

**예시**
```js
// Playwright 예시
await page.goto('/login')
await page.fill('#email', 'user@test.com')
await page.fill('#password', 'password')
await page.click('#login-btn')
await expect(page).toHaveURL('/dashboard')
```

**도구**: **Playwright** (Frontend E2E 필수), Supertest (Backend API E2E)

---

## 3계층 테스트 환경 모델

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  로컬 개발   │ ──→ │  Dev 서버    │ ──→ │   라이브     │
│  (Dev)      │     │  (Staging)  │     │ (Production) │
├─────────────┤     ├─────────────┤     ├─────────────┤
│ Unit (필수)  │     │ E2E (필수)   │     │ 스모크 (필수) │
│ Integration │     │             │     │ 모니터링     │
│ (필요 시)    │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
```

### 환경별 테스트 책임

| 환경 | 역할 | 실행할 테스트 | 필수 여부 |
|------|------|-------------|----------|
| **로컬 개발** (Dev) | 빠른 피드백 | Unit Test + Integration Test (필요 시) | Unit: **필수** / Integration: 선택 |
| **Dev 서버** (Staging) | 배포 후 검증 | E2E (Frontend: Playwright / Backend: supertest 등) + Redis·DB 연동 | **필수** |
| **라이브** (Production) | 배포 후 안정성 | 스모크 Test + 모니터링 | **필수** |

### SDD 워크플로우 매핑

| SDD Phase | 환경 | 실행할 테스트 | 비고 |
|-----------|------|-------------|------|
| **Phase 3** (구현/검증) | 로컬 개발 | Unit + Integration (필요 시) + Lint + Build | `verify.sh code` |
| **Phase 4** (PR/Git) | CI 파이프라인 | Unit + Integration + Lint | GitHub Actions |
| **배포 후** | Dev 서버 (Staging) | E2E | Staging 머지/배포 후 실행 (로컬 또는 서버) |
| **릴리즈 후** | 라이브 (Production) | 스모크 + 모니터링 | 핵심 기능 확인 |

> **E2E는 Staging 머지/배포 후에 실행한다.** Phase 3(구현 단계)에서는 실행하지 않는다. Staging 환경이 준비된 후, 로컬에서 Staging을 대상으로 실행하거나 Staging 서버에서 직접 실행할 수 있다.

---

## 개발부터 배포까지 테스트 흐름

```
로컬 개발 → PR/커밋(CI) → Dev 서버(Staging) → 프로덕션
```

### 로컬 개발 (개발자 PC)

- Unit Test 작성 및 실행 (**필수**)
- Integration Test (외부 의존성 연동 시 필요한 경우)
- TDD라면 테스트를 먼저 작성
- 빠른 피드백 루프가 핵심
- SDD Phase 3의 `verify.sh code`가 이 단계를 담당

### PR/커밋 → CI 파이프라인 (GitHub Actions 등)

PR을 올리면 자동으로 아래 순서로 실행된다.

```
Unit Test
→ Integration Test
→ Lint (정적 분석)
→ Build
→ 실패 시 머지 불가
```

> SDD에서는 Phase 3의 `verify.sh code`가 로컬에서 사전 검증하므로, pre-commit hook에서 별도 Unit Test를 실행하지 않아도 Phase 3이 대체한다.

### Dev 서버 머지/배포 후 (Staging)

- **E2E Test 실행** (**필수** — Frontend: Playwright / Backend: supertest 등)
- **Redis·DB 연동 테스트** (**필수** — 실제 데이터 저장소와의 연동 검증)
- 로컬에서 Staging 대상으로 실행하거나, Staging 서버에서 직접 실행
- 실제 환경과 유사한 조건에서 전체 흐름 검증
- 성능/부하 테스트 (필요 시)

### 프로덕션 배포 후 (라이브)

- 스모크 테스트 (핵심 기능만 빠르게 확인)
- 모니터링/알림 설정 (에러율, 응답속도)
- 이상 발생 시 즉시 롤백

---

## 단계별 정리

| 환경 | 테스트 종류 | 자동/수동 | 목적 |
|------|------------|---------|------|
| 로컬 개발 | Unit (+ Integration 선택) | 자동 | 빠른 피드백 |
| CI | Unit + Integration + Lint + Build | 자동 | 머지 전 검증 |
| Dev 서버 (Staging) | E2E + Redis·DB 연동 | 자동 | Staging 머지/배포 후 검증 |
| 프로덕션 | 스모크 + 모니터링 | 자동 | 배포 후 안정성 확인 |

---

## 핵심 원칙

**Shift Left** - 왼쪽(로컬)에서 버그를 최대한 일찍 잡아야 한다. 오른쪽(프로덕션)으로 갈수록 버그 수정 비용이 기하급수적으로 증가한다.

**Fast Feedback** - 테스트는 빨라야 한다. 느린 테스트는 개발자가 실행을 기피하게 만든다.

**E2E는 Staging 머지/배포 후** - Frontend E2E(Playwright)와 Backend E2E(supertest 등), Redis·DB 연동 테스트는 Staging 환경이 준비된 후에 실행한다. 로컬에서 Staging을 대상으로 실행하거나 Staging 서버에서 직접 실행할 수 있다. Phase 3(구현 단계)에서는 실행하지 않는다.

**Flaky Test 주의** - E2E 테스트는 환경에 따라 불규칙하게 실패할 수 있으므로 핵심 시나리오만 커버한다.
