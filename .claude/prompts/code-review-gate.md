# Check 3.7: 코드 검수 게이트 (Subagent 전용)

> 이 Prompt는 Check 3.7 Subagent에만 주입. 메인 세션 Rules에 포함하지 않음.

## 검증 영역

### 1. 정적 코드 분석 (프로젝트별 스크립트)

프로젝트 검증 스크립트 실행 (예: `verify.sh quality`).

**공통 FAIL 조건:**

| 검사 항목 | FAIL 조건 |
|-----------|----------|
| Spec 범위 외 변경 | Spec에 명시되지 않은 파일 수정 |
| 코드 중복 | 동일 로직 3회+ 반복 |
| 미사용 코드 | import/변수/함수 미사용 |

### 2. AI 판단 영역

| 검사 항목 | 판단 기준 |
|-----------|----------|
| 아키텍처 적절성 | 레이어 분리, 의존성 방향 |
| 네이밍 의미 적절성 | 함수/변수명이 역할을 정확히 반영 |
| 에러 핸들링 충분성 | try-catch 누락, 에러 무시 |
| 성능 안티패턴 | N+1 쿼리, 불필요한 리렌더, 메모리 누수 |

### 3. 복잡도 지표

| 지표 | 경고 기준 | FAIL 기준 |
|------|----------|----------|
| Cyclomatic Complexity | 15+ (WARN) | 25+ (FAIL) |
| Cognitive Complexity | 20+ (WARN) | 35+ (FAIL) |
| 함수 길이 | 50줄+ (WARN) | 100줄+ (FAIL) |

### 4. 보안 적대적 검토 (OWASP Top 10 2025 기반)

각 항목을 코드에서 직접 추적하여 취약 경로를 명시한다. 존재하면 FAIL.

| 취약점 | 검사 포인트 |
|--------|-----------|
| **Injection** (SQL/Command/LDAP/XSS) | 외부 입력이 쿼리·명령·HTML에 직접 삽입되는 경로 |
| **Broken Access Control** | API 엔드포인트에서 소유권 검증(ownership check) 누락 |
| **인증·인가 우회** | JWT 알고리즘 none 허용, 세션 고정, 권한 검사 순서 오류 |
| **Cryptographic Failure** | 평문 비밀번호/토큰 저장, MD5/SHA1 사용, 하드코딩 secret |
| **Security Misconfiguration** | 디버그 모드 ON, 스택 트레이스 노출, CORS wildcard |
| **Supply Chain** | 신규 의존성 추가 시 출처·버전 고정 여부, typosquatting 유사 패키지명 |
| **민감 데이터 로그 노출** | password/token/PII가 로그·응답에 포함되는 경로 |
| **Mishandling Exceptional Conditions** (OWASP 2025 신규) | panic/crash 유발 입력, 오버플로우, 예외 무시 후 상태 오염 |

### 5. 동시성 & 메모리

| 검사 항목 | FAIL 조건 |
|-----------|----------|
| **Race Condition** | 공유 상태에 락 없이 동시 읽기·쓰기, check-then-act 패턴 |
| **Deadlock 위험** | 락 획득 순서 불일치, 중첩 lock |
| **리소스 누수** | DB 커넥션·파일 핸들·스트림 — 에러 경로에서 close 누락 |
| **버퍼 한도 없음** | 캐시·큐·리스트에 최대 크기 미설정 → OOM 가능 |
| **트랜잭션 원자성** | 부분 실패 시 롤백 미보장 |

### 6. API & 비즈니스 로직 무결성

| 검사 항목 | 판단 기준 |
|-----------|----------|
| **직접 객체 참조** | URL 파라미터로 타인 리소스 접근 가능 여부 |
| **비즈니스 룰 우회** | 할인·포인트·한도 로직을 API 직접 호출로 우회 가능한지 |
| **요청 한도** | rate limit·결제·발송 횟수 제한 없는 반복 가능 경로 |
| **멱등성** | POST 중복 호출 시 중복 처리(결제·발송 이중 실행) 여부 |
| **에러 응답 정보 노출** | 500 에러에 내부 스택·DB 구조 노출 |


## 결과 반환 형식 (JSON)

```json
{
  "checkId": "check-3.7",
  "status": "PASS|WARN|FAIL",
  "issues": [
    { "file": "", "line": 0, "rule": "", "severity": "error|warning", "autoFixable": false }
  ],
  "complexity": { "max": 0, "average": 0, "hotspots": [] },
  "outOfScope": [],
  "summary": "",
  "autoFixable": false
}
```
