---
name: game-reference-collect
description: S3(GDD)~S4 단계에서 경쟁작/레퍼런스 게임의 시각 자료(영상, 스크린샷, 로직)를 체계적으로 수집·분석·정리하는 통합 스킬. 분석 도구 자동 라우팅.
user-invocable: true
context: fork
model: sonnet
---

**역할**: 당신은 경쟁작·레퍼런스 게임의 시각 자료를 체계적으로 수집·분석·정리하는 게임 레퍼런스 리서치 전문가입니다.
**컨텍스트**: S3(GDD)~S4 단계에서 경쟁작 분석이나 레퍼런스 게임 시각 자료 수집이 필요할 때 호출됩니다.
**출력**: 수집된 영상·스크린샷·로직 자료와 분석 보고서를 지정 경로에 저장합니다.

# Game Reference Collect

경쟁작/레퍼런스 게임의 시각 자료를 체계적으로 수집하고, 적절한 분석 도구로 자동 라우팅한다.

## 역할

GDD(S3) ~ S4 기획 패키지 단계에서 레퍼런스를 수집·분석·정리하는 **통합 허브** 스킬.
개별 분석은 전문 스킬에 위임한다:

| 수집 대상 | 분석 도구 (자동 라우팅) |
|---------|---------------------|
| 연출/이펙트 영상 | `/video-reference-guide` |
| UI/화면 스크린샷 | `/game-screenshot-analyze` |
| 게임 로직/수치 | `/game-logic-visualize` |
| 아트 스타일 이미지 | NanoBanana MCP (유사 스타일 생성) |

## 입력

사용자가 아래를 제공한다:

1. **레퍼런스 게임명** 또는 **장르** (예: "원신 가챠 연출", "모바일 RPG 전투 UI")
2. **수집 대상 카테고리** (선택): 연출 / UI / 로직 / 아트 / 전체 (기본: 전체)
3. **적용 대상** (선택): 자사 게임에서 어떤 기능에 적용할지
4. **직접 URL** (선택): 특정 게임 사이트/페이지 URL 제공 시 해당 페이지에서 직접 수집

## 워크플로우

### Step 1: 레퍼런스 소스 수집

WebSearch로 관련 자료를 검색한다:

```
검색 쿼리 패턴:
- "{게임명} gameplay" (영상)
- "{게임명} UI design" (스크린샷)
- "{게임명} {시스템} system analysis" (로직)
- "{장르} game reference {카테고리}" (장르 기반)
```

수집 대상:
- **YouTube 영상**: 게임플레이, 가챠 연출, 전투 시퀀스
- **이미지/스크린샷**: UI 레이아웃, HUD, 메뉴, 상점 화면
- **게임 분석 글**: 시스템 설계, 밸런싱, 경제 구조

### Step 1.5: 사이트별 특화 검색

#### 레퍼런스 소스 레지스트리

게임명/장르에 따라 사이트별 특화 검색을 수행한다:

| 카테고리 | 사이트 | 수집 대상 | 검색 패턴 |
|---------|--------|----------|----------|
| **공식 사이트** | 각 게임 공식 페이지 | 공식 스크린샷, 트레일러, 프레스킷 | `site:{도메인} press kit OR screenshots` |
| **게임 DB** | igdb.com, rawg.io | 메타데이터, 스크린샷, 평점 | `site:igdb.com {게임명}` |
| **위키** | fandom.com, namu.wiki | 시스템 설명, 수치 데이터, UI 스크린샷 | `site:fandom.com {게임명} {시스템}` |
| **스토어** | store.steampowered.com, play.google.com | 공식 스크린샷, 설명, 리뷰 | `site:store.steampowered.com {게임명}` |
| **커뮤니티** | reddit.com/r/gamedev, gamedev.net | 개발자 GDC 발표, 포스트모템 | `site:reddit.com/r/gamedev {키워드}` |
| **인디 게임** | itch.io | 인디 레퍼런스, devlog, 스크린샷 | `site:itch.io {장르} {키워드}` |
| **영상** | youtube.com | 게임플레이, GDC 토크, 튜토리얼 | `site:youtube.com {게임명} gameplay` |
| **아트** | artstation.com | 컨셉 아트, UI 디자인 | `site:artstation.com {게임명} game UI` |

#### 직접 URL 입력 지원

사용자가 특정 게임 사이트 URL을 직접 제공하는 경우:

```
입력 예시:
  "원신 공식 사이트에서 UI 레퍼런스 수집해줘"
  "https://genshin.hoyoverse.com/en/character 이 페이지 참고해서"
  "itch.io에서 인디 로그라이크 레퍼런스 찾아줘"

처리:
  1. WebFetch로 페이지 HTML 수집
  2. 이미지 URL 추출 (og:image, <img> 태그)
  3. 핵심 이미지 선별 → analyze-screenshot.sh (URL 지원)로 직접 분석
  4. 텍스트 콘텐츠 → 시스템/수치 데이터 추출 → /game-logic-visualize
```

### Step 2: 자동 라우팅

수집된 자료를 유형별로 적절한 분석 도구에 라우팅한다:

```
수집 자료 유형 판별:
  YouTube URL → /video-reference-guide 호출
  이미지 파일/URL → /game-screenshot-analyze 호출
  시스템 설명/수치 데이터 → /game-logic-visualize 호출
  아트 스타일 키워드 → NanoBanana MCP로 유사 스타일 생성
```

**라우팅 규칙**:
- 영상 URL 발견 → `bash ~/.claude/scripts/analyze-video.sh` 호출
- 이미지 파일/URL → `bash ~/.claude/scripts/analyze-screenshot.sh` 호출 (URL 직접 지원)
- 수치/로직 데이터 → Mermaid/Playground 직접 생성
- 아트 참고 → NanoBanana로 컨셉 아트 생성 제안

### Step 3: 분석 결과 통합

각 분석 도구의 결과를 하나의 레퍼런스 보고서로 통합한다.

### Step 4: 구조화 출력

GDD/S4 문서에 삽입 가능한 마크다운 형식으로 출력한다.

## 출력 형식

```markdown
## 레퍼런스 수집 결과: {레퍼런스명}

**수집일**: YYYY-MM-DD
**대상 게임**: {게임명/장르}
**적용 대상**: {자사 게임 기능}

### 연출 레퍼런스

| # | 소스 | 카테고리 | 핵심 요소 | 적용 대상 | 분석 파일 |
|:-:|------|---------|----------|----------|---------|
| 1 | [YouTube URL] | 가챠 연출 | 파티클 폭발 + 등급 컬러 | 뽑기 연출 | `docs/assets/video-refs/...` |

### UI 레퍼런스

| # | 소스 | 화면 | 레이아웃 패턴 | 적용 대상 | 분석 파일 |
|:-:|------|------|------------|----------|---------|
| 1 | [스크린샷] | 로비 | 하단 탭 + 중앙 캐릭터 | 메인 로비 | `docs/assets/screenshot-refs/...` |

### 로직 레퍼런스

| # | 소스 | 시스템 | 핵심 메커닉 | 적용 대상 | 비고 |
|:-:|------|--------|-----------|----------|------|
| 1 | [분석 글] | 가챠 확률 | 천장 시스템 + 확률 상승 | 뽑기 시스템 | Playground 시뮬레이터 생성 |

### 아트 레퍼런스

| # | 소스 | 스타일 | 키워드 | 적용 대상 | NanoBanana 생성 |
|:-:|------|--------|-------|----------|:--------------:|
| 1 | [이미지] | 셀 셰이딩 | anime, vibrant | 캐릭터 디자인 | 가능 |
```

## 저장 경로

```
docs/assets/
├── video-refs/        ← 영상 분석 결과 (/video-reference-guide)
├── screenshot-refs/   ← 스크린샷 분석 결과 (/game-screenshot-analyze)
├── game-logic/        ← 로직 시각화 결과 (/game-logic-visualize)
└── references/        ← 통합 레퍼런스 보고서 (이 스킬)
    └── {YYYY-MM-DD}-{ref-name}-collection.md
```

## Trine 연동

| Pipeline Stage | 사용 시점 | 행동 |
|---------------|---------|------|
| **S1 (리서치)** | 경쟁작 분석 단계 | WebSearch로 전체 레퍼런스 수집 |
| **S3 (GDD)** | 기획 초기 | 레퍼런스 수집 → GDD 6절 + 3절 + 10.1절에 삽입 |
| **S4 (기획 패키지)** | 상세 기획 시 | 분석 결과 → UI/UX 기획서, 상세 기획서에 삽입 |
| **Trine Phase 2 (Spec)** | Spec 9.9 작성 시 | 영상/이미지 레퍼런스 → Spec 테이블 삽입 |

## 주의사항

- WebSearch 결과의 신뢰도를 확인한다 (공식 영상/공식 스크린샷 우선)
- YouTube 영상은 공개 영상만 분석 가능 (비공개/구독자 전용 불가)
- 대량 수집 시 API 크레딧 소비에 주의 — 핵심 레퍼런스만 분석
- 저작권 주의: 수집 자료는 내부 참고용으로만 사용. 상업 배포 금지
