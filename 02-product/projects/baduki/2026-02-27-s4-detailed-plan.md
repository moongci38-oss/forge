# 로우 바둑이 (Low Baduki) — S4 서비스 상세 기획서

**작성일**: 2026-02-27
**프로젝트 유형**: 게임 개발 (SIGIL S4 — 개발 트랙)
**입력 문서**: S3 GDD `02-product/projects/baduki/2026-02-27-s3-gdd.md`
**버전**: 2.0

---

## 목차

1. [화면별 동작 명세](#1-화면별-동작-명세)
2. [데이터 흐름](#2-데이터-흐름)
3. [비즈니스 로직 상세](#3-비즈니스-로직-상세)
4. [API/서비스 엔드포인트](#4-api서비스-엔드포인트)

---

## 1. 화면별 동작 명세

### 1.1 스플래시/로딩 (Splash Screen) — SCR-001

| 항목 | 내용 |
|------|------|
| **진입 조건** | 앱 콜드 스타트 |
| **화면 요소** | 게임 로고 (중앙), 로딩 프로그레스 바 (하단 30%), 버전 번호 (하단 우측) |
| **지속 시간** | 최소 1초, 최대 3초 |

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| (없음 — 자동 진행) | Firebase SDK 초기화 | 없음 |
| | Remote Config 페치 (피처 플래그 동기화) | `localFeatureFlags` 갱신 |
| | 에셋 번들 로드 (Sprite Atlas: CardAtlas, UIAtlas) | 메모리 로드 |
| | 로컬 캐시 유효성 검증 | 없음 |

**에러 처리**:

| 에러 상황 | 대응 | 유저 노출 |
|---------|------|---------|
| 네트워크 미연결 | 오프라인 모드 진입 (AI 대전만 허용) | "오프라인 모드로 시작합니다" 토스트 |
| Remote Config 타임아웃 (5초) | 로컬 캐시 기본값 사용 | 없음 (조용히 실패) |
| 앱 업데이트 필수 | 강제 업데이트 다이얼로그 | "새 버전이 있습니다" + 스토어 링크 |
| 점검 모드 (`FEATURE_MAINTENANCE = true`) | 점검 화면으로 리다이렉트 | 점검 공지 + 예상 종료 시간 |

**이탈 경로**: 초기화 완료 → 로그인 화면 (SCR-002)

---

### 1.2 로그인 (Login) — SCR-002

| 항목 | 내용 |
|------|------|
| **진입 조건** | 스플래시 완료 AND (세션 미존재 OR 세션 만료) |
| **화면 요소** | 게임 타이틀 로고 + 키비주얼, Google 로그인 버튼, Apple 로그인 버튼 (iOS만), 게스트 플레이 버튼, 버전 정보 (하단) |

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| Google 로그인 탭 | Firebase Auth → Google OAuth 플로우 | `users/{userId}` 생성/갱신 |
| Apple 로그인 탭 (iOS) | Firebase Auth → Apple Sign-In | `users/{userId}` 생성/갱신 |
| 게스트 플레이 탭 | Firebase Anonymous Auth → 게스트 계정 | `users/{guestId}` (제한된 프로필) |
| 자동 로그인 (유효 토큰) | 로그인 화면 스킵 → 메인 로비 | `lastLogin` 타임스탬프 갱신 |

**신규 유저 데이터 구조**:

```json
users/{userId}: {
  "nickname": "플레이어_{randomID}",
  "elo": 1500,
  "level": 1,
  "exp": 0,
  "coins": 500,
  "gems": 0,
  "gamesPlayed": 0,
  "wins": 0,
  "losses": 0,
  "cosmetics": {
    "cardSkin": "default",
    "boardTheme": "default",
    "avatar": "avatar_default",
    "profileFrame": "frame_default",
    "emojis": ["emoji_01","emoji_02","emoji_03","emoji_04","emoji_05","emoji_06"]
  },
  "tans": { "peek": 0, "swap": 0 },
  "tutorialCompleted": false,
  "tutorialProgress": 0,
  "tutorialCompletedDate": null,
  "dailyLoginStreak": 0,
  "lastDailyLogin": null,
  "battlePass": { "premium": false, "points": 0, "level": 0, "claimedRewards": [] },
  "vip": { "active": false, "expiryDate": null },
  "friends": [],
  "deletionRequested": false,
  "createdAt": "timestamp",
  "lastLogin": "timestamp",
  "platform": "android|ios",
  "authProvider": "google|apple|guest",
  "purchaseLog": { "dailyTotal": 0, "monthlyTotal": 0, "lastResetDate": "date" }
}
```

**에러 처리**:

| 에러 상황 | 대응 | 유저 노출 |
|---------|------|---------|
| OAuth 실패 (네트워크) | 재시도 다이얼로그 | "로그인에 실패했습니다. 다시 시도해주세요" |
| OAuth 취소 (유저) | 로그인 화면 유지 | 없음 |
| 계정 정지 상태 | 밴 정보 표시 + 고객센터 링크 | "계정이 정지되었습니다. (사유: {reason})" |
| 게스트 → 소셜 연동 | 기존 게스트 데이터 병합 확인 | "기존 데이터를 유지합니다" 팝업 |

**이탈 경로**:
- 신규 유저: → 튜토리얼 (SCR-003)
- 기존 유저: → 메인 로비 (SCR-004)

---

### 1.3 튜토리얼 (Tutorial) — SCR-003

| 항목 | 내용 |
|------|------|
| **진입 조건** | 로그인 성공 AND `tutorialCompleted == false` |
| **건너뛰기** | 불가 (5단계 필수 완료) |

**5단계 인터랙티브 튜토리얼**:

| 단계 | 제목 | 유저 액션 | 시스템 반응 | 완료 조건 |
|:---:|------|---------|-----------|---------|
| 1 | 바둑이란? | 족보 설명 읽기 + 퀴즈 | 하이라이트 가이드 + 퀴즈 정답 피드백 | 퀴즈 2문제 정답 |
| 2 | 카드 교환 | 카드 탭 → 드로우 확인 | 가이드 화살표 + 교환 애니메이션 | 3회 드로우 완료 |
| 3 | 베팅 배우기 | Fold/Check/Call/Raise 각 1회 실습 | 각 액션 결과 설명 팝업 | 4가지 액션 각 1회 수행 |
| 4 | 골프 만들기 | 미리 정해진 핸드로 A-2-3-4 달성 | 교환 힌트 표시 + 성공 이펙트 | 골프(Perfect) 달성 |
| 5 | 첫 AI 대전 | Easy AI와 1판 완주 | 봇이 의도적으로 약하게 플레이 | 1판 완주 (승패 무관) |

**데이터 변경**:

| 시점 | 변경 필드 | 값 |
|------|---------|---|
| 각 단계 완료 시 | `tutorialProgress` | 해당 단계 번호 |
| 5단계 완료 (전체) | `tutorialCompleted` | `true` |
| 5단계 완료 | `tutorialCompletedDate` | 현재 타임스탬프 |
| 전체 완료 보상 | `coins` | `+500` |
| 전체 완료 보상 | `cosmetics.cardSkin` | `"basic_v1"` 추가 |

**에러 처리**:

| 에러 상황 | 대응 |
|---------|------|
| 중도 이탈 (앱 종료) | `tutorialProgress` 기준 마지막 완료 단계 다음부터 재개 |
| 단계 내 타이머 만료 | 해당 단계 처음부터 재시작 (2회 실패 시 자동 완료 처리) |

**이탈 경로**: 5단계 완료 → 메인 로비 (SCR-004)

---

### 1.4 메인 로비 (Main Lobby) — SCR-004

| 항목 | 내용 |
|------|------|
| **진입 조건** | 로그인 완료 AND `tutorialCompleted == true` |
| **화면 레이아웃** | 상단바 + 중앙 모드 선택 + 하단 탭바 |

**화면 레이아웃 상세**:

```
┌─────────────────────────────────────────────┐
│ [상단바]                                     │
│  코인: 5,000  |  젬: 150  |  [프로필 아이콘]  │
│  [시즌 패스 진행도 바 ████░░░░ Lv.12]        │
├─────────────────────────────────────────────┤
│ [알림 배너] 일일 미션 / 이벤트 공지           │
├─────────────────────────────────────────────┤
│ [게임 모드 — 중앙]                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ AI 대전   │  │ 랭크 매치 │  │ 친구 대전 │  │
│  │  (P0)    │  │   (P0)   │  │   (P0)   │  │
│  └──────────┘  └──────────┘  └──────────┘  │
│       ┌──────────┐  ┌──────────┐           │
│       │ 일반 매치  │  │ 토너먼트  │           │
│       │ (P1) 🔒   │  │ (P2) 🔒  │           │
│       └──────────┘  └──────────┘           │
├─────────────────────────────────────────────┤
│ [하단 탭바]                                  │
│  홈 | 상점 | 콜렉션 | 랭킹 | 프로필          │
└─────────────────────────────────────────────┘
```

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 이동 대상 |
|---------|-----------|---------|
| AI 대전 탭 | AI 대전 선택 화면 | SCR-005 |
| 랭크 매치 탭 | 테이블 선택 → 매칭 대기 | SCR-006 |
| 친구 대전 탭 | 친구 대전 방 | SCR-010 |
| 일반 매치 탭 (잠금 시) | 해금 조건 팝업 | - |
| 토너먼트 탭 (잠금 시) | 해금 조건 팝업 | - |
| 코인 잔액 탭 | 상점 코인 탭 | SCR-011 |
| 젬 잔액 탭 | 상점 젬 탭 | SCR-011 |
| 프로필 아이콘 탭 | 프로필 화면 | SCR-015 |
| 시즌 패스 바 탭 | 배틀패스 화면 | SCR-012 |
| 알림 배너 탭 | 이벤트/공지 상세 팝업 | - |

**진입 시 자동 실행 (순서)**:

| 순서 | 팝업 | 조건 | 데이터 변경 |
|:---:|------|------|-----------|
| 1 | 일일 접속 보너스 | 오늘 최초 접속 | `coins += 200 (or 2000)`, `dailyLoginStreak` 갱신 |
| 2 | 시즌 패스 레벨업 | 미확인 레벨업 존재 | 없음 (확인만) |
| 3 | 이벤트 공지 | 새 이벤트 시작 (1일 1회) | 없음 |
| 4 | 앱 업데이트 권장 | 권장 업데이트 존재 | 없음 |

**일일 접속 보너스 상세**:

| 접속일 | 보상 | 데이터 변경 |
|:-----:|------|-----------|
| 1-6일 | 코인 200 | `coins += 200`, `dailyLoginStreak += 1` |
| 7일 | 코인 2,000 | `coins += 2000`, `dailyLoginStreak = 0` (리셋) |
| 연속 끊김 | 1일차부터 재시작 | `dailyLoginStreak = 1` |

---

### 1.5 AI 대전 선택 (AI Mode Select) — SCR-005

| 항목 | 내용 |
|------|------|
| **진입 조건** | 메인 로비에서 AI 대전 선택 |

**화면 요소**: 난이도 3단계 카드 (Easy / Medium / Hard) + 플레이어 수 선택 (1v1 / 1v2 / 1v3) + AI 봇 아바타/이름 표시

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| Easy 선택 | 즉시 게임 테이블 진입 | `match` 생성 (mode: "ai_easy") |
| Medium 선택 | 즉시 게임 테이블 진입 | `match` 생성 (mode: "ai_medium") |
| Hard 선택 | 잠금 해제 시 게임 테이블 진입 | `match` 생성 (mode: "ai_hard") |
| 플레이어 수 변경 | AI 봇 수 조정, 아바타 갱신 | UI 상태만 변경 |
| 뒤로가기 | → 메인 로비 | 없음 |

**Hard AI 잠금 로직**:

```
해금 조건: tutorialCompleted == true
          AND (currentDate - tutorialCompletedDate) >= 30일
          AND FEATURE_HARD_AI == true (피처 플래그)
잠금 시 UI: 자물쇠 아이콘 + "튜토리얼 완료 {N}일 후 해금" 툴팁
```

---

### 1.6 매칭 대기 (Matchmaking) — SCR-006

| 항목 | 내용 |
|------|------|
| **진입 조건** | 랭크/일반 매치 선택 AND 최소 바이인 코인 보유 |
| **화면 요소** | 대기 애니메이션 (카드 셔플), 현재 ELO, 예상 대기 시간, 취소 버튼 |

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 매칭 진입 | 서버에 매칭 요청 전송 | 매칭 큐 등록 |
| 취소 버튼 | 매칭 큐에서 제거 → 메인 로비 | 매칭 큐 제거 |
| (자동) 매칭 성공 | 매칭 알림 → 게임 테이블 | `match` 생성, `coins -= buyIn` |

**매칭 ELO 확장 로직**:

| 경과 시간 | ELO 범위 | 비고 |
|---------|---------|------|
| 0-5초 | ±50 | 최적 매칭 |
| 5-10초 | ±100 | 범위 확장 |
| 10-20초 | ±150 | 추가 확장 |
| 20-30초 | ±200 | 최대 확장 |
| 30초+ (일반 매치) | 전체 허용 or AI 봇 투입 | 빈 슬롯 AI 충원 |
| 30초+ (랭크 매치) | "매칭 실패" 팝업 → 로비 | 매칭 큐 제거 |

**바이인 검증**:

| 테이블 | SB / BB | 최소 바이인 | 부족 시 |
|--------|:------:|:---------:|--------|
| 연습 테이블 | 10 / 20 | 400코인 | "코인이 부족합니다" → 상점 유도 |
| 일반 테이블 | 50 / 100 | 2,000코인 | "코인이 부족합니다" → 상점 유도 |
| 하이롤러 | 500 / 1,000 | 20,000코인 | "코인이 부족합니다" → 상점 유도 |

**에러 처리**:

| 에러 상황 | 대응 |
|---------|------|
| 코인 부족 | "코인이 부족합니다" 팝업 + [상점] / [광고 시청] 버튼 |
| 매칭 서버 장애 | "서버와 연결할 수 없습니다" → 로비 복귀 |
| 네트워크 끊김 | 자동 매칭 취소 + 재연결 후 안내 |

---

### 1.7 게임 테이블 (Game Table) — SCR-007

| 항목 | 내용 |
|------|------|
| **진입 조건** | 매칭 완료 OR AI 대전 시작 OR 친구 대전 시작 |
| **핵심 화면** | 게임 플레이의 모든 상호작용이 발생하는 메인 화면 |

**화면 레이아웃**:

```
┌──────────────────────────────────────────────────┐
│ [상대 영역]                                       │
│  아바타 | 닉네임 | ELO | ■ ■ ■ ■ (카드 뒷면)     │
│  교환 장수 표시: "2장 교환" (드로우 후 공개)        │
├──────────────────────────────────────────────────┤
│ [테이블 중앙]                                     │
│  POT: {금액}                                     │
│  현재 단계: [프리드로우|아침|점심|저녁|쇼다운]       │
│  딜러 버튼(D) 위치 표시                            │
├──────────────────────────────────────────────────┤
│ [내 핸드 영역]                                    │
│  4장 앞면 카드 (탭으로 선택/해제)                   │
│  족보 자동 계산: "현재: {족보명}"                   │
├──────────────────────────────────────────────────┤
│ [액션 바 — 상황에 따라 전환]                        │
│  베팅 모드: [Fold] [Check/Call] [Raise] [All-in] │
│  드로우 모드: [선택 카드 N장] [교환] [패스]         │
│  [타이머 바] ████████░░ {남은초}s                  │
├──────────────────────────────────────────────────┤
│ [사이드 버튼] 이모지 (좌) / 메뉴 (우)              │
└──────────────────────────────────────────────────┘
```

**게임 진행 상태머신 (State Machine)**:

```
WAITING → BLIND_POSTING → PRE_DRAW_BET → DRAW_1(아침) → BET_2
  → DRAW_2(점심) → BET_3 → DRAW_3(저녁) → BET_4 → SHOWDOWN → RESULT
```

**특수 전환**: 어떤 베팅 라운드에서든 1명 제외 전원 Fold → 즉시 RESULT (쇼다운 생략)

#### 베팅 라운드 (PRE_DRAW_BET, BET_2, BET_3, BET_4)

| 유저 액션 | 조건 | 시스템 반응 | 데이터 변경 |
|---------|------|-----------|-----------|
| Fold 탭 | 항상 | 카드 뒤집기 애니메이션 → 게임 이탈 | `player.status = "folded"`, 팟 포기 |
| Check 탭 | 현재 베팅 없을 때 | 체크 사운드 → 다음 턴 | 없음 |
| Call 탭 | 이전 베팅 존재 시 | 칩 이동 애니메이션 | `player.chips -= callAmt`, `pot += callAmt` |
| Raise (슬라이더+확인) | 항상, 금액 ≥ BB | 칩 스택 증가 애니메이션 | `player.chips -= raiseAmt`, `pot += raiseAmt` |
| All-in 탭 | 항상 | 화면 강조 + 특수 사운드 | `player.chips = 0`, `pot += allInAmt` |
| 타이머 만료 (20초) | 자동 | Check 가능 시 Check, 아니면 Fold | 자동 액션 적용 |

#### 드로우 라운드 (DRAW_1 아침, DRAW_2 점심, DRAW_3 저녁)

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 카드 탭 (선택) | 선택 하이라이트 + 카드가 위로 올라옴 | UI 상태 변경 |
| 카드 탭 (해제) | 하이라이트 해제 + 원위치 | UI 상태 변경 |
| "교환" 버튼 | 선택 카드 제거 → 새 카드 배분 애니메이션 | `player.hand` 갱신, 교환 장수 공개 |
| "패스" 버튼 (Stand Pat) | Stand Pat 사운드 | 교환 장수 0 공개 |
| 타이머 만료 (15초) | 자동 Stand Pat | 교환 장수 0 |

**교환 장수 공개 규칙**: 교환 카드 장수(0-4장)는 전체 공개. 어떤 카드인지는 비공개.

#### 이모지 채팅

| 유저 액션 | 시스템 반응 | 제한 |
|---------|-----------|------|
| 이모지 버튼 탭 | 팔레트 팝업 (6개 기본 + 보유 이모지) | - |
| 이모지 선택 | 상대 화면에 이모지 표시 (2초) + 팝 사운드 | 쿨다운 3초 |

#### 게임 메뉴

| 유저 액션 | 시스템 반응 |
|---------|-----------|
| 메뉴 버튼 탭 | 설정 팝업 (사운드 볼륨, 게임 포기, 족보 가이드) |
| 게임 포기 | 확인 다이얼로그 → 포기 시 Fold 처리 (랭크: ELO 패널티 경고) |

**에러 처리**:

| 에러 상황 | 대응 |
|---------|------|
| 네트워크 끊김 (게임 중) | 재연결 시도 (10초 내 자동) → 실패 시 자동 Fold + 경고 |
| 앱 백그라운드 전환 | 20초 카운트다운 → 초과 시 자동 Fold |
| 상대 연결 끊김 | "상대 연결 해제" + 20초 대기 → 미복귀 시 자동 승리 |
| 서버 동기화 오류 | 서버 상태 기준 강제 동기화 (Server-Authoritative) |

---

### 1.8 쇼다운 (Showdown) — SCR-008

| 항목 | 내용 |
|------|------|
| **진입 조건** | 4라운드 베팅 완료 AND 남은 플레이어 2인 이상 |
| **지속 시간** | 3-5초 (자동 진행) |

**시스템 반응 시퀀스**:

| 순서 | 애니메이션 | 시간 |
|:---:|---------|:---:|
| 1 | 모든 플레이어 카드 한 장씩 앞면 공개 | 0.3초/장 x 4 = 1.2초 |
| 2 | 각 플레이어 족보 텍스트 표시 | 0.5초 |
| 3 | 승자 카드 골드 테두리 강조 | 0.5초 |
| 4 | 팟 → 승자에게 칩 이동 | 0.6초 |
| 5 | 골프(Perfect) 달성 시 특수 이펙트 | 1.5초 (추가) |

**데이터 변경**: 승자 `chips += pot`, 무승부 시 `pot / 생존자수` 균등 분배, 매치 기록 저장

**이탈 경로**: 자동 → 결과/보상 화면 (SCR-009)

---

### 1.9 결과/보상 화면 (Result) — SCR-009

| 항목 | 내용 |
|------|------|
| **진입 조건** | 쇼다운 완료 OR 단독 생존 승리 |
| **자동 닫힘** | 10초 후 메인 로비 복귀 |

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| (자동) 결과 표시 | 승/패 대형 표시 + 코인 손익 | 쇼다운에서 이미 처리 |
| (자동) ELO 변동 | ELO 변동 애니메이션 (랭크 매치만) | `user.elo` 갱신 |
| (자동) 경험치 획득 | 경험치 바 증가 + 레벨업 이펙트 | `user.exp += earned`, `user.level` 갱신 |
| (자동) 시즌 패스 | BP 진행도 업데이트 | `battlePass.points += earned` |
| 광고 시청 (패배 시만) | 리워드 광고 → 코인 100 지급 | `user.coins += 100` |
| [다음 판] 버튼 | 같은 모드 재매칭 | 모드별 상이 |
| [로비] 버튼 | → 메인 로비 | 없음 |

**경험치 & BP 획득 공식**:

| 이벤트 | 경험치 | BP |
|--------|:-----:|:--:|
| 게임 참여 | +10 | +10 |
| 랭크 매치 승리 | +30 | +25 |
| 일반 매치 승리 | +20 | +15 |
| AI 대전 승리 | +15 | +10 |
| 골프 달성 (보너스) | +50 | +20 |

---

### 1.10 친구 대전 방 (Friend Room) — SCR-010

| 항목 | 내용 |
|------|------|
| **진입 조건** | 메인 로비에서 친구 대전 선택 |

**화면 구조**: [방 만들기] 탭 / [방 코드 입력] 탭

**방 만들기 설정**:

| 설정 | 옵션 | 기본값 |
|------|------|--------|
| 블라인드 크기 | 일반(50/100) / 하이롤러(500/1000) | 일반 |
| 판 수 | 1판 / 3판 / 5판 | 3판 |
| 인원 | 2명 / 3명 / 4명 | 4명 |

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 방 만들기 | 방 코드 생성 (8자리 영숫자) | `rooms/{roomCode}` 생성 |
| 초대 링크 복사 | `baduki://room/{roomCode}` 클립보드 복사 | 없음 |
| 방 코드 입력 + 입장 | 방 유효성 검증 → 참가 | `rooms/{roomCode}.players` 추가 |
| 게임 시작 (방장만) | 2인 이상일 때 활성화, 게임 시작 | `match` 생성 |
| 딥링크 진입 | 앱 실행 → 로그인 → 방 자동 입장 | 방 참가 |

**에러 처리**:

| 에러 상황 | 대응 |
|---------|------|
| 잘못된 방 코드 | "존재하지 않는 방입니다" |
| 방 인원 초과 | "방이 가득 찼습니다" |
| 방장 이탈 | 다음 참가자가 방장 승계 / 1인이면 방 해체 |
| 방 만료 (10분 미시작) | 자동 해체 + "방이 만료되었습니다" |

---

### 1.11 상점 (Shop) — SCR-011

| 항목 | 내용 |
|------|------|
| **진입 조건** | 하단 탭 "상점" 또는 코인/젬 잔액 탭 |

**상점 탭 구성**:

| 탭 | 상품 | 가격대 | 피처 플래그 |
|----|------|--------|-----------|
| 카드 스킨 | 4종 개별 + 번들 | ₩1,990~₩6,990 | - |
| 보드 테마 | 3종 | ₩1,490~₩1,990 | - |
| 젬 충전 | 4단계 | ₩1,200~₩59,000 | - |
| 배틀패스 | 시즌 패스 + 레벨업 번들 | ₩4,900~₩9,900 | - |
| VIP 구독 | 월간 구독 | ₩2,900/월 | - |
| 탄 상점 | 엿보기/교체 탄 | ₩990~₩2,490 | `FEATURE_TAN_SYSTEM` ON 시만 노출 |

**구매 한도 검증** (Cloud Functions):

| 한도 | 값 | 초과 시 |
|------|:--:|--------|
| 일일 | ₩100,000 | "일일 구매 한도 초과" 안내 |
| 월간 | ₩500,000 | "월간 구매 한도 초과" 안내 |

**에러 처리**:

| 에러 상황 | 대응 |
|---------|------|
| 결제 실패 | "결제에 실패했습니다. 다시 시도해주세요" |
| 이미 보유 아이템 | 구매 버튼 → "보유 중" 뱃지 |
| 구매 한도 초과 | 한도 안내 + 남은 한도 표시 |
| 영수증 검증 실패 | 아이템 미지급 + CS 안내 |

---

### 1.12 배틀패스 (Battle Pass) — SCR-012

| 항목 | 내용 |
|------|------|
| **진입 조건** | 하단 탭 또는 시즌 패스 바 탭 |

**화면 요소**: 시즌 정보 + 진행도 트랙 (무료 30단계 + 프리미엄 30단계) + 미션 (일일/주간)

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 보상 아이템 탭 (해금 완료) | 보상 수령 애니메이션 | `user.coins/gems/cosmetics` 갱신 |
| 프리미엄 패스 구매 | IAP → 프리미엄 트랙 잠금 해제 | `battlePass.premium = true` |

**배틀패스 레벨업**: 필요 BP = `100 + (level * 10)` (점진 증가)

**미션 유형**:

| 유형 | 예시 | 보상 |
|------|------|------|
| 일일 | 3판 플레이, 1판 승리 | +30~50 BP |
| 주간 | 20판 플레이, 10판 승리 | +150 BP |

---

### 1.13 콜렉션 (Collection) — SCR-013

| 항목 | 내용 |
|------|------|
| **진입 조건** | 하단 탭 "콜렉션" |

**탭 구성**: 카드 스킨 / 보드 테마 / 이모지 (6슬롯 장착) / 아바타+프레임

**유저 액션**: 보유 아이템 미리보기 + 장착, 미보유 아이템 획득 경로 안내 (상점/배틀패스/시즌 보상)

---

### 1.14 설정 (Settings) — SCR-014

| 카테고리 | 항목 | 타입 | 기본값 | 저장 위치 |
|---------|------|------|--------|---------|
| 사운드 | BGM 볼륨 | 슬라이더 0-100% | 40% | 로컬 |
| 사운드 | SFX 볼륨 | 슬라이더 0-100% | 70% | 로컬 |
| 사운드 | 진동 | 토글 | ON | 로컬 |
| 게임 | 타이머 경고 | 토글 | ON | 로컬 |
| 계정 | 소셜 연동 상태 | 읽기 전용 | - | 서버 |
| 계정 | 게스트 → 소셜 연동 | 버튼 | - | 서버 |
| 계정 | 로그아웃 | 버튼 | - | 로컬+서버 |
| 계정 | 계정 삭제 | 버튼 | - | 서버 (PIPA) |
| 지원 | 튜토리얼 다시 보기 | 버튼 | - | - |
| 지원 | 고객센터 | 외부 링크 | - | - |
| 법적 | 이용약관 | 외부 링크 | - | - |
| 법적 | 개인정보처리방침 | 외부 링크 | - | - |
| 법적 | 확률 공시 | 인앱 화면 | - | - |
| 정보 | 앱 버전 | 텍스트 | - | 로컬 |

**계정 삭제 프로세스 (PIPA 준수)**:

1. "계정 삭제" 탭 → 삭제 사유 선택 다이얼로그
2. 재인증 (OAuth 재로그인)
3. 30일 유예 기간 안내 → 최종 확인
4. 서버: `deletionRequested = true`, `deletionDate = now + 30d`
5. 30일 후 Cloud Functions → 데이터 완전 삭제
6. 유예 기간 내 재로그인 시 삭제 취소 가능

---

### 1.15 프로필 (Profile) — SCR-015

| 항목 | 내용 |
|------|------|
| **진입 조건** | 하단 탭 "프로필" 또는 프로필 아이콘 탭 |

**화면 요소**: 아바타+프레임, 닉네임 (편집 가능, 7일 1회, 2-12자), ELO+티어, 레벨, 통계 (총 게임/승률/연승/골프 횟수), 시즌/전체/친구 랭킹 순위, 최근 매치 기록 (20판)

---

### 1.16 랭킹 (Ranking) — SCR-016

| 항목 | 내용 |
|------|------|
| **진입 조건** | 하단 탭 "랭킹" |

**탭 구성**: 전체 랭킹 (Top 100 + 내 순위) / 친구 랭킹 / 시즌 랭킹

**유저 액션**: 다른 유저 탭 → 간단 프로필 팝업 (닉네임, ELO, 티어, 승률) + 친구 추가 버튼

---

## 2. 데이터 흐름

### 2.1 게임 진행 데이터 흐름 (매칭 → 게임 → 결과 → 보상)

```
[클라이언트 — 매칭 요청]
    │ POST /api/match/queue { userId, mode, tableType }
    ▼
[Cloud Functions — 매칭 로직]
    │ 1. 바이인 코인 검증
    │ 2. ELO 범위 내 대기자 검색
    │ 3. 매칭 성공 → match 문서 생성
    │ 4. 매칭 실패 → 범위 확장 (시간 기반)
    ▼
[Realtime DB — 게임 상태 (실시간)]
    matches/{matchId}: {
      state, round, pot, currentTurn,
      players: [{ userId, hand(서버만), chips, status }],
      drawPhase, blinds, deck(서버만)
    }
    │
    ▼
[클라이언트 — 액션 전송]
    │ WebSocket: { action: "bet/draw/fold", data: {...} }
    ▼
[서버 — 유효성 검증 + 게임 로직]
    │ 체크리스트:
    │   □ 해당 플레이어의 턴인가?
    │   □ 액션이 현재 게임 단계에 유효한가?
    │   □ 드로우 시 선택 카드가 핸드에 있는가?
    │   □ 베팅 시 충분한 칩이 있는가?
    │   □ 2초 내 중복 요청이 아닌가?
    │   □ 게임 상태가 "playing"인가?
    ▼
[Realtime DB — 상태 브로드캐스트]
    │ 모든 클라이언트에 새 게임 상태 전송
    │ (상대 핸드는 뒷면, 교환 장수만 공개)
    ▼
[쇼다운 / 게임 종료]
    │ 1. 핸드 공개 + 족보 비교
    │ 2. 팟 분배
    │ 3. 매치 결과 기록
    ▼
[Cloud Functions — 보상 처리]
    │ 1. ELO 업데이트 (랭크 매치)
    │ 2. 경험치 지급 → 레벨업 검사
    │ 3. 배틀패스 BP 지급
    │ 4. 일일/주간 미션 진행도 갱신
    │ 5. 코인 보상 지급
    ▼
[Firestore — 영구 저장]
    users/{userId}: elo, exp, level, coins 갱신
    matchHistory/{matchId}: 매치 기록
    seasons/{seasonId}/rankings/{userId}: 시즌 랭킹
```

### 2.2 수익화 데이터 흐름 (상점 → 결제 → 아이템 지급)

```
[클라이언트 — 구매 요청]
    │ 1. 상점에서 아이템 선택
    │ 2. 구매 한도 로컬 사전 검증
    ▼
[Google Play / App Store — 결제]
    │ 1. 스토어 결제 UI 표시
    │ 2. 결제 성공 → 영수증 반환
    ▼
[Cloud Functions — 영수증 검증]
    │ 1. 스토어 API로 영수증 유효성 검증
    │ 2. 중복 구매 검사 (idempotency key)
    │ 3. 구매 한도 서버 재검증 (일/월)
    ▼
[검증 성공 — 아이템 지급 (Firestore 트랜잭션)]
    │ - 젬 충전: user.gems += amount
    │ - 코스메틱: user.cosmetics.{item} = true
    │ - 배틀패스: user.battlePass.premium = true
    │ - VIP 구독: user.vip.active = true, expiry = +30d
    │ - purchaseLog에 기록
    ▼
[클라이언트 — 지급 확인]
    │ Firestore 리스너로 실시간 반영
    │ 성공 애니메이션 표시
```

### 2.3 소셜 데이터 흐름 (친구 → 초대 → 대전)

```
[친구 추가]
    │ POST /api/friends/request { targetUserId }
    │ → friendRequests/{targetId}/{fromId} 생성
    │ → FCM Push: "친구 요청이 도착했습니다"
    ▼
[친구 수락]
    │ POST /api/friends/accept { requestId }
    │ → 양방향 friends 배열 추가
    ▼
[친구 대전 초대]
    │ 1. 방 생성: rooms/{roomCode}
    │ 2. 딥링크 생성: baduki://room/{roomCode}
    │ 3. 외부 공유 (카카오톡/SMS/클립보드)
    ▼
[딥링크 진입]
    │ baduki://room/{roomCode}
    │ → 앱 실행 → 로그인 확인 → 방 자동 입장
    ▼
[게임 시작]
    │ 방장 "게임 시작" → match 생성
    │ → 일반 게임 플레이 데이터 흐름과 동일
```

---

## 3. 비즈니스 로직 상세

### 3.1 매칭 알고리즘 (ELO 기반)

| 기능 | 입력 | 처리 | 출력 | 예외 |
|------|------|------|------|------|
| 매칭 큐 등록 | userId, mode, tableType | 바이인 검증 → 매칭 큐 삽입 | queueEntry | 코인 부족 시 거부 |
| 매칭 탐색 | queueEntry | ELO 범위 내 상대 탐색 (시간 기반 확장) | matchedPair or null | 30초 타임아웃 |
| 매칭 확정 | matchedPair | match 문서 생성, 큐 제거, 바이인 차감 | matchId | 동시 매칭 충돌 시 한쪽 재큐 |

**매칭 알고리즘 의사코드**:

```
function findMatch(player, elapsedTime):
    baseRange = 50
    expandRate = 50   // 5초마다 +50
    maxRange = 200

    currentRange = min(baseRange + floor(elapsedTime / 5) * expandRate, maxRange)

    candidates = queue.filter(c =>
        abs(c.elo - player.elo) <= currentRange
        AND c.tableType == player.tableType
        AND c.mode == player.mode
    )

    if candidates.length > 0:
        return candidates.sortBy(abs(c.elo - player.elo))[0]
    return null
```

### 3.2 게임 진행 로직

#### 3.2.1 카드 배분

| 기능 | 입력 | 처리 | 출력 | 예외 |
|------|------|------|------|------|
| 덱 셔플 | 52장 배열 | Fisher-Yates 셔플 (서버 SecureRandom) | 셔플 덱 | 없음 |
| 초기 배분 | 셔플 덱, N명 | 각 플레이어에게 4장씩 | player.hand[4], 남은 덱 | 2-4인 검증 |

#### 3.2.2 드로우 (카드 교환)

| 기능 | 입력 | 처리 | 출력 | 예외 |
|------|------|------|------|------|
| 드로우 요청 | userId, selectedCards[] | 1. 핸드 내 존재 검증 2. 선택 카드 제거 3. 덱에서 동수 추출 4. 핸드에 추가 | 새 hand[4], 교환 장수 공개 | 선택 카드 미보유 시 거부 |
| Stand Pat | userId | 교환 없음, 교환 장수 0 공개 | hand 변경 없음 | 없음 |

#### 3.2.3 베팅

| 기능 | 입력 | 처리 | 출력 | 예외 |
|------|------|------|------|------|
| Fold | userId | status → folded | 남은 플레이어 수 | 이미 folded면 거부 |
| Check | userId | 현재 베팅 없을 때만 | 다음 턴 | 베팅 존재 시 거부 |
| Call | userId | 콜 금액 계산 + 칩 차감 | pot, chips 갱신 | 칩 부족 → All-in |
| Raise | userId, amount | 금액 검증 (≥ BB, ≤ 보유칩) | pot, chips, currentBet 갱신 | 범위 위반 시 거부 |
| All-in | userId | 보유 칩 전부 → 팟 | pot 갱신, chips = 0 | 이미 0이면 거부 |

#### 3.2.4 족보 판정 & 승자 결정

| 기능 | 입력 | 처리 | 출력 | 예외 |
|------|------|------|------|------|
| 족보 판정 | hand[4] | Made(1급)/베이스(2급)/투베이스(3급)/노페어(4급) 판정 | { grade, highCards[] } | 없음 |
| 승자 결정 | players[].handRank | 급 비교 → 동급 시 highCards 순차 비교 | winnerId or "tie" | 무승부 시 팟 균등 분배 |

**족보 판정 알고리즘**:

```
function evaluateHand(hand):
    suits = hand.map(c => c.suit)
    ranks = hand.map(c => c.rank)  // A=1, 2=2, ... K=13

    if uniqueSuits == 4 AND uniqueRanks == 4:
        return { grade: 1, name: "메이드", cards: sortDesc(ranks) }

    // 베이스: 중복 제거하여 최선 3장 조합 선택
    best3 = findBestNCards(hand, 3)
    if best3:
        return { grade: 2, name: "베이스", cards: sortDesc(best3) }

    // 투베이스: 최선 2장 선택
    best2 = findBestNCards(hand, 2)
    if best2:
        return { grade: 3, name: "투베이스", cards: sortDesc(best2) }

    // 노페어
    return { grade: 4, name: "노페어", cards: [min(ranks)] }
```

### 3.3 ELO 변동 로직

| 기능 | 입력 | 처리 | 출력 |
|------|------|------|------|
| ELO 업데이트 | winnerId, loserId | K값 결정 → Expected 계산 → 새 ELO 산출 | 양쪽 새 ELO |

**ELO 공식**:

```
새 ELO = 이전 ELO + K * (Actual - Expected)
Expected = 1 / (1 + 10^((상대 ELO - 내 ELO) / 400))
Actual = 1 (승) / 0 (패)

K값:
  신규 (ELO < 1200, 게임 < 30판): K = 64
  일반 (ELO 1200-1500):           K = 32
  상위 (ELO > 1500):              K = 16
```

**ELO 티어**:

| ELO 범위 | 티어명 | 아이콘 색상 |
|---------|--------|---------|
| 900 미만 | 브론즈 | Brown |
| 900-1100 | 실버 | Silver |
| 1100-1300 | 골드 | Gold |
| 1300-1500 | 플래티넘 | Teal |
| 1500-1700 | 다이아몬드 | Blue |
| 1700+ | 레전드 | Gold + 특수 이펙트 |

### 3.4 탄 시스템 로직

| 기능 | 입력 | 처리 | 출력 | 예외 |
|------|------|------|------|------|
| 엿보기 탄 사용 | userId, targetId | 피처 플래그 검증 → 탄 보유 검증 → 대상 핸드 중 랜덤 1장 공개 | 공개 카드 (사용자에게만) | 피처 OFF, 탄 미보유, 대상 folded |
| 교체 탄 사용 | userId, selectedCards[] | 피처 플래그 검증 → 탄 보유 검증 → 추가 교환 실행 | 새 hand | 피처 OFF, 탄 미보유, 드로우 라운드 아닐 때 |

**피처 플래그 이중 잠금**:

```
서버: Firebase Remote Config → FEATURE_TAN_SYSTEM (기본: false)
클라이언트: 컴파일 타임 상수 ENABLE_TAN (심의 빌드: false)

두 값 모두 true일 때만 탄 시스템 활성화.
심의 빌드: 로컬 상수 = false → 코드 경로 도달 불가.
```

### 3.5 경제 로직 (코인/젬)

| 기능 | 입력 | 처리 | 출력 | 예외 |
|------|------|------|------|------|
| 코인 획득 | userId, source, amount | Firestore 트랜잭션: coins += amount | 갱신 잔액 | 없음 |
| 코인 소비 | userId, purpose, amount | 잔액 검증 → coins -= amount | 갱신 잔액 | 잔액 부족 시 거부 |
| 젬 충전 (IAP) | userId, productId, receipt | 영수증 검증 → gems += amount | 갱신 잔액 | 영수증 위조 시 거부 |
| 젬 → 코인 환전 | userId, gemAmount | gems -= amount, coins += (amount * 50) | 갱신 잔액 | 역방향 불가 |

**코인 유입/유출 균형**:

| 유입 | 코인/이벤트 | 유출 | 코인/이벤트 |
|------|:---------:|------|:---------:|
| 일일 보너스 | +200 | 연습 테이블 참가비 | -50 |
| 7일 연속 보너스 | +2,000 | 일반 테이블 참가비 | -50~-100 |
| 일반 승리 보상 | +80 | 하이롤러 참가비 | -500~-1,000 |
| 패배 경험치 보상 | +20 | 코스메틱 (코인) 구매 | -500~-5,000 |
| 광고 시청 | +100 | | |
| 레벨업 | +500 | | |

### 3.6 시즌/배틀패스 로직

| 기능 | 입력 | 처리 | 출력 |
|------|------|------|------|
| 시즌 시작 | seasonId | ELO 소프트 리셋 + 배틀패스 초기화 + 랭킹 리셋 | 새 시즌 데이터 |
| 시즌 종료 | seasonId | 최종 랭킹 확정 + 랭킹 보상 지급 + 아카이브 | 보상 내역 |

**ELO 소프트 리셋**: `newElo = 900 + (prevElo - 900) * 0.75`

**시즌 랭킹 보상**:

| 순위 | 보상 |
|------|------|
| Top 1% (레전드) | "레전드" 칭호 + 한정 카드 스킨 + 50,000코인 + 레전드 프레임 |
| Top 5% (다이아몬드) | "다이아" 칭호 + 20,000코인 + 전용 이모지 3종 |
| Top 10% (플래티넘) | "플래티넘" 칭호 + 10,000코인 |
| Top 25% (골드) | "골드" 칭호 + 5,000코인 |
| Top 50% (실버) | 2,000코인 |
| 참가 보상 | 500코인 (1판 이상 플레이) |

### 3.7 구매 한도 시스템

| 한도 | 값 | 초과 시 |
|------|:--:|--------|
| 일일 | ₩100,000 | 24시간 차단 + 알림 |
| 월간 | ₩500,000 | 월말까지 차단 + 알림 |

```
Cloud Functions: verifyPurchaseLimit(userId, amount)
  1. purchaseLog에서 일간/월간 합산 조회
  2. 한도 초과 → 구매 거부 + 에러 코드
  3. 한도 내 → 구매 처리 + purchaseLog 기록
```

### 3.8 확률 공시

현재 설계에서 확률형 아이템(가챠/뽑기) **없음**. 모든 아이템 직접 구매 방식. 향후 확률형 요소 추가 시 설정 > 법적 문서 > 확률 공시 메뉴에서 공시.

---

## 4. API/서비스 엔드포인트

### 4.1 인증 API

| Method | Path | 설명 | Request Body | Response |
|--------|------|------|-------------|----------|
| POST | `/api/auth/login` | 소셜 로그인 | `{ provider, idToken }` | `{ userId, accessToken, isNewUser }` |
| POST | `/api/auth/guest` | 게스트 로그인 | `{ deviceId }` | `{ userId, accessToken }` |
| POST | `/api/auth/link` | 게스트→소셜 연동 | `{ guestToken, provider, idToken }` | `{ userId, merged }` |
| POST | `/api/auth/refresh` | 토큰 갱신 | `{ refreshToken }` | `{ accessToken }` |
| DELETE | `/api/auth/account` | 계정 삭제 요청 | `{ reason }` | `{ deletionDate }` |
| POST | `/api/auth/cancel-deletion` | 삭제 취소 | `{}` | `{ success }` |

### 4.2 게임 API

| Method | Path | 설명 | Request Body | Response |
|--------|------|------|-------------|----------|
| POST | `/api/match/queue` | 매칭 큐 등록 | `{ mode, tableType }` | `{ queueId, estimatedWait }` |
| DELETE | `/api/match/queue` | 매칭 취소 | `{}` | `{ success }` |
| POST | `/api/match/ai` | AI 대전 시작 | `{ difficulty, playerCount }` | `{ matchId }` |
| WS | `/ws/game/{matchId}` | 게임 상태 WebSocket | - | 실시간 게임 상태 |
| POST | `/api/game/{matchId}/action` | 게임 액션 (REST 폴백) | `{ action, data }` | `{ success, newState }` |
| GET | `/api/game/{matchId}/state` | 게임 상태 조회 (폴백) | - | `{ gameState }` |

**WebSocket 메시지 프로토콜**:

| 방향 | 타입 | 페이로드 | 설명 |
|------|------|---------|------|
| C→S | `action` | `{ type: "fold/check/call/raise/allin/draw", data }` | 플레이어 액션 |
| S→C | `state_update` | `{ gameState, lastAction }` | 상태 브로드캐스트 |
| S→C | `showdown` | `{ hands, rankings, winner, pot }` | 쇼다운 결과 |
| S→C | `game_end` | `{ result, rewards }` | 게임 종료 + 보상 |
| S→C | `error` | `{ code, message }` | 에러 알림 |
| C→S | `emoji` | `{ emojiId }` | 이모지 전송 |
| S→C | `emoji` | `{ fromUserId, emojiId }` | 이모지 수신 |
| C↔S | `ping/pong` | `{}` | 연결 유지 (30초 간격) |

### 4.3 소셜 API

| Method | Path | 설명 | Request Body | Response |
|--------|------|------|-------------|----------|
| POST | `/api/friends/request` | 친구 요청 | `{ targetUserId }` | `{ requestId }` |
| POST | `/api/friends/accept` | 친구 수락 | `{ requestId }` | `{ success }` |
| POST | `/api/friends/reject` | 친구 거절 | `{ requestId }` | `{ success }` |
| DELETE | `/api/friends/{friendId}` | 친구 삭제 | - | `{ success }` |
| GET | `/api/friends` | 친구 목록 | - | `{ friends: [{ userId, nickname, elo, online }] }` |
| POST | `/api/rooms/create` | 방 생성 | `{ blindType, rounds, maxPlayers }` | `{ roomCode, inviteLink }` |
| POST | `/api/rooms/join` | 방 참가 | `{ roomCode }` | `{ roomState }` |
| POST | `/api/rooms/{code}/start` | 게임 시작 (방장만) | `{}` | `{ matchId }` |
| DELETE | `/api/rooms/{code}/leave` | 방 퇴장 | - | `{ success }` |
| POST | `/api/reports` | 유저 신고 | `{ targetUserId, reason, matchId }` | `{ reportId }` |

### 4.4 경제 API

| Method | Path | 설명 | Request Body | Response |
|--------|------|------|-------------|----------|
| GET | `/api/shop/catalog` | 상점 카탈로그 | - | `{ categories: [...items] }` |
| POST | `/api/purchase/verify` | 영수증 검증 | `{ receipt, productId, store }` | `{ success, itemGranted }` |
| GET | `/api/inventory` | 인벤토리 조회 | - | `{ coins, gems, cosmetics, tans }` |
| POST | `/api/exchange/gem-to-coin` | 젬→코인 환전 | `{ gemAmount }` | `{ newGems, newCoins }` |
| GET | `/api/battlepass` | 배틀패스 상태 | - | `{ level, points, rewards, premium }` |
| POST | `/api/battlepass/claim` | 보상 수령 | `{ level }` | `{ items }` |
| POST | `/api/daily-login` | 일일 접속 보너스 | `{}` | `{ day, reward, streak }` |
| GET | `/api/missions` | 미션 목록 | - | `{ daily: [...], weekly: [...] }` |

### 4.5 유저 API

| Method | Path | 설명 | Request Body | Response |
|--------|------|------|-------------|----------|
| GET | `/api/users/me` | 내 프로필 | - | `{ user }` |
| PATCH | `/api/users/me` | 프로필 수정 | `{ nickname, avatar }` | `{ user }` |
| GET | `/api/users/{userId}` | 다른 유저 프로필 (공개 정보만) | - | `{ publicProfile }` |
| GET | `/api/users/me/match-history` | 매치 기록 | `?limit=20&offset=0` | `{ matches }` |
| GET | `/api/users/me/stats` | 통계 | - | `{ totalGames, winRate, ... }` |
| POST | `/api/users/me/cosmetics/equip` | 코스메틱 장착 | `{ type, itemId }` | `{ success }` |

### 4.6 랭킹 API

| Method | Path | 설명 | Response |
|--------|------|------|----------|
| GET | `/api/rankings/global?limit=100` | 전체 랭킹 | `{ rankings, myRank }` |
| GET | `/api/rankings/friends` | 친구 랭킹 | `{ rankings, myRank }` |
| GET | `/api/rankings/season?seasonId=` | 시즌 랭킹 | `{ rankings, myRank }` |

### 4.7 시스템/설정 API

| Method | Path | 설명 | Response |
|--------|------|------|----------|
| GET | `/api/config/feature-flags` | 피처 플래그 | `{ flags }` |
| GET | `/api/config/app-version` | 최소 버전 확인 | `{ minVersion, latestVersion, forceUpdate }` |
| GET | `/api/config/maintenance` | 점검 상태 | `{ maintenance, message, endTime }` |
| GET | `/api/config/season` | 현재 시즌 정보 | `{ seasonId, name, startDate, endDate }` |

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|---------|--------|
| 1.0 | 2026-02-27 | 초안 (부분 작성) | Claude Sonnet 4.6 |
| 2.0 | 2026-02-27 | 전면 보강 — 16개 화면 상세, 데이터 흐름 3종, 비즈니스 로직 8개, API 40+ | Claude Opus 4.6 |

---

**다음 문서**: 서비스 사이트맵 (`2026-02-27-s4-sitemap.md`)
