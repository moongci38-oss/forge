# 프롬프트 로그 — GodBlade 뽑기 시스템

> 모든 AI 이미지 생성의 프롬프트/시드/결과를 기록하는 경험 축적 원장.
> Flywheel 루프 1(성공), 루프 2(실패), 루프 3(골든 레시피)의 데이터 저장소.

## 메타데이터

| 항목 | 값 |
|------|-----|
| 프로젝트 | GodBlade 뽑기 시스템 |
| 스타일 가이드 | `05-design/projects/godblade/style-guide.md` |
| Art Direction Brief | `05-design/projects/godblade/art-direction-brief.md` |
| Resource Manifest | `05-design/projects/godblade/resource-manifest.md` |
| 시작일 | 2026-03-18 |
| 현재 세대 | Gen 0 (초기 상태) |

## 성숙도 KPI

| KPI | 현재값 | 목표 (Gen 1) |
|-----|:-----:|:----------:|
| 1차 생성 채택률 | ~25% | 50%+ |
| 평균 재생성 횟수 | 4-5회 | 2-3회 |
| 안티패턴 발생률 | ~40% | <25% |
| 레시피 커버리지 | 0% | 40% |
| LoRA 세대 | v0 (없음) | v0 |
| 크리틱 평균 점수 | — | 3.5+ |
| 프롬프트 재사용률 | 0% | 30% |

---

## 골든 레시피 (Golden Recipes)

> 동일 에셋 유형에서 성공률이 높은 검증된 프롬프트 패턴.

### (아직 레시피 없음 — 성공 프롬프트 3건+ 축적 시 자동 생성)

레시피 형식:
```
### 골든 레시피: {에셋_유형}
- 모델: {사용 모델}
- 성공률: {N}/{M} ({X}%)
- 핵심 키워드: "{검증된 핵심 키워드 목록}"
- 필수 파라미터: {해상도}, {품질}
- 금지 키워드: "{제외 키워드 목록}"
- 참조 시드: {시드 번호} ({에셋명})
- 대표 앵커: `_assets/{앵커 파일명}`
```

---

## 프롬프트 이력 (Prompt History)

### P2 프로토타입 에셋 (소급 기록)

#### P2-01: 상자 개봉 연출

| 항목 | 값 |
|------|-----|
| 에셋명 | p2-01-chest-opening |
| 모델 | Gemini (NanoBanana) |
| 결과 | ✅ 채택 |
| 크리틱 점수 | (소급 — 미측정) |
| 프롬프트 | `treasure chest opening scene in dark fantasy gothic medieval style, dark navy background #1A1A2E, gold ornate borders and trim #D4A520, atmospheric torch-lit dungeon environment with blue torches, cyan magical rune circle #00CED1 on stone altar, golden burst explosion effect, deep purple accents, stylized fantasy illustration` |
| 시드 | 15356 (FLUX) |
| 비고 | P2 첫 채택 에셋. 앵커 이미지 #1 |

#### P2-02: 카드 그리드 배치

| 항목 | 값 |
|------|-----|
| 에셋명 | p2-02-card-grid |
| 모델 | FLUX 1.1 Pro (Replicate) |
| 결과 | ✅ 채택 |
| 크리틱 점수 | (소급 — 미측정) |
| 프롬프트 | `10 cards face-down in 2 rows of 5 on stone altar, dark dungeon background #1A1A2E, ornate gold card backs with emblem pattern, cyan rune magic circle #00CED1 glowing on altar surface, blue torches on both sides, dark fantasy medieval RPG style, game UI mockup` |
| 시드 | 50198 (FLUX) |
| 비고 | 카드 배치 기준 설정. 앵커 이미지 #2 |

#### P2-03: 짝 맞추기 번개

| 항목 | 값 |
|------|-----|
| 에셋명 | p2-03-pair-match |
| 모델 | Gemini (NanoBanana) |
| 결과 | ✅ 채택 |
| 크리틱 점수 | (소급 — 미측정) |
| 프롬프트 | `two matched cards with lightning arc connecting them, gold glow effect, dark dungeon background, cards flipped showing matching items, electric energy surge between cards, dark fantasy style, cyan and gold color accents` |
| 시드 | — (Gemini) |
| 비고 | 번개 이펙트 기준 설정. 앵커 이미지 #3 |

### P3 대량 생산 에셋 (소급 기록)

#### P3-01~04: 등급별 번개 이펙트 4종

| # | 에셋명 | 등급 | 색상 | 모델 | 결과 |
|:-:|--------|:----:|------|------|:----:|
| 1 | p3-01-effect-white | 1~3성 | #FFFFFF | Gemini | ✅ |
| 2 | p3-02-effect-green | 4~6성 | #92D050 | Gemini | ✅ |
| 3 | p3-03-effect-blue | 7~9성 | #00B0F0 | Gemini | ✅ |
| 4 | p3-04-effect-red | 10~11성 | #CC0000 | Gemini | ✅ |

공통 프롬프트 패턴:
```
{color} lightning effect on transparent background, dark fantasy style,
electrical sparks and energy arcs, glowing {color} aura,
magical energy burst, particle effects,
stylized fantasy illustration, 1024x1024, no background
```

#### P3-05: 스페셜 상자

| 항목 | 값 |
|------|-----|
| 에셋명 | p3-05-special-chest |
| 모델 | Gemini (NanoBanana) |
| 결과 | ✅ 채택 |
| 프롬프트 | `ornate special treasure chest, larger than normal, glowing gold and purple accents, dark fantasy dungeon, ancient sealed chest with magical bindings, golden light escaping through cracks, stone altar setting` |

#### P3-06: 로우 리셋 팝업

| 항목 | 값 |
|------|-----|
| 에셋명 | p3-06-row-reset-popup |
| 모델 | FLUX 1.1 Pro |
| 결과 | ✅ 채택 |
| 프롬프트 | `game UI popup dialog, dark fantasy medieval style, gold ornate border frame, dark navy panel #1A1A2E, stone texture background, confirmation buttons at bottom, gothic RPG interface` |
| 시드 | — |

#### P3-07: 버튼 상태 3종

| 항목 | 값 |
|------|-----|
| 에셋명 | p3-07-button-states |
| 모델 | FLUX 1.1 Pro |
| 결과 | ✅ 채택 |
| 프롬프트 | `three button states (active, disabled, hover) in dark fantasy style, gold border #D4A520, dark panel, gothic medieval RPG UI, game interface buttons, horizontal layout comparison` |
| 시드 | 28048 (FLUX) |

---

## 실패 기록 (Failure Log)

> 거부된 에셋의 프롬프트와 실패 원인을 기록하여 같은 실수 반복 방지.

| # | 에셋 유형 | 실패 원인 분류 | 프롬프트 요약 | 교훈 |
|:-:|---------|:----------:|-----------|------|
| (아직 없음 — 거부 시 자동 기록) | | | | |

실패 원인 분류:
- **구도**: 카메라 앵글/배치 문제
- **색상**: 팔레트 불일치, 밝은 톤
- **스타일**: 아트 방향 이탈
- **디테일**: 과다/부족
- **안티패턴**: G/W/C/F/N/S 해당

---

## 시드 레지스트리

### 검증된 시드 (Golden Seeds)

| 도구 | 시드 | 모델 버전 | 용도 | 프롬프트 요약 | 상태 |
|------|:----:|---------|------|-------------|:----:|
| FLUX | 15356 | flux-1.1-pro | 상자 개봉 연출 | chest opening, golden burst | ✅ |
| FLUX | 50198 | flux-1.1-pro | 카드 그리드 | 10 cards face-down, 2 rows | ✅ |
| FLUX | 28048 | flux-1.1-pro | 버튼/UI | button states, gold border | ✅ |

### 블랙리스트 시드

| 도구 | 시드 | 모델 버전 | 실패 원인 | 등록일 |
|------|:----:|---------|---------|--------|
| (아직 없음) | | | | |

---

*Generated: 2026-03-18*
*Flywheel 상태: Gen 0 — 소급 기록 완료, 골든 레시피 미생성*
