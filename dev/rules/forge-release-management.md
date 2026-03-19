---
title: "릴리즈 관리 규칙"
id: forge-release-management
impact: MEDIUM
scope: [forge]
tags: [release, versioning, rollback, deployment, feature-flag, changelog]
requires: []
section: forge-process
---

# Release Management Rules

> 배포 전략, 버저닝, 롤백 절차를 표준화한다.

## 시맨틱 버저닝

```text
[필수] SemVer 2.0.0 준수: MAJOR.MINOR.PATCH
[필수] Breaking Change → MAJOR 증가
[필수] 새 기능 (하위 호환) → MINOR 증가
[필수] 버그 수정 → PATCH 증가
[권장] Pre-release: 1.0.0-beta.1, 1.0.0-rc.1
```

## 릴리즈 체크리스트

PR merge 후 릴리즈 전 확인:

```text
[필수] 모든 CI 체크 통과
[필수] CHANGELOG.md 업데이트 (Keep a Changelog 형식)
[필수] 마이그레이션 파일 존재 (DB 변경 시)
[필수] 환경 변수 추가 시 .env.example 업데이트
[권장] 스테이징 환경에서 스모크 테스트 완료
```

## 배포 전략

### 기본: Rolling Update

```text
[필수] 무중단 배포 (zero-downtime)
[필수] 헬스체크 통과 후 트래픽 전환
[필수] 이전 버전과 DB 스키마 호환 유지 (마이그레이션 2단계)
```

### 롤백 절차

```text
[필수] 이전 버전으로 즉시 롤백 가능한 상태 유지
[필수] 롤백 시 마이그레이션 down() 실행 가능 확인
[금지] 롤백 불가능한 마이그레이션을 단일 릴리즈에 포함
```

## 환경 변수 관리

```text
[필수] 새 환경 변수 추가 시 .env.example에 반영
[필수] 환경 변수에 적절한 기본값 또는 필수 표시
[필수] ConfigService를 통한 접근 (process.env 직접 접근 금지)
[금지] 환경 변수에 비밀 정보 기본값 설정
```

## Feature Flag (권장)

```text
[권장] 대규모 기능은 Feature Flag로 점진적 릴리즈
[권장] Flag 관리: 환경 변수 또는 DB 기반 설정
[권장] Flag 제거 일정을 릴리즈 노트에 명시
```

## AI SLO (Service Level Objectives)

AI 파이프라인의 품질 기준선:

| 지표 | SLO | 측정 방법 |
|------|-----|---------|
| Check 3.5 FR 커버리지 | ≥ 95% | Spec FR 대비 구현 매칭률 |
| autoFix 성공률 | ≥ 70% | 1회 autoFix로 Check 통과 비율 |
| Phase 1→4 완료율 | ≥ 90% | [STOP] 없이 Phase 4까지 도달 비율 |
| PR 리뷰 코멘트 0건 비율 | ≥ 60% | 첫 PR에서 리뷰 코멘트 없이 통과 |

## AI 인시던트 분류

AI 파이프라인에서 발생할 수 있는 인시던트 4유형:

| 유형 | 코드 | 설명 | 대응 |
|------|------|------|------|
| 침묵 실패 | `SILENT_FAIL` | Check가 PASS를 반환했으나 실제 결함 미탐지 | Check 룰 보강 + 회고 |
| 프롬프트 드리프트 | `PROMPT_DRIFT` | 규칙 변경 후 AI 행동이 기대와 불일치 | 규칙 텍스트 검증 + 테스트 세션 |
| 에이전트 루프 | `AGENT_LOOP` | autoFix/Check 무한 반복 또는 동일 오류 재발 | check3CycleCount 확인 + [STOP] |
| 정책 위반 | `POLICY_VIOLATION` | 보안/접근 제한/게이트 규칙 위반 | 즉시 [STOP] + 원인 분석 + 규칙 강화 |

## AI 에이전트 행동 규칙

1. 새 환경 변수 추가 시 .env.example 업데이트를 확인한다
2. Breaking Change 포함 시 MAJOR 버전 증가를 제안한다
3. 마이그레이션이 롤백 불가능하면 경고한다
4. CHANGELOG.md 갱신 누락을 감지하면 알린다
5. AI 인시던트 발생 시 해당 유형 코드를 gate-log 또는 세션 보고에 기록한다

---

*Last Updated: 2026-03-08*
