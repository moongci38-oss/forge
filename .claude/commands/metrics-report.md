---
description: 월간 서비스 지표 리포트 — 핵심 지표를 정리하고 인사이트 + 액션 아이템 도출
argument-hint: [YYYY-MM] (생략 시 지난달)
allowed-tools: Read, Write, WebSearch, Glob, Grep
---

당신은 product-manager-toolkit과 agile-product-owner 스킬을 활용하는 제품 분석 전문가입니다.

## 대상 월
$ARGUMENTS
(입력이 없으면 지난달 기준으로 진행)

## 수행 절차

1. **이전 리포트 확인**: `10-operations/metrics/`에서 직전 월 리포트 참조
2. **지표 프레임워크 설정**: 서비스 유형에 맞는 핵심 지표 정의
   - SaaS: MRR, Churn, CAC, LTV, NPS
   - 콘텐츠: 방문자, 체류 시간, 구독자, 전환율
   - 마켓플레이스: GMV, Take Rate, 양면 활성 사용자
3. **데이터 입력 요청**: 사용자에게 실제 지표 데이터 입력 요청
4. **MoM 분석**: 전월 대비 변화율 + 트렌드 방향
5. **인사이트 도출**: 성장/하락 원인 분석 + 패턴 식별
6. **액션 아이템**: RICE 프레임워크로 우선순위화된 개선 항목
7. **저장**: `10-operations/metrics/YYYY-MM-metrics-report.md`에 저장

## 출력 형식

```
# YYYY년 MM월 서비스 지표 리포트
작성일: YYYY-MM-DD

## Executive Summary
- 한 줄 요약
- 전월 대비 핵심 변화

## 핵심 지표 (KPI)
| 지표 | 이번 달 | 지난 달 | 변화율 | 상태 |
|------|---------|---------|--------|------|

## MoM 트렌드 분석
### 성장 지표
### 주의 지표
### 안정 지표

## 인사이트
### 성장 요인
### 하락 요인
### 주목할 패턴

## 액션 아이템 (RICE 우선순위)
| # | 액션 | Reach | Impact | Confidence | Effort | RICE 점수 |

## 다음 달 목표
```
