# aitmpl.com/skills 사이트 분석 리포트

> 분석일: 2026-02-13
> 대상: https://www.aitmpl.com/skills

---

## 1. 개요

**[Claude Code Templates](https://www.aitmpl.com/)** (aitmpl.com)는 Anthropic의 Claude Code를 위한 **오픈소스 템플릿/플러그인 마켓플레이스**입니다. CLI 도구와 웹 브라우저를 통해 AI 에이전트, 스킬, 커맨드, 훅, MCP 서버 설정, 프로젝트 템플릿을 검색하고 원클릭 설치할 수 있습니다.

| 항목 | 내용 |
|------|------|
| **URL** | https://www.aitmpl.com |
| **GitHub** | [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) (20.2K stars) |
| **버전** | 1.18.0 |
| **라이선스** | MIT (완전 무료) |
| **기여자** | 45명 |
| **사용자** | 4,000+ (109개국) |

---

## 2. 컴포넌트 카테고리 (6종)

`/skills` 페이지는 아래 6가지 컴포넌트 유형 중 **Skills** 카테고리를 필터링한 뷰입니다.

| 카테고리 | 설명 | 예시 |
|----------|------|------|
| **Skills** | 재사용 가능한 능력 (progressive disclosure) | docx, pdf, xlsx, frontend-design |
| **Agents** | 도메인 특화 AI 전문가 | security-auditor, code-reviewer, architect |
| **Commands** | 슬래시 커맨드 | `/generate-tests`, `/optimize-bundle`, `/check-security` |
| **Settings** | Claude Code 설정 프리셋 | timeout, memory, output style |
| **Hooks** | 자동화 트리거 | pre-commit validation, post-completion |
| **MCPs** | 외부 서비스 통합 | GitHub, PostgreSQL, Stripe, AWS |

> **참고**: Skills 페이지는 SPA(Single Page Application)로 동적 로딩되어, 정적 크롤링으로는 개별 스킬 카드가 표시되지 않음. CLI나 브라우저 JavaScript 실행이 필요.

---

## 3. 주요 피처드 프로젝트

### 3.1 ClaudeKit (핵심 제품)

프로덕션 레벨의 AI 에이전트 & 스킬 번들. **5단계 워크플로** 제공:

```
/docs:init → /brainstorm → /plan → /clear → /code:auto
(코드베이스 분석) (요구사항 도출) (구현 계획) (컨텍스트 리셋) (자동 구현)
```

**주요 커맨드:**

| 커맨드 | 기능 |
|--------|------|
| `/cook` | 독립형 기능 구현 |
| `/code:review` | 보안/성능/표준 코드 리뷰 |
| `/test` | E2E, 통합, 단위 테스트 자동화 |
| `/debug` | 로그 분석 + 원인 진단 |
| `/docs` | 기술 문서 자동 동기화 |
| `/watzup` | 프로젝트 건강도 + 마일스톤 추적 |

**설치:**

```bash
npm i -g claudekit-cli
ck init           # 프로젝트별
ck init -g        # 글로벌
```

### 3.2 BrainGrid

제품 관리 에이전트 — PM 워크플로 자동화

### 3.3 Neon

완전한 PostgreSQL 템플릿 — Neon 서버리스 DB 최적화 설정

---

## 4. 기술 아키텍처

### 4.1 기술 스택 (GitHub 기준)

| 언어 | 비중 | 용도 |
|------|------|------|
| Python | 52.4% | CLI 도구 핵심 |
| JavaScript | 19.5% | 웹 인터페이스 |
| TeX | 10.6% | 문서/템플릿 |
| HTML | 7.7% | 웹 UI |
| Shell | 4.7% | 설치 스크립트 |
| CSS | 1.9% | 스타일링 |

### 4.2 프로젝트 구조

```
claude-code-templates/
├── .claude-plugin/          # 플러그인 설정
├── .claude/                 # Claude Code 설정
├── api/                     # 백엔드 API
├── cli-tool/                # CLI 구현체
├── cloudflare-workers/      # 터널 인프라
├── database/migrations/     # DB 스키마
├── docs/                    # 문서
└── scripts/                 # 유틸리티 스크립트
```

### 4.3 설치 방식

```bash
# 인터랙티브 브라우징 (권장)
npx claude-code-templates@latest

# 특정 컴포넌트 직접 설치
npx claude-code-templates@latest --agent development-tools/code-reviewer --yes
npx claude-code-templates@latest --command performance/optimize-bundle --yes
npx claude-code-templates@latest --mcp database/postgresql-integration --yes
```

### 4.4 샌드박스 실행 환경

| 제공자 | 위치 | 복잡도 | 최적 용도 |
|--------|------|--------|----------|
| **E2B** | 클라우드 | 낮음 | 풀스택 프로젝트 |
| **Cloudflare** | 엣지 | 낮음 | 서버리스 API |
| **Docker** | 로컬 | 중간 | 커스텀 환경 |

---

## 5. 부가 도구

| 도구 | CLI 명령 | 설명 |
|------|---------|------|
| **Analytics** | `claude-code-templates --analytics` | Opus 4 세션 모니터링, 토큰 사용량 추적 |
| **Health Check** | `claude-code-templates --health` | 설치 최적화 진단 |
| **Conversation Monitor** | `claude-code-templates --monitor` | 실시간 응답 분석 (모바일 지원) |
| **Plugin Dashboard** | `claude-code-templates --plugins` | 플러그인 통합 관리 (신규) |

---

## 6. 컴포넌트 출처 (Attribution)

오픈소스 커뮤니티의 다양한 기여로 구성:

| 출처 | 기여 내용 |
|------|----------|
| **Anthropic 공식** | 기본 스킬셋 |
| **K-Dense AI** | 139개 과학 분야 스킬 |
| **obra/superpowers** | 워크플로 자동화 스킬 |
| **alirezarezvani/claude-skills** | 실전 활용 스킬 |
| **NerdyChefsAI** | 엔터프라이즈 특화 스킬 |

---

## 7. 지원 개발 스택 (30+ 기업)

OpenAI, Anthropic, Stripe, Salesforce, AWS, GitHub, Shopify, Twilio 등 주요 플랫폼별 최적화 설정 제공.

---

## 8. 우리 프로젝트와의 비교/시사점

| 항목 | aitmpl.com | 우리 프로젝트 |
|------|-----------|--------------|
| **스킬 관리** | npm 패키지 기반 마켓플레이스 | `.claude/skills/` 로컬 관리 |
| **에이전트** | 단일 역할 에이전트 마켓플레이스 | Agent Teams 6.1 (Lead+Teammates) |
| **워크플로** | ClaudeKit 5단계 | SDD (Spec→Plan→Impl→Verify→PR) |
| **커맨드** | `/cook`, `/debug` 등 | `/commit`, `/test-all` 등 |
| **MCP 통합** | 30+ 기업 프리셋 | PostgreSQL, Redis, Playwright, Context7 |
| **검증** | Health Check 도구 | verify.sh 5단계 AI 검증 게이트 |

### 참고할 만한 점

1. **Analytics 도구**: 토큰 사용량/세션 성능 모니터링 — 우리 finops.md의 `/context` 실행 자동화에 참고 가능
2. **Plugin Dashboard**: 플러그인 활성화/비활성화 UI — MCP 서버 관리 간소화에 참고
3. **샌드박스 실행**: E2B/Cloudflare/Docker 기반 격리 실행 — Teammate 격리 환경으로 발전 가능성
4. **컴포넌트 마켓플레이스 모델**: 스킬을 npm 패키지로 배포 — 우리 스킬도 재사용 가능한 패키지로 구조화 가능

---

## 9. 요약

aitmpl.com은 Claude Code 생태계에서 가장 큰 오픈소스 컴포넌트 마켓플레이스입니다. 20.2K GitHub stars, 400+ 컴포넌트, MIT 라이선스로 무료 제공되며, CLI 기반의 간편한 설치 경험을 제공합니다. 특히 ClaudeKit의 5단계 워크플로(`/docs:init` → `/brainstorm` → `/plan` → `/clear` → `/code:auto`)는 우리 프로젝트의 SDD 워크플로와 유사한 "계획 → 구현" 패턴을 공유하지만, 우리 시스템의 **AI 검증 게이트(verify.sh)** 와 **Agent Teams 아키텍처**는 보다 엄격한 품질 관리 체계를 갖추고 있습니다.

---

## Sources

- [aitmpl.com 메인](https://www.aitmpl.com/)
- [GitHub - davila7/claude-code-templates](https://github.com/davila7/claude-code-templates)
- [공식 문서](https://docs.aitmpl.com/)
- [ClaudeKit 상세](https://www.aitmpl.com/featured/claudekit/index.html)
- [Smithery - aitmpl-downloader](https://smithery.ai/skills/s-hiraoku/aitmpl-downloader)
