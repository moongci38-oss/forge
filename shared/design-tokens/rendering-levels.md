# 렌더링 레벨 가이드 (Rendering Quality Levels)

> 이미지/다이어그램/슬라이드의 비주얼 품질 단계를 정의한다.
> 프로젝트 style-guide에서 레벨을 선택하면, soul-prompt-craft / pptx / 이미지 설계도에서 해당 키워드를 자동 주입한다.

---

## 레벨 정의

| Level | 이름 | 핵심 키워드 | 적합 용도 |
|:-----:|------|-----------|----------|
| **L1** | Flat 2D | 단색 도형, 선형 화살표, 텍스트 라벨 | 내부 메모, 초안, 와이어프레임 |
| **L2** | Soft 3D | 드롭섀도우, 그라데이션 배경, 둥근 모서리 | 일반 기획서, 내부 보고서 |
| **L3** | Premium Glassmorphism | 글래스모피즘, 백드롭 블러, 글로우 화살표, 레이어 그림자, 그리드 패턴 | **정부과제 R&D, 투자 IR, 공식 제안서** |
| **L3.5a** | Isometric Illustration | 45도 아이소메트릭, 미니어처 블록, 컬러풀 입체 | 기술 아키텍처, 인프라 도해 |
| **L3.5b** | Infographic Editorial | 잡지/보고서 스타일, 데이터 시각화 중심, 수치 강조 타이포 | 시장 분석, KPI 대시보드, 데이터 중심 슬라이드 |
| **L3.5c** | Neon Blueprint | 다크 배경, 청사진 그리드, 네온 라인, 테크 감성 | 기술 데모, 해커톤, 개발자 대상 발표 |
| **L3.5d** | Claymorphism | 점토/플레이도 질감, 소프트 3D, 둥글둥글한 형태 | 캐주얼 앱, 교육 콘텐츠, 친근한 톤 |
| **L3.5e** | Paper Craft / Layered | 종이 컷아웃 레이어, 그림자 깊이, 핸드메이드 질감 | 크리에이티브 포트폴리오, 문화 콘텐츠 |
| **L4** | Cinematic 3D | 메탈릭/카본 텍스처, 환경광(HDRI), 네온 엣지, DOF 블러 | 제품 런칭, 프리미엄 IR, 테크 키노트 |
| **L5** | Rendered 3D | Blender/C4D 수준, 실사 렌더링, PBR 머티리얼 | 제품 비주얼, 게임 트레일러, 영상 제작 |

---

## 레벨별 프롬프트 키워드 사전

### L1 — Flat 2D
```
flat design, solid colors, simple shapes, no shadows, clean lines,
minimal illustration, vector style, white background
```

### L2 — Soft 3D
```
soft drop shadow, subtle gradient background, rounded corners,
light 3D effect, clean modern design, slight depth
```

### L3 — Premium Glassmorphism
```
glassmorphism, frosted glass effect, backdrop blur, thin white border,
soft gradient background (white to light gray), subtle grid pattern,
curved glow flow arrows, layered depth shadows, line icons 2px stroke round cap,
gradient text (primary-blue to deep-navy), inner subtle glow on hub elements
```

### L3.5a — Isometric Illustration
```
isometric view, 30-degree angle, 3D block illustration, colorful isometric,
miniature scene, dimetric projection, clean isometric grid,
subtle shadow beneath blocks, consistent light from top-left
```

### L3.5b — Infographic Editorial
```
editorial infographic style, magazine layout, data visualization focus,
bold typography for numbers, clean chart design, accent color highlights,
professional report aesthetic, structured grid layout, metric callout boxes
```

### L3.5c — Neon Blueprint
```
dark background (#0a0a1a), blueprint grid lines, neon glow outlines,
cyan and electric blue accents, tech aesthetic, circuit board pattern,
glowing data flow lines, holographic elements, HUD-style labels
```

### L3.5d — Claymorphism
```
clay 3D style, soft rounded shapes, pastel colors, playful 3D,
matte clay texture, gentle shadows, toy-like appearance,
smooth organic forms, cheerful aesthetic
```

### L3.5e — Paper Craft / Layered
```
paper cutout style, layered paper depth, craft paper texture,
handmade aesthetic, paper shadow layers, cardboard elements,
warm natural tones, scissor-cut edges, collage composition
```

### L4 — Cinematic 3D
```
cinematic 3D render, metallic texture, carbon fiber surface,
HDRI environment lighting, neon edge lighting, depth of field blur,
reflective surfaces, volumetric light, dramatic shadows,
professional product visualization, dark mode with glowing elements
```

### L5 — Rendered 3D
```
Blender/C4D quality render, PBR materials, ray-traced lighting,
photorealistic 3D, physically accurate reflections, subsurface scattering,
global illumination, micro-detail textures, studio HDRI backdrop
```

---

## 적용 매트릭스: Tier × Level

에셋 중요도(Tier)와 렌더링 레벨(Level)의 조합 가이드:

| | T1 핵심 | T2 주요 | T3 대량 |
|---|:---:|:---:|:---:|
| **L1 Flat** | — | — | ✅ 초안/와이어프레임 |
| **L2 Soft** | — | ✅ 내부 문서 | ✅ 대량 다이어그램 |
| **L3 Premium** | ✅ 제안서 메인 | ✅ 제안서 보조 | — |
| **L3.5x 변형** | ✅ 특화 용도 | ✅ 특화 용도 | — |
| **L4 Cinematic** | ✅ IR/키노트 메인 | — | — |
| **L5 Rendered** | ✅ 영상/제품 | — | — |

---

## 용도별 권장 레벨

| 용도 | 권장 레벨 | 비고 |
|------|:-------:|------|
| 정부과제 R&D 계획서 | **L3** | 가독성 + 전문성 밸런스 최적 |
| 정부과제 데이터 중심 장 | **L3.5b** | 수치 강조가 중요한 섹션 |
| 투자 IR 덱 (PPTX) | **L3 ~ L4** | 청중 수준에 따라 |
| 사업 제안서 (PPTX) | **L3** | 공식 문서 표준 |
| 기술 아키텍처 발표 | **L3.5a** 또는 **L3.5c** | 대상이 개발자면 L3.5c |
| 내부 기획서 | **L2** | 속도 우선 |
| 게임 에셋 | **L4 ~ L5** | 게임 내 사용 에셋 |
| 마케팅 콘텐츠 | **L3.5d/e** 또는 **L4** | 톤에 따라 선택 |

---

## PPTX 슬라이드 적용 규칙

PPTX 생성 시 렌더링 레벨에 따라 슬라이드 비주얼 요소를 차등 적용한다:

| 슬라이드 요소 | L2 | L3 | L3.5x | L4 |
|------------|:--:|:--:|:-----:|:--:|
| **배경** | 단색/단순 그라데이션 | 소프트 그라데이션 + 미세 패턴 | 레벨별 특화 배경 | 다크 + 환경광 |
| **도형/카드** | 단순 둥근 사각형 | 글래스모피즘 효과 | 레벨별 특화 질감 | 메탈릭/리플렉션 |
| **아이콘** | 기본 라인 아이콘 | 통일 라인 2px + 글로우 | 레벨별 아이콘 스타일 | 3D 렌더 아이콘 |
| **화살표/연결선** | 직선 + 단색 | 곡선 + 글로우 이펙트 | 레벨별 특화 | 네온/볼류메트릭 |
| **타이포** | 단색 텍스트 | 그라데이션 제목 | 레벨별 특화 | 메탈릭/글로우 텍스트 |
| **다이어그램 이미지** | 도형으로 직접 구성 | NanoBanana L3 생성 삽입 | NanoBanana 레벨별 생성 | NanoBanana L4 생성 |
| **NanoBanana 프롬프트** | 해당 없음 | L3 키워드 사전 적용 | L3.5x 키워드 사전 적용 | L4 키워드 사전 적용 |

### PPTX 슬라이드 유형별 레벨 적용

| 슬라이드 유형 | 권장 처리 |
|------------|---------|
| 표지/섹션 구분 | NanoBanana 배경 이미지 (선택 레벨) |
| 개념도/아키텍처 | NanoBanana 다이어그램 (선택 레벨) |
| 데이터/차트 | python-pptx 차트 + 레벨별 컬러 스킴 |
| 타임라인/로드맵 | NanoBanana 또는 도형 조합 (선택 레벨) |
| 비교/매트릭스 | 테이블 + 레벨별 셀 스타일 |
| CTA/마무리 | NanoBanana 배경 + 브랜드 비주얼 |

---

## 출력 채널별 레벨 해석

렌더링 레벨은 NanoBanana 이미지뿐 아니라 모든 비주얼 출력 채널에 적용된다.

### Draw.io 다이어그램

| Level | 스타일 적용 |
|:-----:|---------|
| L1 | 기본 도형, 단색 fill, 직선 화살표 |
| L2 | rounded 도형, 그라데이션 fill, 그림자 |
| L3 | 글래스모피즘 효과 (반투명 fill + 블러 시뮬레이션), 곡선 화살표, 레이어 그림자, 그리드 배경 |
| L3.5c | 다크 배경 + 네온 컬러 stroke, 글로우 효과 |

### ASCII Art 설계도

이미지 생성 전 설계도의 상세도를 레벨에 맞춰 차등 작성한다.

| Level | ASCII 상세도 | 포함 정보 |
|:-----:|:----------:|---------|
| L1 | 최소 | 블록명 + 화살표 방향만 |
| L2 | 기본 | 블록명 + 내부 텍스트 + 연결 방향 |
| L3 | 상세 | 블록명 + 내부 텍스트 + 컬러 지정 + 아이콘 힌트 + 레이아웃 좌표 + 비주얼 가이드 테이블 |
| L4+ | 최대 | L3 + 질감/조명/반사 키워드 + 참조 이미지 경로 |

### Mermaid 다이어그램

| Level | 테마/스타일 |
|:-----:|---------|
| L1 | `%%{init: {'theme': 'default'}}%%` |
| L2 | `%%{init: {'theme': 'base', 'themeVariables': {...}}}%%` 커스텀 컬러 |
| L3+ | Mermaid 한계로 L2까지만 적용. L3 이상은 NanoBanana 이미지로 대체 생성 |

### HTML 시각화 (game-logic-visualize 등)

| Level | 스타일 적용 |
|:-----:|---------|
| L1 | 기본 HTML 테이블/리스트 |
| L2 | CSS 그라데이션, box-shadow, border-radius |
| L3 | CSS glassmorphism (`backdrop-filter: blur`), 글로우 애니메이션, 그리드 배경 |
| L3.5c | 다크 테마 + CSS 네온 글로우 (`text-shadow`, `box-shadow` 네온) |
| L4 | CSS 3D transform, perspective, 메탈릭 그라데이션 |

### UI/UX 목업 (frontend-design, Stitch)

| Level | 스타일 적용 |
|:-----:|---------|
| L1 | 와이어프레임 (회색 박스 + 라벨) |
| L2 | 로우파이 목업 (실제 컬러 + 기본 컴포넌트) |
| L3 | 하이파이 목업 (디자인 토큰 적용, 그림자/radius/spacing 정밀) |
| L4 | 프로토타입 수준 (마이크로인터랙션, 트랜지션 포함) |

### docx 내 도형 (python-docx 직접 구성)

| Level | 스타일 적용 |
|:-----:|---------|
| L1 | 단순 사각형 + 텍스트 |
| L2 | 둥근 사각형 + 그라데이션 fill + 그림자 |
| L3+ | python-docx 한계로 L2까지만 적용. L3 이상은 NanoBanana 이미지 삽입으로 대체 |

---

## 프로젝트 적용 방법

### 1. style-guide.md에서 선택

```markdown
## Rendering Level
- **기본 레벨**: L3 (Premium Glassmorphism)
- **데이터 슬라이드**: L3.5b (Infographic Editorial)
- **비고**: 정부과제 R&D 계획서 기준
```

### 2. 이미지 설계도에서 명시

```markdown
**스타일**: L3 Premium Glassmorphism (rendering-levels.md 참조)
```

### 3. soul-prompt-craft에서 자동 주입

Tier + Level 조합에 따라 프롬프트 키워드 사전에서 해당 레벨 키워드를 자동 삽입한다.

### 4. PPTX 생성 시 자동 적용

style-guide.md의 Rendering Level 필드를 읽어 슬라이드 비주얼 요소에 레벨별 규칙을 적용한다.

---

## 하단 크레딧 규칙

L3 이상 레벨에서는 이미지 하단에 크레딧을 삽입한다:
- 크레딧 텍스트와 위 요소 사이 충분한 패딩 확보 (그림자 겹침 방지)
- 회색 소형 텍스트 (text-secondary 컬러)
- 형식: `© {회사명} ({영문명}) | {프로젝트명} {연도}`

---

*Created: 2026-04-06*
*Cross-reference: resource-generation.md, style-guide-template.md, soul-prompt-craft SKILL.md, pptx SKILL.md*
