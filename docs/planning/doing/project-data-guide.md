# 프로젝트 쇼케이스 데이터 준비 가이드

프로젝트 쇼케이스에 실제 데이터를 등록하기 위한 가이드입니다.
이 문서에 맞춰 데이터를 정리해 주시면 AI가 시드 데이터를 생성합니다.

---

## 1. 이미지 규격

### 1.1 이미지 종류

| 종류 | 용도 | 권장 크기 | 비율 | 필수 여부 |
|------|------|----------|------|----------|
| **썸네일** | 목록 카드, OG 이미지 | 800 x 450 px | 16:9 | **필수** (프로젝트당 1장) |
| **갤러리 이미지** | 상세 페이지 갤러리 + 라이트박스 | 1920 x 1080 px | 16:9 | 선택 (0~10장) |

### 1.2 이미지 포맷

- **권장**: WebP (용량 대비 화질 최상)
- **허용**: PNG, JPG/JPEG
- **파일 크기**: 썸네일 200KB 이하, 갤러리 이미지 500KB 이하 권장

### 1.3 파일 네이밍 규칙

```
{프로젝트-slug}-thumbnail.webp        # 썸네일
{프로젝트-slug}-gallery-01.webp       # 갤러리 이미지 (01부터 순번)
{프로젝트-slug}-gallery-02.webp
```

**예시:**
```
ai-portfolio-platform-thumbnail.webp
ai-portfolio-platform-gallery-01.webp
ai-portfolio-platform-gallery-02.webp
ai-portfolio-platform-gallery-03.webp
```

### 1.4 이미지 제공 방법

이미지 파일을 다음 폴더에 넣어주세요:

```
docs/project-assets/{프로젝트-slug}/
  ├── thumbnail.webp
  ├── gallery-01.webp
  ├── gallery-02.webp
  └── ...
```

> **참고**: 최종 호스팅 URL은 배포 환경에 따라 결정됩니다. 이미지를 위 폴더에 넣어주시면 AI가 URL을 설정합니다.

---

## 2. JSON 데이터 템플릿

아래 템플릿을 복사하여 프로젝트별로 채워 주세요.
여러 프로젝트는 배열로 나열합니다.

```jsonc
[
  {
    // ── 기본 정보 (필수) ──
    "title": "프로젝트 제목",
    "slug": "project-slug",
    "description": "프로젝트를 1~2문장으로 설명합니다. 목록 카드에 표시됩니다.",
    "category": "web",
    "techStack": ["Next.js", "NestJS", "PostgreSQL", "Redis"],

    // ── 표시 설정 (필수) ──
    "isFeatured": true,
    "orderIndex": 1,

    // ── 링크 (선택) ──
    "githubUrl": "https://github.com/username/repo",
    "githubRepo": "username/repo",
    "demoUrl": "https://demo.example.com",

    // ── 메타데이터 (선택, 상세 페이지에 ROI 지표로 표시) ──
    "metadata": {
      "duration": "3개월",
      "team_size": 1,
      "impact": "응답 속도 50% 개선"
    },

    // ── 본문 Markdown (선택, 상세 페이지 본문) ──
    "content": "## 개요\n\n프로젝트 상세 설명...",

    // ── 갤러리 이미지 (선택) ──
    "images": [
      { "altText": "메인 대시보드 화면", "orderIndex": 0 },
      { "altText": "모바일 반응형 뷰", "orderIndex": 1 }
    ]
  }
]
```

---

## 3. 필드별 상세 규칙

### 3.1 필수 필드

| 필드 | 타입 | 제약 | 설명 |
|------|------|------|------|
| `title` | string | 최대 200자 | 프로젝트 이름 |
| `slug` | string | 영문 소문자 + 하이픈, 고유값 | URL에 사용 (`/projects/{slug}`) |
| `description` | string | 제한 없음 (2줄 이내 권장) | 카드에 표시되는 요약 설명 |
| `category` | string | `web` `mobile` `ai` `infrastructure` 중 택1 | 카테고리 필터에 사용 |
| `techStack` | string[] | 배열, 카드에 최대 4개 표시 (+N) | 사용 기술 목록 |
| `isFeatured` | boolean | `true` / `false` | 메인 페이지 featured 섹션 표시 여부 |
| `orderIndex` | number | 정수, 1부터 | 표시 순서 (낮을수록 먼저) |

### 3.2 선택 필드

| 필드 | 타입 | 제약 | 설명 |
|------|------|------|------|
| `githubUrl` | string | 유효 URL, 최대 500자 | GitHub 버튼 링크 |
| `githubRepo` | string | `owner/repo` 형식 | Phase 2 커밋 로그용 |
| `demoUrl` | string | 유효 URL, 최대 500자 | Live Demo 버튼 링크 |
| `metadata.duration` | string | 자유 형식 | 예: `"3개월"`, `"6 months"` |
| `metadata.team_size` | number | 정수 | 예: `1`, `4` |
| `metadata.impact` | string | 자유 형식 | 예: `"MAU 200% 증가"` |
| `content` | string | Markdown 형식 | 상세 페이지 본문 (아래 §4 참조) |
| `images` | array | 아래 §3.3 참조 | 갤러리 이미지 목록 |

### 3.3 갤러리 이미지

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `altText` | string | 권장 | 이미지 설명 (접근성 + SEO) |
| `orderIndex` | number | **필수** | 표시 순서 (0부터) |

> `url`은 이미지 파일 제공 후 AI가 설정합니다. 파일만 넣어주세요.

### 3.4 카테고리 값

| 값 | 표시명 | 용도 |
|----|--------|------|
| `web` | Web | 웹 애플리케이션 |
| `mobile` | Mobile | 모바일 앱 |
| `ai` | AI | AI/ML 프로젝트 |
| `infrastructure` | Infrastructure | DevOps, 인프라 |

---

## 4. Markdown 본문 (content) 작성 가이드

상세 페이지에서 `react-markdown` + `remark-gfm`으로 렌더링됩니다.

### 4.1 지원되는 문법

| 문법 | 지원 | 예시 |
|------|------|------|
| 제목 (h1~h3) | O | `## 제목` |
| 단락 | O | 빈 줄로 구분 |
| **볼드** / *이탤릭* | O | `**볼드**` / `*이탤릭*` |
| 순서/비순서 목록 | O | `- 항목` / `1. 항목` |
| 인용 | O | `> 인용문` |
| 인라인 코드 | O | `` `코드` `` |
| 코드 블록 (구문 강조) | O | ` ```typescript ` |
| 테이블 (GFM) | O | `| A | B |` |
| 취소선 (GFM) | O | `~~취소~~` |
| 링크 | O | `[텍스트](URL)` — 새 탭 열림 |
| 이미지 | X | 사용 금지 (갤러리 이미지로 대체) |

### 4.2 코드 블록 구문 강조

Prism 기반이므로 대부분의 언어를 지원합니다. 언어를 명시해 주세요:

````markdown
```typescript
const app = await NestFactory.create(AppModule);
await app.listen(3000);
```
````

### 4.3 권장 본문 구조

```markdown
## 개요

프로젝트가 해결하는 문제와 핵심 기능을 2~3문장으로 설명합니다.

## 주요 기능

- 기능 1: 설명
- 기능 2: 설명
- 기능 3: 설명

## 기술적 도전

구현 과정에서 해결한 기술적 난제를 설명합니다.

## 아키텍처

시스템 구조나 핵심 설계 결정을 설명합니다.

## 성과

측정 가능한 결과를 수치와 함께 정리합니다.
```

> **팁**: 본문이 없어도 됩니다. `content`를 비우면 상세 페이지에서 본문 섹션이 생략됩니다.

---

## 5. 작성 예시

```jsonc
[
  {
    "title": "AI 포트폴리오 플랫폼",
    "slug": "ai-portfolio-platform",
    "description": "AI 챗봇과 자동 견적서 생성 기능을 갖춘 풀스택 포트폴리오 웹 애플리케이션",
    "category": "web",
    "techStack": ["Next.js 14", "NestJS 10", "PostgreSQL", "Redis", "Claude API"],
    "isFeatured": true,
    "orderIndex": 1,
    "githubUrl": "https://github.com/username/portfolio",
    "githubRepo": "username/portfolio",
    "demoUrl": "https://portfolio.example.com",
    "metadata": {
      "duration": "3개월",
      "team_size": 1,
      "impact": "1인 개발, AI 기반 자동화로 견적 생성 시간 90% 단축"
    },
    "content": "## 개요\n\nAI를 활용한 포트폴리오 플랫폼입니다.\n\n## 주요 기능\n\n- AI 챗봇: Claude API 기반 대화형 포트폴리오 소개\n- 자동 견적서: 프로젝트 요구사항 분석 후 견적 자동 생성\n- 소스 분석: GitHub 리포지토리 코드 분석 및 시각화\n\n## 기술적 도전\n\n### 스트리밍 응답\n\nClaude API의 스트리밍 응답을 SSE로 클라이언트에 전달하는 구조를 설계했습니다.\n\n```typescript\nasync *streamChat(message: string) {\n  const stream = await this.claude.messages.stream({\n    model: 'claude-sonnet-4-6',\n    messages: [{ role: 'user', content: message }],\n  });\n  for await (const chunk of stream) {\n    yield chunk.delta?.text ?? '';\n  }\n}\n```\n\n## 성과\n\n- 평균 응답 시간 200ms 이하\n- Lighthouse 성능 점수 95+",
    "images": [
      { "altText": "메인 페이지 - 벤토 그리드 레이아웃", "orderIndex": 0 },
      { "altText": "AI 챗봇 대화 화면", "orderIndex": 1 },
      { "altText": "자동 견적서 생성 결과", "orderIndex": 2 }
    ]
  }
]
```

---

## 6. 제출 전 체크리스트

### 필수 항목

- [ ] 각 프로젝트에 `title`, `slug`, `description`, `category`, `techStack` 입력
- [ ] `slug`가 영문 소문자 + 하이픈으로만 구성됨
- [ ] `slug`가 프로젝트 간 중복되지 않음
- [ ] `category`가 `web` / `mobile` / `ai` / `infrastructure` 중 하나
- [ ] `isFeatured`와 `orderIndex` 설정됨
- [ ] 썸네일 이미지 1장 준비됨 (16:9 비율)

### 권장 항목

- [ ] `description`이 2줄 이내로 간결함
- [ ] `techStack`에 주요 기술 4~6개 포함
- [ ] `metadata`에 `duration`, `team_size`, `impact` 중 1개 이상 입력
- [ ] 갤러리 이미지에 `altText` 입력
- [ ] `content` Markdown 본문 작성 (§4.3 구조 참고)
- [ ] 이미지가 권장 크기 및 용량 이내

### 이미지 체크

- [ ] 썸네일: 800x450 / 16:9 / WebP 권장 / 200KB 이하
- [ ] 갤러리: 1920x1080 / 16:9 / WebP 권장 / 500KB 이하
- [ ] 파일이 `docs/project-assets/{slug}/` 폴더에 위치
