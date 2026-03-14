---
description: "AI 시스템 일일 분석 — 6-Tier 소스 수집 + 우리 시스템과 갭 분석 + 적용 계획서 생성"
argument-hint: "[YYYY-MM-DD]"
allowed-tools: "Agent,Bash,WebSearch,WebFetch,Write,Read,Glob,Grep,mcp__brave-search__brave_web_search"
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

## 실행 흐름

### Step 0 (raw-data.json 존재 확인 — 최우선)

```
RAW_JSON="01-research/daily/{date}/raw-data.json"
```

`Glob(RAW_JSON)` 으로 파일 존재 여부 확인:

- **존재 → 수집 스킵**: Wave 1 Subagent(A/B/C/D) 스폰을 건너뛴다.
  raw-data.json 경로를 Wave 2로 직접 전달하고, Subagent E (시스템 스냅샷)만 별도 실행한 뒤
  두 결과를 합쳐서 Wave 2 종합 분석을 실행한다.

- **미존재 → 전체 파이프라인 실행**: 아래 Wave 1부터 정상 진행한다.

---

### Wave 1 (병렬 — 5개 Subagent 동시 스폰)

**Subagent A (Sonnet): AI 공식 소스 + GitHub 생태계**
- Tier 1: Anthropic, OpenAI, Google, Meta, Microsoft, HuggingFace 공식 블로그/changelog
- Tier 2: GitHub Trending (AI/ML), Claude Code Issues, MCP Registry, LangChain/CrewAI/AutoGen 릴리즈
- 전날 날짜 기준 신규 콘텐츠만 필터 (WebFetch + WebSearch)
- **Brave Search 활용**: `brave_web_search`로 공식 소스 도메인 필터링 (예: `site:anthropic.com`, `site:openai.com`). WebFetch 실패 시 fallback
- 출력: 구조화된 마크다운 요약 (최대 1500 토큰)

**Subagent B (Haiku): 개발자 커뮤니티 + 미디어**
- Tier 3: Hacker News 탑 AI 스토리, Reddit r/MachineLearning + r/LocalLLaMA + r/ClaudeAI
- Tier 6: TechCrunch AI, VentureBeat, Product Hunt AI 카테고리, a16z AI Blog
- WebSearch 날짜 필터: `after:$ARGUMENTS`
- **Brave Search 활용**: `brave_web_search`로 커뮤니티/미디어 검색 (HN, Reddit, TechCrunch 등). WebSearch 실패 시 fallback
- 출력: 구조화된 마크다운 요약 (최대 1000 토큰)

**Subagent C (Haiku): YouTube 영상 탐색**
- Tier 4: Fireship, AI Jason, Matt Wolfe, Yannic Kilcher, The AI Advantage 최신 업로드
- WebSearch: "Claude Code" site:youtube.com, "MCP server" site:youtube.com, "AI agents 2026" site:youtube.com
- **Brave Search 활용**: `brave_web_search`로 채널별 최신 업로드 검색 (예: `site:youtube.com "Fireship" AI 2026`)
- 심층 분석 필요 영상 = "추천 시청" 목록으로 분리
- 비즈니스 관련성 4점 이상 예상 영상은 반드시 아래 형식으로 별도 섹션에 나열 (자동 분석 트리거용):
  ```
  ### 자동 분석 대상 (비즈니스 관련성 4+)
  - {YouTube URL} | {예상 점수}/5 | {이유 한 줄}
  ```
- 출력: 영상 목록 + 간략 요약 + 자동 분석 대상 섹션 (최대 800 토큰)

**Subagent D (Haiku): 학술 논문 탐색**
- Tier 5: arXiv cs.AI + cs.CL + cs.SE + cs.MA 전날 신규 제출
- Papers With Code 트렌딩, Semantic Scholar 인용 급증 논문
- 실무 적용 가능성 높은 논문 Top 5 선별
- 출력: 논문 목록 + 핵심 요약 (최대 800 토큰)

**Subagent E (Sonnet): 우리 시스템 현황 스냅샷**
- Read: `~/.claude/trine/rules/`, `~/.claude/rules/`
- Read: `.claude/skills/`, `.claude/agents/`, `.claude/rules/`
- Read: `docs/planning/active/plans/` 최근 계획서 (미처리 액션 확인)
- 현재 시스템 구조, 버전, 패턴, 이전 미해결 갭 정리
- 출력: 시스템 현황 요약 (최대 1000 토큰)

### Wave 1.5 (YouTube 자동 분석 — Subagent C 완료 후)

Subagent C 출력의 "자동 분석 대상 (비즈니스 관련성 4+)" 섹션에서 URL을 추출한다.
최대 3개 URL만 처리 (cron 실행 시간 제한 고려).

각 URL에 대해 순서대로 처리:

1. URL에서 video_id 추출 (예: `v=xxx` → `xxx`)
2. `Glob("01-research/videos/analyses/*{video_id}*.json")`으로 이미 분석된 파일 확인
3. **미존재 시**: Bash로 트랜스크립트 추출
   ```bash
   python3 scripts/yt-analyzer/yt-analyzer.py {URL} 2>&1
   ```
   - 실행 결과에서 생성된 JSON 파일 경로 확인
   - JSON 경로 확인 후 `yt-video-analyst` Subagent 스폰 (JSON 파일 경로 전달)
4. **이미 존재 시**: 스킵 (중복 분석 방지, 로그에 "이미 분석됨: {video_id}" 기록)

**yt-video-analyst Subagent 스폰 시 프롬프트에 포함**:
- JSON 파일 경로
- 분석 결과 저장 위치: `01-research/videos/analyses/{date}-{video_id}-analysis.md`
- 기준일: `$ARGUMENTS`

**에러 처리**:
- yt-analyzer.py 실패 시 (IP 차단, 자막 없음 등): 해당 URL 스킵, 나머지 계속 처리
- 에러 내용은 Wave 2 분석 리포트의 "주목 영상 콘텐츠" 섹션 비고에 기록

### Wave 2 (Lead 종합 — Wave 1 + 1.5 완료 후)

5개 Subagent 결과 + Wave 1.5 분석 결과를 종합하여 2개 문서 직접 작성:

**산출물 1: AI 시스템 분석 리포트** (`docs/reviews/{date}-ai-system-analysis.md`)

```markdown
# {date} AI 시스템 일일 분석 리포트

## Executive Summary (3줄 요약)

## 1. 업계 주요 변화 (전일 기준)
### 1.1 공식 발표/업데이트  [신뢰도: High]
### 1.2 GitHub 생태계 변화  [신뢰도: High]
### 1.3 커뮤니티 시그널     [신뢰도: Medium]
### 1.4 주목 영상 콘텐츠    [신뢰도: Medium]
### 1.5 학술 연구 동향      [신뢰도: High]

## 2. 우리 시스템 현황

## 3. 1:1 비교 분석 (업계 vs 우리)
| 영역 | 업계 최신 | 우리 현황 | 갭 | 영향도 |
|------|---------|---------|-----|:------:|

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
- 액션명, 영향 범위, 예상 작업량, 의존성, 참조 소스

## 누적 미처리 액션 (이전 계획서에서 이월)
```

이전 날짜의 계획서가 있으면 미처리 액션을 이월한다.

## 신뢰도 등급

- `[신뢰도: High]` = 공식 소스 (Tier 1) 또는 다중 소스 교차 확인
- `[신뢰도: Medium]` = 단일 신뢰 소스 (Tier 2-3) 또는 커뮤니티 합의
- `[신뢰도: Low]` = 단일 비공식 소스, 루머, AI 추정
