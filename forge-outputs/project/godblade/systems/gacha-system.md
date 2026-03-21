# 가챠 시스템 레퍼런스

> 분석일: 2026-03-19 | 분석 방법: Unity MCP 런타임 실측 + 정적 분석
> 관련 Spec: `.specify/specs/gacha-draw-animation.spec.md` (섹션 8.5)
> 관련 Spec: `.specify/specs/gacha-pattern-system.spec.md` (서버 사이드)

---

## 1. 런타임 구조 (Unity MCP 실측)

### 기존 가챠 결과 아이콘 계층 (`EodUIGoodsShopGachaResultIcon`)

```
EodUIGoodsShopGachaResultIcon
└── Main [Animator, UIPlaySound]
    ├── TextureIcon [UITexture]           ← 아이템 이미지 (Addressable)
    ├── TextureIconMask [UISprite]        ← 마스크 (비활성)
    ├── NoxMark [UITexture, TweenRotation, TweenAlpha] ← GOD 마크
    ├── TextureBackIcon [UITexture]       ← 등급 배경 (Addressable)
    ├── LabelItemName [UILabel]           ← 아이템 이름 (다국어)
    ├── LabelGradeValue [UILabel]         ← 등급 숫자
    │   └── SpriteGradeMark [UISprite]    ← 별 아이콘
    ├── LabelItemAmount [UILabel]         ← 수량 (1이면 숨김)
    ├── TextureBackIcon_Side [UISprite]   ← 측면 테두리
    └── FX
        ├── ParticleSystem × 2            ← 등급 파티클 (ItemGradeColor)
        └── 1M_UI_Plane_Flip × 3         ← 플립 이펙트 메시
```

### 실측 데이터 (1성 이모탈 부츠)

| 요소 | 텍스처/값 | 규격 |
|------|----------|------|
| 아이템 아이콘 | `ItemIcon_Immortal_Boots_B` | 128x128 |
| 등급 배경 | `Inven_itemslot_common` | 150x196 |
| 아이템 이름 | "이모탈 부츠" (TextDataTable) | — |
| 등급 숫자 | "1" | — |
| GOD 마크 | active=false | — |
| 파티클 색상 | RGBA(0.5, 0.5, 0.5) = 회색 | 1성=gray |

---

## 2. 핵심 클래스/메서드

| 클래스 | 역할 | 위치 |
|--------|------|------|
| `EodUIGoodsShopGachaResultIcon` | 가챠 결과 아이콘 슬롯 | `client/Assets/Scripts/UI/Shop/` |
| `EodUIGoodsShopGachaResultPopup` | 가챠 결과 팝업 (Animator 기반) | `client/Assets/Scripts/UI/Shop/` |
| `EodUIGoodsShopItemGacha` | 가챠 상품 슬롯 | `client/Assets/Scripts/UI/Shop/` |
| `EodUICommonItemIcon` | 공용 아이템 아이콘 | `client/Assets/Scripts/UI/Common/` |
| `EodUIBase` | UI 기반 클래스 (LoadTextureAsync) | `client/Assets/Scripts/UI/` |
| `EodDataManager` | 데이터 매니저 (ItemGradeColor) | `client/Assets/Scripts/Manager/` |
| `EodGameDatascriptManager` | 게임 데이터 매니저 (ItemTable, TextDataTable) | `client/Assets/Scripts/Manager/` |
| `EodSceneManager` | 씬 전환 매니저 | `client/Assets/Scripts/Manager/` |

---

## 3. 호출 패턴 (복붙 가능한 코드)

### 3.1 아이템 이미지 로딩 (UITexture + Addressable)

```csharp
// 1. itemCode → ItemTable에서 아이템 데이터 조회
Eod.GameDatascript.Item itemData = EodGameDatascriptManager.Get.ItemTable.GetData(itemCode);

// 2. Addressable 비동기 텍스처 로드
EodUIBase.LoadTextureAsync(itemData, (key, result, passedBy) => {
    textureItemIcon.mainTexture = result as Texture;
});
```

참조: `EodUIGoodsShopGachaResultIcon.SetItemImage()` (line 153)

### 3.2 등급별 배경 이미지

```csharp
string filePath = Eod.Client.Define.ResourcePath.Image;
string fileName = Eod.Client.Define.BackgroundGradeName.GetInvenSlotBackgroundName(itemData.grade);
EodUIBase.LoadTextureAsync(filePath + fileName, (key, result, passedBy) => {
    textureItemIconBack.mainTexture = result as Texture;
});
```

참조: `EodUIGoodsShopGachaResultIcon.SetItemImage()` (line 160-166), `EodUICommonItemIcon.SetItemImage()` (line 89-94)

### 3.3 등급별 색상

```csharp
// 등급별 색상 가져오기
Color gradeColor = EodDataManager.Get.ItemGradeColor[itemData.itemGrade - 1];

// ParticleSystem에 적용
particleGradeColor.startColor = gradeColor;
```

참조: `EodUIGoodsShopGachaResultIcon.SetGradeParticle()` (line 179-189)

### 3.4 아이템 메타정보 표시

```csharp
// 아이템 이름 (다국어)
labelItemName.text = EodGameDatascriptManager.Get.TextDataTable.GetTextByCurrentLanguage(itemData.nameTextKey);

// 등급 숫자
labelItemGrade.text = itemData.itemGrade.ToString();

// GOD 아이템 마크
spriteNoxMark.SetActive(itemData.noxItem);
```

참조: `EodUIGoodsShopGachaResultIcon` (line 118-144)

### 3.5 씬 전환

```csharp
EodSceneManager.Get.LoadScene(Eod.TableEnum.Type.{NewEnumValue}, Eod.TableEnum.eInGameMode.eNone);
```

---

## 4. 리소스 경로

| 리소스 | 경로 | 포맷 |
|--------|------|------|
| 장비 아이콘 | `ResourcesBundle/GameData/Icon/EquipItem/` | .psd, 128x128 |
| 소비 아이콘 | `ResourcesBundle/GameData/Icon/Item/` | .psd, 128x128 |
| 가챠 상품 아이콘 | `ResourcesBundle/GameData/Icon/Lotto/` | .psd |
| 등급 배경 (인벤) | `ResourcesBundle/GameData/Image/Inven_itemslot_{등급}.psd` | .psd, 150x196 |
| 등급 배경 (가챠) | `ResourcesBundle/GameData/Image/Icon_Lotto_back_{등급}.psd` | .psd |
| 가챠 결과 UI | `ResourcesBundle/GameData/UI/Shop/EodUIGoodsShopGachaResult*.prefab` | .prefab |
| 공용 아이템 아이콘 | `ResourcesBundle/GameData/UI/Common/EodUICommonItemIcon.prefab` | .prefab |

---

## 5. 신규 기능 적용 가이드

### 카드 앞면 구성 (신규 가챠)

카드 앞면은 기존 `EodUIGoodsShopGachaResultIcon` 구조를 기반으로 다음 요소를 포함:

| 요소 | UI 컴포넌트 | 데이터 소스 | 표시 조건 |
|------|-----------|-----------|---------|
| 아이템 이미지 | UITexture | `LoadTextureAsync(itemData)` | 항상 |
| 등급 배경 | UITexture | `BackgroundGradeName.GetInvenSlotBackgroundName()` | 항상 |
| 아이템 이름 | UILabel | `TextDataTable.GetTextByCurrentLanguage()` | 카드 뒤집기 완료 후 |
| 등급 숫자 | UILabel | `itemData.itemGrade` | 유효 등급만 |
| GOD 마크 | GameObject | `itemData.noxItem` | noxItem == true |
| 수량 | UILabel | `amount` | amount > 1 |

### DOTween 카드 뒤집기 시 주의

```csharp
// 카드 뒤집기 중간점(90도)에서 앞/뒷면 전환
seq.AppendCallback(() => {
    cardBackObj.SetActive(false);
    cardFrontObj.SetActive(true);
    // cardFrontObj의 UITexture는 서버 응답 수신 시점에 이미 LoadTextureAsync로 로드 완료
});
```

UISprite가 아닌 **UITexture** 사용 필수. `sprite.spriteName` 교체 방식 금지.

---

## 6. 금지 사항

- UISprite/Atlas 방식으로 아이템 이미지 로딩 금지 → UITexture + Addressable 사용
- `EodUIGoodsShopGachaResultPopup` 직접 재사용 금지 → 아이콘 표시 패턴(3.1~3.4)만 재사용
- Manager 싱글톤 패턴 변경 금지 → 기존 `EodDataManager.Get`, `EodGameDatascriptManager.Get` 그대로 사용
- Animator를 UI 오브젝트에 사용 금지 → DOTween Sequence 사용

---

*Last Updated: 2026-03-20*
