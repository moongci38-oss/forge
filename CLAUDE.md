# Business Workspace - AI Assistant Instructions

> 1인 기업 전체 업무를 위한 AI 워크스페이스. 개발 외 시장조사, 기획, 디자인, 마케팅, 콘텐츠 업무를 커버한다.

---

## 사용 환경

| 환경 | 사용자 | 주요 작업 |
|------|--------|----------|
| **Claude Code (CLI)** | 개발자 | Agent Teams, 스크립트 실행, Git 작업 |
| **Claude Desktop Cowork** | 비개발자 | 리서치, 문서 작성, 콘텐츠 기획 |

> Cowork 환경 상세(MCP 매핑, Hooks 대체, 보안)는 `business-core.md` 규칙에 포함.

---

## Workspace Context

**소유자**: 1인 기업 운영자 (풀스택 개발자 겸 사업가)
**비전**: 백엔드 개발자 1명이 AI Agent Teams로 6개 약점 영역을 80% 이상 보완

### 멀티 프로젝트 워크스페이스

| 프로젝트 | 경로 | 설명 |
|---------|------|------|
| **BUSINESS** | `Z:/home/damools/business/` | 비즈니스/기획 문서 (현재) |
| **Portfolio** | `Z:/home/damools/mywsl_workspace/portfolio-project/` | Next.js + NestJS 웹 개발 |
| **GODBLADE** | `E:/new_workspace/god_Sword/src/` | Unity 게임 프로젝트 (C#) |

---

## 3-트랙 폴더 구조

```
A. 제품 사업 (01~05, 10)  → 수익 활동 (시장조사, 기획, 마케팅, 콘텐츠, 디자인, 운영)
B. 회사 경영 (06~08)      → 민감 영역 (재무, 법무, 경영관리) — AI 직접 작업 금지
C. 시스템 (09-tools)      → AI 워크스페이스 운영 도구
```

---

## Golden Rules

### Do's
- 리서치 결과는 출처(URL, 날짜) 반드시 포함
- 문서 작성 시 한국어 기본, 전문 용어는 영어 병기
- 병렬 처리 가능한 작업은 Agent Teams 사용을 우선 검토

### Don'ts
- B 영역(`06-finance/`, `07-legal/`, `08-admin/`) 내용 외부 공유/출력 금지
- 검증 없는 시장 데이터를 사실로 단정 금지
- 스킬/컴포넌트 라이브러리 원본 직접 수정 금지

---

## Component System

| 타입 | 위치 | 관리 |
|------|------|------|
| Skills | `.claude/skills/` | `manage-skills.sh` |
| Agents | `.claude/agents/` | `manage-components.sh` |
| Commands | `.claude/commands/` | `manage-components.sh` |
| 라이브러리 원본 | `09-tools/` | 원본 보관 |

### 도구 관리 CLI

| 도구 | 명령 |
|------|------|
| 스킬 | `bash scripts/manage-skills.sh {list\|enable\|disable\|audit}` |
| 컴포넌트 | `bash scripts/manage-components.sh {list\|enable\|disable\|token-estimate}` |
| 규칙 | `bash scripts/manage-rules.sh {list\|validate\|build\|stats}` |

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

## Plugin System (Claude Code 2025.10+)

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

## Agent Teams (Opus 4.6+)

> 실험적 기능 활성화됨 (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
> 상세: `business-core.md` 내 agent-teams 섹션 참조

---

## 규칙 시스템 (Rules-as-Code)

| 위치 | 내용 |
|------|------|
| `.claude/rules/` | 컴파일된 규칙 (세션 시작 시 자동 로드) |
| `09-tools/rules-source/` | 규칙 원본 (Frontmatter 포함, 빌드 소스) |
| `~/.claude/rules/` | 전역 규칙 (3파일: docs-structure, opus-best-practices, plan-mode) |
| `~/.claude/trine/rules/` | Trine 개발 규칙 (11파일, 개발 프로젝트에 symlink 배포) |

---

## Output Preferences

- **문서**: Markdown 기본
- **언어**: 한국어 기본, 해외 대상 자료는 영어

---

*Last Updated: 2026-03-02 (Rules-as-Code 전환 + 토큰 최적화)*
