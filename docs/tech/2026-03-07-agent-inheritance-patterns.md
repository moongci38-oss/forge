# Agent Inheritance Patterns — SIGIL/Trine 시스템 분석

> Claude Code의 에이전트 스폰 방식에 따른 스킬 상속 차이와 우리 SIGIL/Trine 파이프라인에서의 실제 영향을 분석한다.

---

## 1. 두 방식의 핵심 차이

### Team Agent (팀 에이전트) — 파일시스템 기반 정적 상속

```
~/.claude/settings.json         ← 전역 설정
project/CLAUDE.md               ← 프로젝트 컨텍스트
project/.claude/agents/         ← 에이전트 정의
```

- 오케스트레이터와 **동일한 파일시스템**을 공유
- `CLAUDE.md`를 자동으로 읽어 프로젝트 규칙/컨텍스트 상속
- `settings.json`의 permissions, tools 설정 공유
- 시작 시점에 이미 컨텍스트가 "로드된 상태"
- 에이전트 간 **대등한 관계** (peer-to-peer)

### Sub-agent (서브에이전트) — 프롬프트 기반 동적 상속

```
Task tool 호출 시점에 명시적으로 전달
↓
{ task: "...", context: "...", tools: [...] }
```

- 오케스트레이터가 Task tool로 스폰할 때 컨텍스트를 **직접 주입**
- `CLAUDE.md`를 자동 상속하지 않음 → 프롬프트에 직접 포함 필요
- 부모의 대화 히스토리가 **격리됨** (독립 컨텍스트 창)
- **부모-자식 계층 관계** (hierarchical)

### 비교표

| 구분 | Team Agent | Sub-agent |
|------|-----------|-----------|
| 상속 시점 | 시작 시 정적 로드 | Task 호출 시 동적 주입 |
| CLAUDE.md | 자동 상속 | 자동 상속 안 됨 |
| 컨텍스트 창 | 공유 가능 | 완전 격리 |
| 권한 범위 | settings 기반 | 호출자가 명시 |
| 관계 | Peer (같은 회사 직원) | Parent-Child (브리핑받은 외주) |

---

## 2. SIGIL 시스템 에이전트 계층도

### Claude Code에서의 실제 동작

Claude Code에서 Agent tool로 스폰된 에이전트는 **동일 프로젝트 디렉토리에서 실행**되므로, `.claude/agents/`에 정의된 모든 에이전트가 CLAUDE.md를 자동 상속한다.

```
Main Session (Opus 4.6)
│
├── Agent tool → pipeline-orchestrator (Opus)     CLAUDE.md ✅
├── Agent tool → research-coordinator (Opus)      CLAUDE.md ✅
├── Agent tool → gdd-writer (Sonnet)              CLAUDE.md ✅
├── Agent tool → technical-writer (Sonnet)        CLAUDE.md ✅
├── Agent tool → market-researcher (Haiku)        CLAUDE.md ✅
├── Agent tool → academic-researcher (Sonnet)     CLAUDE.md ✅
├── Agent tool → fact-checker (Sonnet)            CLAUDE.md ✅
├── Agent tool → ux-researcher (Sonnet)           CLAUDE.md ✅
├── Agent tool → content-planner (Sonnet)         CLAUDE.md ✅
└── Agent tool → cto-advisor (Sonnet)             CLAUDE.md ✅
```

**결론: 1차 레벨 에이전트는 상속 문제가 없다.**

### 2차 레벨 (에이전트가 에이전트를 스폰할 때)

research-coordinator가 Task tool로 specialist를 스폰하는 경우:

```
Main Session
└── Agent tool → research-coordinator (Opus)      CLAUDE.md ✅
     └── Task tool → academic-researcher          CLAUDE.md ❓ (프롬프트 의존)
     └── Task tool → market-researcher            CLAUDE.md ❓ (프롬프트 의존)
     └── Task tool → fact-checker                 CLAUDE.md ❓ (프롬프트 의존)
```

이 2차 레벨에서는 `CLAUDE.md` 자동 상속이 보장되지 않는다. 하지만 실제로 이 경로가 사용되는 빈도는 낮다 — 대부분의 SIGIL 워크플로에서 Main Session이 직접 각 에이전트를 스폰한다.

---

## 3. Stage별 에이전트 스폰 매핑

### S1 Research — Fan-out 패턴

```
Main Session
└── research-coordinator (Opus) ← Agent tool, CLAUDE.md ✅
     ├── market-researcher (Haiku)    ← 시장/TAM 분석
     ├── academic-researcher (Sonnet) ← 학술 자료 조사
     └── fact-checker (Sonnet)        ← 팩트 체크
```

**상속 상태**: research-coordinator는 CLAUDE.md 상속. 하위 researcher들은 coordinator가 프롬프트로 컨텍스트를 전달하므로 핵심 규칙이 포함됨.

### S3 Design Document — Competing Hypotheses 패턴

```
Main Session (or pipeline-orchestrator)
├── gdd-writer A (Sonnet)  ← 독립 초안 1     CLAUDE.md ✅
├── gdd-writer B (Sonnet)  ← 독립 초안 2     CLAUDE.md ✅
└── gdd-writer C (Sonnet)  ← 독립 초안 3     CLAUDE.md ✅
```

**상속 상태**: 모두 Agent tool로 직접 스폰. CLAUDE.md 자동 상속. **문제 없음**.

### S4 Planning Package — Wave 기반 협업

```
Wave 1: technical-writer (Sonnet) → 6대 산출물 초안     CLAUDE.md ✅
Wave 2 (병렬):
  ├── cto-advisor (Sonnet) → 기술 검토                  CLAUDE.md ✅
  └── ux-researcher (Sonnet) → UX 검증                  CLAUDE.md ✅
Wave 3: technical-writer (Sonnet) → 리뷰 반영 최종본     CLAUDE.md ✅
```

**상속 상태**: 모두 Agent tool로 직접 스폰. **문제 없음**.

### Trine Handoff

```
Main Session
└── /trine 커맨드 → Handoff 문서 생성
     → 10-operations/handoff-to-dev/{project}/
```

**상속 상태**: Main Session이 직접 실행. **문제 없음**.

---

## 4. 상속 이슈 분석: 문제 영역 vs 안전 영역

### 문제 없는 영역 (Well-designed)

| 영역 | 이유 |
|------|------|
| **보안 규칙** | CLAUDE.md + `.claude/rules/security.md` 자동 상속 → 06-finance 접근 차단 유지 |
| **파일명 규칙** | CLAUDE.md 자동 상속 + pre-commit hook 이중 방어 |
| **SIGIL 파이프라인 규칙** | `.claude/rules/sigil-pipeline.md` 자동 상속 |
| **리서치 방법론** | `.claude/rules/research-methodology.md` 자동 상속 |
| **Git 규칙** | `.claude/rules/git.md` 자동 상속 |

### 실질적 이슈: 컨텍스트 격리 (상속이 아닌 다른 문제)

상속 차이보다 **대화 컨텍스트 격리**가 실제 영향을 주는 이슈:

| 이슈 | 영향 | 현재 대응 | 심각도 |
|------|------|----------|:------:|
| 대화 히스토리 격리 | 게이트 승인 이력, 이전 Stage 결정사항을 모름 | orchestrator 프롬프트에 명시적 전달 | Low |
| 도구 접근 제한 | market-researcher(Haiku)는 Write/Edit 없음 | 상위 에이전트가 결과를 파일로 저장 | Low |
| 파이프라인 상태 | gate-log.md 상태를 자동 인지 못 함 | orchestrator가 gate-log 읽어서 전달 | Low |
| Council 모드 평가 컨텍스트 | Councilor 간 상대방 결과를 모름 | 라운드 1 결과를 Judge가 수집 후 라운드 2에 전달 | Low |

**모두 Low 심각도** — 현재 설계에서 이미 대응이 되어 있다.

### 왜 문제가 안 되는가? — 3중 방어 메커니즘

```
방어 1: CLAUDE.md 자동 상속 (파일시스템 기반)
  └── 보안, 파일명, 파이프라인, 리서치 규칙 자동 적용

방어 2: 에이전트 프롬프트 4원칙 (agent-teams.md)
  ├── Focused: 하나의 명확한 목표만 부여
  ├── Self-contained: 필요 컨텍스트를 프롬프트에 포함
  ├── Specific scope: 작업 범위 명시적 한정
  └── Specific output: 산출물 형식/저장 위치 명시

방어 3: 파일 기반 상태 관리
  ├── gate-log.md → 파이프라인 상태
  ├── 산출물 경로 규칙 → projects/{project}/YYYY-MM-DD-s{N}-*.md
  └── handoff 문서 → Trine 전환 상태
```

---

## 5. SIGIL Stage별 조합 전략

| Stage | 에이전트 | 스폰 방식 | CLAUDE.md | 비고 |
|:-----:|---------|:---------:|:---------:|------|
| S1 | research-coordinator | Agent tool | ✅ | Fan-out lead |
| S1 | market-researcher | Agent tool | ✅ | 검색 전용 (Write 없음) |
| S1 | academic-researcher | Agent tool | ✅ | 학술 조사 |
| S1 | fact-checker | Agent tool | ✅ | 검증 |
| S2 | (Main Session 직접) | — | ✅ | Lean Canvas, 컨셉 |
| S3 | gdd-writer / prd | Agent tool | ✅ | Competing Hypotheses |
| S3 | content-planner | Agent tool | ✅ | 콘텐츠 트랙 |
| S4 | technical-writer | Agent tool | ✅ | Wave 1, 3 |
| S4 | cto-advisor | Agent tool | ✅ | Wave 2 기술 검토 |
| S4 | ux-researcher | Agent tool | ✅ | Wave 2 UX 검증 |
| Council | Councilor A~E | Agent tool | ✅ | 5명 동시 스폰 |

**결론: SIGIL 파이프라인의 모든 에이전트가 Agent tool로 스폰되어 CLAUDE.md를 상속한다.**

---

## 6. 만약 Sub-agent 방식이었다면? (가상 시나리오)

Sub-agent 방식으로 SIGIL을 구성했을 경우 발생했을 문제들:

| 문제 | 영향 | 현재 방식에서 |
|------|------|:----------:|
| 보안 규칙 미적용 | 06-finance 접근 가능 | 해당 없음 ✅ |
| 파일명 규칙 무시 | `analysis.md` 같은 비규격 파일 생성 | 해당 없음 ✅ |
| 리서치 방법론 미적용 | 신뢰도 등급, 출처 표기 누락 | 해당 없음 ✅ |
| 파이프라인 규칙 무시 | 게이트 스킵, 산출물 누락 | 해당 없음 ✅ |
| Git 규칙 미적용 | Co-Authored-By 누락, 커밋 형식 불일치 | 해당 없음 ✅ |

**Team Agent 방식 선택이 올바른 아키텍처 결정이었음을 확인.**

---

## 7. 인프라 레벨 갭 분석 (상속과 별개)

CLAUDE.md 상속 자체는 문제없지만, **Hook 커버리지**에 보완이 필요한 영역이 존재한다.

### 발견된 갭

| 갭 | 현황 | 영향 | 심각도 |
|----|------|------|:------:|
| **Read 경로 미차단** | `block-sensitive-files.sh`가 Write/Edit만 매칭 | Read 가능한 에이전트(market-researcher 등)가 이론적으로 06-finance 파일 읽기 가능 | Medium |
| **파일명 Hook 범위** | `require-date-prefix.sh`가 `docs/`만 커버 | SIGIL 산출물 경로(`01-research/`, `02-product/`, `04-content/`, `05-design/`)는 Hook 미적용 | Low |
| **리서치 포맷** | `[신뢰도: High/Medium/Low]` 태그가 에이전트 프롬프트에 미포함 | CLAUDE.md 상속으로 커버되지만, 에이전트가 프롬프트의 자체 지시를 우선할 수 있음 | Low |
| **관리자 페이지 전파** | "S3 관리자 포함 시 S4 반영" 규칙이 orchestrator에만 존재 | technical-writer 스폰 시 orchestrator가 매번 전달 필요 | Low |

### 현재 방어 수준 평가

```
보안 (Write/Edit 차단)    ████████████████████ 100%  ← Hook 완벽 방어
보안 (Read 차단)          ████████░░░░░░░░░░░░  40%  ← CLAUDE.md만 의존
파일명 규칙 (docs/)       ████████████████████ 100%  ← Hook 방어
파일명 규칙 (SIGIL 경로)   ████████████░░░░░░░░  60%  ← CLAUDE.md + 에이전트 프롬프트만
파이프라인 상태 전달       ████████████████░░░░  80%  ← orchestrator 설계로 커버
리서치 방법론 적용         ████████████████░░░░  80%  ← CLAUDE.md 상속으로 커버
```

### 개선 권고사항

| 우선순위 | 조치 | 파일 | 영향 |
|:--------:|------|------|------|
| **P1** | `block-sensitive-files.sh` Hook matcher에 `Read` 추가 | `settings.json` | Read 경로 보안 완성 |
| **P2** | `require-date-prefix.sh` 범위를 SIGIL 산출물 경로로 확장 | Hook 스크립트 | 파일명 규칙 완전 적용 |
| **P3** | technical-writer 에이전트 프롬프트에 관리자 전파 규칙 인라인 | `.claude/agents/technical-writer.md` | 컨텍스트 전달 의존 해소 |
| **P3** | research 에이전트들에 `[신뢰도]` 태그 형식 인라인 | `.claude/agents/market-researcher.md` 등 | 출력 형식 표준화 |

> 이 개선사항들은 상속 문제가 아니라 **인프라 커버리지 확장** 성격이다. 현재도 운영에 큰 문제는 없으나, 방어 깊이(Defense in Depth)를 높이는 조치들이다.

---

## 8. Claude Agent SDK 환경에서의 차이

> 참고: Claude Code와 Claude Agent SDK는 다른 환경이다.

| 환경 | Team Agent | Sub-agent | CLAUDE.md 상속 |
|------|-----------|-----------|:-------------:|
| **Claude Code** | `.claude/agents/` 정의 | Agent tool 스폰 | 동일 프로젝트 → 자동 ✅ |
| **Claude Agent SDK** | 별도 프로세스 | Task API 스폰 | 명시적 전달 필요 ❌ |

Agent SDK로 마이그레이션할 경우, 현재 CLAUDE.md에 의존하는 규칙들을 프롬프트에 명시적으로 포함해야 한다. 이 점은 향후 SDK 전환 시 주의 사항이다.

---

## 최종 결론

| 질문 | 답변 |
|------|------|
| CLAUDE.md 상속에 문제가 있는가? | **없다** — Agent tool로 스폰, 동일 프로젝트 디렉토리 |
| 컨텍스트 격리로 문제가 있는가? | **거의 없다** — orchestrator 프롬프트 + 파일 기반 상태 관리로 대응 |
| 인프라 갭이 있는가? | **일부 있다** — Read 경로 보안, Hook 범위가 보완 가능 |
| 현재 운영에 지장이 있는가? | **없다** — 3중 방어 + SIGIL 에이전트 프롬프트 설계가 충분히 커버 |

---

*Last Updated: 2026-03-07*
