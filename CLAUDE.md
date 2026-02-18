# Business Workspace - AI Assistant Instructions

> 1인 기업 전체 업무를 위한 AI 워크스페이스. 개발 외 시장조사, 기획, 디자인, 마케팅, 콘텐츠 업무를 커버한다.

---

## Workspace Context

**소유자**: 1인 기업 운영자 (풀스택 개발자 겸 사업가)
**비전**: 백엔드 개발자 1명이 AI Agent Teams로 6개 약점 영역을 80% 이상 보완
**개발 프로젝트**: `~/mywsl_workspace/portfolio-project/` (별도 워크스페이스)

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

### Don'ts
- 이 워크스페이스에서 코드 프로젝트 개발 금지 (개발은 portfolio-project에서)
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

---

*Last Updated: 2026-02-18*
