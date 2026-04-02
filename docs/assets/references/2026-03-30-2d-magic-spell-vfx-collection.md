# 레퍼런스 수집 결과: 2D 마법 주문 VFX

**수집일**: 2026-03-30
**대상**: 2D 게임 마법 주문 이펙트 (장르 기반)
**적용 대상**: 2D 게임 마법 스킬 / 주문 연출

---

## 연출 레퍼런스

| # | 소스 | 카테고리 | 핵심 요소 | 적용 대상 | 비고 |
|:-:|------|---------|----------|----------|------|
| 1 | [Magic Array VFX Breakdown (YouTube)](https://www.youtube.com/watch?v=_oZlQpUBqMA) | 마법진/소환 연출 | Fantasy formation effect, 방사형 마법진 + 파티클 소환 | 스킬 시전 연출 | Unity+UE 튜토리얼 |
| 2 | [Magic Explosion Spell Breakdown – RTVFX](https://realtimevfx.com/t/magic-explosion-spell-breakdown/19039) | 폭발형 주문 | Swirl mesh + 노이즈 스크롤 + 충격파 squash/stretch | 광역기 연출 | 1MAFX YouTube 채널 영감 |
| 3 | [Hades VFX Behind the Scenes – 80.lv](https://80.lv/articles/a-behind-the-scenes-look-at-the-effects-in-hades) | 원소 마법 연출 | Zeus 번개 / Poseidon 파도 / Artemis 화살 — 읽기 쉬운 실루엣 | 원소 스킬 연출 | Supergiant Games, 상징적 2D VFX 레퍼런스 |
| 4 | [Hades 2 VFX Tutorial (After Effects)](https://x.com/SeterMD/status/1790464591752802496) | 현대 스타일 마법 | After Effects 기반 재현 — 색감/파티클 구조 | 마법 색상 팔레트 | 2024년 튜토리얼 |
| 5 | [Ori and the Will of the Wisps VFX – RTVFX](https://realtimevfx.com/t/ori-and-the-will-of-the-wisps/13715) | 광원형 마법 | Distortion texture + Glow/Bloom 레이어 + clean readable 실루엣 | 보조 마법 / 버프 연출 | Moon Studios, Unity HDRP 기반 |
| 6 | [Magic Fire Effect Breakdown – 80.lv](https://80.lv/articles/breakdown-magic-fire-effect-in-unity) | 불꽃 주문 | Custom dissolve shader + 노이즈 텍스처 스크롤 + 멀티 emitter | 화염 마법 | Hades 영감, GitHub 공개 파일 있음 |

---

## UI 레퍼런스

| # | 소스 | 화면 | 레이아웃 패턴 | 적용 대상 | 분석 파일 |
|:-:|------|------|------------|----------|---------|
| 1 | [2D VFX Pack – Casting and Buffs (itch.io)](https://magusvfx.itch.io/2d-vfx-pack-casting-and-buffs) | 마법진 + 버프 | 9종 마법진 + 3종 특수 효과, 44개 Spritesheet (RPG Maker 호환) | 시전 이펙트 / 상태이상 UI | — |
| 2 | [70 Fantasy Spells Effects Pack – ArtStation](https://gaph.artstation.com/projects/EL1VRn) | 판타지 주문 화면 | 70종 컨셉 × 90개 카운트, Unity AssetStore 출시 | 스킬 아이콘 + 이펙트 통합 | — |
| 3 | [2D Magic & Attack Effects – Unity Asset Store](https://assetstore.unity.com/packages/vfx/particles/2d-magic-attack-effects-97953) | 공격/마법 이펙트 | 파티클 기반 2D 마법+공격 효과 세트 | 전투 VFX | — |
| 4 | [OpenGameArt – 2D Spell Effects](https://opengameart.org/content/2d-spell-effects) | 주문 이펙트 | PNG Spritesheet (fireball, freeze 등), 고해상도 | 프리토타입용 | 오픈소스 |

---

## 로직 레퍼런스

| # | 소스 | 시스템 | 핵심 메커닉 | 적용 대상 | 비고 |
|:-:|------|--------|-----------|----------|------|
| 1 | [VFX Staples: Shape, Color, Motion – 80.lv](https://80.lv/articles/vfx-staples-shape-color-and-motion) | VFX 3단계 구조 | Anticipation → Climax(최고 채도) → Dissipation | 모든 주문 이펙트 시퀀싱 | 채널 분리 셰이더 (R=색상, G=Emission, B=Alpha) |
| 2 | [Creating 2D Particle Effects – Kongregate](https://blog.kongregate.com/creating-2d-particle-effects-in-unity3d/) | 파티클 레이어 구조 | 큰 요소 → 작은 요소 순서 레이어링 | Unity 파티클 시스템 구현 | 입문 레퍼런스 |
| 3 | [RTVFX – Magic Explosion Breakdown](https://realtimevfx.com/t/magic-explosion-spell-breakdown/19039) | 폭발 시퀀스 | Charge-up(Swirl) → Core(듀얼 텍스처 회전) → Explosion(squash/stretch 변형) | 광역 폭발 스킬 | Custom Stream Data로 마스킹 애니메이션 구동 |

---

## 아트 레퍼런스

| # | 소스 | 스타일 | 키워드 | 적용 대상 | NanoBanana 생성 |
|:-:|------|--------|-------|----------|:--------------:|
| 1 | [CGHEVEN VFX Library](https://cgheven.com/blog/the-ultimate-library-of-stylized-vfx-elements-for-games-and-films) | Stylized Flipbook | magic beams, portals, auras, bursts, shockwaves, shields, teleportation | 포탈/전송 연출 | 가능 |
| 2 | [Pinterest – 230 VFX Magic Ideas](https://www.pinterest.com/keyserito/vfx-magic/) | 일러스트 VFX 참고 | elemental, glowing runes, arcane circle | 마법진 디자인 | 가능 |
| 3 | [Pinterest – 95 2D FX Magic Ideas](https://www.pinterest.com/njhchambers/2d-fx-magic/) | 2D FX 스타일 | hand-drawn, anime-inspired, super powers art | 캐릭터 기술 연출 | 가능 |
| 4 | [ArtStation – Holy Magic Spell VFX](https://www.artstation.com/artwork/GaQXDz) | Final Fantasy 스타일 | holy, divine, golden, particle burst | 신성 마법 연출 | 가능 |
| 5 | [ArtStation – Zoltraak Spell VFX (Frieren)](https://www.artstation.com/artwork/WXdEYN) | 애니메이션 스타일 | arcane barrage, geometric precision, blue-white | 다중 투사체 마법 | 가능 |

---

## 핵심 기술 원칙 정리

### VFX 3단계 시퀀스 (Stefan Jevremović)

```
Anticipation(빌드업) → Climax(임팩트) → Dissipation(소멸)
- Anticipation: 작은 움직임으로 에너지 집중 암시 (swirl inward, charge glow)
- Climax: 최고 밀도 + 최고 채도 + 가장 큰 파티클 burst
- Dissipation: 빠르게 감소 → 플레이어 시야 방해 최소화
```

### 레이어 구조 (큰 것 → 작은 것)

```
1. 배경 글로우 (Bloom/Emission)
2. 핵심 임팩트 형상 (Core Shape)
3. 파티클 burst (Primary particles)
4. 스파크/세부 파티클 (Secondary sparks)
5. 트레일/잔상 (Trails)
```

### 색상 전략

| 마법 속성 | 권장 색상 | Emission 보조색 |
|---------|---------|--------------|
| 화염 | Orange-Red #FF4500 | Amber #FFBF00 |
| 냉기 | Cyan-Blue #00BFFF | White #E0F7FF |
| 번개 | Yellow-White #FFFF00 | Purple #8A2BE2 |
| 신성 | Gold #FFD700 | White #FFFFFF |
| 암흑 | Deep Purple #4B0082 | Dark Red #8B0000 |
| 독/자연 | Green #00FF7F | Yellow-Green #ADFF2F |
| 아케인/마나 | Blue-Violet #7B68EE | Cyan #00FFFF |

### 형태 언어 (Shape Language)

- **화염**: 불규칙 유기체형, 위로 좁아지는 형태, 솟구치는 움직임
- **냉기**: 결정체 날카로운 형태, 방사형 균열, 느린 확산 후 급속 동결
- **번개**: 지그재그 직선 분기, 즉각적 충전/방전, arc 패턴
- **포탈**: 소용돌이 나선, 중심 수렴, 역방향 회전 레이어
- **마법진**: 기하학적 대칭, 룬 기호, 점진적 현현 (안쪽 → 바깥쪽)

### 애니메이션 원칙

| 원칙 | 2D 마법 VFX 적용 |
|-----|----------------|
| Anticipation | 시전 직전 에너지 집중 (inward swirl, 화면 미세 떨림) |
| Squash & Stretch | 폭발 형상의 초기 찌그러짐 → 빠른 팽창 |
| Smear Frames | 고속 투사체에 1프레임 스트레치로 속도감 표현 |
| Follow-through | 폭발 후 파편/스파크의 지속 물리 운동 |
| Timing Offset | 루프 이펙트 레이어별 타이밍 오프셋으로 반복감 숨기기 |

---

## 무료 에셋 목록 (프로토타입용)

| 에셋명 | 플랫폼 | 속성 | 링크 |
|-------|--------|------|------|
| 2D Spell Effects | OpenGameArt | Fire, Ice, General | [링크](https://opengameart.org/content/2d-spell-effects) |
| Spell Animation Spritesheets | OpenGameArt | General RPG spells | [링크](https://opengameart.org/content/spell-animation-spritesheets) |
| Free 2D Magic Assets | itch.io | Fire, Earth, Wind, Water, Portal, Explosion | [링크](https://itch.io/game-assets/free/tag-2d/tag-magic) |
| Free Magic Sprites | itch.io | Pixel art 40+ variations | [링크](https://itch.io/game-assets/free/tag-magic/tag-sprites) |
| CGHEVEN CC0 VFX Flipbooks | CGHEVEN | Portals, Auras, Shockwaves | [링크](https://cgheven.com/blog/the-ultimate-library-of-stylized-vfx-elements-for-games-and-films) |

---

## 유료 에셋 목록 (고품질 구현용)

| 에셋명 | 플랫폼 | 가격 | 속성 | 링크 |
|-------|--------|------|------|------|
| 70 Fantasy Spells Effects Pack | Unity Asset Store | 유료 | 70종 판타지 주문 | [링크](https://gaph.artstation.com/projects/EL1VRn) |
| 2D Magic & Attack Effects | Unity Asset Store | 유료 | 마법+공격 파티클 세트 | [링크](https://assetstore.unity.com/packages/vfx/particles/2d-magic-attack-effects-97953) |
| 2D Lightning & Electricity VFX | Unity Asset Store | 유료 | 번개/전기 | [링크](https://assetstore.unity.com/packages/vfx/particles/spells/2d-lightning-electricity-vfx-201871) |
| 2D VFX Pack – Casting & Buffs | itch.io (MagusVFX) | 유료 | 마법진 + 버프 44 Spritesheets | [링크](https://magusvfx.itch.io/2d-vfx-pack-casting-and-buffs) |
| FX Package VFX102 | ArtStation Marketplace | $7 | 포탈, 주문, 화염 4종 | [링크](https://www.artstation.com/marketplace/p/m3RM/fx-package-vfx102) |

---

## 학습 자료

| 자료명 | 플랫폼 | 수준 | 링크 |
|-------|--------|------|------|
| 2D FX Playbook (Toon Boom Harmony) | VFX Apprentice | 입문 | [링크](https://www.vfxapprentice.com/courses/2d-fx-playbook) |
| FX Timing Principles | VFX Apprentice | 입문-중급 | [링크](https://www.vfxapprentice.com/courses/fx-timing-principles) |
| Magic Fire Effect Breakdown | 80.lv | 중급 | [링크](https://80.lv/articles/breakdown-magic-fire-effect-in-unity) |
| VFX Staples: Shape, Color, Motion | 80.lv | 중급 | [링크](https://80.lv/articles/vfx-staples-shape-color-and-motion) |
| 2D FX Secrets (Toon Boom Interview) | Toon Boom Blog | 전문가 인터뷰 | [링크](https://www.toonboom.com/jason-keyser-and-chris-graf-on-the-secrets-behind-the-magic-of-2d-fx) |
| Magic Explosion Spell Breakdown | Real Time VFX | 중급 | [링크](https://realtimevfx.com/t/magic-explosion-spell-breakdown/19039) |
| Magic Array VFX Breakdown (YouTube) | YouTube | 중급 | [링크](https://www.youtube.com/watch?v=_oZlQpUBqMA) |

---

*수집 스킬: game-reference-collect | 라우팅: 영상 레퍼런스 → /video-reference-guide 호출 가능*
