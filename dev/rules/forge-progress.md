---
title: "진행 관리 규칙"
id: forge-progress
impact: MEDIUM
scope: [forge]
tags: [progress, pm, auto-update, notion, mapping]
requires: [forge-session-state]
section: forge-process
audience: dev
impactDescription: "미준수 시 PM 문서와 실제 진행상태 불일치, 매핑 실패로 todo.md 갱신 누락, 외부 도구와 역동기화로 데이터 충돌"
enforcement: flexible
---

# Progress Auto-Management Rules

## 개요

AI 에이전트(`forge-pm-updater`)가 Phase 전환 시 PM 문서(todo.md, development-plan.md)의 진행상태를 갱신한다.

> **실행 주체**: `forge-pm-updater` 에이전트 (Haiku). AI가 Phase 전환/세션 이벤트 시 수동으로 스폰한다.
>
> **실행 모델**: AI가 Forge Dev 파이프라인을 실행하는 동안 Phase 전환 시점에 `forge-pm-updater`를 서브에이전트로 수동 스폰한다. 스폰하지 못하는 경우 Human이 직접 PM 문서를 갱신한다.

## 상태 전환

```
⬜ pending → 🔄 in-progress → ✅ completed
              ↖── 재작업 시 ──↙
```

## AI 에이전트 트리거

아래는 AI 에이전트가 Phase 전환 시 수행하는 행동 규칙이다. AI가 수동으로 `forge-pm-updater`를 스폰하거나, Human이 직접 문서를 갱신한다.

| 이벤트 | 행동 | 상태 변경 |
|--------|------|----------|
| 브랜치 생성 (`feat/xxx`) | `forge-pm-updater` 수동 스폰 → 매핑 조회 → 문서 갱신 | 관련 항목 → 🔄 in-progress |
| PR merge to develop | `forge-pm-updater` 수동 스폰 → 매핑 조회 → 문서 갱신 | 관련 항목 → ✅ completed |
| 재작업 (같은 브랜치 재생성) | `forge-pm-updater` 수동 스폰 → 매핑 조회 → 문서 갱신 | 관련 항목 → 🔄 in-progress |
| **Spec 신규 작성 (Phase 2)** | todo.md `## Forge Dev 개발 진행` 테이블에 신규 행 추가 | ⬜ Todo |

> Forge Dev 파이프라인 밖에서 브랜치를 생성하거나 PR을 merge한 경우, Human이 직접 todo.md의 체크박스/상태를 변경해야 한다.

## Phase Checkpoint 연동

| Checkpoint | 진행 상태 영향 |
|-----------|--------------|
| `phase1_complete` | 관련 항목 → 🔄 |
| `phase1.5_complete` | — |
| `phase2_complete` | — |
| `phase3_complete` | — |
| `session_complete` | 관련 항목 → ✅ |

## Forge Todo 자동 연동

모든 프로젝트는 `docs/planning/active/forge/todo.md`에 Todo Tracker가 존재한다. Todo는 **스펙 단위 칸반 테이블**로 구성되며, Forge Dev 세션 진행 시 AI가 상태를 자동 갱신한다.

### GitHub Actions 자동 갱신

`todo-tracker.yml` 워크플로가 브랜치 생성/PR merge 시 todo.md를 자동 갱신한다.

- **Source of Truth**: `~/.claude/forge/github-spec-kit/workflows/todo-tracker.yml`
- **의존 스크립트**: `~/.claude/forge/github-spec-kit/scripts/update-todo.py`
- **배포 위치**: 프로젝트의 `.github/workflows/todo-tracker.yml` + `.github/scripts/update-todo.py`

> **⚠️ todo.md는 반드시 실제 파일이어야 한다** — 심볼릭 링크로 관리하면 GitHub Actions의 `find`가 파일을 찾지 못해 자동 갱신이 스킵된다.
> 워크플로의 `find`는 `-type f -o -type l` (파일+심볼릭 링크)을 모두 탐지하도록 방어적 설계되어 있으나, GitHub Actions runner에서는 심볼릭 링크 대상이 존재하지 않아 실패한다.
> **따라서 todo.md는 항상 실제 파일로 커밋해야 한다.**

### 칸반 테이블 구조

```markdown
## Forge Dev 개발 진행

| # | Spec | Session | SP | Status | PR | 완료일 |
|:-:|------|:-------:|:--:|:------:|:--:|:------:|
| 1 | {Spec 이름} | S{N} | {SP} | ⬜ Todo | — | — |
```

- **Standard 세션**: 세션 = Spec 1개 = 행 1개

### 상태 전환 (3단계, AI 자동 감지)

| 이벤트 | Status 변경 | 감지 주체 |
|--------|:----------:|:---------:|
| 브랜치 생성 | ⬜ Todo → 🔄 Doing | AI (직접 실행) |
| Check 3 진입 | 🔄 Doing → 🧪 QA | AI (직접 실행) |
| PR Merge 완료 | 🧪 QA → ✅ Done + PR 번호 + 완료일 기록 | AI (감지) |

### 감지 방법

1. `docs/planning/active/forge/todo.md` 존재 여부 확인
2. 존재 시 `## Forge Dev 개발 진행` 섹션의 칸반 테이블 탐색
3. 현재 작업 중인 Spec 이름과 매칭되는 행의 Status/PR/완료일 컬럼을 갱신

### Fallback

- `todo.md`가 존재하지 않으면 경고 출력 후 이 규칙은 스킵
- 갱신 실패 시 세션 종료 보고에 "Todo 갱신 실패" 포함

## 매핑 파일

`.claude/todo-mapping.json`에 브랜치명 ↔ 문서 항목 매핑이 정의된다.

### 자동 생성

매핑은 두 곳에서 AI가 자동 생성한다:

1. **Phase 2 문서 작성 시**: Spec 초기화 시 계획서를 스캔하여 매핑 자동 생성
2. **fallback**: 매핑이 없을 때 계획서에서 키워드 매칭으로 자동 생성

### 자동 감지 실패 시 수동 매핑 가이드

**[STOP] Human 개입 필요** — 아래 징후가 나타나면 자동 감지가 실패한 것이다:

#### 실패 징후 체크리스트

- [ ] AI가 "매핑을 찾을 수 없습니다"라고 보고함
- [ ] Phase 전환 후 todo.md가 갱신되지 않음
- [ ] 브랜치명이 계획서의 어떤 항목과도 키워드 매칭되지 않음
- [ ] 계획서가 비표준 형식이거나 항목 번호가 없음
- [ ] todo-mapping.json 파일 자체가 프로젝트에 존재하지 않음

#### 수동 매핑 방법

1. 프로젝트의 `.claude/todo-mapping.json` 파일을 열거나 생성한다
2. 아래 JSON 스키마에 따라 브랜치명을 키로 매핑을 추가한다
3. 저장 후 다음 Phase 전환부터 AI 에이전트가 매핑을 참조한다

#### 매핑 JSON 스키마

```json
{
  "<branch-name>": {
    "phase": <number>,
    "description": "<작업 설명>",
    "items": {
      "todo.md": ["<항목번호>", ...],
      "상세계획서": ["<항목번호>", ...]
    }
  }
}
```

#### 필드 설명

| 필드 | 타입 | 설명 |
|------|------|------|
| `<branch-name>` (키) | string | Git 브랜치명에서 prefix 제거 (예: `feat/auth-login` → `auth-login`) |
| `phase` | number | 해당 작업이 속한 Phase 번호 |
| `description` | string | 작업 설명 (자동 생성 시 계획서에서 추출) |
| `items.todo.md` | string[] | todo.md에서 갱신할 항목 번호 목록 |
| `items.상세계획서` | string[] | 상세계획서에서 갱신할 항목 번호 목록 |

#### 실제 예시 (Portfolio 프로젝트)

```json
{
  "ai-chatbot": {
    "phase": 3,
    "description": "Phase 3.1 - AI Chatbot MVP (Claude API + WebSocket + Chat UI)",
    "items": {
      "todo.md": ["3.1.1", "3.1.2", "3.1.3", "3.1.4"],
      "상세계획서": ["3.1.1", "3.1.2", "3.1.3", "3.1.4"]
    }
  },
  "project-showcase": {
    "phase": 4,
    "description": "Phase 4.2 - Project Showcase (목록/상세/갤러리/조회수 트래킹)",
    "items": {
      "todo.md": ["4.2.1", "4.2.2", "4.2.3", "4.2.4", "4.2.5"],
      "상세계획서": ["4.2.1", "4.2.2", "4.2.3", "4.2.4", "4.2.5"]
    }
  }
}
```

> **참고**: `items`의 키 이름(`todo.md`, `상세계획서`)은 프로젝트마다 다를 수 있다. 실제 PM 문서 파일명에 맞춰 지정한다.

## PM 문서 자동 갱신

`forge-pm-updater` 에이전트가 Phase 전환 시 PM 문서를 갱신한다:

| 이벤트 | todo.md | development-plan.md |
|--------|:-----------:|:-------------------:|
| 세션 시작 (init) | - | 새 세션 항목 추가 |
| Phase 전환 (checkpoint) | 체크박스 완료 변경 | Phase 상태 업데이트 |
| Check 결과 | 결과 기록 | - |
| 세션 완료 (complete) | PR 번호 기록 | 완료 상태 + 소요 시간 |

## 외부 PM 도구 연동

### Source of Truth

**로컬 `todo.md`가 유일한 Source of Truth**이다. 외부 도구는 읽기/반영 대상이지, 역방향으로 로컬 문서를 덮어쓰지 않는다.

```
todo.md (Source of Truth) ──push──→ Notion DB / Jira / etc.
                               ←read── (참조만, 역동기화 금지)
```

### Notion MCP (현재 활성)

Notion MCP가 연결되어 있으므로 진행상태를 Notion DB에 반영할 수 있다.

**권장 패턴**:

1. Notion에 프로젝트 진행상태 DB 생성 (Status, Phase, PR 컬럼)
2. `forge-pm-updater`가 todo.md 갱신 후 → Notion DB에도 동일 상태 push
3. Notion은 팀/이해관계자 공유 대시보드 용도로만 사용

**AI 행동**:
- Notion DB 업데이트 시 `mcp__*_notion__notion-update-page` 사용
- Notion → todo.md 역동기화는 수행하지 않음

### 기타 도구 (향후 MCP 확장 시)

| 도구 | MCP 추가 시 연동 방법 | 현재 상태 |
|------|---------------------|----------|
| **Jira** | Jira MCP → 이슈 상태 동기화 | 미연동 |
| **Linear** | Linear MCP → 이슈 상태 동기화 | 미연동 |
| **Trello** | Trello MCP → 카드 상태 동기화 | 미연동 |
| **Slack** | Slack MCP → Phase 전환 알림 전송 | 미연동 |

> 새 MCP 연동 시에도 Source of Truth 원칙은 동일하게 적용한다. todo.md → 외부 도구 단방향 push만 허용.

### 양방향 동기화 금지 사유

- 외부 도구에서 상태를 변경하면 todo.md와 불일치 발생
- 충돌 해소 로직이 없으므로 데이터 손실 위험
- Git 이력으로 추적 가능한 로컬 파일이 가장 신뢰할 수 있는 소스

## Worktree 환경에서의 todo.md 갱신

Git worktree에서 작업할 때 todo.md 갱신에 특별한 주의가 필요하다.

### 문제점

- Worktree는 feature 브랜치에서 동작하며, todo.md는 `develop` 브랜치의 메인 워크스페이스에 존재한다
- Worktree 내부 경로 (`./docs/planning/active/forge/todo.md`)는 feature 브랜치의 복사본이므로, 여기를 수정해도 develop에 반영되지 않는다
- Worktree 에이전트는 `git checkout develop`이 불가하다 (이미 메인 워크스페이스에서 체크아웃됨)

### 해결: 절대 경로로 메인 워크스페이스 직접 접근

**메인 워크스페이스의 todo.md 절대 경로**를 사용하여 직접 수정한다:

```
# 메인 워크스페이스 경로 (git worktree list로 확인 가능)
{MAIN_WORKSPACE}/docs/planning/active/forge/todo.md
```

### 갱신 책임자

| 실행 환경 | todo.md 갱신 주체 | 접근 방법 |
|-----------|:-----------------:|----------|
| **메인 워크스페이스** (일반 작업) | AI (직접) | 상대 경로 `./docs/planning/active/forge/todo.md` |
| **Worktree** (Lead 세션) | Lead (직접) | 절대 경로로 메인 워크스페이스의 todo.md 수정 |
| **Worktree** (서브에이전트) | Lead가 완료 후 수행 | 서브에이전트는 todo.md 갱신하지 않음 |

### Worktree에서의 갱신 프로토콜

```
1. 메인 워크스페이스 경로 확인:
   git worktree list | head -1 | awk '{print $1}'

2. todo.md 절대 경로 구성:
   {MAIN_WS_PATH}/docs/planning/active/forge/todo.md

3. todo.md 읽기 → Forge Dev 개발 진행 테이블의 해당 행 갱신

4. 갱신 내용 (PR merge 후):
   - Status: ✅ Done
   - PR: [#{번호}](URL)
   - 완료일: YYYY-MM-DD
```

> **주의**: 메인 워크스페이스의 todo.md를 수정하면 develop 브랜치의 working directory에 변경이 생긴다. 이 변경은 다음 develop 커밋 시 포함하거나, 별도 `docs/update-todo` 브랜치로 커밋할 수 있다. **Git staged 상태를 오염시키지 않도록 주의**.

## AI 에이전트 행동 규칙

1. **브랜치 생성 직후**: `forge-pm-updater` 스폰 → 진행 상태 업데이트
2. **PR 생성 전**: 문서 상태 확인 (todo.md의 체크박스가 현재 Phase까지 완료되었는지)
3. **PR merge 후**: `forge-pm-updater` 스폰 → 완료 상태 업데이트
4. **재작업 시**: `forge-pm-updater` 스폰 → in-progress로 복귀
5. **매핑 자동 감지 실패 시**: **[STOP]** Human에게 "todo-mapping.json에 수동 매핑이 필요합니다"라고 알리고, 위의 수동 매핑 가이드를 안내한다. 매핑 없이 todo.md를 추측으로 갱신하지 않는다.
6. **외부 PM 도구 연동 시**: todo.md 갱신 완료 후에만 외부 도구에 push한다. 외부 도구 갱신 실패는 경고만 출력하고 파이프라인을 중단하지 않는다.
7. **Worktree 환경**: 위 "Worktree에서의 갱신 프로토콜" 참조. 반드시 메인 워크스페이스의 절대 경로로 갱신한다.
8. **Phase 2 Spec 작성 완료 시**: todo.md의 해당 섹션에 `⬜ Todo` 상태로 항목을 추가한다. Spec 파일명과 Spec 제목을 기반으로 행을 생성한다.
