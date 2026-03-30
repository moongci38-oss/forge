# Claude Code Plan Mode 작성 지침

> **적용 대상**: Claude Code 내장 plan mode (`.claude/plans/` 파일)
> **적용 시점**: plan mode가 활성화된 경우에만 적용. 일반 구현 세션에는 해당 없음.

## 핵심 원칙: What vs How 분리

Plan mode의 실행 계획은 **What(무엇을 할 것인가)**의 관점에서만 작성한다.

### Plan에 포함하는 것 (What)

- 변경 이유와 배경 (왜 이 작업이 필요한가)
- 변경 대상 파일/모듈/영역
- 달성해야 할 목표와 기대 결과
- 작업 순서와 의존 관계
- 영향 범위와 사이드 이펙트 분석
- 검증 기준 (어떤 상태가 되면 완료인가)

### Plan에 포함하지 않는 것 (How)

- 구체적인 코드 수정/추가 내용
- 함수 시그니처, 클래스 설계, 변수명
- 구현 로직이나 알고리즘 상세

**구현 상세(How)는 plan 승인 후 실행 단계에서 처리한다.** Spec이 있으면 spec 기준으로, 없으면 승인된 What을 기준으로 구현한다.

## 적용 범위: 모든 plan mode 요청

이 지침은 작업 규모와 무관하게 **모든 plan mode 요청에 동일하게 적용**된다.

- Spec 기반 대규모 기능 개발
- 단순 버그 수정
- 기존 기능 고도화/수정
- 기획서나 개발계획서가 없는 임시 작업

plan mode에서 계획을 작성하라는 요청이 오면, 항상 What 관점으로만 작성하고 구현 상세(How)를 포함하지 않는다.

## 프로젝트 저장 규칙

Plan mode 승인 후, 구현 시작 전에 플랜을 프로젝트에 저장한다.

### 절차

1. `.claude/plans/`의 승인된 플랜 내용을 읽는다
2. `{project}/docs/planning/active/plans/YYYY-MM-DD-{descriptive-name}.md` 경로에 복사한다
   - 파일명: `.claude/plans/`의 랜덤 이름이 아닌, 작업 내용을 설명하는 kebab-case 이름 사용
   - 프로젝트: 현재 작업 디렉토리(Primary working directory) 기준
   - `plans/` 하위 폴더를 사용하여 SIGIL 산출물/범용 기획서와 구분
3. 구현 완료 시 `docs/planning/active/plans/` → `docs/planning/done/`으로 이동한다

### 예외

- `docs/planning/` 폴더가 없는 프로젝트는 스킵
- 리서치/탐색 전용 plan (코드 변경 없음)은 저장 선택적

---

*Last Updated: 2026-03-06*
