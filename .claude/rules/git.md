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

## Git Safety
- `git push --force` 금지 (main/master)
- `git reset --hard` 사용 전 백업
- `.env`, `credentials` 커밋 금지
- `--no-verify` 사용 금지 (pre-commit hook 우회 금지)
