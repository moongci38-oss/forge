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

여러 모듈이 함께 잘 동작하는지 테스트한다. 실제 DB나 API 연동까지 포함하는 경우도 있다.

**특징**
- 모듈 간 인터페이스 검증
- 실제 의존성 일부 포함
- Unit보다 느리지만 E2E보다 빠름

**예시**
```js
// API 호출 → DB 저장 → 응답 확인
POST /users → DB에 실제 저장되는지 확인
GET /users/:id → 올바른 데이터 반환 확인
```

**도구**: Supertest, RestAssured, Testcontainers

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

**도구**: Playwright, Cypress, Selenium

---

## 개발부터 배포까지 테스트 흐름

```
개발자 로컬 → PR/커밋 → CI 파이프라인 → 스테이징 → 프로덕션
```

### 1단계 - 로컬 개발 중 (개발자 PC)

- 코드 작성과 함께 Unit Test 작성 및 실행
- TDD라면 테스트를 먼저 작성
- 빠른 피드백 루프가 핵심

### 2단계 - PR/커밋 시 (Git Hook)

- pre-commit 훅으로 Unit Test 자동 실행
- 테스트 실패 시 커밋 자체를 차단

```bash
# .husky/pre-commit
npm run test:unit
```

### 3단계 - CI 파이프라인 (GitHub Actions 등)

PR을 올리면 자동으로 아래 순서로 실행된다.

```
Unit Test
→ Integration Test
→ 코드 커버리지 체크
→ 정적 분석 (Lint)
→ 실패 시 머지 불가
```

```yaml
# GitHub Actions 예시
on: [pull_request]
jobs:
  test:
    steps:
      - run: npm run test:unit
      - run: npm run test:integration
      - run: npm run lint
```

### 4단계 - 스테이징 서버 배포 후

- E2E Test 실행 (실제 환경과 유사)
- QA팀 수동 테스트
- 성능/부하 테스트

### 5단계 - 프로덕션 배포 후

- 스모크 테스트 (핵심 기능만 빠르게 확인)
- 모니터링/알림 설정 (에러율, 응답속도)
- 이상 발생 시 즉시 롤백

---

## 단계별 정리

| 단계 | 테스트 종류 | 자동/수동 | 목적 |
|------|------------|---------|------|
| 로컬 개발 | Unit | 자동 | 빠른 피드백 |
| PR | Unit + Lint | 자동 | 코드 품질 보장 |
| CI | Unit + Integration | 자동 | 머지 전 검증 |
| 스테이징 | E2E + QA | 자동 + 수동 | 배포 전 최종 검증 |
| 프로덕션 | 스모크 + 모니터링 | 자동 | 배포 후 안정성 확인 |

---

## 핵심 원칙

**Shift Left** - 왼쪽(로컬)에서 버그를 최대한 일찍 잡아야 한다. 오른쪽(프로덕션)으로 갈수록 버그 수정 비용이 기하급수적으로 증가한다.

**Fast Feedback** - 테스트는 빨라야 한다. 느린 테스트는 개발자가 실행을 기피하게 만든다.

**Flaky Test 주의** - E2E 테스트는 환경에 따라 불규칙하게 실패할 수 있으므로 핵심 시나리오만 커버한다.
