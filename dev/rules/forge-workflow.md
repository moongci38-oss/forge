---
title: "Forge Dev 워크플로우 규칙"
id: forge-workflow
impact: HIGH
scope: [forge]
tags: [pipeline, phase, verification, auto-fix, implicit-entry]
requires: []
section: forge-core
audience: dev
impactDescription: "미준수 시 Phase 게이트 누락 → 검증 없는 코드가 PR로 진행, Auto-Fix 무한 루프, 규모 분류 오류로 불필요한 프로세스 수행"
enforcement: rigid
---

# Forge Dev Workflow Rules

> Forge Dev SDD+DDD+TDD 파이프라인의 핵심 거버넌스 규칙.
> **운영 모델**: AI가 규칙을 참조하며 Phase를 수동 실행하고, Human이 게이트에서 승인한다.
> **통합 파이프라인**: `forge/pipeline.md` (Phase 1~12). 이 파일은 Part B (Phase 6~12)를 상세 정의.
> **Phase 매핑**: 구 Phase 1=Phase 6, 1.5=6(병합), 2=7, 3=8, 4=9, 5=10, 6=11, 7=12

## Phase 구조

| Phase | 통합 | 작업 | 산출물 | Human Gate | 자율성 |
|-------|:----:|------|--------|:----------:|:------:|
| 6 | 구1+1.5 | 세션 이해 + 요구사항 분석 | 세션 요약 + 트레이서빌리티 매트릭스 | 자동 (재분류 시만 **[STOP]**) | L4 |
| 7 | 구2 | Spec/Plan/Task 작성 | `.specify/specs/`, `.specify/plans/` | **[STOP]** Spec 승인 | L3 |
| 8 | 구3 | 구현 + AI 자동 검증 | 코드 + Walkthrough | - | L4 |
| 9 | 구4 | PR 생성 | PR URL | autoMerge 설정에 따름: off=**[STOP]** / on=자동 merge | L4 |
| 10 | 구5 | develop 통합 검증 | Integration Report | **[AUTO-PASS]** GitHub Actions 자동 | L5 |
| 11 | 구6 | 릴리스 + 스테이징 | release/* + Release PR | **[STOP]** Release PR Human 승인 | L2 |
| 12 | 구7 | 프로덕션 배포 + 롤백 | GitHub Release + Health Check | **[AUTO-PASS]** 성공 시 / **[STOP]** 실패 시 | L3 |

> **자율성 레벨**: L2=Human 승인 후 실행, L3=AI 제안+Human 확인, L4=AI 자율 실행+사후 보고, L5=완전 자동화.
> Phase 12 배포 전: 비가역적 행동(DB 마이그레이션, 프로덕션 데이터 변경)이 포함된 경우 반드시 L2로 강등하여 Human 명시 승인을 받는다.

## Implicit Entry (기본 개발 방법론)

개발 프로젝트에서 코드 변경 요청이 오면, `/forge` 커맨드 없이도 Forge Dev이 **기본 개발 방법론**으로 자동 적용된다.

### 3-Signal Detection

아래 3개 신호가 **모두 충족**되면 Forge Dev을 자동 적용한다:

| # | Signal | 판별 기준 |
|:-:|--------|----------|
| 1 | **프로젝트 컨텍스트** | `.specify/` 디렉토리 존재 (Forge Dev 설정이 있는 개발 프로젝트) |
| 2 | **코드 변경 의도** | 요청이 코드 수정/추가/삭제를 필요로 함 |
| 3 | **비제외 대상** | 아래 제외 목록에 해당하지 않음 |

### 제외 대상 (Forge Dev 미적용)

- 코드 설명/분석만 요청 (구현 변경 없음)
- 문서(docs/, README)만 수정
- 파일 탐색/검색/코드 리뷰만 요청
- Business 워크스페이스 비개발 작업 (리서치, 마케팅, 콘텐츠)

### Implicit vs Explicit 비교

| 항목 | Implicit (자동 진입) | Explicit (`/forge session-name`) |
|------|---------------------|----------------------------------|
| 세션 이름 | 요청에서 자동 생성 | Human 지정 |
| 규모 분류 | AI 자동 판단 (Heuristic) | AI 자동 분류 (알림 출력) |
| Forge 산출물 | 없음 (기획서 없이 진입) | S4 기획 패키지 참조 |
| 합류 시점 | 규모 분류 후 동일 파이프라인 | Phase 1부터 동일 파이프라인 |

### 자동 규모 분류 Heuristic

AI가 요청 내용에서 아래 기준으로 규모를 자동 판단한다:

| 분류 | Heuristic | 예시 |
|------|-----------|------|
| **Hotfix** | "긴급/장애/프로덕션 에러" 키워드, main 브랜치 수정, 단일 파일 | "로그인 500 에러 긴급 수정" |
| **Standard** | 새 기능, API 구현, 컴포넌트 생성, 리팩토링, 테스트 추가 | "채팅 기능 추가해줘" |

### Hotfix 경량 프로세스

```
Hotfix:  Phase 1(경량) → Phase 3 → Check 3 → Phase 4
```

- Phase 1(경량): 규모 분류만 수행, codebase-analyzer 스킵
- Phase 1.5/2: 스킵
- Check 3.5/3.7: 스킵

### 규모 재분류 (Escalation)

| 징후 | 행동 |
|------|------|
| Hotfix에서 복잡도 발견 (변경 파일 2+ 또는 테스트 필요) | **[STOP]** Standard로 재분류 제안 |
| Spec 없이 구현이 모호해짐 | **[STOP]** Phase 2(Spec 작성)로 전환 제안 |
| 비가역적 행동 포함 (DB 마이그레이션, 외부 API 호출, 데이터 삭제) | **[STOP]** Standard로 재분류 또는 최소 Phase 2 Spec 작성 |

재분류 시 이미 완료된 Phase는 재실행하지 않고, 필요한 Phase부터 이어서 진행한다.

## 작업 규모 분류

| 분류 | 기준 | Phase 스킵 |
|------|------|-----------|
| **Hotfix** | 긴급 장애, main 기반, 단일 파일 수정 | Phase 1.5/2 스킵, Check 3만 |
| **Standard** | 일반 기능 구현, 리팩토링, 테스트 추가 | 전체 Phase 수행 (Subagent 병렬 가능) |

## Plan/Task 조건부 작성

**Plan.md 필수 조건** (하나 이상 해당 시):
- 멀티 도메인 작업
- 여러 접근 방식 중 선택 필요 (아키텍처 결정)
- 10+ 파일 변경 예상

**Task.md 필수 조건:**
- 3+ 에이전트 동시 작업 필요
- 복잡한 의존성 그래프

## 병렬 실행 의존성 규칙

**의존성 없는 태스크만 동시 스폰한다.**

1. TaskCreate 후 의존성 그래프를 Wave로 분류한다
2. Wave 1: 선행 의존성이 없는 태스크 → 병렬 스폰
3. Wave N: Wave N-1의 모든 선행 태스크가 완료된 후 스폰
4. 같은 Wave 내 태스크만 병렬 실행 가능

```
[의존성 없음] Task A ─┐
[의존성 없음] Task B ─┤ Wave 1 (병렬)
                      │
[A에 의존] Task C ────┤ Wave 2 (A 완료 후)
[B에 의존] Task D ────┘
                      │
[C,D에 의존] Task E ──  Wave 3 (C,D 완료 후)
```

## 검증 체계 (Verification Gates) — MVP

| 검증 | 시점 | 실행 | 비고 |
|------|------|------|------|
| **Stitch UI** | 디자인 결정 후, 구현 전 | Stitch MCP → HTML/CSS 생성 (UI 작업만) | 선제 |
| Check 3 | 구현 완료 후 | `verify.sh code` (build + test + lint + type) | 필수 |
| Check 3.5 | Check 3 후 | AI가 `spec-compliance-checker` 스킬 참조하여 수동 실행 | 필수 |
| Check 3.7 | Check 3.5 후 | AI가 `code-reviewer` 에이전트 스폰 | 필수 |
| Check 4-5 | PR 생성 전후 | 커밋/브랜치 규칙 + PR Health | 필수 |
| Check 3.6 | Check 3.7 후 | AI가 `ui-quality-checker` 에이전트 스폰 (FE 변경 시) | 프론트엔드 PR |
| Check 6 | develop push 후 | `develop-integration.yml` GitHub Actions | Phase 5 자동 |
| Check 6.5 | Check 6 실패 시 | GitHub Issue 자동 생성 → AI 분석 + 수정 | Phase 5 실패 대응 |
| Check 7 | 릴리스 브랜치 생성 후 | `release-staging.yml` — staging deploy(조건부) + E2E | Phase 6 자동 |
| Check 7.5 | Check 7 완료 후 | Release PR 생성 + Human 승인 대기 | Phase 6 **[STOP]** |
| Check 8 | main push 후 | `production-deploy.yml` — deploy + health check + smoke test | Phase 7 자동 |
| Check 8.5 | Check 8 실패 시 | `rollback.yml` — L1/L2/L3 롤백 분기 | Phase 7 실패 대응 |

> 확장 체크(3.5T, 3.7P, 3.8)는 수요 확인 후 단계적 추가. 인증/결제 PR에서 3.8 활성화.
> Phase 5-7은 GitHub Actions 기반 자동화. `release-config.json`의 `deployCommand`가 빈 값이면 배포 단계 skip.

## 모델 계층화 (Teammate 스폰)

Agent Teams에서 Teammate 스폰 시 작업 성격에 따라 모델을 선택한다.

| 계층 | 모델 | Effort | 역할 | 사용 시점 |
|------|------|:------:|------|----------|
| Lead | Opus 4.6 | 기본 | 아키텍처 판단, 종합, 오케스트레이션 | 항상 |
| 구현 Teammate | Sonnet 4.6 | 기본/ultra | 코딩, 테스트, 문서 작성 | 코드 변경이 필요한 Task |
| 탐색 Teammate | Haiku 4.5 | low | 파일 탐색, 패턴 확인, 코드 검색 | 정보 수집만 필요한 Task |

### Effort Level Guide

각 모델의 effort 수준은 작업 복잡도와 의사결정 필요성을 나타낸다.

| Effort | 의미 | 작업 특성 | 모델 | 의사결정 수준 |
|:------:|------|---------|------|:------------:|
| **low** | 탐색 | 정보 수집, 패턴 확인, 코드 검색, 설정 조사 | Haiku 4.5 | 미포함 (기계적) |
| **기본** | 구현 | 코드 작성, 테스트 실행, 문서화, 기능 개발 | Sonnet 4.6 | 저수준 (주어진 방향 내 결정) |
| **ultra** | 아키텍처 | 시스템 설계, 기술 선택, 보안 판단, 성능 최적화 | Sonnet 4.6 또는 Lead (Opus) | 고수준 (전략적 판단) |

**의사결정 범위**:
- **low (Haiku)**: 스크립트 기반, 주어진 쿼리에 대한 기계적 응답. "이 패턴을 찾아줘"
- **기본 (Sonnet)**: 구현 가이드 내 자율 판단. "이 기능을 구현해줘" — 접근 방식은 자유이지만 요구사항 범위 내
- **ultra (Sonnet/Opus)**: 전략적 판단 필요. "이 아키텍처 문제 어떻게 해결할까?" — Lead (Opus)가 결정하거나 CTO-advisor 참조

### Haiku 탐색 Teammate 활용 기준

Haiku 4.5를 탐색 Teammate로 스폰하는 경우 (low effort):

- **파일 패턴 조사**: 프로젝트 내 기존 코드 패턴 파악 (예: "기존 DTO 데코레이터 패턴 확인")
- **의존성 매핑**: 모듈 간 import 관계 조사
- **코드 검색**: 특정 함수/클래스의 사용처 전수 조사
- **설정 확인**: 기존 설정 파일 값 수집

Haiku를 사용하지 않는 경우:
- 코드 수정/생성이 필요한 작업 → Sonnet 사용
- 아키텍처 판단이 필요한 작업 → Lead 직접 수행
- 보안/품질 검증 → 전용 Check Subagent 사용

### 스폰 예시

```
# 탐색 Teammate (Haiku) — 정보 수집만
Task(model: "haiku", prompt: "apps/api/src/modules/ 내 모든 Entity의 @Index() 데코레이터 사용 현황 조사")

# 구현 Teammate (Sonnet) — 코드 변경
Task(model: "sonnet", prompt: "estimates 모듈의 Service/Controller 구현")
```

## Document Type Effort Levels (문서 생성 작업 난이도)

문서 생성 요청 시 작업 복잡도와 의사결정 수준을 나타내는 effort 지표.

| Document Type | Effort | 의미 | 작업 특성 | CLI Keyword | 비고 |
|:------:|:------:|------|---------|:----------:|------|
| **TANDF** | low | 분석 | 기술 스택 선택, 아키텍처 상세 분석, 결정 사항 기록 | `--effort low` | 기술 검토 + ADR 작성 |
| **GDD** | 기본 | 게임 설계 | 게임 메커닉, 밸런싱 수치, Core Loop 정의 | `--effort basic` | 게임디자이너 수준 의사결정 |
| **PRD** | 기본 | 제품 기획 | 기능 정의, 사용자 플로우, 요구사항 분석 | `--effort basic` | PM 수준 의사결정 |
| **PRD (Advanced)** | ultra | 복합 기획 | 다중 도메인, 우선순위 조율, 전략적 선택 | `--effort ultra` | CEO/Lead 수준 판단 |

**의사결정 범위**:
- **low (TANDF)**: 기술 가이드 내 분석. 아키텍처 trade-off 검토, 선택지 평가, 결정 근거 문서화. "이 기술 방식이 맞나?"
- **기본 (GDD/PRD)**: 게임/제품 정의 범위 내 자율 판단. 메커닉, 기능, 플로우 결정. "어떤 기능을 만들 것인가?"
- **ultra (PRD Advanced)**: 전략적 판단 필요. 다중 이해관계자, 시장 트레이드오프, 우선순위 조율. "이 전략이 최선인가?" → Lead가 결정

**작업 범위 예시**:

| Document | 포함 범위 | 불포함 범위 |
|---------|---------|-----------|
| **TANDF** | 기술 선택, ADR, 아키텍처 상세, 성능 분석 | 기능 정의, UX/UI, 비즈니스 모델 |
| **GDD** | 메커닉, 수치, Core Loop, 아트스타일, 콘텐츠 계획 | 기술 스택, 마케팅, 대사 대본 |
| **PRD** | 기능, 요구사항, 사용자 플로우, 와이어프레임, 인수 기준 | 기술 설계, 마케팅, 조직 구조 |

## Phase 3 TDD 적용

Phase 3 구현 시 TDD(Test-Driven Development) 프로세스를 적용한다.

### TypeScript (웹/앱 프로젝트)

- **Superpowers 환경**: `superpowers:test-driven-development` 스킬을 적용한다 (Red-Green-Refactor 사이클 강제)
- **Superpowers 미설치 환경 Fallback**:
  1. 실패하는 테스트를 먼저 작성한다 (RED)
  2. 테스트를 통과하는 최소 구현을 작성한다 (GREEN)
  3. 리팩토링한다 (REFACTOR)
  - Iron Law: **프로덕션 코드보다 테스트를 먼저 작성한다. 실패하는 테스트 없이 구현 코드를 작성하지 않는다.**

### Unity / C# (게임 프로젝트)

Unity 프로젝트는 테스트 유형에 따라 TDD 적용 수준이 다르다:

| 테스트 유형 | TDD 단계 | 순서 | 비고 |
|-----------|---------|------|------|
| **EditMode Test** | RED 단계 | 구현 **전** 작성 (필수) | 순수 로직: 알고리즘, 파서, FSM, 수치 계산 |
| **구현 코드** | GREEN 단계 | EditMode 테스트 통과하는 최소 구현 | MonoBehaviour 미포함 로직 |
| **PlayMode Test** | Integration 단계 | 구현 **후** 작성 (예외 허용) | 씬/프리팹/MonoBehaviour 의존성 |
| **Game Loop QA** | 수동 검증 | TDD 면제 | 게임플레이 느낌, 연출, 타격감 |

- **Iron Law**: EditMode 테스트는 반드시 구현 전에 작성한다. 순수 로직에 대해 실패하는 테스트 없이 구현 코드를 작성하지 않는다.
- **PlayMode 예외 근거**: 씬 로딩, 프리팹 인스턴스화, 코루틴 등 Unity 런타임 의존성 때문에 구현 완료 후 작성이 현실적이다.
- **NUnit 프레임워크**: `[Test]`, `[TestCase]`, `[UnityTest]` 어트리뷰트 사용

### 공통

- **규모별 차등**: Hotfix는 TDD 면제, Standard는 필수

## Auto-Fix 규칙

- Check 실패 시 **1회 자동 수정** → 재실행
- 1회 수정 실패 → **[STOP]** Human에게 보고 (에러 내용 + 시도한 수정 요약)
- 동일 패턴 반복 시 `superpowers:systematic-debugging` 스킬 적용 (설치된 경우)
- autoFix 카운터는 session-state.json의 `check3CycleCount` 필드로 영속 관리된다

### E2E 실패 시 컨텍스트 주입

E2E 테스트(Playwright) 실패 시 일반 autoFix와 다른 흐름을 사용한다:

```
Check 3 실패 판별
  ├─ E2E 실패 여부 확인 (verify.sh 종료코드 + test-results/ 폴더 존재)
  │   Yes → [E2E 컨텍스트 수집] → autoFix(컨텍스트 포함) → E2E 재실행
  │   No  → 기존 autoFix 1회 → 재실행
  └─ PASS → 진행 / FAIL → [STOP]
```

**E2E 실패 감지 조건**:
- `verify.sh` 종료 코드 비정상 + `test-results/` 폴더 존재

**컨텍스트 수집 대상** (`test-results/` 폴더):
- 에러 메시지 텍스트 (stderr, reporter 출력)
- 실패한 스크린샷 경로 목록

**autoFix 프롬프트 주입 형식**:
```
[E2E 에러 컨텍스트]
실패 테스트: {test name}
에러 메시지: {error message}
스크린샷: {screenshot paths}
```

**주의**: autoFix 횟수 카운터(1회 제한)는 E2E/비E2E 구분 없이 공유. 한도 초과 시 [STOP].

## PR 역할 분리

| 역할 | AI | Human |
|------|:--:|:-----:|
| 브랜치 생성 | O | - |
| 코드 구현 | O | - |
| PR 생성 + 본문 | O | - |
| PR 검토 | - | **O** |
| PR Merge | autoMerge=true 시 **O** | autoMerge=false 시 **O** |

## Artifact Deployment Principle (전역 vs 프로젝트)

Forge Dev 산출물(규칙, 스크립트, 설정)은 **범용성 기준**으로 배치한다.

| 구분 | 위치 | 배포 | 예시 |
|------|------|------|------|
| **전역 (범용)** | `~/.claude/forge/` | 모든 프로젝트에 공통 적용 | Agent 정의, 시맨틱 룰, 범용 Hook 스크립트 |
| **프로젝트별 (특수)** | 프로젝트 내 | 해당 프로젝트만 적용 | lint-staged 설정, 프레임워크별 ESLint, 프로젝트 고유 경로 |

### 판단 기준

- **전역**: 언어/프레임워크 무관하게 동작하는가? → Forge Dev 중앙
- **프로젝트별**: 특정 기술 스택/디렉토리 구조에 의존하는가? → 프로젝트 내

### Hook 레이어 적용

| 스크립트 | 범용성 | 배치 |
|---------|:------:|------|
| 시크릿 탐지 | 범용 (패턴 매칭) | Forge Dev 중앙 → forge-sync 배포 |
| JSON 무결성 | 범용 (파서) | Forge Dev 중앙 → forge-sync 배포 |
| dev 의존성 체크 | Node.js 전용 | 프로젝트 내 (Node.js 프로젝트만) |
| i18n dead key | 프로젝트 구조 의존 | 프로젝트 내 (해당 프로젝트만) |
| lint-staged 설정 | 프레임워크 의존 | 프로젝트 내 |
| Husky hook 연결 | Git 프로젝트 범용 | Forge Dev 중앙 (템플릿) → forge-sync 배포 |

### Iron Law

- **IRON**: 범용 산출물을 특정 프로젝트에만 하드코딩하지 않는다. Forge Dev 중앙에 두고 sync로 배포한다.
