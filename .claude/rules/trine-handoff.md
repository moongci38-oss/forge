# SIGIL → Trine 전환 규칙

## 전환 조건

Trine 진입은 아래 **모든 조건**을 충족해야 한다:

1. SIGIL S4 Gate가 `✅ PASS`로 기록됨 (`gate-log.md`)
2. S4 필수 산출물 7종이 존재함
3. Human이 Trine 진입을 승인함

## Handoff 문서 구조

S4 완료 시 자동 생성하는 Handoff 문서:

- **경로**: `10-operations/handoff-to-dev/{project}/YYYY-MM-DD-sigil-handoff.md`
- **역할**: SIGIL(설계) → Trine(구현) 간 정보 전달 공식 문서
- **내용**: 산출물 인덱스, 기술 스택, 세션 로드맵, 개발 환경, ADR 요약, 우선순위

## SIGIL 산출물 → Trine 매핑

| SIGIL 산출물 | Trine 활용 시점 | 용도 |
|-------------|----------------|------|
| S1 리서치 | Phase 1 | 프로젝트 컨텍스트 이해 |
| S3 기획서 (PRD/GDD) | Phase 1.5 요구사항 분석 | 기능/비기능 요구사항 추출 |
| S4 상세 기획서 | Phase 2 Spec 작성 | 화면별 동작, 데이터 흐름 참조 |
| S4 사이트맵 | Phase 2 Spec 작성 | 네비게이션 흐름 참조 |
| S4 로드맵 | 세션 우선순위 결정 | Now/Next/Later 참조 |
| S4 개발 계획 | Phase 1 세션 이해 | 기술 스택, ADR, Trine 세션 로드맵 |
| S4 WBS | 세션 범위 설정 | 태스크별 규모 참조 |
| S4 UI/UX 기획서 | Phase 2 Spec UI 섹션 | 와이어프레임, 인터랙션 참조 |
| S4 테스트 전략서 | Phase 3 Check | 테스트 계층, 도구, 커버리지 목표 |

## 프로젝트 유형별 Trine 대상

| 프로젝트 유형 | Trine 대상 환경 | 비고 |
|-------------|---------------|------|
| 게임 (Unity) | GodBlade 또는 별도 Unity 프로젝트 | C# 개발 |
| 웹 서비스 | Portfolio (Next.js + NestJS) | TypeScript 개발 |
| 앱 개발 | 별도 앱 프로젝트 | 프레임워크에 따라 |

## Handoff 후 워크플로우

```
SIGIL S4 완료
    ↓
/trine 커맨드 실행 (BUSINESS 환경)
    ↓
Handoff 문서 자동 생성 (10-operations/handoff-to-dev/{project}/)
    ↓
개발 프로젝트 환경으로 이동 (Human)
    ↓
Trine Session 1부터 순차 진행
    ├─ Spec 작성 (S4 산출물 참조)
    ├─ Plan 작성
    ├─ 구현 + AI Check
    ├─ Walkthrough
    └─ PR
```

## 관리자 산출물 포함 규칙

S3 기획서에 관리자 기능이 포함된 경우, Handoff 문서에 관리자 산출물도 포함:
- 관리자 상세 기획서
- 관리자 사이트맵
- 관리자 UI/UX 기획서
