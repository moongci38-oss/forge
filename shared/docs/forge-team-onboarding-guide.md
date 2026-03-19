# Forge Dev 팀 온보딩 가이드

> Forge Dev 개발 워크플로우를 팀원에게 배포하기 위한 종합 가이드.
> 이 문서는 `~/.claude/forge/docs/`에서 직접 참조합니다.

---

## 1. Forge Dev이란?

Forge Dev은 **SDD(Spec-Driven Development) + DDD(Domain-Driven Design) + TDD(Test-Driven Development)** 3축을 융합한 AI-Native 개발 시스템이다.

### 핵심 개념

| 개념 | 설명 |
|------|------|
| **Source of Truth** | `~/.claude/forge/` — 모든 규칙, 템플릿, 에이전트의 중앙 저장소 |
| **동기화 엔진** | `forge-sync.mjs` — 해시 비교 기반으로 변경분만 프로젝트에 배포 |
| **프로젝트 등록** | `manifest.json` — 개인별 프로젝트 경로와 scope 관리 |
| **Override 추적** | `forge-sync-state.json` — 프로젝트별 커스터마이징 자동 감지 |

### Forge Dev이 배포하는 것

v1.4.0부터 **전역 배포 모델**을 사용한다. 대부분의 파일을 `~/.claude/`에 전역 배포하여 모든 프로젝트에서 자동 로드된다.

#### 전역 배포 (→ `~/.claude/`)

| 카테고리 | 소스 경로 | 배포 경로 | 설명 |
|---------|----------|----------|------|
| rules | `forge/global-rules/` + `forge/rules/` | `~/.claude/rules/` | 전역 규칙 + Forge Dev 규칙 |
| agents | `forge/agents/` | `~/.claude/agents/` | 커스텀 에이전트 (spec-writer, code-reviewer 등) |
| skills | `forge/skills/` | `~/.claude/skills/` | 커스텀 스킬 (spec-compliance-checker 등) |
| commands | `forge/commands/` | `~/.claude/commands/` | 슬래시 커맨드 (/forge, /forge-sync 등) |
| prompts | `forge/prompts/` | `~/.claude/prompts/` | AI 프롬프트 (파이프라인 등) |
| recommended/* | `forge/recommended/` | `~/.claude/{skills,commands,prompts}/` | 추천 스킬, 커맨드, 프롬프트 |

#### 프로젝트별 배포 (→ 프로젝트 내부)

| 카테고리 | 소스 경로 | 배포 경로 | 설명 |
|---------|----------|----------|------|
| templates | `forge/templates/` | `.specify/templates/` | Spec, Plan, Task 템플릿 (scope: all만) |
| github-spec-kit/workflows | `forge/github-spec-kit/workflows/` | `.github/workflows/` | GitHub Actions (spec-check, spec-change-detector) |
| github-spec-kit/issue-templates | `forge/github-spec-kit/issue-templates/` | `.github/ISSUE_TEMPLATE/` | Issue 템플릿 (spec-request, bug-report) |
| github-spec-kit/pr-template | `forge/github-spec-kit/pr-template/` | `.github/` | PR 템플릿 (pull_request_template.md) |
| github-spec-kit/scripts | `forge/github-spec-kit/scripts/` | `scripts/` | Spec 검증 스크립트 (validate-spec.js) |
| recommended/hooks | `forge/recommended/hooks/` | `.claude/hooks/` | 추천 hooks (프로젝트별 설정 의존) |

#### 배포 중단 (소스에서 직접 참조)

| 카테고리 | 이전 배포 경로 | 현재 참조 경로 |
|---------|--------------|-------------|
| docs | `docs/forge/` | `~/.claude/forge/docs/` |
| shared-docs | `docs/shared/` | `~/.claude/forge/shared-docs/` |

---

## 2. 시스템 구조

### 2.1 전체 디렉토리 구조

```
~/.claude/forge/                    ← GitHub private repo (Source of Truth)
├── .gitignore                      ← manifest.json 제외 (개인 경로)
├── README.md                       ← 간략 온보딩 가이드
├── manifest.example.json           ← manifest 템플릿 (플레이스홀더)
├── manifest.json                   ← 개인 설정 (git 추적 안 됨)
│
├── scripts/                        ← 실행 스크립트 (setup이 ~/.claude/scripts/에 복사)
│   ├── forge-sync.mjs              ← 동기화 엔진 v1.5.0
│   ├── session-state.mjs           ← 세션 상태 관리 CLI
│   └── setup.mjs                   ← 부트스트랩 스크립트
│
├── global-rules/                   ← 전역 Claude Code 규칙 (setup이 ~/.claude/rules/에 복사)
│   ├── opus-4-6-best-practices.md  ← 행동/지식/안전성 3축 원칙
│   ├── plan-mode.md                ← Plan mode What vs How 분리
│   └── docs-structure.md           ← docs/ 통일 폴더 구조
│
├── rules/                          ← Forge Dev 규칙 → ~/.claude/rules/에 전역 배포
│   ├── forge-workflow.md           ← SDD 파이프라인 워크플로우 (모델 계층화 포함)
│   ├── forge-session-state.md      ← 세션 상태 관리 규칙
│   ├── forge-context-engineering.md ← 컨텍스트 엔지니어링
│   ├── forge-requirements-analysis.md ← 요구사항 분석
│   ├── forge-walkthrough.md        ← 구현 워크스루 규칙
│   ├── forge-todo.md           ← 진행 상태 추적
│   ├── forge-context-management.md ← 컨텍스트 관리
│   ├── forge-performance.md        ← 백엔드 성능 품질 규칙 (N+1, Pagination, Rate Limiting)
│   └── forge-module-dependency.md  ← 모듈 의존성 방향 검증
│
├── prompts/                        ← → ~/.claude/prompts/에 전역 배포
│   ├── forge-pipeline.md           ← SDD 파이프라인 프롬프트
│   └── security-gate.md            ← Check 3.8 보안 검수 (OWASP API3/4/9 포함)
│
├── docs/                           ← 소스에서 직접 참조 (배포 안 함)
│   ├── forge-architecture.md       ← 아키텍처 설계 문서
│   ├── forge-design-reference.md   ← 설계 레퍼런스
│   ├── forge-execution-plan.md     ← 실행 계획
│   └── forge-team-onboarding-guide.md ← 이 문서
│
├── templates/                      ← → 프로젝트 .specify/templates/에 배포
│   ├── spec-template-base.md       ← Spec 작성 템플릿 (섹션 9 FE 9항목, 섹션 10 테스트 5항목)
│   ├── plan-template-base.md       ← 구현 계획 템플릿
│   ├── task-template-base.md       ← 태스크 분배 템플릿 (Wave 기반)
│   ├── walkthrough-template-base.md ← 구현 워크스루 템플릿
│   ├── todo-template.md        ← 진행 상태 템플릿
│   └── development-plan-template.md ← 개발 계획서 템플릿
│
├── github-spec-kit/                ← → 프로젝트 .github/ + scripts/에 배포 (v1.5.0)
│   ├── workflows/                  ← GitHub Actions workflows
│   │   ├── spec-check.yml          ← PR 시 Spec 파일 검증
│   │   └── spec-change-detector.yml ← Spec 변경 감지 + Issue 생성
│   ├── issue-templates/            ← GitHub Issue 템플릿
│   │   ├── spec-request.md         ← Spec 요청 템플릿
│   │   └── bug-report.md           ← 버그 리포트 템플릿
│   ├── pr-template/                ← PR 템플릿
│   │   └── pull_request_template.md ← SDD 준수 PR 템플릿
│   └── scripts/                    ← Spec 검증 스크립트
│       └── validate-spec.js        ← 로컬 Spec 유효성 검사
│
├── agents/                         ← → ~/.claude/agents/에 전역 배포
│   ├── spec-writer-base.md         ← Spec 작성 에이전트 (6카테고리 검증 + 스킬 참조)
│   ├── code-reviewer-base.md       ← 코드 리뷰 에이전트
│   ├── forge-pm-updater.md         ← PM 업데이트 에이전트
│   ├── performance-checker.md      ← 성능 정적 분석 에이전트 (Check 3.7P)
│   └── test-quality-checker.md     ← 테스트 품질 검증 에이전트 (Check 3.5T)
│
├── skills/                         ← → ~/.claude/skills/에 전역 배포
│   ├── spec-compliance-checker/    ← Spec 준수 검사
│   └── inspection-checklist/       ← 검수 체크리스트
│
├── commands/                       ← → ~/.claude/commands/에 전역 배포
│   ├── forge.md                    ← /forge 커맨드
│   ├── forge-sync.md               ← /forge-sync 커맨드
│   ├── forge-status.md             ← /forge-status 커맨드
│   └── forge-resume.md             ← /forge-resume 커맨드
│
├── shared-docs/                    ← 소스에서 직접 참조 (배포 안 함)
│   ├── setup-reports/              ← 초기 셋업 리포트
│   └── tech/                       ← 기술 참고 문서
│
└── recommended/                    ← → ~/.claude/에 전역 배포 (기존 파일 스킵)
    ├── prompts/                    ← 추천 프롬프트 (게이트)
    ├── commands/                   ← 추천 커맨드 (보안/UI 체크)
    ├── hooks/                      ← 추천 hooks (세션 컨텍스트 등)
    └── skills/                     ← 추천 스킬 (7개)
```

### 2.2 개인 vs 공유 파일

| 파일 | Git 추적 | 설명 |
|------|:--------:|------|
| `manifest.json` | X | 개인별 워크스페이스 경로 + 등록 프로젝트 |
| `.claude/forge-sync-state.json` | X | 프로젝트별 override 추적 상태 |
| `manifest.example.json` | O | 플레이스홀더 기반 manifest 템플릿 |
| 나머지 전부 | O | 규칙, 템플릿, 스크립트 등 팀 공유 자산 |

### 2.3 setup.mjs가 배포하는 파일 vs forge-sync가 배포하는 파일

| 도구 | 배포 대상 | 배포 위치 | 실행 시점 |
|------|----------|----------|---------|
| `setup.mjs` | scripts (2개) | `~/.claude/scripts/` | clone 직후, 업데이트 시 |
| `setup.mjs` | 전역 컴포넌트 (rules, agents, skills, commands, prompts + recommended) | `~/.claude/` | clone 직후, 업데이트 시 |
| `setup.mjs` | 의존성 (Agent SDK, Agent Teams, tmux) | 설치/확인 | clone 직후, 업데이트 시 |
| `setup.mjs` | manifest.example.json | `manifest.json` 생성 | 최초 1회 (인터랙티브) |
| `forge-sync` | 전역 컴포넌트 (위와 동일) | `~/.claude/` | 동기화 시 |
| `forge-sync` | templates | 프로젝트 `.specify/templates/` | 동기화 시 (scope: all만) |
| `forge-sync` | github-spec-kit | 프로젝트 `.github/` + `scripts/` | 동기화 시 (scope: all만, v1.5.0) |
| `forge-sync` | recommended/hooks | 프로젝트 `.claude/hooks/` | 동기화 시 (기존 파일 스킵) |

> **v1.5.0 변경**: GitHub Spec Kit (workflows, issue templates, PR template, validate-spec.js)을 프로젝트에 배포.
> **v1.4.0 변경**: docs, shared-docs는 더 이상 프로젝트에 배포하지 않음. `~/.claude/forge/`에서 직접 참조.

---

## 3. 팀원 온보딩 (신규 셋업)

### 3.1 전제조건

| 항목 | 요구사항 | 확인 방법 |
|------|---------|----------|
| Claude Code | CLI 설치 + `~/.claude/` 존재 | `claude --version` |
| Node.js | 18 이상 | `node --version` |
| GitHub SSH | `moongci38-oss/forge` repo 접근 가능 | `ssh -T git@github.com` |

> Agent SDK, tmux는 setup.mjs가 자동으로 설치/확인합니다.

### 3.2 셋업 순서 (2단계)

#### Step 1: Clone

```bash
git clone git@github.com:moongci38-oss/forge.git ~/.claude/forge
```

HTTPS를 사용하는 경우:

```bash
git clone https://github.com/moongci38-oss/forge.git ~/.claude/forge
```

> **Windows PowerShell 사용자**: PowerShell에서 `~`가 홈 디렉토리로 확장되지 않아, 현재 폴더에 리터럴 `~` 디렉토리가 생성됩니다.
> 반드시 `$HOME`을 사용하세요:
>
> ```powershell
> git clone git@github.com:moongci38-oss/forge.git "$HOME\.claude\forge"
> ```

#### Step 2: Setup 실행

```bash
node ~/.claude/forge/scripts/setup.mjs
```

PowerShell의 경우:

```powershell
node "$HOME\.claude\forge\scripts\setup.mjs"
```

#### Step 3: MCP 서버 전역 등록

전역 MCP 서버(Brave Search, Sentry, Notion 등 10개)를 `~/.claude.json`에 등록한다.
이미 등록된 서버는 건너뛴다 (멱등성 보장).

```bash
bash ~/.claude/forge/shared/scripts/setup-mcp.sh
```

등록 후 필요한 API 키를 환경변수로 설정한다:

| 환경변수 | MCP 서버 | 필수 여부 |
|---------|---------|:--------:|
| `BRAVE_API_KEY` | Brave Search | 필수 |
| `GEMINI_API_KEY` | NanoBanana (이미지 생성) | 필수 |
| `REPLICATE_API_TOKEN` | Replicate (AI 모델) | 선택 |
| `STITCH_API_KEY` | Stitch (UI 목업) | 선택 |
| `LUDO_API_KEY` | Ludo (게임 에셋) | 선택 |

> Sentry, Notion, Lighthouse, Draw.io, Magic UI는 API 키 없이 동작한다.
> API 키는 `forge/.env`에서 관리한다. `.env.example`을 참고한다.

`setup.mjs`가 7단계를 자동으로 수행한다:

```text
========================================
 Forge Dev Setup
========================================

[1/7] Prerequisites
  Node.js: v24.x.x ... OK
  Claude dir: ~/.claude ... OK

[2/7] Install Scripts → ~/.claude/scripts/
  + forge-sync.mjs
  + session-state.mjs

[3/7] Install Global Components → ~/.claude/
  rules/ ... 10 files (3 global + 7 forge)
  agents/ ... 5 files
  skills/ ... 9 dirs (2 forge + 7 recommended)
  commands/ ... 7 files (4 forge + 3 recommended)
  prompts/ ... 6 files (1 forge + 5 recommended)

[4/7] Dependencies
  Agent SDK ... OK (installed)
  Agent Teams ... OK (enabled)
  tmux (WSL) ... OK

[5/7] Configure
  플랫폼: Windows (win32)

  워크스페이스 경로를 입력하세요. (Enter = 건너뛰기)

  WSL 워크스페이스 경로: Z:/home/username/workspace
  Windows 워크스페이스 경로: E:/workspace
  Business 워크스페이스 경로 (선택):

  + manifest.json created

[6/7] Discover & Register

  발견된 프로젝트:
    1. portfolio  → Z:/home/username/workspace/portfolio-project  [all]
    2. godblade   → E:/workspace/god_Sword/src                    [all]

  등록하시겠습니까? (Y/n): Y
  + portfolio registered
  + godblade registered

[7/7] First Sync
  📦 Syncing → portfolio ... ✅ 25 copied
  📦 Syncing → godblade  ... ✅ 25 copied

========================================
 Setup complete!
========================================
```

> **Mac 사용자**: 플랫폼을 자동 감지하여 "프로젝트 워크스페이스 경로" 한 줄만 질문합니다.

### 3.3 자동 설치/확인되는 의존성 (Step 4)

| 항목             | 동작                                                                                      |
|------------------|-------------------------------------------------------------------------------------------|
| **Agent SDK**    | `npm install -g @anthropic-ai/claude-agent-sdk` (미설치 시 자동 설치)                     |
| **Agent Teams**  | `~/.claude/settings.json`에 환경변수 자동 추가 (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) |
| **tmux**         | 존재 확인 + 미설치 시 설치 안내 (Mac: `brew install tmux`, Linux: `apt install tmux`)     |

### 3.4 프로젝트 자동 발견 (Step 6)

워크스페이스 경로를 1단계 깊이로 스캔하여 `.claude/` 폴더가 있는 프로젝트를 자동 발견합니다.

- 프로젝트 이름: 디렉토리명에서 자동 생성 (kebab-case)
- Scope: 경로에 `business` 포함 → `shared-only`, 그 외 → `all`
- 이미 등록된 프로젝트는 건너뜀 (멱등성)

자동 발견에 실패한 프로젝트는 수동 등록 가능:

```bash
node ~/.claude/scripts/forge-sync.mjs init /path/to/project \
  --name my-project \
  --scope all \
  --description "프로젝트 설명" \
  --workspace wsl
```

**Scope 옵션:**

| Scope | 전역 배포 | 프로젝트 Templates | 프로젝트 Hooks |
|-------|:---------:|:-----------------:|:-------------:|
| `all` | 자동 (scope 무관) | O | O (옵션) |
| `shared-only` | 자동 (scope 무관) | X | X |

비개발 워크스페이스(business 등)는 `shared-only` scope로 등록.
전역 컴포넌트는 scope와 무관하게 모든 프로젝트에서 자동 로드된다.

---

## 4. 업데이트

팀 리드가 forge 소스를 변경하여 GitHub에 push한 경우:

```bash
# 1. 최신 소스 받기
cd ~/.claude/forge
git pull

# 2. 스크립트 + 전역 규칙 업데이트
node ~/.claude/forge/scripts/setup.mjs --update

# 3. 프로젝트에 동기화
node ~/.claude/scripts/forge-sync.mjs sync
```

**`--update` 모드 동작:**
- `scripts/` → `~/.claude/scripts/` 덮어쓰기
- 전역 컴포넌트 (`rules/`, `agents/`, `skills/`, `commands/`, `prompts/` + recommended) → `~/.claude/` 덮어쓰기
- 의존성 설치/확인 (Agent SDK, Agent Teams, tmux)
- `manifest.json` → 건드리지 않음 (개인 설정 보존)

---

## 5. 주요 명령어 레퍼런스

### 5.1 forge-sync.mjs

```bash
# 전체 프로젝트 동기화
node ~/.claude/scripts/forge-sync.mjs sync

# 특정 프로젝트만 동기화
node ~/.claude/scripts/forge-sync.mjs sync --target my-project

# Recommended 구성 포함 동기화
node ~/.claude/scripts/forge-sync.mjs sync --include-recommended

# 변경 확인만 (실제 복사 안 함)
node ~/.claude/scripts/forge-sync.mjs sync --dry-run

# 상태 확인 (해시 비교)
node ~/.claude/scripts/forge-sync.mjs status

# 조용히 상태 확인 (CI용, exit code만 반환: 0=synced, 2=out-of-sync)
node ~/.claude/scripts/forge-sync.mjs status --quiet

# 차이 비교
node ~/.claude/scripts/forge-sync.mjs diff my-project

# 등록된 프로젝트 목록
node ~/.claude/scripts/forge-sync.mjs list

# 특정 워크스페이스만 필터
node ~/.claude/scripts/forge-sync.mjs list --workspace wsl

# 새 프로젝트 등록
node ~/.claude/scripts/forge-sync.mjs init <path> \
  --name <name> --scope <all|shared-only> \
  --description "설명" --workspace <key>

# 프로젝트 등록 해제
node ~/.claude/scripts/forge-sync.mjs remove <name>
```

### 5.2 session-state.mjs

```bash
# 새 세션 생성
node ~/.claude/scripts/session-state.mjs init --name my-feature --work-size standard

# 세션 목록
node ~/.claude/scripts/session-state.mjs list

# 세션 상태 확인
node ~/.claude/scripts/session-state.mjs status --session my-feature

# 세션 이름 변경 (UUID 불변)
node ~/.claude/scripts/session-state.mjs rename old-name new-name

# 체크포인트 저장
node ~/.claude/scripts/session-state.mjs checkpoint phase2 --session my-feature

# 완료 세션 정리 (수동)
node ~/.claude/scripts/session-state.mjs clean
```

> **자동 정리**: `init` 실행 시 완료된 세션(`session_complete`)이 자동 삭제되고, `event-log.jsonl`이 500줄 초과 시 최근 200줄로 회전된다.

### 5.3 setup.mjs

```bash
# 초기 셋업 (7단계 전체 실행)
node ~/.claude/forge/scripts/setup.mjs

# 업데이트 (scripts + 전역 컴포넌트 + 의존성, manifest 유지)
node ~/.claude/forge/scripts/setup.mjs --update

# 의존성 설치 건너뛰기
node ~/.claude/forge/scripts/setup.mjs --skip-deps

# 프로젝트 자동 발견 건너뛰기
node ~/.claude/forge/scripts/setup.mjs --skip-discover

# 비대화형 (CI/스크립트)
node ~/.claude/forge/scripts/setup.mjs --workspace ~/projects --business ~/biz   # Mac
node ~/.claude/forge/scripts/setup.mjs --wsl-path "Z:/ws" --win-path "E:/ws"     # Windows
```

---

## 6. Override Tracking (v1.2.0 → v1.5.0)

### 6.1 개요

v1.5.0부터 **templates와 github-spec-kit이 Override Tracking 대상**이다 (agents, skills, commands, prompts는 전역 배포로 전환).

프로젝트에서 forge이 배포한 templates 파일을 수정하면, 이후 전역 소스가 변경되더라도 프로젝트의 커스텀 버전이 유지된다. 반대로, 수정하지 않은 파일은 전역 변경이 자동으로 반영된다.

### 6.2 동작 방식

```
첫 동기화
  └─ 파일 배포 + 해시 기록 (forge-sync-state.json)

이후 동기화
  ├─ 프로젝트 파일 해시 == 기록된 해시
  │   → 프로젝트가 수정하지 않음 → 전역 변경 자동 반영 (auto)
  │
  └─ 프로젝트 파일 해시 != 기록된 해시
      → 프로젝트가 직접 수정함 → 전역 변경 무시 (project override)
```

### 6.3 출력 예시

```
📦 Syncing → portfolio (templates)
  ↻ .specify/templates/spec-template-base.md (auto)
  ⏭ .specify/templates/plan-template-base.md (project override)
```

| 아이콘 | 의미 |
|--------|------|
| `+` | 신규 파일 배포 |
| `↻` | 변경된 파일 업데이트 |
| `↻ (auto)` | Override 파일 자동 업데이트 (프로젝트 미수정) |
| `⏭ (project override)` | 프로젝트 커스텀 버전 유지 (스킵) |

### 6.4 Override 리셋

프로젝트 커스텀 버전을 버리고 전역 소스로 되돌리려면:

```bash
# 해당 파일 삭제
rm .specify/templates/plan-template-base.md

# 재동기화
node ~/.claude/scripts/forge-sync.mjs sync --target my-project
```

### 6.5 상태 파일

- 각 프로젝트의 `.claude/forge-sync-state.json`에 저장
- `.gitignore`에 이미 추가됨 (개인별 상태, git 추적 안 됨)
- 형식: `{ "version": "1.0.0", "files": { "경로": "해시12자리" } }`

---

## 7. manifest.json 상세

### 7.1 전체 구조

```json
{
  "version": "1.1.0",
  "name": "forge",
  "description": "SDD + DDD + TDD 3축 융합 AI-Native 개발 시스템",
  "workspaces": {
    "wsl": {
      "basePath": "Z:/home/username/workspace",
      "platform": "wsl",
      "description": "Linux/WSL 기반 프로젝트"
    },
    "windows": {
      "basePath": "E:/workspace",
      "platform": "windows",
      "description": "Windows 기반 프로젝트"
    }
  },
  "targets": {
    "my-project": {
      "path": "Z:/home/username/workspace/my-project",
      "description": "Next.js 웹 프로젝트",
      "scope": "all",
      "workspace": "wsl"
    }
  },
  "core": { ... },
  "recommended": { ... },
  "toolchain": { ... },
  "sync": {
    "overridePolicy": "skip",
    "hashAlgorithm": "sha256"
  }
}
```

### 7.2 워크스페이스 설정

워크스페이스는 프로젝트를 논리적으로 그룹화한다.

```json
"workspaces": {
  "wsl": {
    "basePath": "Z:/home/username/workspace",
    "platform": "wsl",
    "description": "Linux/WSL 기반 프로젝트"
  }
}
```

- `basePath`: 워크스페이스 루트 경로 (표시용)
- `platform`: `wsl` 또는 `windows`
- `description`: 설명 텍스트

### 7.3 타겟 등록

`forge-sync init`으로 자동 등록되며, 직접 JSON을 편집해도 된다.

```json
"targets": {
  "my-project": {
    "path": "Z:/home/username/workspace/my-project",
    "description": "프로젝트 설명",
    "scope": "all",
    "workspace": "wsl"
  }
}
```

---

## 8. 전역 컴포넌트 (Global Components)

v1.4.0부터 `setup.mjs`와 `forge-sync`가 `~/.claude/`에 전역 배포하는 컴포넌트. 모든 Claude Code 세션에 자동 적용된다.

### 8.1 전역 Rules (10개)

| 파일 | 출처 | 내용 |
|------|------|------|
| `opus-4-6-best-practices.md` | global-rules | 행동/지식/안전/효율 4축 원칙 |
| `plan-mode.md` | global-rules | Plan mode What vs How 분리 |
| `docs-structure.md` | global-rules | docs/ 통일 폴더 구조 |
| `forge-workflow.md` | rules | SDD 파이프라인 워크플로우 |
| `forge-session-state.md` | rules | 세션 상태 관리 규칙 |
| `forge-context-engineering.md` | rules | 컨텍스트 엔지니어링 |
| `forge-requirements-analysis.md` | rules | 요구사항 분석 + 도메인 완결성 체크리스트 (CRUD/권한/에러/FE상태/테스트/입력검증) |
| `forge-walkthrough.md` | rules | 구현 워크스루 규칙 |
| `forge-todo.md` | rules | 진행 상태 추적 (AI 에이전트 트리거 + 수동 매핑 가이드 + 외부 PM 연동) |
| `forge-context-management.md` | rules | 컨텍스트 관리 |

### 8.2 전역 Agents (3개)

| 파일 | 내용 |
|------|------|
| `spec-writer-base.md` | Spec 작성 에이전트 (6카테고리 검증 + Tech Stack 기반 스킬 참조 연결) |
| `code-reviewer-base.md` | 코드 리뷰 에이전트 |
| `forge-pm-updater.md` | PM 업데이트 에이전트 |
| `performance-checker.md` | 성능 정적 분석 에이전트 (Check 3.7P) |
| `test-quality-checker.md` | 테스트 품질 검증 에이전트 (Check 3.5T) |

### 8.3 전역 Commands (7개)

| 파일 | 내용 |
|------|------|
| `forge.md` | /forge 파이프라인 실행 |
| `forge-sync.md` | /forge-sync 동기화 |
| `forge-status.md` | /forge-status 상태 확인 |
| `forge-resume.md` | /forge-resume 세션 재개 |
| `forge-check-traceability.md` | /forge-check-traceability 트레이서빌리티 점검 (Check 3.5) |
| `forge-check-security.md` | /forge-check-security 보안 점검 (recommended) |
| `forge-check-ui.md` | /forge-check-ui UI 품질 점검 (recommended) |
| `forge-generate-image.md` | /forge-generate-image 이미지 생성 (recommended) |

### 8.4 전역 Skills, Prompts

- **Skills**: `spec-compliance-checker`, `inspection-checklist` + recommended 7개
- **Prompts**: `forge-pipeline.md` + recommended 5개 (게이트 프롬프트)

---

## 9. Recommended 구성

v1.4.0부터 `~/.claude/`에 전역 배포. 이미 존재하는 파일은 스킵. hooks만 프로젝트별 배포.

### 9.1 Recommended Prompts

| 파일 | 용도 |
|------|------|
| `requirements-analysis.md` | 요구사항 분석 프롬프트 |
| `code-review-gate.md` | 코드 리뷰 게이트 |
| `security-gate.md` | 보안 점검 게이트 |
| `ui-quality-gate.md` | UI 품질 게이트 |
| `resume-session.md` | 세션 재개 프롬프트 |

### 9.2 Recommended Commands

| 파일 | 용도 |
|------|------|
| `forge-check-security.md` | /forge-check-security 보안 점검 |
| `forge-check-ui.md` | /forge-check-ui UI 품질 점검 |
| `forge-generate-image.md` | /forge-generate-image 이미지 생성 |

### 9.3 Recommended Hooks

| 파일 | 용도 |
|------|------|
| `session-context.sh` | 세션 시작 시 forge 컨텍스트 주입 |
| `pre-phase-transition.sh` | 페이즈 전환 전 검증 |
| `subagent-verify.sh` | 서브에이전트 결과 검증 |

### 9.4 Recommended Skills

| 스킬 | 용도 |
|------|------|
| `writing-plans` | 실행 계획 작성 |
| `concise-planning` | 간결한 계획 작성 |
| `kaizen` | 지속적 개선 |
| `frontend-design` | 프론트엔드 UI/UX 디자인 |
| `hook-creator` | Claude Code Hook 생성 |
| `slash-command-creator` | 슬래시 커맨드 생성 |
| `subagent-creator` | 커스텀 에이전트 생성 |

---

## 10. 작업 이력

### 10.1 v1.6.0 변경사항 (2026-02-28) — Spec 누락 방지 강화

| 변경 | 설명 |
|------|------|
| spec-template-base.md 확장 | 섹션 3(NFR 측정기준+검증방법), 4(Error/Edge Path 분리), 9(FE 2줄→9항목: 라우트/컴포넌트계층/Props/상태관리/에러·로딩·빈상태/반응형/접근성/SEO/인터랙션), 10(테스트 3줄→5항목+시나리오 예시) |
| spec-writer-base.md 강화 | 검증 3항목→6카테고리 (기본섹션/API에러응답/FE검증/테스트시나리오/입력검증/NFR측정), Tech Stack 감지→스킬 참조 연결 (nestjs-expert, nextjs-best-practices, postgres-best-practices) |
| forge-requirements-analysis.md 확장 | Phase 1.5에 도메인 완결성 체크리스트 6개 영역 추가 (CRUD/권한/에러시나리오/FE상태/테스트/입력검증) |
| forge-playground.md 확장 | design-playground→Spec 반영 4단계 워크플로우 (디자인값→Spec 섹션 9.6/9.9 자동 삽입 제안) |
| planning-package-template.md 확장 | S4 산출물 6→7개→3종 통합 (테스트 전략서→개발계획에 흡수, 사이트맵→상세기획서에 흡수, 로드맵+WBS→개발계획에 흡수) |
| forge-pipeline.md 업데이트 | S4 필수 산출물 3종 체계 확정 (상세기획서, 개발계획, UI/UX기획서) |

#### 근본 원인 진단 → 개선 매핑

| 근본 원인 | 비중 | 대응 변경 |
|----------|:----:|----------|
| Spec 자체 불완전 (FE/테스트 빈 스켈레톤) | 70% | spec-template-base 확장 (P1) + spec-writer 검증 강화 (P2) |
| Phase 2 블라인드 스팟 (기존 도구 지식 미연결) | 20% | spec-writer 스킬 참조 연결 (P2) + playground→Spec 반영 (P6) |
| Phase 1.5 예방 실패 (누락 미탐지) | 10% | 요구사항 완결성 체크리스트 (P4) |

#### 검증 결과

기존 Spec(site-foundation.md) 역검증 → 13개 갭 모두 신규 템플릿/규칙으로 감지 가능 확인.
상세: `business/docs/reviews/2026-02-28-spec-gap-diagnostic-verification.md`

### 10.2 v1.5.0 변경사항 (2026-02-24)

| 변경 | 설명 |
|------|------|
| GitHub Spec Kit 전역화 | `github-spec-kit/` → 프로젝트 `.github/` + `scripts/`에 배포 (scope: all) |
| Override Tracking 확장 | templates + github-spec-kit 모두 프로젝트별 커스터마이징 추적 |
| 범용 workflows | Portfolio + GodBlade 장점 결합한 범용 spec-check.yml, spec-change-detector.yml |
| 범용 validate-spec.js | 번호 매김 + 한국어/영어 패턴 지원, Node.js 런타임 불필요 workflow |
| manifest.json v1.2.0 | core 섹션에 github-spec-kit 파일 목록 추가 |

### 10.2 v1.4.0 변경사항 (2026-02-23)

| 변경 | 설명 |
|------|------|
| 전역 배포 모델 | rules/agents/skills/commands/prompts를 `~/.claude/`에 전역 배포 (프로젝트 복사 제거) |
| 프로젝트 배포 축소 | templates만 프로젝트에 배포 (scope: all) |
| docs/shared-docs 배포 중단 | `~/.claude/forge/`에서 직접 참조 |
| Override Tracking 축소 | templates만 대상 (agents/skills는 전역으로 이동) |
| 크로스 프로젝트 기술 문서 전역화 | 범용 기술 문서를 `shared-docs/tech/`로 이동 |
| setup.mjs Step 3 확장 | "Install Rules" → "Install Global Components" |
| ~98개 복사본 제거 | 3개 프로젝트에서 중복 파일 삭제 |

### 10.2 v1.3.0 변경사항 (2026-02-23)

| 변경 | 설명 |
|------|------|
| 원커맨드 셋업 | setup.mjs 7단계 자동 실행 (clone + setup.mjs 2단계로 온보딩 완료) |
| 의존성 자동 설치 | Agent SDK, Agent Teams 활성화, tmux 확인 |
| 크로스 플랫폼 | Windows + Mac 양쪽 지원 (플랫폼 자동 감지) |
| 프로젝트 자동 발견 | 워크스페이스 스캔 → `.claude/` 프로젝트 자동 등록 |
| 글로벌 스킬 3개 추가 | hook-creator, slash-command-creator, subagent-creator |
| CLI 플래그 확장 | `--skip-deps`, `--skip-discover`, 비대화형 모드 |

### 10.2 v1.2.0 변경사항 (2026-02-23)

| 변경 | 설명 |
|------|------|
| Override 자동 추적 | templates/agents/skills의 프로젝트 수정 여부를 해시로 추적 |
| forge-sync-state.json | 프로젝트별 배포 상태 파일 신규 |
| GitHub private repo | `moongci38-oss/forge`으로 팀 공유 |
| setup.mjs | 팀원 부트스트랩 스크립트 |
| manifest.example.json | 플레이스홀더 기반 manifest 템플릿 |
| global-rules/ | 전역 규칙 3개를 repo에 포함 |
| Wave 기반 병렬 실행 | task/plan 템플릿에 의존성 기반 Wave 분류 추가 |

### 10.2 구현된 파일 목록

| 파일 | 작업 |
|------|------|
| `~/.claude/forge/.gitignore` | 신규 — manifest.json 제외 |
| `~/.claude/forge/manifest.example.json` | 신규 — 플레이스홀더 템플릿 |
| `~/.claude/forge/scripts/forge-sync.mjs` | 복사 — 동기화 엔진 v1.2.0 |
| `~/.claude/forge/scripts/session-state.mjs` | 복사 — 세션 상태 CLI |
| `~/.claude/forge/scripts/setup.mjs` | 신규 — 부트스트랩 스크립트 |
| `~/.claude/forge/global-rules/` | 복사 — 전역 규칙 3개 |
| `~/.claude/forge/README.md` | 신규 — 간략 온보딩 가이드 |
| `~/.claude/forge/docs/forge-team-onboarding-guide.md` | 신규 — 이 문서 |
| `business/.gitignore` | 수정 — forge-sync-state.json 추가 |
| `portfolio-project/.gitignore` | 수정 — forge-sync-state.json 추가 |
| `god_Sword/src/.gitignore` | 수정 — forge-sync-state.json 추가 |

### 10.3 v1.4.2 변경사항 (2026-02-24) — Frontend 점진적 품질 루프

| 변경 | 설명 |
|------|------|
| Check 3.6 도구 확장 | `allowed-tools`에 Playwright CLI 4개 도구 + ToolSearch 추가 (반응형 시각 검증 실행 가능) |
| Frontend 점진적 품질 루프 | Phase 3에 컴포넌트 단위 디자인→구현→미리보기→수정 반복 사이클 추가 |
| ui-quality-gate 강화 | 도구 로드 절차 + 반응형 검증 구체 절차 + NanoBanana Visual QA 연계 추가 |
| Walkthrough 시각 검증 | 템플릿에 UI 변경 시 뷰포트별 스크린샷 + 접근성 트리 섹션 추가 |
| Walkthrough 행동 규칙 | 규칙 10 (시각 검증 섹션) + 규칙 11 (점진적 품질 루프) 추가 |

#### Frontend 작업 도구 매트릭스

| 도구 | Tier | Phase | 용도 | Fallback |
| ---- | ---- | ----- | ---- | -------- |
| frontend-design Skill | Core | Phase 3 | 디자인 방향, AI 슬롭 방지 | 없음 (필수) |
| Playwright CLI | Core | Phase 3 + Check 3.6 | 실시간 미리보기, 반응형 검증 | 없음 (필수) |
| Context7 MCP | Core | Phase 3 | React/Next.js 최신 문서 참조 | WebSearch |
| screenshot-capturer | Core | Phase 3 + Walkthrough | 자동 반응형 스크린샷 | Playwright 직접 호출 |
| NanoBanana MCP | Tier 2 | Phase 3 + Check 3.6 | 이미지 생성/편집 + Visual QA | 수동 이미지 준비 |

#### Frontend 점진적 품질 루프

Phase 3에서 UI 구현 시 컴포넌트 단위로 아래 사이클을 반복:

```text
디자인 결정 → 구현 → 이미지 생성 → 시각 확인 → 조정 → 다음 컴포넌트
```

- frontend-design Skill로 디자인 방향 결정
- Context7 MCP로 최신 라이브러리 문서 참조
- NanoBanana MCP로 이미지 에셋 생성
- Playwright CLI로 3+ 뷰포트 시각 확인
- 문제 발견 시 즉시 수정 후 재확인

### 10.4 v1.4.3 변경사항 (2026-02-25) — Check 3.5T 테스트 품질 게이트

| 변경 | 설명 |
|------|------|
| Check 3.5T 신설 | 테스트 품질/포괄성 검증 게이트 (5축: Integration Test, Error Case, Spec 매핑, 격리, 커버리지) |
| `test-quality-checker.md` 에이전트 | read-only Sonnet Subagent — Check 3.5 출력을 입력으로 순차 실행 |
| `forge-test-quality.md` 규칙 | Teammate 행동 규칙 + Lead 검증 규칙 정의 |
| `test-quality-config.json` 템플릿 | 프로젝트별 테스트 설정 (`.specify/test-quality-config.json`에 배치) |
| Check 3.5 출력 확장 | `testType`, `relatedDescribeBlocks` 필드 추가 (하위 호환) |
| autoFix 카운터 통합 | Check 3 ↔ 3.5 ↔ 3.5T 합산 3회 제한 |
| 프로젝트 불가지론 | `.specify/test-quality-config.json` 미존재 시 SKIP (비개발 영향 없음) |

### 10.5 v1.4.2 변경사항 (2026-02-24) — Frontend 점진적 품질 루프

> 기존 10.3 → 10.5로 이동

### 10.6 v1.4.1 변경사항 (2026-02-24) — Lead 파이프라인 고도화

| 변경 | 설명 |
|------|------|
| Check 3.5 Subagent 격리 | `forge-check-traceability` 커맨드 신설 → 3.6/3.7/3.8과 4개 병렬 실행 |
| Check 4 폐지 | 커밋/브랜치 규칙 검증을 Check 3 (`verify.sh code`)에 통합 |
| Walkthrough 위임 | `technical-writer` Subagent에 Walkthrough 초안 작성 위임 (권장) |
| Walkthrough + Check 3 병렬 | 구현 완료 후 Walkthrough와 Check 3를 동시 실행 가능 |
| spec-compliance-checker JSON | Check 3.5 출력 형식을 Markdown → JSON으로 변경 (Subagent 격리 규칙 준수) |

### 10.4 GitHub Repository

- **URL**: `git@github.com:moongci38-oss/forge.git`
- **Visibility**: Private
- **Branch**: master

---

## 11. 트러블슈팅

### 11.1 setup.mjs 에러

| 에러 메시지 | 원인 | 해결 |
|------------|------|------|
| `Node.js 18+ required (current: 16.x)` | Node.js 버전 낮음 | [nodejs.org](https://nodejs.org)에서 LTS 설치. Mac: `brew install node` |
| `~/.claude/ not found` | Claude Code 미설치 | `npm install -g @anthropic-ai/claude-code && claude` |
| `manifest.example.json not found` | repo 불완전 clone | `cd ~/.claude/forge && git pull` 후 재시도 |
| `Agent SDK 설치 실패` | npm 권한 부족 | Mac/Linux: `sudo npm install -g`, Windows: 관리자 터미널 |
| 워크스페이스 경로 존재하지 않음 | 잘못된 경로 입력 | `rm ~/.claude/forge/manifest.json` 후 재실행 |
| `forge이 잘못된 경로에 clone되었습니다` | PowerShell에서 `~` 미확장 | 잘못된 폴더 삭제 후 `$HOME`으로 재clone (아래 11.5 참조) |

### 11.2 forge-sync 에러

| 에러/증상 | 원인 | 해결 |
|----------|------|------|
| `target 'xxx' not found in manifest` | manifest.json에 미등록 | `forge-sync init`으로 등록 |
| `path not found: /path/to/project` | 프로젝트 경로 오류 또는 드라이브 미마운트 | manifest.json 경로 확인, WSL 마운트 확인 |
| `workspace 'xxx' not found` | 워크스페이스 키 오타 | `forge-sync list`로 유효 키 확인 |
| `path already registered as 'yyy'` | 같은 경로가 다른 이름으로 등록됨 | `forge-sync remove yyy` 후 재등록 |
| `(project override)` 계속 표시 | 프로젝트에서 파일을 직접 수정 | 의도적이면 무시. 전역 반영 원하면 해당 파일 삭제 후 재동기화 |

### 11.3 Git/SSH 이슈

| 증상 | 원인 | 해결 |
|------|------|------|
| `Repository not found` | SSH 키가 다른 GitHub 계정에 연결 | `ssh -T git@github.com`으로 인증 계정 확인 |
| `Permission denied (publickey)` | SSH 키 미등록 | `ssh-keygen` → GitHub Settings → SSH Keys에 등록 |
| gh CLI와 SSH 계정 불일치 | 별개 인증 시스템 | `gh auth status`로 확인, `gh auth switch --user <name>` |

### 11.4 Windows PowerShell: `~` 경로 문제

PowerShell에서 `git clone ... ~/.claude/forge`을 실행하면 `~`가 홈 디렉토리로 확장되지 않고, **현재 디렉토리에 리터럴 `~` 폴더**가 생성됩니다.

**증상:**

```text
PS C:\git\myproject> git clone ... ~/.claude/forge
Cloning into '~/.claude/forge'...    ← 리터럴 ~ 폴더 생성!
```

`ls`를 실행하면 `~` 디렉토리가 보입니다.

**해결:**

```powershell
# 1. 잘못 생성된 폴더 삭제
Remove-Item -Recurse -Force "~"

# 2. $HOME으로 다시 clone
git clone git@github.com:moongci38-oss/forge.git "$HOME\.claude\forge"

# 3. setup 실행
node "$HOME\.claude\forge\scripts\setup.mjs"
```

> setup.mjs가 잘못된 경로를 감지하면 자동으로 에러 메시지와 올바른 명령어를 안내합니다.

### 11.5 FAQ

**Q: manifest.json을 실수로 커밋했어요.**
A: `manifest.json`은 `.gitignore`에 있으므로 일반적으로 커밋되지 않습니다. 만약 추적 중이라면:
```bash
git rm --cached manifest.json
git commit -m "chore: remove manifest.json from tracking"
```

**Q: 프로젝트에서 수정한 템플릿을 전역으로 역반영하고 싶어요.**
A: 프로젝트의 수정된 파일을 `~/.claude/forge/templates/`에 복사하고, forge repo에 commit + push하세요.

**Q: 새 워크스페이스를 추가하고 싶어요.**
A: `manifest.json`의 `workspaces` 섹션에 새 키를 추가하세요. 팀 공유 불필요 (manifest는 git 추적 안 됨).

**Q: forge-sync가 배포한 파일인지 내가 만든 파일인지 어떻게 구분해요?**
A: `forge-sync status`로 배포된 파일 목록을 확인하거나, `forge-sync diff <target>`으로 차이를 비교하세요.
