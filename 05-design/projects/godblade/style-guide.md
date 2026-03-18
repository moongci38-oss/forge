# 스타일 가이드 — GodBlade 뽑기 시스템

> 프로젝트의 시각적 일관성을 보장하는 기준 문서. AI 이미지 생성 시 이 가이드를 참조하여 프롬프트를 구성한다.
> Diamond Architecture P0 — 기존 7개 에셋에서 추출.

## 1. 컬러 팔레트

### 1.1 UI/환경 컬러

| 역할 | HEX | RGB | 사용처 |
|------|-----|-----|--------|
| Primary Gold | `#D4A520` | 212,165,32 | 카드 테두리, CTA 버튼, 제목 텍스트, 금장식 |
| Dark Navy | `#1A1A2E` | 26,26,46 | 전체 배경, 던전 어둠 |
| Cyan Rune | `#00CED1` | 0,206,209 | 룬 마법진, 마법 효과, 제단 글로우 |
| Deep Purple | `#6B3FA0` | 107,63,160 | 보물상자, 타이틀 배경 크리스탈, 보라 악센트 |
| Blue Torch | `#4FC3F7` | 79,195,247 | 횃불 불꽃, 앰비언트 조명 |
| Stone Grey | `#5A5A6A` | 90,90,106 | 제단, 던전 벽면, 석재 텍스처 |
| Gold Burst | `#FFD700` | 255,215,0 | 당첨 이펙트, 컨페티, 하이라이트 |
| Surface Dark | `#2A2A3E` | 42,42,62 | 카드 슬롯 배경, 패널 |
| Text White | `#F5F5DC` | 245,245,220 | 본문 텍스트, 부제목 (약간 따뜻한 흰색) |

### 1.2 등급별 이펙트 컬러 (GDD 8.5 확정)

| 등급 | HEX | RGB | 번개 이펙트 | 글로우 이펙트 |
|:----:|-----|-----|:----------:|:------------:|
| 1~3성 | `#FFFFFF` | 255,255,255 | 흰색 번개 | 흰색 글로우 |
| 4~6성 | `#92D050` | 146,208,80 | 초록 번개 | 초록 글로우 |
| 7~9성 | `#00B0F0` | 0,176,240 | 파랑 번개 | 파랑 글로우 |
| 10~11성 | `#CC0000` | 204,0,0 | 빨강 번개 | 빨강 글로우 |

## 2. 아트 스타일 키워드

| 카테고리 | 키워드 | 설명 |
|---------|--------|------|
| 전체 톤 | dark fantasy, gothic medieval, atmospheric | 어둡고 신비로운 중세 판타지 분위기 |
| 아이템 | pixel-art, retro RPG sprite | 카드 내 장비 아이템은 픽셀아트 스타일 |
| 배경 | painted gradient, crystalline, geometric | NanoBanana 배경은 기하학적 그라디언트 |
| 환경 | dark dungeon, stone altar, torch-lit | 던전 씬: 석재 제단, 횃불, 마법진 |
| UI 요소 | ornate gold border, rune pattern, embossed | 금 테두리 장식, 룬 문양, 양각 질감 |
| 이펙트 | lightning spark, golden burst, cyan glow | 번개, 금빛 폭발, 시안 글로우 효과 |

## 3. 일관성 패턴

| 요소 | 규격/규칙 | 비고 |
|------|----------|------|
| 카드 테두리 | 2px 금색 외곽선 (#D4A520) + 내부 장식 문양 | 모든 카드 동일 |
| 카드 뒷면 | 어두운 갈색-금색 오너먼트, 중앙 사슴/용 엠블럼 | 10장 동일 디자인 |
| 버튼 스타일 | 다크 패널 + 금색 테두리 + 중앙 정렬 텍스트 | "모두 열기", "한번 더", "닫기" 등 |
| 제단 | 석재 직사각형 + 상면 시안 룬 마법진 | 모든 씬의 중앙 요소 |
| 횃불 | 벽면 좌우 대칭 배치, 파란 불꽃 (#4FC3F7) | 앰비언트 조명 역할 |
| 마법진 | 시안 (#00CED1) 원형 + 룬 문자 + 발광 효과 | 제단 위 또는 배경 |
| 그림자/깊이감 | 비네팅 효과 + 중앙 집중 조명 | 던전 몰입감 |
| 아이템 카드 슬롯 | 어두운 사각 배경 (#2A2A3E) + 아이템 중앙 | 별 등급 하단 표시 |
| 텍스트 스타일 | 금색 (#D4A520) 굵은 한국어 게임 폰트 | 제목/결과 텍스트 |
| 노이즈/텍스처 | 미세 노이즈 있음 (석재 질감) | 배경과 제단에 적용 |

## 4. 타이포그래피

| 용도 | 스타일 | 크기 | 무게 | 색상 |
|------|--------|------|------|------|
| 제목 (상태 텍스트) | 한국어 게임 세리프 | 대형 (48px+) | Bold | Gold #D4A520 |
| 결과 ("획득!") | 한국어 게임 세리프 | 초대형 (72px+) | Extra Bold | Gold #FFD700 |
| 버튼 라벨 | 한국어 게임 산세리프 | 중형 (24px) | Medium | Beige #F5F5DC |
| 안내 텍스트 | 한국어 게임 산세리프 | 소형 (16px) | Regular | White #F5F5DC |
| 별 등급 표시 | 이모지/아이콘 | 소형 (12px) | — | Gold #D4A520 |

## 5. LoRA 모델 참조

| 항목 | 값 |
|------|-----|
| 모델 ID | 미학습 |
| 학습 데이터 | — |
| 트리거 워드 | — |
| 적합 에셋 | — |

> 현재 LoRA 미사용. NanoBanana MCP + Stitch MCP로 생성 중.

## 6. AI 프롬프트 가이드

### 필수 포함 키워드
```
dark fantasy, gothic medieval, dungeon atmosphere, gold ornate borders,
torch-lit stone environment, cyan rune magic circle, deep purple accents,
dark navy background (#1A1A2E), gold trim (#D4A520)
```

### 금지 키워드
```
photorealistic, 3D render, stock photo, modern UI, minimalist,
bright/cheerful colors, cartoon/chibi style, neon colors,
flat design, material design, clean white background
```

### 프롬프트 템플릿
```
{에셋 종류} in dark fantasy gothic medieval style,
dark navy background, gold ornate borders and trim,
atmospheric torch-lit dungeon environment,
cyan magical rune circle accents, deep purple highlights,
consistent with GodBlade gacha system art direction,
{추가 제약: 등급별 색상, 이펙트 유형 등}
```

### 등급별 이펙트 프롬프트 보조어

| 등급 | 추가 프롬프트 |
|:----:|-------------|
| 1~3성 | `white lightning sparks, subtle white glow, basic shimmer` |
| 4~6성 | `green lightning bolts, emerald glow effect, nature energy` |
| 7~9성 | `blue lightning arcs, sapphire glow, electric blue aura` |
| 10~11성 | `red lightning storm, crimson glow, intense red aura, epic rarity` |

## 7. 이미지 생성 품질 관리

### 3중 품질 보장 프로세스

```
1. 프롬프트 고도화 → 2. 다중 생성 + 선별 → 3. 시드 저장
```

| 단계 | 방법 | 목적 |
|------|------|------|
| **프롬프트 고도화** | §6 템플릿 + 구체적 구도/조명/배치 명시 | 편차 최소화 |
| **다중 생성** | 같은 프롬프트로 3장 생성 → 최선 1장 채택 | 운 의존도 제거 |
| **시드 저장** | 좋은 결과의 시드를 resource-manifest.md에 기록 | 재현성 확보 |

### 도구 선택 기준

| 씬 성격 | 도구 | 이유 |
|---------|:----:|------|
| 감성/이펙트 (상자 개봉, 번개, 폭발) | **Gemini** (NanoBanana) | 스타일라이즈드 감성, 무료 |
| UI 레이아웃 (카드 배치, 버튼 바) | **FLUX** (Replicate) | 구도 정확도, 목업 느낌 |
| 혼합 (레이아웃 + 이펙트) | Gemini 생성 → FLUX 리터치 | 양쪽 강점 조합 |

### 프롬프트 고도화 체크리스트

프롬프트 작성 시 아래 7요소를 반드시 포함한다:

1. **주체**: 무엇을 그리는가 (treasure chest, card grid, UI bar)
2. **구도**: 카메라 앵글, 배치 (top-down, centered, 2 rows of 5)
3. **환경**: 배경 씬 (dark dungeon, stone altar, torches)
4. **색상**: 핵심 컬러 참조 (#1A1A2E, #D4A520, #00CED1)
5. **이펙트**: 광원, 파티클 (golden burst, cyan glow, lightning)
6. **스타일**: 아트 방향 (stylized fantasy illustration, game UI mockup)
7. **제외**: 안티패턴 (no photorealistic, no modern UI, no text errors)

### 시드 관리 규칙

- **좋은 결과** → 시드 + 프롬프트를 resource-manifest.md에 기록
- **나쁜 결과** → 시드를 블랙리스트에 기록 (같은 프롬프트 재사용 방지)
- **다중 생성** → 3장의 시드를 모두 기록, 채택된 시드만 ✅ 표시
- **유사 에셋** → 기존 좋은 시드를 출발점으로 재활용

### 검증된 시드 레지스트리

| 도구 | 시드 | 용도 | 프롬프트 요약 |
|------|:----:|------|-------------|
| FLUX | 15356 | 상자 개봉 연출 | chest opening, golden burst |
| FLUX | 50198 | 카드 그리드 | 10 cards face-down, 2 rows |
| FLUX | 28048 | 마을 UI | village bottom bar, 8 buttons |

## 8. 카메라/조명/구도 사전

### 8.1 GodBlade 게임 카메라

| 앵글 | 프롬프트 키워드 | 사용 씬 |
|------|--------------|---------|
| 탑다운 제단 뷰 | `top-down view, bird's eye, overhead perspective, stone altar centered` | 뽑기 메인 씬, 카드 배치 씬 |
| 사이드뷰 카드 그리드 | `side view, slight low angle, 2 rows of 5 cards, grid layout` | 카드 10장 뒤집기 씬 |
| 정면 클로즈업 | `front view, centered, close-up, dramatic focus` | 상자 개봉, 결과 연출 |
| 로우앵글 | `low angle, looking up, dramatic perspective, heroic` | 보스 등장, 에픽 등급 연출 |

### 조명

| 유형 | 프롬프트 키워드 | 사용 씬 |
|------|--------------|---------|
| 횃불 양측 조명 | `dual blue torches from sides (#4FC3F7), warm-cool contrast, flickering light` | 모든 던전 씬 |
| 시안 룬 발광 | `cyan rune glow (#00CED1) from below, magical ambient light, pulsing` | 제단 위 마법진 활성 |
| 금빛 폭발 | `golden burst light (#FFD700) from center, radial light rays, explosive` | 당첨/획득 연출 |
| 볼류메트릭 | `volumetric light rays through dust, god rays from above, dust motes` | 보물 발견 순간 |
| 앰비언트 던전 | `dim ambient, vignette edges, center-focused illumination, dark surroundings` | 기본 배경 상태 |

## 9. 에셋 기술 규격

### 9.1 GodBlade 게임 에셋 규격

| 에셋 유형 | 타겟 해상도 | 종횡비 | 투명 배경 | 포맷 | 비고 |
|----------|:---------:|:------:|:--------:|:----:|------|
| 스프라이트 (장비 아이템) | 512×512 | 1:1 | 필수 | PNG-32 | pixel-art 스타일, 인게임 축소 |
| VFX 이펙트 (번개/글로우) | 1024×1024 | 1:1 | 필수 | PNG-32 | 등급별 4색, 고해상도 |
| UI 요소 (버튼/패널) | 가변 | 가변 | 필수 | PNG-32 | 9-slice 대응, 금 테두리 |
| 카드 뒷면 | 256×384 | 2:3 | 권장 | PNG-32 | 10장 동일 디자인 |
| 카드 슬롯 배경 | 256×384 | 2:3 | 불필요 | PNG-24 | 어두운 사각 #2A2A3E |
| 배경 (던전 전체) | 1920×1080 | 16:9 | 불필요 | PNG-24 | 풀스크린 |
| 제단+마법진 | 800×600 | 4:3 | 권장 | PNG-32 | 중앙 배치 오브젝트 |
| 아이콘 (별 등급) | 64×64 | 1:1 | 필수 | PNG-32 | 금색 #D4A520 |

## 10. 반복 개선 프로토콜

### GodBlade 실패 원인 → 수정 전략

| 실패 항목 | GodBlade 수정 전략 | 프롬프트 변경 |
|----------|------------------|-------------|
| 색상 불일치 | Dark Navy #1A1A2E 배경 미적용 | `dominant dark navy background #1A1A2E, absolutely no bright backgrounds` |
| 밝은 톤 생성 | 던전 어둠 키워드 강화 | `deep underground, no daylight, only torch and magic illumination` |
| 금색 과도 | Gold Burst를 Primary Gold로 제한 | `gold trim #D4A520 only on borders, no full gold surfaces` |
| 시안 부족 | 룬 마법진 강조 | `prominent cyan rune circle #00CED1 on altar surface, glowing` |
| 현대적 UI 느낌 | 판타지 키워드 보강 | `gothic medieval ornate, stone texture, NO modern UI, NO flat design` |
| AI 플라스틱 느낌 | Layer 3 물성 강화 | `weathered stone grain, tarnished gold, oxidized bronze, dust motes` |
| 서사 부재 | Layer 2 순간 키워드 | `the instant the seal cracks, energy still building, ancient dust rising` |
| 등급 이펙트 약함 | 등급별 색상 HEX 직접 지정 | `{등급} lightning with exact color #{HEX}, intense glow aura` |

### 반복 프로세스

```
1차 생성 → /asset-critic 6항목 평가
  │
  ├─ 평균 3.5+ & 항목5,6 각 3.0+ → ✅ PASS
  │   → resource-manifest + prompt-log 기록
  │   → 크리틱 4.5+ → 앵커 이미지 후보
  │
  └─ 미달 → 최저 항목 식별 → 위 수정 전략 적용
      │
      └─ 2차 생성 → 재평가 (최대 3회 자동)
          └─ 3회 실패 → Human 개입 요청
```

---

*Generated: 2026-03-18*
*Art Direction Brief: `05-design/projects/godblade/art-direction-brief.md`*
*Source Assets: 7개 (NanoBanana 3 + Stitch 4) — `02-product/projects/godblade/_assets/`*
