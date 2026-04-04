# 레퍼런스 수집 결과: Souls-Like Action RPG Combat System

**수집일**: 2026-03-30
**대상 게임/장르**: Souls-Like Action RPG (Dark Souls III, Elden Ring, Sekiro, Black Myth: Wukong, WUCHANG: Fallen Feathers)
**적용 대상**: 소울라이크 전투 시스템 전반 (스태미나, 자세/포이즈, 히트 반응, HUD, 연출)

---

## 연출 레퍼런스

| # | 소스 | 카테고리 | 핵심 요소 | 적용 대상 | 비고 |
|:-:|------|---------|----------|----------|------|
| 1 | [WUCHANG: Fallen Feathers 게임플레이](https://www.dsogaming.com/videotrailer-news/new-gameplay-footage-surfaces-for-the-souls-like-action-rpg-wuchang-fallen-feathers/) | 전투 연출 | 광기(Madness) 게이지 + 히트 임팩트 파티클 | 상태이상 연출 | 2025 출시, UE5 기반 |
| 2 | [Black Myth: Wukong 전투](https://beebom.com/best-soulslike-games/) | 전투 연출 | 고임팩트 히트 반응 + 전통 액션RPG 혼합 | 히트 이펙트 설계 | 소울라이크 + 액션RPG 혼합 사례 |
| 3 | [Soulframe 게임플레이](https://www.theouterhaven.net/soulslike-games-list-2025/) | 전투 연출 | 패리/블록/닷지 3종 분기 연출 | 방어 반응 분기 | 30분 분량 데모 영상 공개 |
| 4 | [Sekiro 데스블로우 연출](https://sekiroshadowsdietwice.wiki.fextralife.com/Posture) | 처형 연출 | 포스처 브레이크 → 데스블로우 윈도우 | 피니시 무브 | 오렌지 스파크 이펙트 |

> **라우팅**: 위 영상들은 `/video-reference-guide` 스킬로 심화 분석 가능

---

## UI 레퍼런스

| # | 소스 | 화면 | 레이아웃 패턴 | 핵심 요소 | 적용 대상 |
|:-:|------|------|------------|----------|----------|
| 1 | [Game UI Database — Dark Souls III](https://www.gameuidatabase.com/gameData.php?id=40) | 전투 HUD | 좌하단 HP/스태미나, 우하단 장비 슬롯 4개 | 듀얼 게이지 스택, 큐 아이콘 | 전투 HUD 기본 레이아웃 |
| 2 | [Game UI Database — Dark Souls](https://www.gameuidatabase.com/gameData.php?id=25) | 전투 HUD | HP/SP/FP 수직 게이지 좌상단 배치 | 3단 리소스 바 | 다중 리소스 표시 |
| 3 | [Souls-Like GUI Elements (Itch.io)](https://rili-xl.itch.io/souls-like-gui-elements) | 범용 HUD | 소울라이크 전용 GUI 에셋 팩 | 보스 게이지, 소울 카운터, 장비 슬롯 | 직접 활용 가능한 UI 에셋 |
| 4 | [Demon's Souls UI/UX 케이스 스터디](https://quirk.work/case-studies/demon-souls-ui-ux-rework/) | 전투 HUD | 아이템 4방향 사이클 (좌손/우손/소비/스펠) | 방향패드 기반 장비 전환 | 인게임 장비 전환 UX |
| 5 | [Sekiro 포스처 게이지](https://sekiroshadowsdietwice.wiki.fextralife.com/Posture) | 포스처 바 | 캐릭터 발 아래/보스 상단 배치, 2색 구성 | 오렌지(위험) → 빨강(임박) 상태 전환 | 보스 체력/포스처 이중 바 |

**HUD 레이아웃 공통 패턴 요약:**
- 플레이어 리소스 바: 좌하단 또는 좌상단 고정
- 보스 게이지: 화면 상단 중앙 고정 (등장 애니와 함께 슬라이드인)
- 장비 슬롯: 우하단, 최소 4슬롯, 현재 선택 강조
- 스태미나 바: HP 바 바로 아래 고정, 길이 동일

> **라우팅**: `/game-screenshot-analyze` 스킬로 Game UI Database 스크린샷 심화 분석 가능

---

## 로직 레퍼런스

### 핵심 전투 시스템 3종

| # | 소스 | 시스템 | 메커닉 | 수치/규칙 | 적용 대상 |
|:-:|------|--------|-------|----------|---------|
| 1 | [Sekiro Posture Wiki](https://sekiroshadowsdietwice.wiki.fextralife.com/Posture) | 포스처 시스템 | 포스처 누적 → 브레이크 → 데스블로우 | 체력 75%→100% 회복, 25%→1% 회복 | 자세 게이지 설계 |
| 2 | [Elden Ring Combat Wiki](https://eldenring.wiki.fextralife.com/Combat) | 가드 카운터 | 블록 직후 카운터어택 입력 → 특수 모션 | 스태미나 소비 후 즉시 반격 | 가드 반격 시스템 |
| 3 | [Elden Ring Wiki — Poise](https://err.fandom.com/wiki/Combat_Mechanics) | 포이즈 | 히든 포이즈 미터 → 임계치 초과 시 경직 | 적 크기/무장 기반 포이즈 수치 | 경직/슈퍼아머 설계 |
| 4 | [Dark Souls Poise Wiki](https://darksouls.wiki.fextralife.com/Poise) | 포이즈 | 피격 시 액션 지속 여부 결정 | 포이즈 수치 높을수록 경직 저항 | 중장갑 가치 설계 |
| 5 | [소울라이크 전투 공통](https://en.wikipedia.org/wiki/Soulslike) | I-Frame 시스템 | 회피 구르기 중 무적 프레임 존재 | 애니메이션 우선순위(Animation Priority) 적용 | 회피 시스템 |
| 6 | [소울라이크 전투 분석](https://neogaf.com/threads/what-do-you-consider-to-be-soulslike-combat.1512646/) | 락온 시스템 | 타겟 고정 → 스트레이핑 이동 전환 | 카메라 부담 감소, 공격 회전 자동 보정 | 락온 UX 설계 |

### 포스처/스태미나 시스템 비교

| 게임 | 리소스명 | 회복 조건 | 브레이크 결과 | 특징 |
|------|---------|---------|------------|------|
| **Dark Souls III** | Stamina | 스틱 뗌 + 자동 회복 | 가드 브레이크 → 경직 | 스태미나 = 모든 행동 공유 리소스 |
| **Sekiro** | Posture | 체력 연동 회복 (HP 낮을수록 느림) | 포스처 브레이크 → 데스블로우 노출 | 공격과 방어 모두 포스처 소모 |
| **Elden Ring** | Stamina + 히든 Poise | 회피/공격 후 자동 회복 | 포이즈 초과 → 강제 경직 | 가드 카운터로 공세 전환 |
| **Black Myth: Wukong** | Focus + HP | 연속 공격으로 Focus 축적 | Focus 소모 → 강화 기술 시전 | 공격적 플레이 보상 구조 |

> **라우팅**: 포스처 시뮬레이터, 스태미나 밸런스 시각화 → `/game-logic-visualize` 스킬 호출 권장

---

## 아트 레퍼런스

| # | 소스 | 스타일 | 키워드 | 적용 대상 | NanoBanana 생성 |
|:-:|------|--------|-------|----------|:--------------:|
| 1 | [Lacre — Dark Souls 캐릭터 컨셉](https://lacre.artstation.com/projects/xJd391) | 다크 판타지 리얼리즘 | dark, gothic, worn armor, decay | 플레이어 캐릭터 실루엣 | 가능 |
| 2 | [Anato Finnstark — Dark Souls 컨셉](https://www.artstation.com/artwork/qZe6D) | 서사시 판타지 | epic, dramatic lighting, knight | 보스 디자인 레퍼런스 | 가능 |
| 3 | [Adrien Vallecilla — 환경 아트](https://adrienvallecilla.artstation.com/projects/Dx2nER) | CGI 환경, WWI/II 분위기 | ruins, fog, desolate, stone | 전투 아레나 환경 | 가능 |
| 4 | [Dark Souls Design Works](https://conceptartworld.com/books/dark-souls-design-works/) | 공식 컨셉 아트 | Miyazaki, monster design, weapon design | 무기/몬스터 디자인 방향성 | 참고용 (서적) |
| 5 | [Dark Fantasy Concept Art](https://www.artstation.com/artwork/aYdR5k) | 다크 판타지 | gloomy, stone, cold atmosphere | 전체 아트 디렉션 | 가능 |

**아트 스타일 방향성 요약:**
- 소울라이크는 **리얼리즘 기반 다크 판타지**가 주류 (셀 셰이딩은 예외적)
- 핵심 분위기 키워드: `decay`, `fog`, `worn`, `gothic`, `desolate`, `dramatic lighting`
- 최근 동양 소울라이크(WUCHANG, Black Myth)는 수묵화/동양화 요소 혼합

---

## 주요 레퍼런스 게임 요약

| 게임 | 출시 | 핵심 전투 혁신 | 벤치마크 포인트 |
|------|------|--------------|--------------|
| **Dark Souls III** | 2016 | 스태미나 + 4슬롯 HUD 완성형 | HUD 레이아웃 기준 |
| **Sekiro** | 2019 | 포스처 시스템 + 패리 중심 | 자세 게이지 + 데스블로우 |
| **Elden Ring** | 2022 | 가드 카운터 + 오픈월드 보스 | 포이즈 계층화 + 확장성 |
| **Black Myth: Wukong** | 2024 | Focus 축적 + 중국 신화 연출 | 공격 보상 구조 + 이펙트 품질 |
| **WUCHANG: Fallen Feathers** | 2025 | Madness 게이지 + UE5 비주얼 | 최신 UE5 기준 비주얼 품질 |

---

## 다음 단계 권장

| 우선순위 | 작업 | 스킬 |
|---------|------|------|
| 1 | Black Myth / WUCHANG 전투 영상 심화 분석 | `/video-reference-guide` |
| 2 | Game UI Database Dark Souls III 스크린샷 분석 | `/game-screenshot-analyze` |
| 3 | 포스처 vs 스태미나 시스템 비교 시각화 (Mermaid 상태도) | `/game-logic-visualize` |
| 4 | 자사 전투 시스템 컨셉 아트 생성 (다크 판타지 키워드 기반) | NanoBanana MCP |

---

*저장 경로: `forge/docs/assets/references/2026-03-30-souls-like-combat-collection.md`*
*GDD 6절(전투 레퍼런스), 3절(아트 디렉션), 10.1절(UI 레퍼런스)에 삽입 가능*
