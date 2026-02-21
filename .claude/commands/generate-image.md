---
description: Generate or edit images using NanoBanana MCP (Google Gemini AI)
allowed-tools: Bash, Read, Task, Write
argument-hint: <mode: generate|edit> <prompt or image-path> [--model pro|normal] [--aspect 16:9|1:1|9:16] [--output path]
model: sonnet
---

# AI Image Generation / Editing (Business)

NanoBanana MCP를 사용하여 이미지를 생성하거나 편집합니다: $ARGUMENTS

## 사전 검증

1. `GOOGLE_API_KEY` 환경변수 확인:

NanoBanana MCP 도구(`generate_image` 또는 `edit_image`)를 직접 호출하여 연결 확인.

**사용 불가 시**: 아래 가이드를 출력하고 종료합니다.
```
[ERROR] NanoBanana MCP를 사용하려면 GOOGLE_API_KEY가 필요합니다.

설정 방법:
  1. Google AI Studio (https://aistudio.google.com/) 에서 API 키 발급
  2. 환경변수 설정:
     - Windows: setx GOOGLE_API_KEY "your-key"
     - Linux/Mac: export GOOGLE_API_KEY="your-key"
  3. Claude Code 재시작
```

## 모드

### `generate` — 텍스트에서 이미지 생성

NanoBanana의 `generate_image` 도구를 호출합니다.

**인자 파싱:**
- 첫 번째 인자: 프롬프트 텍스트
- `--model`: `pro` (고품질) 또는 `normal` (기본, 빠름)
- `--aspect`: `16:9` (히어로/배너), `1:1` (정사각), `9:16` (모바일)
- `--output`: 저장 경로 (기본: `05-design/portfolio/images/`)

**예시:**
```
/generate-image generate "포트폴리오 히어로 이미지, 미니멀 디자인, 파란 그라데이션" --aspect 16:9
/generate-image generate "AlbaNow 프로젝트 쇼케이스 썸네일" --aspect 1:1
/generate-image generate "마케팅 캠페인 배너, 모던 SaaS 스타일" --aspect 16:9 --output 03-marketing/assets/
```

### `edit` — 기존 이미지 편집

NanoBanana의 `edit_image` 도구를 호출합니다.

**인자 파싱:**
- 첫 번째 인자: 편집할 이미지 파일 경로
- 두 번째 인자: 편집 지시사항
- `--output`: 저장 경로 (기본: 원본과 같은 디렉토리, `-edited` 접미사)

**예시:**
```
/generate-image edit 05-design/portfolio/images/albanow/albanow-thumbnail.png "해상도 개선, 색감 보정"
/generate-image edit 03-marketing/assets/banner.png "텍스트 제거하고 배경만"
```

## 기본 출력 경로

| 용도 | 경로 |
|------|------|
| 포트폴리오 갤러리 | `05-design/portfolio/images/` |
| 마케팅 비주얼 | `03-marketing/assets/` |
| 블로그 이미지 | `04-content/images/` |
| 디자인 목업 | `05-design/mockups/` |

## 비용 원칙

- NanoBanana는 **부가 기능** — 검증 게이트에서 사용 금지
- 이미지 생성은 사용자 명시 요청 시에만 실행
- Business 워크스페이스에서는 `verify-image-quality.mjs` 미존재 — 생성 후 파일 크기/포맷만 수동 확인
