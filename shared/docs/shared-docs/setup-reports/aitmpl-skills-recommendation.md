# aitmpl.com 스킬 추천 리포트

> 작성일: 2026-02-13
> 대상: Portfolio Project (Next.js 14 + NestJS 10 + PostgreSQL + Redis)

---

## Part 1: 프로젝트 기술 스택 기반 추천

### 현재 보유 스킬 (15개)

| 스킬 | 유형 | 비고 |
|------|------|------|
| pdf, docx, xlsx, pptx | 문서 처리 | 범용 |
| frontend-design | UI 디자인 | 범용 |
| webapp-testing | E2E 테스트 | Playwright 기반 |
| theme-factory | 테마 적용 | 범용 |
| hook-creator | 훅 생성 | Claude Code 설정 |
| slash-command-creator | 커맨드 생성 | Claude Code 설정 |
| subagent-creator | 서브에이전트 생성 | Claude Code 설정 |
| web-artifacts-builder | 아티팩트 빌드 | React/Tailwind |
| portfolio-analyzer | 소스 분석 | 프로젝트 전용 |
| spec-to-module | Spec→NestJS 모듈 | 프로젝트 전용 |
| quote-generator | 견적서 생성 | 프로젝트 전용 |

### GAP 분석 — 기술 스킬 부족 영역

| 영역 | 현재 상태 | 필요도 |
|------|----------|--------|
| NestJS 전문 지식 | 없음 (일반 rules만) | **높음** |
| Next.js 최적화 | 없음 | **높음** |
| PostgreSQL 최적화 | 없음 | **높음** |
| TypeScript 전문 | 없음 | 중간 |
| 보안 감사 | 없음 | **높음** |
| CI/CD 자동화 | 없음 | 중간 |
| SEO 최적화 | 없음 | 중간 |
| 성능 분석 | 없음 | 중간 |

### 추천 스킬 — 기술 (우선순위순)

#### Tier 1: 즉시 적용 (핵심 스택 직접 매칭)

| # | 스킬명 | 출처 | 추천 이유 |
|---|--------|------|----------|
| 1 | **nestjs-expert** | aitmpl/development | NestJS 프레임워크 전문 지식. Guard, Pipe, Interceptor, TypeORM 통합 등 |
| 2 | **nextjs-best-practices** | aitmpl/development | Next.js 14 App Router, SSR/SSG, Middleware 최적화 |
| 3 | **postgres-best-practices** | aitmpl/development | 쿼리 최적화, 인덱싱, 커넥션 풀링, 마이그레이션 전략 |
| 4 | **typescript-expert** | aitmpl/development | strict mode, 제네릭, 유틸리티 타입, 타입 가드 |
| 5 | **api-security-best-practices** | aitmpl/security | OWASP Top 10, JWT 보안, Rate Limiting, Input Validation |

**설치:**
```bash
npx claude-code-templates@latest --skill development/nestjs-expert --yes
npx claude-code-templates@latest --skill development/nextjs-best-practices --yes
npx claude-code-templates@latest --skill development/postgres-best-practices --yes
npx claude-code-templates@latest --skill development/typescript-expert --yes
npx claude-code-templates@latest --skill security/api-security-best-practices --yes
```

#### Tier 2: 단기 적용 (개발 효율)

| # | 스킬명 | 출처 | 추천 이유 |
|---|--------|------|----------|
| 6 | **playwright** | aitmpl/development | E2E 테스트 고급 패턴 (기존 webapp-testing 보강) |
| 7 | **github-actions-creator** | aitmpl/development | CI/CD 파이프라인 자동 생성 |
| 8 | **database-schema-designer** | aitmpl/development | TypeORM 엔티티 ↔ DB 스키마 설계 최적화 |
| 9 | **web-performance-optimization** | aitmpl/web-development | Lighthouse, Core Web Vitals, 번들 최적화 |
| 10 | **vercel-deploy** | aitmpl/development | Next.js 배포 최적화 |

#### Tier 3: 중기 적용 (품질 강화)

| # | 스킬명 | 출처 | 추천 이유 |
|---|--------|------|----------|
| 11 | **sql-injection-testing** | aitmpl/security | TypeORM 쿼리 보안 검증 |
| 12 | **roier-seo** | aitmpl/web-development | 포트폴리오 SEO 최적화 |
| 13 | **nodejs-best-practices** | aitmpl/development | NestJS 기반 Node.js 성능 튜닝 |
| 14 | **test-driven-development** | aitmpl/development | TDD 워크플로 강화 |

### 추천 MCP 서버

| MCP | 추천 이유 | 현재 보유 |
|-----|----------|----------|
| **sentry** | 에러 트래킹 + 성능 모니터링 | ❌ |
| **postman** | API 테스트 자동화 | ❌ |
| **chrome-devtools** | 프론트엔드 디버깅 | ❌ |
| postgresql-integration | DB 관리 | ✅ 이미 보유 |
| github-integration | Git 관리 | ✅ 이미 보유 |
| context7 | 문서 조회 | ✅ 이미 보유 |

---

## Part 2: 사전 개발 단계 (Pre-Development) 도구 추천

> 자료조사 → 시장분석 → 아이디어 도출 → 사업 아이템 선정 → 기획서 작성 → 개발계획서 작성

### 전체 파이프라인 매핑

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Pre-Development Pipeline                         │
│                                                                     │
│  ① 자료조사/분석    ② 시장분석      ③ 아이디어 도출                    │
│  ┌──────────┐    ┌──────────┐    ┌──────────────┐                   │
│  │research- │    │competitor│    │brainstorming │                   │
│  │engineer  │    │-alterna- │    │game-changing │                   │
│  │context7  │    │tives     │    │-features     │                   │
│  │rag-*     │    │lead-     │    │marketing-    │                   │
│  │notebooklm│    │research  │    │ideas         │                   │
│  └────┬─────┘    └────┬─────┘    └──────┬───────┘                   │
│       │               │                 │                           │
│       ▼               ▼                 ▼                           │
│  ④ 사업아이템 선정   ⑤ 기획서 작성     ⑥ 개발계획서                    │
│  ┌──────────┐    ┌──────────┐    ┌──────────────┐                   │
│  │product-  │    │product-  │    │concise-      │                   │
│  │strategist│    │manager-  │    │planning      │                   │
│  │pricing-  │    │toolkit   │    │writing-plans │                   │
│  │strategy  │    │ceo/cto-  │    │requirements- │                   │
│  │micro-saas│    │advisor   │    │clarity       │                   │
│  │-launcher │    │launch-   │    │spec-to-impl  │                   │
│  └──────────┘    │strategy  │    └──────────────┘                   │
│                  └──────────┘                                       │
└─────────────────────────────────────────────────────────────────────┘
```

### ① 자료조사 및 분석 (Research & Analysis)

| 스킬명 | 출처 | 기능 |
|--------|------|------|
| **research-engineer** | aitmpl/ai-research | 체계적 리서치 수행, 논문/기술 동향 분석 |
| **context7-auto-research** | aitmpl/ai-research | Context7 기반 자동 문서/라이브러리 조사 |
| **rag-implementation** | aitmpl/ai-research | RAG 파이프라인으로 대량 문서 분석 |
| **notion-research-documentation** | aitmpl/productivity | 리서치 결과를 Notion에 체계적 정리 |
| **notebooklm** | aitmpl/productivity | 노트북 기반 학습/분석 관리 |
| **content-research-writer** | aitmpl/business-marketing | 콘텐츠 리서치 + 작성 자동화 |

**활용 시나리오:**
```
"OO 분야의 최신 기술 트렌드와 경쟁 서비스를 조사해줘"
→ research-engineer + context7-auto-research 자동 활성화
→ 기술 동향, 경쟁사 분석, 시장 규모 데이터 수집
→ notion-research-documentation으로 정리
```

### ② 시장분석 (Market Analysis)

| 스킬명 | 출처 | 기능 |
|--------|------|------|
| **competitor-alternatives** | aitmpl/business-marketing | 경쟁사 비교 분석, 대안 서비스 매핑 |
| **competitive-ads-extractor** | aitmpl/business-marketing | 경쟁사 광고 전략 추출/분석 |
| **lead-research-assistant** | aitmpl/business-marketing | 리드/고객 리서치 자동화 |
| **analytics-tracking** | aitmpl/business-marketing | GA4/이벤트 트래킹 설계 |
| **seo-audit** | aitmpl/business-marketing | SEO 기반 시장 키워드 분석 |
| **seo-fundamentals** | aitmpl/business-marketing | 검색 트렌드 기반 수요 파악 |

**활용 시나리오:**
```
"SaaS 시장에서 프로젝트 관리 도구의 경쟁 현황을 분석해줘"
→ competitor-alternatives: 주요 경쟁사 (Asana, Jira, Linear 등) 기능 비교표
→ competitive-ads-extractor: 경쟁사 마케팅 전략 분석
→ seo-audit: 검색 키워드 트렌드로 시장 수요 파악
```

### ③ 아이디어 도출 (Ideation)

| 스킬명 | 출처 | 기능 |
|--------|------|------|
| **brainstorming** | aitmpl/productivity | 구조화된 브레인스토밍 (이미 superpowers에도 존재) |
| **game-changing-features** | aitmpl/productivity | 혁신적 기능 아이디어 발굴 |
| **marketing-ideas** | aitmpl/business-marketing | **140개 SaaS 마케팅 전략** 프레임워크 |
| **marketing-psychology** | aitmpl/business-marketing | 행동 심리학 기반 아이디어 도출 |
| **free-tool-strategy** | aitmpl/business-marketing | 무료 도구 전략으로 사용자 획득 아이디어 |
| **viral-generator-builder** | aitmpl/business-marketing | 바이럴 콘텐츠/도구 설계 |

**활용 시나리오:**
```
"AI 기반 포트폴리오 플랫폼의 차별화 기능 아이디어를 도출해줘"
→ brainstorming: 기능 아이디어 20개 발산
→ game-changing-features: 혁신성 평가 + 우선순위
→ marketing-psychology: 사용자 심리 기반 기능 설계
```

### ④ 사업 아이템 선정 (Business Item Selection)

| 스킬명 | 출처 | 기능 |
|--------|------|------|
| **product-strategist** | aitmpl/business-marketing | 제품 전략 수립, 시장 적합성 평가 |
| **pricing-strategy** | aitmpl/business-marketing | 가격 책정 모델 설계 (Freemium, Subscription 등) |
| **micro-saas-launcher** | aitmpl/business-marketing | Micro SaaS 아이템 검증 + 런칭 전략 |
| **ai-product** | aitmpl/business-marketing | AI 제품 기획 특화 |
| **ai-wrapper-product** | aitmpl/business-marketing | AI API 래퍼 제품 설계 |
| **ceo-advisor** | aitmpl/business-marketing | CEO 관점 사업 의사결정 자문 |

**활용 시나리오:**
```
"3개 후보 아이템 중 가장 유망한 것을 평가해줘"
→ product-strategist: TAM/SAM/SOM 분석 + 시장 적합성 점수
→ pricing-strategy: 각 아이템별 수익 모델 시뮬레이션
→ micro-saas-launcher: MVP 범위 + 런칭 타임라인 제안
```

### ⑤ 기획서 작성 (Business Proposal / PRD)

| 스킬명 | 출처 | 기능 |
|--------|------|------|
| **product-manager-toolkit** | aitmpl/business-marketing | PRD/기획서 작성 프레임워크 |
| **cto-advisor** | aitmpl/business-marketing | 기술 아키텍처 의사결정 자문 |
| **launch-strategy** | aitmpl/business-marketing | 제품 런칭 전략 + Go-to-Market |
| **marketing-strategy-pmm** | aitmpl/business-marketing | PMM (Product Marketing Manager) 전략 문서 |
| **copywriting** | aitmpl/business-marketing | 마케팅 카피/제안서 작성 |
| **content-creator** | aitmpl/business-marketing | 콘텐츠 기획 + 작성 자동화 |
| **agile-product-owner** | aitmpl/business-marketing | 애자일 PO 관점 백로그/스토리 작성 |

**활용 시나리오:**
```
"AI 포트폴리오 플랫폼의 사업 기획서를 작성해줘"
→ product-manager-toolkit: PRD 구조 (문제정의, 목표, 사용자스토리, 성공지표)
→ cto-advisor: 기술 스택 선정 근거 + 아키텍처 제안
→ launch-strategy: GTM 전략 + 마일스톤 로드맵
→ docx/pptx 스킬: 최종 문서 출력 (Word/PPT)
```

### ⑥ 개발계획서 작성 (Development Plan)

| 스킬명 | 출처 | 기능 |
|--------|------|------|
| **concise-planning** | aitmpl/productivity | 전략적 계획 수립 (간결한 형태) |
| **writing-plans** | aitmpl/productivity | 상세 개발 계획서 작성 |
| **executing-plans** | aitmpl/productivity | 계획 실행 체크리스트 |
| **requirements-clarity** | aitmpl/productivity | 요구사항 명확화 + 모호성 제거 |
| **notion-spec-to-implementation** | aitmpl/productivity | Spec → 구현 계획 변환 |
| **kaizen** | aitmpl/productivity | 지속적 개선 방법론 적용 |
| **planning-with-files** | aitmpl/productivity | 파일 기반 계획 관리 |

**활용 시나리오:**
```
"기획서를 바탕으로 Phase별 개발계획서를 작성해줘"
→ requirements-clarity: 기획서에서 모호한 요구사항 식별 + 질문
→ concise-planning: Phase 분류 + 마일스톤 정의
→ writing-plans: 상세 개발계획서 (WBS, 일정, 리소스)
→ 우리 SDD: Spec → Plan → Task 문서 자동 생성
```

---

## Part 3: 종합 추천 — 우선순위별 설치 가이드

### Phase A: 즉시 설치 (사전 개발 + 핵심 기술)

```bash
# 사전 개발 도구 (비즈니스/기획)
npx claude-code-templates@latest --skill business-marketing/product-strategist --yes
npx claude-code-templates@latest --skill business-marketing/product-manager-toolkit --yes
npx claude-code-templates@latest --skill business-marketing/competitor-alternatives --yes
npx claude-code-templates@latest --skill business-marketing/marketing-ideas --yes
npx claude-code-templates@latest --skill business-marketing/pricing-strategy --yes

# 핵심 기술 스킬
npx claude-code-templates@latest --skill development/nestjs-expert --yes
npx claude-code-templates@latest --skill development/nextjs-best-practices --yes
npx claude-code-templates@latest --skill development/postgres-best-practices --yes

# 생산성
npx claude-code-templates@latest --skill productivity/concise-planning --yes
npx claude-code-templates@latest --skill productivity/requirements-clarity --yes
```

### Phase B: 단기 설치 (시장분석 + 개발 효율)

```bash
# 시장분석
npx claude-code-templates@latest --skill business-marketing/content-research-writer --yes
npx claude-code-templates@latest --skill business-marketing/seo-audit --yes
npx claude-code-templates@latest --skill business-marketing/launch-strategy --yes
npx claude-code-templates@latest --skill business-marketing/cto-advisor --yes

# 개발 효율
npx claude-code-templates@latest --skill development/typescript-expert --yes
npx claude-code-templates@latest --skill security/api-security-best-practices --yes
npx claude-code-templates@latest --skill development/github-actions-creator --yes
```

### Phase C: 중기 설치 (심화 도구)

```bash
# AI 리서치
npx claude-code-templates@latest --skill ai-research/research-engineer --yes
npx claude-code-templates@latest --skill ai-research/context7-auto-research --yes

# 마케팅 심화 (coreyhaines31/marketingskills 별도 설치)
git clone https://github.com/coreyhaines31/marketingskills.git /tmp/marketingskills
cp -r /tmp/marketingskills/skills/page-cro .claude/skills/
cp -r /tmp/marketingskills/skills/copywriting .claude/skills/
cp -r /tmp/marketingskills/skills/analytics-tracking .claude/skills/

# 성능/보안
npx claude-code-templates@latest --skill web-development/web-performance-optimization --yes
npx claude-code-templates@latest --skill security/sql-injection-testing --yes
```

---

## Part 4: 사전 개발 파이프라인 워크플로 제안

### 우리 SDD와 통합한 Full Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│  Phase 0: Discovery (신규 — aitmpl 스킬 활용)                    │
│                                                                 │
│  Step 0.1: 자료조사                                              │
│    research-engineer + context7-auto-research                   │
│    → 시장 데이터, 기술 트렌드, 경쟁 현황 수집                       │
│                                                                 │
│  Step 0.2: 시장분석                                              │
│    competitor-alternatives + seo-audit                          │
│    → 경쟁사 비교표, 시장 기회 영역 식별                             │
│                                                                 │
│  Step 0.3: 아이디어 도출                                          │
│    brainstorming + game-changing-features + marketing-ideas     │
│    → 아이디어 후보 리스트 (20+개)                                  │
│                                                                 │
│  Step 0.4: 사업 아이템 선정                                       │
│    product-strategist + pricing-strategy                        │
│    → 최종 아이템 1-2개 선정 + 수익 모델                            │
│                                                                 │
│  Step 0.5: 기획서 작성                                            │
│    product-manager-toolkit + cto-advisor + launch-strategy      │
│    → PRD + 기술 아키텍처 + GTM 전략                               │
│    → docx/pptx 스킬로 문서 출력                                   │
│                                                                 │
│  Step 0.6: 개발계획서 작성                                        │
│    requirements-clarity + concise-planning + writing-plans      │
│    → Phase별 WBS + 마일스톤 + 리소스 계획                         │
│                                                                 │
│  [STOP] Human 검토 + 승인                                        │
├─────────────────────────────────────────────────────────────────┤
│  Phase 1: Spec (기존 SDD)                                       │
│    Spec 작성 → [STOP] → Plan → AI 검증 → [STOP]                 │
│                                                                 │
│  Phase 2: Implementation (기존 SDD)                              │
│    TeamCreate → Shared 타입 → Teammates → Walkthrough → 검증    │
│                                                                 │
│  Phase 3: Delivery (기존 SDD)                                    │
│    커밋 → PR → AI Check 5 → Human 검토 + Merge                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 관련 보고서

- **[1인 기업 개발자를 위한 AI 도구 종합 보고서](./solo-entrepreneur-ai-toolkit.md)** — 본 리포트의 스킬 추천을 확장하여, 시장조사/기획/디자인/마케팅/콘텐츠 등 개발 외 영역의 AI 도구 + 외부 SaaS + 자동화 워크플로를 종합 정리

---

## Sources

- [aitmpl.com](https://www.aitmpl.com/)
- [GitHub - davila7/claude-code-templates](https://github.com/davila7/claude-code-templates)
- [GitHub - coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) (7.5K stars)
- [Claude Skills for Product Managers](https://medium.com/product-powerhouse/claude-skills-the-ai-feature-thats-quietly-changing-how-product-managers-work-aad5d8d0640a)
- [Marketing Plan with Claude Code](https://uditgoenka.medium.com/build-your-complete-marketing-plan-in-30-minutes-using-anthropics-claude-code-610d657731a7)
