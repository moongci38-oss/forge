---
description: Forge Dev 동기화 상태 + 세션 상태 확인
allowed-tools: Bash, Read
argument-hint: [--quiet]
model: haiku
---

# /forge-status — Forge Dev 상태 확인

Forge Dev 동기화 상태와 현재 세션 상태를 한눈에 확인합니다.

## 실행

```bash
# 동기화 상태 확인
node ~/.claude/scripts/forge-sync.mjs status

# 세션 상태 확인
node ~/.claude/scripts/session-state.mjs list

# 조용한 모드 (불일치만 출력)
node ~/.claude/scripts/forge-sync.mjs status --quiet
```

## 출력 예시

```
Forge Dev 동기화 상태
─────────────────
  my-web-app: ✅ 동기화됨 (7/7 rules, 1/1 prompts, ...)
  my-game:    ⚠️ 2개 불일치
    - forge-workflow.md (원본 newer)
    - forge-progress.md (원본 newer)
  → 동기화: /forge-sync --target my-game

세션 상태
─────────
  현재 세션: feature-auth (phase3)
  autoFix: 1/3
```
