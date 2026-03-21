# Icon 에셋 카탈로그

> 분석일: 2026-03-20 | 경로: `client/Assets/ResourcesBundle/GameData/Icon/`
> 전체 616개 아이콘 파일 (모두 .psd 포맷)

---

## 폴더별 요약

| 폴더 | 파일 수 | 네이밍 패턴 | 용도 |
|------|:------:|-----------|------|
| EquipItem | 136 | `{클래스}_{부위}_{번호}.psd` | 장비 아이콘 |
| Item | 162 | `{카테고리}_{이름}_{번호}.psd` | 소비/기타 아이템 |
| Shop | 131 | `icon_{카테고리}_{이름}_{번호}.psd` | 상점 상품 아이콘 |
| GuildMark | 41 | — | 길드 마크 |
| Servant | 29 | — | 서번트 아이콘 |
| Rune | 28 | — | 룬 아이콘 |
| AchievementIcon | 26 | — | 업적 아이콘 |
| Background | 23 | `BackgroundMap_{act번호}.psd` | 맵 배경 이미지 |
| Lotto | 18 | `Icon_Lotto_{종류}_{번호}.psd` | 가챠(로또) 상품 아이콘 |
| WeeklyIcon | 7 | — | 주간 아이콘 |
| Failpopup | 6 | — | 실패 팝업 이미지 |
| GuildSkill | 5 | — | 길드 스킬 아이콘 |
| CoinLogo | 4 | — | 재화 로고 |

---

## 상세 네이밍 규칙

### EquipItem (136개)

클래스별 장비 아이콘. 네이밍: `{클래스}_{무기/방어구}_{번호}.psd`

샘플:
```
archon_weapon_01.psd ~ archon_weapon_05.psd
berserker_weapon_01.psd ~ ...
knight_weapon_01.psd ~ ...
demonhunter_weapon_01.psd ~ ...
slayer_weapon_01.psd ~ ...
```

클래스: `archon`, `berserker`, `knight`, `demonhunter`, `slayer`

### Item (162개)

소비/기타 아이템 아이콘. 다양한 카테고리.

샘플:
```
avatar_armor_seal_01.psd        ← 아바타 인장
avatar_helm_seal_01.psd
avatar_special_seal_01.psd
```

### Shop (131개)

상점 상품 아이콘. 네이밍: `icon_{시스템}_{종류}_{번호}.psd`

샘플:
```
icon_AccUpgrade_box_01.psd      ← 악세서리 강화 상자
icon_Alchemy_Conversion_01.psd  ← 연금술 변환
icon_Alchemy_Metamorphosis_01.psd
icon_Alchemy_Transmutation_01.psd
icon_ArmorUpgrade_box_01.psd    ← 방어구 강화 상자
```

### Lotto / 가챠 (18개)

가챠(로또) 관련 아이콘. 네이밍: `Icon_Lotto_{종류}_{번호}.psd`

```
Icon_Lotto_Acc_01.psd           ← 악세서리 가챠
Icon_Lotto_All_01.psd           ← 전체 가챠
Icon_Lotto_AncientAcces.psd     ← 고대 악세서리
icon_Lotto_AncientAll.psd       ← 고대 전체
Icon_Lotto_AncientAmor.psd      ← 고대 방어구
```

---

## 가챠 신규 에셋 재사용 가이드

| 신규 가챠 요소 | 기존 에셋 재사용 | 경로 |
|--------------|:--------------:|------|
| 아이템 아이콘 (장비) | **재사용** | `Icon/EquipItem/` |
| 아이템 아이콘 (소비) | **재사용** | `Icon/Item/` |
| 가챠 상품 아이콘 | **재사용** | `Icon/Lotto/` |
| 상점 상품 아이콘 | **재사용** | `Icon/Shop/` |
| 카드 뒷면 텍스처 | 신규 제작 | `Icon/` 또는 `Image/` 신규 |
| 등급 배경 | **재사용** | `Image/Icon_Lotto_back_{등급}.psd` |

### 신규 아이콘 추가 시 네이밍 규칙

- 장비: `{클래스}_{부위}_{번호}.psd` → `Icon/EquipItem/`
- 소비: `{카테고리}_{이름}_{번호}.psd` → `Icon/Item/`
- 상점: `icon_{시스템}_{종류}_{번호}.psd` → `Icon/Shop/`
- 가챠: `Icon_Lotto_{종류}_{번호}.psd` → `Icon/Lotto/`

---

*Last Updated: 2026-03-20*
