---
description: "Forge Dev Phase 7 — 롤백 실행 (L1/L2/L3)"
model: sonnet
---

Forge Dev Phase 7 롤백을 실행합니다. 배포 실패 시 아래 레벨 중 선택하세요.

## 롤백 레벨 선택 가이드

| 레벨 | 적용 시점 | 설명 |
|------|----------|------|
| **L1 Quick Revert** | 실패 후 < 30분 | 최근 커밋만 `git revert` — 가장 빠름 |
| **L2 Release Revert** | 실패 후 < 2시간 | 이전 릴리스 태그로 완전 복구 + 재배포 |
| **L3 Hotfix Forward** | 실패 후 > 2시간 | `hotfix/*` 브랜치 생성 → Forge Dev Hotfix 플로우 재진입 |

## 실행 방법

### L1 Quick Revert

```bash
gh workflow run rollback.yml \
  -f reason="<실패 원인 간략 설명>" \
  -f level="L1-quick-revert"
```

### L2 Release Revert

```bash
gh workflow run rollback.yml \
  -f reason="<실패 원인 간략 설명>" \
  -f level="L2-release-revert" \
  -f target_version="<복구할 버전, 예: 1.1.0>"
```

### L3 Hotfix Forward

```bash
gh workflow run rollback.yml \
  -f reason="<실패 원인 간략 설명>" \
  -f level="L3-hotfix-forward"
```

L3 실행 후 생성된 `hotfix/*` 브랜치를 checkout하고 Forge Dev Hotfix 플로우로 진입:

```bash
# L3 실행 후 — rollback.yml Step Summary에서 브랜치명 확인
gh run view --workflow rollback.yml --log | grep "Hotfix branch"
git fetch origin
git checkout hotfix/rollback-<timestamp>
```

## 롤백 상태 확인

```bash
gh run list --workflow rollback.yml --limit 3
```
