---
title: "테스트 품질 규칙"
id: forge-test-quality
impact: HIGH
scope: [forge]
tags: [test, quality, integration, coverage, check-3.5t]
requires: [forge-workflow]
section: forge-quality
audience: dev
impactDescription: "미준수 시 Integration Test 누락으로 API 결함 미발견, Error Case 미테스트로 프로덕션 장애, Spec-Test 매핑 미달로 요구사항 누락"
enforcement: rigid
---

# Test Quality Rules

> Check 3.5T — 테스트 품질 검증 게이트.
> 테스트의 **존재**가 아닌 **품질과 포괄성**을 검증한다.

## 적용 조건

- 프로젝트에 `.specify/test-quality-config.json` 존재 시에만 활성화
- 설정 파일 미존재 → Check 3.5T 전체 **SKIP** (비개발 워크스페이스 영향 없음)

## 검증 8축

### T-0: TDD 프로세스 준수 (Warning)

테스트 커밋이 구현 커밋보다 앞서 작성되었는지 검증한다.

- Git log에서 테스트 파일 변경 커밋과 구현 파일 변경 커밋의 타임스탬프를 비교
- **TypeScript**: 테스트 파일 패턴: `*.spec.ts`, `*.test.ts`, `*.e2e-spec.ts` / 구현 파일 패턴: `*.service.ts`, `*.controller.ts`, `*.module.ts`, `*.tsx`, `*.ts` (테스트 제외)
- **C# / Unity**: 테스트 파일 패턴: `*.Tests.cs`, `*Test.cs`, `*Tests/*.cs` / 구현 파일 패턴: `*.cs` (테스트 파일 제외). Unity PlayMode 테스트는 TDD 순서 예외 (구현 후 작성 허용)
- **WARN**: 구현 커밋이 테스트 커밋보다 앞서는 FR이 50% 이상
- **판정**: Heuristic 기반 경고(Warning)로 설정. Critical이 아닌 이유: 커밋 타임스탬프가 TDD 순서를 100% 반영하지 못함 (amend, squash 등)
- **Superpowers 연동**: `superpowers:test-driven-development` 스킬 적용 시 T-0 위반 가능성 대폭 감소

### T-1: Integration Test 존재 (Critical)

API 변경이 포함된 FR에 대해 Integration Test 파일이 존재해야 한다.

- Check 3.5 출력의 `requirements` 중 API 변경 FR 식별
- 해당 FR의 `testFile`이 설정의 `integrationTestPatterns`에 매칭되는지 확인
- **TypeScript**: `*.e2e-spec.ts`, `*.integration.spec.ts`
- **C# / Unity**: `*.Integration.Tests.cs`, `*IntegrationTests/*.cs`, `*IntegrationTest.cs`
- **FAIL**: API 변경 FR 중 Integration Test 1개라도 누락

### T-2: Error Case 포괄 (Critical)

각 FR의 테스트에 Happy Path 외 Error Case(4xx, 예외)가 포함되어야 한다.

- **TypeScript**: 테스트 파일에서 `describe`/`it`/`test` 블록 분석. Error Case 패턴: 4xx 상태코드, `throw`, `reject`, `error`, `invalid`, `fail`, `unauthorized`, `forbidden`, `not found`
- **C# / Unity**: 테스트 파일에서 `[Test]`/`[TestCase]` 메서드 분석. Error Case 패턴: `Assert.Throws`, `Assert.ThrowsAsync`, `[ExpectedException]`, `Assert.That(..., Throws`, `Should.Throw`, `ArgumentException`, `InvalidOperationException`
- **FAIL**: Error Case가 0개인 FR 존재

### T-3: Spec 테스트 매핑률 (Warning)

Spec 10절(테스트 요구사항)에 명시된 테스트 케이스 대비 실제 구현된 테스트의 매칭률.

- Spec 파일에서 테스트 요구사항 섹션 파싱
- 실제 테스트 파일의 `describe`/`it` 블록과 매칭
- **FAIL**: 매칭률 80% 미만 (임계값은 설정에서 오버라이드 가능)

### T-4: 테스트 격리 (Warning)

테스트가 외부 의존성 없이 독립 실행 가능해야 한다.

- **외부 서비스 직접 호출**: 실제 HTTP 요청, DB 직접 연결 (mock 미사용)
- **전역 상태 변경**:
  - TypeScript: `process.env` 직접 수정, 전역 변수 변경
  - C#: `Environment.GetEnvironmentVariable` / `Environment.SetEnvironmentVariable` 직접 호출, `static` 필드 변경
- **외부 의존성 직접 생성**:
  - TypeScript: `new HttpClient()` 직접 생성 (mock 미사용)
  - C#: `new HttpClient()` / `new SqlConnection()` / `new TcpClient()` 테스트 내 직접 생성 (DI/mock 미사용)
- **순서 의존**: 다른 테스트의 사이드 이펙트에 의존하는 패턴
- **FAIL**: Critical 패턴 1개 이상 존재

### T-5: 커버리지 임계값 (선택)

프로젝트 설정의 `coverageThreshold`에 정의된 임계값 충족 여부.

- 설정에 `coverageThreshold`가 없으면 SKIP
- 커버리지 데이터가 없으면 SKIP (자동 실행하지 않음)
- **FAIL**: 임계값 미달

### T-6: 모바일 디바이스 E2E 커버리지 (Warning)

프론트엔드가 포함된 FR에 대해 모바일 뷰포트 E2E 테스트가 존재해야 한다.

#### TypeScript (웹/앱 프로젝트)

- Spec 9.6에 모바일 breakpoint가 정의되어 있는지 확인
- E2E 테스트 설정(playwright.config)에 모바일 디바이스 프로젝트가 포함되어 있는지 확인
- E2E 테스트 파일에서 모바일 뷰포트 관련 테스트(devices, viewport, isMobile)가 존재하는지 확인
- **WARN**: 모바일 breakpoint 정의 있으나 모바일 E2E 디바이스 설정 없음
- **FAIL**: 프론트엔드 FR이 3개 이상이고 모바일 E2E 테스트 0개

#### C# / Unity (게임 프로젝트)

- **면제**: Unity 게임은 빌드 타겟 기반 크로스플랫폼이므로 T-6 적용하지 않는다
- Unity PlayMode 테스트가 해상도 독립성을 커버한다 (Spec 9.5 해상도 대응표 참조)
- 게임 프로젝트에서 T-6은 자동 **SKIP** 처리

### T-7: 버그 스킵 금지 (Critical)

기능 버그를 스킵으로 숨기는 것을 금지한다. 버그는 반드시 FAIL로 보고해야 한다.

#### TypeScript

- `test.skip()`은 **환경 의존성**에만 허용: env 미설정, 서버 미기동, 외부 서비스 불가, 테스트 데이터 부재
- **금지 패턴**: `skip` + `pre-existing`, `known bug`, `known issue`, `TODO: fix`, `workaround` 조합
- **허용 패턴**: `skip` + `no data`, `not available`, `env`, `server`, `CI` 조합
- 버그 발견 시 선택지: (1) 즉시 수정, (2) `test.fail()` + 이슈 등록, (3) `expect`로 FAIL 처리

#### C# / Unity (NUnit)

- `[Ignore("reason")]` 어트리뷰트는 **환경 의존성**에만 허용
- `[Explicit]` 어트리뷰트는 수동 실행 전용 테스트에만 허용 (성능 벤치마크, 장시간 테스트)
- **금지 패턴**: `[Ignore]` + `known bug`, `known issue`, `TODO`, `workaround`, `pre-existing` 사유
- **허용 패턴**: `[Ignore]` + `requires server`, `no test data`, `CI only`, `env not configured` 사유
- 버그 발견 시 선택지: (1) 즉시 수정, (2) `Assert.Fail("Known bug: #issue")` + 이슈 등록, (3) `Assert.Inconclusive` 사용 금지 (버그 은닉)

#### 공통

- **FAIL**: 기능 버그를 skip/Ignore로 숨기는 패턴 1개 이상 존재

## Teammate 행동 규칙

Teammate는 구현 시 아래 테스트 품질 기준을 준수해야 한다:

0. **테스트 먼저 작성 (TDD)** — Standard+ 규모에서 프로덕션 코드보다 테스트를 먼저 작성한다
1. **API 변경 시 Integration Test 필수** — Unit Test만으로 완료 선언 금지
2. **Error Case 포함 필수** — Happy Path만 테스트하고 완료 선언 금지
3. **Spec 10절 테스트 요구사항 반영** — Spec에 명시된 테스트 케이스를 누락하지 않음
4. **테스트 격리 유지** — 외부 서비스 mock 사용, 전역 상태 오염 방지
5. **테스트 파일 네이밍** — 프로젝트 설정의 패턴 규칙 준수
6. **모바일 E2E 포함 필수** — 프론트엔드 변경 시 Playwright 모바일 디바이스(iPhone/Pixel) 프로젝트에서도 E2E 실행. Unity 게임 프로젝트는 면제
7. **버그 스킵 금지** — 기능 버그를 `test.skip()` (TS) 또는 `[Ignore]` (C#)으로 숨기지 않는다. 환경 의존성만 skip 허용

## Lead 검증 규칙

Lead는 Check 3.5T 결과를 기반으로 판단한다:

1. **PASS**: 8축 모두 통과 → 다음 단계 진행
2. **WARN**: T-3, T-4, T-6에서 Warning → Lead 판단으로 진행 가능
3. **FAIL**: T-1, T-2 또는 T-7에서 Critical 실패 → 자동 수정 또는 [STOP]

## autoFix 규칙

- Check 3 ↔ 3.5 ↔ 3.5T 순환 카운터는 **합산 3회** 제한 (기존 autoFix 카운터 공유)
- T-1/T-2/T-3: 누락 테스트 스켈레톤 자동 생성 가능
- T-4: mock 전환, cleanup 코드 추가 가능
- T-5: 자동 수정 불가 → Lead 판단 ([STOP] 또는 override)
