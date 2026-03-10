---
name: daily-system-review
description: >
  매일 실행하는 AI 시스템 일일 분석. 6-Tier 소스에서 전일 AI/Agentic 동향을
  총망라 수집하고, 우리 시스템과 1:1 비교 분석하여 갭 분석 + 적용 계획서를 생성한다.
argument-hint: "[YYYY-MM-DD]"
allowed-tools: "Agent,WebSearch,WebFetch,Write,Read,Glob,Grep"
user-invocable: true
---

# AI 시스템 일일 분석 파이프라인

> 전일 AI/Agentic 분야 전체 데이터를 6-Tier로 총망라 수집하여, 우리 시스템과 비교 분석한다.

## 인자

- `$ARGUMENTS` = 분석 기준 날짜 (YYYY-MM-DD). 미입력 시 전날 날짜 사용.

## 산출물 (2종)

| # | 문서 | 저장 위치 | 파일명 |
|:-:|------|----------|--------|
| 1 | AI 시스템 분석 리포트 | `docs/reviews/` | `{date}-ai-system-analysis.md` |
| 2 | 적용 계획서 | `docs/planning/active/plans/` | `{date}-system-improvement-plan.md` |

## 데이터 수집 소스 (6-Tier)

### Tier 1: AI 기업 공식 소스 (최고 신뢰도)

| 소스 | URL | 수집 대상 |
|------|-----|----------|
| Anthropic News | `anthropic.com/news` | 모델 발표, 제품 업데이트, 정책 |
| Anthropic Engineering | `anthropic.com/engineering` | 기술 심화 포스트 |
| Anthropic Research | `anthropic.com/research` | 연구 논문, 안전성 |
| Claude API Changelog | `docs.anthropic.com/en/docs/changelog` | API/SDK 변경사항 |
| Claude Code Releases | GitHub `anthropics/claude-code` | CLI 버전, 신기능 |
| MCP Spec/SDK | GitHub `modelcontextprotocol/*` | 프로토콜 변경, SDK 업데이트 |
| OpenAI Blog | `openai.com/blog` | GPT 업데이트, API 변경 |
| OpenAI API Changelog | `platform.openai.com/docs/changelog` | API 변경사항 |
| Google DeepMind Blog | `deepmind.google/blog` | Gemini, 연구 발표 |
| Google AI Blog | `blog.google/technology/ai` | 제품 AI 통합 |
| Meta AI (FAIR) | `ai.meta.com/blog` | Llama, 오픈소스 모델 |
| Microsoft AI Blog | `blogs.microsoft.com/ai` | Copilot, Azure AI |
| Hugging Face Blog | `huggingface.co/blog` | 오픈소스 모델, 트렌드 |

### Tier 2: GitHub 생태계

| 소스 | 수집 대상 |
|------|----------|
| GitHub Trending (daily, AI/ML) | 신규 인기 레포, 스타 급상승 |
| Claude Code Issues/Discussions | 커뮤니티 요청, 버그 리포트 |
| MCP Servers Registry | 신규 MCP 서버, 인기 서버 |
| LangChain/LangGraph Releases | 버전, 신기능 |
| CrewAI Releases | 멀티에이전트 프레임워크 |
| Vercel AI SDK Releases | 프론트엔드 AI 통합 |
| AutoGen/Semantic Kernel | Microsoft 에이전트 프레임워크 |

### Tier 3: 개발자 커뮤니티

| 소스 | 수집 대상 |
|------|----------|
| Hacker News (front page AI) | AI 관련 탑 스토리 + 댓글 인사이트 |
| Reddit r/MachineLearning | 연구 논의, SOTA 결과 |
| Reddit r/LocalLLaMA | 로컬 모델, 양자화, 벤치마크 |
| Reddit r/ClaudeAI | Claude 사용자 경험, 팁, 이슈 |
| Reddit r/artificial | 범용 AI 뉴스 |
| Dev.to / Medium (AI 태그) | 실전 튜토리얼, 사례 |
| Twitter/X AI 커뮤니티 | 실시간 반응, 빠른 뉴스 전파 |
| Discord (Claude, MCP) | 커뮤니티 피드백, 미공개 팁 |

### Tier 4: YouTube 영상 콘텐츠

| 채널/검색 | 수집 대상 |
|----------|----------|
| Fireship | 주요 AI 뉴스 빠른 요약 |
| Two Minute Papers | 논문 시각적 해설 |
| AI Jason | AI 에이전트, 프레임워크 심화 |
| Matt Wolfe | AI 도구 리뷰, 트렌드 |
| Yannic Kilcher | 논문 심층 해설 |
| The AI Advantage | AI 실무 활용 |
| YouTube 검색: "Claude Code" | 최신 Claude Code 튜토리얼/리뷰 |
| YouTube 검색: "MCP server" | MCP 관련 신규 콘텐츠 |
| YouTube 검색: "AI agents 2026" | 에이전트 트렌드 |

### Tier 5: 학술/연구

| 소스 | 수집 대상 |
|------|----------|
| arXiv cs.AI | AI 일반 신규 논문 |
| arXiv cs.CL | 자연어처리, LLM 논문 |
| arXiv cs.SE | 소프트웨어 엔지니어링 + AI |
| arXiv cs.MA | 멀티에이전트 시스템 |
| Papers With Code (trending) | SOTA 벤치마크, 코드 포함 논문 |
| Semantic Scholar (trending) | 인용 급증 논문, 영향력 |

### Tier 6: 산업/미디어

| 소스 | 수집 대상 |
|------|----------|
| TechCrunch AI | 펀딩, 인수, 제품 출시 |
| VentureBeat AI | 엔터프라이즈 AI 동향 |
| The Verge AI | 소비자 AI 제품 |
| Product Hunt (AI 카테고리) | 신규 AI 제품/도구 |
| AI 전문 뉴스레터 | The Batch, TLDR AI, Import AI |
| a16z AI Blog | VC 관점 AI 트렌드 |

## 실행 흐름

### Wave 1 (병렬 — 5개 동시 스폰)

**Teammate A (Sonnet): AI 공식 소스 + GitHub 생태계**
- Tier 1 전체 (13개 공식 소스) — WebFetch로 직접 확인
- Tier 2 전체 (GitHub 릴리즈, 트렌딩)
- 전날 날짜 기준 신규 콘텐츠만 필터
- 출력: 구조화된 JSON 요약 → Lead에게 반환

**Teammate B (Haiku): 개발자 커뮤니티 + 미디어**
- Tier 3 전체 (HN, Reddit, Twitter, Discord)
- Tier 6 전체 (TechCrunch, VentureBeat, Product Hunt)
- WebSearch 날짜 필터: 전날~오늘
- 출력: 구조화된 JSON 요약 → Lead에게 반환

**Teammate C (Haiku): YouTube 영상 탐색**
- Tier 4 전체
- WebSearch: 채널별 최신 업로드 + 키워드 검색
- 영상 제목, URL, 예상 내용 요약, 조회수/반응
- 심층 분석 필요 영상은 "추천 시청" 목록으로 분리
- 출력: 영상 목록 + 요약 → Lead에게 반환

**Teammate D (Haiku): 학술 논문 탐색**
- Tier 5 전체 — academic-researcher 에이전트 타입 활용
- arXiv 전날 신규 제출 (cs.AI, cs.CL, cs.SE, cs.MA)
- Papers With Code 트렌딩
- 실무 적용 가능성 높은 논문 Top 5 선별
- 출력: 논문 목록 + 핵심 요약 → Lead에게 반환

**Teammate E (Sonnet): 우리 시스템 현황 스냅샷**
- Read: `~/.claude/trine/rules/`, `~/.claude/rules/`
- Read: `.claude/skills/`, `.claude/agents/`, `.claude/rules/`
- Read: 최근 improvement plan (있으면)
- 현재 시스템 구조, 버전, 패턴, 미해결 갭 정리
- 출력: 시스템 현황 JSON → Lead에게 반환

### Wave 2 (Lead Opus 종합 — A~E 결과 의존)

Lead가 5개 Teammate 결과를 종합하여 2개 문서 직접 작성:

**산출물 1: AI 시스템 분석 리포트** (`docs/reviews/{date}-ai-system-analysis.md`)

```markdown
# {date} AI 시스템 일일 분석 리포트

## Executive Summary (3줄 요약)

## 1. 업계 주요 변화 (전일 기준)
### 1.1 공식 발표/업데이트
### 1.2 GitHub 생태계 변화
### 1.3 커뮤니티 시그널
### 1.4 주목 영상 콘텐츠
### 1.5 학술 연구 동향

## 2. 우리 시스템 현황

## 3. 1:1 비교 분석 (업계 vs 우리)
| 영역 | 업계 최신 | 우리 현황 | 갭 | 영향도 |

## 4. 갭 분석 + 영향도 평가
### Critical (즉시 대응)
### High (이번 주 내)
### Medium (이번 달 내)
### Low (모니터링)

## 5. 추천 시청/읽기 목록
### 영상
### 논문
### 블로그 포스트

## 출처 및 신뢰도
```

**산출물 2: 적용 계획서** (`docs/planning/active/plans/{date}-system-improvement-plan.md`)

```markdown
# {date} 시스템 개선 계획서

## 오늘의 액션 아이템

### P0 (긴급 — 오늘 처리)
### P1 (높음 — 이번 주)
### P2 (보통 — 이번 달)

## 각 액션 상세
- 액션명
- 영향 범위 (프로젝트/시스템)
- 예상 작업량
- 의존성
- 참조 소스

## 누적 미처리 액션 (이전 계획서에서 이월)
```

이전 날짜의 계획서가 있으면 미처리 액션을 이월한다.

## 신뢰도 등급

모든 데이터에 신뢰도를 표기한다:
- `[신뢰도: High]` = 공식 소스 (Tier 1) 또는 다중 소스 교차 확인
- `[신뢰도: Medium]` = 단일 신뢰 소스 (Tier 2-3) 또는 커뮤니티 합의
- `[신뢰도: Low]` = 단일 비공식 소스, 루머, AI 추정
