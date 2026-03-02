# 바둑이(Baduki) 2D 카드 게임: 플랫폼 전략 & 관리자 도구 리서치

**작성일**: 2026-02-26
**프로젝트**: Baduki (Unity 6.3 LTS 기반)
**출시 로드맵**: 모바일(1차) → PC 런처(2차) → 웹(3차)

---

## 영역 7: 플랫폼 전략 (모바일 → PC 런처 → 웹)

### 7.1 모바일 (1차 출시)

#### 7.1.1 마켓 규모 및 트렌드

**모바일 카드 게임 시장 규모**
- **글로벌**: 모바일 카드 게임은 연 **$2.7B** 규모로 가장 강한 디지털 카드 게임 세그먼트
- **글로벌 카드 게임 시장**: 2025년 $9.8B, 2026년 $20.08B (CCG/TCG 포함)
- **한국**: 2025년 **$6.77B ~ $14.56B** (출처에 따라 상이)
  - 2024년 $6.12B 기준, CAGR 12.05% (2025-2030)
  - 2034년 예상: $23.23B
  - 모바일이 한국 게임 시장 **59%** 차지 (가장 높은 비중)
  - RPG 장르: 모바일 카드 게임 시장의 약 **40%**

**2025-2026 트렌드**
- **Pokémon TCG Pocket**: 2025년 2월 단 한 달에 **$90.4M** 매출 (모바일 카드 게임의 강한 수익화 가능성 증명)
- **라이브 서비스 모델**: 배틀패스, 시즌 이벤트, 마이크로트랜잭션 중심 수익화
- **웹3/NFT 요소**: 일부 타이틀에서 도입, 플레이어 소유권 강조

**시사점**
- 한국은 세계 3대 게임 시장 중 하나로 모바일 게임 소비 의욕이 매우 높음
- 카드 게임 시장이 급속도로 성장 중 → 진입 적기
- Pokémon TCG Pocket의 성공으로 모바일 CCG의 수익화 모델 재조명

[신뢰도: **High**]
출처: [Amra and Elma LLC](https://www.amraandelma.com/card-game-marketing-statistics/), [Straits Research](https://straitsresearch.com/report/collectible-card-games-market), [Sensor Tower](https://www.prnewswire.com/news-releases/sensor-tower-state-of-gaming-gaming-drove-94-billion-in-revenue-in-2025-downloads-reached-52-billion-302696303.html), [Seoulz](https://www.seoulz.com/korea-gaming-industry-2026-esports-economy/), [Playio Blog](https://blog.playio.co/korean-mobile-gamer-insights)
접근일: 2026-02-26

---

#### 7.1.2 수익화 모델 (In-App Purchase, 광고, 구독)

**현재 모바일 게임 수익화 트렌드**

| 모델 | 특징 | 카드 게임에 적합도 |
|------|------|:---:|
| **광고 (Ads)** | 배너, 보상형 영상, 인터스티셜 | 높음 |
| **인앱 구매 (IAP)** | 카드, 부스터, 골드, 스킨 | **매우 높음** |
| **배틀패스** | 시즌 기반 구독 (갱신 불필요) | 높음 |
| **월간 구독** | 지속적 구독 서비스 | 중간 |

**하이브리드 모델 (2025 핵심 트렌드)**
- 광고 + IAP + 배틀패스 **3가지 조합**이 최적
- 82% 플레이어가 광고 있는 무료게임 선호 (vs 유료게임)
- 하지만 46.8%는 광고를 가장 큰 불편으로 표시 → **균형 중요**

**카드 게임 특화 수익화 전략**
1. **IAP 중심** (40-50% 수익): 새 카드, 드래프트 토큰, 프리미엄 골드
2. **배틀패스** (20-30% 수익): 시즌별 보상, 배타적 카드 스킨
3. **보상형 광고** (10-20% 수익): 추가 리소스 획득 선택지
4. **구독 (선택)**: 일일 로그인 보상, 전문가 가이드 접근

**시사점 - 바둑이에 대한 전략**
- **1차**: IAP 80% + 보상형 광고 20% (초기 마네타이제이션은 보수적으로)
- **2차**: 배틀패스 추가 (계절 시스템 도입)
- **3차**: 구독 옵션 추가 (PC 진출 후 고급층 타겟)

[신뢰도: **High**]
출처: [ASO Mobile](https://asomobile.net/en/blog/mobile-market-money-app-monetization-in-2025/), [Plotline](https://www.plotline.so/blog/mobile-game-monetization-strategies), [Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-games/mobile-game-monetization-trends), [AdPushup](https://www.adpushup.com/blog/game-monetization-model/), [Tenjin](https://tenjin.com/blog/ad-mon-gaming-2025/)
접근일: 2026-02-26

---

#### 7.1.3 Google Play Store / Apple App Store 등록 절차

**핵심 요구사항**

| 요소 | Google Play | Apple App Store | 바둑이 고려사항 |
|------|:---:|:---:|------|
| **개발자 계정 비용** | $25 (일회) | $99/년 | 한국 결제 지원 필수 |
| **콘텐츠 등급** | IARC 자동 할당 | 수동 입력 | 게임 (12세 이상 추천) |
| **IAP 승인** | 자동 (카드 게임 허용) | 리뷰 필수 (일반 카드는 OK) | 현금성 아이템 명확 표시 |
| **빌드 포맷** | Android App Bundle (.aab) | .ipa | 필수 준수 |
| **개인정보보호** | 동의 필수 (2025+) | COPPA/GDPR | 미성년자 데이터 보호 |

**카드 게임 특수 규칙**

**Google Play**
- ✅ 일반 CCG/TCG 허용 (수집형 카드는 도박 미분류)
- ✅ 유료 뽑기 시스템 (가챠) 허용
- ⚠️ 실제 금전 베팅 / 복권 불허 (명확히 구분)
- ✅ 인앱 구매 100% 자동 승인

**Apple App Store**
- ✅ 같은 허용 기준
- ⚠️ 확률 공시 강화 (확정률 명시 필수)
- ⚠️ 일부 앱이 "도박 유사성" 이유로 거부당한 사례 있음
- 권장: 확률 공시를 게임 내 명시하고, 앱 설명에서도 게임의 운의 요소 명확히 표시

**제출 체크리스트**
```
- 콘텐츠 등급 설문 완료 (IARC 인증)
- 개인정보보호정책 작성 (한국어 + 영문)
- 스크린샷 5개 + 아이콘 + 미리보기 영상
- 앱 설명: 핵심 기능, 수익화 방식, 확률 명시
- 테스트 계정 제공 (Apple만 필수)
- 심사 기간: Google 몇 시간 ~ 1일, Apple 1-3일
```

**시사점**
- 한국은 양쪽 마켓 모두 중요 (Android 60%, iOS 40% 시장 점유)
- 확률 공시는 필수이자 **신뢰도 강화 요소** → 긍정 요소로 활용
- iOS가 더 엄격하므로 **앱 스토어 심사용 빌드를 먼저 준비**

[신뢰도: **High**]
출처: [InspiringApps](https://www.inspiringapps.com/blog/how-to-submit-app-to-google-play-store), [Natively](https://natively.dev/articles/app-store-requirements), [Google Play Developer Policy](https://support.google.com/googleplay/android-developer/answer/16810878), [iubenda](https://www.iubenda.com/en/blog/an-overview-of-google-plays-requirements-and-restrictions-for-app-submission/)
접근일: 2026-02-26

---

### 7.2 PC 런처 (2차 출시)

#### 7.2.1 Steam vs Epic Games Store vs 자체 런처 비교

**플랫폼 비교 분석**

| 항목 | Steam | Epic Games Store | 자체 런처 |
|------|:---:|:---:|:---:|
| **게임 수** | ~50,000 | <2,000 (엄선) | 무제한 |
| **개발자 수수료** | **30%** | **12%** | **0-20%** |
| **유저 베이스** | 1억+ | ~7,000만 | 구축 필요 |
| **검색 노출** | 우수 | 중간 | 자체만 |
| **사용자 경험** | 클래식 UI | 현대식 UI | 커스텀 |
| **토레이딩 카드** | ✅ 지원 (거래 가능) | 미지원 | 커스텀 |

**Steam (추천 1순위)**
- **장점**:
  - 최대 사용자 풀 (1억+ 월간 활성 유저)
  - 토레이딩 카드 시스템 → 게임 카드와 시너지 (배지, 아니메 프로필 배경 수집)
  - 커뮤니티 기능 (토론, 가이드, 아트)
  - Wishlist 효과 (출시 전 관심도 측정)
- **단점**: 높은 수수료 (30%), 심사 기간 (5-10일)
- **카드 게임 성공 사례**:
  - Balatro (독립작) → 2025년 최다 판매 카드 게임
  - Slay the Spire → 지속적 인기 (7년 지속)
  - Yu-Gi-Oh! Master Duel → Konami 공식 → 엄청난 동시접속

**Epic Games Store**
- **장점**: 낮은 수수료 (12%), 무료 게임 정책으로 마케팅 노출
- **단점**: 유저 베이스 작음, 카드 게임 포지셔닝 약함
- **추천 사용 시기**: Steam 이후 6개월 경과 후 (중복 판매 전략)

**자체 런처**
- **장점**: 완전한 통제, 높은 마진 (수수료 0%), 크로스 플랫폼 데이터 연동 용이
- **단점**:
  - 유저 베이스 구축에 2-3년 소요
  - 마케팅 비용 막대
  - 기술 운영 비용 높음
  - 인디 게임에는 부담
- **추천 시점**: 충분한 자금과 팀 규모가 있는 경우 (초기엔 불가)

**바둑이 권장 전략**
```
Phase 1: Steam 1순위 출시
  - 모바일 성공 후 이미 팬베이스 확보 상태
  - Wishlist 기간 3개월 (마케팅)
  - 출시 후 6-12개월 기준 판매 성과 평가

Phase 2: 6개월 후 Epic Games Store 추가
  - 번들 할인 또는 무료 게임 이벤트 제안

Phase 3: 2년+ 운영 후 자체 런처 검토
  - 월간 활성 유저 1만+ 확보 시에만 추진
```

[신뢰도: **High**]
출처: [Game Marketing Genie](https://gamemarketinggenie.com/blog/steam-vs-epic-game-pros-cons/), [Trusted Reviews](https://www.trustedreviews.com/versus/steam-vs-epic-games-store-4318282), [Game Rant](https://gamerant.com/valve-steam-epic-games-store-better/), [Adventure Gamers](https://adventuregamers.com/article/best-card-games-on-steam), [Steam 250](https://steam250.com/tag/card_game)
접근일: 2026-02-26

---

#### 7.2.2 Steam 카드 게임 시장 분석 (2025)

**2025년 Best-Selling 카드 게임**

| 순위 | 게임명 | 특징 | 판매 영향도 |
|:---:|--------|------|:---:|
| 1 | **Balatro** | Poker + Rogue-like Deckbuilder | 🔥 현재 진행형 |
| 2 | **Slay the Spire** | 턴 기반 덱 빌더 (벤치마크) | 지속적 TOP 10 |
| 3 | **Yu-Gi-Oh! Master Duel** | 공식 TCG (엄청난 동시접속) | 월간 수십만 활성 |
| 4 | **Sultan's Game** | 어두운 톤, 선택 기반 (552K 판매, Apr 2025) | 소규모 성공 |
| 5 | **Marvel's Midnight Suns** | 액션 RPG + 카드 메커닉 | AAA급 예시 |

**성공 요소 분석**

**Balatro의 성공 요인**
- ✅ 단순한 핵심 메커닉 (포커 핸드 스코어링)
- ✅ 무한한 조합 (Joker 카드로 빌드 다양화)
- ✅ 높은 중독성 (3-5분 라운드, 장시간 플레이 가능)
- ✅ 낮은 개발비 + 높은 가격대 ($15) = 높은 마진
- ✅ 독립 개발자 스토리 (마케팅 이슈 없음)

**Slay the Spire의 지속성**
- 7년 이상 TOP 10 유지 → 장기 매력
- 확장팩 및 신 캐릭터 정기 업데이트
- 커뮤니티 가이드 및 전략 콘텐츠 활발

**시사점 - 바둑이의 차별점**
- 모바일에서 입증된 플레이어 베이스 활용
- 2D 아트와 단순 메커닉 → Balatro와 유사 경쟁력
- **강점**: 모바일 크로스플레이 → PC 플레이어에게 "이어서 즐길 수 있음"이 강한 차별점

[신뢰도: **Medium**]
출처: [Steam Charts](https://store.steampowered.com/charts/bestofyear/2025), [Game Rant](https://gamerant.com/steam-best-selling-games-2025/), [WeCoach](https://wecoach.gg/blog/article/top-10-steam-card-games-in-2025)
접근일: 2026-02-26

---

### 7.3 웹 (3차 출시)

#### 7.3.1 Unity WebGL 성능 제약사항

**핵심 제약사항**

| 제약 | 세부 사항 | 바둑이 영향도 |
|------|---------|:---:|
| **메모리 한계** | 브라우저 탭당 ~500MB-2GB (기기 따라 상이) | 🔴 높음 |
| **단일 스레드** | WebGL은 JS 엔진과 공유 (병렬 처리 불가) | 🟡 중간 |
| **GPU 렌더링** | CPU dispatch 느림 (드로우콜 최소화 필수) | 🟢 낮음 |
| **초기 로딩** | 큰 빌드 = 긴 다운로드 = 이탈 증가 | 🔴 높음 |
| **Garbage Collection** | 스택이 비어야만 GC 실행 (자동 관리 어려움) | 🟡 중간 |

**성능 최적화 권장사항**

```
1. 빌드 크기 최소화
   - Mono 대신 IL2CPP 사용 (파일 크기 ~30% 감소)
   - 미사용 에셋 제거 (AssetBundle 권장)
   - Texture Compression (WebP or ASTC)
   - 목표: <30MB 초기 다운로드

2. 메모리 관리
   - Object Pooling (카드 UI 재사용)
   - 동적 언로드 (신 변경 시 메모리 정리)
   - 캐시 정책 (CDN 활용, 로컬 스토리지)

3. 렌더링 최적화
   - 드로우콜 <100 per frame 유지
   - UI 배칭 (Canvas로 통합)
   - 파티클 효과 제한 (카드 게임엔 많지 않음)

4. 네트워크 최적화
   - WebSocket or SSE (실시간 멀티플레이)
   - gzip 압축
   - API 응답 최소화
```

**웹 카드 게임에 우호적인 이유**
- 카드 게임은 3D 그래픽 요구 낮음 → 메모리 절감
- 턴 기반 = 프레임 레이트 요구 낮음
- 정지 이미지 + 애니메이션 → 최적화 쉬움

[신뢰도: **High**]
출처: [Unity Docs - Web Performance](https://docs.unity3d.com/6000.3/Documentation/Manual/webgl-performance.html), [Backtrace](https://backtrace.io/blog/memory-and-performance-issues-in-unity-webgl-builds), [Friendzy](https://friendzy.xyz/2025/09/17/unity-webgl-performance-tips/), [DevCody](https://devcody.com/unity-webgl-technical-limitations-guide-reality-check)
접근일: 2026-02-26

---

#### 7.3.2 웹 카드 게임 사례 및 수익화

**웹 기반 카드 게임 사례**

| 게임명 | 장르 | 수익화 | 상태 |
|-------|------|--------|:---:|
| **Cards and Castles** | CCG + Strategy | Free-to-Play (IAP) | 활성 |
| **Card Hunter** | TCG + 턴제 전투 | Free-to-Play (IAP + 구독) | 안정 |
| **Urban Rivals** | 브라우저 MMO CCG | Free-to-Play (IAP) | 장기 운영 |
| **Hearthstone (웹 시뮬레이터)** | 공식 클론 | 팬 프로젝트 | 제한 |

**웹 수익화 전략**

| 방식 | 특징 | 카드 게임 적합도 |
|------|------|:---:|
| **광고 (최다)** | 배너, 인터스티셜, 영상 | 🟢 높음 |
| **IAP** | 프리미엄 카드, 부스터 | 🟢 높음 |
| **구독** | 월간 또는 배틀패스 | 🟡 중간 |
| **Web Monetization** | 스트리밍 결제 (Web Standard) | 🔴 낮음 (채택 미미) |

**추천 웹 수익화 조합**
```
모바일/PC 플레이어가 웹에서 가벼운 플레이:
- 광고 60% (비침투식: 턴 종료 시, 매칭 대기 시)
- IAP 35% (카드 판매량 적음, 대신 스킨/배경)
- 구독 5% (프리미엄 배경 또는 광고 제거)

목표: 모바일/PC 수익의 20-30% 수준 (웹 트래픽이 낮으므로)
```

[신뢰도: **Medium**]
출처: [Phaser](https://phaser.io/tutorials/game-web-monetization), [Paymentwall](https://blog.paymentwall.com/guides/quick-guide-on-revenue-models-for-browser-games), [Xsolla](https://xsolla.com/blog/monetizing-your-browser-based-game-via-subscriptions), [Playwire](https://www.playwire.com/game-monetization), [Itch.io](https://itch.io/games/html5/tag-card-game), [MMOS](https://mmos.com/review/browser-games/card-games)
접근일: 2026-02-26

---

### 7.4 크로스 플랫폼 계정/데이터 동기화

#### 7.4.1 아키텍처 설계

**Genshin Impact 모델 분석**
Genshin Impact는 모바일(iOS/Android), PC, PS4/PS5, Xbox에서 완전 크로스세이브 구현:

| 방식 | 구현 | 바둑이 적용 |
|------|------|---------|
| **계정 링킹** | HoYoverse ID (통합 계정 시스템) | OAuth 기반 자체 계정 구축 필수 |
| **클라우드 동기화** | 서버 중심 (로컬 캐시 최소) | Firebase Realtime DB 또는 PlayFab |
| **자동 동기화 주기** | 장면 전환, 게임 종료, 5분마다 | 게임 종료 시 + 5분마다 강제 동기화 |
| **플랫폼별 격차** | Genesis Crystals는 플랫폼 제외 (정책) | 통화/재화는 통합 관리 권장 |

**권장 바둑이 아키텍처**

```
┌─────────────────────────────────────────────────────────────┐
│                    Baduki Account (OAuth)                   │
│  - Email / Google / Apple ID 통합 로그인                    │
│  - 전역 고유 UUID 발급                                      │
│  - JWT 토큰 기반 인증                                       │
└─────────────────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────────────────┐
│              Cloud Game State (Firebase/PlayFab)            │
├─────────────────────────────────────────────────────────────┤
│ • Player Data: Rank, Gold, Cards, Unlocks                   │
│ • Progress: Campaign Levels, Quest Status                   │
│ • Cosmetics: Card Skins, Avatars, Borders                   │
│ • Social: Friends, Blocks, Match History                    │
│ • IAP Record: Receipts, Consumables                         │
└─────────────────────────────────────────────────────────────┘
           ↓
    ┌──────────────────────────────────────┐
    │    Platform-Specific Local Cache      │
    ├──────────────────────────────────────┤
    │ Mobile: PlayerPrefs + SQLite          │
    │ PC: Registry / Steam Cloud Save       │
    │ Web: IndexedDB / LocalStorage         │
    └──────────────────────────────────────┘
```

#### 7.4.2 기술 구현 방안

**권장 백엔드 솔루션**

| 솔루션 | 특징 | 바둑이에 적합도 |
|--------|------|:---:|
| **Firebase** | NoSQL, 실시간 동기화, 인증 통합 | 🟢 높음 |
| **PlayFab** | 게임 특화, 더 많은 기능, 더 비쌈 | 🟢 높음 |
| **AWS + 커스텀** | 완전 통제, 높은 개발 비용 | 🔴 낮음 (초기 단계) |

**Firebase 기반 구현 (권장)**
- Realtime Database: 게임 상태 (시합, 랭킹)
- Firestore: 대용량 데이터 (카드 정보, 유저 프로필)
- Authentication: OAuth 로그인
- Cloud Functions: 검증 로직 (부정행위 방지)
- Storage: 프로필 이미지, 스크린샷

**PlayFab 기반 구현 (AAA 게임 수준)**
- Player Data: 게임 상태 저장소
- Character/Inventory: 카드 및 재화 관리
- Leaderboards: 랭킹 시스템
- CloudScript: 백엔드 로직 (Node.js)
- Multiplayer Services: 매칭 + 래더 (선택)

**동기화 전략**

```
동기화 빈도:
- 게임 종료: 반드시 동기화
- 5분마다: 자동 동기화
- 중요 이벤트: 즉시 동기화
  - 카드 획득/소모
  - 순위 변경
  - IAP 완료

충돌 해결 (Last-Write-Wins):
- 서버 데이터 = 단일 진실 공급원
- 클라이언트 로컬 캐시는 20분 이상 오류 시 강제 새로고침
```

#### 7.4.3 크로스플레이 (선택사항, 3년 후)

**크로스 플레이 아키텍처**

```
모바일 플레이어 ──┐
                 ├─→ 매칭 서버 (ELO 기반)
PC 플레이어 ────┘      ↓
웹 플레이어 ────┐   Baduki Rank System
                ├─→ (통합 래더)
                │
          공정성 검증:
          - 동일 룰셋
          - 핸디캡 없음
          - 플랫폼 간 지연시간 보정
```

**3년차 로드맵 (향후 고려)**
- Phase 1: 모바일 ↔ PC 매칭 (2027)
- Phase 2: 웹 추가 (2028)
- Phase 3: 토너먼트 (2029)

[신뢰도: **High**]
출처: [BitTopup - Genshin Cross-Save](https://bittopup.com/article/Genshin-Impact-Cross-Save-2025-Complete-Guide-for-All), [HoYoverse Support](https://support.hoyoverse.com/hc/en-us/articles/49686152994457), [Game8](https://game8.co/games/Genshin-Impact/archives/296729), [PlayedGamer](https://playedgamer.net/blog/cross-platform-gaming/keep-your-game-going-how-to-sync-progress-across-devices-in-cross-platform-games), [Medium - Firebase Multiplayer](https://medium.com/@ktamura_74189/how-to-build-a-real-time-multiplayer-game-using-only-firebase-as-a-backend-b5bb805c6543)
접근일: 2026-02-26

---

## 영역 8: 관리자 도구 (Admin Dashboard)

### 8.1 요구사항 분석

#### 8.1.1 핵심 기능 (우선순위)

| 기능 | 중요도 | 설명 | 구현 시점 |
|------|:---:|------|:---:|
| **유저 관리** | 🔴 필수 | 계정 조회, 밴/제재, 신고 처리 | Phase 1 |
| **실시간 모니터링** | 🔴 필수 | 동시접속, 게임 수, 서버 상태 | Phase 1 |
| **게임 밸런싱** | 🔴 필수 | 카드 스탯 조정 (패치 없이) | Phase 1 |
| **매칭 파라미터 조정** | 🟡 고도 | ELO K값, 시간대별 매칭 | Phase 1.5 |
| **피처 플래그** | 🟡 고도 | 기능 ON/OFF (서버 재시작 불필요) | Phase 1 |
| **이벤트/공지 관리** | 🟡 고도 | 인게임 배너, 푸시 알림 | Phase 1 |
| **매출 대시보드** | 🟢 선택 | IAP, 광고 수익 추적 | Phase 2 |
| **분석 (Analytics)** | 🟢 선택 | 플레이 시간, 이탈률, 유입처 | Phase 2 |

#### 8.1.2 유저 관리 상세 기능

**조회 및 검색**
```
- 유저 ID / 닉네임 / 이메일로 검색
- 순위, 승률, 평균 게임 시간 필터
- 거래/제재 이력 조회
- 최근 로그인 시간
- 결제 이력 (App Store/Google Play 영수증)
```

**제재 관리**
```
- Temp Ban (6시간, 24시간, 7일, 30일)
- Permanent Ban (명백한 부정행위)
- Soft Ban (매칭 제외, 채팅 불가)
- 사유 기록 (자동 & 수동)
- 항소 제출 처리 (검토 큐)
```

**부정행위 탐지**
```
자동 플래그:
- 비정상적 높은 승률 (>75%, 200게임+)
- 카드 드로우 패턴 (연속 다우 또는 다운)
- 순위 폭등 (24시간 +1000점)
- 채팅 스팸 (5분 내 5+ 메시지)

수동 신고:
- 플레이어 리포트 → 큐
- 모더레이터 승인 → 자동 조치
```

#### 8.1.3 게임 밸런싱 조정

**카드 능력 조정 (패치 없이)**

```
예시: 카드 "바둑이의 검" 너무 강함 → 즉시 조정

Before:  { damage: 15, cost: 3, rarity: "common" }
After:   { damage: 12, cost: 3, rarity: "common" }

적용: 앱 재시작 시 즉시 반영
     기존 진행 중인 게임에는 미적용 (공정성)
     다음 매칭부터 새 스탯 사용
```

**구현 아키텍처**
```
Admin Dashboard
      ↓
  [카드 스탯 변경]
      ↓
  Config Server (Redis)
      ↓
  [클라이언트 앱이 시작할 때 받아옴]
  또는
  [매칭 서버에서 참조]
```

**밸런싱 주기 (권장)**
- 주 1회 (또는 필요 시): 스탯 리뷰
- 24시간 적용 대기 (플레이어 부담 완화)
- 매월 대규모 밸런스 패치

#### 8.1.4 피처 플래그 관리

**예시**
```
flags:
  - "new_battle_mode_v2": { enabled: true, rollout: 50% }
    (50%의 플레이어만 신 모드 제공, A/B 테스트)

  - "double_xp_event": { enabled: true, endDate: "2026-03-15" }
    (임시 이벤트, 자동 종료)

  - "matchmaking_v3": { enabled: false, targetDate: "2026-03-01" }
    (개발 중, 예정된 날짜에 자동 활성화)
```

**UI 구성**
```
Flag Name        | Status   | Rollout | Actions
─────────────────┼──────────┼─────────┼──────────────
new_battle_mode  | Enabled  | 50%     | [Edit] [Disable]
double_xp_event  | Enabled  | 100%    | [Edit] [Disable]
matchmaking_v3   | Disabled | 0%      | [Edit] [Enable]
```

#### 8.1.5 실시간 모니터링 대시보드

**메인 지표**

```
┌─ 현재 상태 ────────────────────┐
│ 동시 접속자: 12,450            │
│ 진행 중인 매칭: 1,230          │
│ 평균 대기시간: 8.3초           │
│ 서버 상태: ✅ 정상             │
└────────────────────────────────┘

┌─ 시간대별 차트 (최근 24시간) ──┐
│ 🔵 접속자 수                    │
│ 🟢 매칭 성공률                  │
│ 🔴 에러율                       │
│ 📊 평균 세션 길이              │
└────────────────────────────────┘

┌─ 신호 및 경고 ─────────────────┐
│ ⚠️ 매칭 대기: 45초 (보통 8초)   │
│ ⚠️ 에러율: 2.1% (목표: <0.5%)  │
│ ✅ 결제 시스템: 정상           │
└────────────────────────────────┘
```

**모니터링 대상**
- **서버 상태**: CPU, 메모리, DB 연결, API 응답시간
- **게임 메트릭**: 동시 사용자, 활성 게임, 대기 시간
- **품질**: 에러율, 연결 끊김, 불완전한 거래
- **비즈니스**: IAP 거래량, 광고 임프레션, 일일 활성 사용자

#### 8.1.6 이벤트/공지 관리

**예시 이벤트**

| 이벤트명 | 기간 | 내용 | 상태 |
|---------|------|------|:---:|
| 신년 축제 | 2026-02-01 ~ 03-01 | 경험치 2배, 특별 카드 | 🔴 Live |
| 밸런스 업데이트 | 2026-02-27 | 카드 3장 조정 | 🟡 예정 |
| 서버 점검 | 2026-02-28 10:00-12:00 | 데이터베이스 유지보수 | 🟡 예정 |

**공지사항 구성**
```
Title: "카드 3장 밸런스 패치"
Content: "[마법사의 구슬] 데미지 15→12 조정..."
Priority: High
Pin: Yes (상단 고정)
Platforms: Mobile, PC, Web
AutoExpire: 2026-03-20
```

---

### 8.2 기술 아키텍처

#### 8.2.1 권장 기술 스택

| 계층 | 기술 | 특징 |
|------|------|------|
| **프론트엔드** | React 18 + TypeScript | 실시간 업데이트, 타입 안전 |
| **실시간 통신** | WebSocket + Socket.IO | 1초 이내 지연 |
| **API** | REST (또는 GraphQL) | 기존 게임 API 재사용 |
| **상태 관리** | Redux Toolkit | 복잡한 폼 상태 |
| **차트** | Chart.js 또는 D3.js | 실시간 모니터링 |
| **배포** | Docker + Kubernetes | 높은 가용성, 자동 스케일 |

#### 8.2.2 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────┐
│              Admin Dashboard (React)                    │
├─────────────────────────────────────────────────────────┤
│  • 유저 관리                                            │
│  • 실시간 모니터링                                      │
│  • 게임 밸런싱                                          │
│  • 피처 플래그                                          │
│  • 이벤트 관리                                          │
└─────────────────────────────────────────────────────────┘
                  ↓
          WebSocket + REST API
                  ↓
┌─────────────────────────────────────────────────────────┐
│         Game Backend (Node.js / Python)                 │
├─────────────────────────────────────────────────────────┤
│  • 게임 로직                                            │
│  • 매칭 서버                                            │
│  • 인증 & 권한                                          │
│  • 실시간 이벤트 (Socket.IO)                           │
│  • Config Server (Redis)                                │
└─────────────────────────────────────────────────────────┘
                  ↓
        ┌────────┴────────┐
        ↓                 ↓
   데이터베이스        외부 서비스
   (PostgreSQL/        (분석, 결제,
    MongoDB)           푸시 알림)
```

#### 8.2.3 주요 API 엔드포인트 (관리자용)

```
// 유저 관리
GET    /admin/users?search={query}&page={n}      # 유저 검색
GET    /admin/users/{userId}                      # 상세 정보
POST   /admin/users/{userId}/ban                  # 밴
DELETE /admin/users/{userId}/ban                  # 밴 해제
POST   /admin/users/{userId}/flag                 # 신고

// 게임 밸런싱
GET    /admin/cards                               # 카드 목록
PATCH  /admin/cards/{cardId}                      # 스탯 수정
GET    /admin/cards/{cardId}/stats                # 사용률, 승률

// 모니터링
GET    /admin/metrics/realtime                    # 실시간 지표
GET    /admin/metrics/daily?date={YYYY-MM-DD}    # 일일 통계

// 피처 플래그
GET    /admin/flags                               # 플래그 목록
PATCH  /admin/flags/{flagName}                    # 플래그 수정

// 이벤트
GET    /admin/events                              # 이벤트 목록
POST   /admin/events                              # 이벤트 생성
PATCH  /admin/events/{eventId}                    # 수정

// 권한
GET    /admin/admins                              # 관리자 목록
POST   /admin/admins                              # 관리자 추가
DELETE /admin/admins/{adminId}                    # 관리자 제거
```

---

### 8.3 유사 게임의 관리자 도구 사례

#### 8.3.1 공개 사례 분석

**Hearthstone (Blizzard)**
- ❓ 내부 도구이므로 공개 정보 제한적
- ✅ 알려진 바:
  - 주간 밸런스 리뷰 (패치 노트로 공시)
  - 카드 조정 빈도: 주 1회 (필요 시)
  - 신규 카드 이벤트: 월 1회 (확장팩)
  - A/B 테스트: 특정 플레이어 그룹 대상

**League of Legends (Riot Games)**
- ✅ 공개 정보 많음:
  - 패치 노트 (주 1회)
  - 챔피언 밸런스: 평균 숨겨진 승률 50-52% 목표
  - PBE (Public Beta Environment) 테스트 → 라이브 배포
  - 커뮤니티 피드백 → 밸런스 조정

**Magic: The Gathering Arena (Wizards)**
- ✅ MTG Arena:
  - 월간 밸런스 업데이트
  - 카드 비활성화 (드물게)
  - 매달 신 세트 출시 예정표 공시

#### 8.3.2 바둑이 권장 모델

```
주간 사이클 (매주 월요일 기준):

월요일:
  - 지난주 데이터 분석 (승률, 사용률)
  - 밸런싱 후보 카드 식별

화요일:
  - 밸런싱 안건 검토 (리드 디자이너)
  - 커뮤니티 피드백 수집

수요일:
  - 기술팀: 설정 적용 + 테스트
  - 마케팅: 패치 노트 초안 작성

목요일:
  - QA 테스트
  - 최종 승인

금요일:
  - 00:00 UTC 배포 (플레이어 피해 최소)
  - 라이브 모니터링
  - 긴급 핫픽스 대기

토요일-일요일:
  - 데이터 수집 및 분석
```

---

### 8.4 구현 로드맵

#### Phase 1 (출시 전, 1개월)
- [ ] 기본 어드민 패널 (React + REST API)
- [ ] 유저 검색 및 조회
- [ ] 간단한 밴 시스템
- [ ] 리더보드 조회
- [ ] 기본 모니터링 대시보드

#### Phase 1.5 (출시 후 1-3개월)
- [ ] 실시간 모니터링 (WebSocket)
- [ ] 카드 스탯 조정 UI
- [ ] 피처 플래그 매니저
- [ ] 게임 분석 대시보드

#### Phase 2 (3-6개월)
- [ ] 이벤트 관리 시스템
- [ ] 자동 부정행위 탐지 알고리즘
- [ ] 매출 대시보드
- [ ] IAP 검증 및 거래 모니터링
- [ ] 권한 관리 (Role-Based Access Control)

#### Phase 3 (6개월 이상)
- [ ] A/B 테스트 플랫폼
- [ ] 기계학습 기반 밸런싱 제안
- [ ] 플레이어 세그먼트 분석
- [ ] 자동 이벤트 추천

---

## 최종 시사점 및 전략

### 플랫폼 우선순위
```
1순위: 모바일 (Google Play + Apple App Store)
  → 한국 시장 강세, 최대 수익 기대
  → 6-12개월 운영 후 평가

2순위: PC (Steam)
  → 모바일 성공 후 자연스러운 확장
  → 크로스플레이로 모바일 플레이어 유입

3순위: 웹 (WebGL)
  → 라이트 게이머 대상
  → 모바일/PC 수익의 20-30% 수준 기대
  → 기술적으로 낮은 우선순위
```

### 수익화 전략
```
모바일: IAP 80% + 광고 20%
PC:     IAP 70% + 배틀패스 20% + 광고 10%
웹:     광고 60% + IAP 35% + 구독 5%

총 목표: 월간 활성 사용자 1만명 → 월 매출 10만 달러
```

### 관리자 도구 투자
```
출시 전 필수: 유저 관리, 기본 모니터링, 카드 조정 UI
출시 후 추가: 실시간 대시보드, 자동 부정행위 탐지
운영 안정화 후: 분석 및 A/B 테스트
```

---

## 참고 자료 (전체 출처)

### 시장 규모
- [Amra and Elma LLC - Card Game Marketing Statistics](https://www.amraandelma.com/card-game-marketing-statistics/)
- [Straits Research - Collectible Card Games Market](https://straitsresearch.com/report/collectible-card-games-market)
- [Sensor Tower - State of Gaming 2025](https://www.prnewswire.com/news-releases/sensor-tower-state-of-gaming-gaming-drove-94-billion-in-revenue-in-2025-downloads-reached-52-billion-302696303.html)

### 한국 시장
- [Seoulz - Korea Gaming Industry 2026](https://www.seoulz.com/korea-gaming-industry-2026-esports-economy/)
- [Playio Blog - Korean Mobile Gamer Insights 2026](https://blog.playio.co/korean-mobile-gamer-insights)

### 수익화
- [ASO Mobile - App Monetization 2025](https://asomobile.net/en/blog/mobile-market-money-app-monetization-in-2025/)
- [Tenjin - Ad Monetization Benchmark 2025](https://tenjin.com/blog/ad-mon-gaming-2025/)

### 플랫폼
- [Steam Charts & Analysis](https://store.steampowered.com/charts/bestofyear/2025)
- [Game Marketing Genie - Steam vs Epic](https://gamemarketinggenie.com/blog/steam-vs-epic-game-pros-cons/)

### 기술
- [Unity WebGL Documentation](https://docs.unity3d.com/6000.3/Documentation/Manual/webgl-performance.html)
- [Backtrace - WebGL Performance Issues](https://backtrace.io/blog/memory-and-performance-issues-in-unity-webgl-builds/)

### 크로스플레이
- [BitTopup - Genshin Impact Cross-Save Guide](https://bittopup.com/article/Genshin-Impact-Cross-Save-2025-Complete-Guide-for-All)

---

**리서치 완료일**: 2026-02-26
**작성자**: 게임 플랫폼 리서처
**다음 단계**: 이 리서치 결과를 기반으로 바둑이 SIGIL 파이프라인 S3 (기획서) 작성 시작
