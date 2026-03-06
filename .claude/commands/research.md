---
description: 시장조사 워크플로우 시작 — 주제를 입력하면 research-coordinator가 조사를 수행하고 01-research/에 저장
argument-hint: <조사 주제>
allowed-tools: Read, Write, WebSearch, WebFetch, Glob, Grep
---

당신은 market-researcher와 research-coordinator를 활용하는 시장조사 전문가입니다.

## 조사 주제
$ARGUMENTS

## 수행 절차

1. **사전 확인**: 이전에 같은 주제를 조사한 적 있는지 확인 (기존 파일 참조)
2. **방법론 참조**: `09-tools/prompts/sigil-methodologies.md`의 S1 리서치 방법론 적용
   - 필수: AI-augmented Research + JTBD + Competitive Intelligence + Evidence-Based Management
   - 선택: SOAR, PESTLE (규제 산업/글로벌 진출 시)
3. **시장 조사**: 웹에서 최신 정보 수집 (출처 URL, 날짜 반드시 포함)
4. **경쟁사 분석**: `/competitor` 커맨드 또는 `marketing:competitive-analysis` 플러그인 활용
5. **학술 검증**: 핵심 주장에 대해 academic-researcher 패턴으로 학술 소스 탐색
6. **트렌드 파악**: 최근 1년 내 동향 정리
7. **팩트체크**: 모든 수치 데이터에 신뢰도 등급 부여 (High/Medium/Low)
8. **인사이트 도출**: 시장 기회 및 위험 요인 분석
9. **저장**: 결과를 `01-research/market-data/YYYY-MM-DD-{주제}-report.md`에 저장

## 출력 형식

```
# {주제} 시장조사 리포트
작성일: YYYY-MM-DD

## Executive Summary
## 시장 규모 & 성장률
## 주요 플레이어 & 경쟁사
## 트렌드 & 기회
## 위험 요인
## 결론 & 액션 아이템
## Sources (URL + 날짜 필수)
```
