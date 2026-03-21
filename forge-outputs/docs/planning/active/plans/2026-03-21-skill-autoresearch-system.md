# AutoResearch 스킬 자동 개선 시스템 구현

## Context

43개 스킬 중 품질 측정 체계가 전무 → 개선이 100% 수동.
Karpathy AutoResearch 패턴(이진 평가 + 자율 반복 루프)을 적용하여 스킬 프롬프트를 자동 개선한다.

**대상 스킬 3개** (MCP 무관 + 단일 텍스트 입출력 + 구조화 출력):
1. `concise-planning` — 구현 체크리스트 생성
2. `hook-creator` — Claude Code 훅 설정 JSON 생성
3. `writing-plans` — TDD 기반 구현 계획 생성

**ux-audit 제외 사유**: `git diff` 의존으로 고정 테스트 입력 불가

---

## Step 1 — assessment.md 표준 템플릿

**신규 파일**: `forge/dev/templates/skill-assessment-template.md`

```markdown
---
skill: {skill-name}
version: 1
---
# Assessment: {skill-name}

## 테스트 입력
각 입력에 대해 스킬을 실행하고 출력을 채점한다.
- input_1: "{고정 입력 1}"
- input_2: "{고정 입력 2}"
- input_3: "{고정 입력 3}"

## 평가 기준 (Yes/No)
채점 모델(Haiku)이 출력을 읽고 각 기준에 Yes/No로 답한다.
1. {기준}: {구체적 질문}
...

## 채점
- 1건 pass = 모든 기준 Yes
- pass_rate = pass 건수 / 전체 실행 수
```

---

## Step 2 — 스킬별 assessment.md (정확한 평가 기준)

### 2-1. concise-planning

**파일**: `.claude/skills/concise-planning/assessment.md`

**테스트 입력 3개**:
```
1. "Add dark mode toggle to the settings page"
2. "Refactor the authentication middleware to support JWT refresh tokens"
3. "Create a REST API endpoint for user profile CRUD operations"
```

**평가 기준 6개**:

| # | 기준 | Yes/No 질문 |
|:-:|------|-----------|
| 1 | Approach 존재 | 출력에 "Approach" 또는 고수준 접근법을 설명하는 1-3문장 섹션이 있는가? |
| 2 | Scope In/Out 분리 | "Scope" 섹션에 "In"과 "Out" (또는 동등한 포함/제외) 항목이 **모두** 존재하는가? |
| 3 | Action Items 수량 | Action Items(체크리스트 항목)가 **6개 이상 10개 이하**인가? |
| 4 | 동사 시작 | Action Items의 **80% 이상**이 동사로 시작하는가? (Add, Create, Refactor, Verify, Update, Test 등) |
| 5 | 파일 경로 포함 | Action Items 중 **최소 1개**가 구체적 파일 경로(예: `src/components/Settings.tsx`)를 포함하는가? |
| 6 | Validation 존재 | 테스트/검증 단계가 **최소 1개** 존재하는가? (Validation 섹션 또는 Action Items 내 검증 스텝) |

### 2-2. hook-creator

**파일**: `.claude/skills/hook-creator/assessment.md`

**테스트 입력 3개**:
```
1. "Create a hook that logs all bash commands to ~/.claude/bash-history.log"
2. "Block any attempt to edit .env files and show a warning"
3. "Auto-format Python files with black after every edit"
```

**평가 기준 5개**:

| # | 기준 | Yes/No 질문 |
|:-:|------|-----------|
| 1 | JSON 구조 존재 | 출력에 `"hooks"` 키를 포함하는 JSON 코드 블록이 존재하는가? |
| 2 | 유효한 이벤트 | 이벤트 이름이 `PreToolUse`, `PostToolUse`, `Notification`, `Stop` 중 하나인가? |
| 3 | matcher 존재 | `"matcher"` 필드가 존재하고 값이 비어있지 않은가? (`"*"`, `"Bash"`, `"Edit\|Write"` 등) |
| 4 | command 존재 | `"command"` 필드가 존재하고 실행 가능한 셸 명령(bash, python3, jq 등)을 포함하는가? |
| 5 | 저장 위치 안내 | 설정 파일 경로(`~/.claude/settings.json` 또는 `.claude/settings.json`)가 언급되어 있는가? |

### 2-3. writing-plans

**파일**: `.claude/skills/writing-plans/assessment.md`

**테스트 입력 3개**:
```
1. "Implement a comment system with nested replies for a blog. Spec: users can comment, reply to comments (max 3 depth), edit own comments, delete own comments."
2. "Add email notification system. Spec: send welcome email on signup, password reset email, weekly digest of new posts."
3. "Build a file upload service. Spec: accept images (jpg/png/webp, max 5MB), resize to 3 sizes (thumbnail/medium/large), store in S3, return CDN URLs."
```

**평가 기준 6개**:

| # | 기준 | Yes/No 질문 |
|:-:|------|-----------|
| 1 | 헤더 존재 | 출력에 `Goal`, `Architecture`, `Tech Stack` 을 포함하는 헤더 섹션이 있는가? |
| 2 | Task 구조 | `### Task N:` 형식의 태스크가 **2개 이상** 존재하는가? |
| 3 | 파일 경로 명시 | 각 Task에 `Create:` 또는 `Modify:` 또는 `Test:` 뒤에 **구체적 파일 경로**가 있는가? |
| 4 | TDD 패턴 | **최소 1개 Task**에 "failing test" → "implement" → "test passes" 순서가 있는가? |
| 5 | 단계 세분화 | 각 Task의 Step이 **2-5분 단위**의 작은 액션인가? (한 Step에 여러 파일 수정 = No) |
| 6 | 커밋 포인트 | **최소 1곳**에 커밋 단계("Commit" 또는 "git commit")가 명시되어 있는가? |

---

## Step 3 — manage-skills.sh `assess` 서브커맨드

**수정 파일**: `forge/shared/scripts/manage-skills.sh`
- `cmd_test()` (693-737줄) 플레이스홀더 → `cmd_assess()` 로 교체
- `test)` case (785줄) → `assess)` 로 변경

**신규 파일**: `forge/shared/scripts/skill-assess-runner.sh`

**동작**:
```bash
bash manage-skills.sh assess concise-planning --runs 3
```

1. `.claude/skills/{name}/assessment.md` 존재 확인 (없으면 에러)
2. assessment.md에서 테스트 입력 + 평가 기준 파싱
3. 각 테스트 입력에 대해:
   a. `claude -p "/{skill-name} {test_input}" --model sonnet` 비대화식 실행
   b. 출력을 파일에 저장
   c. `claude -p "{평가 프롬프트}" --model haiku` 로 채점 (각 기준 Yes/No)
4. pass_rate 계산 + 결과 출력

**채점 프롬프트 패턴**:
```
아래 출력을 평가하라. 각 기준에 대해 YES 또는 NO만 답하라.

## 출력
{스킬 출력 내용}

## 평가 기준
1. {기준 1 질문}
2. {기준 2 질문}
...

## 응답 형식 (정확히 이 형식으로)
1: YES
2: NO
3: YES
...
```

---

## Step 4 — 자동 개선 루프 스크립트

**신규 파일**: `forge/shared/scripts/skill-autoresearch.sh`

```bash
bash shared/scripts/skill-autoresearch.sh concise-planning \
  --iterations 10 --budget 5 --target-rate 0.90
```

**루프 (1 iteration)**:
1. `manage-skills.sh assess {skill} --runs 3` → 현재 pass_rate
2. target_rate 미달 시:
   a. 실패 사례(NO 답변)의 패턴을 Claude에게 분석 요청
   b. SKILL.md 개선안 생성 (한 번에 1가지 변경만)
   c. SKILL.md 백업 (`git stash` 또는 `.bak`)
   d. 개선안 적용 → 재평가
   e. pass_rate 향상 → keep, 아닌 → revert
3. `{skill}/autoresearch-log.tsv`에 기록: iteration|pass_rate|delta|status|change_description
4. 종료 조건: `--budget` 초과 OR `--target-rate` 달성 OR `--iterations` 소진

**안전장치**:
- `--budget`: 달러 상한선 (기본 $5)
- `--dry-run`: 실제 수정 없이 평가만
- SKILL.md 수정 전 항상 git commit (revert 보장)
- 한 iteration에 1가지 변경만 (원인 추적 가능)

---

## 주요 파일 목록

| 파일 | 상태 | 설명 |
|------|:----:|------|
| `dev/templates/skill-assessment-template.md` | 신규 | 표준 포맷 |
| `.claude/skills/concise-planning/assessment.md` | 신규 | 평가 기준 6개 |
| `.claude/skills/hook-creator/assessment.md` | 신규 | 평가 기준 5개 |
| `.claude/skills/writing-plans/assessment.md` | 신규 | 평가 기준 6개 |
| `shared/scripts/manage-skills.sh` | 수정 | cmd_test→cmd_assess (693-737줄) |
| `shared/scripts/skill-assess-runner.sh` | 신규 | 실행+채점 로직 |
| `shared/scripts/skill-autoresearch.sh` | 신규 | 자동 개선 루프 |

---

## 검증

```bash
# Step 2 검증: assessment.md 존재 확인
ls .claude/skills/concise-planning/assessment.md
ls .claude/skills/hook-creator/assessment.md
ls .claude/skills/writing-plans/assessment.md

# Step 3 검증: assess 커맨드 동작
bash shared/scripts/manage-skills.sh assess concise-planning --runs 1

# Step 4 검증: 드라이런
bash shared/scripts/skill-autoresearch.sh concise-planning \
  --iterations 2 --budget 1 --dry-run
```
