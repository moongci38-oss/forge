---
name: api-e2e
description: REST API 엔드포인트 HTTP 레벨 E2E 자동 테스트. Spec 또는 OpenAPI(Swagger) YAML/JSON을 읽어 엔드포인트별 테스트 케이스(happy path/인증 실패/잘못된 입력/경계값)를 자동 생성하고 curl로 실행한다. 응답 스키마를 OpenAPI 스펙과 대조해 드리프트를 감지한다. /qa 스킬이 서버/API 프로젝트 감지 시 자동 트리거. 직접 호출: /api-e2e <spec-path> [--base-url http://localhost:3000]
user-invocable: true
context: fork
model: sonnet
---

# api-e2e — REST API E2E 자동 테스트

Spec 또는 OpenAPI 문서에서 엔드포인트를 추출하고 HTTP 레벨로 자동 검증한다.

## 입력

```
/api-e2e <spec-path> [--base-url <URL>] [--auth <token>]
```

- `spec-path`: Spec.md 또는 OpenAPI YAML/JSON 경로
- `--base-url`: 테스트 대상 서버 URL (기본: `http://localhost:3000`)
- `--auth`: Bearer 토큰 (없으면 인증 없이 실행 후 401 검증)

## 실행 흐름

### Step 1: 엔드포인트 추출

Spec.md에서 `## API` 섹션 또는 OpenAPI `paths` 키를 파싱.
각 엔드포인트별로 다음 추출:
- HTTP 메서드 + 경로
- Request body schema (있으면)
- Expected response status codes
- **Response body schema** (OpenAPI `responses.*.content.application/json.schema`)

### Step 2: 테스트 케이스 생성

엔드포인트당 4종 생성:

| 케이스 | 내용 |
|--------|------|
| **happy path** | 유효한 입력 → 200/201 기대 |
| **인증 실패** | 토큰 없음/잘못된 토큰 → 401 기대 |
| **잘못된 입력** | 필수 필드 누락 또는 타입 불일치 → 400 기대 |
| **경계값** | 빈 문자열, 최대 길이 초과, 음수 ID → 400/404 기대 |

### Step 3: curl 실행

각 케이스를 순서대로 실행:
```bash
curl -s -o /tmp/api-e2e-resp.json -w "%{http_code} %{time_total}" \
  -X {METHOD} {BASE_URL}{PATH} \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {TOKEN}" \
  -d '{REQUEST_BODY}'
```

결과 기록:
- 실제 status code vs 기대 status code
- 응답 시간 (`time_total`)
- 응답 body (실패 시 diff 출력)

### Step 4: 스키마 검증 (OpenAPI 입력 시)

OpenAPI 스펙이 입력된 경우, happy path 응답 body를 스펙의 response schema와 대조:

| 검사 항목 | 판단 기준 |
|----------|----------|
| **필수 필드 존재** | `required` 배열의 모든 필드가 응답에 존재하는지 |
| **타입 일치** | 각 필드의 타입이 schema 정의(`string/number/boolean/array/object`)와 일치하는지 |
| **미정의 필드** | 스펙에 없는 필드가 응답에 추가됐는지 (드리프트 경고) |

드리프트 감지 시:
- `WARN: schema-drift` — 스펙에 없는 응답 필드 (내부 데이터 노출 가능성)
- `WARN: schema-missing` — 스펙에 있지만 응답에 없는 필드

> 스키마 검증은 OpenAPI 입력 시만 수행. Spec.md 입력 시 Step 4 스킵.

### Step 5: 리포트 저장

```
forge-outputs/docs/qa/YYYY-MM-DD-{spec-name}-api-e2e-report.md
```

## 리포트 형식

```markdown
# API E2E 테스트 결과: {spec-name}
- 실행 일시: YYYY-MM-DD HH:mm
- Base URL: {url}
- 총 케이스: N | PASS: N | FAIL: N | WARN: N

## 결과 요약

| 엔드포인트 | 케이스 | 기대 | 실제 | 결과 | 응답시간 |
|-----------|--------|------|------|:----:|--------|
| POST /auth/login | happy path | 200 | 200 | ✅ | 45ms |
| POST /auth/login | 인증 실패 | 401 | 401 | ✅ | 12ms |
| GET /users/:id | happy path | 200 | 404 | ❌ | 8ms |

## 스키마 드리프트 경고 (OpenAPI 입력 시)

| 엔드포인트 | 유형 | 상세 |
|-----------|------|------|
| GET /users/:id | schema-drift | 응답에 `internalId` 필드 존재 (스펙 미정의) |

## FAIL 상세

### GET /users/:id — happy path
- 기대: 200
- 실제: 404
- Response body:
  ```json
  {"error": "User not found"}
  ```
```

## 종료 조건

- 전 케이스 PASS → `/qa`로 PASS 결과 반환
- FAIL 존재 → FAIL 상세 + 수정 제안 후 `/qa`에 FAIL 반환
- WARN(스키마 드리프트)만 존재 → WARN 상태로 반환 (FAIL 아님)
- 서버 연결 불가 → "서버 미응답 — base-url 확인" 출력 후 SKIP

## /qa 파이프라인 연동

`/qa` 실행 시 프로젝트 타입이 `server/API`이면 자동 호출:
```
프로젝트 판단 기준: package.json에 express/nestjs/fastify/koa 또는 build.gradle에 spring 포함
```
