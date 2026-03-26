---
title: "콘텐츠 품질 기준"
id: content-quality
impact: MEDIUM
scope: [always]
tags: [content, quality, curation, ai-verification]
section: core
audience: all
impactDescription: "AI 생성 콘텐츠의 품질 미검증 시 브랜드 신뢰도 하락, 사실 오류 발행"
enforcement: flexible
---

# 콘텐츠 품질 기준

> `content-creator` 스킬의 기본 기준(SEO 75점+, 브랜드 음성 일관성)을 확장.
> AI 생성 콘텐츠 검증 절차 + 유형별 품질 기준 추가.

## AI 생성 콘텐츠 검증 절차

```
AI 생성 → 사실 검증 → 품질 체크 → Human 확인 → 발행
```

| 단계 | 검증 항목 | 도구/방법 |
|------|---------|---------|
| 사실 검증 | 수치·날짜·인용이 정확한가 | WebSearch로 교차 확인 |
| 품질 체크 | 아래 유형별 기준 충족 여부 | AI 자체 검증 |
| Human 확인 | 톤·맥락·민감도 최종 점검 | Human 검토 |

## 유형별 품질 기준

### 블로그/기술 글

| 항목 | 기준 |
|------|------|
| SEO 점수 | 75/100 이상 (`content-creator` 기준 유지) |
| 분량 | 1,500-2,500자 (종합 글), 800-1,200자 (짧은 글) |
| 구조 | H2 3개 이상, 핵심 메시지가 첫 2문단에 포함 |
| 출처 | 외부 데이터 인용 시 URL + 날짜 필수 |
| CTA | 글 말미에 명확한 행동 유도 1개 |

### 뉴스레터/주간 리포트

| 항목 | 기준 |
|------|------|
| 요약 | Executive Summary 3줄 이내 (본문 읽지 않아도 핵심 파악) |
| 항목 수 | 핵심 3-5개 (과다 나열 금지) |
| 실행 가능성 | 각 항목에 "그래서 뭘 하라는 건지" 액션 포함 |
| 시의성 | 7일 이내 정보만 포함 (오래된 뉴스 배제) |

### 마케팅 문구 (SNS/광고)

| 항목 | 기준 |
|------|------|
| 길이 | 플랫폼별 최적 길이 준수 (`content-creator` 참조) |
| 톤 | 프로젝트 컨텍스트 브리프의 톤앤매너 일치 |
| 금지 표현 | 브리프의 금지 표현 목록 위반 없음 |
| 과장 | "혁신적", "최고의", "완벽한" 등 검증 불가 수식어 금지 |

## Do

- AI 생성 콘텐츠에 사실 검증 단계를 적용한다
- 유형별 품질 기준을 콘텐츠 작성 전 확인한다
- 프로젝트 컨텍스트 브리프가 있으면 톤/금지 표현을 참조한다

## Don't

- 사실 검증 없이 수치/날짜가 포함된 콘텐츠를 발행하지 않는다
- Executive Summary 없이 뉴스레터를 작성하지 않는다
- 검증 불가 수식어("최고의", "혁신적")를 근거 없이 사용하지 않는다

## AI Diligence Statement (투명성 고지)

> AI Fluency Framework의 Diligence 역량 기반. 모든 AI 생성/공동 작성 산출물에 투명성 고지를 포함한다.

### 적용 대상

| 산출물 유형 | 고지 필수 | 방식 |
|------------|:--------:|------|
| Git commit | 필수 | `Co-Authored-By: Claude {model} <noreply@anthropic.com>` |
| 기획서 (PRD/GDD/상세기획서) | 필수 | 문서 말미 AI Diligence Statement 섹션 |
| Spec/개발 계획 | 필수 | 문서 말미 AI Diligence Statement 섹션 |
| 리서치 리포트/분석 | 필수 | 문서 말미 AI Diligence Statement 섹션 |
| 블로그/뉴스레터/마케팅 | 권장 | 본문 또는 메타데이터에 고지 |
| 내부 메모/임시 문서 | 선택 | 생략 가능 |

### 표준 고지 문구

```markdown
---
## AI Diligence Statement
이 문서는 AI 도구(Claude, Anthropic)를 활용하여 작성되었습니다.
Human 작성자가 비전, 전문 지식, 비판적 판단을 제공하고 최종 검증·승인했습니다.
```

### AI 행동 규칙

- 기획서/Spec/개발 계획/리포트 작성 완료 시 문서 말미에 AI Diligence Statement를 자동 삽입한다
- Human이 명시적으로 제외를 요청한 경우 생략한다
- 고지 문구는 문서의 마지막 섹션으로 배치한다 (본문 흐름을 방해하지 않음)
