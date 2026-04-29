# 세션 작업 워크플로우 (Trine v2.1)

> **운영 모델**: AI가 현재 Phase를 인지하고, 완료 시 다음 Phase로 이동을 제안한다. Human 승인 후 진행한다.

## 모델 계층화

```
Trine Lead                → Opus 4.7   (아키텍처 판단, 오케스트레이션)
구현 Teammate              → Sonnet 4.6 (코딩, 테스트, 문서)
탐색 Teammate              → Haiku 4.5  (파일 탐색, 패턴 확인)
```

---

## Phase 1: 작업 요청 및 세션 이해

1. Human이 개발 계획서의 특정 세션을 AI에게 작업 요청
2. AI가 계획문서에서 해당 세션 내용을 정확히 숙지하고 세션 요약 출력
3. 세션 상태 초기화 (`node ~/.claude/trine/scripts/session-state.mjs init --name <name>`)
4. 작업 규모 분류: 자동 (재분류 필요 시만 [STOP])
   ```
   ✅ Phase 1: Standard 분류 완료. codebase-analyzer를 시작합니다.
   → 이상 있으면 말씀해주세요.
   ```
5. (Standard만) **codebase-analyzer** Subagent 스폰
   - 세션 범위(대상 모듈/파일)를 프롬프트로 전달
   - Subagent가 7축 분석 리포트를 `docs/reviews/`에 자동 저장
   - Lead는 요약(~300토큰)만 수신 (컨텍스트 절약)
   - Hotfix → 스킵 (오버헤드 방지)
   - 분석 결과는 Phase 1.5 Q&A와 Phase 2 Spec 작성의 참고 자료로 활용

### Phase 1 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| `session-state.mjs` | CLI | 세션 상태 초기화/관리 |
| `codebase-analyzer` | 에이전트 | 7축 코드베이스 분석 |
| `code-map` | Playground (선택) | 아키텍처 시각화 (새 코드베이스 시) |

   ─── checkpoint: state=phase1_complete ───

---

## Phase 1.5: 요구사항 분석

> 기획서의 모호한 요구사항을 구현 전에 해소. → `trine-requirements-analysis.md` 규칙 참조.

1. 기획서 읽기 + 불명확점 식별
2. 질문 수 판정: 0개(스킵) / 1~3개(Q&A) / 4~5개(Q&A+보완 권고) / 6+개([STOP] 반려)
3. 인터랙티브 Q&A 실행
4. 도메인 완결성 체크 (CRUD/권한/에러/3-State UI/테스트/입력 검증 6축)
5. 트레이서빌리티 매트릭스 생성 (프로젝트별 스크립트 또는 AI 추출)
6. 저장: `.specify/traceability/{name}-matrix.json`

### Phase 1.5 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| Sequential Thinking | MCP (선택) | 복잡한 요구사항 의존성 구조화 |
| `concept-map` | Playground (선택) | 요구사항 의존성 시각화 (4+ 질문 시) |

   ─── checkpoint: state=phase1.5_complete ───

---

## Phase 2: 문서 작성 (Spec → Plan(조건부) → Task(조건부))

> Plan/Task는 conditional. 멀티도메인/아키결정/10+파일 시 필수.

1. AI가 **Spec.md** 작성 (`.specify/specs/`에 저장)
   - `projectType: game` → `spec-template-game.md` 자동 선택
   - `projectType: web` (기본) → `spec-template-base.md`
2. AI가 복잡도 판단
   - Plan 필요 → Plan.md 작성 (`.specify/plans/`)
   - Plan 불필요 → 4단계
3. (조건부) AI가 **Plan.md** 작성 (테스트 분류 포함)
4. 3관점 검증: Spec(S-1~S-8), Plan(P-1~P-5), Task(T-1~T-4)
   - **통과** → 5단계
   - **실패** → 1단계 복귀
5. **[STOP]** Human이 Spec(+Plan) 승인 — GATE 1 승인 패키지
   - **승인** → 6단계
   - **반려** → 1단계 복귀
6. (조건부) AI가 **Task.md** 작성 — 3+ 병렬 에이전트 필요 시만
7. (조건부) **[STOP]** Human이 Task 최종 승인

### Phase 2 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| `spec-writer` | 에이전트 | Spec 문서 전문 작성 |
| Draw.io | MCP (선택) | Spec 아키텍처 다이어그램 (15+ 노드) |
| Mermaid | 인라인 | 간단한 플로우/시퀀스 (≤15 노드) |
| `design-playground` | Playground (선택) | UI/디자인 결정 탐색 → Spec 반영 |

   ─── checkpoint: state=phase2_complete ───

---

## Phase 3: 구현 + AI 자동 검증

### Superpowers 스킬 연동 (Phase 3 전체)

구현 단계에서 아래 superpowers 스킬을 명시적으로 호출하여 품질을 강화한다:

| 시점 | 스킬 | 역할 |
|------|------|------|
| 구현 시작 시 | `superpowers:test-driven-development` | RED→GREEN→REFACTOR 사이클 강제 |
| 태스크별 구현 | `superpowers:subagent-driven-development` | 태스크마다 서브에이전트 스폰 + 2단계 리뷰 |
| 디버깅 발생 시 | `superpowers:systematic-debugging` | 4단계 디버깅 프로토콜 |
| 완료 선언 시 | `superpowers:verification-before-completion` | 증거 기반 완료 선언 |

### 보안 예방 레이어

| 기존 (사후 검증) | 추가 (사전 예방) |
|-----------------|----------------|
| Check 3.8 `/trine-check-security` | `security-guidance` 플러그인 — 코드 작성 시점에 예방적 보안 패턴 경고 |

### 진행 흐름

1. AI가 Spec 기준으로 구현 (의존성 없는 태스크만 병렬 — Wave 단위 스폰)
2. 구현 완료 후 병렬 실행:
   a. **Walkthrough 작성** → `docs/walkthroughs/` (`technical-writer` Subagent 위임 권장)
   b. **Check 3**: `verify.sh code` (프로젝트별 — test/lint/build + 브랜치/커밋 규칙)
   - Check 3 실패 → 1회 자동 수정 → 재실행. 실패 시 **[STOP]** Human 보고
3. Check 3 PASS 후 순차 실행:
   - **Check 3.5** (트레이서빌리티, `spec-compliance-checker` 스킬 참조)
   - **Check 3.7** (코드 리뷰, `code-reviewer` 에이전트 스폰)
   - 확장 체크(3.6/3.7P/3.8)는 수요 확인 후 단계적 추가
4. Auto-fix: 실패 시 1회 수정 시도 → 실패 시 **[STOP]** Human 에스컬레이션

### E2E 실패 시 컨텍스트 주입

E2E 테스트(Playwright) 실패 시 일반 autoFix와 다른 흐름:

```
Check 3 실패 판별
  ├─ E2E 실패? (verify.sh 비정상 + test-results/ 존재)
  │   Yes → [E2E 컨텍스트 수집] → autoFix(컨텍스트 포함) → E2E 재실행
  │   No  → 기존 autoFix 1회 → 재실행
  └─ PASS → 진행 / FAIL → [STOP]
```

컨텍스트 수집 대상 (`test-results/`): 에러 메시지 텍스트 + 실패 스크린샷 경로 목록

### Frontend 점진적 품질 루프 (UI 파일 변경 시)

UI 컴포넌트/페이지를 구현할 때 아래 루프를 단위별로 반복한다.
"전부 구현 후 사후 검증"이 아니라 **컴포넌트 단위로 구현→확인→수정**을 반복하여 최상급 퀄리티를 달성한다.

#### 루프 사이클 (컴포넌트/페이지 단위)

1. **디자인 결정**: `frontend-design` Skill 로드 → 디자인 방향 결정
   - 타이포그래피, 컬러, 모션, 레이아웃 전략
   - AI 슬롭 회피 (generic 폰트, 뻔한 색상 금지)
1.5. **Stitch UI 생성** (UI 컴포넌트 구현 시에만 — API/백엔드 스킵):
   - Stitch MCP로 화면 레이아웃 생성 → `get_screen_code`로 HTML/CSS 추출
   - 추출 코드를 Next.js 컴포넌트 리팩토링 기반으로 활용
   - Stitch 미가용 시 스킵하고 2단계로 직접 진행
2. **구현**: Stitch 코드 기반 Next.js 컴포넌트 리팩토링 + 비즈니스 로직
   - Context7 MCP로 사용 라이브러리 최신 문서 참조
   - 접근성 속성(aria-label, role) 즉시 포함
3. **이미지 에셋** (필요 시): **NanoBanana MCP** — `/generate-image`로 생성
4. **시각 확인**: **Playwright CLI**로 렌더링 검증
   - 최소 3개 뷰포트: Mobile(375x812), Tablet(768x1024), Desktop(1440x900)
5. **디자인 조정**: 시각적 문제 발견 시 수정 후 4번 재확인
6. **다음 단위**: 만족스러우면 다음 컴포넌트/페이지로 이동

### Phase 3 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| `verify.sh` | CLI | Check 3 — test/lint/build/type 통합 검증 |
| `spec-compliance-checker` | 스킬 | Check 3.5 — Spec 트레이서빌리티 검증 |
| `code-reviewer` | 에이전트 | Check 3.7 — 코드 품질 리뷰 |
| `ui-quality-checker` | 에이전트 | Check 3.6 — UI/UX 품질 (FE 변경 시) |
| Stitch | MCP | UI 목업 생성 → 구현 기반 |
| NanoBanana | MCP | 이미지 에셋 AI 생성 |
| Context7 | MCP Plugin | 라이브러리 최신 문서 참조 |
| Playwright CLI | CLI | 렌더링 검증 (3개 뷰포트 스크린샷) |
| Mermaid | 인라인 | Spec 다이어그램 |

   ─── checkpoint: state=phase3_complete ───

---

## Phase 4: PR 생성 및 완료

### 완료 경로 선택 (Phase 4 시작 시)

구현 완료 후 아래 4가지 선택지를 Human에게 제시한다:
1. **PR 생성** → 기본 경로 (아래 절차 진행)
2. **로컬 merge** → 로컬에서 직접 merge (CI 불필요한 소규모 변경)
3. **브랜치 유지** → 추가 작업 예정 시 브랜치만 유지
4. **브랜치 폐기** → 실험/탐색 브랜치 정리

### PR 생성 절차 (선택지 1)

1. AI가 커밋 생성 (Conventional Commits)
2. AI가 `gh pr create`로 PR 생성 + URL 반환
3. **Check 5 (PR Health Check)** — 2단계 전략:
   - **Step 1**: `gh run watch {RUN_ID}` — CI 완료까지 블로킹 대기 (sleep 폴링 없음)
   - **Step 2** (CI PASS 후 즉시): 리뷰 코멘트 인라인 폴링
     - `gh api .../pulls/{PR}/reviews` — 리뷰 본문
     - `gh api .../pulls/{PR}/comments` — 인라인 코멘트
     - `gh api .../issues/{PR}/comments` — 봇 코멘트
   - 코멘트 없음 → 체크박스 자동 체크 → 완료
   - CI 실패 → 코드 수정 → push → Step 1 재시작
   - 코멘트 발견 → 코드 수정 → push → Step 1 재시작
   - `/loop 2m`은 세션 종료 예정 등 인라인 불가 시만 보조 수단
   - **Ralph Loop 통합 패턴**: CI 반복 실패 시 `/ralph-loop "Fix all CI failures and review comments until PR merges" --completion-promise "The PR is merged and all checks are green"` — 완료 조건 미달 시 자동 재시도
4. (선택적) `code-review` 플러그인 — Check 5 통과 후 GitHub PR에 자동 리뷰 코멘트 게시
5. **Phase 4 완료 분기**:
   - `autoMerge=false` → **[STOP]** Human merge 대기
   - `autoMerge=true` → CI+리뷰 PASS 시 `gh pr merge --squash --delete-branch` → 완료
6. (조건부) Human 리뷰 코멘트 대응 → `superpowers:receiving-code-review` 프로토콜 적용
7. 세션 종료

### Phase 4 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| `gh` CLI | CLI | PR 생성, CI 대기, 리뷰 폴링, merge |
| `code-review` | 플러그인 (선택) | PR 자동 리뷰 코멘트 |
| Notion | MCP | todo.md + Notion Tasks 완료 처리 |

   ─── checkpoint: state=session_complete ───

---

## Phase 5: Develop 통합 검증 (자동)

> `develop-integration.yml` GitHub Actions가 자동 실행. 수동 개입 불필요.

1. PR merge to develop → `develop-integration.yml` 자동 트리거
2. **Check 6** 자동 실행:
   - `verify.sh code` (build + test + lint + type)
   - `e2e-runner.sh --env local` (`.specify/e2e-pipeline.json` 존재 시만)
3. **결과 분기**:
   - ✅ PASS → Step Summary 출력 → Phase 6 진입 가능
   - ❌ FAIL → **Check 6.5**: GitHub Issue 자동 생성 (`integration-failure` + `trine-phase-5` 라벨) → AI가 이슈 분석 + 수정 → develop 재push
4. PASS 확인 후 `/trine-release` 커맨드로 Phase 6 진입

### Phase 5 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| `develop-integration.yml` | GitHub Actions | Check 6 자동 실행 |
| `verify.sh` | CLI (Actions 내) | build/test/lint/type 통합 |
| `e2e-runner.sh` | CLI (Actions 내) | E2E 테스트 (존재 시) |
| `gh` CLI | CLI | Issue 자동 생성 (FAIL 시) |

   ─── Check 6: develop-integration.yml 자동 ───

---

## Phase 6: 릴리스 브랜치 + 스테이징 (수동 트리거)

> `/trine-release` 커맨드로 진입. `release-staging.yml`이 릴리스 브랜치 생성부터 Release PR까지 자동화.

1. Human이 `/trine-release {version}` 실행 (예: `/trine-release 1.2.0`)
2. `release-staging.yml` workflow_dispatch 트리거:
   a. `release/{version}` 브랜치 생성 (develop 기준)
   b. `package.json` version 자동 bump (또는 `CHANGELOG.md` 생성)
   c. `deploy-runner.sh --env staging` 실행:
      - `release-config.json`의 `environments.staging.deployCommand` 읽기
      - **빈 값이면 skip** → "배포 인프라 미설정 — build/test만 실행합니다" 안내
      - 설정된 값이면 실행 → health check
   d. **Check 7**: E2E (`e2e-runner.sh --env staging` — `e2e-pipeline.json` 존재 시)
   e. Release PR 자동 생성 (`release/{version}` → `main`)
3. **Check 7.5**: **[STOP]** Human이 Release PR 검토 + 승인 + merge to main
   - PR merge → Phase 7 자동 트리거

### Phase 6 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| `release-staging.yml` | GitHub Actions | 릴리스 브랜치 + 스테이징 자동화 |
| `deploy-runner.sh` | CLI (Actions 내) | 스테이징 배포 |
| `e2e-runner.sh` | CLI (Actions 내) | E2E 테스트 |
| `gh` CLI | CLI | Release PR 생성 |

   ─── Check 7: release-staging.yml 자동 ───
   ─── Check 7.5: [STOP] Human Release PR 승인 ───

---

## Phase 7: 프로덕션 배포 + 롤백 (자동)

> `main` push 시 `production-deploy.yml` 자동 트리거. 실패 시 `/trine-rollback`으로 롤백.

1. Release PR merge to main → `production-deploy.yml` 자동 트리거
2. **Check 8** 자동 실행:
   a. `deploy-runner.sh --env production` 실행:
      - `release-config.json`의 `environments.production.deployCommand` 읽기
      - **빈 값이면 skip** → build artifacts만 생성
      - 설정된 값이면 실행
   b. Health check (`healthEndpoint` 설정 시)
   c. Smoke test (`smokeTestURL` 설정 시)
   d. GitHub Release 자동 생성 (tag + changelog)
   e. `release/{version}` 브랜치 자동 삭제
3. **결과 분기**:
   - ✅ PASS → Phase 7 완료. todo.md 상태 갱신 (`trine-pm-updater`)
   - ❌ FAIL → **Check 8.5**: Human이 `/trine-rollback` 실행:
     - **L1 Quick Revert**: `git revert` — 최근 커밋만 되돌리기 (< 30분)
     - **L2 Release Revert**: 이전 릴리스 태그로 재배포 (< 2시간)
     - **L3 Hotfix Forward**: `hotfix/*` 브랜치에서 Trine Hotfix 플로우 재진입 (> 2시간)

### Phase 7 사용 도구

| 도구 | 유형 | 용도 |
|------|:----:|------|
| `production-deploy.yml` | GitHub Actions | 프로덕션 배포 자동화 |
| `deploy-runner.sh` | CLI (Actions 내) | 프로덕션 배포 |
| `gh` CLI | CLI | GitHub Release 생성 |
| Sentry | MCP | 배포 후 에러 모니터링 |
| `trine-pm-updater` | 에이전트 | todo.md + Notion 상태 갱신 |

   ─── Check 8: production-deploy.yml 자동 ───
   ─── Check 8.5: [STOP] 롤백 필요 시 Human이 /trine-rollback 실행 ───

---

### 비-Trine 세션에서 활용 가능한 superpowers 스킬 (파이프라인 외)

| 스킬 | 활용 시점 |
|------|----------|
| `brainstorming` | 기획서 없이 아이디어에서 설계를 시작할 때 (SIGIL 이전 단계) |
| `writing-plans` | Spec과 별도로 구현 상세 계획(How+코드)이 필요할 때 |
| `finishing-a-development-branch` | 로컬 merge, 워크트리 정리 등 PR 외 선택지가 필요할 때 |
| `using-git-worktrees` | 여러 기능을 물리적으로 격리하여 병렬 개발할 때 |
| `writing-skills` | 새 스킬 작성 시 TDD 방법론 적용 |
