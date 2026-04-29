---
name: unit-test-gen
description: 소스 코드에서 유닛 테스트를 자동 생성한다. 함수/클래스/메서드를 분석해 Jest(TS/JS), pytest(Python), NUnit/xUnit(C#), JUnit(Java) 테스트 파일을 생성. 뮤테이션 테스팅 점수를 품질 지표로 활용. 테스트 없는 파일 발견 시 자동 제안. /qa 또는 SDD 구현 완료 후 테스트 미존재 시 자동 트리거. 직접 호출: /unit-test-gen <file-or-dir>
user-invocable: true
context: fork
model: sonnet
---

# unit-test-gen — 유닛 테스트 자동 생성

소스 파일을 분석하여 프로젝트 테스트 프레임워크에 맞는 유닛 테스트를 생성한다.

## 입력

```
/unit-test-gen <파일 경로 또는 디렉토리>
```

단일 파일, 디렉토리, 또는 Glob 패턴 지원.

## 품질 지표: 커버리지 vs 뮤테이션 점수

> **커버리지는 허영 지표다.** 100% 커버리지이면서 뮤테이션 점수 4%인 테스트 스위트가 실제로 존재한다.
> 이 스킬은 뮤테이션 생존 케이스(live mutant)를 기반으로 테스트를 강화한다.

| 지표 | 역할 |
|------|------|
| Line/Branch Coverage | 최소 기준 (실행 여부만 검증) |
| **Mutation Score** | 실질 품질 지표 (버그 감지 능력 측정) |

**뮤테이션 점수 기준값:**

| 경로 유형 | 권장 뮤테이션 점수 |
|---------|---------------|
| 크리티컬 경로 (결제/인증/잠금) | 70%+ |
| 일반 비즈니스 로직 | 50%+ |
| 실험적/유틸 함수 | 30%+ |

## 실행 흐름

### Step 1: 프레임워크 감지

프로젝트 루트에서 테스트 프레임워크 자동 감지:

| 감지 조건 | 프레임워크 | 파일 접미사 |
|----------|-----------|-----------|
| `package.json`에 `jest` | Jest (TS/JS) | `.test.ts` / `.spec.ts` |
| `package.json`에 `vitest` | Vitest | `.test.ts` |
| `requirements.txt`에 `pytest` | pytest | `test_{name}.py` |
| `.csproj`에 `xunit` / `nunit` | xUnit/NUnit | `{Name}Tests.cs` |
| `build.gradle`에 `junit` | JUnit 5 | `{Name}Test.java` |

### Step 2: 기존 테스트 확인

대상 파일에 대응하는 테스트 파일이 이미 있으면:
- 커버리지 갭 분석 (테스트 없는 public 함수 목록)
- 갭 항목만 추가 생성

### Step 3: 소스 분석

대상 파일 Read → 다음 추출:
- public 함수/메서드 목록 + 시그니처
- 의존성 (import 목록 → mock 대상 식별)
- 에러 throw 경로
- 경계값 (null/undefined 처리, 최대/최소값)
- **크리티컬 경로 여부** (결제/인증/권한/데이터 무결성 관련 함수 → 뮤테이션 강화 대상)

### Step 4: 테스트 생성

각 함수당 최소 3개 케이스:
1. **happy path** — 정상 입력 → 기대 반환값
2. **edge case** — null/빈값/경계값 입력
3. **에러 케이스** — 예외 throw 또는 에러 반환

기존 테스트 파일 패턴 참고 (프로젝트 컨벤션 유지):
- describe/it 네이밍 컨벤션
- mock 방식 (jest.mock vs sinon vs unittest.mock)
- assertion 스타일

### Step 5: 파일 저장

| 위치 | 규칙 |
|------|------|
| 같은 디렉토리 | `{name}.test.ts` (Jest 기본) |
| `__tests__/` | 프로젝트가 이 구조 사용 시 |
| `tests/` | pytest 프로젝트 |

기존 파일 있으면 **덮어쓰기 금지** → 갭 항목만 append.

### Step 6: 뮤테이션 테스팅 (크리티컬 경로 한정)

크리티컬 경로 함수가 포함된 경우:

1. 뮤테이션 도구 감지:
   - JS/TS: `stryker` (`package.json`에 `@stryker-mutator/*` 존재 시)
   - Python: `mutmut` (`pip show mutmut` 성공 시)
   - 미설치 시 → Step 6 스킵, "뮤테이션 도구 미설치 — 선택적 설치 권장" 안내만

2. 뮤테이션 실행 (대상 파일만, 전체 스위트 아님):
   ```bash
   # Stryker
   npx stryker run --files {source-file},{test-file}

   # mutmut
   mutmut run --paths-to-mutate {source-file}
   ```

3. 생존 뮤턴트(live mutant) 확인:
   - 생존 뮤턴트 = 기존 테스트가 잡지 못한 버그 시뮬레이션
   - 생존 뮤턴트 목록을 추출하여 추가 테스트 케이스 자동 생성
   - 뮤테이션 점수 기준 미달 시 WARN 반환

## 출력 예시 (Jest/TypeScript)

```typescript
import { validateEmail } from './validators';

describe('validateEmail', () => {
  it('유효한 이메일 형식 → true 반환', () => {
    expect(validateEmail('user@example.com')).toBe(true);
  });

  it('빈 문자열 → false 반환', () => {
    expect(validateEmail('')).toBe(false);
  });

  it('@ 없는 문자열 → false 반환', () => {
    expect(validateEmail('notanemail')).toBe(false);
  });
});
```

## /qa 파이프라인 연동

SDD Phase 3 구현 완료 또는 `/qa` 실행 시:
- 변경된 소스 파일에 대응 테스트 파일 없으면 자동 호출
- 생성 후 `npm test` / `pytest` 실행하여 즉시 검증

## 종료 조건

- 테스트 파일 생성 + 테스트 실행 PASS → 완료
- 뮤테이션 점수 기준 미달 → WARN + 생존 뮤턴트 기반 추가 케이스 제안
- 테스트 실행 FAIL → 실패 케이스 수정 1회 시도 후 보고
- 프레임워크 감지 불가 → "테스트 프레임워크 미감지 — package.json 또는 requirements.txt 확인" 출력
