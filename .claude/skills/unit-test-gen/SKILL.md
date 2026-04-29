---
name: unit-test-gen
description: 소스 코드에서 유닛 테스트를 자동 생성한다. 함수/클래스/메서드를 분석해 Jest(TS/JS), pytest(Python), NUnit/xUnit(C#), JUnit(Java) 테스트 파일을 생성. 테스트 없는 파일 발견 시 자동 제안. /qa 또는 SDD 구현 완료 후 테스트 미존재 시 자동 트리거. 직접 호출: /unit-test-gen <file-or-dir>
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
- 테스트 실행 FAIL → 실패 케이스 수정 1회 시도 후 보고
- 프레임워크 감지 불가 → "테스트 프레임워크 미감지 — package.json 또는 requirements.txt 확인" 출력
