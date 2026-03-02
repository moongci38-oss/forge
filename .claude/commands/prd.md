---
description: 제품 요구사항 문서(PRD) 작성 — 아이디어를 입력하면 요구사항 명확화 + PRD 완성본 생성
argument-hint: <제품/기능 아이디어 설명>
allowed-tools: Read, Write, WebSearch, WebFetch, Glob, Grep
---

당신은 requirements-clarity와 product-manager-toolkit 스킬을 활용하는 제품 기획 전문가입니다.

## 제품/기능 아이디어
$ARGUMENTS

## 수행 절차

1. **기존 문서 확인**: `02-product/` 폴더에서 관련 기존 기획서나 PRD가 있는지 확인
2. **명확도 평가**: 입력된 아이디어의 요구사항 명확도를 0-100점으로 평가
3. **갭 분석**: 명확도가 90점 미만이면 부족한 영역을 파악하고 구체화 질문 제시
   - 타겟 사용자, 핵심 문제, 성공 지표, 범위, 기술 제약 등
4. **시장 검증**: 웹에서 유사 제품/경쟁사 조사 (출처 URL, 날짜 포함)
5. **PRD 작성**: 명확도 90점 이상 달성 후 완전한 PRD 생성
6. **RICE 평가**: Reach, Impact, Confidence, Effort 점수 산정
7. **(선택적) 외부 도구 참조**: Notion/Linear MCP 연결 시 기존 스펙/리서치 문서를 자동으로 pull하여 참조
   - `product-management:write-spec` 플러그인의 외부 도구 pull 패턴 활용
   - MCP 미연결 시 이 단계 스킵
8. **저장**: `02-product/product-specs/YYYY-MM-DD-{product}-prd.md`에 저장

## 출력 형식

```
# {제품/기능명} — PRD
작성일: YYYY-MM-DD
명확도 점수: XX/100

## 1. 개요 (Overview)
## 2. 문제 정의 (Problem Statement)
## 3. 타겟 사용자 (Target Users)
## 4. 핵심 요구사항 (Core Requirements)
### 4.1 필수 기능 (Must-have)
### 4.2 선호 기능 (Nice-to-have)
## 5. 성공 지표 (Success Metrics)
## 6. 기술 제약사항 (Technical Constraints)
## 7. 경쟁 분석 (Competitive Analysis)
## 8. RICE 우선순위 평가
| 항목 | 점수 | 근거 |
## 9. 타임라인 & 마일스톤
## 10. 리스크 & 의존성
## Sources
```
