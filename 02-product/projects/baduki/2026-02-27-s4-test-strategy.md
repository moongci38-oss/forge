# 로우 바둑이 (Low Baduki) — S4 테스트 전략서 (서비스 + 관리자 통합)

**작성일**: 2026-02-27
**프로젝트 유형**: 게임 개발 (SIGIL S4 — 개발 트랙)
**기술 스택**: S4 상세 개발 계획서 참조

---

> 프로젝트 전역 테스트 방침을 정의한다.
> Trine Phase에서 작성하는 개별 Spec의 테스트 섹션은 이 전략서를 기반으로 한다.
> **3대 시스템(게임 클라이언트 / Firebase 백엔드 / 관리자 웹)**을 각각 다룬다.

---

## 목차

1. [테스트 계층 및 비율](#1-테스트-계층-및-비율)
2. [게임 클라이언트 테스트 전략](#2-게임-클라이언트-테스트-전략)
3. [Firebase 백엔드 테스트 전략](#3-firebase-백엔드-테스트-전략)
4. [관리자 프론트엔드 테스트 전략](#4-관리자-프론트엔드-테스트-전략)
5. [관리자 백엔드 테스트 전략](#5-관리자-백엔드-테스트-전략)
6. [E2E 테스트 전략](#6-e2e-테스트-전략)
7. [테스트 데이터 시딩 전략](#7-테스트-데이터-시딩-전략)
8. [테스트 환경 설정](#8-테스트-환경-설정)
9. [커버리지 목표](#9-커버리지-목표)
10. [특수 테스트 영역](#10-특수-테스트-영역)
11. [CI/CD 통합](#11-cicd-통합)

---

## 1. 테스트 계층 및 비율

### 1.1 게임 클라이언트 (Unity)

| 계층 | 비율 목표 | 실행 시점 | 도구 | 대상 |
|------|:-------:|---------|------|------|
| 단위 테스트 (Unit) | ~70% | 매 커밋 (pre-push) | NUnit (Unity Test Framework) | 게임 로직, AI 봇, 유틸리티 |
| 통합 테스트 (Integration) | ~20% | CI (GitHub Actions + GameCI) | Unity Test Framework + Firebase Emulator | 네트워크, Firebase 연동, FSM 전체 흐름 |
| E2E 테스트 | ~10% | staging 배포 후 | Unity UI Test Framework | 핵심 유저 플로우 |
| 모바일 디바이스 E2E | (E2E 내) | staging 배포 후 | Firebase Test Lab | 실기기 검증 |

### 1.2 Firebase 백엔드 (Cloud Functions)

| 계층 | 비율 목표 | 실행 시점 | 도구 | 대상 |
|------|:-------:|---------|------|------|
| 단위 테스트 (Unit) | ~70% | 매 커밋 | Jest | 매칭, ELO, 보상, IAP 검증 로직 |
| 통합 테스트 (Integration) | ~25% | CI | Jest + Firebase Emulator Suite | Functions ↔ Firestore ↔ Auth |
| 부하 테스트 | (별도) | 소프트 런치 전 | k6 | CCU 시뮬레이션 |

### 1.3 관리자 웹 애플리케이션

| 계층 | 비율 목표 | 실행 시점 | 도구 | 대상 |
|------|:-------:|---------|------|------|
| 단위 테스트 (Unit) | ~70% | 매 커밋 (pre-push) | Jest + React Testing Library | 컴포넌트, 커스텀 훅, 유틸리티 |
| 통합 테스트 (Integration) | ~20% | CI | Jest + Supertest | API 엔드포인트, DB 연동, Socket.IO |
| E2E 테스트 | ~10% | staging 배포 후 | Playwright | 관리자 핵심 플로우 |
| 모바일 반응형 E2E | (E2E 내) | staging 배포 후 | Playwright devices | 관리자 모바일 뷰포트 |

> 비율은 테스트 피라미드 원칙 기반. 게임 프로젝트 특성상 게임 로직 단위 테스트 비중이 가장 높다.

---

## 2. 게임 클라이언트 테스트 전략

### 2.1 게임 로직 단위 테스트 (NUnit — EditMode)

핵심 게임 로직은 **100% 커버리지**를 목표로 한다. EditMode 테스트로 Unity 런타임 없이 빠르게 실행.

| 컴포넌트 | 테스트 항목 | 예시 | 우선순위 |
|---------|-----------|------|:-------:|
| **HandEvaluator** | 족보 판정 정확성 | 메이드/베이스/투베이스/노페어 분류, 같은 급 내 높은 카드 비교, 무승부 처리 | P0 |
| **CardDeck** | 덱 초기화/셔플 | 52장 정확성, Fisher-Yates 균등 분포, 시드 기반 재현 | P0 |
| **BettingManager** | 베팅 라운드 관리 | Fold/Check/Call/Raise/All-in 유효성, 팟 관리, 사이드 팟 계산, 블라인드 강제 베팅 | P0 |
| **DrawManager** | 3회 드로우 처리 | 0-4장 선택 교환, 교환 장수 공개(카드 내용 비공개), Stand Pat, 덱 소진 시 폴드 카드 재활용 | P0 |
| **GameStateMachine** | FSM 상태 전이 | Waiting→Dealing→Betting→Drawing→Showdown→Result 정상 전이, 예외 상태(연결 끊김, 전원 폴드) | P0 |
| **ShowdownResolver** | 쇼다운 판정 | 핸드 비교, 승자 결정, 팟 분배, 무승부 균등 분배 | P0 |
| **TurnTimer** | 타이머 관리 | 베팅 20초/드로우 15초, 5초 경고, 만료 시 자동 액션(Check or Fold/Stand Pat) | P0 |
| **BlindManager** | 블라인드 관리 | SB/BB 배치, 딜러 로테이션 | P0 |
| **ELO 계산** | ELO 변동 공식 | K값(64/32/16) 구간별, 시즌 소프트 리셋(75%), 티어 분류 | P0 |
| **EconomyManager** | 코인/젬 계산 | 획득/소모 정확성, 잔액 부족 시 거부, 인플레이션 방지 로직 | P1 |

**족보 판정 핵심 테스트 케이스**:

```
- 골프(A-2-3-4, 4무늬) → 최강 메이드
- 일반 메이드(A-2-3-5 등) → 높은 카드로 비교
- 베이스(3카드) → 중복 1장 제거 후 3카드 비교
- 투베이스(2카드) → 중복 2장 제거 후 2카드 비교
- 노페어 → 전부 중복, 4장 중 최저 1장으로 비교
- 메이드 vs 베이스 → 메이드 승리
- 같은 메이드 내 A-2-3-5 vs A-2-3-6 → A-2-3-5 승리 (높은 카드가 낮을수록 유리)
- 무승부 → 팟 균등 분배
```

### 2.2 AI 봇 단위 테스트 (NUnit — EditMode)

| 봇 | 테스트 항목 | 검증 기준 |
|----|-----------|---------|
| **EasyBot** | 드로우: 항상 메이드 목표 | 메이드 보유 시 Stand Pat, 미보유 시 중복 카드 교환 |
| | 베팅: 메이드 시 Call/Check, 미보유 시 80% Fold | 1000판 시뮬레이션으로 분포 검증 |
| | 블러핑: 1% 무작위 | 통계적 검증 (±0.5% 이내) |
| **MediumBot** | 드로우: 족보 기대값 계산 | 상위 50% 핸드 유지 확인 |
| | 베팅: 팟 오즈 기반 | 팟 오즈 ≥ 핸드 확률 시 Call |
| | 블러핑: 20-30% | 통계적 검증 (1000판 시뮬레이션) |
| | 상대 모델링 | 드로우 장수 추적 → 핸드 강도 추정 정확도 |
| **HardBot** | CFR 모델 로드 | ONNX 파일 로드 성공, 입력 텐서 변환(~230차원) |
| | 추론 성능 | CPU 폴백 <50ms, NPU 가속 <10ms |
| | GTO 블러핑 | 내시 균형 기반 전략과 일치도 |

**AI 성능 벤치마크 테스트**:

```csharp
[Test]
public void HardBot_InferenceTime_UnderThreshold()
{
    // Arrange: 게임 상태 → 입력 텐서 (~230차원)
    // Act: 모델 추론
    // Assert: CPU <50ms, NPU <10ms (지원 기기)
}
```

### 2.3 UI 테스트 (Unity UI Test Framework — PlayMode)

PlayMode 테스트로 Unity 런타임에서 UI 렌더링 및 인터랙션을 검증한다.

| 화면 | 검증 항목 |
|------|---------|
| 스플래시/로딩 (SCR-001) | Firebase 초기화, Remote Config 페치, 에셋 로드, 3초 이내 완료 |
| 로그인 (SCR-002) | 소셜 로그인 3종 버튼 존재, 자동 로그인 흐름 |
| 메인 로비 (SCR-003) | 상단바(코인/젬/프로필), 게임 모드 5개, 하단 탭바 5개 |
| 게임 테이블 (SCR-007) | 카드 4장 배분/표시, 베팅 버튼 4종, 드로우 선택, 타이머 바, 이모지 버튼 |
| 쇼다운 (SCR-008) | 카드 공개 애니메이션, 족보 비교 강조, 승자 표시 |
| 결과/보상 (SCR-009) | 코인 +/-, ELO 변동, 시즌 패스 진행도, 다음 판/로비 버튼 |
| 튜토리얼 | 5단계 순차 진행, 건너뛰기 불가, 완료 보상 코인 500 |
| 상점 | 코스메틱 목록, 가격 표시, 구매 플로우 |

**UI 네비게이션 플로우 테스트**:

```
로그인 → 메인 로비 → AI 대전 선택 → 난이도 선택 → 게임 테이블 → 쇼다운 → 결과 → 로비
로그인 → 메인 로비 → 친구 대전 → 방 생성 → 게임 테이블 → 결과 → 로비
```

### 2.4 네트워크 테스트

| 테스트 유형 | 도구 | 검증 항목 |
|-----------|------|---------|
| 지연 시뮬레이션 | Unity Network Simulator | 100ms / 500ms / 1000ms 지연 시 게임 플레이 가능 여부 |
| 패킷 손실 시뮬레이션 | Unity Network Simulator | 1% / 5% / 10% 손실 시 동기화 유지 |
| 재연결 처리 | 수동 + 자동화 | 연결 끊김 → 20초 Grace Period → 재접속 시 상태 복원 |
| Server-Authoritative 검증 | Firebase Emulator | 아래 6항목 체크리스트 |

**Server-Authoritative 검증 6항목**:

| # | 검증 항목 | 테스트 방법 |
|:-:|---------|-----------|
| 1 | 해당 플레이어의 턴인가? | 타 플레이어 턴에 액션 전송 → 서버 거부 확인 |
| 2 | 액션이 현재 게임 단계에 유효한가? | Drawing 단계에서 Bet 전송 → 거부 |
| 3 | 드로우 시 선택 카드가 핸드에 있는가? | 보유하지 않은 카드 ID 전송 → 거부 |
| 4 | 베팅 시 충분한 칩이 있는가? | 잔액 초과 Raise 전송 → 거부 |
| 5 | 2초 내 중복 요청이 아닌가? | 동일 액션 연속 전송 → 두 번째 거부 |
| 6 | 게임 상태가 "playing"인가? | 종료된 게임에 액션 전송 → 거부 |

### 2.5 성능 테스트

| 항목 | 목표값 | 측정 방법 | 실행 시점 |
|------|--------|---------|---------|
| 프레임레이트 | 30 FPS 고정 (모바일) / 60 FPS (PC) | Unity Profiler + 실기기 측정 | 매 스프린트 |
| 메모리 사용량 | < 200MB RAM | Unity Memory Profiler | 매 스프린트 |
| 앱 크기 | < 100MB (초기 다운로드) | 빌드 아티팩트 크기 확인 | 매 빌드 |
| 초기 로딩 | < 3초 (스플래시 → 로비) | 실기기 타이머 | 매 스프린트 |
| 네트워크 패킷 | < 1KB/액션 | Wireshark / Unity Profiler | 네트워크 개발 시 |
| AI 추론 (Hard) | < 50ms (CPU), < 10ms (NPU) | Unity Profiler 타이머 | AI 개발 시 |
| AI 모델 크기 | < 50MB (float16) | 파일 크기 확인 | 모델 배포 시 |

### 2.6 접근성 테스트

| 항목 | 기준 | 검증 방법 |
|------|------|---------|
| 터치 타겟 | 48x48dp 이상 (모바일 게임 권장) | UI 요소 크기 수동 검증 |
| 색상 대비 | 4.5:1+ (텍스트), 3:1+ (그래픽) | WCAG 대비 검사 도구 |
| 카드 무늬 구분 | 색상 + 아이콘 형태 이중 인코딩 | 색맹 시뮬레이션 |
| 턴 타이머 피드백 | 시각 + 청각 + 촉각 3중 | 각 피드백 채널 개별 테스트 |
| Safe Area | iOS notch/Home Indicator, Android system bars | 실기기 테스트 (iPhone/Galaxy) |

---

## 3. Firebase 백엔드 테스트 전략

### 3.1 Cloud Functions 단위 테스트 (Jest)

| 함수 | 테스트 항목 | 검증 기준 |
|------|-----------|---------|
| `matchmaking()` | ELO 기반 매칭 | ±50→±200 점진 확장, 30초 내 매칭 또는 봇 투입 |
| `updateELO()` | ELO 변동 계산 | K값(64/32/16) 구간별 정확성, 시즌 리셋(75%) |
| `processReward()` | 보상 지급 | 승리 +80/패배 +20/일일 +200 정확성, 중복 지급 방지 |
| `verifyIAP()` | IAP 영수증 검증 | Google Play/App Store 영수증 유효성, 이미 처리된 영수증 거부 |
| `seasonReset()` | 시즌 리셋 처리 | ELO 소프트 리셋 공식, 배틀패스 초기화, 시즌 보상 지급 |
| `reportProcessing()` | 신고 접수 | 신고 데이터 저장, 카테고리 분류, 에스컬레이션 |
| `purchaseLimitCheck()` | 구매 한도 검증 | 일 10만원/월 50만원 초과 시 거부 |

### 3.2 Cloud Functions 통합 테스트 (Jest + Firebase Emulator Suite)

Firebase Emulator Suite(Auth + Firestore + Functions + Realtime DB)를 로컬에서 실행하여 통합 테스트한다.

| 시나리오 | 검증 항목 |
|---------|---------|
| 유저 생성 → 첫 로그인 | Auth 토큰 발급, Firestore `users/` 문서 자동 생성, 초기값(ELO 1500, 코인 500) |
| 매칭 → 게임 생성 | `matches/` 문서 생성, 양측 플레이어 연결, 게임 상태 "playing" |
| 게임 완료 → 보상 지급 | ELO 업데이트, 코인 지급, 배틀패스 포인트 적립 |
| IAP 구매 → 젬 지급 | 영수증 검증 → 젬 추가 → 구매 로그 저장 |
| 일일 보너스 수령 | 200코인 지급, 7일 연속 시 2000코인 보너스, 이중 수령 방지 |
| 구매 한도 초과 | 일 10만원 초과 시 거부 + 월 50만원 초과 시 거부 |

### 3.3 Firestore Security Rules 테스트

```javascript
// Firebase Emulator에서 Security Rules 검증
describe('Firestore Security Rules', () => {
  test('유저는 자신의 프로필만 읽기/쓰기 가능');
  test('다른 유저의 코인/젬 필드 수정 불가');
  test('매치 데이터는 참가자만 읽기 가능');
  test('ELO는 Cloud Functions만 수정 가능 (클라이언트 직접 수정 불가)');
  test('관리자 Admin SDK는 전체 접근 가능');
});
```

---

## 4. 관리자 프론트엔드 테스트 전략

### 4.1 컴포넌트 단위 테스트 (Jest + React Testing Library)

| 대상 | 테스트 방식 | 도구 | 예시 |
|------|-----------|------|------|
| UI 컴포넌트 | 단위 | Jest + RTL | DataTable 렌더링, 필터, 정렬, 페이지네이션 |
| 커스텀 훅 | 단위 | @testing-library/react-hooks | useAuth, useWebSocket, useKPI 상태 변화 |
| Zustand 스토어 | 단위 | Jest | 상태 업데이트, 셀렉터 |
| 유틸리티 함수 | 단위 | Jest | 날짜 포맷, KPI 계산, 권한 체크 |

### 4.2 통합 테스트

| 대상 | 테스트 방식 | 도구 | 예시 |
|------|-----------|------|------|
| 페이지 통합 | 통합 | Jest + RTL + MSW | 대시보드 페이지 → API 호출 → 차트 렌더링 |
| API 모킹 | 통합 | MSW (Mock Service Worker) | REST API 요청 가로채기, 에러 상태 시뮬레이션 |
| Socket.IO 연동 | 통합 | Jest + mock-socket | 실시간 데이터 수신 → 위젯 업데이트 |
| 라우팅/인증 | 통합 | Jest + RTL + React Router | 미인가 접근 → 로그인 리다이렉트, RBAC 권한별 메뉴 노출 |

### 4.3 반응형/모바일 렌더링 테스트

| 대상 | 테스트 방식 | 도구 | 예시 |
|------|-----------|------|------|
| 반응형 레이아웃 | 단위/통합 | Jest + `matchMedia` mock | 모바일(375px): 사이드바 숨김, 햄버거 메뉴 표시 |
| 모바일 컴포넌트 전환 | 단위 | Jest + RTL | 테이블(768px+) vs 카드 리스트(~767px) |

### 4.4 FE 테스트 작성 원칙

- 구현 디테일이 아닌 **사용자 행동** 기반 테스트
- `data-testid`를 사용하되 ARIA role/label 우선
- 스냅샷 테스트는 최소화 (변경에 취약)
- 관리자 RBAC 4단계(Super Admin/운영자/CS/분석가) 각 역할별 접근 테스트 필수

---

## 5. 관리자 백엔드 테스트 전략

### 5.1 단위 테스트 (Jest)

| 대상 | 테스트 방식 | 예시 |
|------|-----------|------|
| Service 비즈니스 로직 | 단위 (의존성 Mock) | UserService.ban() → 제재 기록 생성 + Firestore 동기화 |
| Middleware | 단위 | authMiddleware → JWT 검증, rbacMiddleware → 역할별 접근 제어 |
| 유틸리티 | 단위 | KPI 계산, 날짜 범위 필터, 페이지네이션 헬퍼 |

### 5.2 통합 테스트 (Jest + Supertest)

| 대상 | 테스트 방식 | 예시 |
|------|-----------|------|
| REST API 엔드포인트 | Supertest | `/api/users` 검색, `/api/reports` CRUD, `/api/balancing` 변경 |
| DB 연동 (Prisma + PostgreSQL) | 통합 | CRUD + 트랜잭션 롤백, 인덱스 쿼리 성능 |
| Socket.IO 이벤트 | socket.io-client | 실시간 모니터링 데이터 push 검증 |
| Firebase Admin SDK 연동 | 통합 | Firestore 유저 데이터 읽기, Remote Config 업데이트 |

### 5.3 권한 테스트 매트릭스

| API 엔드포인트 | Super Admin | 운영자 | CS | 분석가 | 비인증 |
|--------------|:----------:|:-----:|:--:|:-----:|:-----:|
| `GET /api/users` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `POST /api/users/:id/ban` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `POST /api/users/:id/coins` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `PUT /api/balancing/*` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `PUT /api/features/*` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `GET /api/analytics/*` | ✅ | ✅ | ❌ | ✅ | ❌ |
| `GET /api/monitoring/*` | ✅ | ✅ | ✅ | ✅ | ❌ |

### 5.4 BE 테스트 작성 원칙

- 서비스 레이어: 의존성 Mock 주입 (Prisma Client, Firebase Admin SDK)
- 컨트롤러 레이어: Supertest로 실제 HTTP 요청/응답 검증
- DB 레이어: 테스트 전용 PostgreSQL Docker 컨테이너 사용

---

## 6. E2E 테스트 전략

### 6.1 게임 클라이언트 E2E 시나리오

| # | 시나리오 | 중요도 | 예상 시간 |
|:-:|---------|:-----:|:-------:|
| 1 | 첫 실행 → 회원가입 → 튜토리얼 5단계 → 첫 AI Easy 대전 → 결과 | HIGH | 5분 |
| 2 | 로그인 → 랭크 매치 매칭 → 게임 플레이 (4라운드 베팅 + 3드로우) → 쇼다운 → 보상 | HIGH | 5분 |
| 3 | 로그인 → 친구 대전 방 생성 → 코드 공유 → 게임 → 결과 | HIGH | 5분 |
| 4 | 상점 → 코스메틱 구매 (젬) → 장착 → 게임에서 적용 확인 | MEDIUM | 3분 |
| 5 | IAP 구매 → 젬 충전 → 잔액 확인 | MEDIUM | 2분 |
| 6 | 오프라인 상태 → AI 대전 가능 확인 → 온라인 복귀 시 데이터 동기화 | MEDIUM | 3분 |

### 6.2 관리자 웹 E2E 시나리오 (Playwright)

| # | 시나리오 | 중요도 | 예상 시간 |
|:-:|---------|:-----:|:-------:|
| 1 | 관리자 로그인 → 대시보드 → CCU/KPI 위젯 로드 확인 | HIGH | 1분 |
| 2 | 유저 검색 → 상세 조회 → 제재(일시 정지 7일) → 제재 이력 확인 | HIGH | 2분 |
| 3 | 유저 검색 → 코인 지급(사유 입력) → 지급 로그 확인 | HIGH | 1분 |
| 4 | 피처 플래그 변경(TAN_SYSTEM OFF→ON) → 변경 이력 확인 | HIGH | 1분 |
| 5 | 게임 밸런싱 → 블라인드 수치 변경 → 적용 확인 | MEDIUM | 2분 |
| 6 | 신고 목록 → 신고 처리(제재/기각) → 처리 결과 기록 | MEDIUM | 2분 |

### 6.3 모바일 디바이스 E2E

#### 게임 클라이언트 — Firebase Test Lab

| 디바이스 | OS | 주요 검증 항목 |
|---------|-----|-------------|
| Galaxy A24 | Android 13 | 최소 사양 근접 기기, FPS 30 유지, 메모리 <200MB |
| Galaxy S23 | Android 14 | 권장 사양, NPU AI 추론 성능 |
| iPhone 8 | iOS 16 | iOS 최소 사양, Safe Area (Home Button) |
| iPhone 14 | iOS 17 | iOS 권장 사양, Safe Area (Dynamic Island/Notch) |

**Firebase Test Lab 실행**:
- Robo 테스트: 앱 자동 탐색 (크래시 탐지)
- Instrumentation 테스트: 핵심 플로우 자동화 스크립트

#### 관리자 웹 — Playwright 디바이스 프로필

| 디바이스 프로필 | 뷰포트 | 주요 검증 항목 |
|---------------|--------|-------------|
| iPhone 14 (390x844) | Mobile | 사이드바 숨김 → 햄버거 메뉴, 테이블 → 카드 전환 |
| Galaxy S21 (360x800) | Mobile | Android 시스템 바 대응, 터치 인터랙션 |
| iPad Air (820x1180) | Tablet | 사이드바/콘텐츠 레이아웃 전환 |

### 6.4 관리자 반응형 브레이크포인트 테스트

| 브레이크포인트 | 뷰포트 너비 | 검증 항목 |
|-------------|:---------:|---------|
| Mobile | ~767px | 사이드바 숨김, 햄버거 메뉴, 테이블→카드 리스트, 터치 친화 |
| Tablet | 768~1023px | 접이식 사이드바, 차트 축소 레이아웃 |
| Desktop | 1024px~ | 전체 사이드바, 다열 대시보드, 풍부한 데이터 테이블 |

---

## 7. 테스트 데이터 시딩 전략

### 7.1 게임 클라이언트 + Firebase

| 항목 | 전략 |
|------|------|
| 테스트 DB | Firebase Emulator Suite (로컬 Firestore + Auth + Realtime DB) |
| 시딩 방식 | Factory 패턴 — `createTestUser()`, `createTestMatch()`, `createTestTransaction()` |
| 테스트 격리 | 테스트별 고유 Firestore 프로젝트 ID 분리 (`test-project-{uuid}`) |
| 정리 (Cleanup) | `afterEach`에서 Emulator 데이터 자동 클리어 (`clearFirestoreData()`) |

### 7.2 관리자 백엔드 (PostgreSQL)

| 항목 | 전략 |
|------|------|
| 테스트 DB | PostgreSQL Docker 컨테이너 (`postgres:16-alpine`, 테스트 전용) |
| 시딩 방식 | Prisma + Factory 패턴 — `UserFactory.create()`, `ReportFactory.create()` |
| Factory 라이브러리 | @faker-js/faker (닉네임, 이메일 등 무작위 데이터 생성) |
| 테스트 격리 | 트랜잭션 롤백 (`prisma.$transaction` 래핑, 테스트 후 자동 롤백) |
| 정리 (Cleanup) | `afterEach`에서 `prisma.$executeRaw('TRUNCATE ...')` 또는 트랜잭션 롤백 |

### 7.3 테스트 사용자 프로필

| 프로필 | 시스템 | 역할 | 데이터 | 용도 |
|--------|--------|------|--------|------|
| `testPlayer1` | 게임 | 일반 플레이어 | ELO 1500, 코인 5000 | 게임 로직 테스트 |
| `testPlayer2` | 게임 | 일반 플레이어 | ELO 1500, 코인 5000 | 2인 대전 테스트 |
| `testNewbie` | 게임 | 신규 유저 | ELO 1500, 코인 500, 튜토리얼 미완료 | 첫 실행 플로우 |
| `testGuest` | 게임 | 게스트 | 제한된 프로필 | 게스트 제한 테스트 |
| `testWhale` | 게임 | 과금 유저 | 젬 10000, 코스메틱 다수 | 상점/IAP 테스트 |
| `testSuperAdmin` | 관리자 | Super Admin | 전체 권한 | 관리자 전 기능 테스트 |
| `testOperator` | 관리자 | 운영자 | 유저/게임 운영 권한 | RBAC 운영자 테스트 |
| `testCS` | 관리자 | CS | 유저 조회/신고 처리 권한 | RBAC CS 테스트 |
| `testAnalyst` | 관리자 | 분석가 | 읽기 전용 + 분석 | RBAC 분석가 테스트 |

---

## 8. 테스트 환경 설정

### 8.1 게임 클라이언트 (Unity)

| 환경 | 설정 | 용도 |
|------|------|------|
| Unity Test Runner | EditMode: 게임 로직, PlayMode: UI/통합 | 단위/통합 테스트 |
| EditMode 테스트 경로 | `Assets/Tests/EditMode/` | MonoBehaviour 불필요, 빠른 실행 |
| PlayMode 테스트 경로 | `Assets/Tests/PlayMode/` | Unity 런타임 필요, UI 테스트 |
| Assembly Definition | `Tests.EditMode.asmdef`, `Tests.PlayMode.asmdef` | 테스트 코드 격리 |
| Firebase Emulator | `firebase emulators:start` | Cloud Functions/Firestore 로컬 테스트 |

### 8.2 관리자 백엔드

| 환경 | 파일/설정 | 용도 |
|------|---------|------|
| 환경변수 | `.env.test` | 테스트 전용 PostgreSQL, Redis, JWT Secret |
| Jest 설정 | `jest.config.ts` | 모듈 매핑, 타임아웃 30초, 커버리지 리포터 |
| Docker Compose | `docker-compose.test.yml` | PostgreSQL 16 + Redis 7 테스트 컨테이너 |
| Prisma | `schema.prisma` + 테스트 DB URL | 마이그레이션 자동 적용 |

```yaml
# docker-compose.test.yml
services:
  postgres-test:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: baduki_admin_test
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
    ports: ["5433:5432"]
  redis-test:
    image: redis:7-alpine
    ports: ["6380:6379"]
```

### 8.3 관리자 프론트엔드

| 환경 | 파일/설정 | 용도 |
|------|---------|------|
| Jest 설정 | `jest.config.ts` | jsdom 환경, 모듈 매핑 (`@/` → `src/`) |
| MSW | `src/mocks/handlers.ts` | API 모킹 핸들러 정의 |
| Playwright 설정 | `playwright.config.ts` | 브라우저(Chromium), 뷰포트, 타임아웃 |

### 8.4 환경변수 예시

```env
# .env.test (관리자 백엔드)
DATABASE_URL=postgresql://test:test@localhost:5433/baduki_admin_test
REDIS_URL=redis://localhost:6380
JWT_SECRET=test-secret-key-do-not-use-in-production
FIREBASE_PROJECT_ID=baduki-test
FIREBASE_EMULATOR_HOST=localhost:8080
PORT=3001
```

---

## 9. 커버리지 목표

### 9.1 게임 클라이언트

| 영역 | 목표 | 측정 도구 | 비고 |
|------|:----:|---------|------|
| 게임 로직 (핵심) | **100%** | Unity Code Coverage | HandEvaluator, BettingManager, DrawManager, FSM, ShowdownResolver |
| AI 봇 의사결정 | 90%+ | Unity Code Coverage | EasyBot, MediumBot, HardBot 전략 로직 |
| 데이터 레이어 | 80%+ | Unity Code Coverage | FirebaseManager, Repository 클래스 |
| UI 레이어 | 60%+ | Unity Code Coverage | UI 바인딩/이벤트 핸들러 (비주얼 로직 제외) |
| 네트워크 레이어 | 70%+ | Unity Code Coverage | 동기화, 재연결, 부정행위 검증 |

### 9.2 Firebase Cloud Functions

| 영역 | 목표 | 측정 도구 |
|------|:----:|---------|
| 매칭/ELO/보상 로직 | 90%+ | Istanbul (nyc) |
| IAP 영수증 검증 | 100% | Istanbul (nyc) |
| Security Rules | 100% | Firebase Emulator |
| 전체 | 80%+ | Istanbul (nyc) |

### 9.3 관리자 웹

| 영역 | 목표 | 측정 도구 |
|------|:----:|---------|
| 백엔드 API (Service) | 85%+ | Istanbul (nyc) |
| 백엔드 API (Controller) | 80%+ | Istanbul (nyc) |
| 프론트엔드 컴포넌트 | 70%+ | Jest Coverage (c8) |
| 프론트엔드 커스텀 훅 | 80%+ | Jest Coverage (c8) |
| E2E 크리티컬 패스 | 100% (핵심 시나리오) | — |

### 9.4 커버리지 정책

- **PR merge 시** 커버리지 하락 방지 (CI에서 자동 체크)
- **새 코드** 커버리지: 최소 80%
- 커버리지 리포트: CI 결과에 자동 코멘트 (GitHub Actions)
- **게임 로직 100% 미달 시** PR merge 차단

---

## 10. 특수 테스트 영역

### 10.1 부정행위 방지 (Server-Authoritative 검증)

Server-Authoritative 모델의 6항목 검증을 전용 테스트 스위트로 관리한다.

```
tests/security/
├── anti-cheat.test.ts         # 6항목 서버 검증
├── race-condition.test.ts     # 동시 요청 경쟁 조건
├── replay-attack.test.ts      # 리플레이 공격 방지
└── data-integrity.test.ts     # 클라이언트→서버 데이터 변조 탐지
```

**검증 시나리오**:
- 변조된 카드 ID로 드로우 요청 → 서버 거부
- 잔액보다 큰 금액으로 Raise → 서버 거부
- 동일 액션 100ms 간격 연속 전송 → 두 번째부터 거부
- 다른 플레이어의 턴에 액션 전송 → 서버 거부
- 종료된 게임에 액션 전송 → 서버 거부

### 10.2 탄 시스템 이중 잠금 검증

탄 시스템은 **피처 플래그(Firebase Remote Config) + 컴파일 타임 상수** 이중 잠금으로 제어된다.
심의 빌드에서 코드 경로 도달 불가를 반드시 검증한다.

| 테스트 | 조건 | 기대 결과 |
|--------|------|---------|
| 플래그 OFF + 상수 OFF | 심의 빌드 | 탄 UI 미노출, 탄 로직 코드 경로 도달 불가 |
| 플래그 ON + 상수 OFF | 컴파일 타임 차단 | 탄 UI 미노출 (상수가 우선) |
| 플래그 OFF + 상수 ON | Remote Config 차단 | 탄 UI 미노출 |
| 플래그 ON + 상수 ON | 정상 활성화 | 탄 UI 노출, 엿보기/교체 탄 사용 가능 |

**코드 경로 검증 방법**:

```csharp
// 심의 빌드 (FEATURE_TAN_SYSTEM = false)
#if !FEATURE_TAN_SYSTEM
[Test]
public void TanSystem_CodePath_Unreachable_InReviewBuild()
{
    // TanManager, PeekTan, SwapTan 클래스가 컴파일에서 제외됨을 확인
    var tanTypes = AppDomain.CurrentDomain.GetAssemblies()
        .SelectMany(a => a.GetTypes())
        .Where(t => t.Name.Contains("Tan"));
    Assert.IsEmpty(tanTypes);
}
#endif
```

### 10.3 구매 한도 이중 검증

| 검증 위치 | 한도 | 테스트 방법 |
|---------|------|-----------|
| 클라이언트 (로컬) | 일 10만원 / 월 50만원 | 한도 초과 시 구매 버튼 비활성화 |
| 서버 (Cloud Functions) | 일 10만원 / 월 50만원 | 한도 초과 요청 → 서버 거부 (HTTP 429) |

**엣지 케이스**:
- 일 한도 99,000원 → 2,000원 구매 시도 → 거부
- 월 한도 리셋 직후 → 구매 허용 확인
- 클라이언트 시계 조작 시 → 서버 시간 기준 검증

### 10.4 GRAC 심의 빌드 QA 체크리스트

심의 빌드 전 자동화 검증 스크립트로 아래를 확인한다.

- [ ] `FEATURE_TAN_SYSTEM` 컴파일 타임 상수 `false` 확인
- [ ] 탄 관련 UI 요소 완전 미노출 (스크린샷 자동 비교)
- [ ] 탄 관련 코드 경로 도달 불가 (코드 커버리지로 확인)
- [ ] 가상화폐 → 현금 환전 API 부재 확인
- [ ] 코인 구매 한도 작동 (일 10만원, 월 50만원)
- [ ] 확률형 아이템 확률 공시 (배틀패스/보상 박스 해당 시)

### 10.5 네트워크 복원력 테스트

| 시나리오 | 지연/손실 | 기대 동작 |
|---------|---------|---------|
| 양호한 네트워크 | 50ms, 0% 손실 | 정상 플레이, 즉시 동기화 |
| 일반 모바일 | 100ms, 1% 손실 | 정상 플레이, <200ms 체감 지연 |
| 열악한 네트워크 | 500ms, 5% 손실 | 플레이 가능, 타이머 서버 기준, 액션 재전송 |
| 매우 열악한 네트워크 | 1000ms, 10% 손실 | 경고 표시, 자동 재연결 시도, 플레이 지속 |
| 완전 끊김 | 연결 불가 | 20초 Grace Period → 자동 폴드 → 재접속 시 상태 복원 |

---

## 11. CI/CD 통합

### 11.1 전체 파이프라인 흐름

```
PR 생성/업데이트 (GitHub Actions)
  ├─ [게임 클라이언트]
  │   ├─ GameCI: Unity EditMode 테스트 (단위)
  │   ├─ GameCI: Unity PlayMode 테스트 (통합)
  │   └─ 커버리지 리포트 → PR 코멘트
  │
  ├─ [Firebase Functions]
  │   ├─ npm test (Jest 단위 + 통합)
  │   ├─ Firebase Emulator Suite 자동 시작
  │   └─ 커버리지 리포트 → PR 코멘트
  │
  ├─ [관리자 백엔드]
  │   ├─ docker-compose up (PostgreSQL + Redis)
  │   ├─ npx prisma migrate deploy
  │   ├─ npm test (Jest 단위 + Supertest 통합)
  │   └─ 커버리지 리포트 → PR 코멘트
  │
  └─ [관리자 프론트엔드]
      ├─ lint + type-check
      ├─ npm test (Jest 단위 + 통합)
      ├─ build 성공 확인
      └─ 커버리지 리포트 → PR 코멘트

staging 배포 시
  ├─ [게임] Firebase Test Lab: 모바일 디바이스 E2E (Galaxy A24, iPhone 8)
  ├─ [관리자] Playwright E2E (Chromium + 모바일 뷰포트)
  └─ 결과 알림 (Slack/이메일)
```

### 11.2 GitHub Actions 워크플로우

| 워크플로우 | 트리거 | 실행 내용 | 예상 시간 |
|-----------|--------|---------|:-------:|
| `unity-test.yml` | PR (게임 코드 변경) | EditMode + PlayMode 테스트, 커버리지 | 5-10분 |
| `firebase-test.yml` | PR (functions/ 변경) | Jest + Emulator 통합 테스트, 커버리지 | 3-5분 |
| `admin-api-test.yml` | PR (admin-api/ 변경) | Docker 컨테이너 → Jest + Supertest, 커버리지 | 3-5분 |
| `admin-web-test.yml` | PR (admin-web/ 변경) | Jest + RTL, 커버리지 | 2-3분 |
| `e2e-game.yml` | staging 배포 | Firebase Test Lab (4 디바이스) | 15-30분 |
| `e2e-admin.yml` | staging 배포 | Playwright (3 뷰포트) | 5-10분 |

### 11.3 CI 품질 게이트

| 게이트 | 조건 | 실패 시 |
|--------|------|--------|
| 단위 테스트 | 전체 통과 | PR merge 차단 |
| 통합 테스트 | 전체 통과 | PR merge 차단 |
| 게임 로직 커버리지 | 100% (핵심) | PR merge 차단 |
| 전체 커버리지 | 기존 대비 하락 없음 | PR merge 차단 |
| 새 코드 커버리지 | 80% 이상 | PR 경고 (soft block) |
| E2E (staging) | 핵심 시나리오 통과 | 릴리즈 차단 |
| Firebase Test Lab | 크래시 0건 | 릴리즈 차단 |

---

## 검증 체크리스트

- [x] 테스트 계층 및 비율 정의 완료 (게임/Firebase/관리자 3대 시스템)
- [x] 게임 클라이언트 테스트 전략 + 도구(NUnit, Unity Test Framework)
- [x] Firebase 백엔드 테스트 전략 + 도구(Jest, Firebase Emulator Suite)
- [x] 관리자 FE 테스트 전략 + 도구(Jest, RTL, Playwright)
- [x] 관리자 BE 테스트 전략 + 도구(Jest, Supertest, Docker)
- [x] E2E 핵심 시나리오 정의 (게임 6개 + 관리자 6개)
- [x] 모바일 디바이스 E2E 프로필 정의 (Firebase Test Lab + Playwright devices)
- [x] 관리자 반응형 브레이크포인트 테스트 명세 (Mobile/Tablet/Desktop)
- [x] 테스트 데이터 시딩 전략 확정 (Firebase Emulator + PostgreSQL Docker)
- [x] 테스트 환경 설정 문서화 (Unity/Firebase/관리자 BE/FE)
- [x] 커버리지 목표 수립 (게임 로직 100%, 전체 80%+)
- [x] 특수 테스트: 부정행위 방지 6항목, 탄 시스템 이중 잠금, 구매 한도, GRAC 심의, 네트워크 복원력
- [x] CI/CD 파이프라인 테스트 흐름 정의 (6개 워크플로우)
- [x] 관리자 RBAC 권한 매트릭스 테스트
- [x] 접근성 테스트 (터치 타겟, Safe Area, 색맹 대응)

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|---------|--------|
| 1.0 | 2026-02-27 | S4 테스트 전략서 초안 작성 (게임+Firebase+관리자 통합) | Claude Opus 4.6 |
