# superpowers 워크플로우 자동 적용 규칙 (trine — Portfolio)

> superpowers v4.3.1 플러그인 — 전역 설치 완료.
> 이 파일을 Portfolio 프로젝트의 `.claude/rules/superpowers-workflow.md`에 복사한다.
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
  → pnpm install (monorepo 패키지 매니저)

TeamCreate → Agent Teams (유지)
  → Lead (Opus 4.6): 아키텍처 판단, 종합
  → Backend Teammate (Sonnet 4.6): apps/api/**
  → Frontend Teammate (Sonnet 4.6): apps/web/**

per task → ④ Skill("superpowers:test-driven-development")
  → Jest 실패 테스트 → NestJS 서비스/컨트롤러 최소 구현 → 리팩터
  → Frontend: React Testing Library + Playwright E2E

에러 발생 → ⑤ Skill("superpowers:systematic-debugging")
  → Root Cause → Pattern → Hypothesis → Implementation
  → 3회 수정 실패 → 아키텍처 재검토

태스크 완료 → ⑥ Skill("superpowers:verification-before-completion")
  → pnpm build + pnpm test 증거 + 요구사항 체크
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
  → NestJS 패턴 준수 + API 보안 체크 포함

완료 검증 → ⑧ Skill("superpowers:verification-before-completion")
  → 전체 테스트 + 빌드 + 요구사항 증거

PR/Merge → ⑨ Skill("superpowers:finishing-a-development-branch")
  → 4옵션: Merge / PR / Keep / Discard
  → worktree 정리
```

---

## trine 전용 설정 (Portfolio)

- **Tech Stack**: Next.js + NestJS + TypeScript + PostgreSQL
- **패키지 매니저**: pnpm (monorepo)
- **테스트 프레임워크**: Jest (unit), Playwright (e2e)
- **TDD 적용 범위**: API 엔드포인트, 서비스 로직, 유틸리티 함수 전체
- **Code Review**: NestJS 패턴 준수 + API 보안 체크 포함
- **기존 superpowers 스킬** (수동 복사본): docx, pdf, pptx, xlsx, frontend-design, web-artifacts-builder, hook-creator, slash-command-creator, subagent-creator, theme-factory, webapp-testing — 유지 필수 (v4.3.1에서 제거됨)

---

## 기존 규칙과의 우선순위

| 상황 | 우선 적용 |
|------|----------|
| 코드 작성 | superpowers TDD `Skill("superpowers:test-driven-development")` |
| 디버깅 | superpowers `Skill("superpowers:systematic-debugging")` |
| 팀 구성/병렬화 | 기존 Agent Teams (모델 계층화) |
| 보안 감사 | 기존 check-security 커맨드 |
| 민감 파일 보호 | 기존 block-sensitive-files 훅 |
| ESLint/Prettier | 기존 PostToolUse 훅 |
| 보안 | 기존 security.md (항상 우선) |
