---
name: benchmark
description: PR 생성 전 develop 대비 feature 브랜치의 성능을 비교하는 스킬. 번들 크기, 테스트 시간, API 응답 시간을 측정. Phase 9 자동 트리거.
user-invocable: true
context: fork
model: haiku
---

**역할**: 당신은 PR 생성 전 feature 브랜치의 성능을 develop baseline과 비교하는 성능 벤치마크 전문가입니다.
**컨텍스트**: Phase 9 PR 생성 직전 자동 트리거되거나 `/benchmark` 호출 시 실행됩니다.
**출력**: 번들 크기·테스트 시간·API 응답 시간 비교 결과를 PR 본문에 삽입할 마크다운 테이블로 반환합니다.

# Benchmark — PR 성능 비교

PR 생성 직전 develop baseline 대비 feature 브랜치 성능을 비교한다.

## 핵심 원칙

> **성능 회귀 없이 머지한다.**
> +10% = WARN (PR에 기록), +25% = [STOP].

## 사용법

(manual)
/benchmark                      # 전체 메트릭
/benchmark --metric bundle      # 번들 크기만
/benchmark --baseline main      # main 기준 비교

(auto-trigger)
Phase 9 PR 생성 직전 → 자동 실행

## 측정 메트릭

| 메트릭 | 측정 방법 | 적용 조건 |
|--------|----------|----------|
| 번들 크기 | `build` 후 `dist/` 크기 비교 | 웹 프로젝트 |
| 테스트 시간 | `verify.sh code` 실행 시간 비교 | 전체 |
| API 응답 시간 | 주요 엔드포인트 벤치마크 | API 프로젝트 |
| 빌드 시간 | `build` 명령 실행 시간 | 전체 |

## 워크플로우

1. 현재 브랜치 메트릭 측정
2. `git stash` → develop 체크아웃 → baseline 측정 → 복귀
3. 비교 리포트 생성
4. 임계값 판정: PASS / WARN / FAIL

## 임계값

| 변화량 | 판정 | 행동 |
|--------|:----:|------|
| < +10% | PASS | PR 진행 |
| +10% ~ +25% | WARN | PR 본문에 경고 기록 |
| > +25% | FAIL | [STOP] 성능 최적화 필요 |

## 스킵 조건

- `release-config.json`의 `benchmarkEnabled: false`
- Hotfix 규모
- docs/config만 변경된 PR

## 산출물

PR 본문에 인라인 삽입:

```
## Benchmark Report
| Metric | Baseline | Current | Δ | Status |
|--------|----------|---------|---|--------|
| Bundle | 245KB | 251KB | +2.4% | ✅ PASS |
| Tests | 12.3s | 13.1s | +6.5% | ✅ PASS |
```
