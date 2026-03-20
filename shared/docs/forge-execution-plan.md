# Forge Dev — 전역화 실행계획 (Phase A)

> **Forge Dev** (삼위일체/트라인): SDD + DDD + TDD 3축 융합 AI-Native 개발 시스템

## Context

GodBlade과 Portfolio 두 개발 프로젝트가 동일한 Forge Dev 워크플로우 구성요소(Rules, Prompts, Docs, Templates, Agents, Scripts, Hooks, Commands)를 각각 독립적으로 보유하고 있다. 한쪽을 수정하면 다른 쪽도 수동으로 맞춰야 하는 유지보수 부담이 있다.

**목표**: `~/.claude/forge/`에 중앙 저장소를 만들고, 동기화 스크립트로 양 프로젝트에 배포하며, Business 워크스페이스는 완전 격리한다.

**대상 구성요소**: Forge Dev Core 22개 + Forge Dev Recommended 22개 = **44개**

---

## Step 0: 참고 문서 분리

현재 플랜의 배경/벤치마킹/철학/인벤토리 등 참고 자료를 별도 문서로 저장한다.

- 저장 경로: `~/.claude/forge/docs/forge-design-reference.md`
- 포함 내용: bkit 벤치마킹, 전체 구성요소 인벤토리 (3-Scope 테이블), PM 2계층 설계 상세, 전문 스킬 전략, Forge Dev 통합 철학 (SDD+DDD+TDD 매핑), 사용자 레벨별 자동 간소화, 참고 자료/소스

---

## Step 1: Forge Dev 원본 저장소 생성

`~/.claude/forge/` 디렉토리 구조를 생성하고 Core 구성요소를 작성한다.

### 디렉토리 레이아웃

```
~/.claude/
├── forge/                             ★ Forge Dev 원본 (Source of Truth)
│   ├── manifest.json                  배포 대상 + 파일 해시
│   ├── rules/                         핵심 규칙 7개
│   │   ├── forge-workflow.md
│   │   ├── forge-session-state.md
│   │   ├── forge-context-engineering.md
│   │   ├── forge-requirements-analysis.md
│   │   ├── forge-walkthrough.md
│   │   ├── forge-todo.md
│   │   └── forge-context-management.md
│   ├── prompts/
│   │   └── forge-pipeline.md          통합 워크플로우 프롬프트
│   ├── docs/
│   │   └── forge-architecture.md      Agent Teams 아키텍처
│   ├── templates/                     베이스 템플릿 6개
│   │   ├── spec-template-base.md
│   │   ├── plan-template-base.md
│   │   ├── task-template-base.md
│   │   ├── walkthrough-template-base.md
│   │   ├── todo-template.md       PM: 진행 상태
│   │   └── development-plan-template.md PM: 개발계획서
│   ├── agents/                        베이스 에이전트 3개
│   │   ├── spec-writer-base.md
│   │   ├── code-reviewer-base.md
│   │   └── forge-pm-updater.md
│   ├── skills/                        Forge Dev 전용 스킬 2개
│   │   ├── spec-compliance-checker/SKILL.md
│   │   └── inspection-checklist/SKILL.md
│   ├── commands/                      Core 슬래시 커맨드 4개
│   │   ├── forge.md
│   │   ├── forge-sync.md
│   │   ├── forge-status.md
│   │   └── forge-resume.md
│   └── recommended/                   권장 구성요소
│       ├── prompts/                   5개
│       ├── commands/                  3개 (forge-check-security, forge-check-ui, forge-generate-image)
│       ├── hooks/                     3개 (session-context, pre-phase-transition, subagent-verify)
│       └── skills/                    4개 (writing-plans, concise-planning, kaizen, frontend-design)
├── scripts/
│   ├── session-state.mjs              (기존 유지)
│   └── forge-sync.mjs                 ★ 동기화 스크립트
├── rules/
│   ├── opus-4-6-best-practices.md     (기존 유지)
│   └── plan-mode.md                   (기존 유지)
│                                      ← session-state.md 제거
└── commands/
    └── resume.md                      ← 제거 (forge-resume.md로 이관)
```

### 핵심 규칙 파일 통합 방침

| 파일 | 기준 버전 | 통합 방침 |
|------|----------|----------|
| `forge-workflow.md` | Portfolio | 빌드 도구 참조를 `verify.sh code` 참조로 추상화 |
| `forge-session-state.md` | 전역 + Portfolio 병합 | 멀티세션 구조 + 작업규모 분류 + autoFix/순환 제한 통합 |
| `forge-context-engineering.md` | Portfolio | 예시 파일 경로를 `{project-specific}` 플레이스홀더로 |
| `forge-requirements-analysis.md` | Portfolio | 비표준 기획서 Fallback 포함 |
| `forge-walkthrough.md` | Portfolio | 브랜치별 적용 기준을 일반화 |
| `forge-todo.md` | 양쪽 병합 | GodBlade의 checkpoint 연동 + Portfolio의 매핑 파일 |
| `forge-context-management.md` | Portfolio | MCP 토큰 인지, Tool Search 포함 (상위 호환) |

### forge-pipeline.md 통합

- `node scripts/session-state.mjs` → `node ~/.claude/scripts/session-state.mjs` (전역 경로)
- Phase 3 Check 3에서 구체적 빌드 도구 → `verify.sh code (프로젝트별)` 참조
- 프로젝트별 검증 상세는 `verification-integration.md`에 위임

### forge-architecture.md 통합

Portfolio 기준 + GodBlade 차이 병합:
- Layer 1/2/3 라벨링, Phase 1 승인 게이트 반영
- 모델 버전: Sonnet 4.6 통일
- 프로젝트별 경로 → `{project-specific}` 플레이스홀더
- `워크플로우수정.md` 참조 → `forge-pipeline.md` 참조

### 템플릿 — 베이스 + 오버라이드

**공통 구조**(섹션 골격)를 베이스로, **기술 스택**(언어/프레임워크)은 프로젝트 `.specify/templates/`에서 오버라이드.
- sync 시 프로젝트에 커스텀 버전이 있으면 **덮어쓰지 않음**
- PM 템플릿 2종(progress, development-plan)은 표준 — 오버라이드 없음

### Agents — 베이스 + 오버라이드

- **spec-writer-base**: 핵심 로직만 (constitution 읽기 → Spec 참조 → 작성 → 검증). 기술 스택 → `{constitution}`, `{template}` 플레이스홀더
- **code-reviewer-base**: 범용 코드 리뷰 로직
- **forge-pm-updater**: Phase 전환 시 Notion Tasks + development-plan.md 자동 갱신

### Skills — 신규 생성 2개

- **spec-compliance-checker**: Spec ↔ 코드 ↔ 테스트 추적성 검증 (Check 3.5)
- **inspection-checklist**: 통합 검수 체크리스트 작성

### manifest.json

```json
{
  "version": "1.0.0",
  "name": "forge",
  "targets": {
    "portfolio": { "path": "Z:/home/damools/mywsl_workspace/portfolio-project" },
    "godblade": { "path": "E:/new_workspace/god_Sword/src" }
  },
  "toolchain": {
    "tier1": ["memory-mcp", "sequential-thinking-mcp", "context7-mcp", "gh-cli"],
    "tier2": ["sharp-mcp", "lighthouse-mcp", "a11y-mcp", "nanobanana-mcp", "brave-search-mcp", "playwright-cli"]
  }
}
```

---

## Step 2: forge-sync.mjs 구현

`~/.claude/scripts/forge-sync.mjs` — Node.js ESM, 외부 의존성 없음, `session-state.mjs`와 동일 패턴.

### CLI 인터페이스

```
node ~/.claude/scripts/forge-sync.mjs <command>

  sync [--target <name>]           원본 → 프로젝트 배포 (전체 또는 특정)
  status [--quiet]                  파일 해시 일치 여부 확인
  diff <target>                     원본 vs 프로젝트 차이 표시
  init <path> --name <name>         새 프로젝트 등록
  remove <name>                     프로젝트 등록 해제
```

### 동작 규칙

- 해시 비교로 변경분만 복사
- **Core 배포** (7개 카테고리): rules/, prompts/, docs/, templates/, agents/, skills/, commands/
- **Recommended 배포** (`--include-recommended` 또는 `init` 시 자동): recommended/ 하위 → 프로젝트 `.claude/`에 복사
- templates/agents/skills: 프로젝트에 커스텀 버전이 있으면 **덮어쓰지 않음** (오버라이드 우선)
- recommended: `init` 시 자동 복사, `sync` 시 기존 있으면 스킵 (최초 온보딩만)

---

## Step 3: Portfolio 마이그레이션

```bash
node ~/.claude/scripts/forge-sync.mjs sync --target portfolio
```

### 삭제 (forge-* 파일로 대체)

- `.claude/rules/context-engineering.md`
- `.claude/rules/requirements-analysis.md`
- `.claude/rules/walkthrough-requirement.md`
- `.claude/rules/progress-automation.md`
- `.claude/rules/context-management.md`
- `.claude/rules/session-state.md` (프로젝트 레벨)
- `.claude/prompts/워크플로우수정.md`
- `docs/Planning/AI-Native-Multi-Agent-System.md`

### 유지 (프로젝트 전용)

- `verification-integration.md`, `agent-teams.md`, `.specify/templates/`, `verify.sh`

### 동작 확인

- Forge Dev 워크플로우 시뮬레이션 — 기존과 동일 동작 확인

---

## Step 4: GodBlade 마이그레이션

```bash
node ~/.claude/scripts/forge-sync.mjs sync --target godblade
```

### 삭제

- `.claude/rules/context-engineering.md`
- `.claude/rules/requirements-analysis.md`
- `.claude/rules/walkthrough-requirement.md`
- `.claude/rules/progress-automation.md`
- `.claude/rules/context-management.md`
- `.claude/prompts/워크플로우수정.md`
- `docs/tech/AI-Native-Multi-Agent-System.md`

### 유지

- `agent-teams.md`, `model-routing.md`, `extended-thinking.md`, `verification-integration.md`, `.specify/templates/`

---

## Step 5: 전역 정리 + Business 격리

- `~/.claude/rules/session-state.md` 삭제 (forge-session-state.md로 이관)
- `~/.claude/commands/resume.md` → `~/.claude/forge/commands/forge-resume.md` 이관
- Business 세션에서 Forge Dev 관련 규칙이 로드되지 않는 것 확인
- 전역 rules에는 범용 규칙 2개만 유지 (`opus-4-6-best-practices.md`, `plan-mode.md`)

---

## Step 6: SessionStart Hook 업데이트 + MEMORY.md 갱신

- Portfolio/GodBlade의 `session-context.sh`에 해시 비교 경고 추가:
  - 세션 시작 시 `forge-sync.mjs status --quiet` 실행
  - 불일치 시 경고 메시지 출력 (동기화 커맨드 안내)
  - 세션 차단 없음 (경고만)
- MEMORY.md에 Forge Dev 전역화 상태 반영

---

## 대상 파일 경로 요약

### 신규 생성 — Forge Dev Core (22개)

| 카테고리 | 파일 | 수량 |
|---------|------|:----:|
| manifest | `~/.claude/forge/manifest.json` | 1 |
| Rules | `~/.claude/forge/rules/forge-*.md` | 7 |
| Prompts | `~/.claude/forge/prompts/forge-pipeline.md` | 1 |
| Docs | `~/.claude/forge/docs/forge-architecture.md` | 1 |
| Templates | `~/.claude/forge/templates/*-base.md` + PM 2종 | 6 |
| Agents | `~/.claude/forge/agents/` (spec-writer, code-reviewer, pm-updater) | 3 |
| Skills | `~/.claude/forge/skills/` (spec-compliance-checker, inspection-checklist) | 2 |
| Commands | `~/.claude/forge/commands/` (forge, forge-sync, forge-status, forge-resume) | 4 |

### 신규 생성 — Forge Dev Recommended (15개 파일)

| 카테고리 | 파일 | 수량 |
|---------|------|:----:|
| Prompts | requirements-analysis, code-review-gate, security-gate, ui-quality-gate, resume-session | 5 |
| Commands | forge-check-security, forge-check-ui, forge-generate-image | 3 |
| Hooks | session-context, pre-phase-transition, subagent-verify | 3 |
| Skills | writing-plans, concise-planning, kaizen, frontend-design | 4 |

### 신규 생성 — Script

- `~/.claude/scripts/forge-sync.mjs`

### 삭제 대상

| 프로젝트 | 파일 |
|---------|------|
| 전역 | `~/.claude/rules/session-state.md` |
| 전역 | `~/.claude/commands/resume.md` (forge-resume.md로 이관) |
| Portfolio | `.claude/rules/` — session-state, context-engineering, requirements-analysis, walkthrough-requirement, progress-automation, context-management (6개) |
| Portfolio | `.claude/prompts/워크플로우수정.md` |
| Portfolio | `docs/Planning/AI-Native-Multi-Agent-System.md` |
| GodBlade | `.claude/rules/` — context-engineering, requirements-analysis, walkthrough-requirement, progress-automation, context-management (5개) |
| GodBlade | `.claude/prompts/워크플로우수정.md` |
| GodBlade | `docs/tech/AI-Native-Multi-Agent-System.md` |

### 유지 (변경 없음)

- 각 프로젝트의 `verification-integration.md`, `agent-teams.md`, `verify.sh`
- `~/.claude/scripts/session-state.mjs`
- `~/.claude/rules/opus-4-6-best-practices.md`, `~/.claude/rules/plan-mode.md`

---

## 검증

1. `forge-sync.mjs status` — 양 프로젝트 파일 해시 일치 확인
2. 원본 1개 파일 수정 → `sync` → 양 프로젝트에서 변경 반영 확인
3. Business 세션 시작 — Forge Dev 규칙 로드 안 되는 것 확인
4. Portfolio에서 Forge Dev 워크플로우 시뮬레이션 — 기존과 동일 동작 확인
5. GodBlade에서 동일 시뮬레이션
6. 새 프로젝트 가상 등록 → 규칙 배포 → 해제

---

## 참고 문서

- `~/.claude/forge/docs/forge-design-reference.md` — bkit 벤치마킹, 전체 구성요소 인벤토리, PM 2계층 설계, 전문 스킬 전략, SDD+DDD+TDD 통합 철학, 사용자 레벨별 자동 간소화, 참고 자료/소스
