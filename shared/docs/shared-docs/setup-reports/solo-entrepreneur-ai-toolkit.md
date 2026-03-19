# 1인 기업 개발자를 위한 AI 도구 종합 보고서

> 작성일: 2026-02-13
> 대상: 백엔드 개발 역량을 가진 1인 기업(솔로프리너)
> 목적: 프로그래밍 외 부족 영역을 AI 도구로 보완하기 위한 종합 가이드

---

## Executive Summary

백엔드 개발자가 1인 기업으로 서비스를 런칭할 때, **코딩 이외의 6개 영역**이 병목이 된다. 2026년 현재, 각 영역을 AI 도구로 80% 이상 보완할 수 있다. 본 보고서는 **Claude Code Skills + 외부 AI 도구 + 자동화 워크플로**를 통합하여, 개발자 1명이 기획부터 마케팅까지 전 과정을 실행할 수 있는 도구 체계를 정리한다.

**핵심 수치:**
- 솔로프리너 테크 스택 연간 비용: $3,000~$12,000 (전통 팀 대비 95-98% 절감)
- Micro SaaS 시장 규모: $15.7B → $59.6B (2030, 연 30% 성장)
- AI 도구 활용 시 콘텐츠 제작 속도: 기존 대비 3~5배 향상

---

## 목차

1. [약점 영역 진단](#1-약점-영역-진단)
2. [시장조사 & 경쟁분석](#2-시장조사--경쟁분석)
3. [사업기획 & 전략](#3-사업기획--전략)
4. [디자인 & UI/UX](#4-디자인--uiux)
5. [프론트엔드 & 퍼블리싱](#5-프론트엔드--퍼블리싱)
6. [마케팅 & 그로스](#6-마케팅--그로스)
7. [콘텐츠 제작](#7-콘텐츠-제작)
8. [멀티에이전트 자동화 워크플로](#8-멀티에이전트-자동화-워크플로)
9. [통합 파이프라인: Discovery → Delivery](#9-통합-파이프라인-discovery--delivery)
10. [도구 설치 가이드](#10-도구-설치-가이드)
11. [Sources](#sources)

---

## 1. 약점 영역 진단

백엔드 개발자의 전형적인 역량 프로필과 AI 보완 가능성:

| 영역 | 자체 역량 | AI 보완도 | 핵심 도구 |
|------|:---------:|:---------:|----------|
| **시장조사/분석** | ★☆☆☆☆ | ★★★★☆ | Crayon, Browse AI, Claude Research |
| **사업기획/전략** | ★★☆☆☆ | ★★★★☆ | PrometAI, Product Strategist Skills |
| **디자인/UI/UX** | ★☆☆☆☆ | ★★★★★ | v0.dev, Figma AI, Lovable |
| **프론트엔드/퍼블리싱** | ★★☆☆☆ | ★★★★★ | v0.dev, Bolt.new, Claude Code |
| **마케팅/그로스** | ★☆☆☆☆ | ★★★★☆ | Blaze, Jasper, Marketing Skills |
| **콘텐츠 제작** | ★★☆☆☆ | ★★★★★ | Claude, Writesonic, SurferSEO |

> AI 보완도 ★★★★★ = 거의 완전 대체 가능, ★★★★☆ = 80% 대체 + 사람의 판단 필요

---

## 2. 시장조사 & 경쟁분석

### 2.1 Claude Code Skills

| 스킬 | 출처 | 기능 | 설치 |
|------|------|------|------|
| **research-engineer** | aitmpl/ai-research | 체계적 리서치 수행, 기술 동향 분석 | `npx claude-code-templates@latest --skill ai-research/research-engineer --yes` |
| **competitor-alternatives** | aitmpl/business-marketing | 경쟁사 비교 분석, 대안 서비스 매핑 | `npx claude-code-templates@latest --skill business-marketing/competitor-alternatives --yes` |
| **lead-research-assistant** | aitmpl/business-marketing | 리드/고객 리서치 자동화 | `npx claude-code-templates@latest --skill business-marketing/lead-research-assistant --yes` |
| **seo-audit** | aitmpl/business-marketing | SEO 키워드 기반 시장 수요 파악 | `npx claude-code-templates@latest --skill business-marketing/seo-audit --yes` |
| **seo-fundamentals** | aitmpl/business-marketing | 검색 트렌드 기반 시장 분석 | `npx claude-code-templates@latest --skill business-marketing/seo-fundamentals --yes` |

### 2.2 외부 AI 도구

| 도구 | 용도 | 가격 | 추천도 |
|------|------|------|:------:|
| **[Crayon](https://www.crayon.co/)** | 경쟁사 실시간 모니터링, 배틀카드 자동 생성 | $$$$ (Enterprise) | ★★★★★ |
| **[Browse AI](https://browse.ai/)** | 노코드 웹 스크래핑, 경쟁사 데이터 수집 | Free~$249/mo | ★★★★★ |
| **[Semrush](https://www.semrush.com/)** | SEO 인텔리전스, 키워드/트래픽 분석 | $139~$499/mo | ★★★★☆ |
| **[Similarweb](https://www.similarweb.com/)** | 경쟁사 트래픽/유입원 분석 | Free~Enterprise | ★★★★☆ |
| **[Visualping](https://visualping.io/)** | 웹사이트 변경 감지, 경쟁사 모니터링 | Free~$58/mo | ★★★☆☆ |
| **[Optimo](https://www.optimo.co/)** | 즉시 SWOT/PESTLE/경쟁 Gap 분석 | Free | ★★★★☆ |
| **[SpyFu](https://www.spyfu.com/)** | 경쟁사 PPC/키워드 분석 (저가) | $39~$79/mo | ★★★☆☆ |

### 2.3 워크플로 시나리오

```
"포트폴리오 자동 생성 SaaS의 시장성을 조사해줘"

Step 1: research-engineer 스킬 → 기술 트렌드 + 시장 규모 수집
Step 2: Browse AI → 경쟁사 (Portfolium, Carbonmade, Semplice) 기능/가격 스크래핑
Step 3: competitor-alternatives 스킬 → 경쟁사 비교표 자동 생성
Step 4: Semrush/seo-audit → "portfolio builder", "portfolio website" 검색량 분석
Step 5: Claude → 수집 데이터 종합 분석 → 시장 기회 리포트 출력
```

---

## 3. 사업기획 & 전략

### 3.1 Claude Code Skills

| 스킬 | 출처 | 기능 |
|------|------|------|
| **product-strategist** | aitmpl/business-marketing | 제품 전략 수립, TAM/SAM/SOM 분석, 시장 적합성 평가 |
| **pricing-strategy** | aitmpl/business-marketing | Freemium/Subscription/Usage-based 가격 모델 설계 |
| **micro-saas-launcher** | aitmpl/business-marketing | Micro SaaS MVP 검증 + 런칭 전략 |
| **product-manager-toolkit** | aitmpl/business-marketing | PRD/기획서 작성 프레임워크 |
| **ceo-advisor** | aitmpl/business-marketing | CEO 관점 사업 의사결정 자문 |
| **cto-advisor** | aitmpl/business-marketing | 기술 아키텍처 의사결정 자문 |
| **ai-product** | aitmpl/business-marketing | AI 제품 기획 특화 |
| **ai-wrapper-product** | aitmpl/business-marketing | AI API 래퍼 제품 설계 |
| **launch-strategy** | aitmpl/business-marketing | GTM(Go-to-Market) 전략 + 런칭 로드맵 |
| **agile-product-owner** | aitmpl/business-marketing | 애자일 PO 관점 백로그/스토리 작성 |

### 3.2 외부 AI 도구

| 도구 | 용도 | 가격 | 추천도 |
|------|------|------|:------:|
| **[PrometAI](https://prometai.app/)** | AI 사업계획서 생성, 재무 예측, 투자 시뮬레이션 | Free~$99/mo | ★★★★★ |
| **[IdeaBuddy](https://ideabuddy.com/)** | 가이드형 비즈니스 모델 설계 + 재무 예측 | $15~$35/mo | ★★★★☆ |
| **[Bizplanr](https://bizplanr.ai/)** | 10분 내 사업계획서 자동 생성 (모바일 친화) | Free~$20/mo | ★★★☆☆ |
| **[Pitch](https://pitch.com/)** | AI 투자 피치덱 자동 생성 | Free~$80/mo | ★★★★☆ |
| **[Lean Canvas AI](https://leancanvas.com/)** | 린 캔버스 자동 작성 + 가설 검증 | Free~$20/mo | ★★★★☆ |

### 3.3 워크플로 시나리오

```
"3개 후보 아이템 중 가장 유망한 것을 평가하고, 선정된 아이템의 기획서를 작성해줘"

Step 1: product-strategist 스킬 → TAM/SAM/SOM + 시장 적합성 점수 비교
Step 2: pricing-strategy 스킬 → 각 아이템별 수익 모델 시뮬레이션
Step 3: micro-saas-launcher 스킬 → MVP 범위 + 런칭 타임라인
Step 4: PrometAI → 재무 예측 (3년 P&L, BEP 분석)
Step 5: product-manager-toolkit + cto-advisor → PRD + 기술 아키텍처
Step 6: launch-strategy → GTM 전략 + 마일스톤 로드맵
Step 7: docx/pptx 스킬 → 최종 기획서 문서 출력
```

---

## 4. 디자인 & UI/UX

> 개발자에게 가장 큰 약점이지만, 2026년 AI로 가장 많이 보완 가능한 영역

### 4.1 Claude Code Skills

| 스킬 | 출처 | 기능 |
|------|------|------|
| **frontend-design** | superpowers | 프로덕션급 프론트엔드 인터페이스 생성, 고품질 디자인 |
| **theme-factory** | superpowers | 10개 프리셋 테마 적용, 커스텀 테마 생성 |
| **web-artifacts-builder** | superpowers | 복잡한 멀티 컴포넌트 아티팩트 (React + shadcn/ui) |

### 4.2 외부 AI 도구 — 코드 생성형 (개발자 최적)

| 도구 | 용도 | 특징 | 가격 | 추천도 |
|------|------|------|------|:------:|
| **[v0.dev](https://v0.dev/)** | React/Next.js 컴포넌트 생성 | shadcn/ui 기반, 프로덕션 품질, Vercel 통합 | Free~$20/mo | ★★★★★ |
| **[Lovable](https://lovable.dev/)** | 풀스택 앱 빌더 | 가장 깔끔한 React 코드 출력, 대화형 개선 | Free~$50/mo | ★★★★★ |
| **[Bolt.new](https://bolt.new/)** | 브라우저 기반 즉시 생성 | 프레임워크 유연성 최고, 즉시 미리보기 | Free~$20/mo | ★★★★☆ |
| **[Emergent](https://emergent.sh/)** | AI-native 풀스택 빌더 | 멀티에이전트 아키텍처, 레이아웃 인텔리전스 | Beta | ★★★★☆ |

### 4.3 외부 AI 도구 — 디자인 전문

| 도구 | 용도 | 특징 | 가격 | 추천도 |
|------|------|------|------|:------:|
| **[Figma AI](https://www.figma.com/)** | 디자인 생성/편집 | 기존 디자인 시스템 호환, 네이티브 AI 레이어 | Free~$15/mo | ★★★★★ |
| **[Tempo.new](https://tempo.new/)** | 디자인-코드 브릿지 | UX 엔지니어급 UI 빌드, 비주얼 + 코드 동시 | Beta | ★★★★☆ |
| **[Flowstep](https://flowstep.ai/)** | 대화형 UI 디자인 | 설명 → Figma 호환 프로덕션 디자인 생성 | Beta | ★★★★☆ |
| **[Builder.io](https://www.builder.io/)** | 비주얼 코드 에디터 | Git 워크플로 통합, 디자인 시스템 활용 PR 생성 | Free~$50/mo | ★★★☆☆ |
| **[Midjourney](https://midjourney.com/)** | 비주얼 에셋/일러스트 | 히어로 이미지, 아이콘, 일러스트 생성 | $10~$60/mo | ★★★★☆ |

### 4.4 개발자를 위한 디자인 보완 전략

```
비전문가 개발자의 디자인 워크플로:

1. v0.dev로 컴포넌트 프로토타입 생성 (shadcn/ui 기반)
2. Figma AI로 전체 페이지 레이아웃 정리
3. Midjourney로 히어로 이미지/일러스트 생성
4. frontend-design 스킬로 Claude Code에서 코드 구현
5. theme-factory 스킬로 일관된 테마 적용
6. webapp-testing 스킬로 반응형/다크모드 검증
```

---

## 5. 프론트엔드 & 퍼블리싱

### 5.1 Claude Code Skills

| 스킬 | 출처 | 기능 |
|------|------|------|
| **frontend-design** | superpowers | 프론트엔드 인터페이스 구현 |
| **nextjs-best-practices** | aitmpl/development | Next.js 14 App Router, SSR/SSG 최적화 |
| **web-performance-optimization** | aitmpl/web-development | Lighthouse, Core Web Vitals, 번들 최적화 |
| **roier-seo** | aitmpl/web-development | SEO 메타데이터, 구조화 데이터 최적화 |
| **webapp-testing** | superpowers | Playwright E2E 테스트 + 시각 검증 |

### 5.2 외부 AI 도구 — "바이브 코딩" 시대

2026년, "바이브 코딩(Vibe Coding)"이 콜린스 사전 올해의 단어로 선정되었다. 개발자가 코드를 한 줄씩 쓰는 대신, 원하는 것을 설명하면 AI가 빌드하는 패러다임이다.

| 도구 | 최적 용도 | 코드 품질 | 가격 |
|------|----------|:---------:|------|
| **[Cursor](https://cursor.com/)** | 프로덕션 코드베이스 (장기 프로젝트) | ★★★★★ | Free~$20/mo |
| **[Claude Code](https://claude.ai/claude-code)** | 터미널 기반 AI 코딩 (현재 사용 중) | ★★★★★ | Max 구독 |
| **[v0.dev](https://v0.dev/)** | React 컴포넌트 라이브러리 개발 | ★★★★★ | Free~$20/mo |
| **[Bolt.new](https://bolt.new/)** | 빠른 프로토타입/랜딩 페이지 | ★★★★☆ | Free~$20/mo |
| **[Lovable](https://lovable.dev/)** | 폴리시된 데모/투자자 프레젠테이션 | ★★★★★ | Free~$50/mo |
| **[Replit](https://replit.com/)** | 클라우드 IDE + 즉시 배포 | ★★★☆☆ | Free~$25/mo |
| **[Windsurf](https://codeium.com/windsurf)** | Cursor 대안, AI 코딩 에디터 | ★★★★☆ | Free~$15/mo |

### 5.3 도구 선택 가이드

```
목적별 최적 도구 선택:

┌─────────────────────────────────────────────────────┐
│  "랜딩 페이지/프로토타입 빠르게"  → Bolt.new          │
│  "투자자/고객 데모"              → Lovable            │
│  "shadcn/ui 컴포넌트 생성"      → v0.dev             │
│  "프로덕션 코드 작성"           → Claude Code + Cursor│
│  "기존 코드베이스 확장"         → Claude Code          │
│  "디자인 → 코드 변환"          → Figma MCP + Cursor   │
└─────────────────────────────────────────────────────┘
```

### 5.4 Claude Code + v0.dev 통합 워크플로

```
1. v0.dev에서 대화형으로 컴포넌트 디자인 (shadcn/ui)
2. 생성된 코드를 프로젝트에 복사
3. Claude Code에서 프로젝트 컨텍스트에 맞게 통합/수정
4. webapp-testing 스킬로 반응형 + 다크모드 검증
5. web-performance-optimization 스킬로 Lighthouse 점수 최적화
```

---

## 6. 마케팅 & 그로스

### 6.1 Claude Code Skills

| 스킬 | 출처 | 기능 |
|------|------|------|
| **marketing-ideas** | aitmpl/business-marketing | **140개 SaaS 마케팅 전략** 프레임워크 |
| **marketing-psychology** | aitmpl/business-marketing | 행동 심리학 기반 전환율 최적화 |
| **marketing-strategy-pmm** | aitmpl/business-marketing | PMM 전략 문서 작성 |
| **free-tool-strategy** | aitmpl/business-marketing | 무료 도구 전략으로 사용자 획득 |
| **viral-generator-builder** | aitmpl/business-marketing | 바이럴 콘텐츠/도구 설계 |
| **competitive-ads-extractor** | aitmpl/business-marketing | 경쟁사 광고 전략 추출/분석 |
| **analytics-tracking** | aitmpl/business-marketing | GA4/이벤트 트래킹 설계 |
| **page-cro** | coreyhaines31/marketingskills | 랜딩 페이지 전환율 최적화 |
| **copywriting** | coreyhaines31/marketingskills | 마케팅 카피 작성 |

### 6.2 외부 AI 도구

| 도구 | 용도 | 특징 | 가격 | 추천도 |
|------|------|------|------|:------:|
| **[Blaze](https://www.blaze.ai/)** | 올인원 마케팅 플랫폼 | 솔로프리너 특화, 브랜드 보이스 유지, 멀티채널 | Free~$25/mo | ★★★★★ |
| **[Jasper](https://www.jasper.ai/)** | AI 마케팅 에이전트 | 마케팅 특화 AI, 팀 협업, 브랜드 가이드 | $49~$125/mo | ★★★★☆ |
| **[Buffer](https://buffer.com/)** | 소셜 미디어 스케줄링 | AI 캡션 생성, 최적 게시 시간 분석 | Free~$120/mo | ★★★★☆ |
| **[Mailchimp](https://mailchimp.com/)** | 이메일 마케팅 자동화 | AI 세그멘테이션, 개인화 캠페인 | Free~$350/mo | ★★★★☆ |
| **[Carrd](https://carrd.co/)** | 1페이지 랜딩/마케팅 사이트 | 초저가, 빠른 배포, A/B 테스트 | $19/yr | ★★★★★ |
| **[Hotjar](https://www.hotjar.com/)** | 사용자 행동 분석 | 히트맵, 세션 녹화, AI 인사이트 | Free~$80/mo | ★★★★☆ |

### 6.3 솔로프리너 마케팅 자동화 파이프라인

```
런칭 전 마케팅 자동화:

1. marketing-ideas 스킬 → 140개 전략 중 자사 적합 전략 10개 선별
2. free-tool-strategy → 무료 도구 기획 (리드 자석)
3. Carrd → 랜딩 페이지 24시간 내 배포
4. analytics-tracking 스킬 → GA4 이벤트 설계
5. Buffer → SNS 콘텐츠 2주분 자동 스케줄링
6. Mailchimp → 이메일 웰컴 시퀀스 자동화 (5통)
7. page-cro 스킬 → 전환율 A/B 테스트 설계
```

---

## 7. 콘텐츠 제작

### 7.1 Claude Code Skills

| 스킬 | 출처 | 기능 |
|------|------|------|
| **content-research-writer** | aitmpl/business-marketing | 콘텐츠 리서치 + 작성 자동화 |
| **content-creator** | aitmpl/business-marketing | 콘텐츠 기획 + 작성 |
| **copywriting** | coreyhaines31/marketingskills | 마케팅 카피/헤드라인/CTA 작성 |

### 7.2 외부 AI 도구

| 도구 | 용도 | 특징 | 가격 | 추천도 |
|------|------|------|------|:------:|
| **Claude / ChatGPT** | 범용 콘텐츠 작성 | 블로그, 기술 문서, 마케팅 카피 | $20/mo | ★★★★★ |
| **[Writesonic](https://writesonic.com/)** | SEO 최적화 글 작성 | 100+ 소스 기반, 자동 팩트체크, EEAT 시그널 | $16~$33/mo | ★★★★★ |
| **[Surfer SEO](https://surferseo.com/)** | SEO 콘텐츠 최적화 | 키워드 분석, 경쟁사 역공학, 콘텐츠 에디터 | $89~$219/mo | ★★★★☆ |
| **[GravityWrite](https://gravitywrite.com/)** | 블로그/SNS 콘텐츠 | 다국어, 브랜드 보이스, 대량 생성 | Free~$19/mo | ★★★★☆ |
| **[SEOWriting.ai](https://seowriting.ai/)** | 1클릭 SEO 아티클 | 자동 인터널 링킹, NLP 최적화 | $14~$64/mo | ★★★☆☆ |
| **[Koala AI](https://koala.sh/)** | 장문 SEO 블로그 | 실시간 SERP 분석 기반 글 생성 | $9~$49/mo | ★★★★☆ |
| **[Midjourney](https://midjourney.com/)** | 비주얼 콘텐츠 | 블로그 히어로 이미지, SNS 비주얼 | $10~$60/mo | ★★★★☆ |

### 7.3 콘텐츠 제작 워크플로

```
기술 블로그 + SEO 콘텐츠 파이프라인:

1. Surfer SEO → 타겟 키워드 클러스터 분석
2. content-research-writer 스킬 → 주제별 리서치 + 아웃라인
3. Claude → 초안 작성 (기술적 정확성 + 경험 기반)
4. Writesonic → SEO 최적화 (EEAT 시그널, 소스 인용)
5. Midjourney → 히어로 이미지 + 다이어그램 소스 생성
6. Surfer SEO → 최종 SEO 스코어 검증
7. Buffer → SNS 프로모션 자동 스케줄링
```

> **핵심 원칙**: AI가 뼈대를 만들고, 사람이 경험과 인사이트를 채운다. "Fresh, high-quality content written from real experience beats any optimizer."

---

## 8. 멀티에이전트 자동화 워크플로

> 2026년은 "에이전트의 해". n8n + Claude MCP로 자율적 워크플로 오케스트레이션이 가능해졌다.

### 8.1 자동화 플랫폼 비교

| 플랫폼 | 특징 | AI 통합 | 가격 | 추천도 |
|--------|------|---------|------|:------:|
| **[n8n](https://n8n.io/)** | 오픈소스, 셀프호스팅 가능, MCP 통합 | Claude/GPT + MCP 네이티브 | Free (셀프) ~ $50/mo | ★★★★★ |
| **[Make.com](https://www.make.com/)** | 비주얼 워크플로 빌더 | AI 모듈 풍부 | Free~$29/mo | ★★★★☆ |
| **[Zapier](https://zapier.com/)** | 7000+ 앱 연동, 가장 큰 생태계 | AI by Zapier | Free~$29/mo | ★★★★☆ |

### 8.2 n8n + Claude MCP 통합

n8n MCP 서버를 통해 Claude Code/Desktop에서 직접 n8n 워크플로를 제어할 수 있다:

```bash
# n8n MCP 서버 설치
npm install -g n8n-mcp

# .mcp.json에 추가
{
  "n8n": {
    "command": "n8n-mcp",
    "args": ["--n8n-url", "http://localhost:5678", "--api-key", "..."]
  }
}
```

**가능한 자동화 시나리오:**

| 시나리오 | 트리거 | 액션 |
|----------|--------|------|
| 경쟁사 모니터링 | 주 1회 스케줄 | Browse AI 스크래핑 → Claude 분석 → Slack 알림 |
| SEO 콘텐츠 파이프라인 | 새 키워드 발견 | Surfer 분석 → Claude 초안 → WordPress 게시 |
| 고객 피드백 분석 | 새 리뷰/이슈 등록 | 수집 → Claude 분류/감성 분석 → 노션 정리 |
| 리드 자동 응답 | 문의 폼 제출 | Claude 맞춤 응답 생성 → 이메일 발송 |
| SNS 자동 게시 | 블로그 포스트 발행 | 요약 생성 → 이미지 생성 → Buffer 스케줄링 |

### 8.3 Claude Code 내부 멀티에이전트

현재 프로젝트의 Agent Teams (Ver 6.1) 아키텍처를 활용:

```
Team Lead (Opus/Sonnet) — 전체 오케스트레이션
├── Backend Teammate (Sonnet) — API/서비스 구현
├── Frontend Teammate (Sonnet) — UI 컴포넌트 구현
└── 서브에이전트 (Haiku/Sonnet)
    ├── Explore — 코드베이스 탐색
    ├── spec-writer — Spec 문서 작성
    ├── code-reviewer — 코드 리뷰
    └── systematic-debugging — 디버깅
```

---

## 9. 통합 파이프라인: Discovery → Delivery

기존 SDD 워크플로에 Phase 0 (Discovery)을 추가한 전체 파이프라인:

```
┌─────────────────────────────────────────────────────────────────┐
│  Phase 0: Discovery (AI 도구 활용)                                │
│                                                                   │
│  0.1 자료조사                                                      │
│    research-engineer + Browse AI + Semrush                       │
│    → 시장 데이터, 기술 트렌드, 경쟁 현황                              │
│                                                                   │
│  0.2 시장분석                                                      │
│    competitor-alternatives + Crayon + seo-audit                  │
│    → 경쟁사 비교표, 시장 기회 영역                                    │
│                                                                   │
│  0.3 아이디어 도출                                                  │
│    brainstorming + game-changing-features + marketing-ideas      │
│    → 아이디어 후보 20+개, 심리학 기반 기능 설계                       │
│                                                                   │
│  0.4 사업 아이템 선정                                                │
│    product-strategist + pricing-strategy + PrometAI              │
│    → 최종 1-2개 선정, 수익 모델, 재무 예측                            │
│                                                                   │
│  0.5 기획서 작성                                                     │
│    product-manager-toolkit + cto-advisor + launch-strategy       │
│    → PRD + 기술 아키텍처 + GTM → docx/pptx 출력                     │
│                                                                   │
│  0.6 개발계획서                                                      │
│    requirements-clarity + concise-planning + writing-plans       │
│    → Phase별 WBS + 마일스톤 → SDD Spec 연계                        │
│                                                                   │
│  [STOP] Human 검토 + 승인                                          │
├─────────────────────────────────────────────────────────────────┤
│  Phase 1: Spec (SDD)                                              │
│    Spec 작성 → [STOP] → Plan → AI 검증 → [STOP]                   │
├─────────────────────────────────────────────────────────────────┤
│  Phase 2: Implementation (SDD)                                    │
│    TeamCreate → Shared 타입 → Teammates → Walkthrough → 검증      │
│    + v0.dev/Figma AI로 디자인 보강                                   │
│    + Claude Code frontend-design 스킬로 UI 구현                     │
├─────────────────────────────────────────────────────────────────┤
│  Phase 3: Delivery (SDD)                                          │
│    커밋 → PR → AI Check 5 → Human 검토 + Merge                     │
├─────────────────────────────────────────────────────────────────┤
│  Phase 4: Launch & Growth                                         │
│    Carrd 랜딩 → marketing-ideas 전략 → Buffer SNS → Mailchimp     │
│    Surfer SEO 콘텐츠 → analytics-tracking → Hotjar 분석            │
│    n8n 자동화 파이프라인으로 지속 운영                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 10. 도구 설치 가이드

### Phase A: 즉시 설치 (사전 개발 + 핵심)

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

### Phase C: 중기 설치 (심화)

```bash
# AI 리서치
npx claude-code-templates@latest --skill ai-research/research-engineer --yes
npx claude-code-templates@latest --skill ai-research/context7-auto-research --yes

# 마케팅 심화 (coreyhaines31/marketingskills)
git clone https://github.com/coreyhaines31/marketingskills.git /tmp/marketingskills
cp -r /tmp/marketingskills/skills/page-cro .claude/skills/
cp -r /tmp/marketingskills/skills/copywriting .claude/skills/
cp -r /tmp/marketingskills/skills/analytics-tracking .claude/skills/

# 성능/보안
npx claude-code-templates@latest --skill web-development/web-performance-optimization --yes
npx claude-code-templates@latest --skill security/sql-injection-testing --yes
```

### 외부 도구 필수 구독 (최소 스택)

| 도구 | 월 비용 | 용도 |
|------|---------|------|
| Claude Max | $100 | 코딩 + 콘텐츠 + 분석 (현재 사용 중) |
| v0.dev Free | $0 | 프론트엔드 컴포넌트 생성 |
| Carrd | ~$2 | 랜딩 페이지 |
| Buffer Free | $0 | SNS 스케줄링 |
| Mailchimp Free | $0 | 이메일 마케팅 (500명까지) |
| n8n Self-hosted | $0 | 워크플로 자동화 |
| **합계** | **~$102/mo** | 전체 스택 |

> 최소 $102/월로 시장조사부터 마케팅까지 전 과정 운영 가능. 풀타임 직원 1명 월급의 2-3%.

---

## Sources

### 시장조사 & 분석
- [Top AI Market Research Tools 2026 - Pragmatic Coders](https://www.pragmaticcoders.com/blog/top-ai-market-research-tools)
- [10 Best AI Tools for Competitor Analysis - Visualping](https://visualping.io/blog/best-ai-tools-competitor-analysis)
- [27 Best AI Market Research Tools - The CMO](https://thecmo.com/tools/best-ai-market-research-tools/)

### 사업기획 & 전략
- [Solopreneur Tech Stack 2026 - PrometAI](https://prometai.app/blog/solopreneur-tech-stack-2026)
- [Solopreneur Guide to Scaling 2026](https://entrepreneurloop.com/solopreneur-guide-to-scaling-2026/)
- [Best AI Business Plan Generators 2026 - Monday.com](https://monday.com/blog/crm-and-sales/best-ai-for-business-plan/)
- [Best Micro SaaS Ideas 2026 - Superframeworks](https://superframeworks.com/articles/best-micro-saas-ideas-solopreneurs)

### 디자인 & UI/UX
- [6 Best AI Tools for UI Design 2026 - Emergent](https://emergent.sh/learn/best-ai-tools-for-ui-design)
- [11 Best AI Design Tools 2026 - Figma](https://www.figma.com/resource-library/ai-design-tools/)
- [15 Best AI Tools for Designers - Builder.io](https://www.builder.io/blog/best-ai-tools-for-designers)

### 프론트엔드 & 코드 생성
- [Best Vibe Coding Tools 2026 - Taskade](https://www.taskade.com/blog/best-vibe-coding-tools)
- [Best AI App Builder 2026: Lovable vs Bolt vs v0 - Mocha](https://getmocha.com/blog/best-ai-app-builder-2026/)
- [V0 vs Cursor Comparison - ToolJet](https://blog.tooljet.com/v0-vs-cursor/)

### 마케팅 & 그로스
- [7 AI Tools for Solopreneurs 2026 - Entrepreneur.com](https://www.entrepreneur.com/science-technology/7-ai-tools-solopreneurs-need-for-2026-to-hit-7-figures/499925)
- [7 AI Tools That Run a One-Person Business - Entrepreneur.com](https://www.entrepreneur.com/growing-a-business/7-ai-tools-that-run-a-one-person-business-in-2026-no/501943)
- [Indie Hacker Tools Stack - BuiltThisWeek](https://www.builtthisweek.com/blog/indie-hacker-tools-2025)

### 콘텐츠 제작
- [Best AI Writing Tools for SEO Content - Medium](https://medium.com/freelancers-hub/best-ai-writing-tools-d9f064ac2d5c)
- [32 AI Content Marketing Tools 2026 - DigitalFirst.ai](https://www.digitalfirst.ai/blog/ai-content-marketing-tools)
- [How Solo Founders Use AI for Content - DNYUZ](https://dnyuz.com/2026/02/12/how-3-solo-founders-use-ai-to-transform-their-content-into-business/)

### 멀티에이전트 자동화
- [n8n MCP Claude Integration - addROM](https://addrom.com/n8n-mcp-claude-integration-control-workflows-directly-from-ai/)
- [n8n Integrations Guide 2026 - NextGen Tools](https://www.nxgntools.com/blog/n8n-integrations-guide-2026)
- [n8n MCP GitHub Repository](https://github.com/czlonkowski/n8n-mcp)

### Claude Code Skills
- [aitmpl.com](https://www.aitmpl.com/)
- [GitHub - davila7/claude-code-templates](https://github.com/davila7/claude-code-templates)
- [GitHub - coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills)

### 관련 보고서
- [aitmpl 스킬 추천 리포트](./aitmpl-skills-recommendation.md) — 기술 스택 기반 Claude Code Skills 상세 추천
