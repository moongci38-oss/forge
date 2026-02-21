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
| `mcp__memory__*` | 대화 컨텍스트 유지 (세션 내) | Cowork는 세션 간 메모리 없음 — 중요 결론은 파일로 저장 |
| `mcp__notion__*` | Notion 커넥터 플러그인 | 동일하게 사용 가능 |

### Cowork 환경: Hooks → 규칙 기반 대체

Cowork에서는 bash hooks가 실행되지 않으므로, 아래 규칙을 **반드시** 준수한다.

**[block-sensitive-files 대체]** 민감 영역 파일 보호:
- `06-finance/`, `07-legal/`, `08-admin/insurance/`, `08-admin/freelancers/` 내 파일은 읽기/쓰기/편집 **절대 금지**
- 해당 경로 접근 요청 시 거부하고, 직접 편집기 사용을 안내

**[require-date-prefix 대체]** 파일명 규칙 강제:
- `docs/` 하위 새 `.md` 파일 생성 시 반드시 `YYYY-MM-DD-{name}.md` 형식 사용
- 예외: CLAUDE.md, README.md, index.md, subscriptions.md, domains.md, terms-of-service.md, privacy-policy.md

**[no-force-push 대체]** Git 안전 규칙:
- `git push --force` 또는 `-f` 명령은 main/master 브랜치 대상으로 절대 실행 금지
- feature/, fix/ 등 작업 브랜치만 허용

**[session-context 대체]** 세션 시작 체크리스트:
- 세션 시작 시 Track A(제품사업) 우선, Track B 접근 금지 원칙 상기
- 새 파일 생성 시 날짜 prefix 규칙 적용
- Cowork에서는 Memory MCP 불가 → 이전 작업 내용은 관련 폴더의 기존 파일을 참조

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
│ ◆ A. 제품 사업 영역 (Product Business)  → 수익을 만드는 모든 활동
├── 01-research/      시장조사 & 경쟁사 분석
├── 02-product/       제품 전략 & 기획 & 로드맵 (전략+기획 통합)
├── 03-marketing/     마케팅 & SEO & 그로스
├── 04-content/       콘텐츠 & 블로그 & SNS
├── 05-design/        디자인 & UI/UX
└── 10-operations/    서비스 운영 (지표, 릴리즈, 장애, 고객지원)
│
│ ◆ B. 회사 경영 영역 (Company Management)  ⛔ 민감 — AI 직접 작업 금지
├── 06-finance/       재무 & 회계 & 세무신고 & 자금관리
├── 07-legal/         법무 & 계약 & 사업자 관련
└── 08-admin/         경영관리 & 인사 & 총무
│
│ ◆ C. 시스템 영역 (Tools & Systems)  → AI 워크스페이스 운영 도구
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
- 파일명: kebab-case + 날짜 prefix (`2026-02-13-market-analysis.md`)
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

**39개 스킬 + 9개 에이전트 + 6개 MCP 서버** 활성화됨

| 타입 | 위치 | 관리 |
|------|------|------|
| Skills | `.claude/skills/` | `manage-skills.sh` |
| Agents | `.claude/agents/` | `manage-components.sh` |
| Commands | `.claude/commands/` | `manage-components.sh` |
| 라이브러리 원본 | `09-tools/` | 원본 보관 |

---

## Agent Teams (Opus 4.6+)

> 실험적 기능 활성화됨 (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
> 상세 가이드: `docs/tech/Opus_4_6_신기능_심층_가이드_추가_섹션.md`

### 병렬 처리 원칙

> 병렬 처리가 가능한 작업은 Agent Teams 사용을 우선 검토한다.
> 실행 계획 수립 시 가장 먼저 병렬화 가능 여부를 판단한다.

| 상황 | 선택 |
|------|------|
| 독립적으로 나눌 수 있는 작업 2개 이상 | **Agent Teams** (우선 검토) |
| 단일 순차 작업 | Task 도구 또는 직접 실행 |
| 프로덕션 크리티컬 (롤백 필요) | Task 도구 + Watchdog 패턴 |

### 오케스트레이션 패턴 (4가지)
- **Fan-out/Fan-in**: 독립 병렬 작업 (모듈 분석, 리서치)
- **Pipeline**: 순차 의존성 (스키마→API→프론트)
- **Competing Hypotheses**: 최적 해법 탐색 (성능 최적화 전략 비교)
- **Watchdog**: 프로덕션 변경 안전 모니터링

### 모델 계층화 (비용 60-70% 절감)
```
Lead            → Opus 4.6   (아키텍처 판단, 종합)
구현 Teammate   → Sonnet 4.6 (코딩 작업)
탐색 Teammate   → Haiku 4.5  (검색, 파일 분석)
```

### 필수: 실행 환경
- **tmux 필수** (VS Code 통합 터미널 미지원)
- Windows Terminal + WSL(`tmux new-session -s agent-team`) 사용

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
| **productivity** | 06-project-management | ⭐ |
| **product-management** | 02-product | ⭐ |
| **marketing** | 03-marketing | ⭐ |
| **enterprise-search** | 전체 크로스 검색 | ⭐ |
| **data** | 01-research, 02-product | Phase 2 |
| **finance** | 06-finance | Phase 2 (--scope local) |
| **legal** | 07-legal | Phase 2 (--scope local) |

---

## MCP Servers (6개)

- **Memory**: 세션 간 컨텍스트 영속 저장 → 세션 시작 시 `search_nodes` 호출
- **Brave Search**: 실시간 웹 검색, 시장조사 → 리서치/경쟁사 분석 시 우선 사용
- **Context7**: 최신 라이브러리 문서 → 코드 생성 시 항상 사용
- **Filesystem**: 파일 접근 (Business + E:\portfolio_project)
- **Playwright**: 브라우저 자동화, UI 스크린샷
- **Sequential Thinking**: 복잡한 전략 계획 수립

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

---

*Last Updated: 2026-02-21 (멀티 프로젝트 워크스페이스 참조 추가 + 크로스 프로젝트 개발 허용)*
