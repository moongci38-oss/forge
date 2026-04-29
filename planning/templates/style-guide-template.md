---
project: "{프로젝트명}"
generated_at: "{YYYY-MM-DD}"
version: "1.0"
palette:
  primary: "#______"
  secondary: "#______"
  accent: "#______"
  background: "#______"
  surface: "#______"
  text_primary: "#______"
  text_secondary: "#______"
  error: "#______"
  success: "#______"
art_style:
  tone: []          # flat, minimal, vibrant, dark, ...
  character: []     # chibi, semi-realistic, ...
  background: []    # painted, gradient, geometric, ...
  icon: []          # outlined, filled, duotone, ...
  ui: []            # rounded, sharp, glassmorphism, ...
lora_model: ""      # Replicate model ID or "untrained"
lora_trigger: ""
asset_path: ""
---

# 스타일 가이드 — {프로젝트명}

> 프로젝트의 시각적 일관성을 보장하는 기준 문서. AI 이미지 생성 시 이 가이드를 참조하여 프롬프트를 구성한다.

## 1. 컬러 팔레트

| 역할 | HEX | 사용처 | (IG default) |
|------|-----|--------|-------------|
| Primary | `#______` | 주요 UI, CTA, 강조 | `#0095F6` |
| Secondary | `#______` | 보조 UI, 배경 악센트 | `#4F5BD5` |
| Accent | `#______` | 알림, 뱃지, 포인트 | `#D62976` |
| Background | `#______` | 전체 배경 | `#FFFFFF` |
| Surface | `#______` | 카드, 패널, 모달 | `#FAFAFA` |
| Text Primary | `#______` | 본문 텍스트 | `#262626` |
| Text Secondary | `#______` | 보조 텍스트, 캡션 | `#8E8E8E` |
| Error | `#______` | 에러 상태 | `#ED4956` |
| Success | `#______` | 성공 상태 | `#00C853` |

## 2. 아트 스타일 키워드

| 카테고리 | 키워드 | 설명 |
|---------|--------|------|
| 전체 톤 | {예: flat, minimal, vibrant} | 프로젝트 전반 아트 방향 |
| 캐릭터 | {예: chibi, semi-realistic} | 캐릭터/아바타 스타일 |
| 배경 | {예: painted, gradient, geometric} | 배경 아트 스타일 |
| 아이콘 | {예: outlined, filled, duotone} | 아이콘 디자인 방향 |
| UI 요소 | {예: rounded, sharp, glassmorphism} | UI 컴포넌트 스타일 |

## 3. 일관성 패턴

| 요소 | 규격/규칙 | 비고 |
|------|----------|------|
| 테두리 굵기 | {px} | 모든 에셋 동일 |
| 테두리 반경 | {px} (IG Squircle: sm 3px / md 8px / lg 16px) | 카드, 버튼, 아이콘 통일 |
| 그림자 | {CSS shadow / 없음} | 일관된 깊이감 |
| 여백 (기본 단위) | {px} (4px 그리드 기반: xs:4 sm:8 md:12 lg:16 xl:24) | 4px 그리드 기반 |
| 라인 스타일 | {solid/dashed/none} | 구분선, 외곽선 |
| 노이즈/텍스처 | {있음/없음/종류} | 배경 텍스처 일관성 |

## 4. 타이포그래피

| 용도 | 폰트 | 크기 | 무게 |
|------|------|------|------|
| 제목 (H1) | {font} (IG: SF Pro Display) | {px} (IG: 28px) | {weight} (IG: Bold) |
| 부제목 (H2) | {font} (IG: SF Pro Display) | {px} (IG: 22px) | {weight} (IG: SemiBold) |
| 본문 | {font} (IG: SF Pro Display) | {px} (IG: 14px) | {weight} (IG: Regular) |
| 캡션 | {font} (IG: SF Pro Display) | {px} (IG: 12px) | {weight} (IG: Regular) |
| UI 라벨 | {font} (IG: SF Pro Display) | {px} (IG: 11px) | {weight} (IG: Medium) |

## 5. LoRA 모델 참조

| 항목 | 값 |
|------|-----|
| 모델 ID | {Replicate model ID 또는 "미학습"} |
| 학습 데이터 | {학습에 사용된 에셋 수/종류} |
| 트리거 워드 | {LoRA 트리거 키워드} |
| 적합 에셋 | {이 모델로 생성하기 적합한 에셋 유형} |

## 6. AI 프롬프트 가이드

### 필수 포함 키워드
```
{스타일 키워드}, {컬러 키워드}, {분위기 키워드}
```

### 금지 키워드
```
{안티패턴 키워드 — 예: photorealistic, 3D render, stock photo}
```

### 6.1 모델별 프롬프트 어댑터 (공용)

| 모델 | 인코더/특성 | 토큰 한계 | 네거티브 프롬프트 | 프롬프트 형식 |
|------|-----------|:--------:|:--------------:|-------------|
| **FLUX 1.1 Pro** | T5 (서술형 문장) + CLIP (키워드 리스트) | 500 토큰 | ❌ 미지원 — "prominently featuring" 등 자연어 강조 사용 | `[서술형 문장]. [키워드 리스트, 쉼표 구분]` |
| **Gemini (NanoBanana)** | 서사형 단락 선호. 메타 지시 → 상세 서술 순서 | 제한 넓음 | 자연어 제외 표현 사용 | `[메타 지시]\n[상세 서술 단락]\n[참조 이미지 경로 (선택)]` |
| **Replicate (LoRA)** | 트리거 워드 + 스타일 키워드 기반 | 모델별 상이 | ✅ 지원 (negative_prompt 파라미터) | `{trigger_word}, [스타일 키워드], [제외 키워드]` |

**모델 선택 기준:**
- 감성/서사 중심 에셋 → **Gemini (NanoBanana)**
- 구도/레이아웃 정확도 → **FLUX 1.1 Pro (Replicate)**
- 프로젝트 고유 스타일 재현 → **Replicate (LoRA)** (학습된 모델 필요)
- 참조 이미지 기반 편집 → **Gemini (NanoBanana)** (멀티턴 편집 가능)

### 6.2 🎮 게임 트랙 — Soul-Injected 프롬프트 템플릿

12요소 Soul-Injected 슬롯 프롬프트:

```
[1. 철학 메타]       "An image evoking {target_emotion} — {project_light_dark_principle}."
[2. 순간/서사]       "{narrative_moment} — {physical_reaction}, {reveal_state}."
[3. 주체]            "{subject_with_physicality}"
[4. 구도/카메라]      "{composition_with_tension}"
[5. 환경]            "{environment_with_texture}"
[6. 색상(HEX)]       "dominant {palette_dominant} with {palette_accent}, {tension_color_accent}"
[7. 이펙트]          "{effects_with_organic_rhythm}"
[8. 감성 텍스처]      "{physicality_keywords}"
[9. 의도적 긴장]      "{intentional_imperfection}"
[10. 스타일]         "{project_art_style}, painterly quality, NOT photorealistic, NOT smooth plastic"
[11. 기술 규격]       "{resolution}, {aspect_ratio}, {format}"
[12. 제외]           "no perfect symmetry, no clean surfaces, {project_exclusions}, no text"
```

**슬롯 작성 가이드:**

| 슬롯 | 작성 원칙 | 예시 |
|------|---------|------|
| 1. 철학 메타 | 프로젝트의 핵심 감정/세계관 원칙 | "An image evoking sacred dread — where light is earned, not given." |
| 2. 순간/서사 | 시간 흐름이 느껴지는 특정 순간 | "The instant the seal cracks — energy still building, fragments rising." |
| 3. 주체 | 물성이 느껴지는 주체 묘사 | "A weathered blade with chipped edge, wrapped in fraying leather" |
| 4. 구도/카메라 | 의도적 비대칭/긴장감 있는 배치 | "Low angle, subject at right third, empty space left for implied threat" |
| 5. 환경 | 텍스처가 있는 공간 묘사 | "Crumbling stone altar in dim cavern, moss on edges, dripping water" |
| 6. 색상(HEX) | §1 컬러 팔레트 HEX 직접 참조 | "dominant #1a1a2e with #e94560, tension accent #f5a623" |
| 7. 이펙트 | 유기적 리듬이 있는 이펙트 | "Flickering ember particles, irregular rhythm, fading at edges" |
| 8. 감성 텍스처 | 물성/촉감/마모 키워드 | "scratched metal, dust motes, ink-stained parchment, worn leather" |
| 9. 의도적 긴장 | 완벽하지 않은 요소 (안티 AI미학) | "Slightly uneven glow, asymmetric cracks, one corner darker" |
| 10. 스타일 | 프로젝트 아트 방향 + 안티패턴 | "{project_art_style}, painterly quality, NOT photorealistic" |
| 11. 기술 규격 | §9 에셋 규격 참조 | "1024x1024, 1:1, PNG-32 transparent background" |
| 12. 제외 | §5 Art Direction Brief 안티패턴 + 추가 | "no perfect symmetry, no clean surfaces, no text, no watermark" |

### 6.3 🌐 웹/앱 트랙 — Soul-Injected 프롬프트 템플릿

12요소 구조 동일, 웹/앱 기본값 적용:

```
[1. 철학 메타]       "An image conveying {brand_emotion} — {brand_promise}."
[2. 순간/서사]       "{user_scenario} — {emotional_state}, {context_hint}."
[3. 주체]            "{subject_description}"
[4. 구도/카메라]      "{composition_with_responsive_safe_areas}, {crop_points}"
[5. 환경]            "{environment_lighting}, {brand_mood}"
[6. 색상(HEX)]       "dominant {palette_dominant} with {palette_accent}, {brand_accent}"
[7. 이펙트]          "{subtle_effects}"
[8. 감성 텍스처]      "{material_keywords}"
[9. 의도적 긴장]      "{natural_imperfection}"
[10. 스타일]         "modern illustration, professional, NOT stock photo, NOT AI aesthetic"
[11. 기술 규격]       "{resolution} @{density}x, {format}, max {file_size}"
[12. 제외]           "no AI aesthetic, no generic stock, no text in image, {project_exclusions}"
```

**웹/앱 트랙 특수 고려사항:**

| 슬롯 | 웹/앱 특화 | 게임과의 차이 |
|------|----------|-------------|
| 4. 구도 | 반응형 세이프 영역 고려, 크롭 포인트 명시 | 고정 해상도 대신 크롭 안전 영역 |
| 5. 환경 | 스튜디오/자연광, 브랜드 무드 | 게임 세계관 대신 브랜드 톤 |
| 10. 스타일 | "NOT stock photo" 기본 포함 | "NOT photorealistic" 기본 포함 |
| 11. 기술 규격 | 1x/2x 레티나, WebP/AVIF, 파일 크기 제한 | 엔진 호환 포맷 (PNG-32) |
| 12. 제외 | "no AI aesthetic, no generic stock" | "no clean surfaces, no perfect symmetry" |

### 6.4 프롬프트 고도화 체크리스트 (10항목)

프롬프트 작성 시 아래 10항목을 순서대로 점검한다. 누락 항목이 있으면 생성 품질이 저하된다.

| # | 항목 | 설명 | 점검 질문 |
|:-:|------|------|---------|
| 1 | 주체 | 무엇을 그리는가 | 주체가 구체적으로 묘사되었는가? |
| 2 | 순간/서사 | 어떤 순간인가 (시간 흐름 암시) | 정적 묘사가 아닌 "순간"이 느껴지는가? |
| 3 | 구도/카메라 | 앵글, 배치, 비대칭 의도 | §8 카메라 사전에서 적합한 앵글을 선택했는가? |
| 4 | 환경 | 배경 씬, 공간감 | 주체가 어디에 있는지 명확한가? |
| 5 | 색상 | HEX 컬러 참조 + 긴장 악센트 | §1 컬러 팔레트의 HEX 값을 직접 참조했는가? |
| 6 | 이펙트 | 파티클, 글로우, 유기적 리듬 | 이펙트가 균일하지 않고 유기적 리듬이 있는가? |
| 7 | 감성 텍스처 | 물성 키워드 (마모, 먼지, 질감) | 촉감이 느껴지는 물성 키워드가 포함되었는가? |
| 8 | 스타일 | 아트 방향 + 안티 AI미학 | §2 아트 스타일 키워드와 일치하는가? |
| 9 | 기술 규격 | 해상도, 종횡비, 투명도, 포맷 | §9 에셋 규격에 맞는 스펙인가? |
| 10 | 제외 | 안티패턴 + 금지 키워드 | Art Direction Brief의 안티패턴이 제외 목록에 포함되었는가? |

### 6.5 3-Tier 프롬프트 깊이

에셋 중요도에 따라 프롬프트 투자 수준을 차등 적용한다.

| Tier | 대상 에셋 | 프롬프트 깊이 | Soul Layer | 예상 토큰 | 다중 생성 |
|:----:|---------|:-----------:|:----------:|:--------:|:--------:|
| T1 핵심 | 히어로 이미지, 메인 씬, 브랜딩 에셋 | 12요소 풀 Soul | 4/4 (전체 적용) | 250-350 | 3장 필수 |
| T2 주요 | UI 컴포넌트, 배경, 이펙트, 아이콘 세트 | 8요소 + 선택 Soul | 2/4 (핵심만) | 120-200 | 2장 권장 |
| T3 대량 | 변형, 색상 교체, 리사이즈, 필러 | 최소 설명 + edit_image | 0 (불필요) | 30-80 | 1장 |

**Tier 판단 기준:**
- T1: 사용자가 가장 먼저 보는 에셋, 브랜드를 대표하는 에셋
- T2: 반복 사용되는 에셋, 일관성이 중요한 에셋
- T3: 기존 에셋의 변형, 기계적 수정

## 7. 품질 관리

### 7.1 3중 품질 보장 프로세스 (공용)

| 단계 | 방법 | 목적 |
|------|------|------|
| 프롬프트 고도화 | §6 템플릿 + 구체적 구도/조명/배치 명시 | 편차 최소화 |
| 다중 생성 | 같은 프롬프트로 3장 생성 → 최선 1장 채택 | 운 의존도 제거 |
| 시드 저장 | 좋은 결과의 시드를 resource-manifest.md에 기록 | 재현성 확보 |

### 7.2 시드 관리 (공용)

**시드 관리 규칙:**
- 좋은 결과 → 시드 + 프롬프트를 resource-manifest.md에 기록
- 나쁜 결과 → 시드를 블랙리스트에 기록 (반복 방지)
- 다중 생성 → 3장 시드 모두 기록, 채택 시드만 ✅ 표시
- 유사 에셋 → 기존 좋은 시드를 출발점으로 재활용

**시드 레지스트리 템플릿:**

| 도구 | 시드 | 용도 | 프롬프트 요약 | 상태 |
|------|:----:|------|-------------|:----:|
| {tool} | {seed} | {purpose} | {summary} | ✅/❌ |

### 7.3 🎮 게임 트랙 — 도구 선택 + 검증 기준

**도구 선택:**

| 씬 성격 | 도구 | 이유 |
|---------|:----:|------|
| 감성/이펙트 중심 | Gemini (NanoBanana) | 스타일라이즈드 감성 표현 강점 |
| UI 레이아웃/구도 정확 | FLUX (Replicate) | 구도 정확도 우위 |
| 혼합 (감성 + 정확) | Gemini 생성 → FLUX 리터치 | 양쪽 강점 조합 |

**검증 기준:**

| # | 항목 | 기준 | 검증 방법 |
|:-:|------|------|---------|
| 1 | 투명도 검증 | PNG-32 알파 채널 정상 | 체커보드 배경에서 확인 |
| 2 | 축소 선명도 | 타겟 해상도로 축소 시 디테일 유지 | 50% 축소 후 시각 검증 |
| 3 | 프레임 일관성 | 동일 세트 에셋 간 스타일 통일 | 5개+ 에셋 컴포지트 비교 |
| 4 | 엔진 호환성 | Unity 임포트 시 아티팩트 없음 | Unity Editor에서 확인 |

### 7.4 🌐 웹/앱 트랙 — 도구 선택 + 검증 기준

**도구 선택:**

| 에셋 유형 | 도구 | 이유 |
|----------|:----:|------|
| 히어로 이미지 | Gemini (NanoBanana) | 감성 일러스트 표현 |
| 아이콘 세트 | FLUX / SVG 생성 도구 | 일관성 + 벡터 출력 |
| 프로덕트 샷 | Gemini (NanoBanana) | 자연스러운 조명 표현 |
| 배경 패턴 | FLUX (Replicate) | 타일링 정확도 |

**검증 기준:**

| # | 항목 | 기준 | 검증 방법 |
|:-:|------|------|---------|
| 1 | WCAG 대비율 | AA 기준 4.5:1 이상 | 대비율 체커 도구 |
| 2 | 반응형 크롭 | 세이프 영역 내 핵심 요소 유지 | 16:9 / 4:3 / 1:1 크롭 테스트 |
| 3 | 파일 크기 | WebP 기준 히어로 <300KB, 인라인 <200KB | 파일 크기 확인 |
| 4 | Core Web Vitals | LCP 이미지 2.5초 이내 로드 | Lighthouse 감사 |

## 8. 카메라/조명/구도 사전

### 8.1 🎮 게임 카메라

**앵글:**

| 앵글 | 프롬프트 키워드 | 사용 씬 |
|------|--------------|---------|
| 아이소메트릭 | `isometric view, 30-degree angle, dimetric projection` | 전략 게임 맵, 마을 |
| 탑다운 | `top-down view, bird's eye, overhead perspective` | 제단 씬, 카드 배치 |
| 사이드뷰 | `side view, profile angle, 2D platformer perspective` | 카드 그리드, 인벤토리 |
| 로우앵글 | `low angle, looking up, dramatic perspective` | 보스 등장, 이펙트 클로즈업 |
| 더치앵글 | `Dutch angle, tilted frame, 15-degree tilt` | 긴장감 있는 순간 |

**조명:**

| 유형 | 프롬프트 키워드 | 효과 |
|------|--------------|------|
| 단일 상단광 | `single overhead light, dramatic shadows below` | 던전 분위기 |
| 횃불 양측 | `dual torch light from sides, warm-cool contrast` | 제단 씬 |
| 후광 | `backlit, rim lighting, silhouette edges` | 영웅적 순간 |
| 앰비언트 | `ambient glow, soft fill light, no harsh shadows` | UI 에셋 |
| 볼류메트릭 | `volumetric light rays, god rays, dust in light beams` | 보물 발견 |

### 8.2 🌐 웹 카메라

**앵글:**

| 앵글 | 프롬프트 키워드 | 사용 |
|------|--------------|------|
| 프로덕트 샷 | `product photography, centered, clean studio` | 제품 소개 |
| 라이프스타일 | `lifestyle photography, natural environment, candid` | 사용 장면 |
| 플랫레이 | `flat lay, overhead, organized arrangement` | 기능 소개 |
| 클로즈업 | `macro detail, shallow depth of field, 85mm` | 디테일 강조 |
| 와이드 | `wide angle, environmental, establishing shot` | 히어로 배경 |

**조명:**

| 유형 | 프롬프트 키워드 | 효과 |
|------|--------------|------|
| 스튜디오 | `studio lighting, 3-point setup, clean shadows` | 프로 느낌 |
| 자연광 | `natural window light, dappled sun, golden hour` | 따뜻함 |
| 드라마틱 | `dramatic side light, chiaroscuro, deep shadows` | 임팩트 |
| 소프트 | `soft diffused light, overcast, even illumination` | 부드러움 |

## 9. 에셋 기술 규격

### 9.1 🎮 게임 에셋 규격

| 에셋 유형 | 타겟 해상도 | 종횡비 | 투명 배경 | 포맷 | DPI | 비고 |
|----------|:---------:|:------:|:--------:|:----:|:---:|------|
| 스프라이트 | 512x512 | 1:1 | ✅ 필수 | PNG-32 | — | 인게임 스케일 적용 |
| VFX 이펙트 | 1024x1024 | 1:1 | ✅ 필수 | PNG-32 | — | 고해상도 → 축소 |
| UI 요소 | 가변 | 가변 | ✅ 필수 | PNG-32 | — | 9-slice 대응 |
| 배경 | 1920x1080 | 16:9 | ❌ 불필요 | PNG-24/JPG | 72 | 풀스크린 |
| 카드 앞면 | 256x384 | 2:3 | ✅ 권장 | PNG-32 | — | 10장 그리드 |
| 아이콘 | 128x128 | 1:1 | ✅ 필수 | PNG-32 | — | Atlas 배치 |

### 9.2 🌐 웹 에셋 규격

| 에셋 유형 | 타겟 해상도 | 종횡비 | 포맷 | 최대 파일크기 | 비고 |
|----------|:---------:|:------:|:----:|:----------:|------|
| 히어로 이미지 | 1920x1080 (2x: 3840x2160) | 16:9 | WebP | 300KB | LCP 고려 |
| OG 이미지 | 1200x630 | ~1.9:1 | PNG/JPG | 200KB | SNS 공유 |
| 아이콘 | 24x24 ~ 48x48 | 1:1 | SVG 우선 | 5KB | Lucide/Heroicons |
| 배너 | 728x90 / 300x250 | 가변 | WebP/PNG | 150KB | 광고 규격 |
| 프로필/아바타 | 400x400 | 1:1 | WebP | 100KB | 원형 크롭 |
| 일러스트 | 800x600 ~ 1200x900 | 4:3 | SVG/WebP | 200KB | 인라인 |

## 10. 반복 개선 프로토콜

### 실패 원인 → 수정 전략 매핑

| 실패 항목 | 수정 전략 | 프롬프트 변경 예시 |
|----------|---------|-----------------|
| 색상 불일치 | HEX 값 직접 지정 강화, 안티 색상 추가 | `dominant #XXXXXX, absolutely no {wrong_color}` |
| 구도 불량 | 카메라 앵글 §8 사전 참조, 구체적 배치 지시 | `positioned at {fraction} from left, {angle} angle` |
| 스타일 이탈 | 앵커 이미지 첨부 (Gemini), 스타일 키워드 강화 | `style matching [앵커이미지], {additional_keywords}` |
| 디테일 과다 | "simple", "clean", "minimal detail" 키워드 추가 | `clean shapes, minimal detail, no ornate` |
| 디테일 부족 | 구체적 텍스처/물성 키워드 추가 | `with visible {texture}, {material} surface` |
| AI 플라스틱 느낌 | Layer 3 감성 텍스처 키워드 강화 | `weathered, imperfect, {physicality_keywords}` |
| 서사 부재 | Layer 2 순간/서사 키워드 추가 | `the instant {moment}, energy still building` |

### 크리틱 6항목 평가 (5점 척도)

| # | 평가 항목 | 1점 (FAIL) | 3점 (보통) | 5점 (우수) |
|:-:|---------|-----------|----------|----------|
| 1 | 주체 정확도 | 주체 누락/왜곡 | 주체 존재하나 디테일 부족 | 주체 명확, 디테일 풍부 |
| 2 | 색상 일치도 | §1 팔레트와 불일치 | 유사하나 HEX 편차 존재 | §1 팔레트 정확 반영 |
| 3 | 구도/앵글 | 지시와 다른 앵글 | 유사 앵글, 배치 편차 | §8 사전 키워드 정확 반영 |
| 4 | 스타일 일관성 | §2 아트 방향과 불일치 | 부분 일치 | 완전 일치, 기존 에셋과 통일 |
| 5 | 감성/서사 | 정적, 생기 없음 | 분위기 있으나 순간 부재 | 시간 흐름, 물성, 긴장감 존재 |
| 6 | 기술 규격 | §9 규격 미달 (해상도, 포맷) | 규격 충족, 품질 보통 | 규격 충족 + 선명도 우수 |

### 반복 프로세스

```
1차 생성 → 크리틱 6항목 평가 (5점 척도)
  │
  ├─ 평균 3.5+ & 항목5,6 각 3.0+ → ✅ PASS → resource-manifest 기록
  │
  └─ 미달 → 최저 점수 항목 식별 → 위 수정 전략 적용
      │
      └─ 2차 생성 → 재평가
          │
          ├─ PASS → ✅ 기록
          └─ FAIL → Human 개입 요청 (최대 3회 자동 시도)
```

**PASS 기준:**
- 6항목 평균 **3.5점 이상**
- 항목 5 (감성/서사) **3.0점 이상**
- 항목 6 (기술 규격) **3.0점 이상**
- 최대 자동 반복: **3회** → 초과 시 **[STOP]** Human 개입

---

*Generated: YYYY-MM-DD*
*Art Direction Brief: {경로 참조}*
