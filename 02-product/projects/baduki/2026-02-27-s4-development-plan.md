# 로우 바둑이 (Low Baduki) — S4 상세 개발 계획 (서비스 + 관리자 통합)

**작성일**: 2026-02-27
**프로젝트 유형**: 게임 개발 (SIGIL S4 — 개발 트랙)
**입력 문서**: S3 GDD `02-product/projects/baduki/2026-02-27-s3-gdd.md`
**방법론**: C4 Model + ADR + Trine 세션 로드맵

---

## 목차

1. [기술 스택](#1-기술-스택)
2. [아키텍처 (C4 Model)](#2-아키텍처-c4-model)
3. [개발 환경](#3-개발-환경)
4. [ADR (Architecture Decision Records)](#4-adr-architecture-decision-records)
5. [Unity AI 활용 계획](#5-unity-ai-활용-계획)
6. [Trine 세션 로드맵](#6-trine-세션-로드맵)

---

## 1. 기술 스택

### 1.1 게임 클라이언트

| 레이어 | 기술 | 버전 | 선택 근거 |
|--------|------|------|---------|
| 게임 엔진 | Unity | 6.3 LTS | 크로스플랫폼(Android/iOS/PC/WebGL), 2D 최적화, Unity AI 3대 기능 풀 지원 |
| 언어 | C# | .NET 7+ | Unity 표준, 강타입, 풍부한 에코시스템 |
| 2D 렌더러 | 2D Renderer (URP) | - | 카드 게임에 최적화된 경량 렌더 파이프라인 |
| 물리 | Box2D v3 | - | 카드 애니메이션 물리, 멀티스레드 지원 |
| UI 프레임워크 | UI Toolkit + TextMesh Pro | - | 모던 UI 바인딩, 한글 폰트 최적화 |
| AI 추론 | Unity Inference Engine | (구 Sentis) | 온디바이스 ONNX 추론, NPU 가속 |
| 트윈 애니메이션 | DOTween | 1.2+ | 카드/칩 애니메이션 이징 |

### 1.2 네트워크

| 레이어 | 기술 | Phase | 비용 | 선택 근거 |
|--------|------|:-----:|:---:|---------|
| Phase 1 (프로토타입) | Unity Netcode for GameObjects | 1 | $0 | Unity 기본 제공, 소규모 테스트 충분 |
| Phase 2 (소프트 런치) | Photon Fusion | 2 | $0 (100 CCU 이하) | 안정적 매칭, Room 관리, 검증된 솔루션 |
| Phase 3+ (스케일) | Photon Fusion 업그레이드 | 3+ | $95/년+ | 100 CCU 초과 시 자동 확장 |
| 프로토콜 | WebSocket (TCP) | - | - | 턴 기반 게임에 적합, 안정적 전송 보장 |

### 1.3 백엔드 (게임 서비스)

| 레이어 | 기술 | 버전 | 선택 근거 |
|--------|------|------|---------|
| 인증 | Firebase Authentication | - | Google/Apple/게스트 원클릭, 무료 |
| 데이터베이스 | Firebase Firestore | - | NoSQL 문서 DB, 실시간 동기화, 모바일 SDK |
| 실시간 DB | Firebase Realtime Database | - | 게임 상태 실시간 동기화 보조 |
| 서버리스 로직 | Firebase Cloud Functions | Node.js 18 | 매칭, ELO 업데이트, 보상 지급, IAP 검증 |
| 분석 | Firebase Analytics + Crashlytics | - | 행동 분석, 리텐션 추적, 크래시 리포팅 |
| 원격 설정 | Firebase Remote Config | - | 피처 플래그, 밸런스 수치 원격 변경 |
| 광고 | Google AdMob | - | 리워드 광고, 모바일 네이티브 |

### 1.4 관리자 웹 애플리케이션

| 레이어 | 기술 | 버전 | 선택 근거 |
|--------|------|------|---------|
| 프론트엔드 | React | 18 | 컴포넌트 기반 UI, 풍부한 에코시스템 |
| 언어 | TypeScript | 5.x | 타입 안전성, 대규모 코드베이스 관리 |
| 스타일링 | Tailwind CSS | 3.x | 유틸리티 퍼스트, 빠른 프로토타이핑 |
| 차트/시각화 | Recharts + D3.js | - | 실시간 모니터링, KPI 대시보드 |
| 실시간 | Socket.IO | 4.x | 양방향 실시간 통신, 모니터링 데이터 스트림 |
| 상태 관리 | Zustand | 4.x | 경량 상태 관리, React hooks 친화적 |
| HTTP 클라이언트 | Axios + React Query | - | API 호출 캐싱, 자동 재시도 |

### 1.5 관리자 백엔드

| 레이어 | 기술 | 버전 | 선택 근거 |
|--------|------|------|---------|
| 런타임 | Node.js | 20 LTS | JavaScript 생태계 공유, Firebase Functions와 동일 런타임 |
| 프레임워크 | Express | 4.x | 경량 REST API, 미들웨어 패턴 |
| ORM | Prisma | 5.x | TypeScript 친화, 자동 마이그레이션 |
| 데이터베이스 | PostgreSQL | 16 | 관계형 데이터(유저 관리, 제재, 로그), JSONB 지원 |
| 캐싱 | Redis | 7.x | 실시간 모니터링 데이터 캐싱, 세션 관리 |
| 인증 | JWT + bcrypt | - | Stateless 인증, 관리자 RBAC |
| 배포 | Docker + Nginx | - | 컨테이너 격리, 리버스 프록시 |

### 1.6 CI/CD

| 도구 | 용도 | 비용 |
|------|------|:---:|
| GitHub Actions | 자동 빌드/테스트/배포 파이프라인 | $0 (2,000분/월) |
| GameCI | Unity Android/iOS 빌드 액션 | $0 |
| Firebase CLI | Cloud Functions 배포, Firestore 규칙 배포 | $0 |
| Docker Hub | 관리자 백엔드 이미지 레지스트리 | $0 |

---

## 2. 아키텍처 (C4 Model)

### 2.1 Context Diagram (시스템 컨텍스트)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          외부 시스템 / 유저                                  │
│                                                                             │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│  │ 플레이어  │    │  관리자   │    │  Google  │    │  Apple   │              │
│  │ (모바일)  │    │  (웹)    │    │  Play    │    │  App     │              │
│  └────┬─────┘    └────┬─────┘    │  Store   │    │  Store   │              │
│       │               │          └────┬─────┘    └────┬─────┘              │
│       │               │               │               │                     │
└───────┼───────────────┼───────────────┼───────────────┼─────────────────────┘
        │               │               │               │
        ▼               ▼               │               │
┌───────────────┐ ┌───────────────┐    │               │
│ 로우 바둑이    │ │ 관리자 웹     │    │               │
│ 게임 클라이언트│ │ 애플리케이션   │    │               │
│ (Unity)       │ │ (React)       │    │               │
└───────┬───────┘ └───────┬───────┘    │               │
        │                 │            │               │
        ▼                 ▼            ▼               ▼
┌──────────────────────────────────────────────────────────────┐
│                     Firebase Platform                         │
│  ┌──────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌───────┐ │
│  │ Auth │ │ Firestore│ │ Cloud    │ │ Analytics│ │Remote │ │
│  │      │ │          │ │ Functions│ │ +Crash   │ │Config │ │
│  └──────┘ └──────────┘ └──────────┘ └──────────┘ └───────┘ │
└──────────────────────────────────────────────────────────────┘
        │                 │
        │                 ▼
        │         ┌───────────────┐
        │         │ 관리자 백엔드  │
        │         │ (Node.js)     │
        │         └───────┬───────┘
        │                 │
        │                 ▼
        │         ┌──────────────────┐
        │         │ PostgreSQL+Redis │
        │         └──────────────────┘
        │
        ▼
┌───────────────┐    ┌───────────────┐
│ Google AdMob  │    │ Photon Fusion │
│ (리워드 광고)  │    │ (멀티플레이)   │
└───────────────┘    └───────────────┘
```

### 2.2 Container Diagram (컨테이너)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    로우 바둑이 시스템                                 │
│                                                                     │
│  ┌─────────────────────────────┐  ┌───────────────────────────────┐ │
│  │  Unity Game Client          │  │  Admin React App              │ │
│  │                             │  │                               │ │
│  │  ┌───────────────────────┐  │  │  ┌────────────────────────┐  │ │
│  │  │ Game Logic Layer      │  │  │  │ Dashboard Pages        │  │ │
│  │  │ (규칙/족보/FSM)       │  │  │  │ (모니터링/유저/밸런싱) │  │ │
│  │  └───────────────────────┘  │  │  └────────────────────────┘  │ │
│  │  ┌───────────────────────┐  │  │  ┌────────────────────────┐  │ │
│  │  │ AI Engine Layer       │  │  │  │ Real-time Layer        │  │ │
│  │  │ (Rule/MCTS/CFR)       │  │  │  │ (Socket.IO Client)     │  │ │
│  │  │ (Inference Engine)    │  │  │  └────────────────────────┘  │ │
│  │  └───────────────────────┘  │  │  ┌────────────────────────┐  │ │
│  │  ┌───────────────────────┐  │  │  │ API Client             │  │ │
│  │  │ UI Layer (UI Toolkit) │  │  │  │ (Axios + React Query)  │  │ │
│  │  └───────────────────────┘  │  │  └────────────────────────┘  │ │
│  │  ┌───────────────────────┐  │  └───────────────────────────────┘ │
│  │  │ Network Layer         │  │                                    │
│  │  │ (Netcode/Photon)      │  │  ┌───────────────────────────────┐ │
│  │  └───────────────────────┘  │  │  Admin API Server             │ │
│  │  ┌───────────────────────┐  │  │  (Node.js + Express)          │ │
│  │  │ Firebase SDK Layer    │  │  │                               │ │
│  │  └───────────────────────┘  │  │  ┌────────────────────────┐  │ │
│  └─────────────────────────────┘  │  │ REST API Endpoints     │  │ │
│                                   │  │ (유저/밸런싱/피처플래그)│  │ │
│  ┌─────────────────────────────┐  │  └────────────────────────┘  │ │
│  │  Firebase Cloud Functions   │  │  ┌────────────────────────┐  │ │
│  │                             │  │  │ Socket.IO Server       │  │ │
│  │  - matchmaking()            │  │  │ (실시간 모니터링)      │  │ │
│  │  - updateELO()              │  │  └────────────────────────┘  │ │
│  │  - processReward()          │  │  ┌────────────────────────┐  │ │
│  │  - verifyIAP()              │  │  │ Prisma ORM             │  │ │
│  │  - seasonReset()            │  │  │ (PostgreSQL 16)        │  │ │
│  │  - reportProcessing()       │  │  └────────────────────────┘  │ │
│  └─────────────────────────────┘  │  ┌────────────────────────┐  │ │
│                                   │  │ Redis Cache            │  │ │
│                                   │  │ (세션/실시간 데이터)    │  │ │
│                                   │  └────────────────────────┘  │ │
│                                   └───────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.3 Component Diagram (주요 컴포넌트 — 게임 클라이언트)

```
Unity Game Client Components:

┌─ Game Logic ──────────────────────────────────────────────┐
│                                                           │
│  CardDeck          → 52장 덱 관리, 셔플, 드로우 풀       │
│  HandEvaluator     → 족보 판정 (Made/Base/TwoBase/None)  │
│  BettingManager    → 베팅 라운드 관리, 팟, 사이드 팟     │
│  DrawManager       → 3회 드로우 처리, 교환 장수 공개     │
│  GameStateMachine  → FSM (Waiting→Deal→Bet→Draw→Show)    │
│  ShowdownResolver  → 쇼다운 판정, 팟 분배                │
│  TurnTimer         → 베팅 20초/드로우 15초, 자동 액션    │
│  BlindManager      → SB/BB 관리, 딜러 로테이션           │
│                                                           │
└───────────────────────────────────────────────────────────┘

┌─ AI Engine ───────────────────────────────────────────────┐
│                                                           │
│  IBotStrategy      → 봇 전략 인터페이스                   │
│  EasyBot           → Rule-Based LUT, 1% 블러핑           │
│  MediumBot         → Heuristic + MCTS, 20-30% 블러핑     │
│  HardBot           → CFR ONNX 모델, GTO 블러핑           │
│  InferenceRunner   → Unity Inference Engine 래퍼          │
│  BotProfiler       → AI 응답 시간 제어 (의도적 지연)     │
│                                                           │
└───────────────────────────────────────────────────────────┘

┌─ UI Layer ────────────────────────────────────────────────┐
│                                                           │
│  LobbyScreen       → 메인 로비, 모드 선택, 탭 바         │
│  GameTableScreen   → 게임 테이블, 핸드, 베팅 버튼        │
│  ShowdownScreen    → 카드 공개, 족보 비교 연출            │
│  ResultScreen      → 승/패, 보상, ELO 변동               │
│  TutorialManager   → 5단계 인터랙티브 튜토리얼           │
│  ShopScreen        → 코스메틱 상점, 젬 충전               │
│  CardAnimator      → 카드 배분/교환/뒤집기 애니메이션    │
│  ChipAnimator      → 칩 이동/팟 분배 애니메이션          │
│                                                           │
└───────────────────────────────────────────────────────────┘

┌─ Network Layer ───────────────────────────────────────────┐
│                                                           │
│  NetworkManager    → Netcode/Photon 연결 관리             │
│  MatchmakingClient → ELO 기반 매칭 요청/응답             │
│  GameSyncManager   → 게임 상태 동기화, 액션 브로드캐스트 │
│  RoomManager       → 친구 대전 방 생성/참가              │
│  ReconnectHandler  → 재접속 처리, 상태 복원              │
│                                                           │
└───────────────────────────────────────────────────────────┘

┌─ Data Layer ──────────────────────────────────────────────┐
│                                                           │
│  FirebaseManager   → Firebase SDK 초기화, Auth 관리       │
│  UserRepository    → 유저 데이터 CRUD (Firestore)         │
│  MatchRepository   → 매치 기록 저장/조회                  │
│  CosmeticManager   → 코스메틱 보유/장착 관리             │
│  EconomyManager    → 코인/젬 잔액 관리, 트랜잭션         │
│  RemoteConfig      → 피처 플래그, 밸런스 수치 원격 로드  │
│  IAPManager        → 인앱 구매 처리, 영수증 검증         │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

### 2.4 Component Diagram (관리자 백엔드)

```
Admin API Server Components:

┌─ API Routes ──────────────────────────────────────────────┐
│                                                           │
│  /api/auth/*        → 관리자 로그인, JWT 발급/갱신        │
│  /api/users/*       → 유저 검색/상세/제재/코인 지급       │
│  /api/reports/*     → 신고 목록/처리                      │
│  /api/monitoring/*  → CCU/게임 수/서버 상태               │
│  /api/balancing/*   → 블라인드/AI/리워드/ELO 설정        │
│  /api/features/*    → 피처 플래그 CRUD                    │
│  /api/shop/*        → 상품 관리, 이벤트 관리              │
│  /api/analytics/*   → KPI/매출/코호트 데이터              │
│                                                           │
└───────────────────────────────────────────────────────────┘

┌─ Middleware ──────────────────────────────────────────────┐
│                                                           │
│  authMiddleware     → JWT 검증, 만료 체크                 │
│  rbacMiddleware     → 역할 기반 접근 제어 (4단계)         │
│  rateLimiter        → API 호출 빈도 제한                  │
│  errorHandler       → 글로벌 에러 핸들링, 로깅            │
│  auditLogger        → 관리자 액션 감사 로그               │
│                                                           │
└───────────────────────────────────────────────────────────┘

┌─ Services ────────────────────────────────────────────────┐
│                                                           │
│  UserService        → 유저 조회/제재/보상 비즈니스 로직   │
│  MonitoringService  → 실시간 메트릭 수집, Socket.IO 전송  │
│  BalancingService   → 밸런스 수치 변경, Firebase 동기화   │
│  FeatureFlagService → 피처 플래그 변경, Remote Config 동기│
│  ShopService        → 상품/이벤트/배틀패스 관리           │
│  AnalyticsService   → KPI 계산, 코호트 분석               │
│  AuditService       → 감사 로그 저장/조회                 │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

---

## 3. 개발 환경

### 3.1 개발 도구

| 도구 | 용도 | 버전/설정 |
|------|------|---------|
| Unity Editor | 게임 개발 | 6.3 LTS, 2D URP 템플릿 |
| Unity AI Assistant | 코드 생성, 디버깅 | Unity 6.3 내장 |
| Unity AI Generators | 에셋 생성 (스프라이트/텍스처/사운드) | Unity 6.3 내장 |
| VS Code | C# 코드 편집 | C# Dev Kit + Unity 확장 |
| JetBrains Rider | C# 코드 편집 (대안) | Unity 디버거 지원 |
| Git | 버전 관리 | LFS 활성화 (에셋 바이너리) |
| GitHub | 원격 저장소 | Private repo, Actions CI/CD |

### 3.2 에디터 설정

| 설정 | 값 | 비고 |
|------|------|------|
| Unity Color Space | Linear | URP 2D 표준 |
| Unity Scripting Backend | IL2CPP | 모바일 빌드 성능 |
| Unity Managed Stripping Level | Medium | 앱 크기 최적화 |
| Asset Serialization | Force Text | Git diff 가능 |

### 3.3 빌드 타겟

| 플랫폼 | 최소 사양 | 빌드 설정 | Phase |
|--------|---------|---------|:-----:|
| Android | API 24 (7.0), 2GB RAM | ARM64, ASTC 6x6, IL2CPP | 1 |
| iOS | iOS 14.0, iPhone 8 | ARM64, Metal, IL2CPP | 1 |
| PC (Standalone) | Windows 10, DirectX 11 | x86_64, 60 FPS | 3 |
| WebGL | Chrome 90+ | WebGL 2.0, 30 FPS | 3+ |

### 3.4 테스트 환경

| 테스트 유형 | 도구 | 적용 시점 |
|-----------|------|---------|
| 단위 테스트 | NUnit (Unity Test Framework) | 코어 게임 로직 개발 시 |
| 통합 테스트 | Unity Test Framework + Firebase Emulator | 네트워크 기능 개발 시 |
| UI 테스트 | Unity UI Test Framework | UI 구현 완료 후 |
| 부하 테스트 | k6 (관리자 API) | 소프트 런치 전 |
| 실기기 테스트 | Galaxy A 시리즈, iPhone 8 | 매 스프린트 |

---

## 4. ADR (Architecture Decision Records)

### ADR-001: Unity 6.3 LTS 선택

- **Status**: Accepted
- **Context**: 2D 카드 게임 엔진 선택. 후보: Unity, Godot 4, Cocos2d-x.
- **Decision**: Unity 6.3 LTS 선택.
- **Consequences**:
  - (+) Unity AI 3대 기능(Assistant, Generators, Inference Engine) 풀 활용으로 1인 개발 생산성 극대화
  - (+) 크로스플랫폼(Android/iOS/PC/WebGL) 단일 코드베이스
  - (+) 풍부한 에코시스템(DOTween, Photon, Firebase SDK)
  - (+) LTS 2년 장기 지원 보장
  - (-) 라이선스 비용 발생 가능 ($200K+ 수익 시 Pro 필요)
  - (-) 빌드 크기가 Godot 대비 상대적으로 큼

### ADR-002: Server-Authoritative 게임 모델

- **Status**: Accepted
- **Context**: 멀티플레이 아키텍처 선택. 후보: Server-Authoritative vs P2P vs Relay.
- **Decision**: Server-Authoritative 모델 선택.
- **Consequences**:
  - (+) 부정행위 방지의 핵심 (서버가 게임 상태 권한 보유)
  - (+) 카드 정보 서버에서 관리 → 핸드 노출 불가
  - (+) 일관된 게임 상태 보장
  - (-) 서버 응답 지연(100-200ms)이 체감될 수 있음
  - (-) Firebase Cloud Functions 비용 발생 (DAU 증가 시)
  - **완화**: 턴 기반 게임이므로 지연 영향 최소, 클라이언트 예측 불필요

### ADR-003: Firebase 기반 백엔드 (자체 서버 대신)

- **Status**: Accepted
- **Context**: 백엔드 인프라 선택. 후보: Firebase vs 자체 서버(AWS/GCP) vs PlayFab.
- **Decision**: Firebase(Auth + Firestore + Cloud Functions + Analytics) 선택.
- **Consequences**:
  - (+) Phase 1 비용 $0 (Spark 무료 플랜)
  - (+) 서버 관리 부담 제거 (서버리스)
  - (+) Unity SDK 공식 지원, 실시간 동기화 내장
  - (+) Analytics + Crashlytics 통합 → 별도 분석 도구 불필요
  - (-) Firestore 쿼리 유연성 제한 (복잡한 JOIN 불가)
  - (-) Blaze 전환 시 비용 예측 어려움
  - (-) 벤더 종속(Vendor Lock-in)
  - **완화**: 관리자 백엔드는 별도 PostgreSQL → 관계형 데이터 처리. 비용 알림 설정 + 캐싱 레이어.

### ADR-004: Unity Inference Engine for AI (서버 AI 대신)

- **Status**: Accepted
- **Context**: Hard AI 봇 추론 위치 선택. 후보: 온디바이스(Inference Engine) vs 서버 추론(Cloud Functions + ML) vs 외부 API(OpenAI).
- **Decision**: Unity Inference Engine 온디바이스 추론 선택.
- **Consequences**:
  - (+) 서버 비용 $0 (추론이 유저 기기에서 실행)
  - (+) 오프라인 AI 대전 가능 (인터넷 불필요)
  - (+) NPU 가속 시 <10ms 응답, CPU 폴백 <50ms
  - (+) ONNX 표준 형식으로 모델 교체 용이
  - (-) 모델 크기 제한 (50MB 목표, float16 양자화 필요)
  - (-) 저사양 기기에서 추론 시간 증가 가능
  - (-) CFR 모델 학습은 별도 Python 파이프라인 필요
  - **폴백**: 모델 크기 초과 시 서버 추론 전환 (ADR 수정)

### ADR-005: 관리자 React + Node.js 별도 서버

- **Status**: Accepted
- **Context**: 관리자 도구 아키텍처 선택. 후보: Firebase 콘솔 확장 vs 별도 웹 앱 vs Unity 인앱 관리자.
- **Decision**: React + Node.js + PostgreSQL 별도 웹 애플리케이션.
- **Consequences**:
  - (+) 게임 클라이언트와 독립적 개발/배포 가능
  - (+) PostgreSQL → 복잡한 쿼리(유저 검색, 통계, 로그)에 적합
  - (+) Socket.IO → 실시간 모니터링 (CCU, 게임 수, 에러)
  - (+) RBAC 4단계 세밀한 권한 관리
  - (-) 별도 서버 운영 비용 (Docker, DB 호스팅)
  - (-) Firebase↔PostgreSQL 간 데이터 동기화 필요
  - **완화**: 관리자 백엔드가 Firebase Admin SDK로 직접 Firestore 접근 + PostgreSQL에 관리자 전용 데이터 저장

### ADR-006: Photon Fusion 네트워크 단계적 도입

- **Status**: Accepted
- **Context**: 멀티플레이 네트워크 솔루션 선택. 후보: Photon Fusion vs Mirror vs Fish-Net vs Netcode for GameObjects.
- **Decision**: Phase 1 Netcode for GameObjects → Phase 2 Photon Fusion 전환.
- **Consequences**:
  - (+) Phase 1: 무료, Unity 기본 제공, 프로토타입 충분
  - (+) Phase 2: Photon Fusion 100 CCU 무료, 검증된 매칭/Room 시스템
  - (+) 100 CCU ≈ 10,000 DAU → BEP 전에 비용 발생하지 않음
  - (-) Phase 1→2 전환 시 네트워크 코드 리팩토링 필요
  - (-) Photon 서버 종속 (다른 솔루션 전환 비용 높음)
  - **완화**: 네트워크 추상화 레이어(INetworkProvider) 설계 → 전환 비용 최소화

### ADR-007: Firestore 데이터 구조 (관계형 대신 문서 기반)

- **Status**: Accepted
- **Context**: 게임 데이터 저장소 구조 설계.
- **Decision**: Firestore 문서 기반 비정규화 구조.
- **Consequences**:
  - (+) 유저별 데이터 1회 읽기로 전체 프로필 로드 (latency 최소)
  - (+) 실시간 리스너로 코인/ELO 변동 즉시 반영
  - (-) 데이터 중복 (비정규화) → 업데이트 시 다중 문서 수정
  - (-) 복잡한 통계 쿼리 어려움 → 관리자 PostgreSQL로 보완

---

## 5. Unity AI 활용 계획

### 5.1 Unity AI Assistant — 코드 생성 + 디버깅

| 적용 영역 | 구체 사례 | 예상 생산성 향상 |
|----------|---------|:-------------:|
| 게임 규칙 엔진 | HandEvaluator, BettingManager, DrawManager C# 클래스 초안 생성 | 50-70% |
| Firebase CRUD | UserRepository, MatchRepository 보일러플레이트 생성 | 60-80% |
| UI 바인딩 | UI Toolkit 데이터 바인딩 코드 생성 | 40-60% |
| 네트워크 코드 | Netcode/Photon RPC 메서드 생성 | 30-50% |
| 씬 구성 | 로비/테이블/결과 화면 씬 오브젝트 자동 배치 | 40-60% |
| 디버깅 | 콘솔 오류 자동 해결, 런타임 에러 분석 | 20-40% |

### 5.2 Unity AI Generators — 에셋 생성

| 에셋 유형 | 사양 | 수량 | 프롬프트 전략 |
|----------|------|:---:|-------------|
| 카드 기본 덱 | 256x384px, PNG | 52장 | "Premium minimalist playing card [rank][suit], clean white background, gold accent, Korean style" |
| 카드 뒷면 | 256x384px, PNG | 5종 | "Card back design, [theme], elegant pattern, dark green and gold" |
| 코스메틱 카드 스킨 | 256x384px, PNG | 20종+ | 테마별 배리에이션 (골드/블루/다크/전통) |
| 테이블 배경 | 1920x1080px, PNG | 5종 | "Dark green felt poker table texture, [variation], premium casino aesthetic" |
| UI 아이콘 | 64x64px, PNG | 50+ | "Flat icon [name], white on transparent, poker game style" |
| 플레이어 아바타 | 128x128px, PNG | 20종 | "Cartoon portrait avatar, [gender/style], friendly expression, circle crop" |
| 이모지 | 64x64px, PNG | 30종 | "Emoji [emotion], cartoon style, poker theme" |
| 칩/토큰 | 128x128px, PNG | 5종 | "Casino poker chip [color], top view, realistic texture" |
| 카드 배분 애니메이션 | Sprite Sheet | 1세트 | "Card dealing animation, smooth slide, 8 frames" |
| 카드 뒤집기 애니메이션 | Sprite Sheet | 1세트 | "Card flip animation, 3D perspective, 6 frames" |
| BGM (로비) | WAV/OGG, 루프 | 1곡 | "Relaxed jazz piano, lounge style, 120 BPM, loop ready" |
| BGM (게임 중) | WAV/OGG, 루프 | 2곡 | "Minimal electronic, focus inducing, [normal/tense]" |
| SFX | WAV, 짧은 | 15+ | "Card [action] sound effect, crisp, satisfying" |

### 5.3 Unity Inference Engine — Hard AI 봇

| 단계 | 작업 | 도구 | 산출물 |
|------|------|------|--------|
| 1. CFR 학습 (오프라인) | 로우 바둑이 게임 트리 탐색 + 균형 전략 계산 | Python + CFR 라이브러리 | 전략 테이블 |
| 2. 모델 변환 | 전략 테이블 → 뉴럴 네트워크 근사 → ONNX 내보내기 | PyTorch + ONNX | .onnx 파일 |
| 3. 양자화 | float32 → float16 양자화 (50MB 이하 목표) | ONNX Runtime | .onnx (경량) |
| 4. Unity 배포 | Assets/AI/ 폴더 배치 + Inference Engine API 래퍼 | Unity | InferenceRunner.cs |
| 5. 런타임 추론 | 게임 상태 → 입력 텐서(~230차원) → 추론 → 액션 확률 → 샘플링 | Unity Inference Engine | Bot 액션 |

**입력 텐서 구조 (약 230차원)**:
- 핸드 인코딩: 208차원 (4장 x 52 one-hot)
- 공개 정보: ~22차원 (드로우 단계, 팟 크기, 상대 드로우 장수, 베팅 금액, 포지션)

**성능 목표**:
- NPU 가속 (지원 기기): <10ms
- CPU 폴백: <50ms
- 모델 크기: <50MB (float16)

---

## 6. Trine 세션 로드맵

> 각 Trine 세션의 범위, 분류, Spec/Plan/Task 문서명, Todo 체크리스트를 명시한다.
> 세션 순서는 로드맵 우선순위 + 의존성 기반으로 배치.

### Session 1: 프로젝트 셋업 + 인증

- **범위**: Unity 6.3 LTS 프로젝트 생성, Firebase 연동(Auth + Firestore + Analytics), Git 구조, 소셜 로그인(Google/Apple/게스트), 프로필 기본 정보, 스플래시 화면, Firestore 스키마
- **에픽**: EP-01 (프로젝트 셋업) + EP-02 (인증/계정)
- **분류**: Standard
- **산출물**:
  - Spec: `.specify/specs/baduki-auth-spec.md`
  - Plan: `.specify/plans/baduki-auth-plan.md`
- **Todo**:
  - [ ] Spec 작성 (FR: 로그인 3종 + 프로필, NFR: 스플래시 3초 이내, Firebase 초기화)
  - [ ] Plan 작성 (구현 전략)
  - [ ] 구현 + AI Check 3 통과
  - [ ] Walkthrough 작성
  - [ ] PR 생성

### Session 2: 코어 게임 로직

- **범위**: 카드 덱 관리, 핸드 배분, 3회 드로우(아침/점심/저녁), 4라운드 베팅(Fold/Check/Call/Raise/All-in), 족보 판정(메이드/베이스/투베이스/노페어), 쇼다운 + 팟 분배, 게임 상태 머신(FSM), 턴 타이머
- **에픽**: EP-03 (코어 게임 로직)
- **분류**: **Multi-Spec** (8개 스토리, 34 SP, 복잡한 상호 의존성)
- **산출물**:
  - Spec: `.specify/specs/baduki-core-game-spec.md`
  - Plan: `.specify/plans/baduki-core-game-plan.md`
  - Task: `.specify/plans/baduki-core-game-task.md`
- **세부 도메인**:
  - 도메인 A: 카드/덱/족보 (EP03-01, EP03-02, EP03-03)
  - 도메인 B: 드로우/베팅/FSM (EP03-04, EP03-05, EP03-07, EP03-08)
  - 도메인 C: 쇼다운/결과 (EP03-06)
- **Todo**:
  - [ ] Spec 작성 (FR: 규칙 전체, NFR: 족보 판정 정확도 100%, 턴 타이머 정밀도)
  - [ ] Plan 작성 (도메인별 구현 순서)
  - [ ] Task 분배 (도메인 A/B/C 병렬)
  - [ ] 구현 + AI Check 3 통과
  - [ ] Walkthrough 작성
  - [ ] PR 생성

### Session 3: AI 대전 시스템

- **범위**: AI 봇 프레임워크(IBotStrategy), Easy 봇(Rule-Based), Medium 봇(Heuristic + MCTS), AI 난이도 선택 화면, 봇 행동 프로파일(응답 시간 제어)
- **에픽**: EP-04 (AI 대전) — Easy/Medium만 (Hard는 Session 별도)
- **분류**: Standard
- **산출물**:
  - Spec: `.specify/specs/baduki-ai-bot-spec.md`
  - Plan: `.specify/plans/baduki-ai-bot-plan.md`
- **비고**: Hard 봇(CFR + Inference Engine)은 Session 11에서 별도 구현
- **Todo**:
  - [ ] Spec 작성 (FR: Easy/Medium 행동 프로파일, NFR: Easy <100ms, Medium 0.5-2초)
  - [ ] Plan 작성 (구현 전략)
  - [ ] 구현 + AI Check 3 통과
  - [ ] Walkthrough 작성
  - [ ] PR 생성

### Session 4: 게임 UI + 로비

- **범위**: 메인 로비, 게임 테이블 UI, 쇼다운/결과 화면, 카드 애니메이션 시스템, 친구 대전 방 화면, 설정/프로필 화면
- **에픽**: EP-05 (UI/프론트엔드)
- **분류**: **Multi-Spec** (7개 스토리, 27 SP, 다양한 화면)
- **산출물**:
  - Spec: `.specify/specs/baduki-ui-spec.md`
  - Plan: `.specify/plans/baduki-ui-plan.md`
  - Task: `.specify/plans/baduki-ui-task.md`
- **세부 도메인**:
  - 도메인 A: 로비/설정/프로필 (EP05-01, EP05-06, EP05-07)
  - 도메인 B: 게임 테이블/쇼다운/결과 (EP05-02, EP05-03, EP05-05)
  - 도메인 C: 튜토리얼 (EP05-04)
- **Todo**:
  - [ ] Spec 작성 (FR: 10개 화면 전체, NFR: FPS 30, 메모리 <200MB, 로딩 <3초)
  - [ ] Plan 작성 (도메인별 구현 순서)
  - [ ] Task 분배 (도메인 A/B/C 병렬)
  - [ ] 구현 + AI Check 3 통과
  - [ ] Walkthrough 작성
  - [ ] PR 생성

### Session 5: 네트워크 멀티플레이

- **범위**: ELO 기반 매칭, Server-Authoritative 게임 서버, 네트워크 동기화, 연결 끊김 처리, 친구 대전 네트워크, 부정행위 방지 서버 검증
- **에픽**: EP-06 (네트워크 멀티플레이)
- **분류**: **Multi-Spec** (6개 스토리, 28 SP, 높은 기술적 복잡도)
- **산출물**:
  - Spec: `.specify/specs/baduki-network-spec.md`
  - Plan: `.specify/plans/baduki-network-plan.md`
  - Task: `.specify/plans/baduki-network-task.md`
- **세부 도메인**:
  - 도메인 A: 매칭 + 서버 (EP06-01, EP06-02)
  - 도메인 B: 동기화 + 재접속 (EP06-03, EP06-04)
  - 도메인 C: 친구 대전 + 보안 (EP06-05, EP06-06)
- **Todo**:
  - [ ] Spec 작성 (FR: 매칭/동기화/보안, NFR: 지연 <200ms, 동기화 에러율 <1%)
  - [ ] Plan 작성 (Netcode → Photon 전환 전략)
  - [ ] Task 분배 (도메인 A/B/C)
  - [ ] 구현 + AI Check 3 통과
  - [ ] Walkthrough 작성
  - [ ] PR 생성

### Session 6: 경제/수익화

- **범위**: 코인 경제 시스템, 젬(프리미엄 재화), 코스메틱 상점, 배틀패스 시스템, ELO 랭크, IAP 연동(Google Play/App Store), 리워드 광고(AdMob), VIP 구독
- **에픽**: EP-08 (경제/수익화)
- **분류**: **Multi-Spec** (8개 스토리, 34 SP)
- **산출물**:
  - Spec: `.specify/specs/baduki-economy-spec.md`
  - Plan: `.specify/plans/baduki-economy-plan.md`
  - Task: `.specify/plans/baduki-economy-task.md`
- **세부 도메인**:
  - 도메인 A: 코인/젬/ELO 기반 시스템 (EP08-01, EP08-02, EP08-05)
  - 도메인 B: 상점/배틀패스 (EP08-03, EP08-04)
  - 도메인 C: IAP/광고/VIP (EP08-06, EP08-07, EP08-08)
- **Todo**:
  - [ ] Spec 작성 (FR: 통화 4종, 상점, 배틀패스, IAP, NFR: 구매 한도, 영수증 검증)
  - [ ] Plan 작성 (도메인별 구현 순서)
  - [ ] Task 분배 (도메인 A/B/C)
  - [ ] 구현 + AI Check 3 통과
  - [ ] Walkthrough 작성
  - [ ] PR 생성

### Session 7: 탄 시스템

- **범위**: 엿보기 탄, 교체 탄, 피처 플래그 연동(FEATURE_TAN_SYSTEM), 탄 상점 UI, 심의 빌드 분리(컴파일 타임 + Remote Config 이중 잠금)
- **에픽**: EP-09 (탄 시스템)
- **분류**: Standard
- **산출물**:
  - Spec: `.specify/specs/baduki-tan-system-spec.md`
  - Plan: `.specify/plans/baduki-tan-system-plan.md`
- **비고**: GRAC 심의 대응 핵심. 피처 플래그 OFF 시 코드 경로 도달 불가 검증 필수.
- **Todo**:
  - [ ] Spec 작성 (FR: 엿보기/교체 탄, 피처 플래그, NFR: OFF 시 코드 경로 검증)
  - [ ] Plan 작성 (이중 잠금 설계)
  - [ ] 구현 + AI Check 3 통과
  - [ ] Walkthrough 작성
  - [ ] PR 생성

### Session 8: 소셜 시스템

- **범위**: 친구 추가/관리, 이모지 채팅(게임 중), 리더보드(3종), 신고 시스템(클라이언트)
- **에픽**: EP-07 (소셜) — 클럽/길드 제외 (Later)
- **분류**: Standard
- **산출물**:
  - Spec: `.specify/specs/baduki-social-spec.md`
  - Plan: `.specify/plans/baduki-social-plan.md`
- **비고**: 클럽/길드(EP07-04)는 Later Phase로 별도 세션.
- **Todo**:
  - [ ] Spec 작성 (FR: 친구/이모지/리더보드/신고, NFR: 이모지 쿨다운 3초, 리더보드 캐싱 5분)
  - [ ] Plan 작성 (구현 전략)
  - [ ] 구현 + AI Check 3 통과
  - [ ] Walkthrough 작성
  - [ ] PR 생성

### Session 9: 관리자 — 대시보드 + 유저 관리

- **범위**: React 관리자 프로젝트 셋업, 관리자 인증 + RBAC(4단계), 실시간 모니터링 위젯, KPI 대시보드, 에러 로그 뷰어, 유저 검색/상세/제재/코인 지급, 신고 처리
- **에픽**: EP-10 (대시보드) + EP-11 (유저 관리) + EP-14-05 (관리자 백엔드)
- **분류**: **Multi-Spec** (15개 스토리, 54 SP, 프론트+백엔드 동시 개발)
- **산출물**:
  - Spec: `.specify/specs/baduki-admin-dashboard-spec.md`
  - Plan: `.specify/plans/baduki-admin-dashboard-plan.md`
  - Task: `.specify/plans/baduki-admin-dashboard-task.md`
- **세부 도메인**:
  - 도메인 A: 관리자 백엔드 + 인증/RBAC (EP14-05, EP10-01, EP10-02)
  - 도메인 B: 모니터링/KPI/에러 로그 (EP10-03, EP10-04, EP10-05)
  - 도메인 C: 유저 관리/신고 처리 (EP11-01~EP11-05)
- **Todo**:
  - [ ] Spec 작성 (FR: 관리자 전 기능, NFR: CCU 5초 갱신, RBAC 4단계)
  - [ ] Plan 작성 (프론트/백엔드 동시 개발 전략)
  - [ ] Task 분배 (도메인 A/B/C)
  - [ ] 구현 + AI Check 3 통과
  - [ ] Walkthrough 작성
  - [ ] PR 생성

### Session 10: 관리자 — 게임 운영 + 경제 관리

- **범위**: 게임 밸런싱 패널, 피처 플래그 관리, 매칭 설정, ELO/시즌 설정, 점검 모드, 상점 상품 관리, 이벤트 관리, 배틀패스 시즌 관리, 매출 리포트
- **에픽**: EP-12 (게임 운영) + EP-13 (경제 관리)
- **분류**: Standard
- **산출물**:
  - Spec: `.specify/specs/baduki-admin-operations-spec.md`
  - Plan: `.specify/plans/baduki-admin-operations-plan.md`
- **Todo**:
  - [ ] Spec 작성 (FR: 밸런싱/피처플래그/매칭/경제, NFR: 변경 즉시 적용, 감사 로그)
  - [ ] Plan 작성 (구현 전략)
  - [ ] 구현 + AI Check 3 통과
  - [ ] Walkthrough 작성
  - [ ] PR 생성

### Session 11: AI Hard + CFR 파이프라인

- **범위**: CFR 모델 학습 파이프라인(Python, 오프라인), ONNX 내보내기 + float16 양자화, Unity Inference Engine 통합, Hard 봇(GTO 블러핑 + 적응형 Exploit), NPU 가속/CPU 폴백
- **에픽**: EP-04-04 (Hard 봇) + EP-04-06 (CFR 학습)
- **분류**: Standard
- **산출물**:
  - Spec: `.specify/specs/baduki-ai-hard-spec.md`
  - Plan: `.specify/plans/baduki-ai-hard-plan.md`
- **비고**: Session 3(Easy/Medium) 완료 후 진행. CFR 학습은 오프라인 Python 파이프라인.
- **Todo**:
  - [ ] Spec 작성 (FR: CFR 모델 학습/배포/추론, NFR: <50MB 모델, NPU <10ms)
  - [ ] Plan 작성 (학습 → 변환 → 양자화 → Unity 배포)
  - [ ] 구현 + AI Check 3 통과
  - [ ] Walkthrough 작성
  - [ ] PR 생성

### Session 12: 품질/인프라

- **범위**: 단위 테스트(게임 로직 100% 커버리지), 통합 테스트(네트워크 전체 플로우), Crashlytics 연동, 성능 프로파일링(FPS/메모리/앱 크기), 모니터링 + 알림, CI/CD 완성
- **에픽**: EP-14 (품질/인프라) — EP14-05(관리자 백엔드)는 Session 9에 포함
- **분류**: Standard
- **산출물**:
  - Spec: `.specify/specs/baduki-quality-infra-spec.md`
  - Plan: `.specify/plans/baduki-quality-infra-plan.md`
- **Todo**:
  - [ ] Spec 작성 (FR: 테스트/모니터링, NFR: FPS 30, 메모리 <200MB, 앱 <100MB)
  - [ ] Plan 작성 (테스트 전략, CI/CD 파이프라인)
  - [ ] 구현 + AI Check 3 통과
  - [ ] Walkthrough 작성
  - [ ] PR 생성

### 세션 의존성 순서

```
Session 1 (셋업+인증)
├── Session 2 (코어 게임) ← 인증/Firestore 필요
│   ├── Session 3 (AI Easy/Medium) ← 게임 로직 FSM 필요
│   │   └── Session 11 (AI Hard CFR) ← Easy/Medium 봇 프레임워크 필요
│   ├── Session 4 (게임 UI) ← 게임 로직 필요
│   └── Session 5 (네트워크) ← 게임 로직 필요
│       └── Session 6 (경제/수익화) ← 매칭+상점 UI 필요
│           └── Session 7 (탄 시스템) ← 경제 시스템 필요
├── Session 8 (소셜) ← 프로필/인증 필요
├── Session 9 (관리자 대시보드+유저) ← Firebase 연동 필요
│   └── Session 10 (관리자 운영+경제) ← 관리자 기반 인프라 필요
└── Session 12 (품질/인프라) ← 전체 기능 개발 후 집중 QA
```

### 세션별 요약 테이블

| Session | 이름 | 분류 | 에픽 | 스토리 | SP | Phase |
|:-------:|------|:----:|------|:------:|:--:|:-----:|
| 1 | 프로젝트 셋업 + 인증 | Standard | EP-01, EP-02 | 10 | 30 | Now |
| 2 | 코어 게임 로직 | Multi-Spec | EP-03 | 8 | 34 | Now |
| 3 | AI 대전 (Easy/Medium) | Standard | EP-04 (일부) | 4 | 14 | Now |
| 4 | 게임 UI + 로비 | Multi-Spec | EP-05 | 7 | 27 | Now |
| 5 | 네트워크 멀티플레이 | Multi-Spec | EP-06 | 6 | 28 | Next |
| 6 | 경제/수익화 | Multi-Spec | EP-08 | 8 | 34 | Next |
| 7 | 탄 시스템 | Standard | EP-09 | 4 | 16 | Later |
| 8 | 소셜 시스템 | Standard | EP-07 (일부) | 4 | 13 | Next |
| 9 | 관리자 대시보드 + 유저 | Multi-Spec | EP-10, EP-11, EP-14(일부) | 15 | 54 | Now~Next |
| 10 | 관리자 운영 + 경제 | Standard | EP-12, EP-13 | 9 | 32 | Next |
| 11 | AI Hard + CFR | Standard | EP-04 (일부) | 2 | 13 | Next |
| 12 | 품질/인프라 | Standard | EP-14 (일부) | 5 | 17 | Next |
| | **합계** | | | **82** | **312** | |

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|---------|--------|
| 1.0 | 2026-02-27 | S4 상세 개발 계획 초안 작성 (기술 스택 + C4 + ADR 7개 + Trine 12세션) | Claude Opus 4.6 |
