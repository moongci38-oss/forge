---
title: "Git 규칙"
id: git-rules
impact: HIGH
scope: [always]
tags: [git, commit, branch]
section: core
audience: all
impactDescription: "force push로 팀 작업물 영구 소실 가능. --no-verify로 품질 게이트 우회 시 프로덕션 장애 위험"
enforcement: rigid
---

# Git 규칙

## 브랜치 전략
- `main`: 프로덕션 (안정 버전)
- `feature/*`: 신규 기능
- `fix/*`: 버그 수정

## 커밋 메시지 (Conventional Commits)

```
feat: 새 기능 추가
fix: 버그 수정
docs: 문서만 변경
style: 코드 포맷팅 (로직 변경 없음)
refactor: 리팩토링
test: 테스트 추가/수정
chore: 빌드, 설정 파일 변경
```

## 머지 전략
- **Squash merge 전용** (커밋 히스토리 정리)
- PR 필수 (1인이라도 검토 프로세스 유지)

## AI Co-Authoring
모든 AI 생성 커밋에 추가:
```
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

## Do

- Conventional Commits 형식으로 커밋 메시지를 작성한다
- Squash merge를 사용한다
- PR을 통해 머지한다 (1인이라도 검토 프로세스 유지)
- AI 생성 커밋에 Co-Authored-By를 추가한다
- `git reset --hard` 사용 전 백업한다
- `feature/*`, `fix/*` 브랜치 전략을 따른다

## Don't

- `git push --force` 금지 (main/master)
- `.env`, `credentials` 커밋 금지
- `--no-verify` 사용 금지 (pre-commit hook 우회 금지)
- main 브랜치에 직접 커밋 금지
- 백업 없이 `git reset --hard` 실행 금지
