# superpowers 워크플로우 자동 적용 규칙

> superpowers v4.3.1 — 기존보다 좋은 기능은 **교체**, 없던 기능은 **추가**.
> 조건 충족 시 묻지 않고 즉시 적용한다.

---

## 시스템 정의

| 시스템 | 적용 범위 | 설명 |
|--------|----------|------|
| **sigil** | Business 프로젝트 | 리서치, 기획, 마케팅, 콘텐츠, 운영 |
| **trine** | 개발 프로젝트 (Portfolio, GodBlade) | SDD 기반 개발 워크플로우 |

---

## 핵심 기능 — 자동 트리거 + 기존 기능 교체/추가

### 1. Brainstorming (sigil + trine) — 교체

> 교체 대상: `mcp__sequential-thinking__sequentialthinking()`
> 교체 이유: HARD-GATE 디자인 승인 + 2-3 접근법 비교 + 섹션별 승인 > 단순 사고 분해

**트리거:**
- 새 기능/컴포넌트/모듈/기획 요청
- 크로스 프로젝트 파이프라인 시작
- 대규모 기획 작업 (sigil)

**호출:** `Skill("superpowers:brainstorming")`
- 체크리스트 5단계:
  1. 프로젝트 컨텍스트 탐색 (기존 코드, docs, 최근 커밋)
  2. 질문 1개씩 순차 (why, constraints, success criteria)
  3. 2-3 접근법 제안 + 트레이드오프 + 추천안
  4. 섹션별 디자인 발표 → 사용자 승인 (HARD-GATE: 승인 없이 구현 금지)
  5. `docs/plans/YYYY-MM-DD-<topic>-design.md` 저장 + commit
- 완료 시 writing-plans로 자동 전환

**예외:** 단순 버그 수정, 기존 파일 수정, 설정 변경

### 2. Writing Plans (sigil + trine) — 교체

> 교체 대상: `concise-planning` 스킬
> 교체 이유: bite-sized 2-5분 단위 태스크 + 정확한 파일 경로 + 완전 코드 > 간략한 계획

**트리거:**
- brainstorming 완료 후 (자동 전환)
- "계획 세워줘" 요청

**호출:** `Skill("superpowers:writing-plans")`
- 각 스텝 = 하나의 액션 (2-5분)
- trine 예시: "실패 테스트 작성" → "실행 확인" → "최소 코드 구현" → "테스트 통과" → "커밋"
- sigil 예시: "시장 데이터 수집" → "경쟁사 비교표" → "기회 영역 도출" → "보고서 저장"
- `docs/plans/YYYY-MM-DD-<feature-name>.md` 저장
- DRY, YAGNI, TDD 원칙 적용

**유지:** sigil에서 `Skill("requirements-clarity")`를 writing-plans 전처리로 유지 (superpowers 미지원)

### 3. TDD (trine only) — 추가

> 기존 상태: TDD 프로세스 없음 (코드 작성 후 테스트 또는 테스트 미작성)
> 추가 이유: Iron Law — 실패 테스트 먼저 → 최소 코드 → 리팩터

**트리거:**
- 새 함수/클래스/모듈 구현 시작
- 버그 수정 코드 작성 시작
- 리팩토링 시작

**호출:** `Skill("superpowers:test-driven-development")`
- Iron Law: 실패하는 테스트 먼저 → 최소 코드 → 리팩터
- 코드 먼저 작성 시 삭제 후 재시작
- 합리화 차단 (12개 변명 대응)
- Portfolio: Jest (unit) + Playwright (e2e)
- GodBlade: NUnit (EditMode) + Unity Test Framework (PlayMode)

**예외:** 설정 파일만 수정, 사용자가 프로토타입 허용

### 4. Systematic Debugging (sigil + trine) — 추가

> 기존 상태: 즉석 수정 시도 (체계적 프로세스 없음)
> 추가 이유: 4단계 근본원인 분석 + 3회 실패 시 아키텍처 재검토

**트리거:**
- 테스트 실패, 빌드 에러, 런타임 예외
- "버그", "에러", "안 돼", "실패" 키워드
- 이전 수정이 문제를 해결 못한 경우
- 스크립트 실행 실패 (sigil)

**호출:** `Skill("superpowers:systematic-debugging")`
- 근본 원인 조사 없이 수정 시도 금지
- 4단계: Root Cause → Pattern → Hypothesis → Implementation
- 3회 수정 실패 시 아키텍처 재검토

### 5. Verification Before Completion (sigil + trine) — 추가

> 기존 상태: 완료 검증 프로세스 없음
> 추가 이유: 증거 기반 완료 검증 — "Should work now" 합리화 차단

**트리거:**
- "완료", "다 됐다", "끝났다" 선언 직전
- git commit / PR 생성 직전
- 태스크를 completed로 마킹 직전
- 문서 최종본 제출 직전 (sigil)

**호출:** `Skill("superpowers:verification-before-completion")`
- 증거 없이 완료 주장 금지
- 테스트/빌드/요구사항 각각 검증 필수
- "Should work now", "I'm confident" 합리화 차단

### 6. Code Review (trine only) — 교체

> 교체 대상: 기존 code-reviewer 에이전트 (단일 리뷰)
> 교체 이유: BASE_SHA/HEAD_SHA 기반 2단계 리뷰 (spec compliance → code quality) > 단일 리뷰

**트리거:**
- 기능 구현 완료 후 (3개 이상 파일 변경)
- merge/PR 전
- 사용자 리뷰 요청

**호출:** `Skill("superpowers:requesting-code-review")`
- Step 1: git SHA 확인
  ```bash
  BASE_SHA=$(git rev-parse HEAD~N)  # 또는 origin/main
  HEAD_SHA=$(git rev-parse HEAD)
  ```
- Step 2: code-reviewer 서브에이전트 디스패치
  ```
  Task(subagent_type="superpowers:code-reviewer", prompt="
    WHAT_WAS_IMPLEMENTED: {구현 내용}
    PLAN_OR_REQUIREMENTS: {계획 문서 경로}
    BASE_SHA: {base}
    HEAD_SHA: {head}
    DESCRIPTION: {요약}
  ")
  ```
- Step 3: 피드백 처리
  - Critical → 즉시 수정
  - Important → 진행 전 수정
  - Minor → 나중에 처리

### 7. Git Worktrees (trine only) — 교체

> 교체 대상: 브랜치 전략만 존재 (`git checkout -b feature/x`)
> 교체 이유: worktree 격리 환경 + .gitignore 안전 검증 + 프로젝트 설정 자동 탐지 > 브랜치만

**트리거:**
- 새 feature 브랜치 작업 시작
- 격리 환경 필요한 구현
- executing-plans / subagent-driven-development 시작 전

**호출:** `Skill("superpowers:using-git-worktrees")`
- `git worktree add ../project-feature-name feature/feature-name`
- .gitignore 안전 검증 (node_modules, .env, dist 등)
- 프로젝트 설정 탐지 (package.json → npm/pnpm install)
- 기본 테스트 통과 확인 후 작업 시작

### 8. Finishing Branch (trine only) — 추가

> 기존 상태: 구조화된 브랜치 완료 프로세스 없음 (수동 PR)
> 추가 이유: 4옵션 구조화 (Merge/PR/Keep/Discard)

**트리거:**
- 전체 구현 완료 + 테스트 통과
- verification-before-completion 통과 후

**호출:** `Skill("superpowers:finishing-a-development-branch")`
- Step 1: 테스트 통과 확인
- Step 2: 4가지 옵션 제시
  - Option A: 직접 Merge (main/develop에 병합)
  - Option B: PR 생성 (`gh pr create`)
  - Option C: 브랜치 유지 (추가 작업 예정)
  - Option D: 브랜치 폐기 (실험 종료)
- Step 3: 선택 실행 + worktree 정리

---

## 보조 스킬 — 자동 체인

| 보조 스킬 | 호출 | 트리거 | 적용 |
|----------|------|--------|------|
| writing-plans | `Skill("superpowers:writing-plans")` | brainstorming 완료 후 / "계획 세워줘" | sigil + trine |
| executing-plans | `Skill("superpowers:executing-plans")` | writing-plans 완료 후 / 별도 세션 실행 | trine |
| subagent-driven-development | `Skill("superpowers:subagent-driven-development")` | 독립 태스크 다수 + 같은 세션 | trine |
| dispatching-parallel-agents | `Skill("superpowers:dispatching-parallel-agents")` | 독립 문제 2개 이상 동시 | sigil + trine |
| finishing-a-development-branch | `Skill("superpowers:finishing-a-development-branch")` | 전체 구현 완료 + 테스트 통과 | trine |

---

## 파이프라인 단계별 호출 매핑

### sigil (Business) — Phase 0 Discovery + Phase 4 Launch

```
Phase 0.1 자료조사
  → Skill("research-engineer") + Browse AI + Semrush     (유지)

Phase 0.2 시장분석
  → Skill("competitive-ads-extractor") + seo-audit        (유지)

Phase 0.3 아이디어 도출
  → ① Skill("superpowers:brainstorming")                  (교체 ← sequentialthinking)
  → Skill("game-changing-features")                       (유지, 보조)

Phase 0.4 사업 아이템 선정
  → Skill("product-manager-toolkit") + pricing-strategy    (유지)

Phase 0.5 기획서 작성
  → Skill("cto-advisor") + launch-strategy → docx/pptx    (유지)

Phase 0.6 개발계획서
  → Skill("requirements-clarity")                         (유지, 전처리)
  → ② Skill("superpowers:writing-plans")                  (교체 ← concise-planning)

Phase 4 Launch & Growth
  → marketing-ideas + Buffer + Mailchimp + Surfer SEO      (유지)

모든 Phase 공통:
  에러 시 → ③ Skill("superpowers:systematic-debugging")    (추가)
  완료 전 → ④ Skill("superpowers:verification-before-completion") (추가)
```

### trine (Dev SDD) — Phase 1 Spec → Phase 2 Impl → Phase 3 Delivery

```
Phase 1 Spec:
  설계 검토 → ① Skill("superpowers:brainstorming")        (교체 ← sequentialthinking)
  Plan 작성 → ② Skill("superpowers:writing-plans")        (교체 ← concise-planning)
  [STOP] Human 검토                                       (유지)

Phase 2 Implementation:
  격리 환경 → ③ Skill("superpowers:using-git-worktrees")   (교체 ← 브랜치만)
  TeamCreate → Agent Teams (Opus→Sonnet→Haiku)             (유지, 기존이 더 정교)
  per task  → ④ Skill("superpowers:test-driven-development") (추가)
  에러 발생 → ⑤ Skill("superpowers:systematic-debugging")   (추가)
  태스크 완료 → ⑥ Skill("superpowers:verification-before-completion") (추가)

Phase 3 Delivery:
  커밋      → Conventional Commits + Co-Authored-By         (유지)
  코드 리뷰 → ⑦ Skill("superpowers:requesting-code-review") (교체 ← code-reviewer 에이전트)
             → Task(subagent_type="superpowers:code-reviewer") (서브에이전트 디스패치)
  완료 검증 → ⑧ Skill("superpowers:verification-before-completion") (추가)
  PR/Merge  → ⑨ Skill("superpowers:finishing-a-development-branch") (추가)
  Human 검토                                               (유지)
```

---

## 워크플로우 체인 (전체 흐름)

### trine (개발 프로젝트)

```
새 기능 요청
  ① Skill("superpowers:brainstorming")          — 디자인 HARD-GATE
    ② Skill("superpowers:writing-plans")         — bite-sized 계획
      ③ Skill("superpowers:using-git-worktrees") — 격리 환경
        [per task]:
          ④ Skill("superpowers:test-driven-development")   — Red-Green-Refactor
            에러 시 → ⑤ Skill("superpowers:systematic-debugging") — 4단계 분석
          ⑥ Skill("superpowers:verification-before-completion") — 태스크 완료 검증
        [all tasks done]:
          ⑦ Skill("superpowers:requesting-code-review")    — 2단계 리뷰
            → Task(subagent_type="superpowers:code-reviewer")
          ⑧ Skill("superpowers:verification-before-completion") — 전체 완료 검증
          ⑨ Skill("superpowers:finishing-a-development-branch") — Merge/PR/Keep/Discard
```

### sigil (Business 프로젝트)

```
새 기획/기능 요청
  ① Skill("superpowers:brainstorming")          — 접근법 탐색 + HARD-GATE
    + Skill("game-changing-features")            — 10x 기회 보조 (유지)
  ② Skill("requirements-clarity")               — 요구사항 명확화 (유지, 전처리)
    ③ Skill("superpowers:writing-plans")         — 태스크 분해
      [각 태스크 실행]:
        기존 도메인 스킬 (research-engineer, product-strategist 등)
          에러 시 → ④ Skill("superpowers:systematic-debugging") — 4단계 분석
        ⑤ Skill("superpowers:verification-before-completion") — 결과 검증
```

---

## 기존 기능 교체/추가 매핑

| 기존 기능 | 기존 호출 | 상태 | 교체 후 호출 |
|----------|----------|:----:|------------|
| sequentialthinking MCP (문제 분해) | `mcp__sequential-thinking__sequentialthinking()` | **교체** | `Skill("superpowers:brainstorming")` |
| concise-planning (계획) | `concise-planning` (수동) | **교체** | `Skill("superpowers:writing-plans")` |
| 즉석 수정 시도 | — | **추가** | `Skill("superpowers:systematic-debugging")` |
| 코드 후 테스트 패턴 | — | **추가** | `Skill("superpowers:test-driven-development")` |
| 완료 검증 없음 | — | **추가** | `Skill("superpowers:verification-before-completion")` |
| code-reviewer 에이전트 (단일) | `Task(subagent_type="superpowers:code-reviewer")` | **교체** | `Skill("superpowers:requesting-code-review")` → `Task(subagent_type="superpowers:code-reviewer")` |
| 브랜치 전략만 | `git checkout -b feature/x` | **교체** | `Skill("superpowers:using-git-worktrees")` |
| 수동 PR | `gh pr create` | **추가** | `Skill("superpowers:finishing-a-development-branch")` |

## 유지되는 기존 기능 (교체하지 않음)

| 기존 기능 | 유지 이유 | 참조 문서 |
|----------|----------|----------|
| Agent Teams 모델 계층화 (Opus→Sonnet→Haiku) | superpowers 미지원 | `.claude/rules/agent-teams.md` |
| Agent Teams 4대 오케스트레이션 패턴 | 기존이 더 정교 | `.claude/rules/agent-teams.md` |
| Research Methodology | superpowers에 리서치 없음 | `.claude/rules/research-methodology.md` |
| Security/File-naming | superpowers 미지원, 항상 우선 | `.claude/rules/security.md`, `file-naming.md` |
| Cross-project pipeline | superpowers 미지원 | `.claude/rules/cross-project-pipeline.md` |
| 도메인 에이전트 (portfolio-analyzer 등) | superpowers는 code-reviewer만 제공 | `.claude/agents/*.md` |
| v3 수동 복사 스킬 (frontend-design, docx, pdf 등) | v4.3.1에서 제거됨, 유지 필수 | `.claude/skills/frontend-design/` 등 |
| requirements-clarity | superpowers 미지원, brainstorming 전처리 | `.claude/skills/requirements-clarity/` |
| game-changing-features | superpowers 미지원, brainstorming 보조 | `.claude/skills/game-changing-features/` |
| Conventional Commits + Co-Authored-By | superpowers 미지원 | `.claude/rules/git.md` |
