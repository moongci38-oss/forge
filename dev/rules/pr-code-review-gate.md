# PR Code Review Gate (전역)

> PR 생성 전후 코드 리뷰 워닝을 사전 차단하고, 생성 후 자동 대응하는 규칙.

## 핵심 원칙

**PR을 생성하기 전에 자체 코드 리뷰를 수행한다. PR 생성 후 봇/Human 리뷰 코멘트는 반드시 수정한다.**

**자동 머지 원칙 (전역 기본값):**
- CI PASS + 모든 리뷰 코멘트 해결 완료 시 → **Human 승인 대기 없이 즉시 squash merge + branch 삭제**
- 머지 후 다음 작업(의존 태스크 포함)을 즉시 진행한다
- Worktree 병렬 작업 시: Wave N PR이 머지되면 Wave N+1 의존 태스크를 바로 착수한다
- `.specify/config.json`의 `autoMerge` 설정과 무관하게 항상 자동 머지가 기본이다
- **중간 PR마다 Human에게 보고하지 않는다** — 파이프라인을 끊지 않고 끝까지 진행
- **모든 작업이 완전히 완료된 시점에 딱 한 번** Human에게 최종 완료 보고를 한다

## PR 생성 전 자체 검증 (Pre-PR Review)

PR 생성 직전, 변경된 파일에 대해 아래 항목을 검증한다:

### 보안 (Blocking — 발견 시 PR 생성 중단)

| 패턴 | 설명 | 수정 방법 |
|------|------|----------|
| `canActivate() return true` | Stub Guard — 인증 우회 | 실제 JWT/RBAC Guard 구현 |
| Script 태그 내 `${}` 보간 | XSS 위험 | `JSON.stringify()` 사용 |
| 프로덕션 코드에 하드코딩 시크릿 | 시크릿 노출 | 환경변수/ConfigService |

### 품질 (Warning — 수정 권장)

| 패턴 | 설명 | 수정 방법 |
|------|------|----------|
| 프로덕션 코드에 하드코딩 UUID | 설정값 하드코딩 | Config/Auth context |
| `expiresIn: '15m'` 등 매직 넘버 | 설정 하드코딩 | ConfigService |
| `any` 타입 3개 초과 | 타입 안전성 부족 | 적절한 인터페이스 정의 |
| bcrypt + bcryptjs 혼용 | 의존성 불일치 | 하나로 통일 |
| `TODO/FIXME/HACK` 잔존 | 미완성 코드 | 수정 또는 이슈 등록 |
| useCallback 의존성 누락 | React 렌더링 버그 | deps 배열 검토 |

## PR 생성 후 리뷰 대응 (AI Check 5)

PR 생성 후 **2단계 전략**으로 CI + 리뷰를 처리한다:

### Step 1: CI 완료 대기 (`gh run watch` — 블로킹)

```bash
# PR의 CI run ID를 확인하고 완료까지 블로킹 대기 (sleep 폴링 없음)
gh run watch {RUN_ID} --repo {owner}/{repo}
```

- CI pending 중 불필요한 폴링을 제거한다
- CI 완료 시 즉시 Step 2로 전환한다
- CI FAIL 시 → 코드 수정 → push → `gh run watch`로 재대기

### Step 2: 리뷰 코멘트 폴링 (`/loop 2m`)

CI 전체 PASS 확인 후 `/loop 2m`으로 리뷰 대응을 시작한다:

```
1. /loop 2m 으로 아래를 자동 반복:
   - gh api repos/{owner}/{repo}/pulls/{PR}/reviews → 리뷰 본문 확인
   - gh api repos/{owner}/{repo}/pulls/{PR}/comments → 인라인 코멘트 확인
   - gh api repos/{owner}/{repo}/issues/{PR}/comments → 봇 코멘트 체크박스 확인
   - 코멘트 없음 → 체크박스 자동 체크 → 완료 보고 후 루프 종료
   - 코멘트 발견 → 아래 2-3단계 수행 후 루프 계속
2. WARN/BLOCK 코멘트 → 코드 수정 → 새 커밋 push
3. 각 코멘트에 "Fixed in {hash} — {요약}" 회신 (**중복 회신 방지 필수** — 아래 규칙 참조)
4. 코드 수정 push 후 → `gh run watch`로 CI 재대기 → PASS 후 루프 복귀
5. CI 전체 PASS + 코멘트 0건 시 PR body + 봇 코멘트의 미체크 체크박스를 자동 체크:
   - PR body: `gh api repos/{owner}/{repo}/pulls/{PR} -X PATCH -f body="..."`
   - 봇 코멘트: `gh api repos/{owner}/{repo}/issues/comments/{ID} -X PATCH -f body="..."`
   - `[ ]` → `[x]` 일괄 변환 (For Reviewers 포함)
```

## PR 체크박스 자동 완료 (CI PASS 시)

CI 전체 통과 + 리뷰 코멘트 처리 완료 후, PR의 **모든 미체크 체크박스를 자동으로 체크**한다.

### 대상

| 위치 | 체크 대상 | 방법 |
|------|----------|------|
| PR body | Review Checklist, Test plan, For Reviewers 등 모든 `[ ]` | `gh api pulls/{PR} -X PATCH -f body=...` |
| 봇 코멘트 (issue comments) | Spec Check 봇 등의 체크리스트 `[ ]` | `gh api issues/comments/{ID} -X PATCH -f body=...` |

### 자동 체크 스크립트 패턴

```bash
# PR body 체크박스 전체 체크
BODY=$(gh api repos/{owner}/{repo}/pulls/{PR} --jq '.body')
UPDATED=$(echo "$BODY" | sed 's/- \[ \]/- [x]/g')
gh api repos/{owner}/{repo}/pulls/{PR} -X PATCH -f body="$UPDATED"

# 봇 코멘트 체크박스 전체 체크
gh api repos/{owner}/{repo}/issues/{PR}/comments --jq '.[] | select(.body | test("\\[ \\]")) | {id: .id, body: .body}' | \
  jq -c '.' | while read -r item; do
    ID=$(echo "$item" | jq -r '.id')
    BODY=$(echo "$item" | jq -r '.body' | sed 's/- \[ \]/- [x]/g')
    gh api repos/{owner}/{repo}/issues/comments/$ID -X PATCH -f body="$BODY"
  done
```

### 실행 조건

- CI 전체 PASS (`gh pr checks` 모든 항목 pass/skipping)
- 리뷰 코멘트 미해결 건 없음
- 위 조건 미충족 시 체크박스 자동 체크 하지 않음

## 중복 회신 방지 (필수)

리뷰 코멘트에 회신하기 전, **기존 회신이 이미 존재하는지 반드시 확인**한다. 컨텍스트 압축(compaction) 경계를 넘으면 이전 회신 기억이 사라지므로, 항상 API로 확인해야 한다.

```bash
# 회신 전 기존 회신 확인 (필수)
gh api repos/{owner}/{repo}/pulls/{PR}/comments \
  --jq '.[] | select(.user.login != "gemini-code-assist[bot]") | {id: .id, in_reply_to: .in_reply_to_id, body: (.body | split("\n")[0])}'
```

| 상황 | 행동 |
|------|------|
| 해당 코멘트에 내 회신이 이미 존재 | **회신하지 않는다** (스킵) |
| 해당 코멘트에 내 회신이 없음 | 회신 작성 |
| 이전 회신이 있지만 새 커밋으로 재수정 | 기존 회신을 **PATCH로 업데이트** (새 회신 생성 금지) |

## 체크박스 체크 타이밍 (필수)

체크박스를 체크한 후 새 커밋을 push하면, GitHub Actions 봇이 코멘트를 재생성/업데이트하면서 **체크박스가 리셋**될 수 있다. 따라서:

1. **체크박스 체크는 모든 push가 완료된 후, CI 전체 PASS 확인 후에만 실행**한다
2. 코드 수정 push → CI 대기 → CI PASS → **그때** 체크박스 체크
3. ❌ 금지: 코드 수정 push 전에 체크박스를 미리 체크 (봇이 리셋함)
4. ❌ 금지: 체크박스 체크 후 추가 push (봇이 리셋함)

```
올바른 순서:
  코드 수정 → push → CI 대기 → CI 전체 PASS 확인
  → 봇 코멘트가 최종 상태로 안정화 (30초 대기)
  → 체크박스 일괄 체크 (PR body + 봇 코멘트)
  → CLEAN 보고

잘못된 순서:
  ❌ 체크박스 체크 → 코드 수정 → push (봇이 리셋)
  ❌ CI pending 중 체크박스 체크 (봇이 재실행되면서 리셋)
```

## AI 행동 규칙

1. `gh pr create` 실행 전 위 보안 패턴을 자체 검증
2. Blocking 이슈 발견 시 PR 생성하지 않고 수정 먼저
3. **PR 생성 직후 `gh run watch`로 CI 대기 → PASS 후 `/loop 2m`으로 리뷰 폴링** (2단계 전략)
4. 봇 리뷰(Gemini 등)도 Human 리뷰와 동일하게 대응
5. CI + 리뷰 코멘트 확인을 **스킵하지 않는다** — 어떤 상황에서도 건너뛰기 금지
6. **CI 전체 PASS + 리뷰 코멘트 0건 → 즉시 squash merge + branch 삭제 → 다음 작업 착수**
7. **중간 PR 완료 시 Human에게 개별 보고하지 않는다** — 파이프라인 흐름을 끊지 않음
8. **모든 작업이 완전히 끝난 시점에 딱 한 번 Human에게 최종 완료 보고**
7. **CI 전체 PASS 시 PR body + 봇 코멘트의 모든 체크박스를 자동 체크** — 수동 확인 불필요
8. CI + 리뷰 코멘트 확인을 **스킵하지 않는다** — 어떤 상황에서도 건너뛰기 금지
9. **리뷰 코멘트 회신 전 기존 회신 존재 여부를 API로 반드시 확인** — 중복 회신 금지
10. **체크박스 체크는 최종 push 후 CI PASS 확인 후에만 실행** — push 전/중 체크 금지
11. `.specify/config.json`의 `autoMerge` 값을 세션 시작 시 읽는다 (미존재 시 기본값 `false`)
12. `autoMerge: true` 시 merge 전 최종 확인: squash merge + branch 삭제
13. merge 실패 시 (conflict 등) → [STOP] 에스컬레이션
14. Worktree 에이전트 프롬프트에도 autoMerge 설정값을 전달한다

## 자동 폴링 필수 규칙 (`/loop`)

> **전역 규칙 — 모든 프로젝트에 공통 적용.**
> PR 생성 후 CI/리뷰 상태를 자동으로 폴링하여 문제 발견 시 즉시 대응한다.

### 필수 실행 시점

| 이벤트 | 행동 |
|--------|------|
| `gh pr create` 직후 | **즉시** `gh run watch`로 CI 대기 시작 |
| CI 전체 PASS 후 | `/loop 2m`으로 리뷰 코멘트 폴링 시작 |
| 워크트리 에이전트 PR 생성 | 에이전트 프롬프트에 2단계 전략 지시 포함 필수 |
| 코드 수정 후 push | `gh run watch`로 CI 재대기 → PASS 후 `/loop` 복귀 |

### Step 1: CI 대기

```bash
# CI run ID 확인 후 블로킹 대기 (sleep 폴링 없음)
RUN_ID=$(gh run list --branch {BRANCH} --limit 1 --json databaseId --jq '.[0].databaseId')
gh run watch $RUN_ID
```

### Step 2: `/loop` 폴링 내용 (CI PASS 후)

```bash
# 매 2분마다 반복 (CI 체크 제외 — 이미 PASS 확인됨):
gh api repos/{owner}/{repo}/pulls/{PR}/reviews  # 리뷰 본문
gh api repos/{owner}/{repo}/pulls/{PR}/comments # 인라인 코멘트
gh api repos/{owner}/{repo}/issues/{PR}/comments # 봇 코멘트
```

### 종료 조건

| 조건 | 행동 |
|------|------|
| CI PASS + 코멘트 0건 | 체크박스 체크 → `gh pr merge --squash --delete-branch` → 완료 보고 → **의존 다음 작업 즉시 착수** |
| CI FAIL | 코드 수정 → push → 루프 계속 |
| 리뷰 코멘트 발견 | 코드 수정 → push → CI 재대기 → 루프 계속 |
| merge conflict | **[STOP]** Human 에스컬레이션 |
| Human이 PR merge 완료 | 루프 자동 종료 (PR closed 감지) → 다음 작업 착수 |

### 금지 사항

- ❌ PR 생성 후 `gh run watch` 없이 `sleep` 폴링으로 CI 대기
- ❌ CI pending 중 `/loop`로 불필요한 리뷰 폴링 시작
- ❌ CI 결과를 수동으로 한 번만 확인하고 끝내기
- ❌ CI + 리뷰 확인 없이 "CI 확인해주세요"라고 Human에게 떠넘기기

---

*Last Updated: 2026-03-10*
