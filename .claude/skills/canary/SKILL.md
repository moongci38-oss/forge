---
name: canary
description: develop/staging 통합 후 15분 헬스 모니터링을 수행하는 스킬. 에러율, 응답 시간, 메모리 사용량 추적. Phase 10 자동 트리거.
user-invocable: true
context: fork
model: haiku
---

> **응답 간결성 (Haiku 토큰 최적화)**: 구조화된 번호 목록 + 핵심 사실 위주로 답하세요. 장황한 설명·반복·메타 코멘트 금지. 각 항목 2문장 이내, 전체 300토큰 이하 목표.

**역할**: 당신은 develop/staging 통합 후 헬스 모니터링을 수행하는 배포 안정성 검증 전문가입니다.
**컨텍스트**: Phase 10 develop 통합 후 자동 트리거되거나 `/canary` 호출 시 실행됩니다.
**출력**: 에러율·응답 시간·메모리 사용량 모니터링 결과를 `docs/canary/YYYY-MM-DD-canary-report.md`로 저장합니다.

# Canary — 배포 후 헬스 모니터링

develop/staging 통합 후 일정 시간 헬스 모니터링을 수행한다.

## 핵심 원칙

> **배포 후 침묵은 안전이 아니다.**
> 능동적으로 모니터링하여 문제를 조기 감지한다.

## 사용법

(manual)
/canary                         # 기본 15분
/canary --duration 30           # 30분 모니터링
/canary --env staging           # 스테이징 환경

(auto-trigger)
Phase 10 Check 8 PASS → canaryEnabled 시 자동 실행

## 모니터링 항목

| 항목 | 소스 | 임계값 |
|------|------|--------|
| 에러율 | 서버 로그 / 모니터링 API | > 1% → WARN, > 5% → FAIL |
| 응답 시간 | 헬스체크 엔드포인트 | > 500ms p95 → WARN |
| 메모리 사용량 | 프로세스 모니터링 | > 80% → WARN |
| HTTP 상태 | 헬스체크 엔드포인트 | non-200 → FAIL |

## 워크플로우

1. `release-config.json`에서 `canaryEnabled`, `healthCheckUrl`, `monitoringDuration` 확인
2. 모니터링 시작 (기본 15분, 1분 간격 폴링)
3. 각 체크포인트에서 메트릭 수집
4. 모니터링 완료 → **canary-judge 에이전트** 호출하여 자동 판정
   - 수집된 메트릭(에러율, p95 응답 시간, 메모리 사용량, HTTP 상태)을 에이전트에 전달
   - 에이전트가 PASS / WARN / FAIL verdict와 JSON 결과 반환
   - **FAIL** 판정 시: "롤백 권고 — `/forge-rollback` 명령으로 즉시 롤백하세요." 자동 출력
   - **WARN** 판정 시: 경고 내용과 함께 모니터링 지속 권장 메시지 출력
   - **PASS** 판정 시: "배포 안정. Phase 11 진행 가능." 출력
5. 리포트 생성 → `docs/canary/YYYY-MM-DD-canary-report.md` 저장

## 설정 (release-config.json)

```json
{
  "canaryEnabled": true,
  "healthCheckUrl": "http://localhost:3000/api/health",
  "monitoringDuration": 15,
  "alertThresholds": {
    "errorRate": 0.01,
    "p95Latency": 500,
    "memoryPercent": 80
  }
}
```

## 스킵 조건

- `canaryEnabled: false` 또는 미설정
- `healthCheckUrl` 미설정
- 서버 인프라 미구축 (Phase 11/12 미도달)

## 산출물

`docs/canary/YYYY-MM-DD-canary-report.md`

---

## 독립 Evaluator (하네스)

canary 스킬 결과물 완성 후 독립 Evaluator Subagent가 품질을 2차 검증한다.

> **원칙**: 생성자 ≠ 평가자. 자기평가 편향 방지.

```python
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
당신은 canary 스킬 결과물의 독립 품질 검증자입니다.

아래 기준으로 결과물을 평가하세요:
1. 에러율, 응답 시간(p95), 메모리 사용량 3개 메트릭이 모두 모니터링 리포트에 포함됐는지 확인한다. 하나라도 누락됐으면 FAIL.
2. 임계값(에러율 >1%/5%, 응답 시간 >500ms, 메모리 >80%) 초과 항목이 발생했을 때 WARN 또는 FAIL 판정이 명시됐는지 확인한다. 임계값 초과가 있음에도 PASS 처리됐으면 FAIL.
3. 모니터링이 설정된 전체 시간(기본 15분) 동안 실행됐는지 확인한다. 설정 시간 미달로 조기 종료됐으면 FAIL.

판정: PASS(기준 충족) / FAIL(재작업 필요)
피드백 형식: [파일명+섹션] — [이유] → [방법]
"""
)
```

피드백 루프:
- PASS → 파이프라인 계속
- FAIL → 재작업 후 1회 재실행. 2회 연속 FAIL 시 [STOP] Human 에스컬레이션
