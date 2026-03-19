# Forge Dev 시스템 — 백엔드 개발 진행 단계 상세 기술

> Phase 3 구현 시 Backend Teammate의 실제 작업 흐름, 4축 품질 검증, 도구 효율성 분석, 개선 권장사항을 기술한다.
> 작성일: 2026-02-24

---

## 1. Backend Teammate 스폰 및 컨텍스트 수신

### 1.1 팀 내 역할

```text
Team Lead (Opus 4.6)
  ├── Backend Teammate (Sonnet 4.6)  → apps/api/**
  └── Frontend Teammate (Sonnet 4.6) → apps/web/**
```

| 항목 | 내용 |
|------|------|
| 모델 | Sonnet 4.6 |
| 소유 파일 | `apps/api/src/modules/**`, `apps/api/test/**` |
| 수정 불가 | `apps/web/**`, `packages/shared/**`, `packages/ui/**`, 설정 파일 |
| 책임 | 백엔드 구현 + Unit Test + Integration Test (supertest) |

### 1.2 스폰 시 Lead가 전달하는 컨텍스트

Lead가 Task 도구로 Backend Teammate를 스폰할 때 다음을 전달:

- **Spec 파일 경로**: `.specify/specs/{name}.md` — API 설계, 데이터 모델, 테스트 요구사항
- **Plan 파일 경로**: `.specify/plans/{name}-plan.md` — 기술 결정, Task 의존성
- **공유 타입 위치**: `packages/shared/src/types/{feature}.ts` (Lead가 사전 정의)
- **파일 소유권 범위**: 수정 가능/불가 영역 명시
- **Task 의존성**: 선행 Task 완료 여부, 병렬 실행 가능 여부
- **구현 목표**: 어떤 엔드포인트/기능을 구현할 것인지

### 1.3 Wave별 스폰 타이밍

```text
Wave 1: Lead 직접 수행 (Shared 타입 정의)
Wave 2: Backend + Frontend Teammate 동시 스폰 (병렬)
Wave 3: Frontend Teammate 재스폰 (Backend 완료 의존)
Wave 4: Backend Teammate 재스폰 (통합 테스트)
```

재스폰 = 이전 Teammate 작업 완료 후 **새로운 Task 도구 호출**로 같은 역할의 Teammate를 다시 생성. Agent Teams에서 Teammate는 세션 재개가 불가하므로, Lead가 git commit으로 중간 상태를 영속화하고 새 Teammate에게 컨텍스트를 명시적으로 전달한다.

---

## 2. Backend Teammate의 구현 워크플로우

### 2.1 전체 흐름

```text
① Spec/Plan 분석 (15분)
   ↓
② 코드 구현 (1-3시간)
   Entity → DTO → Service → Controller → Module
   ↓
③ 단위 테스트 작성 (30분)
   Service.spec.ts + Controller.spec.ts
   ↓
④ Integration Test 작성 (20분)  ← 절대 규칙: Unit만으로 완료 선언 불가
   apps/api/test/{feature}.e2e-spec.ts (supertest 기반 통합 테스트)
   ↓
⑤ 자체 디버깅 (에러 시, 최대 3회)
   ↓
⑥ 완료 보고
   TaskUpdate(completed) + SendMessage(결과 요약)
```

### 2.2 ① Spec/Plan 분석

Backend Teammate가 가장 먼저 수행하는 작업:

1. **Spec 파일 읽기** — API 설계(Endpoints, Request/Response), 테스트 요구사항(required/optional) 확인
2. **Plan 파일 읽기** — 기술 결정(선택된 접근 방식), Task 의존성 그래프 확인
3. **공유 타입 확인** — `packages/shared/src/types/` 에서 Lead가 정의한 타입 import 방식 확인
4. **기존 코드 패턴 참고** — 프로젝트 내 다른 모듈(예: `apps/api/src/modules/chat/`)의 Entity/DTO/Service 패턴 파악

### 2.3 ② 코드 구현 순서

NestJS 모듈 구조에 따른 권장 구현 순서:

```text
apps/api/src/modules/{feature}/
├── entities/
│   └── {feature}.entity.ts        # ① Entity (TypeORM) — 데이터 구조 먼저
├── dto/
│   ├── create-{feature}.dto.ts    # ② DTO (class-validator) — 입력 검증
│   └── update-{feature}.dto.ts
├── {feature}.service.ts           # ③ Service — 비즈니스 로직
├── {feature}.controller.ts        # ④ Controller — HTTP 라우팅
└── {feature}.module.ts            # ⑤ Module — 의존성 주입 선언
```

**왜 이 순서인가?**

- Entity가 Service의 Repository 타입을 결정
- DTO가 Controller의 입력 파라미터 타입을 결정
- Service가 Controller의 호출 대상
- Module이 모든 것을 조립

### 2.4 ③ 단위 테스트

구현 완료 직후 즉시 작성:

- **Service.spec.ts**: 비즈니스 로직 검증 (Repository mock, Happy Path + Error Case)
- **Controller.spec.ts**: 엔드포인트 기본 동작 검증 (Service mock)
- 실행: `pnpm test`

### 2.5 ④ Integration Test — 통합 테스트 (절대 규칙)

```text
백엔드 API를 1개라도 추가/수정하면
supertest 기반 통합 테스트 (apps/api/test/*.e2e-spec.ts) 필수 작성
Unit 테스트만으로는 "테스트 완료" 선언 불가
```

- **테스트 레벨**: Integration (통합 테스트) — E2E(Playwright)가 아님
- **파일**: `apps/api/test/{feature}.e2e-spec.ts` (파일명 관례는 `.e2e-spec.ts`이나 실제 레벨은 Integration)
- **프레임워크**: NestJS `Test` + `supertest`
- **검증 대상**: HTTP 상태 코드, 응답 본문, DTO Validation, 파라미터 검증, 에러 케이스
- **실행**: `pnpm --filter api test:e2e`

### 2.6 ⑤ 자체 디버깅

| 상황 | 행동 |
|------|------|
| 테스트 FAIL, 원인 식별 가능 | 코드 수정 → 재실행 |
| 3회 이상 반복 실패 | Lead에게 보고 (SendMessage) |
| 설계 결함 발견 | 즉시 Lead 보고 |

### 2.7 ⑥ 완료 보고

Backend Teammate가 작업 완료 시 두 가지를 실행:

1. **TaskUpdate**: `status: "completed"`로 변경
2. **SendMessage**: Lead에게 결과 요약 전송
   - 구현 파일 목록
   - 테스트 통과 현황 (unit/integration)
   - 문제 없음 / 이슈 사항
   - Frontend과 API 계약 협의 필요 항목

---

## 3. 피어 메시징 (API 계약 협의)

Backend Teammate와 Frontend Teammate는 **SendMessage로 직접 대화** 가능:

- Backend가 API 응답 스키마를 정의 → Frontend에게 확인 요청
- Frontend가 추가 필드 요청 → Backend가 수정
- Lead는 이 협의 과정을 idle notification의 peer DM summary로 모니터링
- **Spec은 Lead만 수정 가능** — Teammate는 Spec 변경을 요청만 할 수 있음

---

## 4. 재스폰 (Wave 4) 상세 절차

### 4.1 재스폰이 필요한 이유

Agent Teams에서 Teammate는 하나의 Task를 완료하면 종료된다. 같은 역할의 Teammate에게 후속 Task를 배정하려면 **새로운 Task 도구 호출**로 재스폰해야 한다.

### 4.2 재스폰 전 Lead의 준비

1. **이전 Task 완료 확인**: TaskList로 선행 Task(예: Task 2) 완료 상태 확인
2. **중간 상태 영속화**: 필요시 git commit (WIP 커밋)
3. **새 Task의 컨텍스트 준비**: 이전 작업 결과 + 새 요구사항 정리

### 4.3 재스폰 시 컨텍스트 전달 방식

Lead가 Task 도구로 새 Backend Teammate를 스폰할 때 prompt에 포함하는 정보:

```text
1. 이전 진행 상황
   - 어떤 코드가 이미 구현되어 있는지
   - 어떤 테스트가 이미 통과했는지
   - git commit 참조 (해시)

2. 새 Task 요구사항
   - 이번에 구현할 구체적 내용
   - Spec의 관련 FR/NFR 번호
   - 의존하는 파일 경로

3. 파일 소유권
   - 수정 가능/불가 파일 재명시

4. 품질 기준
   - 필수 테스트 범위 (unit + integration)
   - 검증 명령어 (pnpm test, pnpm --filter api test:e2e)
```

### 4.4 estimate-e2e-flow 예시: Wave 4

```text
Wave 4: Backend Teammate 재스폰 (Task 5: 통합 테스트)

이전 상황:
- Task 2 (Wave 2): chat.gateway.ts에 @OnEvent("estimate.created") 핸들러 구현 완료
- Task 4 (Wave 3): Frontend의 generateEstimate() REST 호출 구현 완료

이번 Task:
- estimates.e2e-spec.ts 보강
  - POST /generate → estimate.created EventEmitter → chat:estimate WebSocket emit 통합 검증
  - 전체 플로우: WebSocket 연결 → 견적 키워드 → estimate_suggest → /generate → estimate 수신
  - 에러 케이스: 대화 내용 부족 → 400

의존 파일:
- chat.gateway.ts (Task 2에서 구현된 @OnEvent 핸들러)
- estimates.controller.ts (기존 eventEmitter.emit)
- 기존 e2e 테스트 패턴 (contact.e2e-spec.ts의 EventEmitter mock)

파일 소유권:
- 수정 가능: apps/api/test/estimates.e2e-spec.ts
- 수정 불가: apps/web/**, packages/shared/**
```

---

## 5. Lead의 후속 처리 (Teammate 완료 후)

Teammate 완료 보고를 받은 Lead가 수행하는 단계:

```text
① 결과 코드 검토
   ↓
② Shared 파일 추가 수정 (필요시)
   ↓
③ Walkthrough 작성
   docs/walkthroughs/{spec-name}-walkthrough.md
   ↓
④ verify.sh code 실행
   → Check 3: test + lint + build
   ↓
⑤ AI Check 3.5 자동 실행
   → Spec FR/NFR 대비 구현 검증
   → 결함 시 자동 수정 (최대 3회)
   ↓
⑥ Check 3.6/3.7/3.8 병렬 실행 (Subagent 격리)
   → UI/UX, 코드 품질, 보안
   ↓
⑦ 모두 통과 → PR 생성 (Phase 4)
```

---

## 6. 핵심 규칙 요약

| 규칙 | 내용 |
|------|------|
| **Spec 준수** | Spec 요구사항 100% 구현 |
| **파일 소유권** | `apps/api/**`만 수정, Shared/Web 수정 불가 |
| **Integration Test 필수** | API 변경 시 supertest 통합 테스트 작성 필수 (Unit만으로 불가) |
| **자체 디버깅 한도** | 3회 반복 실패 시 Lead 보고 |
| **구현 순서** | Entity → DTO → Service → Controller → Module → Test |
| **완료 보고** | TaskUpdate + SendMessage (파일 목록, 테스트 상태) |
| **재스폰 컨텍스트** | Lead가 이전 작업 + 새 요구사항 + 파일 소유권을 명시 전달 |
| **피어 메시징** | Frontend과 API 계약 불일치 시 직접 협의 가능 |

---

## 7. 백엔드 결과물 4축 품질 검증 (외부 Best Practices 포함)

### 7.1 4축 개요

| 축 | 검증 대상 | 현재 Forge Dev 커버리지 | 외부 벤치마크 |
|----|----------|:------------------:|-------------|
| **안정성 (Stability)** | 에러 핸들링, 입력 검증, 트랜잭션 | ~75% | NestJS Exception Filters, class-validator |
| **성능 (Performance)** | 응답 시간, DB 쿼리, 캐싱 | **~40% (최약)** | OWASP API4:2023, N+1 쿼리 방지 |
| **보안 (Security)** | 인증, 인가, 입력 살균 | ~85% | OWASP API Security Top 10 (2023) |
| **유지보수 (Maintainability)** | 코드 구조, 타입 안전성, 문서화 | ~80% | Clean Architecture, SOLID |

### 7.2 안정성 (Stability) — 현재 상태 및 Best Practices

**현재 Forge Dev 검증 체계:**

- [AUTO] Check 3: Unit Test + Integration Test (supertest) — Happy Path + Error Case
- [AUTO] Check 3.5: Spec FR/NFR 대비 트레이서빌리티 검증
- [AUTO] Check 3.7: 코드 품질 (code-reviewer 에이전트) — 에러 핸들링 패턴 검증

**외부 Best Practices (NestJS 공식 + OWASP):**

| 항목 | Best Practice | Forge Dev 상태 |
|------|-------------|:----------:|
| 글로벌 예외 필터 | `HttpExceptionFilter` + 커스텀 비즈니스 예외 | **구현됨** (verify.sh 검증) |
| class-validator DTO | `@IsString()`, `@IsNotEmpty()`, `@IsEmail()` 데코레이터 | **구현됨** (Spec FR 강제) |
| TypeORM 트랜잭션 | `QueryRunner` 또는 `@Transaction()` 래핑 | **PARTIAL** (복잡 mutation만) |
| 입력 크기 제한 | `@MaxLength()`, Payload 크기 Guard | **누락** — DoS 벡터 |
| Rate Limiting | `@nestjs/throttler` 미들웨어 | **PARTIAL** (전역만, 엔드포인트별 미적용) |

**권장 추가 검증:**

- DTO 필드에 `@MaxLength()` / `@Max()` 제한 필수화 → Check 3.7 룰에 추가
- 트랜잭션 래핑 여부를 Spec NFR로 명시 → Check 3.5에서 자동 검증

### 7.3 성능 (Performance) — 가장 취약한 축

**현재 Forge Dev 검증 체계:**

- [AUTO] Check 3: `pnpm build` 성공 여부만 확인
- [PARTIAL] Spec NFR에 응답 시간 명시 (예: `< 5s p95`) — 그러나 실측 검증 부재
- [NONE] APM, 로드 테스트, 쿼리 프로파일링 없음

**외부 Best Practices:**

| 항목 | Best Practice | Forge Dev 상태 |
|------|-------------|:----------:|
| N+1 쿼리 방지 | TypeORM `relations` eager/lazy + `QueryBuilder` JOIN | **검증 없음** |
| DB 인덱스 검증 | WHERE/ORDER BY 대상 컬럼 인덱스 존재 확인 | **검증 없음** |
| 응답 시간 측정 | APM (Datadog/New Relic) 또는 미들웨어 로깅 | **구현 없음** |
| 캐싱 전략 | Redis `@CacheInterceptor` 또는 in-memory TTL | **검증 없음** |
| Pagination | 대량 데이터 목록 API에 cursor/offset 필수 | **PARTIAL** (일부 API만) |
| 쿼리 로그 | TypeORM `logging: true` (개발 환경) | **구현 없음** |

**OWASP API4:2023 (Unrestricted Resource Consumption):**

> API가 요청 크기, 빈도, 리소스 소비를 제한하지 않으면 DoS 및 비용 폭증 위험.
> 적용: Rate Limiting + Payload 크기 + 응답 Pagination 필수.

**권장 추가 검증:**

- `TypeORM` 쿼리 로깅 개발 환경 활성화 → 미들웨어 또는 NestJS Interceptor
- Integration Test에서 응답 시간 assertion 추가 (`expect(responseTime).toBeLessThan(5000)`)
- N+1 감지: 테스트 실행 시 쿼리 카운트 assertion (ORM 훅)

### 7.4 보안 (Security) — 현재 가장 체계적

**현재 Forge Dev 검증 체계:**

- [AUTO] Check 3.8: 보안 전문 서브에이전트 (OWASP Top 10, 인증/인가, 입력 살균)
- [AUTO] Check 3.7: 코드 품질 검수에 보안 패턴 일부 포함
- [RULE] `forge-security.md` 룰 — Spec 단계에서 보안 요구사항 강제

**OWASP API Security Top 10 (2023) 대비:**

| OWASP ID | 위험 | Check 3.8 커버리지 |
|----------|------|:-----------------:|
| API1 | Broken Object Level Authorization (BOLA) | **검증됨** |
| API2 | Broken Authentication | **검증됨** |
| API3 | Broken Object Property Level Authorization | **PARTIAL** |
| API4 | Unrestricted Resource Consumption | **누락** (성능 축) |
| API5 | Broken Function Level Authorization | **검증됨** |
| API6 | Unrestricted Access to Sensitive Business Flows | **PARTIAL** |
| API7 | Server Side Request Forgery (SSRF) | **검증됨** |
| API8 | Security Misconfiguration | **검증됨** |
| API9 | Improper Inventory Management | **누락** |
| API10 | Unsafe Consumption of APIs | **검증됨** |

**권장 추가 검증:**

- API3 (Property Level Auth) 강화: DTO `@Exclude()` 데코레이터 검증 추가
- API9 (Inventory Management): 미사용/레거시 엔드포인트 감지 자동화

### 7.5 유지보수 (Maintainability)

**현재 Forge Dev 검증 체계:**

- [AUTO] Check 3: ESLint + TypeScript strict 컴파일
- [AUTO] Check 3.7: 코드 품질 (순환 복잡도, 중복 코드, 네이밍)
- [AUTO] Check 3.5: Walkthrough 문서 기반 구현 추적
- [RULE] `forge-walkthrough.md` — 구현 워크스루 필수 작성

**외부 Best Practices:**

| 항목 | Best Practice | Forge Dev 상태 |
|------|-------------|:----------:|
| 순환 복잡도 < 10 | McCabe Complexity 측정 | **Check 3.7 검증** |
| 함수 길이 < 50줄 | Long Method 감지 | **Check 3.7 검증** |
| 타입 안전성 | TypeScript strict mode | **구현됨** |
| Barrel exports | `index.ts`로 모듈 공개 API 관리 | **패턴 존재** |
| 변경 영향 범위 | 모듈 간 의존성 방향 검증 (의존성 역전) | **검증 없음** |
| 데드 코드 | 미사용 export/import 감지 | **PARTIAL** (ESLint 기본만) |

---

## 8. AI Agent Teams 병렬 개발 효율성 (학술/외부 근거)

### 8.1 외부 연구 결과

| 출처 | 핵심 발견 | Forge Dev 시사점 |
|------|----------|-------------|
| **Anthropic Multi-Agent** (2025) | 멀티 에이전트 시스템에서 단일 에이전트 대비 최대 90.2% 품질 향상 | Wave 기반 병렬화가 품질에 긍정적 |
| **METR RCT** (2025) | 경험 많은 개발자에게 AI 코딩이 19% 속도 **저하** (작업 전환 비용) | Teammate에게 명확한 컨텍스트 전달이 핵심 |
| **FeatureBench** (2025) | 복잡한 기능에서 AI 에이전트 성공률 11% (단순 기능은 ~60%) | Task 분해를 최대한 작은 단위로 |
| **AGENTS.md 연구** | 표준화된 에이전트 지침으로 실행 시간 28.64% 단축 | Forge Dev 룰/프롬프트 체계가 효율에 기여 |
| **모델 계층화 연구** | 리더-워커 구조에서 비용 최대 95% 절감 (품질 유지) | Opus(Lead) + Sonnet(Teammate) 전략 적합 |

### 8.2 현재 Forge Dev Agent Teams 효율성 평가

| 설계 원칙 | 현재 구현 | 효율성 |
|----------|----------|:------:|
| **파일 소유권 분리** | Backend/Frontend 충돌 방지 | **우수** |
| **Wave 기반 의존성 관리** | 선행 완료 후 다음 Wave 스폰 | **우수** |
| **모델 계층화** | Opus(Lead) + Sonnet(구현) | **우수** (비용 절감) |
| **컨텍스트 전달** | Prompt에 Spec/Plan/파일 소유권 명시 | **양호** |
| **재스폰 메커니즘** | git commit 영속화 + 새 Task 호출 | **양호** (컨텍스트 손실 가능) |
| **피어 메시징** | SendMessage로 API 계약 협의 | **양호** |
| **Haiku 활용** | 탐색/검색용 3번째 계층 | **미활용** (현재 Sonnet만 사용) |

### 8.3 병렬 개발 개선 기회

1. **Task 세분화**: FeatureBench 결과에 따라, 복잡한 Task를 더 작은 단위로 분해하면 AI 성공률 향상
2. **Haiku 계층 활용**: 파일 탐색, 패턴 확인 등 단순 작업에 Haiku 4.5 스폰 → 추가 비용 절감
3. **재스폰 시 컨텍스트 표준화**: AGENTS.md 연구의 시사점 — 구조화된 템플릿으로 컨텍스트 전달하면 28% 효율 향상
4. **WIP 커밋 자동화**: 재스폰 전 git commit을 자동화하면 컨텍스트 손실 방지

---

## 9. 현재 도구 활용 효율성 분석

### 9.1 에이전트 (Agents) — 4축 매핑

| 에이전트 | 안정성 | 성능 | 보안 | 유지보수 | 평가 |
|---------|:------:|:----:|:----:|:-------:|------|
| **code-reviewer** (Check 3.7) | O | △ | △ | O | 성능 검증 룰 부족 |
| **forge-check-security** (Check 3.8) | - | - | O | - | 적절히 활용 |
| **forge-check-traceability** (Check 3.5) | O | O | O | O | Spec 대비 전수 검증 |
| **forge-check-ui** (Check 3.6) | - | - | - | - | 백엔드 해당 없음 |
| **portfolio-analyzer** | - | - | - | O | 아키텍처 분석 |

**갭**: 성능 전문 검증 에이전트가 부재. Check 3.7이 코드 품질에 집중하나 N+1 쿼리, 응답 시간, 캐싱 전략은 미검증.

### 9.2 스킬 (Skills) — 4축 매핑

| 스킬 | 관련 축 | 활용 시점 | 효율성 |
|------|--------|----------|:------:|
| **requirements-clarity** | 전체 | Phase 1.5 Q&A | 우수 |
| **cto-advisor** | 전체 | 아키텍처 결정 | 미활용 (수동 호출 필요) |
| **research-engineer** | 전체 | 기술 분석 | 적절 |
| **ai-product** | 안정성/성능 | AI 통합 시 | 적절 |

**갭**: 성능 최적화 전문 스킬(Redis 캐싱, DB 쿼리 분석, 프로파일링) 부재.

### 9.3 룰 (Rules) — 4축 매핑

| 룰 | 안정성 | 성능 | 보안 | 유지보수 |
|----|:------:|:----:|:----:|:-------:|
| `forge-workflow.md` | O | - | O | O |
| `forge-walkthrough.md` | O | - | - | O |
| `forge-session-state.md` | - | - | - | O |
| `forge-requirements-analysis.md` | O | O | O | O |

**갭**: 성능 관련 전용 룰 부재 (예: "N+1 쿼리 금지", "인덱스 검증 필수", "캐싱 전략 명시" 등).

### 9.4 훅 (Hooks) — 4축 매핑

| 훅 | 관련 축 | 기능 |
|----|--------|------|
| `block-sensitive-files.sh` | 보안 | 민감 파일 쓰기 차단 |
| `require-date-prefix.sh` | 유지보수 | 파일명 규칙 강제 |
| `no-force-push.sh` | 안정성 | Git 안전 |
| `session-context.sh` | - | 세션 시작 컨텍스트 |

**갭**: 성능 관련 훅 부재 (예: "Integration Test 응답 시간 assertion 누락 경고").

### 9.5 MCP 서버 — 4축 매핑

| MCP | 관련 축 | 활용도 |
|-----|--------|:------:|
| **filesystem** | 유지보수 | 높음 |
| **playwright** | 안정성 | 백엔드 해당 없음 |
| **memory** | 유지보수 | 높음 |
| **sequential-thinking** | 전체 | 중 (복잡 설계 시) |
| **notion** | 유지보수 | 중 |

**갭**: APM/모니터링 MCP 부재. 쿼리 분석/프로파일링 도구 미연결.

### 9.5.1 APM/모니터링 부재 보완 전략

프로덕션 APM(Datadog, New Relic 등)을 Forge Dev 개발 워크플로우에 MCP로 연결하는 것은 과잉 설계이다.
대신 **개발 시점 성능 검증**을 3계층으로 보완한다.

#### 계층 1: 코드 레벨 — NestJS 내장 도구 활용

| 도구 | 구현 방식 | 감지 대상 |
|------|----------|----------|
| **TypeORM 쿼리 로깅** | `ormconfig`에 `logging: ['query', 'error']` (dev 환경) | 느린 쿼리, 실행 쿼리 수 |
| **LoggingInterceptor** | NestJS `@Injectable()` Interceptor로 요청 Duration 자동 로깅 | 응답 시간 이상치 |
| **QueryCountSubscriber** | TypeORM `EntitySubscriberInterface` 구현 → 요청당 쿼리 수 추적 | N+1 쿼리 자동 감지 |

구현 예시 (LoggingInterceptor):

```typescript
// apps/api/src/common/interceptors/logging.interceptor.ts
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context, next) {
    const start = Date.now();
    return next.handle().pipe(
      tap(() => {
        const duration = Date.now() - start;
        if (duration > 1000) {
          Logger.warn(`Slow request: ${context.getHandler().name} ${duration}ms`);
        }
      }),
    );
  }
}
```

구현 예시 (QueryCountSubscriber):

```typescript
// apps/api/src/common/subscribers/query-count.subscriber.ts
// AsyncLocalStorage 기반으로 요청별 쿼리 수 추적
// 개발 환경에서만 활성화 (NODE_ENV === 'development')
// 요청당 쿼리 10개 초과 시 WARNING 로그 출력
```

#### 계층 2: 테스트 레벨 — Integration Test 확장

supertest 기반 Integration Test에 성능 assertion을 표준 패턴으로 내장한다.

```typescript
// apps/api/test/helpers/performance.helper.ts
export function expectPerformance(response: supertest.Response, maxMs: number) {
  const duration = Number(response.header['x-response-time']);
  expect(duration).toBeLessThan(maxMs);
}

export function expectQueryCount(count: number, maxQueries: number) {
  expect(count).toBeLessThan(maxQueries);
}
```

적용 시점: Backend Teammate의 Integration Test 작성 단계(④)에서 자동 적용.
Spec NFR에 응답 시간 명시된 경우 → 해당 값으로 assertion.
NFR 미명시 → 기본 임계값 (5000ms) 적용.

#### 계층 3: 검증 레벨 — Check 확장 (정적 분석)

| Check | 검증 내용 | 방식 |
|-------|----------|------|
| **Check 3.7 확장** | code-reviewer 에이전트에 성능 룰 추가 | TypeORM `.find()` 호출에 `relations` 없이 관계 엔티티 접근 → N+1 경고 |
| **performance-checker** (신규) | 전용 성능 검증 에이전트 | Pagination 미적용 목록 API, 인덱스 누락 WHERE 절, 캐싱 미적용 빈번 조회 감지 |

#### 각 계층의 적용 단계

| 계층 | 적용 단계 | 성격 | 담당 |
|------|----------|------|------|
| **계층 1** (코드 인프라) | **프로젝트 인프라 셋업** (Phase 2 이전, 1회) | Interceptor/Subscriber를 프로젝트에 설치 → 이후 모든 기능 개발에 자동 적용 | Lead 또는 인프라 담당 |
| **계층 2** (테스트 패턴) | **Phase 3** (개발 단계) | Backend Teammate가 Integration Test 작성 시(④단계) 헬퍼 import하여 assertion 적용 | Backend Teammate |
| **계층 3** (검증 에이전트) | **Phase 3 이후** (검증 단계) | Check 3.6/3.7/3.8 병렬 실행 시점에 정적 분석으로 성능 문제 자동 감지 | Subagent (격리) |

```text
[1회 인프라 셋업] ← 계층 1 (Interceptor, Subscriber, helper 설치)
       ↓
Phase 2: Spec NFR에 응답 시간 명시
       ↓
Phase 3: Backend Teammate 구현 + Integration Test ← 계층 2 (assertion 패턴 사용)
       ↓
Phase 3 검증: Check 3.7 + performance-checker ← 계층 3 (자동 정적 분석)
       ↓
Phase 4: PR 생성
```

핵심: 계층 1은 개별 기능 개발(Phase 3)이 아니라, 프로젝트 레벨 인프라로 **사전 1회 설치**한다.
설치 후에는 모든 기능 개발에서 자동으로 쿼리 로깅/카운팅이 동작하므로,
Backend Teammate는 계층 2(테스트 assertion)만 의식적으로 적용하면 된다.

#### 왜 외부 APM MCP가 불필요한가

| 구분 | 프로덕션 APM | 개발 시점 검증 (위 3계층) |
|------|:----------:|:---------------------:|
| 목적 | 실시간 모니터링, 알림 | 코드 레벨 성능 문제 사전 차단 |
| 데이터 | 실 트래픽 기반 | 테스트 데이터 기반 |
| 비용 | Datadog $23/host/월~ | 무료 (NestJS 내장) |
| Forge Dev Phase | Phase 4 이후 (프로덕션) | **Phase 3 (개발)** ← 현재 범위 |
| MCP 필요 | 프로덕션 배포 후 연동 고려 | **불필요** |

결론: Phase 3 백엔드 개발 단계에서는 계층 1~3으로 충분히 성능 검증 가능.
프로덕션 APM은 서비스 런칭 후 인프라 차원에서 별도 설정 (Forge Dev 워크플로우 범위 밖).

### 9.6 도구 효율성 종합

```text
안정성:  ████████░░  75%  — Check 3 + 3.5 + 3.7로 대부분 커버
성능:    ████░░░░░░  40%  — ★ 가장 취약. 전용 도구/룰/에이전트 부재
보안:    ████████░░  85%  — Check 3.8 + 보안 룰로 체계적 커버
유지보수: ████████░░  80%  — Walkthrough + ESLint + Check 3.7로 커버
```

---

## 10. 갭 해소를 위한 기능 추천 (우선순위순)

### 10.1 우선순위 P1 — 성능 축 강화 (가장 시급)

| # | 추천 기능 | 유형 | 구현 난이도 | 기대 효과 |
|---|----------|------|:----------:|----------|
| 1 | **performance-checker 에이전트** | Agent | 중 | N+1 쿼리 감지, 인덱스 검증, 캐싱 전략 검토를 Check 3.7과 병렬 실행 |
| 2 | **forge-performance.md 룰** | Rule | 낮음 | "대량 데이터 API는 Pagination 필수", "N+1 쿼리 금지", "인덱스 검증" 등 명시적 룰 |
| 3 | **Integration Test 응답 시간 assertion** | Rule/Template | 낮음 | supertest 테스트에 `expect(res.duration).toBeLessThan(NFR값)` 패턴 강제 |
| 4 | **TypeORM 쿼리 로깅 미들웨어** | Skill/Template | 낮음 | 개발 환경에서 실행 쿼리 수/시간 자동 로깅 |

### 10.2 우선순위 P2 — 안정성/보안 강화

| # | 추천 기능 | 유형 | 구현 난이도 | 기대 효과 |
|---|----------|------|:----------:|----------|
| 5 | **DTO @MaxLength 필수 룰** | Rule | 낮음 | 문자열 필드에 크기 제한 강제 → DoS 방지 (OWASP API4) |
| 6 | **Check 3.8 OWASP API3 강화** | Agent 룰 | 중 | Property Level Auth — `@Exclude()` 데코레이터 검증 |
| 7 | **엔드포인트별 Rate Limiting 검증** | Rule | 낮음 | `@Throttle()` 데코레이터 존재 여부 Check 3.8에서 검증 |

### 10.3 우선순위 P3 — 병렬 개발 효율 향상

| # | 추천 기능 | 유형 | 구현 난이도 | 기대 효과 |
|---|----------|------|:----------:|----------|
| 8 | **재스폰 컨텍스트 템플릿** | Template | 낮음 | 구조화된 YAML/MD 템플릿으로 컨텍스트 손실 최소화 (AGENTS.md 연구 근거: 28% 효율 향상) |
| 9 | **Haiku 탐색 Teammate** | 워크플로우 | 낮음 | 파일 탐색/패턴 확인에 Haiku 4.5 활용 → 비용 추가 절감 |
| 10 | **WIP 커밋 자동화 훅** | Hook | 낮음 | Teammate 완료 시 자동 git commit → 재스폰 안정성 향상 |

### 10.4 우선순위 P4 — 유지보수 강화

| # | 추천 기능 | 유형 | 구현 난이도 | 기대 효과 |
|---|----------|------|:----------:|----------|
| 11 | **모듈 의존성 방향 검증** | Check 3.7 룰 | 중 | 순환 의존성 감지, 의존성 역전 원칙 검증 |
| 12 | **데드 코드 감지 강화** | ESLint 플러그인 | 낮음 | `eslint-plugin-unused-imports` 추가 |

---

## 11. 구현 로드맵

```text
Phase A (즉시 적용 가능, 1일):
  → #2 forge-performance.md 룰 작성
  → #3 Integration Test 응답 시간 패턴 템플릿 추가
  → #5 DTO @MaxLength 필수 룰 추가
  → #8 재스폰 컨텍스트 템플릿 작성

Phase B (1주일 내):
  → #1 performance-checker 에이전트 개발
  → #4 TypeORM 쿼리 로깅 미들웨어 스킬
  → #7 엔드포인트별 Rate Limiting 검증

Phase C (2주 내):
  → #6 Check 3.8 OWASP API3 강화
  → #9 Haiku 탐색 Teammate 워크플로우
  → #10 WIP 커밋 자동화 훅
  → #11 모듈 의존성 방향 검증
  → #12 데드 코드 감지 강화
```

---

*Last Updated: 2026-02-24*
