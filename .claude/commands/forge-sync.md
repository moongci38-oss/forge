---
description: Forge Dev 중앙 저장소에서 프로젝트로 동기화
allowed-tools: Bash, Read
argument-hint: [--target <name>] [--include-recommended] [--dry-run]
model: haiku
---

# /forge-sync — Forge Dev 동기화

`~/.claude/forge/` 원본 저장소의 Core 구성요소를 프로젝트에 배포합니다.

## 동기화

```bash
# 전체 프로젝트 동기화
node ~/.claude/scripts/forge-sync.mjs sync

# 특정 프로젝트만
node ~/.claude/scripts/forge-sync.mjs sync --target portfolio

# Recommended 포함
node ~/.claude/scripts/forge-sync.mjs sync --include-recommended

# 변경 사항만 확인 (실제 복사 안 함)
node ~/.claude/scripts/forge-sync.mjs sync --dry-run
```

## 등록 목록 조회

```bash
# 전체 target 목록 (워크스페이스별 그룹)
node ~/.claude/scripts/forge-sync.mjs list

# 특정 워크스페이스만 필터
node ~/.claude/scripts/forge-sync.mjs list --workspace wsl
```

## 새 프로젝트 온보딩

```bash
# 1. 등록 (scope, description, workspace 지정)
node ~/.claude/scripts/forge-sync.mjs init /path/to/project \
  --name my-project \
  --scope all \
  --description "프로젝트 설명" \
  --workspace wsl

# 2. forge 배포
node ~/.claude/scripts/forge-sync.mjs sync --target my-project --include-recommended

# 3. 프로젝트별 설정 (수동)
#    - CLAUDE.md 작성
#    - .specify/ 디렉토리 생성
#    - .claude/rules/agent-teams.md 파일 소유권 정의
#    - verify.sh 작성
```

**워크스페이스 키:**

- `wsl` — `Z:/home/damools/mywsl_workspace` (Linux/WSL 프로젝트)
- `windows` — `E:/new_workspace` (Windows 프로젝트)
- `business` — `Z:/home/damools/forge` (비개발, shared-only)

## 동작 규칙

- 해시 비교로 변경분만 복사
- **Override 자동 업데이트** (v1.2.0): templates/agents/skills 카테고리
  - 프로젝트별 `.claude/forge-sync-state.json`에 배포 시점 해시 기록
  - 프로젝트가 수정하지 않은 파일 → 전역 소스 변경 시 자동 업데이트 `(auto)`
  - 프로젝트가 직접 커스터마이징한 파일 → 스킵 `(project override)`
  - 첫 실행 시 해시 초기화 (1회 스킵), 이후부터 자동 추적
- Recommended는 `init` 시 자동 복사, `sync` 시 기존 있으면 스킵
- `shared-only` scope: shared-docs만 배포 (core/recommended 제외)
