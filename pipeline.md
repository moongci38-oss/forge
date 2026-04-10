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
    ↓
/autoplan — 3관점 순차 리뷰
    ↓
충돌 항목 Human 에스컬레이션
```

1. Phase 2 디렉션 5축 요약을 에이전트 프롬프트에 주입
2. 에이전트 2~3명 병렬 스폰 → 독립 기획서 초안
3. **디렉션 탈락 필터**: Don't 태그 위반 초안 → 비교에서 제외
4. Competing Hypotheses: 생존 초안 비교표 + 선택 근거
5. **`/autoplan` 3관점 순차 리뷰** [MANDATORY — Competing Hypotheses 직후 반드시 실행. 건너뛰기 금지]:

   | 순서 | 리뷰어 | 검토 항목 |
   |:----:|--------|----------|
   | 1 | CEO Review | 비즈니스 모델, 수익성, 시장 적합성 |
   | 2 | Design Review | UX/UI 일관성, 사용자 경험 흐름 |
   | 3 | Engineering Review | 기술 실현성, 아키텍처 건전성 |

   - 각 리뷰어는 기획서에 어노테이션(AGREE / WARN / BLOCK) 추가
   - BLOCK 항목 2개 이상 또는 리뷰어 간 충돌 → **[STOP]** Human 에스컬레이션
6. 시각 자료 포함 필수: Mermaid, Stitch UI 목업, NanoBanana 일러스트
7. **Glossary** 섹션 필수 (한국어↔영어↔정의↔관계 4열 테이블)
8. 관리자 기능 포함 시 관리자 기획서도 동등 작성
9. `/pptx` 스킬로 .pptx 변환 (단계적: 시안 5-7슬라이드 → 전체 확장)
10. 산출물 저장 + gate-log.md 업데이트

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
   - **learnings 자동 로드**: `.claude/learnings.jsonl` 존재 시 `/learn load` 자동 실행
     - 세션 컨텍스트와 관련성 높은 상위 3개 항목 출력
     - 이전 세션 에러 패턴, 해결법, 도구별 발견사항 포함
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

### /investigate 자동 트리거 조건

Check 6 (`verify.sh`) 결과가 아래 조건 중 하나라도 해당하면 `/investigate` 스킬을 **자동 실행**한다 (lint/type 오류는 제외):

| 조건 | 설명 |
|------|------|
| **런타임 오류** | Check 6 실패 원인이 런타임 에러 (lint·type 오류 제외) |
| **반복 패턴** | 동일 에러 패턴이 2회 이상 반복 발생 |
| **미확인 Root Cause** | 스택 트레이스에 원인 불명 에러 포함 |

`/investigate` 완료 후 분석 결과를 autoFix 프롬프트에 주입하여 재시도한다.

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
   - **Check 6.8 QA Loop**: Check 6.7 PASS 직후 `/qa` 자동 실행
     - Spec 기준 기능별 시나리오 검증 (발견→수정→재검증 루프)
     - 최대 2사이클 반복. 2사이클 이후에도 이슈 잔존 → **[STOP]** Human 에스컬레이션

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

### Pre-PR Benchmark

PR 생성 전 `/benchmark` 자동 실행 (develop baseline vs feature 브랜치 비교):

| 메트릭 | WARN 기준 | [STOP] 기준 |
|--------|:---------:|:-----------:|
| 번들 사이즈 | +10% | +25% |
| 테스트 실행 시간 | +10% | +25% |
| API 응답 시간 (적용 시) | +10% | +25% |

- WARN: 결과 기록 후 PR 생성 계속 진행
- [STOP]: Human 승인 없이 PR 생성 금지

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
4. PASS 확인 후 Canary 모니터링:
   - `release-config.json`에 `canaryEnabled: true` 설정 시 `/canary` **자동 트리거**
   - **15분** 헬스 모니터링 윈도우 실행
   - 모니터링 항목: 에러율, 응답 시간, 메모리 사용량 (모니터링 미설정 시 해당 항목 스킵)
   - Canary PASS → Phase 11 진입 / FAIL → **[STOP]** Human 에스컬레이션
5. PASS 확인 후 `/forge-release` 커맨드로 Phase 11 진입

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
| 3-AP | Phase 3 — /autoplan 3관점 리뷰 | 자동 / BLOCK→[STOP] | AI→Human |
| 4 | Phase 4 완료 — Wave 검증 | AUTO-PASS | AI |
| 5 | Phase 5 완료 — Handoff 검증 | AUTO-PASS | AI |
| 6 | Phase 8 — verify.sh | auto-fix→[STOP] | AI→Human |
| 6-INV | Phase 8 — /investigate 자동 트리거 | 자동 (런타임 오류 시) | AI |
| 6.5 | Phase 8 — 트레이서빌리티 | auto-fix→[STOP] | AI→Human |
| 6.7 | Phase 8 — 코드 리뷰 | auto-fix→[STOP] | AI→Human |
| 6.8 | Phase 8 — /qa QA Loop | 최대 2사이클→[STOP] | AI→Human |
| 7-BM | Phase 9 — /benchmark Pre-PR | WARN or [STOP] | AI→Human |
| 7 | Phase 9 — CI+리뷰 | **[STOP]** or auto-merge | Human or AI |
| 8 | Phase 10 — develop 통합 | 자동 / FAIL→[STOP] | AI |
| 8-CNR | Phase 10 — /canary 모니터링 | 자동 (canaryEnabled 시) | AI |
| 9 | Phase 11 — 스테이징 E2E | 자동 | AI |
| 9.5 | Phase 11 — Release PR | **[STOP]** | Human |
| 10 | Phase 12 — 프로덕션 배포 | 자동 / FAIL→[STOP] 롤백 | AI→Human |

## gstack 자동화 규칙

> Phase checkpoint마다 자동 실행되는 gstack 스킬 트리거 규칙 요약.

### /learn 자동 저장 (모든 Phase checkpoint)

모든 Phase checkpoint (`state=phaseN_complete`) 도달 시 `/learn save` 자동 실행:

- **저장 대상**: 새로운 패턴 발견, 발생 및 해결된 에러, 도구별 발견사항
- **저장 조건**: 해당 Phase에서 유의미한 learnings가 없으면 스킵
- **저장 경로**: `.claude/learnings.jsonl` (프로젝트 기준)

### 자동 트리거 스킬 요약

| 스킬 | 트리거 시점 | 조건 |
|------|-----------|------|
| `/learn load` | Phase 6 세션 시작 | `.claude/learnings.jsonl` 존재 시 |
| `/autoplan` | Phase 3 Competing Hypotheses 완료 후 | 항상 |
| `/investigate` | Phase 8 Check 6 실패 시 | 런타임 오류 또는 반복 에러 패턴 |
| `/qa` | Phase 8 Check 6.7 PASS 후 | 항상 |
| `/benchmark` | Phase 9 PR 생성 전 | 항상 |
| `/canary` | Phase 10 Check 8 PASS 후 | `canaryEnabled: true` 시 |
| `/learn save` | 모든 Phase checkpoint | 유의미한 learnings 존재 시 |

---

## Iron Laws (Single Source of Truth)

> 이 섹션이 모든 Iron Laws의 유일한 정의. forge-core.md, forge-planning.md는 이 섹션을 참조.

### 파이프라인
- **PIPELINE-IRON-1**: Phase 3 기획서 없이 Phase 4 진입 금지 (Hard 의존성)
- **PIPELINE-IRON-2**: Phase 4 기획 패키지 없이 Phase 5 진입 금지 (Hard 의존성)
- **PHASE3-IRON-1**: 단일 에이전트 초안으로 기획서 확정 금지 (에이전트 회의 필수)
- **PHASE3-IRON-2**: .pptx 없이 기획서 승인 금지
- **PHASE4-IRON-1**: 필수 산출물 3종 완성 전 Gate 통과 금지
- **PHASE4-IRON-2**: Phase 3에 관리자 기능 포함 시 Phase 4에도 관리자 산출물 필수
- **HANDOFF-IRON-1**: Handoff 문서 없이 Phase 6 진입 금지
- Phase 2 기획 디렉션 5축의 Axis 1/3은 Human 확인 없이 확정 금지
- Phase 4 Wave 2B Don't 태그 위반 = CRITICAL → [STOP]
- Phase 7 Spec 승인 없이 구현 시작 금지
- Phase 10 Check 8 PASS 없이 Phase 11 진입 금지
- Phase 11 Release PR 승인 없이 Phase 12 진입 금지
- 기획/계획 문서 수정은 Forge 워크스페이스 원본에서만 (symlink 자동 반영)

### 산출물
- **OUTPUTS-IRON-1**: forge/에 산출물 저장 금지. 모든 산출물은 forge-outputs/로
- **OUTPUTS-IRON-2**: `forge-outputs/`는 forge/의 형제 폴더 (`~/forge-outputs/`). CWD 상대경로 금지

### 보안
- **SECURITY-IRON-1**: 민감 정보(.env, credentials, API 키) 절대 커밋 금지
- **SECURITY-IRON-2**: 06-finance/, 07-legal/, 08-admin/ 내용 외부 출력 금지
- **SECURITY-IRON-3**: 하드코딩 시크릿 코드 포함 금지
- **SECURITY-IRON-4**: `forge/dev/`, `~/.claude/rules/`, `~/.claude/scripts/` 삭제/이동/덮어쓰기 금지

### 병렬 실행
- **PARALLEL-IRON-1**: 파일 소유권 미선언 상태로 병렬 작업 금지
- **PARALLEL-IRON-2**: 의존성 있는 태스크 동시 스폰 금지

### PM
- **PM-IRON-1**: Human 수동 변경한 Notion 상태 덮어쓰기 금지

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

*Last Updated: 2026-03-30 (gstack 자동화 7개 통합)*

---

# Part C: 정부지원사업 (forge-outputs/09-grants/)

> 정부기관 지원사업 라이프사이클 관리. Part A/B와 인프라(Subagent, Notion, Cron)를 공유하되 Phase/Gate는 독립 운영.
> Check GR: 각 Phase별 게이트

## 전체 흐름

```
Phase GR-1: 공고 분석 & 적격성   → Phase GR-2: 전략 & Go/No-Go → Phase GR-3: 서류 작성
  [AUTO-PASS]                        [STOP]                          [STOP]
                                                                        ↓
Phase GR-4: 제출 패키지 완성     → Phase GR-5: 제출 & 대기        → Phase GR-6: 수행 관리
  [STOP]                             [ASYNC]                         [주기적 체크포인트]
```

## Phase GR-1: 공고 분석 & 적격성 검토

> 공고문 파싱 → _grant-info.md 자동 생성 → 적격성 판정
> Check GR-1: AUTO-PASS (자격 요건 충족 시)

1. 트리거: `/grants {agency} {사업명}` 또는 공고 파일 경로 제공
2. 원본 파일을 `_source/`로 복사 (E:\정부지원\에서)
3. Subagent Wave 1 (3명 병렬):
   - Subagent A: 공고문 파싱 → `_grant-info.md` 자동 생성 (기본정보, 일정, 제출서류 체크리스트, 평가기준)
   - Subagent B: 지원 자격 체크 → `eligibility-check.md`
   - Subagent C: 과거 선정 사례 웹 리서치 → `competition-analysis.md`
4. 산출물: `_grant-info.md`, `00-research/*`
5. Notion Grants DB에 사업 등록

**도구**: Read(PDF/HWP), Brave Search(MCP), WebSearch(내장)

   ─── [AUTO-PASS] Check GR-1: 자격 요건 충족 시 자동 진행 ───

---

## Phase GR-2: 전략 수립 & Go/No-Go

> 시장조사 + 평가기준 기반 고득점 전략 수립
> Check GR-2: STOP (Human Go/No-Go 결정)

1. Subagent Wave 1 (2명 병렬):
   - 시장조사 Subagent → `market-research/`
   - 평가기준 분석 Subagent → `evaluation-criteria.md` + `strategy.md`
2. Human에게 분석 결과 보고
3. Go/No-Go 판단:
   - Go → GR-3 진행
   - No-Go → `_archive/`로 이동 + 사유 기록

**도구**: Brave Search(MCP), WebSearch(내장), Sequential Thinking(MCP)

   ─── **[STOP]** Check GR-2: Human Go/No-Go 결정 ───

---

## Phase GR-3: 서류 작성

> _grant-info.md 체크리스트 기반 서류 작성
> Check GR-3: STOP (Human 검토 승인)

1. `_grant-info.md`의 제출서류 체크리스트 확인
2. `_source/신청양식/`에서 양식 파일 참조
3. Subagent 작업:
   - Writer Subagent: 사업수행계획서 초안 (평가기준 고득점 영역 집중)
   - Budget Subagent: 예산편성 규칙 기반 예산서 초안
4. 반복 루프: Human 피드백 → 수정 → 체크리스트 업데이트 (최대 3회)
5. 산출물: `01-preparation/drafts/`, `budget/`

   ─── **[STOP]** Check GR-3: Human 검토 승인 ───

---

## Phase GR-4: 제출 패키지 완성

> 최종 검증 + 제출 확정본 격리
> Check GR-4: STOP (최종 확인)

1. 자동 검증:
   - `_grant-info.md` 체크리스트 vs `02-submission/final/` 파일 대조
   - 파일명 규칙 확인 (e나라도움 규격 등)
   - 용량 확인 (50MB 이하 등 기관별 제한)
2. 발표 자료 준비 (2단계 평가 대비)
3. 산출물: `02-submission/final/`, `presentation/`

   ─── **[STOP]** Check GR-4: Human 최종 확인 ───

---

## Phase GR-5: 제출 & 결과 대기

> 제출 기록 + Notion 상태 업데이트
> ASYNC (결과 발표 대기)

1. 제출 기록 → `submission-log.md` (제출 일시, 접수번호)
2. Notion Grants DB 상태 → "GR-5 제출완료"
3. 발표 평가 준비 (서면 통과 시)

---

## Phase GR-6: 수행 관리

> 선정 후 협약~정산~사후관리 또는 탈락 처리

### 선정 시:
1. 협약 체결 → `03-selection/agreement/`
2. 마일스톤 일정 등록 (Notion + Cron 알림)
3. 중간보고/실적보고 → `04-execution/reports/`
4. 정산 → `05-settlement/`
5. 사후관리 → `06-postcare/`

### 탈락 시:
1. 심사평 기록 → `03-selection/result.md`
2. `_archive/`로 이동
3. `_common/knowledge-base/lessons-learned.md` 업데이트
