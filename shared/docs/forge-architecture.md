# Forge Dev AI-Native Multi-Agent System

> **Agent Teams Single Engine Architecture**
> Claude Code의 Agent Teams를 유일한 병렬 실행 엔진으로 사용하는 AI-Native 개발 시스템.
> 워크스페이스 단위로 적용 가능 — 프로젝트에 독립적인 범용 아키텍처.

---

## 1. Architecture Overview

### 1.1 Agent Teams Single Engine

```
┌────────────────────────────────────────────────────┐
│                  Team Lead (현재 세션)                │
│  SDD 게이트 + 팀 생성/해체 + Shared 파일 수정 + 검증  │
└─────────┬────────────────────┬─────────────────────┘
          │                    │
    ┌─────┴──────┐      ┌─────┴──────┐
    │  Domain A   │ ←──→ │  Domain B   │    ← 피어 메시징
    │  Teammate   │      │  Teammate   │      (API 계약 협의)
    └─────┬──────┘      └─────┴──────┘
          │                    │
    {domain-a}/**        {domain-b}/**
```

**핵심 원칙:**
- Agent Teams = **유일한** 병렬 실행 엔진 (코드/문서/조사/리뷰 모두)
- Teammate는 **풀 사이클** 수행: 구현 → 테스트 → 디버깅 → 수정
- 충돌 방지: **파일 소유권** 규칙 (Lock-Free)
- 서브에이전트는 **단일 작업 전용** (Explore, spec-writer 등)

### 1.2 역할 정의

| 역할 | 담당 | 도구 |
|------|------|------|
| **Team Lead** | SDD 게이트, 팀 생성/해체, Shared 파일 수정, Walkthrough, 검증 | TeamCreate, TaskCreate, Task tool |
| **Teammate** | 도메인별 구현 + 단위 테스트 + 자체 디버깅 | Read, Write, Edit, Bash, Grep, Glob |

### 1.3 Agent Teams vs 서브에이전트 선택

| 조건 | Agent Teams | 서브에이전트 |
|------|:-----------:|:----------:|
| 병렬 작업 (멀티 도메인) | **사용** | - |
| Teammate 간 API 계약 협의 | **사용** | - |
| 단일 도메인 작업 | - | **사용** |
| Spec 작성 (spec-writer) | - | **사용** |
| 탐색/검색 (Explore) | - | **사용** |
| 코드 리뷰 | - | **사용** |

### 1.4 파일 소유권 규칙

**Teammate는 자기 도메인 파일만 수정. Shared 파일은 Lead만 수정.**

> 프로젝트별 파일 소유권 상세는 각 프로젝트의 `.claude/rules/agent-teams.md`에서 정의.

---

## 2. Forge Dev SDD + TDD Workflow

### 2.1 전체 파이프라인

```
Phase 1   (세션 이해)    → 작업 규모 분류 → [STOP] 승인
Phase 1.5 (요구사항 분석) → Q&A → 트레이서빌리티 매트릭스 생성
Phase 2   (문서)         → Spec → Plan(조건부) → AI검증1-2 → [STOP] Human 승인 → Task(조건부)
Phase 3   (구현+자동검증) → Agent Teams 실행 → Walkthrough → Check 3 → 3.5 → 3.5T → 3.6/3.7/3.7P/3.8(병렬)
Phase 4   (PR)           → Check 4 → 커밋 → PR → Check 5 (PR Health) → [STOP] Human 검토+Merge
Phase 5   (develop 통합)  → develop-integration.yml → Check 6 (verify+e2e) → [AUTO-PASS] or Issue 생성
Phase 6   (릴리스)        → /forge-release → release-staging.yml → Check 7 (staging+e2e) → [STOP] Release PR
Phase 7   (프로덕션)      → production-deploy.yml → Check 8 (deploy+health+smoke) → [AUTO-PASS] or /forge-rollback
```

### 2.2 Human 승인 게이트

| 단계 | 승인 | 설명 |
|------|:---:|------|
| Phase 1 작업 규모 분류 | **필수** | Hotfix/Small/Standard/Multi-Spec |
| Spec(+Plan) 작성 완료 | **필수** | Human 승인 후 다음 단계 |
| Task 최종 승인 (해당 시) | **필수** | 구현 시작 전 |
| PR 검토 + Merge | **필수** | AI는 생성만, Human이 검토+Merge |
| Release PR 승인 (Phase 6) | **필수** | staging 검증 후 main merge 전 |
| 롤백 레벨 선택 (Phase 7 실패) | **필수** | L1/L2/L3 중 Human이 선택 |

### 2.3 Plan/Task 조건부 작성

**Plan.md**: 멀티 도메인 / 아키텍처 결정 / 10+ 파일 변경
**Task.md**: 3+ 에이전트 동시 작업 / 복잡한 의존성 그래프
**SKIP**: 단일 도메인 + 직관적 구현 + 3개 미만 파일 변경

---

## 3. Agent Teams Execution (Phase 3)

### 3.1 실행 워크플로우

```
Human "구현해줘"
  → ① Lead: Shared 타입 먼저 작성
  → ② Lead: TaskCreate × N (태스크 생성 + 의존성 설정)
  → ③ Lead: 의존성 그래프 → Wave 분류 (의존성 없는 태스크만 같은 Wave)
  → ④ Lead: Wave 1 태스크만 먼저 Teammate 스폰 (병렬)
  → ⑤ Teammates: 태스크 수행 (풀 사이클: 구현→테스트→디버깅→수정)
  → ⑥ Lead: Wave 1 완료 확인 → Wave 2 태스크 스폰 (반복)
  → ⑦ Teammates: 피어 메시징으로 API 계약 협의 (필요 시)
  → ⑧ Lead: 결과 통합 + Shared 파일 추가 수정
  → ⑨ Lead: Walkthrough 작성
  → ⑩ Lead: Check 3 → Check 3.5 → Check 3.5T (순차)
  → ⑪ Lead: Check 3.6/3.7/3.7P/3.8 (병렬, Subagent 격리, ⑩과 동시 시작)
  → ⑫ Lead: 커밋 → PR → Check 5 (PR Health)
```

### 3.2 Teammate 풀 사이클

```
구현 → 테스트 작성 → 테스트 실행 → (실패 시) 디버깅 → 수정 → 재테스트 → 완료 보고
```

- 자체 해결 불가 → Lead에 보고 → Lead가 판단

### 3.3 모델 배정

| Role | 모델 | 이유 |
|------|------|------|
| Team Lead | 현재 세션 (Opus/Sonnet) | 조율 + SDD 게이트 |
| Teammate | Sonnet 4.6 | 코드 구현 (SWE-bench Opus 동급) |

---

## 4. Verification Gates

| 검증 | 시점 | 내용 | Layer |
|------|------|------|:-----:|
| Check 1-2 | 문서 완료 후 | Spec/Plan 구조 | 1 |
| Check 3 | 구현 완료 후 | test, lint, build | 1 |
| Check 3.5 | Walkthrough 후 | 트레이서빌리티 + Spec 준수 | 2 |
| Check 3.5T | Check 3.5 후 | 테스트 품질 (test-quality-checker, 3.5와 순차) | 2 |
| Check 3.6 | Check 3 후 | UI/UX 품질 (Subagent) | 3 |
| Check 3.7 | Check 3 후 | 코드 품질 (Subagent, 3.6과 병렬) | 3 |
| Check 3.7P | Check 3 후 | 성능 품질 (performance-checker, 3.7과 병렬) | 3 |
| Check 3.8 | Check 3 후 | 보안 (Subagent, 3.6/3.7과 병렬) | 3 |
| Check 4 | PR 생성 전 | 브랜치명, 커밋, 설정 파일 | 1 |
| Check 5 | PR 생성 후 | PR Health | 1 |

---

## 5. Error Handling

### 5.1 Teammate 실패 시

```
Teammate 실패 → 자체 디버깅 (풀 사이클)
  → 해결 → 계속 진행
  → 미해결 → Lead에 보고 → Lead가 판단
    → 코드 수정 필요 → Lead가 직접 수정 또는 재할당
    → 설계 변경 필요 → Human에 에스컬레이션
```

### 5.2 알려진 제한사항

| 제한 | 대응 |
|------|------|
| 세션 복원 불가 | 중간 git commit 필수 |
| Team 중첩 불가 | 한 번에 하나의 Team만 |
| 동일 파일 동시 편집 | 파일 소유권 규칙으로 방지 |
| Rate Limit | Teammate 수 조절 (2명 권장) |

---

## 6. Applying to Other Projects

### 6.1 필수 설정 파일

| 파일 | 용도 |
|------|------|
| `CLAUDE.md` | 프로젝트 컨텍스트 (기술 스택, Golden Rules) |
| `.claude/rules/agent-teams.md` | 팀 구성 + 파일 소유권 |
| `.specify/` | Spec/Plan/Task 템플릿 + constitution |
| `verify.sh` (프로젝트별) | 검증 게이트 스크립트 |

### 6.2 적용 절차

```
# 1. forge에 프로젝트 등록
node ~/.claude/scripts/forge-sync.mjs init /path/to/project \
  --name my-project --scope all --workspace wsl --description "프로젝트 설명"

# 2. forge 배포 (Core + Recommended)
node ~/.claude/scripts/forge-sync.mjs sync --target my-project --include-recommended

# 3. 프로젝트별 설정 (수동)
3a. CLAUDE.md에 프로젝트 기본 정보 작성
3b. .specify/ 디렉토리 생성 (constitution + 템플릿)
3c. .claude/rules/agent-teams.md에 도메인별 파일 소유권 정의
3d. verify.sh 프로젝트 테스트 명령에 맞게 작성
3e. .claude/state/ 디렉토리 생성 (.gitignore 포함)
```

**워크스페이스**: `wsl` (Linux/WSL), `windows` (Windows), `business` (비개발, shared-only)

---

## References

- `forge-pipeline.md` — Forge Dev 워크플로우 상세 실행 흐름
- `forge-workflow.md` — 워크플로우 거버넌스 규칙
- 프로젝트별 `.claude/rules/agent-teams.md` — 파일 소유권 상세
- 프로젝트별 `.claude/rules/verification-integration.md` — 검증 통합 규칙

---

**문서 버전**: 7.0 (Forge Dev 통합)
