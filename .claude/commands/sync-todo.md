# /sync-todo — todo.md ↔ PR 머지 상태 자동 동기화

## 목적

`docs/planning/active/sigil/todo.md`의 진행 상태를 GitHub PR 머지 기록과 대조하여 자동 갱신한다.
`/loop 30m /sync-todo`로 주기적 실행 가능.

## 실행 절차

### 1. todo.md 탐색

프로젝트 루트에서 `docs/planning/active/sigil/todo.md` 파일을 찾는다.
없으면 "todo.md가 없습니다" 출력 후 종료.

### 2. PR 머지 상태 조회

```bash
gh pr list --state merged --base develop --limit 50 --json number,title,mergedAt,headRefName
```

### 3. todo.md 파싱 및 대조

todo.md의 `## Trine 개발 진행` 및 유사 테이블 섹션에서 각 행을 파싱한다.

**매칭 전략** (우선순위):

1. **PR 번호 매칭**: 행에 `[#NNN]` 형태의 PR 번호가 있으면, 해당 PR의 머지 상태 확인
2. **브랜치명 매칭**: Spec 이름에서 `feat/{spec-name}` 패턴으로 브랜치명 추론 → PR 검색
3. **제목 키워드 매칭**: Spec 이름 키워드가 PR 제목에 포함되는지 확인

### 4. 상태 갱신 규칙

| 현재 Status | PR 머지 확인 | 갱신 |
|------------|:----------:|------|
| ⬜ Todo | 머지됨 | → ✅ Done + PR# + 완료일 |
| 🔄 Doing | 머지됨 | → ✅ Done + PR# + 완료일 |
| 🧪 QA | 머지됨 | → ✅ Done + PR# + 완료일 |
| ✅ Done | — | 변경 없음 (이미 완료) |
| ⬜ Todo | Open PR 존재 | → 🧪 QA + PR# |
| ⬜ Todo | 브랜치만 존재 | → 🔄 Doing |

**완료일**: PR `mergedAt`에서 `YYYY-MM-DD` 추출 (UTC→KST 변환)

### 5. 변경 적용

- Edit 도구로 todo.md의 해당 행을 업데이트
- 변경이 1건 이상이면 `**최종 업데이트**` 날짜도 갱신

### 6. 결과 보고

변경 사항을 간결하게 출력:

```
📋 todo.md 동기화 완료
- #12: 🧪 QA → ✅ Done (PR #116, 2026-03-09)
- #13: ⬜ Todo → ✅ Done (PR #117, 2026-03-10)
변경: 2건 | 이미 최신: 13건
```

변경 없으면:

```
📋 todo.md 이미 최신 상태 (15건 확인)
```

### 7. 커밋 여부

- **`/loop`에서 호출 시**: 변경이 있으면 자동 커밋
  ```
  docs(todo): sync todo.md with merged PR status

  Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
  ```
- **수동 호출 시**: 변경 보고 후 커밋 여부를 사용자에게 확인

## 제약사항

- `gh` CLI가 인증되어 있어야 함
- `docs/planning/active/sigil/todo.md`가 존재하는 프로젝트에서만 동작
- PR이 `develop` 브랜치 대상인 경우만 매칭 (main 대상 hotfix는 별도)
- 이미 ✅ Done인 항목은 절대 변경하지 않음 (안전 장치)

## 오픈 PR 체크 (선택)

`gh pr list --state open` 결과도 확인하여 ⬜ Todo → 🔄 Doing / 🧪 QA 전환 감지.

## `/loop` 사용 예시

```
/loop 30m /sync-todo     # 30분마다 자동 동기화
/loop 10m /sync-todo     # 10분마다 (활발한 개발 중)
/sync-todo               # 수동 1회 실행
```
