# Business Workspace - AI Assistant Instructions

> 1인 기업 전체 업무를 위한 AI 워크스페이스. 개발 외 시장조사, 기획, 디자인, 마케팅, 콘텐츠 업무를 커버한다.

---

## 사용 환경

이 워크스페이스는 두 가지 환경에서 사용된다:

| 환경 | 사용자 | 주요 작업 |
|------|--------|----------|
| **Claude Code (CLI)** | 개발자 | Agent Teams, 스크립트 실행, Git 작업 |
| **Claude Desktop Cowork** | 비개발자 | 리서치, 문서 작성, 콘텐츠 기획 |

### Cowork 사용자 행동 가이드
- 기술 용어(Agent Teams, 서브에이전트, MCP) 대신 일반 용어로 설명
- 병렬 작업 자동 판단 — 사용자에게 "Agent Teams 사용할까요?" 묻지 않음
- 파일 경로 제안 시 전체 경로 대신 폴더 이름으로 안내
- 에러 발생 시 기술 로그 대신 문제 요약 + 해결 방안 제시

### Cowork 환경: MCP 서버 → 내장 도구 매핑

Cowork에서는 `.mcp.json`의 MCP 서버가 직접 실행되지 않는다. 아래 매핑 테이블에 따라 대체 도구를 사용한다.

| Claude Code (MCP 서버) | Cowork (내장 도구) | 비고 |
|----------------------|-------------------|------|
| `mcp__filesystem__*` | Read, Write, Edit, Glob, Grep, Bash(ls) | 파일 읽기/쓰기/검색 |
| `mcp__playwright__*` | WebFetch, WebSearch, Claude in Chrome | 웹 자동화/스크린샷 |
| `mcp__sequential-thinking__*` | Task(Plan agent) + TodoWrite | 복잡한 전략 수립 시 계획 모드 활용 |
| Memory MCP (제거됨) | Auto Memory 파일 (`~/.claude/projects/*/memory/`) | 세션 간 컨텍스트는 auto memory로 관리 |
| `mcp__notion__*` | Notion 커넥터 플러그인 | 동일하게 사용 가능 |

### Cowork 환경: Hooks → 규칙 기반 대체

> Cowork에서는 bash hooks가 실행되지 않으므로 `.claude/rules/security.md`의 "Cowork 환경 보안" 섹션 규칙을 준수한다.

### Cowork 환경: Agent Teams → Task 도구 대체

| Claude Code (Agent Teams) | Cowork (Task 도구) |
|--------------------------|-------------------|
| Fan-out/Fan-in (tmux 병렬) | Task 도구 다중 호출 (동시 실행) |
| Pipeline (순차 의존) | Task 도구 순차 호출 |
| Competing Hypotheses | Task 도구 병렬 → 결과 비교 |
| Watchdog 모니터링 | 해당 없음 (Cowork에서 프로덕션 변경 금지) |

> Cowork에서 2개 이상 독립 작업 발견 시, Task 도구를 병렬로 호출하여 처리한다.

---

## 행동 원칙

이 워크스페이스는 **비개발자도 사용**하므로, 행동 원칙을 보수적으로 적용한다:

- 외부 서비스 연동, 파일 대량 수정, 데이터 삭제 등은 반드시 확인 후 수행
- 리서치 결과는 출처와 신뢰도를 반드시 표기
- 검증 없는 데이터를 사실로 단정하지 않음
- B 영역(finance/legal/admin) 접근 시 항상 경고

---

## Workspace Context

**소유자**: 1인 기업 운영자 (풀스택 개발자 겸 사업가)
**비전**: 백엔드 개발자 1명이 AI Agent Teams로 6개 약점 영역을 80% 이상 보완

### 멀티 프로젝트 워크스페이스

이 워크스페이스는 `Z:\home\damools\damools-workspace.code-workspace`에 정의된 멀티 프로젝트 환경의 일부이다. 개발 프로젝트 관련 업무(SDD 파이프라인, 스크립트 생성, 크로스 프로젝트 설정 등)도 이 워크스페이스에서 수행할 수 있다.

| 프로젝트 | 경로 | 설명 |
|---------|------|------|
| **BUSINESS** | `Z:/home/damools/business/` | 비즈니스/기획 문서 (현재) |
| **Portfolio** | `Z:/home/damools/mywsl_workspace/portfolio-project/` | Next.js + NestJS 웹 개발 |
| **GODBLADE** | `E:/new_workspace/god_Sword/src/` | Unity 게임 프로젝트 (C#) |

---

## 3-트랙 폴더 구조

```
business/
│
│ A. 제품 사업 영역 (Product Business)  → 수익을 만드는 모든 활동
├── 01-research/      시장조사 & 경쟁사 분석
├── 02-product/       제품 전략 & 기획 & 로드맵 (전략+기획 통합)
├── 03-marketing/     마케팅 & SEO & 그로스
├── 04-content/       콘텐츠 & 블로그 & SNS
├── 05-design/        디자인 & UI/UX
└── 10-operations/    서비스 운영 (지표, 릴리즈, 장애, 고객지원)
│
│ B. 회사 경영 영역 (Company Management)  — 민감, AI 직접 작업 금지
├── 06-finance/       재무 & 회계 & 세무신고 & 자금관리
├── 07-legal/         법무 & 계약 & 사업자 관련
└── 08-admin/         경영관리 & 인사 & 총무
│
│ C. 시스템 영역 (Tools & Systems)  → AI 워크스페이스 운영 도구
└── 09-tools/         AI 스킬 & 에이전트 & 자동화 스크립트
```

| 구분 | 성격 | 주기 | 예시 |
|------|------|------|------|
| **A. 제품 사업** | 창의적, AI 자동화 가능 | 매일/매주 | 시장조사, 마케팅, 콘텐츠 |
| **B. 회사 경영** | 준법, 문서 보관 중심 | 월간/분기/연간 | 세무신고, 계약서, 보험 |
| **C. 시스템** | 도구 관리 | 필요 시 | 스킬 활성화, 스크립트 |

---

## Golden Rules

### Do's
- 리서치 결과는 출처(URL, 날짜) 반드시 포함
- 문서 작성 시 한국어 기본, 전문 용어는 영어 병기
- 파일명 규칙: `.claude/rules/file-naming.md` 참조
- 민감 자료(재무, 법무)는 `06-finance/`, `07-legal/`, `08-admin/` 하위에만 저장
- 스킬 관리: `bash scripts/manage-skills.sh {list|enable|disable}`
- 컴포넌트 관리: `bash scripts/manage-components.sh {list|enable|disable}`
- 병렬 처리 가능한 작업은 Agent Teams 사용을 우선 검토 → 실행 계획 수립 시 먼저 고려

### Don'ts
- B 영역(`06-finance/`, `07-legal/`, `08-admin/`) 내용 외부 공유/출력 금지
- 검증 없는 시장 데이터를 사실로 단정 금지
- 스킬/컴포넌트 라이브러리 원본(`09-tools/skills-library/`, `09-tools/components-library/`) 직접 수정 금지

---

## Component System

| 타입 | 위치 | 관리 |
|------|------|------|
| Skills | `.claude/skills/` | `manage-skills.sh` |
| Agents | `.claude/agents/` | `manage-components.sh` |
| Commands | `.claude/commands/` | `manage-components.sh` |
| 라이브러리 원본 | `09-tools/` | 원본 보관 |

---

## Agent Teams (Opus 4.6+)

> 실험적 기능 활성화됨 (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
> 상세: `.claude/rules/agent-teams.md` 참조

---

## Plugin System (Claude Code 2025.10 출시)

### 핵심 CLI 명령어
```bash
claude plugin marketplace add anthropics/knowledge-work-plugins
claude plugin install {plugin-name}@{marketplace} --scope project
claude plugin list
claude plugin enable {plugin-name}
claude plugin disable {plugin-name}
```

### Cowork 공식 플러그인

| 플러그인 | 연결 폴더 | 설치 우선순위 |
|---------|----------|:-----------:|
| **productivity** | 06-project-management | Phase 1 |
| **product-management** | 02-product | Phase 1 |
| **marketing** | 03-marketing | Phase 1 |
| **enterprise-search** | 전체 크로스 검색 | Phase 1 |
| **data** | 01-research, 02-product | Phase 2 |
| **finance** | 06-finance | Phase 2 (--scope local) |
| **legal** | 07-legal | Phase 2 (--scope local) |

---

## MCP Servers & Plugins

### MCP Servers (4개, .mcp.json 정의)

| 서버 | 설명 |
|------|------|
| **Filesystem** | 파일 접근 (Business + Portfolio 프로젝트) |
| **Sequential Thinking** | 복잡한 전략 계획 수립 |
| **Notion** | Notion 페이지/DB 연동 |
| **NanoBanana** | Google Gemini AI 이미지 생성/편집 (Tier 3) |

### Plugins (2개, 플러그인 시스템)

| 플러그인 | 설명 |
|---------|------|
| **Context7** | 최신 라이브러리 문서 → 코드 생성 시 항상 사용 |
| **Playwright** | 브라우저 자동화, UI 스크린샷 |

> 웹 검색은 내장 `WebSearch` 도구 사용.

---

## Output Preferences

- **문서**: Markdown 기본
- **언어**: 한국어 기본, 해외 대상 자료는 영어

---

## 모듈화된 규칙

@.claude/rules/git.md
@.claude/rules/file-naming.md
@.claude/rules/security.md
@.claude/rules/agent-teams.md
@.claude/rules/research-methodology.md
@.claude/rules/cross-project-pipeline.md
@.claude/rules/sigil-pipeline.md
@.claude/rules/trine-handoff.md
@.claude/rules/sigil-council-mode.md

---

*Last Updated: 2026-03-02 (Trine 전환 체계 추가 + 감사 리포트 전체 반영)*
