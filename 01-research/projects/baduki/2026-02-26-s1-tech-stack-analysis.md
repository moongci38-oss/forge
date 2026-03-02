# 바둑이(Baduki) 2D 카드 게임: 기술 스택 분석

**작성일**: 2026-02-26
**프로젝트**: Baduki (Unity 6.3 LTS 기반)
**출시 로드맵**: 모바일(1차) → PC 런처(2차) → 웹(3차)
**조사 관점**: 1인 개발자 (AI 보조)

---

## 영역 1: Unity 6.3 LTS 2D 게임 개발

### 1.1 Unity 6.3 LTS 개요

**버전 정보**
- **릴리스**: 2025년 12월 (최신 LTS)
- **지원 기간**: 2년 (2027년 12월까지 보안/버그픽스)
- **사용 강도**: 카드 게임에 적합한 선택 (3D 무거운 엔진에서 2D 최적화 강화)

[신뢰도: **High**]
출처: [Render Arena - Unity 6.3 LTS Released](https://renderarena.com/2025/12/06/unity-6-3-lts-released/), [GameFromScratch - Unity 6.3 Released](https://gamefromscratch.com/unity-6-3-released/), [Unity Releases](https://unity.com/releases/unity-6/support)
접근일: 2026-02-26

### 1.2 2D 개발 핵심 기능

**Unity 6.3 LTS의 2D 강화 기능**

| 기능 | 설명 | 바둑이 활용도 |
|------|------|:---:|
| **2D/3D 혼합 렌더링** | 2D 스프라이트 + 3D 요소를 동일 신에 렌더링 | 🟢 높음 |
| **2D Lights 통합** | 2D 조명이 3D 메시와 상호작용 | 🟡 중간 |
| **Box2D v3 물리** | 저수준 API로 정밀 제어 | 🟢 높음 (카드 애니메이션) |
| **Sprite Masks** | 더 효율적인 마스킹 | 🟡 중간 |
| **크로스플랫폼 Platform Toolkit** | 계정, 저장, 성취도 통합 API | 🟢 높음 |

**주요 특징**
- 통합 Platform Toolkit으로 모바일/PC/웹 간 코드 재사용성 ↑
- 2D 성능 최적화 강화 (물리, 렌더링, 메모리)
- 학습 자료 풍부 (Unity 공식 2D 게임 개발 가이드)

[신뢰도: **High**]
출처: [CG Channel - Unity 6.3 LTS Features](https://www.cgchannel.com/2025/12/unity-6-3-lts-is-out-see-5-key-features-for-cg-artists/), [Unity Manual - 2D Game Development](https://docs.unity3d.com/6000.3/Documentation/Manual/2d-game-development-landing.html)
접근일: 2026-02-26

### 1.3 권장 2D 카드 게임 기술 설정

**최적화된 프로젝트 설정**

```
• Rendering: 2D Renderer (3D 혼합 필요 없으면 URP 대신 사용)
• Physics: Box2D v3 (2D 물리)
• UI: TextMesh Pro + Canvas (또는 UI Toolkit for modern UI)
• Sprite Management: Sprite Atlas (배칭 최적화)
• Build Target: Android/iOS/PC/WebGL
```

**성능 목표치**
- 모바일: 60 FPS (배터리 소비 낮추려면 30 FPS 선택 권장)
- PC: 60 FPS (필수 아님, 안정성 중심)
- 웹: 30 FPS (WebGL 메모리 제약)

---

## 영역 2: 네트워킹 솔루션 비교

### 2.1 주요 선택지 분석

**5가지 네트워킹 솔루션 비교**

| 솔루션 | 가격 | 설정 용이도 | 권장 대상 | 카드 게임 적합도 |
|--------|:---:|:---:|----------|:---:|
| **Unity Netcode** | 무료 | 🟡 중간 | Unity 통합 원함 | 🟢 높음 |
| **Photon Fusion** | 100 CCU 무료 / 200 CCU $95/년 | 🟡 중간 | 상업화 목표 | 🟢 높음 |
| **Photon PUN 2** | 동일 | 🟢 쉬움 | 레거시 호환 | 🟢 높음 |
| **Mirror** | 오픈소스 무료 | 🔴 어려움 | 자체 서버 운영 | 🟢 높음 |
| **FishNet** | 오픈소스 무료 | 🔴 어려움 | 완전 제어 원함 | 🟢 높음 |

### 2.2 각 솔루션 상세 분석

#### **Unity Netcode for GameObjects** ⭐ 추천 1순위

**특징**
- Unity 공식 네트워킹 라이브러리
- High-Level API로 복잡성 감소
- 전용 서버 + P2P 모두 지원
- 무료 (Unity 번들)

**카드 게임에 적합한 이유**
✅ 턴 기반 게임에 최적화
✅ 권한 기반 흐름 제어 쉬움
✅ 모바일/PC/웹 크로스플랫폼
✅ 커뮤니티 사례 증가 중

**단점**
- Photon만큼 성숙하지 않음 (2024-2026 활발히 개선 중)
- CCU 기반 과금 없음 (비용 우수)
- 문서는 개선 중

**권장 대상**: 비용 절감 + Unity 통합을 원하는 1인 개발자

**참고**: [Netcode for turn-based card game](https://discussions.unity.com/t/netcode-for-turn-based-card-game/938869)

---

#### **Photon Fusion** ⭐ 추천 2순위

**특징**
- Photon 최신 고성능 네트워킹
- 100 CCU 무료 (매우 합리적)
- 발달된 매칭메이킹 + 상태 동기화
- 지연시간 최소 (실시간 게임 최적화)

**카드 게임에 적합한 이유**
✅ 카드 게임 사례 많음 (PUN 2 시대부터)
✅ 성숙한 플랫폼
✅ 24/7 고객 지원
✅ 예측 가능한 비용 (100 CCU 무료는 한 해 최대 수만 동시 플레이어)

**단점**
- 200+ CCU일 때 비용 발생 ($95/년 vs $1,440/년)
- 학습곡선 가파름
- Fusion으로 마이그레이션 중 (PUN 2 레거시화)

**비용 계산**
```
초기 (< 100 CCU): $0
성장 (200 CCU): $95/년 (약 $8/월)
대형 (500 CCU): $125/월

카드 게임의 CCU는 동시 매칭 수 기준이므로,
모바일 1만 DAU = 약 50-100 CCU (합리적)
```

**권장 대상**: 상업 운영 준비가 되어있고, 안정성 우선인 개발자

[신뢰도: **High**]
출처: [Photon Fusion Pricing](https://www.photonengine.com/fusion/pricing), [Photon Blog - Free 100 CCU](https://blog.photonengine.com/new-free-100-ccu-for-photon-fusion-and-quantum-games/), [Photon Engine Blog - Pricing Explained](https://blog.photonengine.com/multiplayer-pricing-made-simple/)
접근일: 2026-02-26

---

#### **Mirror** (오픈소스)

**특징**
- 완전 오픈소스 (MIT 라이선스)
- 자체 서버 운영 필수
- 커뮤니티 중심 개발
- CCU 제한 없음

**카드 게임에 적합한 이유**
✅ 턴 기반 게임 예제 풍부
✅ 완전 무료 (서버 비용만)
✅ 여러 동시 게임 예제 제공

**단점**
- 서버 운영 경험 필요
- 문서 < Photon
- 버그 수정 속도 느림 (커뮤니티 의존)

**커뮤니티 사례**
- [A Glimpse of Luna](https://github.com/MirrorNetworking/Mirror) - 전술 카드 게임
- [Untamed Isles](https://github.com/MirrorNetworking/Mirror) - 몬스터 타이밍 MMORPG

**권장 대상**: 서버 운영에 자신 있고, AWS/GCP 비용을 감당할 수 있는 개발자

[신뢰도: **High**]
출처: [Mirror Networking GitHub](https://github.com/MirrorNetworking/Mirror), [Mirror Documentation](https://mirror-networking.gitbook.io/docs/manual/examples), [Longwelwind - Networking of Turn-Based Game](https://longwelwind.net/blog/networking-turn-based-game/)
접근일: 2026-02-26

---

#### **FishNet** (오픈소스, 최신 선택)

**특징**
- 2026년 2월 최신 업데이트 (4.6.22R)
- 원칙: 서버 권한 기반 (보안 우수)
- 매우 유연한 네트워크 토폴로지
- CCU 제한 없음, 서버 호스팅 선택 가능

**카드 게임에 적합한 이유**
✅ 서버 권한 설계로 부정행위 방지
✅ 턴 기반 게임 최적화
✅ 자체 서버 또는 클라우드 선택 자유

**단점**
- Mirror 대비 커뮤니티 작음
- 문서 부족
- 학습곡선 (초급자 부담)

**권장 대상**: 완전 제어 + 보안을 최우선시하는 개발자

[신뢰도: **High**]
출처: [FishNet Asset Store](https://assetstore.unity.com/packages/tools/network/fishnet-networking-evolved-207815), [FishNet GitHub](https://github.com/FirstGearGames/FishNet), [FishNet Documentation](https://fish-networking.gitbook.io/docs)
접근일: 2026-02-26

---

### 2.3 바둑이 권장 선택

#### **1인 개발자 최적 경로**

```
Phase 1 (MVP, 싱글플레이): Netcode for GameObjects 준비
  - 이유: 무료, Unity 통합, 빠른 프로토타입
  - 목표: 3개월 내 베타 출시

Phase 2 (멀티플레이 출시, 1만 DAU 목표): Photon Fusion 전환
  - 이유: 100 CCU 무료는 충분, 안정성 검증
  - 비용: 월 0원 (처음 1년) → $95/년
  - 목표: 안정적 서비스 운영

Phase 3 (자체 서버 검토, 100만+ 누적 플레이어): Mirror 또는 FishNet
  - 이유: 제어 최대화, 비용 효율
  - 추정 시점: 2-3년 후
```

#### **즉시 실행 액션**
1. **Phase 1**: Unity 6.3 + Netcode for GameObjects로 싱글플레이 카드 게임 구현
2. **Phase 2 준비**: Photon Fusion 튜토리얼 병행 (마이그레이션 경로 학습)
3. **서버 아키텍처**: 턴 기반 게임이므로 가벼운 서버 충분 (실시간 게임보다 요구사항 낮음)

---

## 영역 3: 백엔드 솔루션 비교

### 3.1 주요 선택지 분석

**3가지 백엔드 솔루션 비교**

| 솔루션 | 가격 | 관리 부담 | 카드 게임 기능 | 시장 성숙도 |
|--------|:---:|:---:|:---:|:---:|
| **Firebase** | 무료(스파크) ~ 사용량 기반 | 🟢 낮음 | 기본 (커스텀 필요) | ⭐⭐⭐⭐⭐ |
| **PlayFab** | 무료 ~ 규모 기반 | 🟡 중간 | 게임 특화 풍부 | ⭐⭐⭐⭐ |
| **Supabase** | 무료 ~ 사용량 기반 (예측가능) | 🟡 중간 | SQL 커스터마이징 | ⭐⭐⭐ |
| **자체 서버(NestJS)** | 서버 호스팅만 | 🔴 높음 | 완전 제어 | 경험 의존 |

### 3.2 각 솔루션 상세 분석

#### **Firebase** ⭐ 추천 1순위 (초기 단계)

**특징**
- Google의 No-Code 플랫폼
- Firestore (문서 DB) + Realtime Database
- 인증 (Email, Google, Apple 통합)
- 실시간 동기화 (게임 상태 공유)

**강점**
✅ 설정 5분 (Google 계정만 있으면 됨)
✅ 무료 스파크 플랜으로 시작 가능
✅ 모바일 최적화 (네이티브 SDK)
✅ 한국 기업 많이 선택

**약점**
- NoSQL 제약 (복잡한 쿼리 어려움)
- 비용 예측 어려움 (사용량 급증 시 갑자기 비쌈)
- 직접 서버 로직 커스터마이징 어려움
- 대시보드 복잡 (초보자 혼동)

**기대 비용 (1만 DAU 기준)**
```
Spark (개발용): $0
Blaze (본운영):
  - Firestore 읽기: 5만/일 × $0.06/10만 = $30/월
  - Realtime DB: 1GB 저장 × $5 + 100GB 다운로드 × $1 = $105/월
  - 합계: ~$150-200/월 (변동성 높음)
```

**카드 게임 구현 예시**
```
Firestore Collection 구조:
{
  users/
    /{userId}/
      {
        nickname: string,
        elo_rating: number,
        cards: { cardId: quantity },
        gold: number,
        created_at: timestamp
      }

  matches/
    /{matchId}/
      {
        player1_id: string,
        player2_id: string,
        winner_id: string,
        state: "active" | "finished",
        board: [...],
        created_at: timestamp
      }

  leaderboard/
    /{userId}/
      { rank: number, elo: number }
}
```

**권장 대상**: 빠르게 출시하고, 나중에 확장하려는 1인 개발자

[신뢰도: **High**]
출처: [Firebase](https://firebase.google.com), [SaaSHub - Firebase vs PlayFab](https://www.saashub.com/compare-firebase-vs-playfab)
접근일: 2026-02-26

---

#### **PlayFab** ⭐ 추천 2순위 (AAA급 기능 필요 시)

**특징**
- Microsoft의 게임 특화 BaaS
- Player Data, Leaderboards, Inventory (네이티브)
- CloudScript (Node.js 백엔드 로직)
- 통계 및 분석 (기본 포함)

**강점**
✅ 게임 특화 기능 풍부 (카드 게임 바로 적용)
✅ 캐시 레이어 (성능 우수)
✅ 기업 지원 우수
✅ Matchmaking 내장

**약점**
- 초기 설정 복잡 (Azure 연동 필요)
- 비용이 Firebase보다 비쌈 (경험상)
- 프리 티어 제한 많음
- UI/UX 오래됨

**기대 비용 (1만 DAU)**
```
프리 티어:
  - 월 10만 읽기 + 10만 쓰기 + 300GB 스토리지 무료

초과 시:
  - 추가 읽기 1천당 $0.20 = 월 $200 (대략)
  - 합계: 무료 ~ $200+/월
```

**카드 게임 구현 예시**
```
PlayFab 구조 (네이티브):
Players:
  - PlayFabId (중복 없는 고유 ID 자동 생성)
  - CustomData { nickname, level, current_elo }
  - VirtualCurrency { Gold, Gems }
  - Inventory { cardId: { InstanceId, … } }

TitleData (설정):
  - Card Definitions (카드 스탯)
  - Event Schedule (시즌, 배틀패스)
  - Maintenance Window

CloudScript:
  - 매칭 로직
  - 게임 결과 검증
  - 보상 계산
```

**권장 대상**: 장기 운영 준비 + 게임 고급 기능 필요한 팀

[신뢰도: **High**]
출처: [StackShare - PlayFab vs Supabase](https://stackshare.io/stackups/playfab-vs-supabase), [Blog Back4App - PlayFab vs Firebase](https://blog.back4app.com/playfab-vs-firebase/)
접근일: 2026-02-26

---

#### **Supabase** (PostgreSQL 기반)

**특징**
- 오픈소스 Firebase 대체 (PostgreSQL)
- 완전한 SQL 쿼리 가능
- 자체 호스팅 옵션
- 예측 가능한 가격

**강점**
✅ SQL의 강력함 (복잡한 쿼리 쉬움)
✅ 자체 호스팅 가능 (비용 제어)
✅ 현재 Firebase보다 저렴
✅ PostgreSQL 표준 (마이그레이션 쉬움)

**약점**
- 게임 특화 기능 부족 (PlayFab 레벨 X)
- 커뮤니티 < Firebase/PlayFab
- 커스텀 코딩 많이 필요
- 모바일 SDK 미흡

**기대 비용 (1만 DAU)**
```
프리 플랜:
  - 500MB 스토리지, 월 5만 API 호출 무료

프로 플랜:
  - $25/월 기본 + 초과 사용량

비용 예측: $25-50/월 (매우 예측가능)
```

**권장 대상**: SQL 숙련 + 비용 예측성 중요한 개발자 (1-2인 팀)

[신뢰도: **High**]
출처: [ClickitTech - Supabase vs Firebase 2026](https://www.clickittech.com/software-development/supabase-vs-firebase/), [The Software Scout - Supabase vs Firebase](https://thesoftwarescout.com/supabase-vs-firebase-2026-which-backend-should-you-choose/), [MakerKit - Firebase vs Supabase](https://makerkit.dev/blog/saas/supabase-vs-firebase)
접근일: 2026-02-26

---

### 3.3 바둑이 권장 선택

#### **2단계 백엔드 전략**

```
Phase 1 (0-3개월, 싱글플레이 + 간단 온라인):
  → Firebase (Spark 플랜)
  - 비용: 무료
  - 설정 시간: 1시간
  - 기능: 유저 인증, 점수 저장, 친구 목록

Phase 2 (3-12개월, 풀 멀티플레이 + 시즌 시스템):
  → Firebase (Blaze) 또는 PlayFab 전환
  - Firebase: 빠른 확장 (계속 무료 또는 저비용)
  - PlayFab: 안정성/기능 최우선
  - 목표 비용: $100-200/월
```

#### **즉시 실행 액션**
```bash
# Firebase 세팅 (15분)
1. Google Cloud Console에서 새 프로젝트 생성
2. Firestore 활성화 (선택: Native 또는 Datastore)
3. Firebase Authentication 활성화 (Google, Apple, Email)
4. Unity용 Firebase SDK 설치
   - https://firebase.google.com/download/unity

# 초기 Firestore 스키마 (카드 게임용)
users/{userId}:
  - nickname: string
  - elo: number (랭킹)
  - gold: number
  - gems: number (유료화폐)
  - cards: map<cardId, quantity>
  - profile_image_url: string
  - updated_at: timestamp

matches/{matchId}:
  - player1_id: string
  - player2_id: string
  - winner_id: string (null = 진행 중)
  - state: "waiting" | "playing" | "finished"
  - created_at: timestamp
  - finished_at: timestamp (null = 진행 중)
```

---

## 영역 4: 턴 기반 카드 게임 멀티플레이 아키텍처

### 4.1 아키텍처 모델 선택

**3가지 동기화 모델**

| 모델 | 설명 | 레이턴시 | 부정행위 방지 | 대역폭 | 카드 게임 적합도 |
|------|------|:---:|:---:|:---:|:---:|
| **상태 동기화** | 서버가 주기적 상태 전송 | 높음 | 🟢 | 🔴 높음 | 🔴 부적합 |
| **결정론적 록스텝** | 로컬 예측 + 서버 확인 | 낮음 | 🟡 | 🟢 낮음 | 🟡 중간 |
| **서버 권한 모델** | 모든 로직이 서버 기반 | 중간 | 🟢🟢 | 🟢 | ⭐⭐⭐⭐⭐ |

### 4.2 바둑이에 최적 아키텍처: 서버 권한 모델

**특징**
- 모든 게임 로직이 서버에서 실행
- 클라이언트는 "Action"만 전송 (카드 선택, 턴 종료 등)
- 서버가 검증 후 새 상태 브로드캐스트
- 부정행위 불가능 (서버가 모든 결정)

**구현 흐름**

```
┌─────────────┐                 ┌──────────────┐
│   Player A  │                 │   Player B   │
│  (Client)   │                 │  (Client)    │
└──────┬──────┘                 └──────┬───────┘
       │                               │
       │ "Play card ID=42"             │
       │──────────────────────────────→│
       │                         ┌─────▼──────┐
       │                         │   Server   │
       │                         │  (Logic)   │
       │                         └─────┬──────┘
       │                               │
       │ ┌─ 검증 ─┐                    │
       │ │ - 해당 카드 있나?            │
       │ │ - 비용 충분한가?            │
       │ │ - 타겟 유효한가?             │
       │ │ - 부정행위 신호?             │
       │ └────────┘                    │
       │                               │
       │ "New State: board=[...]"      │
       │←──────────────────────────────│
       │                               │
       │ "New State: board=[...]"      │
       │                    ──────────→│
       ▼                               ▼
  [UI 업데이트]                [UI 업데이트]
```

**구현 세부사항**

```
// Server Endpoint
POST /api/game/{matchId}/play-card
{
  playerId: string,
  cardId: string,
  targetId?: string,  // 대상 카드/플레이어
  from: "hand" | "board"
}

// Server Response
{
  status: "success" | "error",
  message?: string,

  // 성공 시
  newState: {
    board: Card[],
    hand1: Card[],
    hand2: Card[],
    p1_health: number,
    p2_health: number,
    current_turn: "p1" | "p2",
    mana_used: { p1: number, p2: number }
  },

  // 에러 시
  errorCode: "invalid_card" | "insufficient_mana" | "cheating_detected"
}

// 타임아웃/네트워크 오류 시
// 클라이언트는 자동으로 상태 폴 (GET /api/game/{matchId}/state)
GET /api/game/{matchId}/state
→ authoritative server state 재수신
```

**UI/UX 최적화**

```
로컬 예측 (responsiveness):
1. 플레이어가 카드 선택
2. 클라이언트가 즉시 "ghost" 애니메이션 시작 (시각적 피드백)
3. 서버에 요청 전송
4. 서버 응답 대기 중...
5. 응답 도착 → 서버 상태 맞춤 (맞으면 부드러운 계속, 틀리면 스냅백)

예시: 카드 "검"을 보드에 배치
- T0: 플레이어 터치
- T0+50ms: 클라이언트 ghost 이동 애니메이션 (비활성 상태)
- T0+100ms: 서버 요청 송신
- T0+200ms: 서버 응답 (유효함)
- T0+250ms: 최종 상태 반영 (대부분 일치, 부드러운 transition)

최악의 경우: 카드가 부정행위이거나 비용 부족
- 스냅백 애니메이션 (자연스러운 취소)
- 사용자: "아, 비용이 부족하구나" (피드백 명확)
```

[신뢰도: **High**]
출처: [DevelopersVoice - Real-Time Multiplayer Card Games Architecture](https://developersvoice.com/blog/practical-design/realtime-card-games-net-architecture-guide/), [Longwelwind - Networking of Turn-Based Game](https://longwelwind.net/blog/networking-turn-based-game/), [Gabriel Gambetta - Client-Server Game Architecture](https://www.gabrielgambetta.com/client-server-game-architecture.html)
접근일: 2026-02-26

### 4.3 부정행위 방지 체크리스트

```
서버 검증 체크:
□ 해당 플레이어의 턴인가?
□ 플레이어가 해당 카드를 소유하고 있나?
□ 카드를 사용할 충분한 자원(마나, 비용)이 있나?
□ 카드의 타겟이 유효한가?
□ 타겟 카드/플레이어가 보호 상태는 아닌가?
□ 같은 플레이어에서 2초 이내 중복 요청은 아닌가? (클릭 스팸 방지)
□ 게임 상태가 "playing" 상태인가? (이미 끝나지 않았나?)
□ 비정상적 게임 진행 패턴은 없나? (초고속 카드 드로우, 무한 루프 등)
```

---

## 영역 5: CI/CD & DevOps

### 5.1 주요 선택지

**모바일 게임 CI/CD 솔루션 비교**

| 솔루션 | 가격 | 설정 | 플랫폼 | 추천도 |
|--------|:---:|:---:|:---:|:---:|
| **Unity Cloud Build** | 무료 ~ 유료 | 🟢 쉬움 | iOS/Android 공식 | 🟡 중간 |
| **GitHub Actions** | 무료 (OSS 무제한) | 🟡 중간 | All | ⭐⭐⭐⭐⭐ |
| **Jenkins** | 자체 호스팅 | 🔴 어려움 | All | 🟡 중간 |
| **CircleCI** | 무료 ~ 유료 | 🟡 중간 | iOS/Android | 🟡 중간 |

### 5.2 GitHub Actions ⭐ 추천

**특징**
- GitHub 저장소 기본 포함 (무료)
- GameCI 커뮤니티 프로젝트로 Unity 빌드 간편화
- 오픈소스 = 무제한 분 (2,000분/월 유료 계정 대비)

**설정 예시**

```yaml
# .github/workflows/build.yml
name: Unity Build

on:
  push:
    branches: [ develop, main ]
  pull_request:
    branches: [ develop, main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    # 1. 저장소 체크아웃
    - uses: actions/checkout@v3
      with:
        fetch-depth: 0  # Git history 전체

    # 2. Unity 라이브러리 캐시 (빌드 속도 ↑)
    - uses: actions/cache@v3
      with:
        path: Library
        key: Library-Build-${{ hashFiles('Assets/**', 'Packages/**', 'ProjectSettings/**') }}
        restore-keys: |
          Library-Build-
          Library-

    # 3. 테스트 실행
    - uses: game-ci/unity-test-runner@v4
      with:
        unityVersion: 6.3.0f1
        testMode: all  # Edit + Play Mode

    # 4. Android 빌드 (.aab)
    - uses: game-ci/unity-builder@v4
      with:
        unityVersion: 6.3.0f1
        targetPlatform: Android
        buildsPath: builds

    # 5. iOS 빌드 (Xcode)
    - uses: game-ci/unity-builder@v4
      if: runner.os == 'macos-latest'
      with:
        unityVersion: 6.3.0f1
        targetPlatform: iOS
        buildsPath: builds

    # 6. 빌드 산출물 업로드
    - uses: actions/upload-artifact@v3
      with:
        name: Build-${{ matrix.targetPlatform }}
        path: builds/${{ matrix.targetPlatform }}

    # 7. 테스트 결과 리포트
    - uses: test-summary/action@v2
      with:
        paths: |
          TestResults/**/*.xml
```

**실행 흐름**

```
Develop 브랜치에 Push
    ↓
GitHub Actions 자동 트리거
    ├─ 코드 체크아웃
    ├─ Unity 테스트 실행 (Edit Mode + Play Mode)
    │  ├─ 유닛 테스트 (게임 로직)
    │  └─ 통합 테스트 (UI, 네트워킹)
    ├─ Android 빌드 (.aab)
    │  └─ 캐시 적용 (3-5분 단축)
    ├─ 빌드 산출물 저장
    └─ 테스트 결과 리포트

결과:
  ✅ PASS → 테스트 성공 배지 + 바이너리 다운로드 가능
  ❌ FAIL → 상세 로그 + 실패 위치 강조
```

**커스터마이제이션 (선택사항)**

```yaml
# 배포 (Google Play Store)
deploy-android:
  runs-on: ubuntu-latest
  needs: build

  steps:
  - name: 👤 Authenticate to Google Play
    uses: r0adkll/upload-google-play@v1
    with:
      serviceAccountJson: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
      packageName: com.baduki.game
      releaseFiles: 'builds/Android/*.aab'
      track: internal  # internal → alpha → beta → production
      userFraction: 0.25  # 25%의 유저에게만 배포 (staged rollout)
```

**비용**
```
무료: 공개 저장소 + 무제한 분
     (GitHub Actions 분 제한 = 월 2,000분, 충분함)

프라이빗: $0.008/분 (월 ~$6)
```

[신뢰도: **High**]
출처: [Anchorpoint - Setting up CI/CD for Unity with GitHub Actions](https://www.anchorpoint.app/blog/setting-up-a-ci-cd-build-pipeline-for-unity-using-github-actions), [GameCI - Getting Started](https://game.ci/docs/github/getting-started/), [GitHub Marketplace - Unity Builder](https://github.com/marketplace/actions/unity-builder)
접근일: 2026-02-26

### 5.3 테스트 자동화 (Unity Test Framework)

**체크리스트**

```
Phase 1 (출시 전):
□ 유닛 테스트: 카드 능력 로직 (데미지 계산, 효과)
□ 유닛 테스트: 매칭 로직 (ELO 계산)
□ 통합 테스트: 게임 진행 (카드 드로우 → 플레이 → 승리 판정)

Phase 2 (출시 후):
□ 회귀 테스트: 패치 후 기존 기능 유지
□ 성능 테스트: 메모리 누수, 프레임 드롭
□ 모바일 테스트: 실기기 (iPhone + Galaxy)

GitHub Actions로 자동화:
- 매 Push마다 전체 테스트 실행 (5-10분)
- 테스트 실패 시 PR 병합 차단
- 테스트 커버리지 리포트 (CI에 첨부)
```

[신뢰도: **High**]
출처: [Unity - Automated Tests with Unity Test Framework](https://unity.com/how-to/automated-tests-unity-test-framework), [HeadSpin - Mastering Automated Testing](https://www.headspin.io/blog/unity-test-framework-for-running-automated-testing), [LambdaTest - Unity Testing Guide](https://www.lambdatest.com/blog/unity-testing/)
접근일: 2026-02-26

---

## 영역 6: 2D 성능 최적화

### 6.1 모바일 2D 최적화 핵심

**3가지 성능 병목**

| 병목 | 증상 | 해결책 | 카드 게임 영향 |
|------|------|--------|:---:|
| **드로우콜** | 프레임 드롭 | Sprite Atlas | 높음 |
| **텍스처 메모리** | 크래시 | Compression | 높음 |
| **배터리** | 과열/빠른 소진 | FPS 캡 30 | 중간 |

### 6.2 최적화 기법

**Sprite Atlas** (가장 중요)

```
최적화 전:
  카드 1장 = 별도 텍스처 파일
  → 드로우콜 10+ (1초에 수십 번)

최적화 후:
  모든 카드 스프라이트 → 1개 텍스처 (Sprite Atlas)
  → 드로우콜 1 (배칭으로 통합 렌더링)

결과: 프레임 60 → 화면 50개 카드 표시 가능
```

**텍스처 압축**

```
원본: card.png (1024x1024, RGBA 비압축)
  = 4MB (메모리)

압축 후: ASTC 6x6
  = 1MB (메모리)
  = 설정: Edit → Project Settings → Editor → Default Texture Compression
```

**배터리 최적화**

```
Unity 설정:
  Edit → Project Settings → Quality
  → VSync: Enabled
  → Target Frame Rate: 30 (모바일)
  → Fixed Timestep: 0.033s

효과:
  - 배터리 소비 50% 감소
  - 게임 플레이 (턴 기반)은 30 FPS로 충분
  - 실제 게임 구동 시간 3시간 연속 가능 (vs 60 FPS 1.5시간)
```

[신뢰도: **High**]
출처: [Unity Blog - Optimize Mobile Game Performance](https://blog.unity.com/technology/optimize-your-mobile-game-performance-expert-tips-on-graphics-and-assets), [Medium - Optimizing Build Size with Sprite Setup](https://medium.com/@bada/optimizing-build-size-and-performance-with-proper-sprite-setup-7c76c91626b6), [Damian Connolly - Performance Tips for Unity 2D Mobile](https://divillysausages.com/2016/01/21/performance-tips-for-unity-2d-mobile/)
접근일: 2026-02-26

### 6.3 성능 목표

```
성능 목표 (카드 게임):
  모바일: 30 FPS 고정 (배터리 최우선)
  PC: 60 FPS
  메모리: < 200MB (기기)
  초기 로딩: < 3초
  앱 크기: < 100MB
```

---

## 최종 권장 기술 스택 (1인 개발자)

### Phase 1 (MVP, 싱글플레이) — 3-4개월

```
게임 엔진:     Unity 6.3 LTS
언어:          C#
2D 렌더링:     2D Renderer + Sprite Atlas
물리:          Box2D v3
UI:            TextMesh Pro + Canvas
데이터베이스:  Firebase (Spark 플랜, 무료)
인증:          Firebase Authentication
네트워킹:      Netcode for GameObjects (준비 단계)
CI/CD:         GitHub Actions (테스트만)
```

**기대치**
- 비용: $0 (무료)
- 개발 기간: 3-4개월
- 산출물: 싱글플레이 + 프렌드 대전 기능

### Phase 2 (멀티플레이 런칭) — 6-12개월

```
게임 엔진:     Unity 6.3 LTS (동일)
네트워킹:      Photon Fusion (100 CCU 무료)
데이터베이스:  Firebase (Blaze 플랜) 또는 PlayFab 전환
백엔드:        NestJS/Express (매칭, 랭킹)
배포:          Google Play Store + Apple App Store
CI/CD:         GitHub Actions (테스트 + 빌드 + 배포)
```

**기대 비용**
```
개발: 무료 (네트워킹은 Photon 100 CCU 무료)
운영: $100-200/월
  - Firebase/PlayFab: $50-100/월
  - 서버 호스팅 (NestJS): $20-50/월 (AWS t3.micro)
  - CDN (이미지): $0-30/월
```

### Phase 3 (2년+, 향후 검토)

```
스케일링 옵션:
  옵션 1: Photon Fusion 유지 ($200-500/월)
  옵션 2: Mirror + 자체 서버 전환 (비용 절감, 운영 복잡도 ↑)
  옵션 3: PlayFab 전환 (기능 극대화, 비용 ↑)
```

---

## 최종 실행 액션 아이템

### 즉시 (이번 주)

```
□ Unity 6.3 LTS 다운로드 및 설치
□ 새 2D 프로젝트 생성
  설정:
    - Render Pipeline: 2D Renderer
    - Physics: 2D
    - Default Scripting Modules: C#

□ GitHub 저장소 생성
  - .gitignore (Unity용)
  - README.md (프로젝트 설명)
  - .github/workflows/test.yml (GitHub Actions)
```

### 1주 내

```
□ Firebase 계정 생성 (Google Cloud)
□ Firestore 데이터베이스 초기화
□ Firebase 인증 (이메일, Google 로그인) 설정
□ Unity Firebase SDK 설치
□ 간단한 유저 등록 + 로그인 구현
```

### 2주 내

```
□ Netcode for GameObjects 튜토리얼 학습
□ 싱글플레이 카드 게임 로직 구현 (50%)
□ 게임 상태 Firebase에 저장
□ 유닛 테스트 추가 (카드 능력 로직)
```

### 1개월 내

```
□ 싱글플레이 완성
□ Photon Fusion 계정 생성 (무료 100 CCU)
□ Fusion 튜토리얼 학습
□ 프레임워크 프로토타입 (매칭 → 게임 시작 → 결과)
```

---

## 참고 자료 (전체 출처)

### Unity 6.3 LTS
- [Render Arena - Unity 6.3 LTS Released](https://renderarena.com/2025/12/06/unity-6-3-lts-released/)
- [CG Channel - Unity 6.3 Features](https://www.cgchannel.com/2025/12/unity-6-3-lts-is-out-see-5-key-features-for-cg-artists/)
- [Unity Manual - 2D Game Development](https://docs.unity3d.com/6000.3/Documentation/Manual/2d-game-development-landing.html)

### 네트워킹
- [Unity Discussions - Netcode for Turn-Based Card Game](https://discussions.unity.com/t/netcode-for-turn-based-card-game/938869/)
- [Photon Fusion Pricing](https://www.photonengine.com/fusion/pricing)
- [Photon Blog - Multiplayer Pricing](https://blog.photonengine.com/multiplayer-pricing-made-simple/)
- [Mirror Networking GitHub](https://github.com/MirrorNetworking/Mirror)
- [FishNet Asset Store](https://assetstore.unity.com/packages/tools/network/fishnet-networking-evolved-207815)

### 백엔드
- [SaaSHub - Firebase vs PlayFab](https://www.saashub.com/compare-firebase-vs-playfab)
- [ClickitTech - Supabase vs Firebase 2026](https://www.clickittech.com/software-development/supabase-vs-firebase/)
- [MakerKit - Supabase vs Firebase](https://makerkit.dev/blog/saas/supabase-vs-firebase)

### 아키텍처
- [DevelopersVoice - Real-Time Multiplayer Card Games](https://developersvoice.com/blog/practical-design/realtime-card-games-net-architecture-guide/)
- [Longwelwind - Networking Turn-Based Game](https://longwelwind.net/blog/networking-turn-based-game/)
- [Gabriel Gambetta - Client-Server Architecture](https://www.gabrielgambetta.com/client-server-game-architecture.html)

### CI/CD
- [Anchorpoint - CI/CD for Unity](https://www.anchorpoint.app/blog/setting-up-a-ci-cd-build-pipeline-for-unity-using-github-actions)
- [GameCI - Getting Started](https://game.ci/docs/github/getting-started/)
- [GitHub Marketplace - Unity Builder](https://github.com/marketplace/actions/unity-builder)

### 성능 최적화
- [Unity Blog - Mobile Game Performance](https://blog.unity.com/technology/optimize-your-mobile-game-performance-expert-tips-on-graphics-and-assets)
- [Medium - Sprite Optimization](https://medium.com/@bada/optimizing-build-size-and-performance-with-proper-sprite-setup-7c76c91626b6)
- [Unity Test Framework](https://unity.com/how-to/automated-tests-unity-test-framework)

---

**리서치 완료일**: 2026-02-26
**작성자**: 게임 기술 리서처
**다음 단계**: 이 기술 스택을 기반으로 바둑이 SIGIL 파이프라인 S3 (PRD) 작성 진행
