---
title: "SIGIL → Trine 전환"
id: trine-handoff
impact: HIGH
scope: [sigil, trine]
tags: [handoff, transition, trine]
requires: [sigil-s4-planning]
section: sigil-pipeline
audience: dev
impactDescription: "Handoff 문서 미생성 시 Trine에서 S4 산출물 참조 경로 불명 → 기획-개발 단절. 기술 스택/ADR 미전달 시 재의사결정 필요"
enforcement: rigid
---

# SIGIL → Trine 전환 규칙

## 경로 해석 규칙

모든 경로는 워크스페이스 루트의 `sigil-workspace.json`에서 해석한다.

```
경로 해석: {folderMap.product}/{project}/ → 실제 경로 (예: 02-product/projects/portfolio-admin/)
```

> `sigil-workspace.json`이 없으면 **[STOP]** — `sigil-init` 실행을 안내한다.

## 전환 조건

Trine 진입은 아래 **모든 조건**을 충족해야 한다:

1. SIGIL S4 Gate가 `PASS`로 기록됨 (`gate-log.md`)
2. S4 필수 산출물 4종이 존재함
3. Todo Tracker가 존재함 (`{folderMap.product}/{project}/YYYY-MM-DD-todo.md`)

## Handoff 문서 구조

S4 완료 시 자동 생성하는 Handoff 문서:

- **경로**: `{folderMap.handoff}/{project}/YYYY-MM-DD-sigil-handoff.md`
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

## Symlink 기반 문서 연동 (Source of Truth: SIGIL 워크스페이스)

**SIGIL 워크스페이스가 모든 기획/계획 문서의 유일한 원본**이다. 개발 프로젝트는 symlink로 참조만 한다.

### 원칙

- 기획서/개발계획서 수정은 반드시 SIGIL 워크스페이스에서 SIGIL 파이프라인을 통해 수행
- 개발 프로젝트의 `{symlinkBase}/` 폴더에 symlink를 생성 (`sigil-workspace.json`의 프로젝트별 설정)
- symlink이므로 SIGIL 워크스페이스에서 수정하면 개발 프로젝트에 자동 반영

### Symlink 대상 (전체 SIGIL 산출물)

| symlink 이름 | 원본 경로 (folderMap 기준) |
|-------------|--------------------------|
| `todo.md` | `{folderMap.product}/{project}/YYYY-MM-DD-todo.md` |
| `handoff.md` | `{folderMap.handoff}/{project}/YYYY-MM-DD-sigil-handoff.md` |
| `s3-prd.md` (또는 `s3-gdd.md`) | `{folderMap.product}/{project}/YYYY-MM-DD-s3-prd.md` |
| `s4-detailed-plan.md` | `{folderMap.product}/{project}/YYYY-MM-DD-s4-detailed-plan.md` |
| `s4-development-plan.md` | `{folderMap.product}/{project}/YYYY-MM-DD-s4-development-plan.md` |
| `s4-uiux-spec.md` | `{folderMap.design}/{project}/YYYY-MM-DD-s4-uiux-spec.md` |
| `s4-test-strategy.md` | `{folderMap.product}/{project}/YYYY-MM-DD-s4-test-strategy.md` |
| 관리자 산출물 (`s4-admin-*.md`) | 해당 원본 경로 (S3에 관리자 포함 시) |

### Symlink 생성 시점

- **신규 프로젝트**: Handoff 단계에서 개발 프로젝트 폴더 생성 + 전체 symlink 일괄 생성
- **기존 프로젝트**: S4 산출물 추가/변경 시 누락된 symlink만 추가

### Symlink 파일명 규칙

- 원본의 날짜 prefix(`YYYY-MM-DD-`)를 제거한 이름으로 symlink 생성
- 예: `2026-03-03-s4-roadmap.md` → symlink 이름 `s4-roadmap.md`

### 개발 프로젝트 매핑 (`sigil-workspace.json`)

```json
"projects": {
  "my-project": {
    "devTarget": "/path/to/dev/project",
    "symlinkBase": "docs/planning/active/sigil"
  }
}
```

- `devTarget`: 개발 프로젝트 절대 경로 (symlink 생성 대상)
- `symlinkBase`: 개발 프로젝트 내 symlink 디렉토리 (상대 경로)

## Handoff 후 워크플로우

```
SIGIL S4 완료
    ↓
Handoff 문서 자동 생성 ({folderMap.handoff}/{project}/)
    ↓
개발 프로젝트 {symlinkBase}/ 에 전체 symlink 생성
    ↓
Human이 개발 프로젝트 환경으로 이동
    ↓
Trine 자동 발동 (Implicit Entry: .specify/ 디렉토리 감지)
    ↓
Trine Session 1부터 순차 진행
    ├─ Spec 작성 (symlink된 S4 산출물 참조)
    ├─ Plan 작성
    ├─ 구현 + AI Check
    ├─ Walkthrough
    └─ PR (Merge 시 todo.md 자동 갱신)
```

## 관리자 산출물 포함 규칙

S3 기획서에 관리자 기능이 포함된 경우, Handoff 문서에 관리자 산출물도 포함:
- 관리자 상세 기획서
- 관리자 사이트맵
- 관리자 UI/UX 기획서

## Do

- S4 Gate PASS 후 Handoff 문서를 자동 생성한다
- 산출물 인덱스에 모든 S4 산출물 경로를 포함한다
- S3에 관리자 기능이 포함된 경우 관리자 산출물도 Handoff에 포함한다
- Handoff 문서에 Todo Tracker 경로를 포함한다
- Handoff 단계에서 개발 프로젝트에 전체 SIGIL 산출물 symlink를 생성한다
- 기획서/개발계획서 수정은 반드시 SIGIL 워크스페이스에서 SIGIL 파이프라인을 통해 수행한다

## Don't

- Handoff 문서 미생성으로 Trine에 진입하지 않는다
- 산출물 인덱스에 누락이 있는 상태로 Handoff를 완료하지 않는다
- Todo Tracker 미생성 상태로 Trine에 진입하지 않는다
- 개발 프로젝트에서 기획/계획 문서 원본을 직접 수정하지 않는다 (symlink이므로 SIGIL 워크스페이스에서 수정)
- symlink 없이 문서를 복사하여 개발 프로젝트에 배치하지 않는다
- `sigil-workspace.json` 없이 경로를 하드코딩하지 않는다

## AI 행동 규칙

1. **`sigil-workspace.json`을 먼저 읽고 경로를 해석한다** — 없으면 [STOP]
2. S4 Gate PASS 확인 후 Handoff 문서를 자동 생성한다
3. Handoff 문서에 산출물 인덱스, 기술 스택, 세션 로드맵을 포함한다
4. `sigil-workspace.json`의 프로젝트 매핑으로 개발 프로젝트에 전체 symlink를 생성한다
5. Human에게 Trine 진입 안내를 제공한다 (개발 프로젝트 이동 시 Trine 자동 발동)
6. 기획/계획 문서 수정 요청 시 SIGIL 워크스페이스의 원본을 수정한다 (symlink 자동 반영)

## Iron Laws

- **IRON-1**: Handoff 문서 미생성 상태로 Trine에 진입하지 않는다
- **IRON-2**: gate-log.md에 S4 PASS 기록이 없으면 Trine 진입을 거부한다

## Rationalization Table

| 합리화 (Thought) | 현실 (Reality) |
|-------------------|---------------|
| "Handoff는 형식적이니 스킵해도 개발 가능하다" | Handoff 없이 Trine에 진입하면 S4 산출물 참조 경로가 불명확하여 기획-개발 단절이 발생한다 |
| "어차피 같은 사람이 하니까 문서 없어도 된다" | 1인이라도 세션 간 컨텍스트가 유실된다. Handoff는 세션 독립성을 보장하는 공식 문서다 |

## Red Flags

- "바로 코딩부터 시작하자..." → STOP. gate-log.md에서 S4 PASS를 확인한다
- "Handoff 문서는 나중에 만들면..." → STOP. Trine 진입 전 Handoff 자동 생성을 실행한다
