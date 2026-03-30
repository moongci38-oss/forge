# 스크린샷 레퍼런스 분석: Gacha / Lotto UI 에셋

**원본 파일**: `/tmp/fail_lotto.png`, `/tmp/gacha_reward.png`, `/tmp/lotto_all.png`, `/tmp/lotto_equip.png`, `/tmp/lotto_weapon.png`
**분석일**: 2026-03-29
**분석 유형**: 아이콘/에셋 분석 + UI 레이아웃 분석
**분석 방법**: 직접 비전 분석 (Gemini API 키 만료로 스크립트 미사용)

---

## 1. 에셋 분석 (4개 아이콘)

| 에셋 | 파일 | 아트 스타일 | 주요 소재 | 조명 방향 |
|------|------|-----------|---------|---------|
| 가챠 보상 아이콘 | `gacha_reward.png` | 미니멀 플랫 (녹색 룬 심볼) | 타원형 스톤/씰 | 없음 (단색 배경) |
| 갑옷+반지 세트 | `lotto_all.png` | 사실적 3D 렌더 | 검은 금속갑옷 + 스톤 반지 | 좌상단 |
| 갑옷 풀셋 | `lotto_equip.png` | 사실적 3D 렌더 | 뿔 달린 검은 갑옷 | 좌상단 |
| 도끼형 검 | `lotto_weapon.png` | 사실적 3D 렌더 | 금속 날 + 가죽 손잡이 | 좌상단 |

### 컬러 팔레트 (에셋 공통)

| 용도 | 색상명 | Hex 추정 |
|------|--------|---------|
| 기본 금속 (어두운) | 차콜 블랙 | `#1A1A1A` |
| 금속 하이라이트 | 골드 브라운 | `#8B6914` |
| 금속 광택 | 실버 그레이 | `#C8C8C8` |
| 가챠 심볼 | 네온 그린 | `#39FF14` |
| 반지 보석 | 화이트 글로우 | `#F0EEE8` |

### 공통 아트 디렉션

- **스타일**: Dark Fantasy / 사실적 3D 렌더 (아이콘용 컴포지트)
- **배경**: 투명 또는 흰색 (PNG 알파 채널 사용)
- **조명**: 좌상단 단일 광원 — 일관됨
- **소재 키워드**: 검은 강철, 금박 트림, 마모된 금속, 다크 판타지
- **일관성 점수**: **High** — 3개 3D 에셋이 동일 라이팅·소재 컨벤션 공유

---

## 2. UI 레이아웃 분석 (fail_lotto.png — 가챠 결과 화면)

### 화면 영역 구조

| 영역 | 위치 | 크기 비율(추정) | 컴포넌트 | Unity 구현 |
|------|------|--------------|---------|-----------|
| 상단 탭 바 | Top | 100% × 12% | 탭 2개 ("일반 뽑기") | `HorizontalLayoutGroup` + `Toggle Group` |
| 메인 카드 패널 (중앙) | Center | 40% × 60% | 5성 아이템 카드, 별 5개, 아이템명 라벨 | `Canvas` Overlay, `Image` + `Text` |
| 좌측 카드 패널 | Left 25% | 25% × 60% | 일반 등급 아이템 카드 | `Image` + `Text`, 채도 낮춤 |
| 우측 카드 패널 | Right 25% | 25% × 60% | 상자/보물함 카드 | `Image` + `Text` |
| 아이템명 텍스트 | Center Bottom | 100% × 8% | "루비 네크리스" 라벨 | `TextMeshPro`, center-align |
| 하단 가격/버튼 영역 | Bottom | 100% × 15% | 다이아 아이콘 + 가격(3,000), 구매 버튼 | `HorizontalLayoutGroup`, `Button` |
| 광원 이펙트 | 전체 오버레이 | - | 중앙 방사형 글로우 | `Image` (Additive blend) |

### 컬러 팔레트 (UI)

| 용도 | 색상명 | Hex 추정 |
|------|--------|---------|
| 배경 | 딥 다크 브라운 | `#1C0F08` |
| 5성 하이라이트 | 골드 | `#FFD700` |
| 별(★) | 골드-옐로우 | `#FFC200` |
| 카드 테두리 (일반) | 다크 브론즈 | `#5C3D1A` |
| 카드 테두리 (5성) | 브라이트 골드 | `#FFE066` |
| 중앙 글로우 | 핑크-화이트 | `#FF80C0` → `#FFFFFF` |
| 가격 텍스트 | 화이트 | `#FFFFFF` |
| 다이아 아이콘 | 시안-블루 | `#00D4FF` |
| 탭 액티브 | 레드-오렌지 | `#E84A2A` |

### Unity UGUI 구현 가이드

- **Canvas**: Screen Space - Overlay, Reference Resolution 1080×1920
- **Canvas Scaler**: Scale With Screen Size, Match: 0.5 (Width/Height 균형)
- **카드 레이아웃**: `HorizontalLayoutGroup` — 3열, Child Alignment Center, Spacing 8px
- **중앙 카드 강조**: `Scale(1.15, 1.15, 1)` + Z-order 최상위, 별도 패널
- **글로우 이펙트**: `Image` with Additive Blend Material, Alpha 0.6~0.8
- **5성 별**: `HorizontalLayoutGroup` 내 별 5개 `Image` 컴포넌트
- **Safe Area**: 하단 버튼은 `SafeAreaLayoutGroup` 또는 Bottom Anchor + Offset 적용

### 컴포넌트 디컴포지션 테이블

| # | 컴포넌트 | 타입 | Z-order | 부모 |
|---|---------|------|---------|------|
| 1 | RootCanvas | Canvas (Overlay) | — | 씬 루트 |
| 2 | TabBar | HorizontalLayoutGroup | 10 | RootCanvas |
| 3 | Tab_Normal | Toggle + Image + Text | 11 | TabBar |
| 4 | CardPanel | HorizontalLayoutGroup | 20 | RootCanvas |
| 5 | Card_Left | Image + VerticalLayoutGroup | 21 | CardPanel |
| 6 | Card_Center | Image + VerticalLayoutGroup | 25 | CardPanel (스케일 업) |
| 7 | Card_Right | Image + VerticalLayoutGroup | 21 | CardPanel |
| 8 | StarGroup | HorizontalLayoutGroup | 26 | Card_Center |
| 9 | ItemNameLabel | TextMeshPro | 27 | Card_Center |
| 10 | GlowOverlay | Image (Additive) | 30 | RootCanvas |
| 11 | FooterBar | HorizontalLayoutGroup | 40 | RootCanvas |
| 12 | DiamondIcon | Image | 41 | FooterBar |
| 13 | PriceLabel | TextMeshPro | 41 | FooterBar |
| 14 | BuyButton | Button + Image + Text | 41 | FooterBar |
