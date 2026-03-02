---
title: "크로스 프로젝트 파이프라인"
id: cross-project-pipeline
impact: MEDIUM
scope: [always]
tags: [cross-project, pipeline, handoff]
section: cross-project
audience: dev
impactDescription: "핸드오프 문서 미작성 시 개발팀이 기획 의도 파악 불가. 역할 분리 위반 시 BUSINESS에서 코드 변경 → 충돌"
enforcement: flexible
---

# 크로스 프로젝트 파이프라인

## 개요
BUSINESS(비개발 리서치/콘텐츠) ↔ 개발 프로젝트(Portfolio/GodBlade) 간 양방향 데이터 흐름.

## 공유 저장소
`10-operations/` 폴더가 양방향 파이프라인의 허브 역할:

```
10-operations/
├── handoff-to-dev/       # BUSINESS → 개발팀 (기획서, 요구사항, 디자인)
│   ├── portfolio/        # Portfolio 프로젝트 전달 문서
│   └── godblade/         # GodBlade 프로젝트 전달 문서
├── handoff-from-dev/     # 개발팀 → BUSINESS (릴리즈노트, 기술문서, 데모)
│   ├── portfolio/
│   └── godblade/
└── shared-assets/        # 공유 자산 (이미지, 브랜딩, 용어집)
```

## 데이터 흐름

### BUSINESS → 개발 (비개발자 → 개발자)
| 산출물 | 출발 | 도착 | 형식 |
|--------|------|------|------|
| 시장조사 결과 | `01-research/` | `10-operations/handoff-to-dev/` | Markdown |
| 제품 기획서 (PRD) | `02-product/` | `10-operations/handoff-to-dev/` | Markdown |
| 디자인 시안 | `05-design/` | `10-operations/handoff-to-dev/` | PNG/Figma URL |
| 콘텐츠 원고 | `04-content/` | `10-operations/handoff-to-dev/` | Markdown |

### 개발 → BUSINESS (개발자 → 비개발자)
| 산출물 | 출발 | 도착 | 형식 |
|--------|------|------|------|
| 릴리즈 노트 | 개발 프로젝트 | `10-operations/handoff-from-dev/` | Markdown |
| 기술 제약사항 | 개발 프로젝트 | `10-operations/handoff-from-dev/` | Markdown |
| 데모 스크린샷 | 개발 프로젝트 | `10-operations/handoff-from-dev/` | PNG |
| API 문서 (비기술 요약) | 개발 프로젝트 | `10-operations/handoff-from-dev/` | Markdown |

## MCP 연결
- Filesystem MCP가 `Z:/home/damools/business/` + `E:/portfolio_project` 접근 가능
- 개발 프로젝트에서 BUSINESS 파이프라인 폴더 읽기 가능 (쓰기는 BUSINESS에서만)

## 역할 분리
| 역할 | BUSINESS 환경 | 개발 프로젝트 환경 |
|------|-------------|----------------|
| 리서치/기획 | 직접 수행 | 참조만 |
| 코드 개발 | 금지 | 직접 수행 |
| 파이프라인 문서 작성 | handoff-to-dev | handoff-from-dev |
| 파이프라인 문서 읽기 | handoff-from-dev | handoff-to-dev |
