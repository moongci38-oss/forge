---
name: load-test
description: k6 기반 부하 테스트 시나리오 자동 생성·실행. API 엔드포인트 또는 Spec을 입력받아 k6 스크립트를 생성하고 VU/duration 설정 후 실행. p95/p99 응답시간, 에러율, TPS 결과 리포트 저장. 성능 테스트, 부하 테스트, stress test가 필요할 때 사용. /api-e2e PASS 후 선택적 실행.
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
/load-test <spec-path 또는 endpoint-list> [--vus 10] [--duration 30s] [--base-url http://localhost:3000]
```

| 옵션 | 기본값 | 설명 |
|------|--------|------|
| `--vus` | 10 | 동시 가상 유저 수 |
| `--duration` | 30s | 테스트 지속 시간 |
| `--ramp` | false | true 시 0→vus→0 ramp-up 패턴 |
| `--threshold-p95` | 500ms | p95 응답시간 임계값 |
| `--threshold-error` | 1% | 에러율 임계값 |

## 실행 흐름

### Step 1: 시나리오 생성

Spec에서 주요 엔드포인트 추출 (최대 5개 — 핵심 경로 우선).

`/tmp/k6-{spec-name}-{timestamp}.js` 생성:

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: {VUS},
  duration: '{DURATION}',
  thresholds: {
    http_req_duration: ['p(95)<{THRESHOLD_P95}'],
    http_req_failed: ['rate<{THRESHOLD_ERROR}'],
  },
};

export default function () {
  const res = http.post('{BASE_URL}/api/endpoint', JSON.stringify({...}), {
    headers: { 'Content-Type': 'application/json' },
  });
  check(res, { 'status 200': (r) => r.status === 200 });
  sleep(1);
}
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
- 실행: YYYY-MM-DD HH:mm | VUs: {N} | Duration: {T}

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
