---
name: load-test
description: k6 기반 부하 테스트 시나리오 자동 생성·실행. API 엔드포인트 또는 Spec을 입력받아 k6 스크립트를 생성하고 VU/RPS/duration 설정 후 실행. p95/p99 응답시간, 에러율, TPS 결과 리포트 저장. 성능 테스트, 부하 테스트, stress test가 필요할 때 사용. /api-e2e PASS 후 선택적 실행.
user-invocable: true
context: fork
model: sonnet
---

# load-test — k6 부하 테스트

API 엔드포인트에 대한 부하 테스트 시나리오를 생성하고 k6로 실행한다.

## 사전 요구사항

```bash
k6 --version  # k6 설치 확인
# 미설치 시: sudo apt install k6 또는 brew install k6
```

## 입력

```
/load-test <spec-path 또는 endpoint-list> [--vus 10] [--duration 30s] [--rps 0] [--ramp] [--base-url http://localhost:3000]
```

| 옵션 | 기본값 | 설명 |
|------|--------|------|
| `--vus` | 10 | 동시 가상 유저 수 (`--rps` 미지정 시 사용) |
| `--duration` | 30s | 테스트 지속 시간 |
| `--rps` | 0 | 초당 고정 요청 수 (0=미사용). 지정 시 `constant-arrival-rate` 실행자 사용 |
| `--ramp` | false | true 시 0→vus→0 ramp-up 패턴 |
| `--threshold-p95` | 500ms | p95 응답시간 임계값 |
| `--threshold-error` | 1% | 에러율 임계값 |

## 실행자 선택 기준

| 목적 | 실행자 | 옵션 |
|------|--------|------|
| **기능 부하** — 기본 동시성 검증, CI/CD per-commit | `shared-iterations` | `--vus` |
| **SLA/용량** — 고정 RPS에서 지연시간 보장 확인 | `constant-arrival-rate` | `--rps` |
| **스트레스/Ramp** — 한계점 탐색 | `ramping-vus` | `--ramp` |

> `constant-arrival-rate`는 서버가 느려져도 RPS를 일정하게 유지한다.
> 실서비스 SLA("100 RPS에서 p95 < 200ms") 검증에 적합.

## 실행 주기 권장

| 시나리오 유형 | 권장 주기 |
|-------------|---------|
| 단순 API 단위 부하 (--vus, 30s) | per-commit (CI 연동 가능) |
| 시나리오 부하 (--ramp, 5m+) | 일 1회 (야간 스케줄) |
| SLA 검증 (--rps) | 릴리즈 전 또는 주 1회 |

## 실행 흐름

### Step 1: 시나리오 생성

Spec에서 주요 엔드포인트 추출 (최대 5개 — 핵심 경로 우선).

파일: `/tmp/k6-{spec-name}-{timestamp}.js`

**기본 VU 모드** (`--rps` 미지정):
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: VUS,
  duration: 'DURATION',
  thresholds: {
    http_req_duration: ['p(95)<THRESHOLD_P95'],
    http_req_failed: ['rate<THRESHOLD_ERROR'],
  },
};

export default function () {
  const res = http.post('BASE_URL/api/endpoint', JSON.stringify({}), {
    headers: { 'Content-Type': 'application/json' },
  });
  check(res, { 'status 200': (r) => r.status === 200 });
  sleep(1);
}
```

**constant-arrival-rate 모드** (`--rps N` 지정):
```javascript
export const options = {
  scenarios: {
    constant_load: {
      executor: 'constant-arrival-rate',
      rate: RPS,
      timeUnit: '1s',
      duration: 'DURATION',
      preAllocatedVUs: Math.ceil(RPS * 1.5),
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<THRESHOLD_P95'],
    http_req_failed: ['rate<THRESHOLD_ERROR'],
  },
};
```

**ramping-vus 모드** (`--ramp` 지정):
```javascript
export const options = {
  stages: [
    { duration: '1m', target: VUS },   // ramp-up
    { duration: '3m', target: VUS },   // steady
    { duration: '1m', target: 0 },     // ramp-down
  ],
  thresholds: {
    http_req_duration: ['p(95)<THRESHOLD_P95'],
    http_req_failed: ['rate<THRESHOLD_ERROR'],
  },
};
```

### Step 2: k6 실행

```bash
k6 run --out json=/tmp/k6-results.json /tmp/k6-{spec-name}-{timestamp}.js
```

### Step 3: 결과 파싱 + 리포트

`/tmp/k6-results.json` 파싱하여 주요 지표 추출.

리포트 저장: `forge-outputs/docs/qa/YYYY-MM-DD-{spec-name}-load-report.md`

## 리포트 형식

```markdown
# 부하 테스트 결과: {spec-name}
- 실행: YYYY-MM-DD HH:mm | 실행자: {executor} | VUs/RPS: {N} | Duration: {T}

## 핵심 지표

| 지표 | 결과 | 임계값 | 판정 |
|------|------|--------|:----:|
| p95 응답시간 | 234ms | <500ms | ✅ |
| p99 응답시간 | 891ms | — | — |
| 에러율 | 0.3% | <1% | ✅ |
| TPS (req/s) | 87.4 | — | — |
| 총 요청 수 | 26,220 | — | — |

## 판정: PASS / FAIL

## 임계값 초과 항목 (FAIL 시)
- p95 응답시간 {실제}ms > {임계값}ms — 병목 예상 엔드포인트: {경로}
```

## 종료 조건

- 모든 임계값 PASS → PASS 반환
- 임계값 초과 → FAIL + 병목 엔드포인트 명시
- k6 미설치 → "k6 미설치 — `sudo apt install k6` 실행 후 재시도" 출력 후 SKIP
