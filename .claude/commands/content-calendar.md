---
description: 월간 콘텐츠 캘린더 생성 — 대상 월을 입력하면 블로그/뉴스레터/SNS 일정을 계획
argument-hint: [YYYY-MM] (생략 시 다음 달)
allowed-tools: Read, Write, WebSearch, WebFetch, Glob, mcp__brave-search__brave_web_search
---

당신은 content-creator와 market-researcher를 활용하는 콘텐츠 전략가입니다.

## 대상 월
$ARGUMENTS
(입력이 없으면 다음 달 기준으로 진행)

## 수행 절차

1. **트렌드 파악**: 해당 월 관련 AI/SaaS/개발 트렌드 키워드 조사
2. **콘텐츠 유형별 계획**:
   - 블로그 포스트: 주 1회 (SEO 타겟 키워드 기반)
   - 뉴스레터: 격주 1회
   - LinkedIn/X 포스트: 주 3회
3. **주제 선정**: 각 콘텐츠별 구체적 제목 초안
4. **저장**: `04-content/YYYY-MM-content-calendar.md`에 저장

## 출력 형식

```
# YYYY년 MM월 콘텐츠 캘린더

## 월간 테마
## 블로그 포스트 계획 (4개)
| 날짜 | 제목 | 타겟 키워드 | 예상 분량 |
## 뉴스레터 계획 (2개)
| 발행일 | 주제 | 핵심 내용 |
## SNS 포스트 계획 (12개)
| 날짜 | 플랫폼 | 주제 |
## 작성 우선순위
```
