---
description: "Forge Dev Phase 6 — 릴리스 브랜치 생성 + 스테이징 배포 + Release PR"
---

Forge Dev Phase 6 릴리스 파이프라인을 시작합니다.

## 사용법

```
/forge-release <version>
예: /forge-release 1.2.0
```

## 전제 조건 확인

아래 항목을 먼저 확인해주세요:

1. **Phase 5 PASS**: develop 브랜치의 `develop-integration.yml` 워크플로우가 green인지 확인
   ```bash
   gh run list --branch develop --workflow develop-integration.yml --limit 1
   ```
2. **release-config.json 존재**: 프로젝트 루트에 `release-config.json`이 있는지 확인 (없으면 템플릿 복사)
   ```bash
   ls release-config.json || echo "Missing — copy from forge template"
   ```

## 실행 방법

Phase 6는 GitHub Actions `workflow_dispatch`로 트리거합니다:

```bash
# GitHub CLI로 트리거
gh workflow run release-staging.yml \
  -f version=<version> \
  -f deploy_staging=true
```

또는 GitHub Actions 탭 → `Release + Staging` → `Run workflow`에서 수동 실행.

## 결과 확인

```bash
# 워크플로우 실행 상태 확인
gh run list --workflow release-staging.yml --limit 1

# Release PR 확인
gh pr list --head "release/<version>"
```

## 다음 단계

Release PR이 생성되면 **[STOP]** Human 검토 + 승인 + merge to main → Phase 7 자동 시작.
