---
name: forge-onboard
description: 신규 프로젝트를 Forge 파이프라인에 온보딩하는 스킬. forge-sync 등록 → 규칙/템플릿 배포 → CLAUDE.md/constitution 스캐폴딩 → forge-workspace.json 연결까지 4단계 자동화. 새 프로젝트 추가, 프로젝트 온보딩, forge 등록, 프로젝트 초기 설정 요청 시 사용.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent
context: fork
---

# Forge Onboard — 신규 프로젝트 온보딩

신규 프로젝트를 Forge 파이프라인에 등록하고 개발 환경을 완성하는 4단계 자동화 스킬.

## 실행 전 수집 정보

아래 정보를 사용자에게 확인한다. 대부분은 경로만 알면 자동 추론 가능.

| 항목 | 예시 | 필수 |
|------|------|:----:|
| 프로젝트 경로 | `/home/user/my-project` | **필수** |
| 프로젝트 이름 | `my-project` (kebab-case) | **필수** |
| 프로젝트 유형 | `web` / `game` | **필수** |
| 설명 | "Next.js SaaS 플랫폼" | 권장 |
| 워크스페이스 | `wsl` / `windows` | 경로에서 추론 |
| 테크 스택 | 자동 탐지 (package.json, .csproj 등) | 자동 |
| 기획 도메인 | forge-workspace.json의 symlinkBase | 권장 |

### 워크스페이스 자동 추론

```
{YOUR_WSL_WORKSPACE}/* → wsl
/mnt/e/* 또는 E:/* → windows
```

## Phase 1: forge-sync 등록

### 1.1 manifest.json에 타겟 등록

```bash
node ~/.claude/scripts/forge-sync.mjs init <project-path> \
  --name <project-name> \
  --scope all \
  --description "<description>" \
  --workspace <wsl|windows>
```

이 명령이 자동으로:
- `forge/dev/manifest.json`에 타겟 추가
- `.specify/config.json` 생성 (없으면)

### 1.2 .specify/config.json 보강

자동 생성된 config.json을 프로젝트에 맞게 보강한다:

```json
{
  "projectName": "MyProject",
  "projectType": "web|game",
  "autoMerge": false,
  "branchPrefix": {
    "feature": "feat/",
    "fix": "fix/",
    "hotfix": "hotfix/"
  },
  "defaultBranch": "develop",
  "specNaming": "{feature-name}.spec.md",
  "notion": {
    "projectName": "MyProject",
    "tasksDbId": "<forge-workspace.json에서 자동 추출>"
  }
}
```

게임 프로젝트 추가 필드:
```json
{
  "engine": "Unity",
  "buildSystem": "msbuild",
  "language": "csharp"
}
```

## Phase 2: forge-sync 배포

```bash
node ~/.claude/scripts/forge-sync.mjs sync --target <project-name> --include-recommended
```

배포되는 항목:

| 카테고리 | 경로 | 내용 |
|---------|------|------|
| Dev Rules | `.claude/rules/forge-*.md` | 워크플로, 세션, 테스트, 성능 등 14개 |
| 공통 Rules | `.claude/rules/` | frontend-standards, plan-mode, pr-code-review-gate |
| Templates | `.specify/templates/` | Spec/Plan/Task/Walkthrough 템플릿 |
| GitLab Spec Kit | `.gitlab/` + `scripts/` | CI 워크플로, 이슈/PR 템플릿 |
| Hooks (recommended) | `.claude/hooks/` | 보안 체크, JSON 무결성 |

### Windows(NTFS) 프로젝트 대응

`forge-sync`가 EPERM 에러 시 수동 복사로 대체:

```bash
for f in ~/.claude/forge/rules/*.md; do
  cp "$f" "<project-path>/.claude/rules/$(basename $f)" 2>/dev/null
done
```

## Phase 3: 프로젝트 스캐폴딩

forge-sync가 배포하지 않는 프로젝트 고유 파일을 생성한다.

### 3.1 CLAUDE.md

프로젝트 루트에 CLAUDE.md를 생성한다. 기존 파일이 있으면 Forge 참조만 추가.

**필수 섹션:**
- Project Context (테크 스택, 핵심 기능)
- Quick Start (빌드/실행 명령)
- Golden Rules (Do's / Don'ts)
- Development Methodology: SDD (Forge Dev 파이프라인 기반)
- Git Workflow (브랜치 전략)
- Key Documents (Forge 파이프라인 참조 포함)

테크 스택은 프로젝트에서 자동 탐지:
- `package.json` → Node.js/React/Next.js/NestJS
- `*.csproj` / `*.sln` → C#/.NET/Unity
- `Cargo.toml` → Rust
- `go.mod` → Go
- `requirements.txt` / `pyproject.toml` → Python

### 3.2 .specify/constitution.md

프로젝트 헌법. 탐지된 테크 스택 기반으로 스캐폴딩:

**필수 섹션:**
1. 프로젝트 개요
2. 기술 스택
3. 코딩 표준
4. 아키텍처 패턴
5. 테스트 표준
6. SDD 워크플로우

### 3.3 .claude/rules/agent-teams.md

Agent Teams 파일 소유권 정의. 프로젝트 구조에 맞게 생성:

**Web (모노레포):**
```markdown
| Role | 담당 | 모델 |
|------|------|------|
| Team Lead | SDD 게이트, Shared 파일 | 현재 세션 |
| Backend | apps/api/src/** | Sonnet 4.6 |
| Frontend | apps/web/src/** | Sonnet 4.6 |
```

**Game:**
```markdown
| Role | 담당 | 모델 |
|------|------|------|
| Team Lead | SDD 게이트, 공통 로직 | 현재 세션 |
| Server | server/**, common/** | Sonnet 4.6 |
| Client | client/Assets/** | Sonnet 4.6 |
```

### 3.4 verify.sh

빌드+테스트 검증 스크립트. 테크 스택에 따라 생성:

**Web (Node.js):**
```bash
#!/bin/bash
set -e
pnpm lint
pnpm build
pnpm test
```

**Game (Unity/.NET):**
```bash
#!/bin/bash
set -e
cd common && msbuild *.sln /p:Configuration=Release
cd ../server && msbuild *.sln /p:Configuration=Debug
```

### 3.5 docs/ 폴더 구조

`docs-structure.md` 전역 규칙에 따라 생성:

```bash
mkdir -p docs/{guides,tech,planning/{active/forge,done},reviews,infrastructure,walkthroughs,assets,references,_archive}
```

### 3.5 Inspector Reference Sheet

`forge/planning/templates/inspector-reference-template.md`를 `docs/references/inspector-reference.md`에 복사한다.

```bash
cp ~/forge/planning/templates/inspector-reference-template.md <project-path>/docs/references/inspector-reference.md
```

프로젝트 유형에 따라 초기 값 조정:
- **game (Unity/NGUI)**: Canvas Scaler, UIRect anchor, ParticleSystem 섹션 활성
- **game (Unity/UGUI)**: RectTransform, Canvas Scaler, Animator 섹션 활성
- **web (React/Next.js)**: CSS props, design tokens, responsive breakpoints 섹션으로 변환

> 이 시트는 AI-Human 분업의 핵심. AI가 Spec/코드 작성 시 이 시트를 참조하고, Human이 에디터/브라우저에서 교정한 값을 누적한다.

## Phase 4: forge-workspace.json 연결

`forge/forge-workspace.json`의 `projects`에 등록하여 기획 파이프라인(Phase 1~5) 산출물이 프로젝트에 연결되도록 한다.

```json
{
  "projects": {
    "<project-name>": {
      "devTarget": "<project-path>",
      "symlinkBase": "docs/planning/active/forge/<domain>"
    }
  }
}
```

게임 프로젝트 추가 필드:
```json
{
  "projectType": "game",
  "projectScale": "Small"
}
```

## 완료 체크리스트

모든 단계 완료 후 아래를 검증한다:

```
[ ] manifest.json에 타겟 등록 확인
[ ] .specify/config.json 존재 + Notion DB 연결
[ ] .claude/rules/forge-*.md 14개 배포 확인
[ ] .specify/templates/ 배포 확인
[ ] CLAUDE.md 존재 + Forge 참조 포함
[ ] .specify/constitution.md 존재
[ ] .claude/rules/agent-teams.md 존재
[ ] verify.sh 존재 + 실행 권한
[ ] docs/ 폴더 구조 생성
[ ] forge-workspace.json에 프로젝트 등록
[ ] forge-sync status 확인
```

```bash
node ~/.claude/scripts/forge-sync.mjs status
```

## 주의사항

- 기존 파일이 있으면 덮어쓰지 않는다 (CLAUDE.md, constitution.md 등)
- 기존 파일에 Forge 참조가 없으면 추가만 한다
- `.env`, credentials 등 민감 파일은 생성하지 않는다
- 프로젝트 고유 규칙(agent-teams.md 등)은 템플릿 생성 후 사용자 확인을 받는다
- Notion Projects DB에 프로젝트를 등록할지는 사용자에게 확인한다
