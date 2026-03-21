# ResourcesBundle 전체 경로 맵

> 분석일: 2026-03-20 | 분석 방법: 정적 디렉토리 탐색
> 경로 기준: `client/Assets/ResourcesBundle/GameData/`

---

## 전체 구조

```
ResourcesBundle/GameData/
├── CameraTrigger/     ← 카메라 트리거 (22)
├── Effect/            ← 이펙트 프리팹 (514)
│   ├── archon/        (28)    ← 아콘 클래스
│   ├── berserker/     (40)    ← 버서커 클래스
│   ├── boss/          (69)    ← 보스 전용
│   ├── buf/           (12)    ← 버프 이펙트
│   ├── bullet/        (39)    ← 투사체
│   ├── common/        (6)     ← 공용 이펙트
│   ├── demonhunter/   (40)    ← 데몬헌터 클래스
│   ├── guardian_stone/ (17)   ← 수호석
│   ├── GuardiansAura/ (5)     ← 가디언 오라
│   ├── Hit/           (13)    ← 피격 이펙트
│   ├── Indicator/     (2)     ← 인디케이터
│   ├── knight/        (51)    ← 나이트 클래스
│   ├── lightning/     (2)     ← 번개
│   ├── monster/       (10)    ← 몬스터 전용
│   ├── NavyDirect/    (1)     ← 해군 연출
│   ├── noti/          (31)    ← 알림 이펙트
│   ├── projectile/    (46)    ← 투사체 이펙트
│   ├── raid/          (24)    ← 레이드 전용
│   ├── Servant/       (1)     ← 서번트
│   ├── slayer/        (24)    ← 슬레이어 클래스
│   ├── Trap/          (1)     ← 트랩
│   ├── UpgradeFX/     (50)    ← 강화 이펙트
│   └── trigger/       (1)     ← 트리거
├── Entity/            ← 캐릭터/몬스터 모델 (8)
├── GameDatascript/    ← 게임 데이터 스크립트 (208)
├── Hero/              ← 영웅 모델 (5)
├── Icon/              ← 아이콘 (616) → icon-catalog.md 상세
│   ├── AchievementIcon/ (26)
│   ├── Background/    (23)
│   ├── CoinLogo/      (4)
│   ├── EquipItem/     (136)
│   ├── Failpopup/     (6)
│   ├── GuildMark/     (41)
│   ├── GuildSkill/    (5)
│   ├── Item/          (162)
│   ├── Lotto/         (18)
│   ├── Rune/          (28)
│   ├── Servant/       (29)
│   ├── Shop/          (131)
│   └── WeeklyIcon/    (7)
├── Image/             ← 배경/등급 이미지 (54)
│   ├── Icon_Lotto_back_{등급}.psd    ← 가챠(로또) 등급 배경 (7종)
│   ├── Inven_itemslot_{등급}.psd     ← 인벤토리 슬롯 배경 (9종)
│   ├── itemslot_{등급}.psd           ← 일반 슬롯 배경 (11종)
│   ├── Servantitemslot_{번호}.psd    ← 서번트 슬롯 (7종)
│   ├── icon_dungeon_*.psd           ← 던전 아이콘 (5종)
│   └── member_slot_01.psd           ← 멤버 슬롯 (1종)
├── Item/              ← 아이템 3D 모델 (320)
├── Map/               ← 맵 데이터 (262)
├── Monster/           ← 몬스터 모델 (207)
├── NPC/               ← NPC 모델 (16)
├── Pet/               ← 펫 모델 (17)
├── Projectile/        ← 투사체 모델 (3)
├── Scene/             ← 씬 파일 (6)
├── Sound/             ← 사운드 (474) → sound-catalog.md 상세
│   ├── Effect/        (96)  .wav
│   ├── Monster/       (119) .wav
│   ├── UI/            (30)  .ogg/.wav
│   ├── UiFx/          (24)  .wav
│   └── Voice/         (205) .ogg/.wav
├── Trigger/           ← 트리거 데이터 (147)
└── UI/                ← UI 프리팹 (376) → ui-prefab-catalog.md 상세
    ├── Achievement/   (3)
    ├── Alchemy/       (15)
    ├── Attendance/    (7)
    ├── Character/     (1)
    ├── CharacterSelect/ (3)
    ├── Chatting/      (7)
    ├── Cheat/         (7)
    ├── Common/        (13)
    ├── Friend/        (10)
    ├── Guide/         (3)
    ├── Guild/         (30)
    ├── HUD/           (7)
    ├── Inventory/     (33)
    ├── ItemCraft/     (8)
    ├── JewelBox/      (11)
    ├── Lobby/         (1)
    ├── MailBox/       (6)
    ├── Matching/      (5)
    ├── Movie/         (1)
    ├── OccupationWar/ (10)
    ├── PvP/           (7)
    ├── Quest/         (7)
    ├── Raid/          (4)
    ├── Ranking/       (11)
    ├── Servant/       (13)
    ├── Shop/          (18)
    ├── Skill/         (3)
    ├── Stage/         (43)
    ├── StoryScene/    (4)
    ├── ToolTip/       (1)
    ├── Tutorial/      (1)
    └── UserName/      (3)
```

## 총 파일 수 (비 .meta)

| 폴더 | 파일 수 |
|------|:------:|
| CameraTrigger | 22 |
| Effect | 514 |
| Entity | 8 |
| GameDatascript | 208 |
| Hero | 5 |
| Icon | 616 |
| Image | 54 |
| Item | 320 |
| Map | 262 |
| Monster | 207 |
| NPC | 16 |
| Pet | 17 |
| Projectile | 3 |
| Scene | 6 |
| Sound | 474 |
| Trigger | 147 |
| UI | 376 |
| **합계** | **3,255** |

## 등급 시스템 에셋 경로 (가챠 관련)

| 등급 | Image 슬롯 배경 | Image 가챠 배경 |
|------|----------------|----------------|
| common | `itemslot_common.psd` | `Icon_Lotto_back_common.psd` |
| uncommon | `itemslot_uncommon.psd` | `Icon_Lotto_back_uncommon.psd` |
| rare | `itemslot_rare.psd` | `Icon_Lotto_back_rare.psd` |
| superior | `itemslot_superior.psd` | `Icon_Lotto_back_superior.psd` |
| epic | `itemslot_epic.psd` | `Icon_Lotto_back_epic.psd` |
| legendary | `itemslot_legendary.psd` | `Icon_Lotto_back_legendary.psd` |
| Immortal | `itemslot_Immortal.psd` | `Icon_Lotto_back_Immortal.psd` |
| Nox | `itemslot_Nox.psd` | — |

---

*Last Updated: 2026-03-20*
