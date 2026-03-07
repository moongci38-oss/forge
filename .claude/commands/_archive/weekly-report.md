---
description: 주간 리서치 리포트 생성 — AI/게임/웹 개발 + 비즈니스 동향 + 사업 아이템 제안
allowed-tools: Read, Write, WebSearch, WebFetch, Glob
---

당신은 research-coordinator입니다. 지난 7일간의 주요 동향을 수집하고 주간 리포트를 작성합니다.

## 수행 절차

### 1. 기술 뉴스 수집 (최근 7일)

아래 영역별로 웹 검색합니다:

**AI 개발:**
- "AI agent" / "LLM" / "Claude" / "prompt engineering" / "RAG" / "MCP"
- AI SaaS 신제품, 오픈소스 AI 도구

**게임 개발:**
- "Unity" / "Unreal" / "indie game" / "게임 AI" / "프로시저럴 생성"
- 게임 엔진 업데이트, 인디 게임 트렌드

**웹 개발:**
- "Next.js" / "NestJS" / "React" / "TypeScript" 생태계
- 프레임워크 업데이트, 새 라이브러리

### 2. 비즈니스 뉴스 수집

- SaaS/스타트업 동향, 투자 라운드, M&A
- "Micro SaaS" / "solo founder" / "indie hacker" / "1인 기업"
- Product Hunt 이번 주 주목 제품

### 3. 사업 아이템 제안 (SIGIL S1 방식)

SIGIL S1 리서치 방법론을 적용합니다:
1. **경쟁 가설 3개** 수립 — 각각 웹 검색으로 근거 수집
2. **TAM/SAM/SOM 간이 추정** — 시장 규모 범위 제시
3. **최종 1개 선정** — 선정 기준: **1인 개발자가 내달 1,000만원+ 수익 달성 가능성**
4. **JTBD + Lean Validation** 관점 분석
5. **구체적 실행 로드맵** 포함 (MVP 범위, 기술 스택, 타임라인)

모든 데이터에 **신뢰도 등급** 표기:
- [High] = 다중 소스 일치 확인
- [Medium] = 단일 신뢰 소스
- [Low] = AI 추정 또는 비공식 소스

### 4. 액션 아이템

이번 주 동향 기반 다음 주 행동 3~5개 도출

### 5. 저장

`01-research/weekly/YYYY-WW-report.md` 형식으로 저장합니다.
(예: 2026-W10-report.md)

## 출력 형식

```
# YYYY-WW 주간 리서치 리포트
기간: YYYY-MM-DD ~ YYYY-MM-DD

## 1. 기술 뉴스
### 1.1 AI 개발
### 1.2 게임 개발
### 1.3 웹 개발

## 2. 비즈니스 뉴스
### 2.1 SaaS/스타트업
### 2.2 인디해커/1인기업
### 2.3 Product Hunt 주목 제품

## 3. 사업 아이템 제안
### 3.1 후보 3개 (경쟁 가설)
### 3.2 최종 선정 및 분석
### 3.3 실행 로드맵

## 4. 액션 아이템

## Sources
```
