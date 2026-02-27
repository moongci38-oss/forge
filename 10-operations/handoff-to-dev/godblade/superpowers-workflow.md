# superpowers 워크플로우 자동 적용 규칙 (trine — GodBlade)

> superpowers v4.3.1 플러그인 — 전역 설치 완료.
> 이 파일을 GodBlade 프로젝트의 `.claude/rules/superpowers-workflow.md`에 복사한다.
> 조건 충족 시 묻지 않고 즉시 적용한다.

---

## trine SDD 파이프라인 — 단계별 호출 매핑

### Phase 1: Spec

```
설계 검토 → ① Skill("superpowers:brainstorming")
  → 2-3 아키텍처 접근법 비교 → 사용자 승인 (HARD-GATE)
  → docs/plans/YYYY-MM-DD-<topic>-design.md 저장

Plan 작성 → ② Skill("superpowers:writing-plans")
  → bite-sized 2-5분 태스크 단위로 분해
  → docs/plans/YYYY-MM-DD-<feature-name>.md 저장

[STOP] Human 검토
```

### Phase 2: Implementation

```
격리 환경 → ③ Skill("superpowers:using-git-worktrees")
  → git worktree 생성 + .gitignore 안전 검증
  → Unity: Library/ 폴더 재생성 필요, .meta 파일 추적 필수

TeamCreate → Agent Teams (유지)
  → Lead (Opus 4.6): 게임 아키텍처 판단
  → Server Teammate (Sonnet 4.6): server/**
  → Client Teammate (Sonnet 4.6): client/**

per task → ④ Skill("superpowers:test-driven-development")
  → NUnit 실패 테스트 → C# 게임 로직 최소 구현 → 리팩터
  → PlayMode Test: MonoBehaviour 테스트
  → TDD 제외: 렌더링/물리 (EditMode Test만)

에러 발생 → ⑤ Skill("superpowers:systematic-debugging")
  → Root Cause → Pattern → Hypothesis → Implementation
  → 3회 수정 실패 → 게임 디자인 패턴 재평가

태스크 완료 → ⑥ Skill("superpowers:verification-before-completion")
  → dotnet build 또는 Unity CLI 빌드 증거 + 테스트 결과
```

### Phase 3: Delivery

```
코드 리뷰 → ⑦ Skill("superpowers:requesting-code-review")
  → BASE_SHA / HEAD_SHA 확인
  → Task(subagent_type="superpowers:code-reviewer", prompt="
      WHAT_WAS_IMPLEMENTED: {구현 내용}
      PLAN_OR_REQUIREMENTS: {계획 문서 경로}
      BASE_SHA: {base}  HEAD_SHA: {head}
      DESCRIPTION: {요약}
    ")
  → Unity 리뷰 포인트: ScriptableObject 패턴, Component 커플링, 메모리 관리

완료 검증 → ⑧ Skill("superpowers:verification-before-completion")
  → 전체 테스트 + 빌드 + 요구사항 증거

PR/Merge → ⑨ Skill("superpowers:finishing-a-development-branch")
  → 4옵션: Merge / PR / Keep / Discard
  → worktree 정리 (Unity: Library/ 재생성 고려)
```

---

## trine 전용 설정 (GodBlade)

- **Tech Stack**: Unity 2022+ + C# + .NET
- **테스트 프레임워크**: NUnit (EditMode), Unity Test Framework (PlayMode)
- **TDD 적용 범위**: 게임 로직, 유틸리티, 데이터 모델 (렌더링/물리는 제외)
- **Code Review**: SOLID 원칙 + Unity 안티패턴 체크 (Update() 남용, GetComponent 반복 호출 등)
- **빌드 검증**: `dotnet build` 또는 Unity CLI 빌드

---

## 기존 규칙과의 우선순위

| 상황 | 우선 적용 |
|------|----------|
| C# 코드 작성 | superpowers TDD `Skill("superpowers:test-driven-development")` |
| 디버깅 | superpowers `Skill("superpowers:systematic-debugging")` |
| 팀 구성/병렬화 | 기존 Agent Teams (모델 계층화) |
| Unity 에셋 관리 | Unity 프로젝트 컨벤션 |
| .meta 파일 | 항상 git 추적 (삭제 금지) |
| 보안 | 기존 security.md (항상 우선) |
