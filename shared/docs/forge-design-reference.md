# Forge Dev — Design Reference

> 실행계획(`forge-execution-plan.md`)에서 분리된 배경/벤치마킹/철학/인벤토리 참고 자료

---

## Forge Dev 핵심 철학: SDD + DDD + TDD on Claude Code

Forge Dev은 **3대 방법론의 융합** 위에 **AI 도구(Claude Code)**를 결합한 AI-Native 개발 시스템이다:

| 기둥 | 역할 | SDD 파이프라인 매핑 |
|------|------|-------------------|
| **SDD** (Spec-Driven Development) | 문서 기반 개발 파이프라인 — 요구사항->Spec->구현->검증->PR | 전체 Phase 1->4 흐름 |
| **DDD** (Domain-Driven Design) | 도메인 모델링 — Ubiquitous Language, Bounded Context, Strategic/Tactical Design | Phase 1.5 요구사항 분석 + Phase 2 Spec + Agent Teams 파일 소유권 |
| **TDD** (Test-Driven Development) | 테스트 우선 개발 — Red->Green->Refactor 사이클 | Phase 2 테스트 요구사항 정의 -> Phase 3 테스트 작성->구현->리팩토링 -> Check 3 검증 |
| **Claude Code** (AI Tool) | AI 에이전트 기반 자동화 — Rules, Skills, Agents, Hooks, MCP 서버 | 모든 Phase에서 AI가 실행 엔진 역할 |

> **SDD = DDD + TDD + AI 자동화의 통합 오케스트레이션 계층**. DDD로 "무엇을 만들 것인가"를 정의하고, TDD로 "올바르게 만들었는가"를 검증하며, Claude Code로 "AI가 이 전체 프로세스를 실행"한다.

---

## bkit.ai 벤치마킹

[bkit](https://www.bkit.ai/) (Vibecoding Kit)은 Claude Code 플러그인으로, PDCA(Plan-Do-Check-Act) 방법론 기반 AI-Native 개발 시스템이다.

| 항목 | bkit | Forge Dev |
|------|------|---------|
| **방법론** | PDCA (Plan-Do-Check-Act) | **SDD + DDD + TDD** — Claude Code 기반 AI-Native 융합 |
| **파이프라인** | 9-stage (Schema->Deploy) | 4-Phase + 5-Check (Spec->PR) |
| **배포 형태** | Claude Code Plugin (마켓플레이스) | 현재 수동 설정 -> **Plugin 목표** |
| **구성 요소** | 27 Skills, 16 Agents, 45 Scripts, 241 Functions | 7 Rules, 3 Agents, 6 Templates, 2 Skills, 4 Commands, 1 Prompt, 1 Doc |
| **검증 체계** | Check-Act 반복 (최대 5회, 90% 임계값) | Check 3->3.5->3.6/3.7/3.8 (3계층, 최대 3회) |
| **팀 구성** | CTO-Led Team (5팀 에이전트) | Agent Teams (Lead + Domain Teammates) |
| **커스터마이징** | 파일 복사 후 오버라이드 (`.claude/` > `~/.claude/` > 플러그인) | 프로젝트 `.claude/rules/`에서 오버라이드 |
| **PM 도구** | 내부 JSON 상태 관리 (외부 연동 없음) | **Built-in Markdown + 외부 어댑터 (Notion/Linear/GitHub)** |
| **라이선스** | Apache 2.0 | TBD |
| **타겟** | Starter->Enterprise (범용) | **전 레벨** — 작업 규모 분류로 자동 간소화 |

### Functions가 없는 이유

bkit의 241 Functions = Scripts 내부의 재사용 가능한 유틸리티 함수 라이브러리를 별도 카운트한 것이다. Forge Dev은 현재 `session-state.mjs` 내부에 `findProjectRoot()`, `atomicWrite()`, `ensureDir()` 등이 존재하지만 별도 분리하지 않았다. **Phase C (플러그인 배포) 시 공통 유틸을 `lib/`로 분리**하여 Functions 계층을 만든다.

### Forge Dev의 차별점 (bkit 대비)

1. **SDD+DDD+TDD 융합**: Spec-First(SDD) + Domain Modeling(DDD) + Test-First(TDD)의 3축 통합. bkit은 PDCA 단일 방법론
2. **AI-Native 실행**: Claude Code의 Rules/Skills/Agents/Hooks/MCP를 실행 엔진으로 활용. 사람이 아닌 AI가 파이프라인을 구동
3. **3계층 자동 검증**: Code -> Traceability -> UI/Quality/Security 병렬 Subagent. bkit은 "Zero Script QA" (로그 모니터링 기반)
4. **파일 소유권 = Bounded Context**: Agent Teams에서 DDD의 Bounded Context를 파일 소유권으로 구현 (Lock-Free 충돌 방지). bkit에는 동등한 메커니즘 없음
5. **트레이서빌리티 매트릭스**: Spec <-> 코드 <-> 테스트 추적성 자동 검증. bkit에는 없음
6. **PM 2계층**: Built-in Markdown 진행 관리(외부 의존 없음) + 어댑터 패턴으로 외부 PM 도구 확장. bkit은 내부 JSON 상태만

### bkit에서 참고 -> 적용 판단

| # | 참고 항목 | 적용 | Phase | Forge Dev 반영 |
|---|----------|:----:|:-----:|---------|
| 1 | 배포 구조 (plugin.json) | **O** | C | 플러그인 매니페스트 필수 |
| 2 | 5-Layer Hook 시스템 | **부분** | A | SessionStart Hook 이미 있음. 나머지는 필요 시 확장 |
| 3 | 프로젝트 레벨 감지 | **O** | A | 작업 규모 분류 + 사용자 레벨 자동 간소화 연계 |
| 4 | 오버라이드 패턴 (3단계 우선순위) | **O** | A | 이미 3-Layer 구조로 설계됨 (플러그인->전역->프로젝트) |
| 5 | Output Styles (4단계 응답) | **triangle** | 미정 | 우선순위 낮음 |

### 사용자 레벨별 자동 간소화

| 레벨 | 작업 규모 | Phase 스킵 | Spec 작성 | AI 보조 |
|------|----------|-----------|----------|--------|
| **Starter** (초급) | Hotfix / Small | Phase 1.5/2 스킵 가능 | AI가 간단 Spec 자동 생성 | 높음 |
| **Standard** (중급) | Standard | 전체 Phase 수행 | AI가 초안 -> Human 승인 | 중간 |
| **Advanced** (상급) | Multi-Spec | 전체 Phase + Plan/Task 필수 | Human이 직접 작성 가능 | 낮음 |

---

## Forge Dev 런타임 의존성 (Toolchain)

### Tier 1: Forge Dev 필수

| 도구 | 타입 | Forge Dev 역할 |
|------|------|---------|
| Memory MCP | MCP 서버 | 세션 간 컨텍스트 영속 |
| Sequential Thinking MCP | MCP 서버 | Phase 1.5 복잡 요구사항 분석 |
| Context7 MCP | MCP 서버 | 라이브러리 문서 조회 (구현 시) |
| GitHub CLI (`gh`) | CLI 도구 | Phase 4 PR 생성 |
| spec-writer | Agent | Phase 2 Spec 작성 |
| code-reviewer | Agent | Check 3.7 코드 품질 검증 |

### Tier 2: Forge Dev 권장

| 도구 | 타입 | Forge Dev 역할 |
|------|------|---------|
| sharp MCP | MCP 서버 | Check 3.6 이미지 메타/최적화 검증 |
| lighthouse MCP | MCP 서버 | Check 3.6 성능/접근성/SEO 감사 |
| a11y MCP | MCP 서버 | Check 3.6 WCAG 접근성 스캔 |
| nanobanana MCP | MCP 서버 | 이미지 생성/편집 |
| Brave Search MCP | MCP 서버 | 리서치/기술 조사 |
| frontend-design | Skill | Phase 3 프론트엔드 UI/UX 디자인 |
| writing-plans | Skill | Phase 2 Plan 작성 보조 |

### Tier 3: 프로젝트별

DB MCP, 캐시 MCP, 테스트 도구, 언어 전문 Skill, 빌드 도구, 공식 Plugin 등

---

## 전체 구성요소 인벤토리 (3-Scope)

**처리 방침 범례**: 🔵 Forge Dev Core (전역화) | 🟢 Forge Dev Recommended (권장 배포) | 🟡 프로젝트 전용 (유지) | ⚪ 유틸리티 (범용)

### Rules

| 파일 | 전역 | Portfolio | GodBlade | 방침 |
|------|:----:|:---------:|:---------:|:----:|
| context-engineering.md | - | O | O | 🔵 |
| context-management.md | - | O | O | 🔵 |
| progress-automation.md | - | O | O | 🔵 |
| requirements-analysis.md | - | O | O | 🔵 |
| walkthrough-requirement.md | - | O | O | 🔵 |
| session-state.md | O | O | - | 🔵 (병합) |
| forge-workflow.md (신규) | - | - | - | 🔵 (신규) |
| opus-4-7-best-practices.md | O | - | - | ⚪ (전역 유지) |
| plan-mode.md | O | - | - | ⚪ (전역 유지) |
| specs.md | - | O | - | 🟢 |
| agent-teams.md | - | O | O | 🟡 (완전 다름) |
| verification-integration.md | - | O | O | 🟡 (완전 다름) |
| frontend.md | - | O | - | 🟡 |
| frontend-aesthetics.md | - | O | - | 🟡 |
| backend.md | - | O | - | 🟡 |
| monorepo.md | - | O | - | 🟡 |
| testing-strategy.md | - | O | - | 🟡 |
| test-code-requirements.md | - | O | - | 🟡 |
| e2e-workflow.md | - | O | - | 🟡 |
| git-workflow.md | - | O | - | 🟡 |
| git-worktree.md | - | O | - | 🟡 |
| mcp-configuration.md | - | O | - | 🟡 |
| context7-usage.md | - | O | - | 🟡 |
| ai-integration.md | - | O | - | 🟡 |
| finops.md | - | O | - | 🟡 |
| ssh-tunnels.md | - | O | - | 🟡 |
| extended-thinking.md | - | - | O | 🟡 |
| model-routing.md | - | - | O | 🟡 |

### Skills

| 스킬 | 전역 | Portfolio | GodBlade | 방침 |
|------|:----:|:---------:|:---------:|:----:|
| hook-creator | O | - | - | ⚪ |
| slash-command-creator | O | - | - | ⚪ |
| subagent-creator | O | - | - | ⚪ |
| writing-plans | - | O | O | 🟢 |
| concise-planning | - | O | O | 🟢 |
| kaizen | - | O | O | 🟢 |
| frontend-design | - | O | - | 🟢 |
| web-artifacts-builder | - | O | - | 🟢 |
| nestjs-expert ~ quote-generator | - | O | - | 🟡 |
| db-migration, protocol-spec | - | - | O | 🟡 |

### Agents

| 에이전트 | 전역 | Portfolio | GodBlade | 방침 |
|---------|:----:|:---------:|:---------:|:----:|
| spec-writer | - | O | - | 🔵 (베이스 전역화) |
| code-reviewer | O | O | O | 🔵 (베이스 전역화) |
| forge-pm-updater (신규) | - | - | - | 🔵 (신규) |

### Commands (슬래시 커맨드)

| 커맨드 | 전역 | Portfolio | GodBlade | 방침 |
|--------|:----:|:---------:|:---------:|:----:|
| /forge | - | - | - | 🔵 (신규) |
| /forge-sync | - | - | - | 🔵 (신규) |
| /forge-status | - | - | - | 🔵 (신규) |
| /forge-resume | O | - | - | 🔵 (구 /resume) |
| /forge-check-security | - | O | O | 🟢 |
| /forge-check-ui | - | O | O | 🟢 |
| /forge-generate-image | - | O | O | 🟢 |
| /feature ~ /test-all | - | O | - | 🟡 |

### Prompts, Hooks, Scripts, MCP 서버

(실행계획과 동일하므로 생략 — 인벤토리 테이블은 위 Rules/Skills/Agents/Commands 참조)

### 수량 집계

| 방침 | Rules | Skills | Agents | Prompts | Commands | Hooks | Scripts | MCP | 합계 |
|------|:-----:|:------:|:------:|:-------:|:--------:|:-----:|:-------:|:---:|:----:|
| 🔵 Forge Dev Core | 7 | 2 | 3 | 1 | 4 | - | 2 | 3 | **22** |
| 🟢 Forge Dev Recommended | 1 | 5 | - | 5 | 3 | 3 | - | 5 | **22** |
| 🟡 프로젝트 전용 | 18 | 17 | - | 3 | 9 | 6 | 3 | 4+ | **60+** |
| ⚪ 유틸리티 | 2 | 8 | - | - | - | - | - | 1 | **11** |

---

## PM 도구 — 2계층 구조 (Built-in + Adapter)

### Layer 1: Built-in Markdown (기본값)

| 파일 | 용도 | 갱신 시점 | 템플릿 |
|------|------|----------|--------|
| `docs/Planning/todo.md` | 체크리스트 기반 진행 상태 + Merged PR 이력 | Phase 완료, PR merge 시 | `todo-template.md` |
| `docs/Planning/development-plan.md` | 전체 세션 목록 + 각 세션 상세 단계 + 스케줄 | 세션 추가/완료 시 | `development-plan-template.md` |

자동화 메커니즘:
1. 온보딩 시 자동 생성 (forge-sync.mjs init)
2. 세션 시작 시 자동 등록 (session-state.mjs init)
3. Phase 전환 시 자동 갱신 (session-state.mjs checkpoint)
4. 세션 완료 시 자동 마감 (session-state.mjs complete)

### Layer 2: 외부 어댑터 (Phase B — 설계만)

Built-in 위에 외부 PM 도구를 **추가** 연동 (대체가 아님).

```
~/.claude/forge/adapters/
├── adapter-interface.mjs    어댑터 공통 인터페이스
├── notion-adapter.mjs       Notion 어댑터 (MCP 활용)
├── github-adapter.mjs       GitHub Projects 어댑터
└── mock-adapter.mjs         테스트/오프라인용
```

Forge Dev Phase -> 칸반 매핑:
- phase1/1.5 -> Backlog
- phase2 -> To Do
- phase3 -> In Progress
- phase4 -> In Review
- session_complete -> Done

설정: `<project>/.claude/forge-config.json`에서 adapter 지정 (기본값: `"none"` = Built-in만)

---

## 전문 스킬 전략

### Forge Dev Phase별 전문 스킬 매핑

| Forge Dev 단계 | 전문 영역 | 필요 스킬/도구 | 보유 | 조치 |
|----------|----------|-------------|:---:|------|
| Phase 2 | Spec 문서 작성 | spec-writer Agent | O | 베이스 전역화 |
| Phase 2 | 요구사항 명확화 | requirements-clarity Skill | O | Forge Dev 통합 |
| Phase 3 | Frontend UI/UX | frontend-design Skill | O | 전역 권장 |
| Phase 3 | Backend 구현 | 프로젝트별 Skill | 별도 | 프로젝트 오버라이드 |
| Check 3.5 | Spec 준수 검증 | spec-compliance-checker | **X** | **생성 필요** |
| Check 3.7 | 코드 리뷰 | code-reviewer Agent | O | 베이스 전역화 |
| 검수 | 통합 검수 | inspection-checklist | **X** | **생성 필요** |

### 스킬 획득 전략

1. 기존 보유 스킬 활용
2. 외부 마켓플레이스/커뮤니티 검색
3. 직접 생성 (skill-creator / subagent-creator)

---

## Forge Dev 통합 철학 — SDD + DDD + TDD

### 3대 방법론 융합 구조

```
+-------------------------------------------------------------+
|                    SDD (오케스트레이션 계층)                    |
|         Phase 1->1.5->2->3->4 파이프라인 + 검증 게이트         |
|                                                             |
|   +---------------------+   +-------------------------+     |
|   |   DDD (설계 계층)     |   |   TDD (검증 계층)         |     |
|   |                     |   |                         |     |
|   | - Ubiquitous Lang.  |   | - Red->Green->Refactor  |     |
|   | - Bounded Context   |   | - Test-First Spec       |     |
|   | - Strategic Design  |   | - 자동화된 검증 게이트    |     |
|   | - Domain Modeling   |   | - 회귀 방지              |     |
|   +---------------------+   +-------------------------+     |
|                                                             |
|   +---------------------------------------------------------+
|   |            Claude Code (AI 실행 엔진)                     |
|   |  Rules - Skills - Agents - Hooks - MCP - Commands        |
|   |  -> 사람이 아닌 AI가 파이프라인을 구동한다                   |
|   +---------------------------------------------------------+
+-------------------------------------------------------------+
```

### Forge Dev Phase별 DDD + TDD 역할

| Forge Dev Phase | DDD 역할 | TDD 역할 | Claude Code 역할 |
|-----------|---------|---------|-----------------|
| Phase 1 | 도메인 컨텍스트 파악 | - | Memory MCP |
| Phase 1.5 | Ubiquitous Language, Strategic Design | 테스트 가능한 요구사항 도출 | Sequential Thinking MCP |
| Phase 2 | Domain Model 정의 | Testing Requirements 선행 작성 | spec-writer Agent |
| Phase 3 | Tactical Design | Red->Green->Refactor | Agent Teams 병렬 구현 |
| Check 3 | - | verify.sh test (Green 확인) | 자동 실행 + autoFix |
| Check 3.5 | 문서-코드 정합성 | Spec <-> 테스트 커버리지 | spec-compliance-checker |
| Check 3.7 | 도메인 모델 준수 | 테스트 품질 리뷰 | code-reviewer Agent |
| Phase 4 | - | 모든 테스트 PASS 필수 | gh CLI PR 생성 |

### DDD <-> Forge Dev 매핑

| DDD 원칙 | Forge Dev 대응 요소 | 반영 |
|----------|-------------|:---:|
| Ubiquitous Language | constitution.md + Spec 용어 | O |
| Bounded Context | Agent Teams 파일 소유권 | O |
| Strategic Design | Phase 1.5 + Phase 2 Spec | O |
| Tactical Design | Phase 3 구현 | O |
| Document-Driven | Spec-First 파이프라인 | O |
| 문서-코드 정합성 | 트레이서빌리티 (Check 3.5) | O |
| Domain Events | - | X |
| Anti-Corruption Layer | - | X |

### TDD <-> Forge Dev 매핑

| TDD 원칙 | Forge Dev 대응 요소 | 반영 |
|----------|-------------|:---:|
| Test-First | Phase 2 Testing Requirements | O |
| Red->Green->Refactor | Phase 3 사이클 | O |
| 자동화된 테스트 실행 | verify.sh test + Check 3 | O |
| 회귀 방지 | Check 3 전체 테스트 스위트 | O |
| 테스트 커버리지 | Check 3.5 트레이서빌리티 | O |
| 테스트 생성 자동화 | /generate-tests + AI Agent | O |

---

## 로드맵 — 3단계 구축

### Phase A: 전역화 (현재)
- Forge Dev 중앙 저장소 생성 (Core 22 + Recommended 22)
- forge-sync.mjs 구현
- Portfolio/GodBlade 마이그레이션
- Built-in PM 자동화
- 신규 스킬: spec-compliance-checker, inspection-checklist
- Business 격리

### Phase B: PM 도구 연동 (향후)
- 어댑터 인터페이스 구현
- Notion 어댑터 (1차), GitHub Projects 어댑터 (2차)
- session-state.mjs에 어댑터 호출 통합

### Phase C: 플러그인 배포 (향후)
- plugin.json 매니페스트
- 마켓플레이스 패키징
- README, 문서, 라이선스
- GitHub 리포 구성

---

## 참고 자료

- [bkit-claude-code GitHub](https://github.com/popup-studio-ai/bkit-claude-code)
- [bkit Showcase (bkamp)](https://bkamp.ai/en/showcases/55c58fa9-0a35-4504-bfa9-1d8b5a630eea)
- [Spec Kit Review](https://vibecoding.app/blog/spec-kit-review)
- [bkit 개념 정리 (TILNOTE)](https://tilnote.io/en/pages/6971d065324e33cc1df11173)
- [Eric Evans on DDD + LLM](https://www.infoq.com/news/2024/03/Evans-ddd-experiment-llm/)
- [문서 중심 개발과 AI 코딩](https://www.jiniai.biz/2025/11/12/%EB%AC%B8%EC%84%9C-%EC%A4%91%EC%8B%AC-%EA%B0%9C%EB%B0%9Cddd%EA%B3%BC-tdd-ai-%EC%BD%94%EB%94%A9-%EC%97%90%EC%9D%B4%EC%A0%84%ED%8A%B8-%EC%8B%9C%EB%8C%80%EC%9D%98-%EC%83%88%EB%A1%9C%EC%9A%B4/)
- [DDD 핵심 원리](https://f-lab.kr/insight/understanding-ddd)
- ["AI 코딩 잘 하고 있다고? DDD 모르면 지금 망하고 있는 겁니다" (YouTube)](https://youtu.be/7GjRM2uv-6E)
