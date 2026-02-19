# Portfolio 데이터 추출 자동화

**작성일**: 2026-02-18
**상태**: 실행 대기

---

## Context

포트폴리오 사이트 제작을 위해 `E:\portfolio_project` 의 프로젝트들을 자동 발견하고
기술스택·기능·설명·이미지를 정제된 형태로 추출한다.

**요구사항**:
- 병렬 자동화 (발견된 프로젝트 동시 분석)
- 정확하고 풍부한 데이터 — 기술스택 카테고리별 상세 기술
- 컨텍스트 최소화 — 에이전트는 파일 저장 후 "DONE" 1줄만 반환
- 자체 검증 — 품질 기준 미달 섹션 자동 재작성
- 즉시 사용 가능 — 포트폴리오 사이트에서 바로 import 가능한 포맷

---

## 구축 완료된 파일

| 파일 | 역할 |
|------|------|
| `.claude/agents/portfolio-analyzer.md` | 프로젝트 분석 → JSON 저장 |
| `.claude/agents/portfolio-content-writer.md` | JSON → .md 카드 + index.json + 자체검증 |
| `.claude/agents/portfolio-image-extractor.md` | 이미지 추출 보조 |
| `.claude/commands/portfolio-analyze.md` | `/portfolio-analyze` 슬래시 커맨드 |
| `09-tools/scripts/extract-portfolio-images.ps1` | 이미지 추출 PS 스크립트 |

---

## 프로젝트 목록 (자동 발견)

Step 0에서 `E:\portfolio_project` 폴더를 스캔하여 동적으로 수집한다.
아래는 현재 확인된 예시 목록이며, 실행 시 실제 폴더 기준으로 재발견된다.

| # | 폴더명 | project_id | 추정 타입 |
|---|--------|-----------|---------|
| 1 | albanow | albanow | React Native 모바일 |
| 2 | clayon source | clayon-source | VDI/Java |
| 3 | Crawling | crawling | Java Maven 크롤러 |
| 4 | exchange_kodaqs | exchange-kodaqs | Java 거래 플랫폼 |
| 5 | mukja | mukja | Android + 서버 |
| 6 | NCLSource | ncl-source | Java 서버 프레임워크 |
| 7 | nice_i | nice-i | BizDemoServer |
| 8 | pin_key | pin-key | PHP CodeIgniter |
| 9 | samsungmall | samsungmall | Java Maven 쇼핑몰 |
| 10 | SmartDoor | smart-door | IoT 도어 시스템 |
| 11 | starmario-develop | starmario | 게임 |

---

## 실행 파이프라인

```
Step 0: 프로젝트 자동 발견
  └─ E:\portfolio_project 폴더 스캔
      ├─ _ 로 시작하는 폴더 제외 (_portfolio-data 등)
      └─ 폴더명 → kebab-case 변환 (공백→-, 대문자→소문자, _→-)

Step 1: 출력 디렉토리 생성
  └─ 05-design/portfolio/ 하위 폴더 일괄 생성

Step 2: 동시 실행 (하나의 메시지에서)
  ├─ Task: portfolio-analyzer × N (병렬)
  │   └─ 각 에이전트: 폴더 분석 → _analysis/{id}.json 저장 → "DONE" 반환
  └─ Bash: extract-portfolio-images.ps1 (PS 병렬 잡)
      └─ 이미지 복사 → _analysis/{id}-images.json 저장

Step 3: 완료 확인 (파일 존재 여부 체크)

Step 4: portfolio-content-writer (단일 에이전트)
  └─ _analysis/*.json 읽기
      → projects/{id}.md 생성 (자체검증 포함)
      → index.json 생성
```

### 컨텍스트 최소화 전략
- 분석기 N개 × "DONE: {id}.json saved" = ~110 토큰/프로젝트
- 이미지 추출은 PS 스크립트 (AI 컨텍스트 0)
- content-writer 검증은 자체 컨텍스트 내부에서만 수행

---

## 출력 구조

```
Z:\home\damools\business\05-design\portfolio\
├── index.json
├── projects\
│   ├── albanow.md
│   └── ... (발견된 프로젝트 수)
└── images\
    ├── albanow\
    └── ... (프로젝트별)
```

### .md 카드 구조
```yaml
---
title: "AlbaNow"
subtitle: "Part-time Job Matching App"
description_ko: "알바생과 사장님을 연결하는 위치 기반 모바일 매칭 플랫폼"
period: "미상"
type: mobile
role: "개인 프로젝트"
techStack:
  - React Native 0.70
  - Node.js + Express
  - MongoDB
features_ko:
  - 위치 기반 알바 공고 탐색 및 필터링
  - 카카오 OAuth 소셜 로그인
images:
  - images/albanow/screenshot1.png
---

# {title_en}
> {subtitle_en}

## 프로젝트 개요
(1문단: 배경 및 해결 문제, 2문단: 핵심 기술 선택, 3문단: 결과/학습 포인트)

## 기술 스택
(카테고리별 테이블 — Frontend / Backend / Database / DevOps & Tools)

## 핵심 기능
(기능명 ### 소제목 + 2~3문장, "어떤 가치를 제공하는가" 관점)

## 시스템 아키텍처
(architecture.pattern + 폴더/모듈 구조 ASCII tree 또는 목록으로 시각화)

## Technical Challenges
(도전 → 해결 구조, 구체적 기술 용어 사용)

*{role} | {type} | {period}*
```

### index.json 스키마
```json
{
  "generated": "2026-02-18",
  "total": 11,
  "projects": [{
    "id": "albanow",
    "title": "AlbaNow",
    "subtitle": "Part-time Job Matching App",
    "description_ko": "알바생과 사장님을 연결하는 위치 기반 모바일 매칭 플랫폼",
    "type": "mobile",
    "techStack": ["React Native", "Node.js", "MongoDB"],
    "thumbnail": "images/albanow/screenshot.png",
    "mdPath": "projects/albanow.md",
    "period": "미상",
    "role": "개인 프로젝트"
  }]
}
```

---

## 자체 검증 루브릭

| 항목 | 최소 기준 | 재작성 조건 |
|------|---------|-----------|
| 기술스택 완성도 | 8/10 | 카테고리 분류 또는 역할 설명 누락 |
| 프로젝트 개요 | 7/10 | 2문단 미만 또는 단순 나열 |
| 핵심 기능 | 7/10 | 가치 중심 서술 없음 |
| 기술 도전 | 7/10 | 도전→해결 구조 없음 |
| 시스템 아키텍처 | 7/10 | 구조 시각화 또는 흐름 설명 누락 |
| 정확성 | 9/10 | JSON에 없는 내용 추가 |

---

## 오류 처리

- 개별 프로젝트 분석 실패 시: 해당 프로젝트만 재시도 (전체 재실행 금지)
- JSON 파싱 오류: 원본 프로젝트 폴더 재분석
- 이미지 복사 실패: 빈 이미지 배열로 진행 (문서 생성 블로킹 금지)

## 최종 보고 형식

```
=== Portfolio Data 생성 완료 ===
마크다운 카드: 11개
이미지 파일: 37개

--- 프로젝트 목록 ---
🖼 [mobile   ] AlbaNow — React Native, Node.js, MongoDB
   [tool     ] Crawling — Java, Maven, Jsoup
...
```

---

## 제약사항

- 압축파일(zip, tar, gz, rar) 분석/추출 금지
- node_modules, .git, dist, build, target 폴더 제외
- nice_i의 BizDemoServer.zip → 폴더 구조만 분석
- starmario-develop 폴더만 분석 (.tar 파생 파일 무시)
- GitHub/배포 URL 없음 (프라이빗 프로젝트)

---

## 재실행 방법

```
/portfolio-analyze
```

---

## 검증 완료 기준

1. `05-design/portfolio/projects/` → 발견된 프로젝트 수만큼 .md 파일 존재
2. 각 .md: frontmatter에 techStack 배열 + 본문에 기술스택 테이블 포함
3. `05-design/portfolio/index.json` → 올바른 스키마, description_ko 포함
4. `05-design/portfolio/images/` → 원본 이미지 복사 확인
5. content-writer 자체검증 모든 항목 기준 통과

---

## 진행 상태

- [x] Step 0: 프로젝트 자동 발견 — 11개 발견
- [x] Step 1: 출력 디렉토리 생성
- [x] Step 2: 병렬 분석 + 이미지 추출 — _analysis/11×{id}.json + 11×{id}-images.json
- [x] Step 3: 완료 확인
- [x] Step 4: projects.json 생성 + images 배열 보정 (매니페스트 기준 10장/프로젝트)
- [x] 완료 → `docs/planning/done/` 으로 이동

## 최종 결과

| 항목 | 값 |
|------|-----|
| 프로젝트 수 | 11개 |
| projects.json | ✅ `05-design/portfolio/projects.json` |
| 이미지 폴더 | ✅ `05-design/portfolio/images/` (대부분 gallery-01~10) |
| 분석 JSON | ✅ `05-design/portfolio/_analysis/` |
| 완료일 | 2026-02-18 |
