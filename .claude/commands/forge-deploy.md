---
description: "Forge Dev Phase 7 — 프로덕션 배포 상태 확인 및 수동 트리거"
model: haiku
---
> **⚠️ 실행 모드 확인**: 이 커맨드는 쓰기 모드에서만 정상 동작합니다. Plan mode 감지 시 즉시 [STOP] — "Escape로 plan mode 해제 후 재실행하세요. 내부 [STOP] 게이트가 승인 지점입니다."


Forge Dev Phase 7 프로덕션 배포를 확인하거나 수동으로 트리거합니다.

## 자동 트리거 (권장)

Phase 7은 Release PR이 main에 merge되면 자동으로 `production-deploy.yml`이 실행됩니다.
별도 명령 불필요 — GitLab CI/CD → Pipelines에서 진행 상황을 확인하세요.

```bash
# 최신 production-deploy 실행 상태 확인
glab ci list
```

## 수동 트리거

배포 인프라가 없거나 build artifacts만 생성하려면:

```bash
glab ci run --branch main -v SKIP_DEPLOY=true
```

deployCommand가 설정된 경우 전체 배포 실행:

```bash
glab ci run --branch main
```

## 배포 결과 확인

```bash
# 최신 GitLab Release 확인
glab release list --per-page 5

# 최신 태그 확인
git tag --sort=-creatordate | head -5
```

## 실패 시

배포 실패 → `/forge-rollback`으로 롤백 레벨 선택:
- **L1** (< 30분): Quick Revert — 최근 커밋 revert
- **L2** (< 2시간): Release Revert — 이전 태그로 재배포
- **L3** (> 2시간): Hotfix Forward — hotfix 브랜치에서 수정 후 재배포
