# 1인 기업 AI Agent Teams 구축 실행 계획 - 최종본

**작성일**: 2026-02-16
**버전**: v3.0 (폴더 구조 재설계 + Notion 통합)
**상태**: ✅ 계획 확정 - 구현 대기
**목표**: 백엔드 개발자 1명이 AI Agent Teams로 6개 약점 영역을 **60-70% 보완**

---

## 📋 주요 변경사항 (v3.0)

### 🔄 폴더 구조 재설계 (7개 → 7개, 역할 명확화)

| 변경 전 | 변경 후 | 변경 이유 |
|---------|---------|----------|
| 02-strategy | **02-business-strategy** | 사업 전략 명확화 |
| 03-design | **05-design** | 순서 조정 |
| 05-content | **03-product-planning** | 제품 기획 명확화 |
| 06-dev-tools | **07-operations/dev-tools** | 통합 (operations 내 하위) |
| (없음) | **06-project-management** | 신규 생성 (Notion 통합) |

### 🆕 Notion MCP 통합 (06-project-management)
- Notion 데이터베이스와 양방향 동기화
- 프로젝트 상태, 백로그, 스프린트 자동 관리

### 🔗 워크스페이스 자동 연동
- **Z:\home\damools\mywsl_workspace** (리눅스 프로젝트)
- **E:\new_workspace** (윈도우 프로젝트)
- Filesystem MCP로 프로젝트 자동 탐지 및 Notion 동기화

---

## 🗂️ 새로운 폴더 구조 (7개)

```
Z:\home\damools\business\
├── 01-research/           📊 시장조사 & 경쟁사 분석
├── 02-business-strategy/  💼 사업 전략 (린 캔버스, 가격 모델, GTM)
├── 03-product-planning/   📋 제품 기획 (게임/웹/앱, PRD, GDD)
├── 04-marketing/          📢 마케팅 전략 & 콘텐츠 (SEO, 블로그, 광고)
├── 05-design/             🎨 디자인 & UX (UI, 브랜드, 에셋)
├── 06-project-management/ 📅 프로젝트 관리 (Notion + 워크스페이스 통합)
└── 07-operations/         ⚙️ 운영 & 관리 (재무, 법무, dev-tools)
```

### 폴더별 상세 업무

**01-research/** (변경 없음)
```
시장조사, 경쟁사 분석, 트렌드 리서치
→ Brave Search, 논문, 오픈소스 분석
→ 4가지 자료 타입 (기사, 공식문서, 오픈소스, 기타)
```

**02-business-strategy/** (기존 02-strategy)
```
사업계획서, 린 캔버스, 가격 모델
→ TAM/SAM/SOM, GTM 전략
→ product-strategist, micro-saas-launcher 스킬 활용
```

**03-product-planning/** (기존 05-content, 역할 재정의)
```
🎮 게임 기획 (GDD, 게임 메커니즘, 레벨 디자인)
🌐 웹/앱 서비스 기획 (PRD, 기능 명세, 요구사항)
📝 콘텐츠 기획 (교육 커리큘럼, 미디어 전략)
📊 프로젝트 기획서 (개요, 범위, 일정)

→ product-manager-toolkit, agile-product-owner 스킬
→ technical-writer, requirements-clarity 스킬
```

**04-marketing/** (확장: 전략 + 콘텐츠)
```
마케팅 전략 (SEO, 광고 전략, 캠페인)
콘텐츠 제작 (블로그, 뉴스레터, SNS)
→ 15개 마케팅 스킬 활용
→ seo-analyzer, search-ai-optimization-expert 에이전트
```

**05-design/** (기존 03-design)
```
UI/UX 디자인, 브랜드 에셋, 디자인 시스템
→ v0.dev, Figma AI, Midjourney 연동
→ ux-researcher, screenshot-capturer 에이전트
```

**06-project-management/** (신규 ⭐)
```
프로젝트 관리 (일정, 백로그, 스프린트, 리스크)
→ Notion MCP 통합 (양방향 동기화)
→ 워크스페이스 자동 연동:
   - Z:\home\damools\mywsl_workspace (리눅스)
   - E:\new_workspace (윈도우)
→ agile-product-owner, concise-planning 스킬
```

**07-operations/** (확장: dev-tools 통합)
```
운영 & 관리 (재무, 법무, 프로세스)
dev-tools (스킬/컴포넌트 관리)
→ orchestrator 에이전트
→ 3-Layer 상태 관리 (Memory + Task + File)
```

---

## 🔗 06-project-management/ 상세 설계 (핵심 신규 기능)

### 시스템 아키텍처

```
06-project-management/
├── CLAUDE.md                     ← Notion + 워크스페이스 통합 시스템
├── workspace-sync/               ← 워크스페이스 자동 동기화
│   ├── linux-projects.json       ← mywsl_workspace 프로젝트 목록
│   ├── windows-projects.json     ← new_workspace 프로젝트 목록
│   └── sync-status.md            ← 동기화 상태 로그
├── notion-databases/             ← Notion 데이터베이스 메타데이터
│   ├── projects-db.json          ← 프로젝트 DB 스키마
│   ├── backlog-db.json           ← 백로그 DB 스키마
│   └── sprints-db.json           ← 스프린트 DB 스키마
├── project-tracking/             ← 프로젝트 추적
│   ├── active-projects.md        ← 진행 중 프로젝트
│   ├── backlog-projects.md       ← 백로그 프로젝트
│   └── completed-projects.md     ← 완료 프로젝트
├── timelines/                    ← 프로젝트 타임라인
├── backlogs/                     ← 제품 백로그
├── sprints/                      ← 스프린트 계획
├── risk-management/              ← 리스크 관리
└── templates/                    ← Notion 템플릿
    ├── project-template.json
    ├── sprint-template.json
    └── backlog-template.json
```

### Notion MCP 설정

**.mcp.json 추가**:
```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-notion"],
      "env": {
        "NOTION_API_KEY": "${NOTION_API_KEY}"
      }
    }
  }
}
```

**환경변수 설정**:
```bash
# .env 파일
NOTION_API_KEY=secret_xxxxxxxxxxxxx
```

### 자동화 워크플로우

#### 1. 프로젝트 자동 탐지 (주간)

**weekly-sync.sh**:
```bash
#!/bin/bash
# 매주 월요일 08:00 실행

echo "🔍 Scanning workspaces..."

# 리눅스 워크스페이스 스캔
claude "Filesystem MCP로 Z:\home\damools\mywsl_workspace 스캔
→ .git, package.json, README.md 있는 디렉토리 탐지
→ workspace-sync/linux-projects.json 업데이트"

# 윈도우 워크스페이스 스캔
claude "Filesystem MCP로 E:\new_workspace 스캔
→ .git, package.json, README.md 있는 디렉토리 탐지
→ workspace-sync/windows-projects.json 업데이트"

echo "✅ Workspace scan completed"
```

**프로젝트 메타데이터 추출**:
```json
{
  "name": "my-saas-project",
  "path": "Z:/home/damools/mywsl_workspace/my-saas-project",
  "type": "web",
  "tech_stack": ["Next.js", "NestJS", "PostgreSQL"],
  "status": "active",
  "last_commit": "2026-02-16T10:30:00Z",
  "git_branch": "main"
}
```

#### 2. Notion 동기화 (자동)

**notion-sync.sh**:
```bash
#!/bin/bash
# 프로젝트 탐지 직후 실행

echo "🔄 Syncing to Notion..."

# 탐지된 프로젝트 → Notion 데이터베이스 생성/업데이트
claude "Notion MCP로 Projects 데이터베이스 업데이트
→ workspace-sync/*.json 읽기
→ 신규 프로젝트: Notion에 자동 생성
→ 기존 프로젝트: 상태/메타데이터 업데이트"

echo "✅ Notion sync completed"
```

**Notion 데이터베이스 스키마**:
```
Projects 데이터베이스
├── Name (title)           프로젝트 이름
├── Status (select)        active | backlog | completed
├── Type (select)          game | web | app | content
├── Tech Stack (multi)     기술 스택 태그
├── Workspace (select)     linux | windows
├── Path (text)            프로젝트 경로
├── Last Updated (date)    마지막 업데이트
└── Sprint (relation)      연결된 스프린트
```

#### 3. 양방향 연동

**Notion → 워크스페이스**:
```
사용자: Notion에서 신규 프로젝트 생성

→ Claude Code가 Notion MCP로 변경 감지
→ 워크스페이스에 디렉토리 자동 생성
  - 윈도우 프로젝트 → E:\new_workspace\{project-name}
  - 리눅스 프로젝트 → Z:\home\damools\mywsl_workspace\{project-name}
→ 기본 템플릿 파일 생성 (README.md, .gitignore 등)
```

**워크스페이스 → Notion**:
```
사용자: 워크스페이스에서 새 프로젝트 init

→ weekly-sync.sh가 신규 프로젝트 탐지
→ Notion에 자동으로 프로젝트 항목 생성
→ 상태: backlog (기본값)
```

### 활용 스킬 & 에이전트

**스킬**:
- agile-product-owner ✅ (백로그, 스프린트)
- concise-planning ✅ (프로젝트 계획)
- writing-plans ✅ (계획서 작성)
- product-manager-toolkit ✅ (PRD, RICE 우선순위)

**에이전트**:
- orchestrator ✅ (워크플로우 조정)
- technical-writer ✅ (프로젝트 문서화)

**MCP 서버**:
- Notion MCP ⭐ (프로젝트 DB 관리)
- Filesystem MCP ✅ (워크스페이스 스캔)
- Memory MCP ✅ (프로젝트 히스토리 저장)

---

## 📊 현재 시스템 상태

### ✅ 이미 구축된 인프라

**스킬**: 39개 설치됨
- 비즈니스/마케팅: 20개
- 생산성: 7개
- 리서치: 2개
- 기타: 10개

**에이전트**: 9개 활성화됨
- orchestrator, research-coordinator, market-researcher
- technical-writer, ux-researcher, academic-researcher
- fact-checker, seo-analyzer, search-ai-optimization-expert

**MCP 서버**: 6개 → 7개 (Notion 추가)
- Memory, Filesystem, Brave Search
- Context7, Playwright, Sequential Thinking
- **Notion** ⭐ (신규 추가)

---

## 🎯 현실적인 목표 및 성과 지표

| 지표 | Phase 1 목표 | Phase 2 목표 | 측정 방법 |
|------|:-------------:|:-------------:|----------|
| **토큰 사용량** | 30-40% 절감 | 50-60% 절감 | 세션별 토큰 로그 분석 |
| **시장조사 시간** | 4h → 2h (50%) | 4h → 1h (75%) | 타이머 기록 + 작업 로그 |
| **제품 기획** | 8h → 5h (38%) | 8h → 3h (63%) | Before/After 실측 |
| **프로젝트 관리** | 수동 | **자동 동기화** | Notion + 워크스페이스 연동 |
| **작업 복구율** | 50% (수동) | 90% (자동) | 중단 테스트 5회 |

---

## 🔄 구현 계획 (6-8주, 4 Phases)

### Phase 1: 토큰 최소화 & 기반 구축 (Week 1-2)

**목표**: 토큰 30-40% 절감 + 핵심 2개 폴더

#### Week 1: 토큰 최소화

**1.1 MCP Tool Search 활성화 + 실측**
```bash
# 환경변수 설정
export ENABLE_TOOL_SEARCH=auto

# Before/After 측정 (5개 세션)
# 목표: 30-40% 절감 (96%는 과장된 수치)
```

**1.2 Root CLAUDE.md 간소화**
```
현재: 243줄 → 목표: 100줄 이하
- 기본 개념, 폴더 구조, Golden Rules만
- 새로운 7개 폴더 구조 반영
```

**1.3 .claude/rules/ 모듈화 (3개)**
```
.claude/rules/
├── git.md              ← Git 규칙
├── file-naming.md      ← 파일명 규칙
└── security.md         ← 보안 체크리스트
```

#### Week 2: 핵심 2개 폴더 CLAUDE.md

**우선순위 1: 01-research/CLAUDE.md**
- 4가지 자료 타입 (기사, 공식문서, 오픈소스, 기타)
- market-researcher, docs-tracker, opensource-intel

**우선순위 2: 03-product-planning/CLAUDE.md** ⭐
- 게임/웹/앱 기획 워크플로우
- product-manager-toolkit, agile-product-owner 스킬

---

### Phase 2: Notion 통합 & 자동화 (Week 3-4)

**목표**: 프로젝트 관리 자동화 + Hook 2개

#### Week 3: Notion MCP 통합

**2.1 Notion MCP 설정**
```bash
# .mcp.json에 Notion 추가
# NOTION_API_KEY 환경변수 설정
```

**2.2 06-project-management/CLAUDE.md 작성**
- Notion 데이터베이스 스키마
- 워크스페이스 자동 동기화 시스템
- 양방향 연동 워크플로우

**2.3 워크스페이스 스캔 스크립트**
```bash
# weekly-sync.sh
# - Z:\home\damools\mywsl_workspace 스캔
# - E:\new_workspace 스캔
# - workspace-sync/*.json 생성
```

**2.4 Notion 동기화 스크립트**
```bash
# notion-sync.sh
# - 탐지된 프로젝트 → Notion DB 생성/업데이트
```

#### Week 4: Hook 시스템 & 검증

**2.5 Hook 2개**
- user-prompt-submit (컨텍스트 자동 주입)
- task-update (체크포인트 자동 저장)

**2.6 성과 측정 (1주일)**
- 토큰 사용량 분석
- 프로젝트 동기화 정확도
- 작업 시간 Before/After

---

### Phase 3: 확장 (Week 5-6)

**목표**: 나머지 폴더 + 신규 에이전트

#### Week 5: 추가 CLAUDE.md (3개)

- 02-business-strategy/CLAUDE.md
- 04-marketing/CLAUDE.md
- 05-design/CLAUDE.md

#### Week 6: 신규 에이전트 (2개)

- docs-tracker.md (공식문서 모니터링)
- opensource-intel.md (GitHub trending)

---

### Phase 4: 최적화 & 검증 (Week 7-8)

**목표**: 실사용 + 성과 측정 + 문서화

#### Week 7: 실제 프로젝트 적용

- Micro SaaS 아이디어 1개로 전체 워크플로우 테스트
- 시장조사 → 전략 수립 → 제품 기획 → 프로젝트 관리

#### Week 8: 최종 측정 & 문서화

- 토큰 사용량 최종 집계
- 작업 시간 Before/After 비교
- 각 시스템 사용 가이드 작성

---

## 🗂️ 마이그레이션 계획

### 1단계: 폴더 이름 변경

```bash
cd Z:/home/damools/business

# 폴더 이름 변경
mv 02-strategy 02-business-strategy
mv 03-design 05-design
mv 05-content 03-product-planning

echo "✅ Folders renamed"
```

### 2단계: 신규 폴더 생성

```bash
# 06-project-management 생성
mkdir -p 06-project-management/{workspace-sync,notion-databases,project-tracking,timelines,backlogs,sprints,risk-management,templates}

echo "✅ Project management folder created"
```

### 3단계: dev-tools 통합

```bash
# dev-tools를 operations로 이동
mkdir -p 07-operations/dev-tools
mv 06-dev-tools/* 07-operations/dev-tools/
rmdir 06-dev-tools

echo "✅ Dev-tools integrated into operations"
```

### 4단계: 디렉토리 구조 생성

```bash
# 03-product-planning 하위 구조
mkdir -p 03-product-planning/{game-design,web-app-specs,content-strategy,templates}

# 04-marketing 하위 구조 (콘텐츠 추가)
mkdir -p 04-marketing/{seo,campaigns,email-sequences,blog-posts,newsletters,social-media}

# 05-design 하위 구조
mkdir -p 05-design/{ui-components,brand-assets,design-system,screenshots}

echo "✅ Directory structure created"
```

---

## ✅ 실행 체크리스트

### Phase 1: 토큰 최소화 & 기반 구축 (Week 1-2)

**Week 1**:
- [ ] MCP Tool Search 활성화 + 실측 (5개 세션)
- [ ] Root CLAUDE.md 간소화 (243줄 → 100줄)
- [ ] .claude/rules/ 디렉토리 생성
- [ ] .claude/rules/git.md
- [ ] .claude/rules/file-naming.md
- [ ] .claude/rules/security.md

**Week 2**:
- [ ] 01-research/CLAUDE.md (4가지 자료 타입)
- [ ] 03-product-planning/CLAUDE.md (게임/웹/앱 기획)

### Phase 2: Notion 통합 & 자동화 (Week 3-4)

**Week 3**:
- [ ] Notion MCP 설정 (.mcp.json 업데이트)
- [ ] NOTION_API_KEY 환경변수 설정
- [ ] 06-project-management/CLAUDE.md
- [ ] workspace-sync/ 디렉토리 생성
- [ ] weekly-sync.sh (워크스페이스 스캔)
- [ ] notion-sync.sh (Notion 동기화)

**Week 4**:
- [ ] .claude/hooks/context-inject.sh
- [ ] .claude/hooks/checkpoint.sh
- [ ] 성과 측정 프로토콜 실행 (1주일)

### Phase 3: 확장 (Week 5-6)

**Week 5**:
- [ ] 02-business-strategy/CLAUDE.md
- [ ] 04-marketing/CLAUDE.md
- [ ] 05-design/CLAUDE.md

**Week 6**:
- [ ] .claude/agents/docs-tracker.md
- [ ] .claude/agents/opensource-intel.md

### Phase 4: 최적화 (Week 7-8)

**Week 7**:
- [ ] Micro SaaS 프로젝트 전체 워크플로우 테스트

**Week 8**:
- [ ] 최종 성과 측정 리포트
- [ ] 사용 가이드 작성
- [ ] 트러블슈팅 문서

---

## 📊 폴더별 상세 설계

### 01-research/ (변경 없음)

**업무**: 시장조사 & 경쟁사 분석

**자료 타입** (4가지):
- 📰 기사 (Brave Search) - market-researcher
- 📚 공식문서 (Context7) - docs-tracker
- 💻 오픈소스 (GitHub) - opensource-intel
- 📊 기타 (케이스 스터디) - research-coordinator

**자동화**: 주간 리포트 (weekly.sh)

---

### 02-business-strategy/ (기존 02-strategy)

**업무**: 사업 전략 수립

**핵심 시스템**:
- 린 캔버스, 가격 모델, TAM/SAM/SOM
- GTM 전략, 사업계획서

**활용 스킬** (10개):
- product-strategist, micro-saas-launcher
- pricing-strategy, ceo-advisor, cto-advisor

**워크플로우**:
1. market-researcher → 시장 규모 분석
2. product-strategist → TAM/SAM/SOM 계산
3. pricing-strategy → 수익 모델 시뮬레이션
4. micro-saas-launcher → MVP 범위 정의
5. technical-writer → 사업계획서 작성

---

### 03-product-planning/ (기존 05-content, 재정의 ⭐)

**업무**: 제품 기획 (게임/웹/앱/콘텐츠)

**디렉토리 구조**:
```
03-product-planning/
├── game-design/              ← 게임 기획
│   ├── gdd/                  ← Game Design Document
│   ├── mechanics/            ← 게임 메커니즘
│   └── levels/               ← 레벨 디자인
├── web-app-specs/            ← 웹/앱 서비스 기획
│   ├── requirements/         ← 요구사항 명세
│   ├── features/             ← 기능 명세
│   └── user-flows/           ← 사용자 플로우
├── content-strategy/         ← 콘텐츠 기획
│   ├── curriculum/           ← 교육 커리큘럼
│   └── media-strategy/       ← 미디어 전략
└── templates/                ← 템플릿
    ├── gdd-template.md
    ├── prd-template.md
    └── user-story-template.md
```

**활용 스킬** (8개):
- product-manager-toolkit (PRD, RICE)
- agile-product-owner (백로그, 스토리)
- game-changing-features (10x 기능)
- requirements-clarity (요구사항 명확화)
- concise-planning (계획 수립)

**워크플로우** (예: 웹 서비스 기획):
1. requirements-clarity → 요구사항 명확화
2. product-manager-toolkit → PRD 작성
3. agile-product-owner → 사용자 스토리 생성
4. game-changing-features → 차별화 기능 발굴
5. technical-writer → 최종 기획서 정리
6. **→ 06-project-management로 자동 전달** (Notion 백로그 생성)

---

### 04-marketing/ (확장: 전략 + 콘텐츠)

**업무**: 마케팅 전략 & 콘텐츠 제작

**디렉토리 구조**:
```
04-marketing/
├── seo/                      ← SEO 최적화
├── campaigns/                ← 마케팅 캠페인
├── email-sequences/          ← 이메일 시퀀스
├── blog-posts/               ← 블로그 (마케팅용)
├── newsletters/              ← 뉴스레터
└── social-media/             ← SNS 콘텐츠
```

**활용 스킬** (15개):
- seo-audit, programmatic-seo, schema-markup
- competitive-ads-extractor, social-content
- email-sequence, copywriting, content-creator

**워크플로우** (블로그 포스트):
1. seo-audit → 키워드 리서치
2. content-creator → 초안 작성 (SEO 최적화)
3. copywriting → 설득력 있는 카피
4. fact-checker → 사실 검증
5. technical-writer → 최종 편집

---

### 05-design/ (기존 03-design)

**업무**: 디자인 & UX

**디렉토리 구조**:
```
05-design/
├── ui-components/            ← UI 컴포넌트
├── brand-assets/             ← 브랜드 에셋
├── design-system/            ← 디자인 시스템
└── screenshots/              ← 스크린샷 (Playwright)
```

**워크플로우** (외부 도구 중심):
1. **v0.dev** (수동) → 컴포넌트 생성
2. **Figma AI** (수동) → 레이아웃 정리
3. **Midjourney** (수동) → 이미지 생성
4. Claude Code → 코드 구현 (자동화)
5. ux-researcher → UX 평가 (에이전트)

---

### 06-project-management/ (신규 ⭐⭐⭐)

**업무**: 프로젝트 관리 (Notion + 워크스페이스 통합)

**핵심 기능**:
1. **워크스페이스 자동 탐지**:
   - Z:\home\damools\mywsl_workspace (리눅스)
   - E:\new_workspace (윈도우)
   - Filesystem MCP로 프로젝트 스캔

2. **Notion 양방향 동기화**:
   - 탐지된 프로젝트 → Notion DB 자동 생성
   - Notion에서 생성 → 워크스페이스 디렉토리 생성

3. **프로젝트 상태 관리**:
   - active, backlog, completed
   - 스프린트, 백로그, 타임라인

**디렉토리 구조**:
```
06-project-management/
├── CLAUDE.md                 ← Notion + 워크스페이스 통합 시스템
├── workspace-sync/           ← 워크스페이스 자동 동기화
│   ├── linux-projects.json
│   ├── windows-projects.json
│   └── sync-status.md
├── notion-databases/         ← Notion DB 메타데이터
│   ├── projects-db.json
│   ├── backlog-db.json
│   └── sprints-db.json
├── project-tracking/         ← 프로젝트 추적
│   ├── active-projects.md
│   ├── backlog-projects.md
│   └── completed-projects.md
├── timelines/                ← 프로젝트 타임라인
├── backlogs/                 ← 제품 백로그
├── sprints/                  ← 스프린트 계획
├── risk-management/          ← 리스크 관리
└── templates/                ← Notion 템플릿
```

**자동화 스크립트**:
```bash
# weekly-sync.sh (주간 월요일 08:00)
# 1. 두 워크스페이스 스캔
# 2. 프로젝트 메타데이터 추출
# 3. workspace-sync/*.json 업데이트
# 4. notion-sync.sh 자동 호출

# notion-sync.sh (weekly-sync 직후)
# 1. workspace-sync/*.json 읽기
# 2. Notion Projects DB와 비교
# 3. 신규/업데이트/삭제 동기화
```

**Notion 데이터베이스 스키마**:
```
Projects DB
├── Name (title)              프로젝트 이름
├── Status (select)           active | backlog | completed
├── Type (select)             game | web | app | content
├── Tech Stack (multi-select) 기술 스택
├── Workspace (select)        linux | windows
├── Path (text)               프로젝트 경로
├── Last Updated (date)       마지막 업데이트
├── Sprint (relation)         연결된 스프린트
└── Backlog Items (relation)  연결된 백로그
```

**활용 스킬**:
- agile-product-owner (백로그, 스프린트)
- concise-planning (프로젝트 계획)
- product-manager-toolkit (RICE 우선순위)

**활용 MCP**:
- Notion MCP (프로젝트 DB 관리)
- Filesystem MCP (워크스페이스 스캔)
- Memory MCP (프로젝트 히스토리)

---

### 07-operations/ (확장: dev-tools 통합)

**업무**: 운영 & 관리

**디렉토리 구조**:
```
07-operations/
├── finances/                 ← 재무 (민감 정보)
├── legal/                    ← 법무 (민감 정보)
├── processes/                ← 프로세스 문서
└── dev-tools/                ← 스킬/컴포넌트 관리 (통합)
    ├── skills-library/
    ├── components-library/
    └── scripts/
```

**핵심 시스템**:
- 3-Layer 상태 관리 (Memory + Task + File)
- 스킬/컴포넌트 관리 (manage-skills.sh, manage-components.sh)
- orchestrator 에이전트 (워크플로우 조정)

---

## 🚀 즉시 실행 항목 (오늘)

### 1단계: 토큰 베이스라인 측정
```bash
# 5개 세션에서 동일 작업 수행
# 1. 시장조사 요청
# 2. 제품 기획서 작성
# 3. 전략 수립 요청
# 4. 리서치 리포트 생성
# 5. 마케팅 콘텐츠 생성

# 각 세션 토큰 사용량 기록 → Before 기준값 설정
```

### 2단계: MCP Tool Search 활성화
```bash
echo 'export ENABLE_TOOL_SEARCH=auto' >> ~/.bashrc
source ~/.bashrc
```

### 3단계: 내일 동일 작업으로 After 측정
```bash
# 동일한 5개 세션 수행
# 토큰 사용량 기록
# 절감율 계산: (Before - After) / Before * 100
# 목표: 30-40% 절감
```

---

## 📈 예상 성과 (현실적)

### Phase 1 완료 시 (Week 2)
- 토큰 사용량: **30-40% 절감**
- CLAUDE.md: 2개 폴더 (01-research, 03-product-planning)

### Phase 2 완료 시 (Week 4)
- 토큰 사용량: **50-60% 절감**
- 시장조사: **30-50% 시간 절감** (4h → 2-3h)
- 제품 기획: **30-50% 시간 절감** (8h → 4-5h)
- **프로젝트 관리 자동화**: Notion + 워크스페이스 동기화 ⭐

### Phase 3 완료 시 (Week 6)
- 토큰 사용량: **60-70% 절감**
- 제품 기획: **50-70% 시간 절감** (8h → 3-4h)
- CLAUDE.md: 5개 폴더

### Phase 4 완료 시 (Week 8)
- 토큰 사용량: **70-80% 절감** (최적화 후)
- 전체 워크플로우 검증 완료
- 작업 복구율: **80-90%**

---

## 🎯 핵심 차별화 요소

1. ✅ **39개 스킬 + 9개 에이전트** 이미 설치
2. ✅ **7개 MCP 서버** (Notion 추가)
3. ✅ **7개 업무 영역** 명확한 역할 분담
4. ✅ **Notion 프로젝트 관리** 자동화
5. ✅ **워크스페이스 자동 연동** (리눅스/윈도우)
6. ✅ **현실적 목표** (60-70% 보완, 50-70% 토큰 절감)
7. ✅ **점진적 확장** (6-8주)

---

## 📝 다음 액션

**오늘 (2026-02-16)**:
1. 토큰 베이스라인 측정 (5개 세션)
2. MCP Tool Search 활성화

**내일 (2026-02-17)**:
1. 토큰 After 측정 (동일 5개 세션)
2. 절감율 계산 및 검증

**Week 1 (2026-02-17 ~ 2026-02-23)**:
1. Root CLAUDE.md 간소화
2. .claude/rules/ 모듈화 (3개)
3. 폴더 구조 마이그레이션

**Week 2 (2026-02-24 ~ 2026-03-01)**:
1. 01-research/CLAUDE.md
2. 03-product-planning/CLAUDE.md

---

**작성자**: Claude Sonnet 4.5
**버전**: v3.0 (폴더 재설계 + Notion 통합)
**참조**:
- docs/plan/doing/2026-02-16-agent-teams-implementation-report-REVIEWED.md
- solo-entrepreneur-ai-toolkit.md
- component-installation-report.md

*이 계획은 6-8주에 걸쳐 점진적으로 확장되며, 매 Phase마다 실측 기반으로 조정됩니다.*
