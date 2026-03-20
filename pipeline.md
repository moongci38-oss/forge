# Forge Pipeline (Phase 1~12)

> 아이디어에서 프로덕션까지. Phase 1~12 단일 연속 번호.
> `forge/` = 시스템 (파이프라인, 규칙, 도구). `forge-outputs/` = 결과물 (산출물 전부).
> **forge/에 산출물 저장 금지.**

## 전체 흐름

```
═══ Part A: 기획 (forge/) ═══

Phase 1 Research → Phase 2 Concept → Phase 3 Design Doc → Phase 4 Planning Package
  [AUTO-PASS]        [STOP]            [STOP]               [AUTO-PASS]
                                                                  ↓
═══ 전환점 ═══                                    Phase 5 Handoff + Project Setup
                                                        [AUTO-PASS]
                                                                  ↓
═══ Part B: 개발+배포 (project/) ═══

Phase 6 → Phase 7 → Phase 8 → Phase 9 → Phase 10 → Phase 11 → Phase 12
Session   Spec      Implement  PR+Merge  Develop    Release    Production
 (auto)  [STOP]    (auto-fix)  [STOP]    (auto)     [STOP]     (auto)
```

### 브랜치 ↔ 환경 매핑

| Git 브랜치 | 서버 환경 | Phase |
|-----------|----------|:-----:|
| `develop` | Develop | 10 |
| `release/*` | Staging | 11 |
| `main` | Production | 12 |

> 본 문서에서 `main`과 `production`은 각각 Git 브랜치와 서버 환경을 가리키며, 같은 배포 단계를 의미한다.

## 진입 경로 (5가지)

| 시나리오 | 시작 Phase | 필요 입력 | 스킵 |
|---------|:---------:|----------|------|
| 아이디어만 있음 | Phase 1 | 아이디어 한 줄 | 없음 |
| 리서치 자료 있음 | Phase 2 | 기존 리서치 문서 | Phase 1 |
| 컨셉 확정됨 | Phase 3 | 컨셉 문서 or Lean Canvas | Phase 1+2 |
| 기획서(PRD/GDD) 있음 | Phase 4 | 기획서 문서 | Phase 1+2+3 |
| 기획 패키지 있음 | Phase 6 | S4 산출물 + Handoff | Part A 전체 |

> **Soft 의존성** (스킵 가능): Phase 1→2, Phase 2→3
> **Hard 의존성** (순서 불변): Phase 3→4→5→6, Phase 7→8

## 모델 계층화

| 역할 | 모델 | 적용 범위 |
|------|:----:|----------|
| Lead / 오케스트레이션 | Opus 4.6 | 판단, 종합, 게이트 심판, 아키텍처 |
| 기획서·문서·코드 작성 | Sonnet 4.6 | PRD/GDD, Spec, 구현, 테스트 |
| 리서치·탐색 | Haiku 4.5 | 검색, 팩트체크, 파일 탐색 |

---

# Part A: 기획 (forge/)

## Phase 1: Research

> 방법론: AI-augmented Research + JTBD + Competitive Intelligence
> Check 1: AUTO-PASS (DoD 자동 검증)

1. 프로젝트 유형 식별 (앱/웹/게임)
2. `forge-workspace.json`에서 `folderMap` 경로 확인
3. **research-coordinator** Subagent 스폰 (Fan-out 병렬):
   - market-researcher, academic-researcher, fact-checker 3명 동시 투입
   - TAM/SAM/SOM, 경쟁사 5개사+, 기술 트렌드 독립 조사
   - 결과 병합 + 신뢰도 등급(High/Medium/Low) 표기
4. 산출물 저장: `{folderMap.research}/projects/{project}/YYYY-MM-DD-phase1-{topic}.md`
5. gate-log.md 업데이트

**도구**: Brave Search(MCP), WebSearch(내장), Context7(MCP), Sequential Thinking(MCP), Notion(MCP), `/screenshot-analyze`, `/game-reference-collect`

   ─── [AUTO-PASS] Check 1: DoD 자동 검증 → 알림 후 자동 진행 ───

---

## Phase 2: Concept

> 방법론: Pretotyping + Mom Test + Lean Validation + OKR
> Check 2: STOP (비전/타겟/차별점 + 기획 디렉션 5축 Human 승인)

1. `/lean-canvas` → Lean Canvas 작성 (9블록)
2. TAM/SAM/SOM 추정 — TAM < $1M 시 Kill 신호
3. **Go/No-Go 스코어링** (4영역 가중 평가):

   | 영역 | 가중치 | Kill Criteria |
   |------|:-----:|---------------|
   | 시장 기회 | 30% | TAM < $1M |
   | 기술 실현성 | 25% | 핵심 기술 불가 |
   | 비즈니스 모델 | 25% | 수익화 경로 없음 |
   | 위험 관리 | 20% | 규제 장벽 |

   - 80점+ = Go / 60-79점 = 조건부 / 60점 미만 = No-Go

4. **기획 디렉션 5축** 수립:

   | # | 축 | 형식 요건 |
   |:-:|---|---------|
   | 1 | 전략 방향 | "A > B" 또는 "A, not B" (트레이드오프 필수) |
   | 2 | 경험 원칙 | 측정 가능한 수치 포함 |
   | 3 | 범위 경계 | Do 2개+ / Don't 2개+ (Don't는 `태그` 형식) |
   | 4 | 품질 기준 | 측정 가능한 NFR 값 |
   | 5 | 벤치마크 | 레퍼런스 1-3개 + 참조 이유 |

   - **Iron Law**: Axis 1/3은 Human 확인 없이 확정 금지

5. **Pretotyping** (3경로):

   | 경로 | 방법 | 도구 | 적합 상황 |
   |------|------|------|----------|
   | A | 클릭 가능 프로토타입 | Replit Agent | UI/UX 검증 |
   | B | AI UI 목업 | **Stitch MCP** | 빠른 시각 검증 |
   | C | 문서 Pretotype | Markdown | 콘텐츠/가격 검증 |

6. OKR 정의 (Phase 3 기획서 측정 기준으로 연결)
7. 산출물 저장 + gate-log.md 업데이트

**도구**: Brave Search(MCP), Stitch(MCP), Sequential Thinking(MCP), Notion(MCP)

   ─── **[STOP]** Check 2: 비전/타겟/차별점 + 기획 디렉션 5축 Human 승인 ───

---

## Phase 3: Design Document

> 에이전트 회의 필수 (Competing Hypotheses). PPT 변환 필수 (.md + .pptx).
> Check 3: STOP (기획서 Human 승인)

| 유형 | 에이전트 | 산출물 |
|------|---------|--------|
| 앱/웹 | `/prd` 커맨드 | PRD (.md + .pptx 필수) |
| 게임 | `gdd-writer` 에이전트 | GDD (.md + .pptx 필수) |

### 에이전트 회의 흐름

```
Phase 2 디렉션 5축 요약 프롬프트 주입 (~5줄)
    ↓
에이전트 A/B/C 자유 초안 작성
    ↓
디렉션 탈락 필터 (Don't 태그 위반 → 해당 초안 탈락)
    ↓
생존 초안만 비교 (아키텍처, 성능, UX) → 최적안 선택/병합
```

1. Phase 2 디렉션 5축 요약을 에이전트 프롬프트에 주입
2. 에이전트 2~3명 병렬 스폰 → 독립 기획서 초안
3. **디렉션 탈락 필터**: Don't 태그 위반 초안 → 비교에서 제외
4. Competing Hypotheses: 생존 초안 비교표 + 선택 근거
5. 시각 자료 포함 필수: Mermaid, Stitch UI 목업, NanoBanana 일러스트
6. **Glossary** 섹션 필수 (한국어↔영어↔정의↔관계 4열 테이블)
7. 관리자 기능 포함 시 관리자 기획서도 동등 작성
8. `/pptx` 스킬로 .pptx 변환 (단계적: 시안 5-7슬라이드 → 전체 확장)
9. 산출물 저장 + gate-log.md 업데이트

### Diamond Architecture (시각 자료 생성 시 인라인 호출)

```
"가챠 UI 목업 필요"
  → library-search (Prefab Library 검색)
  → 없음 → style-guide 확인 → soul-prompt-craft → Stitch/NanoBanana 생성
  → 기획서에 삽입

"전투 FSM 다이어그램 필요"
  → game-logic-visualize → Playground 시뮬레이터 생성
```

> Diamond Architecture 상세: `planning/rules-source/always/resource-generation.md` 참조

**도구**: NanoBanana(MCP), Stitch(MCP), Draw.io(MCP), Notion(MCP), `/pptx`, `/screenshot-analyze`, `/game-logic-visualize`, `/game-reference-collect`, `/video-reference-guide`, Mermaid(인라인)

   ─── **[STOP]** Check 3: 기획서(.md + .pptx) Human 승인 ───

---

## Phase 4: Planning Package

> 방법론: Now/Next/Later + RICE/ICE + C4 Model + ADR + 테스트 전략
> Check 4: AUTO-PASS (Wave 검증 자동 통과 / 실패 시 STOP)

### 필수 산출물 3종

| # | 산출물 | 파일명 | 내용 |
|:-:|--------|--------|------|
| 1 | **상세 기획서** | s4-detailed-plan.md | 화면별 동작 + 데이터 흐름 + 사이트맵 |
| 2 | **개발 계획** | s4-development-plan.md | 기술 스택 + C4 아키텍처 + ADR + 세션 로드맵 + WBS + **테스트 전략** |
| 3 | **UI/UX 기획서** | s4-uiux-spec.md | 와이어프레임 + 컴포넌트 스펙 + 인터랙션 패턴 |

> Phase 3에 관리자 기능 포함 시: `s4-admin-detailed-plan.md`, `s4-admin-uiux-spec.md` 추가 필수

### Spec 크기 가드레일 5원칙

| # | 원칙 | 기준 | 위반 시 |
|:-:|------|------|---------|
| 1 | 1 Spec = 1 Feature | 하나의 사용자 가치 단위 | 분리 권고 |
| 2 | Spec 크기 상한 | 700-900줄 적정, 1,500줄+ 분리 필수 | [STOP] |
| 3 | SP 상한 | 5-8 SP 적정, 12+ 분리 필수 | [STOP] |
| 4 | 세션-Spec 명시 | "Session N — Spec M: [제목] (N SP)" 형식 | Gate FAIL |
| 5 | 번들링 정당화 | 2개 기능 번들 시 분리 불가 사유 명시 | 리뷰 시 확인 |

### Wave 프로토콜

```
Wave 1 (순차): technical-writer → 3종 산출물 초안
  - Phase 3 시각 자료 재활용 정책 적용
  - MCP 도구 (Stitch, NanoBanana, Draw.io) 직접 호출

Wave 2A (트레이서빌리티 검증):
  - Phase 3 FR/NFR 전수 체크 → 누락 항목 보완

Wave 2B (디렉션 일관성 검증 — Lead 또는 cto-advisor, self-review 불허):
  - Phase 2 디렉션 5축 vs Phase 4 산출물 일관성 검증
  - Don't 태그 위반 = CRITICAL → [STOP]
  - 전략/품질 불일치 = WARN

Wave 3 (병렬):
  - cto-advisor    → 기술 검토 (아키텍처, ADR)
  - ux-researcher  → UX 검증 (와이어프레임, 인터랙션)

Wave 4 (최종): technical-writer → Wave 2-3 반영 최종본
```

### Diamond Architecture (대량 에셋 + 품질 검증)

```
Phase 4 작성 중 "대량 아이콘 필요"
  → game-asset-generate (P3 대량) → asset-critic (P4 검증)

"UI/UX 기획서에 와이어프레임 필요"
  → Stitch MCP → 화면 목업 생성
```

### AUTO-PASS 조건 (모두 충족)

1. `forge-gate-check.sh` Phase 4 → PASS
2. Wave 2A: 누락 FR/NFR 0건
3. Wave 2B: CRITICAL 0건 (Don't 태그 위반 없음)
4. Wave 3: CRITICAL 0건

하나라도 FAIL → [STOP] 에스컬레이션.

**도구**: Stitch(MCP), NanoBanana(MCP), Draw.io(MCP), Notion(MCP), `/screenshot-analyze`, `/game-logic-visualize`, `forge-gate-check.sh`, Mermaid(인라인)

   ─── [AUTO-PASS] Check 4: Wave 검증 통과 시 자동 / 실패 시 [STOP] ───

---

# 전환점

## Phase 5: Handoff + Project Setup

> Check 5: AUTO-PASS (Handoff 완성도 자동 검증)

### 전제조건

- 서버 인프라 미구축 시 `forge-outputs/docs/infrastructure/server-setup.md` 참조하여 사전 구축
- Phase 11(Release+Staging), Phase 12(Production Deploy) 실행에 서버 인프라 필수

### 신규 프로젝트 (devTarget 폴더 미존재)

`/forge-onboard` 스킬을 자동 호출하여 4단계 온보딩 실행:

1. **forge-sync 등록**: `forge-sync init` → manifest.json + `.specify/config.json`
2. **forge-sync 배포**: `forge-sync sync --target <name> --include-recommended` → 규칙/템플릿/GitLab Spec Kit
3. **프로젝트 스캐폴딩**: CLAUDE.md, constitution.md, agent-teams.md, verify.sh, docs/ 구조
4. **forge-workspace.json 등록**: devTarget + symlinkBase 연결
5. `git init` + initial commit

### 기존 프로젝트

1. `forge-sync sync --target <name>` — 규칙/템플릿 최신화
2. symlink 생성 (누락분만 추가)

### 공통 (신규/기존 모두)

1. **Handoff 문서 자동 생성**:
   - 경로: `{folderMap.handoff}/{project}/YYYY-MM-DD-forge-handoff.md`
   - 내용: 산출물 인덱스, 기술 스택, 세션 로드맵, ADR 요약
2. **symlink 일괄 생성** (`forge-workspace.json`의 `devTarget` + `symlinkBase` 기준):
   - 개발 프로젝트 `docs/planning/active/forge/{domain}/`에 산출물 symlink
   - `todo.md`는 실제 파일로 생성 (symlink 금지 — GitLab CI 호환)
3. **todo.md 행 추가** (Notion MCP 미연결 시 Tier 2 Fallback)
4. Human에게 프로젝트 폴더 이동 안내

### Forge 산출물 → Part B 매핑

| Forge 산출물 | Part B 활용 시점 |
|-------------|----------------|
| Phase 1 리서치 | Phase 6 — 프로젝트 컨텍스트 |
| Phase 3 PRD/GDD | Phase 6 — FR/NFR 추출 + Phase 7 Spec 입력 |
| Phase 4 상세 기획서 | Phase 7 — 화면별 동작, 데이터 흐름 참조 |
| Phase 4 개발 계획 | Phase 6 — 기술 스택, ADR, 세션 로드맵 + Phase 8 테스트 전략 |
| Phase 4 UI/UX 기획서 | Phase 7 — Spec UI 섹션 참조 |

   ─── [AUTO-PASS] Check 5: Handoff 완성도 자동 검증 ───
   검증 항목:
   1. Handoff 문서 존재 (`{folderMap.handoff}/{project}/`)
   2. forge-sync status — 개발 프로젝트 규칙 최신 (`node ~/.claude/scripts/forge-sync.mjs status --quiet`)
   3. 개발 프로젝트 CLAUDE.md 존재 (`{devTarget}/CLAUDE.md`)
   4. symlink 유효성 — 최소 1개 이상 정상 연결

---

# Part B: 개발+배포 (project/)

## Phase 6: Session Setup + Requirements

> 구 Phase 1 + Phase 1.5 병합

1. Handoff 문서 + Phase 4 개발 계획에서 해당 세션 내용 숙지 + 세션 요약 출력
2. 세션 상태 초기화: `node ~/.claude/forge/scripts/session-state.mjs init --name <name>`
3. **작업 규모 자동 분류** (재분류 필요 시만 [STOP]):

   | 분류 | 기준 | Phase 스킵 |
   |------|------|-----------|
   | **Hotfix** | 긴급 장애, 단일 파일 수정 | Phase 7 스킵, Check 6만 |
   | **Standard** | 일반 기능 구현, 리팩토링 | 전체 Phase 수행 |

4. (Standard만) **codebase-analyzer** Subagent → 7축 분석 리포트 → `docs/reviews/`
5. 기획서 읽기 + 불명확점 식별
6. 질문 수 판정: 0개(스킵) / 1~3개(Q&A) / 4~5개(Q&A+보완 권고) / 6+개([STOP] 반려)
7. 인터랙티브 Q&A 실행
8. 도메인 완결성 체크 (CRUD/권한/에러/3-State UI/테스트/입력 검증 6축)
9. 트레이서빌리티 매트릭스 생성 → `.specify/traceability/{name}-matrix.json`

**도구**: `session-state.mjs`(CLI), `codebase-analyzer`(에이전트), Sequential Thinking(MCP, 선택)

   ─── checkpoint: state=phase6_complete ───

---

## Phase 7: Spec Writing

> Plan/Task는 조건부. 멀티도메인/아키결정/10+파일 시 필수.
> Check 7: STOP (Spec 승인)

1. AI가 **Spec.md** 작성 → `.specify/specs/`에 저장
   - `projectType: game` → `spec-template-game.md` 자동 선택
   - `projectType: web` (기본) → `spec-template-base.md`
2. 복잡도 판단 → Plan 필요 시 Plan.md 작성
3. 3관점 검증 (Spec/Plan/Task)
4. **[STOP]** Human이 Spec(+Plan) 승인
5. (조건부) **Task.md** 작성 → **[STOP]** Human 최종 승인

**도구**: `spec-writer`(에이전트), Draw.io(MCP, 선택), Mermaid(인라인)

   ─── checkpoint: state=phase7_complete ───

---

## Phase 8: Implementation + Verification

> TDD + Subagent-driven development
> Check 6 → Check 6.5 → Check 6.7 순차 실행

### Superpowers 스킬 연동

| 시점 | 스킬 | 역할 |
|------|------|------|
| 구현 시작 시 | `superpowers:test-driven-development` | RED→GREEN→REFACTOR |
| 태스크별 구현 | `superpowers:subagent-driven-development` | 서브에이전트 스폰 + 2단계 리뷰 |
| 디버깅 발생 시 | `superpowers:systematic-debugging` | 4단계 디버깅 프로토콜 |
| 완료 선언 시 | `superpowers:verification-before-completion` | 증거 기반 완료 선언 |

### 진행 흐름

1. Spec 기준 구현 (의존성 없는 태스크만 병렬 — Wave 단위 스폰)
2. 구현 완료 후:
   - **Walkthrough 작성** → `docs/walkthroughs/`
   - **Check 6**: `verify.sh code` (test + lint + build + type)
     - 실패 → 1회 자동 수정 → 재실행 / 재실패 → **[STOP]**
     - E2E 실패 시: `test-results/` 컨텍스트 수집 → autoFix 프롬프트에 주입
3. Check 6 PASS 후 순차:
   - **Check 6.5** 트레이서빌리티 (`spec-compliance-checker` 스킬)
   - **Check 6.7** 코드 리뷰 (`code-reviewer` 에이전트)
   - 실패 → 1회 자동 수정 → 재실행 / 재실패 → **[STOP]**

### Frontend 점진적 품질 루프 (UI 파일 변경 시)

```
1. frontend-design 스킬 → 디자인 방향 결정
2. Stitch MCP → 화면 목업 생성 + get_screen_code 추출
3. 구현: Stitch 코드 기반 컴포넌트 + 비즈니스 로직
4. Playwright CLI → 렌더링 검증 (Mobile/Tablet/Desktop)
5. 디자인 조정 → 4번 재확인
6. 다음 컴포넌트로 이동
```

### Diamond Architecture (구현 중 에셋 필요 시)

```
"구현에 필요한 아이콘/이미지"
  → library-search (Prefab Library) → 있으면 재사용
  → 없으면 → soul-prompt-craft → NanoBanana/Replicate 생성
```

**도구**: `verify.sh`(CLI), `spec-compliance-checker`(스킬), `code-reviewer`(에이전트), Stitch(MCP), NanoBanana(MCP), Context7(MCP), Playwright CLI, Mermaid(인라인)

   ─── checkpoint: state=phase8_complete ───

---

## Phase 9: PR + Merge

> Check 7: CI + 리뷰 코멘트

### 완료 경로 선택

1. **PR 생성** → 기본 경로
2. **로컬 merge** → 소규모 변경
3. **브랜치 유지** → 추가 작업 예정
4. **브랜치 폐기** → 실험 브랜치 정리

### PR 생성 절차

1. AI가 커밋 생성 (Conventional Commits)
2. AI가 `glab mr create` → MR URL 반환
3. **Check 7 (PR Health Check)** — 2단계:
   - **Step 1**: `glab ci view {PIPELINE_ID} --wait` — CI 완료까지 블로킹 대기
   - **Step 2**: 리뷰 코멘트 인라인 폴링
     - 코멘트 없음 → 완료 / CI 실패·코멘트 발견 → 수정 → push → Step 1 재시작
4. **완료 분기**:
   - `autoMerge=false` → **[STOP]** Human merge 대기
   - `autoMerge=true` → CI+리뷰 PASS 시 `glab mr merge --squash --remove-source-branch`
5. (조건부) 리뷰 코멘트 → `superpowers:receiving-code-review` 프로토콜

**도구**: `gh` CLI, `code-review`(플러그인, 선택), Notion(MCP)

   ─── checkpoint: state=session_complete ───

---

## Phase 10: Develop Integration

> `develop-integration.yml` GitLab CI 자동 실행. 수동 개입 불필요.
> Check 8: 자동

1. PR merge to develop → `develop-integration.yml` 자동 트리거
2. **Check 8** 자동 실행:
   - `verify.sh code` (build + test + lint + type)
   - `e2e-runner.sh --env local` (`.specify/e2e-pipeline.json` 존재 시만)
3. **결과 분기**:
   - ✅ PASS → Phase 11 진입 가능
   - ❌ FAIL → GitLab Issue 자동 생성 → AI 분석 + 수정 → develop 재push
     - **재시도 한도: 최대 2회.** 2회 연속 FAIL 시 자동 수정 중단 → **[STOP]** Human 에스컬레이션 필수
4. PASS 확인 후 `/forge-release` 커맨드로 Phase 11 진입

   ─── Check 8: develop-integration.yml 자동 ───

---

## Phase 11: Release + Staging

> `/forge-release {version}` 커맨드로 진입.
> Check 9 + Check 9.5: STOP (Human Release PR 승인)

1. Human이 `/forge-release {version}` 실행
2. `release-staging.yml` workflow_dispatch 트리거:
   - `release/{version}` 브랜치 생성 + version bump + CHANGELOG
   - `deploy-runner.sh --env staging` (빈 값이면 skip)
   - **Check 9**: E2E (`e2e-runner.sh --env staging`)
   - Release PR 자동 생성 (`release/{version}` → `main`)
3. **Check 9.5**: **[STOP]** Human이 Release PR 검토 + 승인 + merge to main → Phase 12 자동 트리거

   ─── Check 9: release-staging.yml 자동 ───
   ─── Check 9.5: [STOP] Human Release PR 승인 ───

---

## Phase 12: Production Deploy + Rollback

> `main` push 시 `production-deploy.yml` 자동 트리거.
> Check 10: 자동 / 실패 시 STOP 롤백

1. Release PR merge to main → `production-deploy.yml` 자동 트리거
2. **Check 10** 자동 실행:
   - `deploy-runner.sh --env production` (빈 값이면 skip)
   - Health check + Smoke test (설정 시)
   - GitLab Release 자동 생성 (tag + changelog)
   - `release/{version}` 브랜치 자동 삭제
3. **결과 분기**:
   - ✅ PASS → 완료. `forge-pm-updater`로 Notion + development-plan.md 상태 갱신
   - ❌ FAIL → **[STOP]** Human이 `/forge-rollback` 실행:

     | 레벨 | 방법 | 기준 |
     |------|------|------|
     | L1 Quick Revert | `git revert` | < 30분 |
     | L2 Release Revert | 이전 릴리스 태그로 재배포 | < 2시간 |
     | L3 Hotfix Forward | `hotfix/*` → Hotfix 플로우 재진입 | > 2시간 |

   ─── Check 10: production-deploy.yml 자동 ───

---

# 부록

## 검증 게이트 전체 요약

| Check | 위치 | 유형 | 주체 |
|:-----:|------|:----:|:----:|
| 1 | Phase 1 완료 — DoD 자동 검증 | AUTO-PASS | AI |
| 2 | Phase 2 완료 — 비전+5축 승인 | **[STOP]** | Human |
| 3 | Phase 3 완료 — 기획서 승인 | **[STOP]** | Human |
| 4 | Phase 4 완료 — Wave 검증 | AUTO-PASS | AI |
| 5 | Phase 5 완료 — Handoff 검증 | AUTO-PASS | AI |
| 6 | Phase 8 — verify.sh | auto-fix→[STOP] | AI→Human |
| 6.5 | Phase 8 — 트레이서빌리티 | auto-fix→[STOP] | AI→Human |
| 6.7 | Phase 8 — 코드 리뷰 | auto-fix→[STOP] | AI→Human |
| 7 | Phase 9 — CI+리뷰 | **[STOP]** or auto-merge | Human or AI |
| 8 | Phase 10 — develop 통합 | 자동 / FAIL→[STOP] | AI |
| 9 | Phase 11 — 스테이징 E2E | 자동 | AI |
| 9.5 | Phase 11 — Release PR | **[STOP]** | Human |
| 10 | Phase 12 — 프로덕션 배포 | 자동 / FAIL→[STOP] 롤백 | AI→Human |

## Iron Laws

- Phase 3 기획서 없이 Phase 4 진입 금지 (Hard 의존성)
- Phase 4 기획 패키지 없이 Phase 5 진입 금지 (Hard 의존성)
- Handoff 문서 없이 Phase 6 세션 시작 금지
- Phase 3에 관리자 기능 포함 시 Phase 4에도 관리자 산출물 필수
- Phase 2 기획 디렉션 5축의 Axis 1/3은 Human 확인 없이 확정 금지
- Phase 4 Wave 2B Don't 태그 위반 = CRITICAL → [STOP]
- Phase 7 Spec 승인 없이 구현 시작 금지
- Phase 10 Check 8 PASS 없이 Phase 11 진입 금지
- Phase 11 Release PR 승인 없이 Phase 12 진입 금지
- 기획/계획 문서 수정은 Forge 워크스페이스 원본에서만 (symlink 자동 반영)
- **forge/에 산출물 저장 금지. 모든 산출물은 forge-outputs/로.**

## 산출물 저장 경로 요약

| 유형 | 경로 |
|------|------|
| 리서치 | `forge-outputs/01-research/projects/{project}/` |
| 컨셉 | `forge-outputs/02-product/projects/{project}/` |
| PRD/GDD | `forge-outputs/02-product/projects/{project}/` + `.pptx` |
| 상세 기획서 | `forge-outputs/02-product/projects/{project}/` |
| 개발 계획 | `forge-outputs/02-product/projects/{project}/` |
| UI/UX 기획서 | `forge-outputs/05-design/projects/{project}/` |
| Handoff 문서 | `forge-outputs/10-operations/handoff-to-dev/{project}/` |
| 게이트 로그 | `forge-outputs/02-product/projects/{project}/gate-log.md` |
| 코드베이스 분석 | `{project}/docs/reviews/` |
| Walkthrough | `{project}/docs/walkthroughs/` |
| 에셋 | `forge-outputs/05-design/projects/{project}/` |

> 모든 경로는 `forge-workspace.json`의 `folderMap`에서 해석. 파일 없으면 [STOP].

---

*Last Updated: 2026-03-19 (Phase 1~12 통합)*
