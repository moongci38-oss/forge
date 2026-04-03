---
description: "Forge Dev Phase 6 — 릴리스 브랜치 생성 + 스테이징 배포 + Release MR"
model: sonnet
---
> **⚠️ 실행 모드 확인**: 이 커맨드는 쓰기 모드에서만 정상 동작합니다. Plan mode 감지 시 즉시 [STOP] — "Escape로 plan mode 해제 후 재실행하세요. 내부 [STOP] 게이트가 승인 지점입니다."


Forge Dev Phase 6 릴리스 파이프라인을 시작합니다.

## 사용법

```
/forge-release <version>
예: /forge-release 1.2.0
```

## 전제 조건 확인

아래 항목을 먼저 확인해주세요:

1. **Phase 5 PASS**: develop 브랜치의 `develop-integration.yml` 파이프라인이 green인지 확인
   ```bash
   glab ci list --branch develop
   ```
2. **release-config.json 존재**: 프로젝트 루트에 `release-config.json`이 있는지 확인 (없으면 템플릿 복사)
   ```bash
   ls release-config.json || echo "Missing — copy from forge template"
   ```

## 실행 방법

Phase 6는 GitLab CLI로 트리거합니다:

```bash
# GitLab CLI로 트리거
glab ci run --branch develop \
  -v VERSION=<version> \
  -v DEPLOY_STAGING=true
```

또는 GitLab CI/CD → Pipelines → `Release + Staging` → `Run pipeline`에서 수동 실행.

## 결과 확인

```bash
# 파이프라인 실행 상태 확인
glab ci list

# Release PR 확인
glab mr list --source-branch "release/<version>"
```

## 다음 단계

Release MR이 생성되면 **[STOP]** Human 검토 + 승인 + merge to main → Phase 7 자동 시작.
