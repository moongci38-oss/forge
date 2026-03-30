# Check 3.8: 보안 검수 게이트 (Subagent 전용)

> 이 Prompt는 Check 3.8 Subagent에만 주입. 메인 세션 Rules에 포함하지 않음.

## 검증 영역

### 1. 보안 정적 분석 (프로젝트별 스크립트)

프로젝트 검증 스크립트 실행 (예: `verify.sh security`).

**100% 코드 판정 (AI 판단 없음):**

| 검사 항목 | FAIL 조건 |
|-----------|----------|
| 하드코딩 크레덴셜 | password, secret, apikey 등 리터럴 |
| `.env` git 추적 | `.env` 파일이 git에 포함 |
| SQL Injection | raw query + 문자열 연결 |
| XSS | 위험한 HTML 삽입 (프레임워크별 패턴) |
| CORS 와일드카드 | `origin: '*'` 프로덕션 사용 |

### 2. OWASP Top 10 패턴 매칭

| 취약점 | 탐지 패턴 |
|--------|----------|
| A01:Broken Access Control | 인증 없는 API 엔드포인트 |
| A02:Cryptographic Failures | MD5/SHA1 사용, 약한 암호화 |
| A03:Injection | SQL/NoSQL/Command injection |
| A07:Auth Failures | JWT 하드코딩, 토큰 미만료 |

### 3. OWASP API Security Top 10 (2023) 강화 검증

OWASP API Security Top 10 (2023) 기준으로 추가 검증한다.

#### API3: Broken Object Property Level Authorization

DTO/Entity에서 민감 필드가 응답에 노출되지 않는지 검증한다.

| 검사 항목 | FAIL 조건 |
|-----------|----------|
| `@Exclude()` 누락 | Entity의 `password`, `hashedPassword`, `refreshToken` 등 민감 필드에 `@Exclude()` 미적용 |
| ClassSerializerInterceptor 부재 | 글로벌 또는 모듈 레벨에서 `ClassSerializerInterceptor` 미등록 |
| DTO 응답 분리 | Entity를 직접 반환하고 별도 Response DTO 없음 |

**탐지 방법:**
1. `*.entity.ts`에서 `password`, `secret`, `token`, `hash` 패턴 필드 탐색
2. 해당 필드에 `@Exclude()` 데코레이터 존재 여부 확인
3. Controller에서 Entity 직접 반환 vs Response DTO 사용 여부 확인

#### API4: Unrestricted Resource Consumption

`trine-performance.md` 룰의 Rate Limiting/DTO 크기 제한과 연동하여 검증한다.

| 검사 항목 | FAIL 조건 |
|-----------|----------|
| `@Throttle()` 누락 | 인증/결제 등 민감 엔드포인트에 `@Throttle()` 미적용 |
| `@SkipThrottle()` 오용 | 공개 엔드포인트에 `@SkipThrottle()` 적용 |
| Payload 크기 미제한 | Express body-parser 크기 제한 미설정 (`limit` 옵션 없음) |

#### API9: Improper Inventory Management

미사용/레거시 엔드포인트를 감지한다.

| 검사 항목 | WARN 조건 |
|-----------|----------|
| 레거시 경로 | `/v1/` 경로와 `/v2/` 경로가 동시 존재 (구버전 미폐기) |
| 미사용 Controller | Controller에 등록된 라우트 중 테스트/문서에 언급 없는 엔드포인트 |
| Debug 엔드포인트 | `/debug`, `/test`, `/internal` 경로가 프로덕션 코드에 존재 |

### 4. 의존성 CVE 스캔

프로젝트 패키지 매니저의 audit 명령 실행.

## 보안 에스컬레이션 레벨

| 레벨 | 조건 | 행동 |
|------|------|------|
| Level 1 | WARN 항목만 | 자동 수정 가능 |
| Level 2 | FAIL 1~2건 | 자동 수정 + 재검증 |
| Level 3 | FAIL 3건+ 또는 critical CVE | [STOP] Human 승인 필수 |

## 결과 반환 형식 (JSON)

```json
{
  "checkId": "check-3.8",
  "status": "PASS|WARN|FAIL",
  "secrets": { "found": 0, "items": [] },
  "injection": { "sql": 0, "xss": 0, "items": [] },
  "owasp": { "violations": [] },
  "dependencies": { "critical": 0, "high": 0 },
  "escalationLevel": 1,
  "summary": "",
  "autoFixable": false
}
```
