# 전체 파이프라인 워크플로우 (SIGIL → Trine)

> **SIGIL**: 전략 수립 + 기획 자동화 파이프라인 (S1→S4)
> **Trine**: 구현 + 배포 자동화 파이프라인 (Phase 1→7)
> **연결 지점**: SIGIL S4 Handoff 문서 → Trine Phase 1 세션 이해
> **운영 모델**: AI가 현재 위치를 인지하고 완료 시 다음 단계를 제안. Human이 [STOP] 게이트에서 승인.

## 전체 흐름

```
[SIGIL 파이프라인 — 기획]
S1 Research → S2 Concept → S3 Design Document → S4 Planning Package
     ↓              ↓               ↓                      ↓
[AUTO-PASS]      [STOP]          [STOP]             [AUTO-PASS]
                                                           ↓
                                               Handoff 문서 + symlink 생성
                                                           ↓
[Trine 파이프라인 — 구현 + 배포]
Phase 1 → Phase 1.5 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6 → Phase 7
  (auto)    (auto)    [STOP]     (auto)   [STOP]/auto  (자동)   [STOP]    (자동)
세션 이해   요구사항   Spec 승인   구현+검증   PR+Merge   통합검증  스테이징   프로덕션
```

### 진입 경로

| 상황 | 시작 위치 | 스킵 |
|------|----------|------|
| 아이디어만 있음 | SIGIL S1 | 없음 |
| 리서치 자료 있음 | SIGIL S2 | S1 |
| 컨셉 확정됨 | SIGIL S3 | S1+S2 |
| 기획서(PRD/GDD) 있음 | SIGIL S4 | S1+S2+S3 |
| S4 기획 패키지 있음 | Trine Phase 1 | SIGIL 전체 |

---

# Part 1. SIGIL 파이프라인

> Hard 의존성: S3→S4, S4→Trine (반드시 순서 유지)
> Soft 의존성: S1→S2, S2→S3 (기존 자료 있으면 스킵 가능)

## S1. Research (리서치)

> 방법론: AI-augmented Research + JTBD + Competitive Intelligence + Evidence-Based Management

1. 프로젝트 유형 식별 (앱/웹/게임)
2. `sigil-workspace.json`에서 `folderMap` 경로 확인
3. **research-coordinator** Subagent 스폰 (Fan-out 병렬):
   - market-researcher, academic-researcher, fact-checker 3명 동시 투입
   - 시장 규모(TAM/SAM/SOM), 경쟁사 분석, 기술 트렌드 독립 조사
   - 결과 병합 + 신뢰도 등급(High/Medium/Low) 표기
4. 산출물 저장: `{folderMap.research}/projects/{project}/YYYY-MM-DD-s1-{topic}.md`
5. gate-log.md 업데이트

   ─── [AUTO-PASS] S1 Gate: DoD 자동 검증 → 알림 후 자동 진행 ───

---

## S2. Concept (컨셉 확정)

> 방법론: Pretotyping + Mom Test + Lean Validation + TAM/SAM/SOM + OKR

1. `/lean-canvas` 스킬로 Lean Canvas 작성 (9블록)
2. TAM/SAM/SOM 추정 — TAM < $1M 시 Kill 신호
3. **Go/No-Go 스코어링** (4영역 가중 평가):

   | 영역 | 가중치 | Kill Criteria |
   |------|:-----:|---------------|
   | 시장 기회 | 30% | TAM < $1M |
   | 기술 실현성 | 25% | 핵심 기술 구현 불가 |
   | 비즈니스 모델 | 25% | 수익화 경로 없음 |
   | 위험 관리 | 20% | 규제 장벽 |

   - 80점+ = Go / 60-79점 = 조건부 / 60점 미만 = No-Go

4. OKR 정의 (S3 기획서 측정 기준으로 연결)
5. 산출물 저장: `{folderMap.product}/{project}/YYYY-MM-DD-s2-concept.md`
6. gate-log.md 업데이트

   ─── **[STOP]** S2 Gate: 비전/타겟/차별점 Human 승인 ───

---

## S3. Design Document (기획서)

> **에이전트 회의 필수**: 기획 에이전트 2~3명 독립 초안 → Competing Hypotheses → 최적안 선택/병합
> **PPT 변환 필수**: .md 완성 후 `/pptx` 스킬로 .pptx 생성

| 유형 | 에이전트 | 산출물 |
|------|---------|--------|
| 앱/웹 | `/prd` 커맨드 | PRD (.md + .pptx 필수) |
| 게임 | `gdd-writer` 에이전트 | GDD (.md + .pptx 필수) |

1. 에이전트 2~3명 병렬 스폰 → 독립 기획서 초안 작성
2. Competing Hypotheses: 비교표 + 선택 근거 명시
3. 시각 자료 필수: Mermaid 다이어그램, Stitch UI 목업, NanoBanana 일러스트, 차트
4. **Glossary** 섹션 필수 (한국어↔영어↔정의↔관계 4열 테이블)
5. 관리자 기능 포함 시 관리자 기획서도 동등 작성
6. `/pptx` 스킬로 .pptx 변환
7. 산출물 저장: `{folderMap.product}/{project}/YYYY-MM-DD-s3-prd.md` + `.pptx`
8. gate-log.md 업데이트

   ─── **[STOP]** S3 Gate: 기획서(.md + .pptx) Human 승인 ───

---

## S4. Planning Package (기획 패키지)

> 방법론: Now/Next/Later + RICE/ICE + C4 Model + ADR + 테스트 전략

### 필수 산출물 3종

| # | 산출물 | 파일명 | 내용 |
|:-:|--------|--------|------|
| 1 | **상세 기획서** | s4-detailed-plan.md | 화면별 동작 + 데이터 흐름 + 사이트맵 |
| 2 | **개발 계획** | s4-development-plan.md | 기술 스택 + C4 아키텍처 + ADR + Trine 세션 로드맵 + WBS + 테스트 전략 |
| 3 | **UI/UX 기획서** | s4-uiux-spec.md | 와이어프레임 + 컴포넌트 스펙 + 인터랙션 패턴 |

> S3에 관리자 기능 포함 시: `s4-admin-detailed-plan.md`, `s4-admin-uiux-spec.md` 추가 필수

### Wave 프로토콜

```
Wave 1 (순차): technical-writer → 3종 산출물 초안
Wave 2 (검증): S3 FR/NFR 전수 체크 → 누락 항목 보완
Wave 3 (병렬): cto-advisor(기술) + ux-researcher(UX) 동시 검토
Wave 4 (최종): technical-writer → Wave 2-3 반영 최종본
```

1. Wave 1-4 순차 실행
2. `sigil-gate-check.sh S4` 자동 검증 (8개 DoD 항목)
3. 산출물 저장: `{folderMap.product}/{project}/`, `{folderMap.design}/{project}/`
4. gate-log.md 업데이트

   ─── [AUTO-PASS] S4 Gate: Wave 검증 통과 시 자동 진행 / 실패 시 [STOP] ───

---

## SIGIL → Trine 전환 (Handoff)

> S4 Gate PASS 확인 후 실행. gate-log.md에 S4 PASS 없으면 [STOP].

1. **Handoff 문서 자동 생성**:
   - 경로: `{folderMap.handoff}/{project}/YYYY-MM-DD-sigil-handoff.md`
   - 내용: 산출물 인덱스, 기술 스택, Trine 세션 로드맵, ADR 요약, 우선순위
2. **symlink 일괄 생성** (`sigil-workspace.json` `devTarget`/`symlinkBase` 기준):
   - 개발 프로젝트 `docs/planning/active/sigil/{domain}/`에 S3/S4 산출물 symlink
   - `todo.md`는 실제 파일로 생성 (symlink 금지 — GitHub Actions 호환)
3. **Tier 2 Todo 자동 생성** (Notion MCP 미연결 시):
   - `{folderMap.product}/todo.md`에 Spec 칸반 행 추가
4. Human에게 Trine 진입 안내 → Human이 개발 프로젝트로 이동하면 Trine 자동 발동

### SIGIL 산출물 → Trine 매핑

| SIGIL 산출물 | Trine 활용 시점 |
|-------------|----------------|
| S1 리서치 | Phase 1 — 프로젝트 컨텍스트 |
| S3 PRD/GDD | Phase 1.5 — FR/NFR 추출 + Phase 2 Spec 입력 |
| S4 상세 기획서 | Phase 2 — 화면별 동작, 데이터 흐름, 사이트맵 참조 |
| S4 개발 계획 | Phase 1 — 기술 스택, ADR, 세션 로드맵 + Phase 3 테스트 전략 |
| S4 UI/UX 기획서 | Phase 2 — Spec UI 섹션 참조 |

---

# Part 2. Trine 파이프라인

> .specify/ 디렉토리 감지 시 자동 발동 (Implicit Entry)
> SIGIL S4 산출물이 symlink로 개발 프로젝트에 연결된 상태에서 시작

## Phase 1: 작업 요청 및 세션 이해

1. Handoff 문서 + S4 개발 계획에서 해당 세션 내용 숙지 + 세션 요약 출력
2. 세션 상태 초기화: `node ~/.claude/trine/scripts/session-state.mjs init --name <name>`
3. **작업 규모 자동 분류** (재분류 필요 시만 [STOP]):

   | 분류 | 기준 | Phase 스킵 |
   |------|------|-----------|
   | **Hotfix** | 긴급 장애, 단일 파일 수정 | Phase 1.5/2 스킵, Check 3만 |
   | **Standard** | 일반 기능 구현, 리팩토링 | 전체 Phase 수행 |

4. (Standard만) **codebase-analyzer** Subagent 스폰
   - 7축 분석 리포트 → `docs/reviews/`에 저장
   - Lead는 요약(~300토큰)만 수신

   ─── checkpoint: state=phase1_complete ───

---

## Phase 1.5: 요구사항 분석

> S3 PRD/GDD에서 모호한 요구사항을 구현 전에 해소
> 참조: `trine-requirements-analysis.md` 규칙

1. S3 기획서 읽기 + 불명확점 식별
2. 질문 수 판정:

   | 질문 수 | 판정 | 동작 |
   |:-------:|------|------|
   | 0개 | 명확 | Q&A 스킵 |
   | 1~3개 | 정상 | Q&A 실행 |
   | 4~5개 | 경고 | Q&A + 기획서 보완 권고 |
   | 6+개 | 반려 | [STOP] 기획서 반려 |

3. 인터랙티브 Q&A 실행
4. 도메인 완결성 체크 (CRUD/권한/에러/3-State UI/테스트/입력 검증 6축)
5. 트레이서빌리티 매트릭스 생성 → `.specify/traceability/{name}-matrix.json`

   ─── checkpoint: state=phase1.5_complete ───

---

## Phase 2: 문서 작성 (Spec → Plan → Task)

> Plan/Task는 조건부. 멀티도메인/아키결정/10+파일 시 필수.
> S4 상세 기획서 + UI/UX 기획서를 참조하여 Spec 작성.

1. AI가 **Spec.md** 작성 → `.specify/specs/`에 저장
2. 복잡도 판단:
   - Plan 필요 (멀티도메인/아키결정/10+파일) → Plan.md 작성
   - Plan 불필요 → 4단계
3. (조건부) **Plan.md** 작성 → `.specify/plans/`에 저장
4. 3관점 검증 (Spec/Plan/Task)
5. **[STOP]** Human이 Spec(+Plan) 승인
6. (조건부) **Task.md** 작성 — 3+ 병렬 에이전트 필요 시만
7. (조건부) **[STOP]** Human이 Task 최종 승인

   ─── checkpoint: state=phase2_complete ───

---

## Phase 3: 구현 + AI 자동 검증

### Superpowers 스킬 연동

| 시점 | 스킬 | 역할 |
|------|------|------|
| 구현 시작 시 | `superpowers:test-driven-development` | RED→GREEN→REFACTOR 사이클 강제 |
| 태스크별 구현 | `superpowers:subagent-driven-development` | 태스크마다 서브에이전트 스폰 + 2단계 리뷰 |
| 디버깅 발생 시 | `superpowers:systematic-debugging` | 4단계 디버깅 프로토콜 |
| 완료 선언 시 | `superpowers:verification-before-completion` | 증거 기반 완료 선언 |

### 진행 흐름

1. Spec 기준으로 구현 (의존성 없는 태스크만 병렬 — Wave 단위 스폰)
2. 구현 완료 후:
   - **Walkthrough 작성** → `docs/walkthroughs/`
   - **Check 3**: `verify.sh code` (test + lint + build + type)
     - 실패 → 1회 자동 수정 → 재실행 / 재실패 → **[STOP]**
3. Check 3 PASS 후 순차 실행:
   - **Check 3.5** 트레이서빌리티 (`spec-compliance-checker` 스킬)
   - **Check 3.7** 코드 리뷰 (`code-reviewer` 에이전트 스폰)
   - 실패 → 1회 자동 수정 → 재실행 / 재실패 → **[STOP]**

### Frontend 점진적 품질 루프 (UI 파일 변경 시)

```
1. frontend-design 스킬 → 디자인 방향 결정 (타이포/컬러/모션/레이아웃)
2. Stitch MCP → 화면 목업 생성 + get_screen_code 추출
3. 구현: Stitch 코드 기반 Next.js 컴포넌트 리팩토링 + 비즈니스 로직
4. Playwright CLI → 렌더링 검증 (Mobile/Tablet/Desktop 3개 뷰포트)
5. 디자인 조정 → 4번 재확인
6. 만족 시 다음 컴포넌트로 이동
```

   ─── checkpoint: state=phase3_complete ───

---

## Phase 4: PR 생성 및 완료

### 완료 경로 선택

1. **PR 생성** → 기본 경로
2. **로컬 merge** → 소규모 변경
3. **브랜치 유지** → 추가 작업 예정
4. **브랜치 폐기** → 실험 브랜치 정리

### PR 생성 절차 (선택지 1)

1. AI가 커밋 생성 (Conventional Commits)
2. AI가 `gh pr create` → PR URL 반환
3. **Check 5 (PR Health Check)** — 2단계 전략:
   - **Step 1**: `gh run watch {RUN_ID}` — CI 완료까지 블로킹 대기 (sleep 폴링 없음)
   - **Step 2** (CI PASS 후 즉시): `gh api .../reviews` + `gh api .../comments` + `gh api .../issues/{PR}/comments` 3종 인라인 폴링
   - 코멘트 없음 → 체크박스 자동 체크 → 완료 보고
   - CI 실패 또는 코멘트 발견 → 코드 수정 → 새 커밋 push → Step 1 재시작
   - `/loop 2m`은 세션 종료 예정 등 인라인 불가 시만 보조 수단
4. **Phase 4 완료 분기**:
   - `autoMerge=false` → **[STOP]** Human merge 대기
   - `autoMerge=true` → CI+리뷰 PASS 시 `gh pr merge --squash --delete-branch` → 완료
5. (조건부) 리뷰 코멘트 대응 → `superpowers:receiving-code-review` 프로토콜

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

   ─── Check 6: develop-integration.yml 자동 ───

---

## Phase 6: 릴리스 브랜치 + 스테이징 (수동 트리거)

> `/trine-release {version}` 커맨드로 진입. `release-staging.yml`이 릴리스 브랜치 생성부터 Release PR까지 자동화.

1. Human이 `/trine-release {version}` 실행 (예: `/trine-release 1.2.0`)
2. `release-staging.yml` workflow_dispatch 트리거:
   - `release/{version}` 브랜치 생성 (develop 기준)
   - `package.json` version 자동 bump + `CHANGELOG.md` 생성
   - `deploy-runner.sh --env staging` 실행:
     - `release-config.json`의 `environments.staging.deployCommand` 읽기
     - **빈 값이면 skip** → "배포 인프라 미설정 — build/test만 실행" 안내
   - **Check 7**: E2E (`e2e-runner.sh --env staging` — `e2e-pipeline.json` 존재 시)
   - Release PR 자동 생성 (`release/{version}` → `main`)
3. **[STOP]** Human이 Release PR 검토 + 승인 + merge to main → Phase 7 자동 트리거

   ─── Check 7: release-staging.yml 자동 ───
   ─── Check 7.5: **[STOP]** Human Release PR 승인 ───

---

## Phase 7: 프로덕션 배포 + 롤백 (자동)

> `main` push 시 `production-deploy.yml` 자동 트리거. 실패 시 `/trine-rollback`으로 롤백.

1. Release PR merge to main → `production-deploy.yml` 자동 트리거
2. **Check 8** 자동 실행:
   - `deploy-runner.sh --env production` 실행
     - `release-config.json`의 `environments.production.deployCommand` 읽기
     - **빈 값이면 skip** → build artifacts만 생성
   - Health check (`healthEndpoint` 설정 시)
   - Smoke test (`smokeTestURL` 설정 시)
   - GitHub Release 자동 생성 (tag + changelog)
   - `release/{version}` 브랜치 자동 삭제
3. **결과 분기**:
   - ✅ PASS → Phase 7 완료. `trine-pm-updater`로 todo.md 상태 갱신
   - ❌ FAIL → **[STOP]** Human이 `/trine-rollback` 실행:

     | 레벨 | 방법 | 기준 |
     |------|------|------|
     | L1 Quick Revert | `git revert` — 최근 커밋만 되돌리기 | < 30분 |
     | L2 Release Revert | 이전 릴리스 태그로 재배포 | < 2시간 |
     | L3 Hotfix Forward | `hotfix/*` 브랜치 → Trine Hotfix 플로우 재진입 | > 2시간 |

   ─── Check 8: production-deploy.yml 자동 ───
   ─── Check 8.5: **[STOP]** 롤백 필요 시 Human이 /trine-rollback 실행 ───

---

# 검증 게이트 전체 요약

| # | 게이트 | 위치 | 유형 | 주체 |
|:-:|--------|------|:----:|:----:|
| 1 | S1 DoD 자동 검증 | SIGIL S1 완료 | AUTO-PASS | AI |
| 2 | 비전/타겟/차별점 승인 | SIGIL S2 완료 | **[STOP]** | Human |
| 3 | 기획서(.md+.pptx) 승인 | SIGIL S3 완료 | **[STOP]** | Human |
| 4 | Wave 2-3 검증 통과 | SIGIL S4 완료 | AUTO-PASS | AI |
| 5 | Spec(+Plan) 승인 | Trine Phase 2 완료 | **[STOP]** | Human |
| 6 | Check 3/3.5/3.7 | Trine Phase 3 완료 | auto-fix→[STOP] | AI→Human |
| 7 | PR 검토 + Merge | Trine Phase 4 | **[STOP]** or auto-merge | Human or AI |
| 8 | Develop 통합 검증 | Trine Phase 5 | 자동 / FAIL→[STOP] | AI |
| 9 | Release PR 승인 | Trine Phase 6 | **[STOP]** | Human |
| 10 | 프로덕션 배포 검증 | Trine Phase 7 | 자동 / FAIL→[STOP] 롤백 | AI→Human |

---

# 모델 계층화

```
SIGIL pipeline-orchestrator (Lead)  → Opus 4.6   (판단, 종합, 게이트 심판)
SIGIL 기획서 작성 (gdd/prd)          → Sonnet 4.6 (문서 작성, 분석)
SIGIL 기획 패키지 (technical-writer) → Sonnet 4.6 (S4 산출물 작성)
SIGIL 리서치/검색 Teammates          → Haiku 4.5  (검색, 팩트체크, 트렌드 수집)

Trine Lead                           → Opus 4.6   (아키텍처 판단, 오케스트레이션)
Trine 구현 Teammate                  → Sonnet 4.6 (코딩, 테스트, 문서)
Trine 탐색 Teammate                  → Haiku 4.5  (파일 탐색, 패턴 확인)
```

---

# Iron Laws

- S3 기획서 없이 S4 진입 금지 (Hard 의존성)
- S4 기획 패키지 없이 Trine 진입 금지 (Hard 의존성)
- Handoff 문서 없이 Trine 세션 시작 금지
- S3에 관리자 기능 포함 시 S4에도 관리자 산출물 필수
- Trine Phase 2 Spec 승인 없이 구현 시작 금지
- Phase 5 Check 6 PASS 없이 Phase 6 진입 금지
- Phase 6 Release PR 승인 없이 Phase 7 진입 금지
- 기획/계획 문서 수정은 SIGIL 워크스페이스 원본에서만 (symlink 자동 반영)
