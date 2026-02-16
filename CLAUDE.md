# Business Workspace - AI Assistant Instructions

> 1인 기업 전체 업무를 위한 AI 워크스페이스. 개발 외 시장조사, 기획, 디자인, 마케팅, 콘텐츠 업무를 커버한다.

---

## Workspace Context

이 워크스페이스는 **비개발 업무** 중심이다. 코드 작성보다 **리서치, 기획, 글쓰기, 분석**이 주요 작업.

**소유자**: 1인 기업 운영자 (풀스택 개발자 겸 사업가)
**개발 프로젝트**: `~/mywsl_workspace/portfolio-project/` (별도 워크스페이스)

---

## Folder Structure

| 폴더 | 용도 | 주요 작업 |
|------|------|----------|
| `01-research/` | 시장조사 & 분석 | 경쟁사 분석, 트렌드 리서치, 데이터 수집 |
| `02-strategy/` | 사업기획 & 전략 | 사업계획서, 가격 모델, 린 캔버스 |
| `03-design/` | 디자인 에셋 | UI 목업, 브랜드 에셋, 생성 이미지 |
| `04-marketing/` | 마케팅 & 그로스 | 캠페인, 이메일, SNS, SEO |
| `05-content/` | 콘텐츠 제작 | 블로그, 문서, 뉴스레터 |
| `06-dev-tools/` | 개발 도구 & 스킬 | 스킬 라이브러리, 자동화, 프롬프트 |
| `07-operations/` | 운영/관리 | 재무, 법무, 프로세스 |

---

## Golden Rules

### Do's
- 리서치 결과는 출처(URL, 날짜)를 반드시 포함
- 문서 작성 시 한국어 기본, 전문 용어는 영어 병기
- 파일명은 kebab-case + 날짜 prefix 권장 (`2026-02-13-market-analysis.md`)
- 민감 자료(재무, 법무)는 `07-operations/` 하위에만 저장
- 스킬 관리는 `scripts/manage-skills.sh`, 기타 컴포넌트는 `scripts/manage-components.sh` 사용

### Don'ts
- 이 워크스페이스에서 코드 프로젝트 개발 금지 (개발은 portfolio-project에서)
- `07-operations/finances/`, `07-operations/legal/` 내용을 외부 공유/출력 금지
- 검증 없는 시장 데이터를 사실로 단정 금지
- 스킬 라이브러리 원본 직접 수정 금지 (심링크로 활성화만)
- 컴포넌트 라이브러리 원본 직접 수정 금지 (enable/disable로 관리)

---

## Component System

6가지 컴포넌트 타입으로 AI 기능을 확장한다.

| 타입 | 위치 (활성) | 관리 방법 |
|------|------------|----------|
| **Skills** | `.claude/skills/` | `manage-skills.sh` (심링크) |
| **Agents** | `.claude/agents/` | `manage-components.sh` (복사) |
| **Commands** | `.claude/commands/` | `manage-components.sh` (복사) |
| **Hooks** | `.claude/hooks/` | `manage-components.sh` (복사 + settings.json) |
| **MCPs** | `.mcp.json` | 수동 병합 |
| **Settings** | `.claude/settings.json` | 수동 병합 |

### 컴포넌트 관리
```bash
# 전체 컴포넌트 목록 (스킬 포함)
bash scripts/manage-components.sh list

# 특정 타입만 보기
bash scripts/manage-components.sh list agents

# 컴포넌트 활성화 (library → .claude/ 복사)
bash scripts/manage-components.sh enable agents seo-analyzer

# 컴포넌트 비활성화
bash scripts/manage-components.sh disable agents seo-analyzer

# aitmpl에서 다운로드 + 라이브러리 저장
bash scripts/manage-components.sh install agents web-tools/seo-analyzer

# 다른 프로젝트에 동기화
bash scripts/manage-components.sh sync ~/mywsl_workspace/portfolio-project
```

### 스킬 관리 (기존)
```bash
bash scripts/manage-skills.sh list
bash scripts/manage-skills.sh enable aitmpl/business-marketing/product-strategist
bash scripts/manage-skills.sh disable product-strategist
bash scripts/manage-skills.sh sync ~/mywsl_workspace/portfolio-project
```

### 라이브러리 구조
```
06-dev-tools/
├── skills-library/          ← 스킬 전용 (기존)
│   ├── aitmpl/
│   ├── marketingskills/
│   └── community/
└── components-library/      ← 스킬 외 컴포넌트
    ├── agents/              ← 에이전트 원본
    ├── commands/            ← 슬래시 커맨드 원본
    ├── hooks/               ← 훅 원본
    ├── mcps/                ← MCP 설정 원본
    └── settings/            ← 세팅 프리셋 원본
```

---

## Task Patterns by Business Area

### 시장조사 (01-research)
```
"경쟁사 X 분석해줘" → 01-research/competitors/에 결과 저장
"Y 시장 트렌드 조사" → 01-research/trends/에 결과 저장
```

### 사업기획 (02-strategy)
```
"린 캔버스 작성해줘" → 02-strategy/lean-canvas/에 저장
"가격 모델 비교" → 02-strategy/pricing-models/에 저장
```

### 마케팅 (04-marketing)
```
"이메일 시퀀스 작성" → 04-marketing/email-sequences/에 저장
"SEO 키워드 분석" → 04-marketing/seo/에 저장
```

### 콘텐츠 (05-content)
```
"블로그 포스트 초안" → 05-content/blog-posts/에 저장
"뉴스레터 작성" → 05-content/newsletters/에 저장
```

---

## File Naming Convention

```
{YYYY-MM-DD}-{description}.{ext}

예시:
2026-02-13-competitor-analysis-saas.md
2026-02-13-pricing-model-v2.xlsx
2026-Q1-marketing-report.md
```

---

## MCP Servers

이 워크스페이스는 6개의 MCP 서버로 AI 기능을 확장한다.

### 설치된 MCP 서버

**Project 스코프** (`.mcp.json`):
- **Filesystem**: Business 워크스페이스 + E:\portfolio_project 접근
- **Playwright**: 브라우저 자동화, UI 스크린샷, 웹앱 테스트
- **Sequential Thinking**: 복잡한 전략 계획을 위한 사고 프레임워크
- **Memory**: 세션 간 컨텍스트 영속 저장 (지식 그래프)

**User 스코프** (`~/.claude.json`):
- **Context7**: 최신 라이브러리 문서 (React 19, Next.js 15 등)
- **Brave Search**: 실시간 웹 검색, 시장조사, 경쟁사 분석

### MCP 서버 사용 가이드

#### 기본 원칙
- 최신 라이브러리 코드 생성 시 **항상 Context7 사용**
- 시장조사/경쟁사 분석 시 **Brave Search 우선**
- 포트폴리오 프로젝트 이미지 작업 시 **Playwright 사용**
- 복잡한 전략 계획은 **Sequential Thinking** 프레임워크 적용
- 세션 시작 시 **Memory에서 관련 컨텍스트 검색** (`search_nodes`)

#### 사용 예시

**시장조사** (Brave Search):
```
"2026년 SaaS 시장 트렌드를 조사해줘"
→ Brave Search로 최신 웹 검색 결과 수집
→ 01-research/trends/에 결과 저장
```

**최신 기술 문서** (Context7):
```
"Next.js 15의 Server Actions 사용법을 알려줘"
→ Context7로 최신 Next.js 15 문서 참조
→ 정확한 API 사용법 제공
```

**포트폴리오 작업** (Filesystem + Playwright):
```
"E:\portfolio_project의 프로젝트 UI 스크린샷을 캡처해줘"
→ Filesystem으로 프로젝트 목록 확인
→ Playwright로 각 프로젝트 스크린샷 자동 캡처
```

**전략 계획** (Sequential Thinking):
```
"신제품 출시 전략을 단계별로 계획해줘"
→ Sequential Thinking 프레임워크 적용
→ 논리적 단계별 계획 수립
→ 02-strategy/launch-plans/에 저장
```

**지식 보존** (Memory):
```
# 세션 시작 시 관련 컨텍스트 검색
"이전에 조사한 경쟁사 정보를 요약해줘"
→ Memory에서 search_nodes로 검색
→ 기존 인사이트 활용

# 중요 정보 저장
"이 시장 데이터를 기억해줘"
→ Memory에 entities/relations/observations 저장
```

#### 보안 주의사항

**Filesystem 접근 제한**:
- `.env`, `.git/` 디렉토리 접근 금지
- `07-operations/finances/`, `07-operations/legal/` 민감 정보 보호

**API 키 관리**:
- Brave API: 무료 2,000쿼리/월 (rate limit 모니터링)
- Context7 API: 무료 (rate limit 완화 키 적용)

#### 토큰 효율성 최적화

- **MCP Tool Search 활성화**: 환경변수 `ENABLE_TOOL_SEARCH=auto` 설정
- **서브에이전트 도구 화이트리스팅**: 필요한 도구만 할당
- **예상 토큰 절감**: 세션당 ~30-40K 토큰 (15-20%)

---

## Output Preferences

- **문서**: Markdown 기본. 필요 시 DOCX/PDF 변환
- **스프레드시트**: CSV 또는 XLSX
- **프레젠테이션**: PPTX (pitch-decks)
- **언어**: 한국어 기본, 해외 대상 자료는 영어

---

*Last Updated: 2026-02-16*
