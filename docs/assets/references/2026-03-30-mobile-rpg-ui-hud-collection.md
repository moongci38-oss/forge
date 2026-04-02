# 레퍼런스 수집 결과: 모바일 RPG UI/HUD

**수집일**: 2026-03-30
**대상 게임**: 모바일 RPG 상위권 게임 (Genshin Impact, Honkai: Star Rail, AFK Arena, Raid: Shadow Legends, PUBG Mobile)
**적용 대상**: GodBlade — 전투 HUD, 캐릭터 스위치 UI, 스킬 버튼, 체력바, 미니맵

---

## 핵심 레퍼런스 소스

| # | 게임 | 분류 | 소스 유형 | URL |
|:-:|------|------|---------|-----|
| 1 | Genshin Impact | HUD 전체 | 공식 위키 + Game UI DB | [gameuidatabase.com](https://www.gameuidatabase.com/gameData.php?id=470) |
| 2 | Honkai: Star Rail | HUD + 메뉴 IA | interfaceingame.com | [interfaceingame.com](https://interfaceingame.com/games/honkai-star-rail/) |
| 3 | AFK Arena | 전투 UI | Game UI DB | [gameuidatabase.com](https://www.gameuidatabase.com/gameData.php?id=1316) |
| 4 | 장르 분석 | HUD 설계 원칙 | generalistprogrammer.com | [링크](https://generalistprogrammer.com/tutorials/game-ui-design-complete-interface-guide-2025) |
| 5 | Genshin vs Star Rail | UI 비교 분석 | Medium 아티클 | [링크](https://medium.com/@acarenatnic/how-honkai-star-rail-fixes-genshin-impacts-ui-problem-6b386d6154f1) |
| 6 | 모바일 RPG 전반 | 디자인 원칙 | pixune.com | [링크](https://pixune.com/blog/mobile-games-ui-design-a-handy-guide/) |
| 7 | RPG HUD 비주얼 | 디자인 레퍼런스 | Dribbble | [dribbble.com/tags/rpg-hud](https://dribbble.com/tags/rpg%20hud) |
| 8 | 다수 게임 스크린샷 | DB 전체 | Game UI Database | [gameuidatabase.com](https://gameuidatabase.com/) |

---

## UI 레퍼런스 — HUD 레이아웃 패턴

### 1. Genshin Impact (모바일) — 업계 표준 레이아웃

**레이아웃 구조 (5존)**

```
[좌상단]          [중앙 상단]         [우상단]
 미니맵             퀘스트 트래커        상점/이벤트/배틀패스 아이콘

[좌하단]                              [우하단]
 체력바/원소 게이지                      공격 버튼 (중앙 우측)
 캐릭터 포트레이트 ×4                    원소 스킬 (중하단 우)
 스태미나 바 (중앙 상단 팝업)            원소 버스트 (하단 우)
                                       회피 버튼 (버스트 우측)
```

**핵심 HUD 요소**

| 요소 | 위치 | 디자인 패턴 |
|------|------|-----------|
| 체력바 | 좌하단 캐릭터 포트레이트 위 | 세그먼트형, 각 캐릭터별 분리 표시 |
| 캐릭터 포트레이트 | 좌하단 세로 스택 4개 | 원형 아이콘, 현재 캐릭터 강조 |
| 원소 스킬 버튼 | 우하단 중앙 | 원형 대형, 쿨다운 시계 오버레이 |
| 원소 버스트 버튼 | 원소 스킬 우측 하단 | 원형 소형, 원소 게이지 채움 표시 |
| 공격 버튼 | 우측 중앙 | 대형 원형, 가장 접근 쉬운 엄지 존 |
| 미니맵 | 좌상단 원형 | 탭 시 전체 맵 전환 |
| 회피/스프린트 | 공격 버튼 우측 | 소형 원형 |

**주요 특징**: 왼손 이동(조이스틱 좌하단) + 오른손 전투(스킬/공격 우하단)의 양손 분리 구조

---

### 2. Honkai: Star Rail — 개선된 IA 패턴

**Genshin 대비 주요 개선점**

| 항목 | Genshin Impact | Honkai: Star Rail | 개선 이유 |
|------|---------------|-------------------|----------|
| 메뉴 위치 | 좌측 패널 | **우측 패널** | 엄지 접근 용이 (Thumb Zone 원칙) |
| 장비/스탯 확인 | 장비창 → 캐릭터창 왕복 | **한 화면에서 전체 스탯 표시** | 내비게이션 뎁스 감소 |
| 지도 레이어 | 복잡한 다층 구조 | **지상/지하 명확히 분리** | 인지 부하 감소 |
| 가챠 인터페이스 | 세리프 서체, 정보 밀도 높음 | **산세리프, 스캐너블 레이아웃** | 즉각적 정보 파악 |
| 파티 편성 | 턴 순서 불명확 | **공격 순서 + 역할 시각화** | 전략적 팀 빌딩 지원 |
| 유물/장비 시너지 | 텍스트 기반 | **시각적 시너지 표시** | 빠른 세트 파악 |

**전투 UI 특징 (턴제)**

```
[상단]  적 HP 바 + 상태이상 아이콘 (좌) / 턴 순서 타임라인 (우상단)
[중앙]  3D 전투 공간
[하단]  스킬 선택 버튼 ×4 / 얼티밋 버튼 / 캐릭터 포트레이트 ×4
        └─ 스킬 포인트(SP) 표시기 (중앙 하단)
```

---

### 3. AFK Arena — 캐주얼/AFK 전투 HUD 패턴

**전투 화면 구조**

```
[상단]  진행 바 (웨이브/챕터) + 설정
[중앙]  자동 전투 5v5 필드
[하단]  영웅 포트레이트 ×5 (각 얼티밋 버튼 내장)
        오토/매뉴얼 토글 (우하단)
        스피드 배속 버튼 (우상단)
```

**핵심 패턴**: 기본 전투는 자동, 플레이어는 얼티밋 타이밍만 컨트롤. 개입 최소화로 캐주얼 접근성 극대화.

---

### 4. Raid: Shadow Legends — 정통 모바일 RPG HUD

**전투 UI 특징**

| 요소 | 설명 |
|------|------|
| 턴 순서 표시 | 상단 가로 타임라인 (캐릭터 아이콘 순서 표시) |
| 스킬 버튼 | 하단 우측 3~4개 스킬 원형 버튼 |
| 체력바 | 각 캐릭터 위 인라인 표시 |
| 자원(에너지) | 좌하단 또는 스킬 버튼 옆 |
| 보스 HP | 상단 대형 바 (별도 강조) |

---

## 로직 레퍼런스 — HUD 설계 원칙

### 모바일 RPG 전투 HUD 공통 원칙

| 원칙 | 설명 | 적용 게임 |
|------|------|----------|
| **엄지 존 설계** | 중요 버튼을 화면 하단 1/3 이내 배치 | Genshin, Star Rail, AFK Arena |
| **맥락적 표시** | 전투 중에만 스킬 버튼 표시, 탐색 시 최소화 | Genshin Impact |
| **쿨다운 시각화** | 시계 방향 오버레이 또는 채움 애니메이션 | 전 게임 공통 |
| **Z-패턴 배치** | 상단 모서리: 영구 정보 / 하단 중앙: 임시 프롬프트 | 모바일 RPG 표준 |
| **안전 영역 준수** | 노치/펀치홀로부터 최소 20-40px 여백 | 모바일 표준 |
| **터치 타깃 최소 크기** | iOS: 44×44pt / Android: 48×48dp | 모바일 표준 |
| **정보 계층화** | 체력 > 스킬 쿨다운 > 스태미나 > 부가 정보 | 전 게임 공통 |
| **캐릭터 스위치 UI** | 좌하단 포트레이트 스택 또는 하단 가로 나열 | Genshin(스택) vs Star Rail(가로) |

### 적응형 HUD (Adaptive HUD) 패턴

```
탐색 모드: 풀 HUD (미니맵 + 퀘스트 + 체력 + 스태미나 + 전체 메뉴)
     ↓ 전투 감지
전투 모드: 집중 HUD (체력 + 스킬 버튼 + 원소 게이지만 표시)
     ↓ 전투 종료
탐색 모드로 복귀
```

---

## 아트 레퍼런스 — 시각 스타일

| # | 게임 | UI 비주얼 스타일 | 컬러 팔레트 | 서체 특성 | NanoBanana 생성 |
|:-:|------|---------------|-----------|----------|:--------------:|
| 1 | Genshin Impact | 판타지 + 원소 테마 아이콘, 수채화 인상 | 골드/파랑/흰색, 원소별 컬러 | 세리프+웨이트 혼합 | 가능 |
| 2 | Honkai: Star Rail | SF+판타지 혼합, 클린 라인 | 연보라/금색/흰색 | 산세리프 중심, 가독성 우선 | 가능 |
| 3 | AFK Arena | 다크 판타지, 글로우 이펙트 | 짙은 파랑/금색/붉은 강조색 | 굵은 판타지 서체 | 가능 |
| 4 | Raid: Shadow Legends | 다크 판타지, 메탈릭 텍스처 | 어두운 회색/골드/붉은 악센트 | 굵은 영웅적 서체 | 가능 |

---

## 디자인 실수 방지 목록 (Anti-Patterns)

| 실수 | 설명 | 대안 |
|------|------|------|
| 정보 과부하 | 한 화면에 모든 스탯 표시 | 맥락적 표시 + 점진적 공개 |
| 작은 터치 타깃 | 48dp 미만 버튼 | 최소 48×48dp 보장 |
| 비일관적 시각 언어 | 화면마다 다른 버튼 스타일 | 디자인 시스템 구축 |
| 저콘트라스트 | 배경과 유사한 UI 색상 | 최소 4.5:1 대비비 |
| 창의성 > 사용성 | 독특하지만 혼란스러운 UI | 70% 관례 + 30% 차별화 |
| 고정 HUD (비적응) | 탐색 중에도 전투 HUD 유지 | 상황별 HUD 표시 전환 |

---

## GodBlade 적용 제안

프로젝트 특성(분산 멀티플레이어 모바일 RPG)을 고려한 우선순위:

| 우선순위 | 적용 항목 | 레퍼런스 게임 | 비고 |
|---------|----------|-------------|------|
| P0 | 엄지 존 기반 스킬 버튼 배치 (우하단) | Genshin Impact | 핵심 전투 UX |
| P0 | 체력바 + 캐릭터 포트레이트 좌하단 | Genshin Impact | 업계 표준 패턴 |
| P1 | 스킬 쿨다운 시계 오버레이 | 전 게임 공통 | 즉각적 피드백 |
| P1 | 적응형 HUD (탐색→전투 전환) | Genshin Impact | 몰입감 향상 |
| P1 | 우측 패널 메뉴 배치 | Honkai: Star Rail | Genshin보다 접근성 우수 |
| P2 | 멀티플레이 대상 턴 순서 표시 | Raid/Star Rail | 분산 전투 가시성 |
| P2 | 보스 HP 바 상단 대형 강조 | Raid: Shadow Legends | 긴장감 연출 |

---

## 추가 탐색 추천 소스

| 용도 | URL |
|------|-----|
| 55,000+ 게임 스크린샷 DB | [gameuidatabase.com](https://gameuidatabase.com/) |
| RPG HUD 디자인 레퍼런스 | [dribbble.com/tags/rpg-hud](https://dribbble.com/tags/rpg%20hud) |
| 모바일 RPG UI 디자인 | [dribbble.com/tags/mobile-game-ui](https://dribbble.com/tags/mobile-game-ui) |
| Honkai Star Rail UI 스크린샷 | [interfaceingame.com/games/honkai-star-rail](https://interfaceingame.com/games/honkai-star-rail/) |
| RPG 게임 UI 에셋 | [opengameart.org](https://opengameart.org/content/rpg-hud) |
| 모바일 컨트롤 패턴 DB | [gameuidatabase.com/index.php?scrn=147](https://www.gameuidatabase.com/index.php?scrn=147) |
