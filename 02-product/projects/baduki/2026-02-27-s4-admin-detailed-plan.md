# 로우 바둑이 (Low Baduki) — S4 관리자 상세 기획서

**작성일**: 2026-02-27
**프로젝트 유형**: 게임 개발 (SIGIL S4 — 개발 트랙)
**입력 문서**: S3 GDD `02-product/projects/baduki/2026-02-27-s3-gdd.md` 섹션 9 (관리자 도구)
**버전**: 1.0

---

## 목차

1. [대시보드 (Dashboard)](#1-대시보드-dashboard)
2. [유저 관리 (User Management)](#2-유저-관리-user-management)
3. [게임 운영 (Game Operations)](#3-게임-운영-game-operations)
4. [경제 관리 (Economy Management)](#4-경제-관리-economy-management)
5. [콘텐츠 관리 (Content Management)](#5-콘텐츠-관리-content-management)
6. [관리자 API 엔드포인트](#6-관리자-api-엔드포인트)

---

## 관리자 도구 개요

### 기술 스택

| 구분 | 기술 |
|------|------|
| **프론트엔드** | React 18 + TypeScript + Tailwind CSS |
| **실시간** | WebSocket + Socket.IO |
| **백엔드** | Node.js + Express |
| **데이터베이스** | PostgreSQL (운영 데이터) + Redis (캐시/세션) |
| **배포** | Docker + Nginx |
| **인증** | JWT + Refresh Token (관리자 전용 인증) |

### 접근 권한 (RBAC)

| 역할 | 코드 | 권한 범위 |
|------|------|----------|
| **Super Admin** | `ROLE_SUPER` | 전체 기능 (피처 플래그, 시스템 설정 포함) |
| **운영자 (Admin)** | `ROLE_ADMIN` | 유저 관리, 신고 처리, 모니터링, 경제 관리 |
| **CS 담당자** | `ROLE_CS` | 유저 조회, 신고 처리 (제재 권한 없음) |
| **분석가 (Analyst)** | `ROLE_ANALYST` | 읽기 전용 (모든 대시보드 + 로그) |

### 공통 UI 레이아웃

```
┌─────────────────────────────────────────────────────┐
│ [로고] 로우 바둑이 관리자   [알림🔔] [계정▼] [로그아웃] │
├────────┬────────────────────────────────────────────┤
│        │                                            │
│ 사이드  │       메인 콘텐츠 영역                      │
│ 네비    │                                            │
│ 게이션  │                                            │
│        │                                            │
│ ├ 대시보드│                                           │
│ ├ 유저관리│                                           │
│ ├ 게임운영│                                           │
│ ├ 경제관리│                                           │
│ ├ 콘텐츠 │                                           │
│ ├ 로그   │                                           │
│ └ 설정   │                                           │
│        │                                            │
├────────┴────────────────────────────────────────────┤
│ [상태바] CCU: 1,234  게임 수: 456  서버: OK  v1.0.0   │
└─────────────────────────────────────────────────────┘
```

---

## 1. 대시보드 (Dashboard)

### ADM-001. 메인 대시보드

| 항목 | 내용 |
|------|------|
| **진입 조건** | 관리자 로그인 완료 |
| **접근 권한** | 전 역할 접근 가능 |
| **갱신 방식** | WebSocket 실시간 push (5초 간격) |

#### 1.1 실시간 모니터링 카드 (상단)

| 카드 | 데이터 소스 | 갱신 주기 | 표시 형식 |
|------|-----------|---------|---------|
| **CCU (동시 접속자)** | Firebase Realtime DB `presence/` | 5초 | 숫자 + 미니 라인 차트 (최근 1시간) |
| **진행 중 게임** | Firebase Realtime DB `games/` (status=playing) | 5초 | 숫자 + AI/PvP/친구 비율 파이차트 |
| **서버 응답시간** | Health Check endpoint `/api/health` | 10초 | ms 수치 + 상태 컬러 (Green/Yellow/Red) |
| **서버 오류율** | Cloud Functions 에러 로그 집계 | 10초 | % + 경고 임계값 (>1% = Yellow, >5% = Red) |
| **금일 신규 가입** | Firestore `users/` (createdAt = today) | 실시간 | 숫자 + 전일 대비 증감 (↑↓) |
| **금일 매출** | Firestore `transactions/` (type=purchase, today) | 실시간 | ₩ 금액 + 전일 대비 증감 |

**카드 상태 임계값**:

| 지표 | Green | Yellow | Red |
|------|:-----:|:------:|:---:|
| 서버 응답시간 | < 200ms | 200-500ms | > 500ms |
| 오류율 | < 1% | 1-5% | > 5% |
| CCU | 정상 범위 | > 80% 용량 | > 95% 용량 |

#### 1.2 KPI 차트 영역 (중앙)

| 차트 | 데이터 | 기간 선택 | 차트 타입 |
|------|------|---------|---------|
| **DAU / MAU** | Firestore `analytics/dailyActive` | 7일/30일/90일 | 이중축 라인 차트 |
| **리텐션 (D1/D7/D30)** | Firestore `analytics/retention` | 주간/월간 | 코호트 히트맵 |
| **ARPU / ARPPU** | 매출 / 활성유저 집계 | 7일/30일/90일 | 바 차트 + 트렌드 라인 |
| **매치 통계** | Firestore `games/` 완료 건 집계 | 7일/30일 | 스택 바 차트 (AI/PvP/친구별) |
| **ELO 분포** | Firestore `users/` elo 필드 분포 | 현재 | 히스토그램 (100점 구간) |

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 기간 필터 변경 (7일/30일/90일) | 해당 기간 데이터 재조회 + 차트 재렌더 | 없음 |
| 차트 호버 | 툴팁 — 해당 일자 상세 수치 표시 | 없음 |
| 차트 클릭 | 해당 일자 상세 페이지로 drill-down | 없음 |
| CSV 내보내기 버튼 | 현재 차트 데이터를 CSV 다운로드 | `admin_logs` 기록 |
| 새로고침 버튼 | 전체 대시보드 데이터 재조회 | 없음 |

#### 1.3 에러 로그 스트림 (하단)

| 항목 | 내용 |
|------|------|
| **데이터 소스** | Cloud Functions 로그 + 게임 서버 에러 로그 |
| **표시 방식** | 실시간 스크롤 테이블 (최신 50건) |
| **갱신** | WebSocket push (발생 즉시) |

**테이블 컬럼**:

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `timestamp` | datetime | 발생 시각 (KST) |
| `severity` | enum | `INFO` / `WARN` / `ERROR` / `FATAL` |
| `source` | string | 발생 서비스 (auth, game, economy, matchmaking) |
| `message` | string | 에러 메시지 (최대 200자, 클릭 시 전체 보기) |
| `userId` | string | 관련 유저 ID (있는 경우) |
| `traceId` | string | 요청 추적 ID (서버 로그 연동) |

**필터 옵션**: severity별, source별, 시간 범위, userId 검색

---

### ADM-002. 알림 센터

| 항목 | 내용 |
|------|------|
| **진입 조건** | 상단 알림 아이콘 클릭 또는 자동 푸시 |
| **접근 권한** | 전 역할 접근 가능 |

**알림 타입 & 트리거**:

| 알림 타입 | 트리거 조건 | 심각도 | 대상 역할 |
|---------|---------|:-----:|---------|
| 서버 오류 급증 | 오류율 > 5% (5분 지속) | `CRITICAL` | Super Admin, Admin |
| CCU 용량 경고 | CCU > 80% 서버 용량 | `WARNING` | Super Admin, Admin |
| 신규 신고 접수 | 유저 신고 1건 접수 | `INFO` | Admin, CS |
| 피처 플래그 변경 | 플래그 ON/OFF 변경 | `WARNING` | Super Admin |
| 구매 한도 초과 시도 | 일/월 한도 초과 구매 시도 | `INFO` | Admin |
| 점검 모드 진입/해제 | `FEATURE_MAINTENANCE` 변경 | `CRITICAL` | 전체 |
| 배틀패스 시즌 종료 임박 | 시즌 종료 D-3 | `INFO` | Admin |

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 알림 클릭 | 해당 상세 페이지로 이동 | `notification.readAt` 갱신 |
| 전체 읽음 처리 | 모든 미읽음 알림 읽음 처리 | 배치 `readAt` 갱신 |
| 알림 설정 | 알림 타입별 ON/OFF 설정 | `admin_preferences` 갱신 |

---

## 2. 유저 관리 (User Management)

### ADM-010. 유저 검색/목록

| 항목 | 내용 |
|------|------|
| **진입 조건** | 사이드바 "유저 관리" 클릭 |
| **접근 권한** | Super Admin, Admin, CS (읽기), Analyst (읽기) |

**검색 조건**:

| 필드 | 검색 타입 | 예시 |
|------|---------|------|
| UID | 완전 일치 | `user_abc123` |
| 닉네임 | 부분 일치 (LIKE) | `바둑이마스터` |
| 이메일 | 완전 일치 | `user@email.com` |
| ELO 범위 | 범위 검색 | 1500 ~ 2000 |
| 가입일 범위 | 날짜 범위 | 2026-01-01 ~ 2026-02-27 |
| 계정 상태 | 드롭다운 | 정상 / 경고 / 정지 / 영구밴 |
| 계정 유형 | 드롭다운 | Google / Apple / 게스트 |

**검색 결과 테이블**:

| 컬럼 | 타입 | 정렬 가능 |
|------|------|:--------:|
| UID | string | ✅ |
| 닉네임 | string | ✅ |
| ELO | number | ✅ |
| 레벨 | number | ✅ |
| 코인 보유량 | number | ✅ |
| 게임 수 | number | ✅ |
| 승률 | % | ✅ |
| 가입일 | date | ✅ |
| 최종 접속 | datetime | ✅ |
| 상태 | badge | ✅ |
| 액션 | button | - |

**페이지네이션**: 20건/50건/100건 선택, 커서 기반 (offset 금지 — Firestore 대용량 쿼리 최적화)

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 검색 실행 | Firestore 쿼리 + 결과 테이블 렌더 | 없음 |
| 컬럼 헤더 클릭 | 해당 컬럼 기준 오름/내림차순 정렬 | 없음 |
| 유저 행 클릭 | 유저 상세 페이지 (ADM-011)로 이동 | 없음 |
| CSV 내보내기 | 현재 검색 결과 CSV 다운로드 (최대 10,000건) | `admin_logs` 기록 |

---

### ADM-011. 유저 상세 정보

| 항목 | 내용 |
|------|------|
| **진입 조건** | 유저 목록에서 유저 클릭 또는 UID 직접 입력 |
| **접근 권한** | Super Admin (전체), Admin (전체), CS (조회+메모), Analyst (조회) |

#### 2.1 프로필 정보 탭

| 항목 | 표시 내용 | 수정 가능 역할 |
|------|---------|:----------:|
| UID | `user_abc123` | - (읽기 전용) |
| 닉네임 | 현재 닉네임 + 변경 이력 | Super Admin, Admin |
| 이메일 | 가려진 이메일 (`u***@email.com`) | - |
| 계정 유형 | Google / Apple / 게스트 | - |
| 가입일 | 2026-02-15 14:30 KST | - |
| 최종 접속 | 2026-02-27 09:15 KST | - |
| ELO | 1,650 (Gold II) | Super Admin |
| 레벨 | Lv.25 (EXP: 12,450 / 15,000) | Super Admin |
| 코인 | 15,200 | Super Admin, Admin |
| 젬 | 120 | Super Admin, Admin |
| 누적 구매 | ₩45,000 (금월 ₩12,000) | - |
| 구매 한도 잔여 | 일 ₩88,000 / 월 ₩455,000 | - |

#### 2.2 게임 통계 탭

| 항목 | 데이터 |
|------|------|
| 총 게임 수 | 350판 |
| 승/무/패 | 180 / 20 / 150 |
| 승률 | 51.4% |
| 최근 20판 승률 | 60.0% |
| 평균 게임 시간 | 4분 32초 |
| 최장 연승 | 8연승 |
| 선호 모드 | AI 대전 45% / 랭크 35% / 친구 20% |
| 메이드 달성률 | 38.2% |
| 골프 달성 횟수 | 12회 |

**매치 히스토리 테이블** (최근 100판):

| 컬럼 | 타입 | 설명 |
|------|------|------|
| 날짜/시간 | datetime | 게임 시작 시각 |
| 모드 | enum | AI / 랭크 / 일반 / 친구 |
| 상대 | string | 닉네임 (AI 시 난이도 표시) |
| 결과 | enum | 승 / 패 / 무 |
| 최종 핸드 | string | 메이드 A-2-3-4, 베이스 등 |
| ELO 변동 | number | +15, -12 등 |
| 코인 변동 | number | +500, -200 등 |
| 게임 시간 | duration | 3분 45초 |
| 상세 | link | 게임 리플레이 로그 |

#### 2.3 구매 내역 탭

| 컬럼 | 타입 | 설명 |
|------|------|------|
| 거래 ID | string | `txn_20260227_001` |
| 일시 | datetime | 구매 시각 |
| 상품 | string | 코인 팩 / 배틀패스 / 코스메틱 |
| 결제 금액 | number | ₩5,000 |
| 결제 수단 | string | Google Play / App Store |
| 상태 | enum | 완료 / 환불 / 보류 |

#### 2.4 관리자 메모 탭

| 항목 | 내용 |
|------|------|
| **접근 권한** | Super Admin, Admin, CS (작성 가능), Analyst (읽기) |
| **기능** | 유저별 내부 메모 추가 (CS 대응 이력, 특이사항 등) |

**메모 데이터 구조**:

```json
{
  "noteId": "note_001",
  "userId": "user_abc123",
  "authorId": "admin_super01",
  "authorRole": "ROLE_SUPER",
  "content": "반복 욕설 사용 — 1차 경고 발송 완료",
  "createdAt": "2026-02-27T09:15:00+09:00",
  "category": "warning"
}
```

**카테고리**: `info` / `warning` / `cs_response` / `compensation` / `ban_reason`

---

### ADM-012. 계정 제재

| 항목 | 내용 |
|------|------|
| **진입 조건** | 유저 상세 (ADM-011) → "제재" 버튼 |
| **접근 권한** | Super Admin (전체), Admin (경고/채팅금지/일시정지), CS (없음) |

**제재 유형 & 단계**:

| 단계 | 제재 유형 | 기간 | 효과 | 권한 |
|:----:|---------|------|------|:----:|
| 1 | 경고 (Warning) | - | 인게임 경고 메시지 표시 | Admin+ |
| 2 | 채팅 금지 (Mute) | 1일 / 3일 / 7일 / 30일 | 이모지/채팅 비활성화 | Admin+ |
| 3 | 일시 정지 (Suspend) | 1일 / 3일 / 7일 / 30일 | 로그인 차단 | Admin+ |
| 4 | 영구 밴 (Permanent Ban) | 무기한 | 계정 영구 차단 | Super Admin |

**제재 프로세스 (유저 액션 & 시스템 반응)**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 제재 유형 선택 | 해당 유형에 따른 기간 옵션 표시 | 없음 |
| 사유 입력 (필수) | 텍스트 입력 (최소 10자) | 없음 |
| "제재 적용" 버튼 | 확인 다이얼로그 (이중 확인) | 아래 참조 |
| 확인 | 1. `users/{userId}.status` → 제재 상태 갱신 | Firestore |
| | 2. `sanctions/{sanctionId}` 생성 | Firestore |
| | 3. `admin_logs` 기록 (who/what/when) | PostgreSQL |
| | 4. 해당 유저 실시간 세션 강제 종료 (진행 중 게임 시 → 판돈 환불 후 종료) | Realtime DB |
| | 5. 푸시 알림 발송 (제재 사유 + 기간) | FCM |

**제재 해제**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| "제재 해제" 버튼 | 확인 다이얼로그 + 해제 사유 입력 | 없음 |
| 확인 | 1. `users/{userId}.status` → `active` | Firestore |
| | 2. `sanctions/{sanctionId}.releasedAt` 갱신 | Firestore |
| | 3. `admin_logs` 기록 | PostgreSQL |

**에러 처리**:

| 에러 상황 | 대응 |
|---------|------|
| 이미 제재 중인 유저에 중복 제재 | 기존 제재 정보 표시 + "기존 제재를 해제 후 재적용" 안내 |
| Super Admin이 아닌 관리자가 영구밴 시도 | 권한 부족 에러 + "Super Admin에게 요청" 안내 |
| 진행 중인 게임이 있는 유저 제재 | 경고 — "진행 중 게임이 있습니다. 게임 종료 후 적용됩니다" (옵션: 즉시 강제 종료) |

---

### ADM-013. 신고 처리

| 항목 | 내용 |
|------|------|
| **진입 조건** | 사이드바 "유저 관리 > 신고 관리" |
| **접근 권한** | Super Admin, Admin, CS |

**신고 목록 테이블**:

| 컬럼 | 타입 | 설명 |
|------|------|------|
| 신고 ID | string | `report_001` |
| 신고 일시 | datetime | 접수 시각 |
| 신고자 | string (link) | 닉네임 (클릭 시 ADM-011) |
| 피신고자 | string (link) | 닉네임 (클릭 시 ADM-011) |
| 사유 | enum | 욕설/비매너/핵사용의심/부적절닉네임/기타 |
| 상세 내용 | text | 신고자 작성 내용 |
| 상태 | badge | 접수 / 처리중 / 완료 / 반려 |
| 처리자 | string | 처리 관리자 닉네임 |
| 처리일 | datetime | 처리 완료 시각 |

**필터**: 상태별 / 사유별 / 날짜 범위 / 처리자별

**신고 처리 플로우**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 신고 건 클릭 | 상세 모달 — 신고 내용 + 해당 게임 로그 + 피신고자 이력 | 없음 |
| "처리 시작" 버튼 | 상태 → `처리중`, 처리자 배정 | `reports/{id}.status`, `assignedTo` |
| 게임 로그 확인 | 해당 게임의 채팅/이모지/행동 로그 타임라인 표시 | 없음 |
| 피신고자 과거 신고 이력 확인 | 과거 신고 목록 + 누적 제재 이력 표시 | 없음 |
| 처리 결과 선택 | `제재 적용` / `경고` / `반려` 옵션 | 없음 |
| → 제재 적용 선택 | ADM-012 제재 프로세스로 이동 (사유 자동 기입) | 연계 |
| → 경고 선택 | 피신고자에게 경고 메시지 발송 | `users/{id}` 경고 횟수 증가 |
| → 반려 선택 | 반려 사유 입력 필수 | `reports/{id}.status` → `반려` |
| 처리 완료 | 1. 상태 → `완료` | `reports/{id}` 갱신 |
| | 2. 신고자에게 처리 결과 알림 | FCM |
| | 3. `admin_logs` 기록 | PostgreSQL |

**자동 에스컬레이션 규칙**:

| 조건 | 액션 |
|------|------|
| 동일 유저 신고 3건 누적 (7일 이내) | Admin에게 자동 알림 + "반복 신고" 태그 |
| 동일 유저 신고 5건 누적 (30일 이내) | Super Admin에게 에스컬레이션 |
| 핵사용 의심 신고 | 즉시 Super Admin 알림 + 해당 게임 로그 자동 첨부 |

---

### ADM-014. 코인/아이템 지급

| 항목 | 내용 |
|------|------|
| **진입 조건** | 유저 상세 (ADM-011) → "보상 지급" 버튼 |
| **접근 권한** | Super Admin (무제한), Admin (일 100,000 코인 한도) |

**지급 가능 항목**:

| 항목 | 타입 | 제한 |
|------|------|------|
| 코인 | number | Admin: 건당 최대 10,000 / 일 100,000 |
| 젬 | number | Admin: 건당 최대 100 / 일 1,000 |
| 코스메틱 아이템 | select | 상점 등록 아이템 중 선택 |
| 배틀패스 레벨 | number | 최대 5레벨 |

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 지급 항목 선택 | 해당 항목 입력 폼 표시 | 없음 |
| 수량/아이템 입력 | 실시간 유효성 검증 (한도 확인) | 없음 |
| 사유 입력 (필수) | 텍스트 입력 (CS 보상 / 이벤트 보상 / 버그 보상 / 테스트 / 기타) | 없음 |
| "지급" 버튼 | 확인 다이얼로그 (지급 대상 + 수량 + 사유 재확인) | 없음 |
| 확인 | 1. 유저 재화 증가 (`users/{userId}.coins += amount`) | Firestore |
| | 2. 지급 트랜잭션 기록 | Firestore `transactions/` |
| | 3. `admin_logs` 기록 (감사 추적) | PostgreSQL |
| | 4. 유저에게 인게임 알림 ("운영자로부터 코인 xxx 지급") | FCM |

**에러 처리**:

| 에러 상황 | 대응 |
|---------|------|
| Admin 일일 한도 초과 | "일일 지급 한도를 초과했습니다 (잔여: X)" |
| 존재하지 않는 유저 | "해당 UID의 유저를 찾을 수 없습니다" |
| 밴 상태 유저에게 지급 | 경고 — "제재 중인 유저입니다. 계속하시겠습니까?" |

---

## 3. 게임 운영 (Game Operations)

### ADM-020. 게임 밸런싱

| 항목 | 내용 |
|------|------|
| **진입 조건** | 사이드바 "게임 운영 > 밸런싱" |
| **접근 권한** | Super Admin (전체 수정), Admin (조회) |

#### 3.1 블라인드 구조

| 파라미터 | 현재값 | 범위 | 단위 | 적용 방식 |
|---------|:-----:|------|------|---------|
| 연습 테이블 SB | 10 | 5-50 | 코인 | 즉시 적용 (신규 게임부터) |
| 연습 테이블 BB | 20 | 10-100 | 코인 | 즉시 적용 |
| 일반 테이블 SB | 50 | 25-200 | 코인 | 즉시 적용 |
| 일반 테이블 BB | 100 | 50-400 | 코인 | 즉시 적용 |
| 하이롤러 SB | 500 | 100-2000 | 코인 | 즉시 적용 |
| 하이롤러 BB | 1000 | 200-4000 | 코인 | 즉시 적용 |
| 최소 입장 코인 (일반) | 2000 | 1000-10000 | 코인 | 즉시 적용 |
| 최소 입장 코인 (하이롤러) | 20000 | 10000-100000 | 코인 | 즉시 적용 |

**변경 프로세스**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 값 변경 (슬라이더/인풋) | 변경 전후 비교 하이라이트 | 없음 (미저장) |
| "미리보기" 버튼 | 변경 후 예상 경제 시뮬레이션 결과 표시 | 없음 |
| "적용" 버튼 | 확인 다이얼로그 + 변경 사유 입력 | 없음 |
| 확인 | 1. Firebase Remote Config 업데이트 | Remote Config |
| | 2. 진행 중 게임에는 미적용 (신규 게임부터 적용) | - |
| | 3. `admin_logs` + `config_history` 기록 | PostgreSQL |
| "롤백" 버튼 | 이전 설정값 목록 표시 → 선택 시 해당 값으로 복원 | Remote Config |

#### 3.2 AI 난이도 파라미터

| 파라미터 | Easy | Medium | Hard | 범위 |
|---------|:----:|:------:|:----:|------|
| 블러핑 빈도 | 0.05 | 0.15 | 동적 (CFR) | 0.0 ~ 1.0 |
| 공격성 (Raise 비율) | 0.1 | 0.25 | 동적 (CFR) | 0.0 ~ 1.0 |
| 드로우 최적성 | 0.6 | 0.85 | 동적 (CFR) | 0.0 ~ 1.0 |
| 폴드 빈도 | 0.3 | 0.15 | 동적 (CFR) | 0.0 ~ 1.0 |
| 실수 주입률 | 0.2 | 0.05 | 0.0 | 0.0 ~ 0.5 |

> **Hard AI**: CFR 모델 기반으로 동적 결정. 관리자 툴에서는 `실수 주입률`만 조정 가능 (0.0 = 최적 플레이).

#### 3.3 리워드 테이블

| 항목 | 현재값 | 범위 | 설명 |
|------|:-----:|------|------|
| 승리 보너스 (AI) | 100 | 50-500 | AI 대전 승리 시 추가 코인 |
| 승리 보너스 (PvP) | 0 | 0-200 | PvP는 팟 수익만 (보너스 조정 가능) |
| 일일 첫 승 보너스 | 500 | 100-2000 | 하루 첫 승리 추가 보너스 |
| 출석 보상 (기본) | 200 | 100-1000 | 일일 출석 보상 |
| 출석 보상 (7일 연속) | 2000 | 500-5000 | 7일 연속 출석 보너스 |
| 레벨업 보상 | 레벨 × 100 | 계수 조정 | 레벨업 시 코인 보상 |
| 광고 시청 보상 | 300 | 100-1000 | 리워드 광고 1회 시청 |
| 광고 일일 상한 | 5회 | 3-10 | 하루 광고 시청 최대 횟수 |

#### 3.4 ELO 시스템

| 파라미터 | 현재값 | 범위 | 설명 |
|---------|:-----:|------|------|
| 초기 ELO | 1500 | 1000-2000 | 신규 유저 시작 ELO |
| K값 (배치 10판) | 64 | 32-128 | 배치 기간 K값 |
| K값 (일반) | 32 | 16-64 | 일반 K값 |
| K값 (마스터+) | 16 | 8-32 | 상위 티어 K값 |
| 시즌 리셋 비율 | 0.75 | 0.5-0.9 | `newELO = 1500 + (current - 1500) × ratio` |
| 매칭 ELO 범위 (초기) | ±100 | ±50~±200 | 매칭 시작 ELO 범위 |
| 매칭 ELO 확장 속도 | 10초당 ±50 | ±20~±100 | 매칭 대기 시 범위 확장 속도 |

---

### ADM-021. 피처 플래그 관리

| 항목 | 내용 |
|------|------|
| **진입 조건** | 사이드바 "게임 운영 > 피처 플래그" |
| **접근 권한** | Super Admin **전용** (최고 권한 기능) |

**플래그 목록**:

| 플래그 | 현재 상태 | 기본값 | 설명 | 영향도 |
|--------|:-------:|:-----:|------|:-----:|
| `FEATURE_TAN_SYSTEM` | 🔴 OFF | OFF | 탄 시스템 전체 ON/OFF (심의 핵심) | `CRITICAL` |
| `FEATURE_TOURNAMENT` | 🔴 OFF | OFF | 토너먼트 모드 활성화 | `HIGH` |
| `FEATURE_HARD_AI` | 🔴 OFF | OFF | Hard AI (CFR) 잠금 해제 | `MEDIUM` |
| `FEATURE_SEASON_SPECIAL` | 🔴 OFF | OFF | 시즌별 특수 규칙 모드 | `MEDIUM` |
| `FEATURE_MAINTENANCE` | 🔴 OFF | OFF | 점검 모드 (로그인 차단) | `CRITICAL` |
| `FEATURE_NEW_USER_GIFT` | 🟢 ON | ON | 신규 유저 추가 보상 | `LOW` |

**탄 시스템 플래그 특별 프로토콜** (`FEATURE_TAN_SYSTEM`):

이 플래그는 GRAC 심의 대응의 핵심이므로 이중 잠금(Dual Lock) 체계를 적용한다.

```
[이중 잠금 구조]

Lock 1: Firebase Remote Config    ← 관리자 툴에서 제어
Lock 2: 클라이언트 컴파일 상수     ← Unity 빌드 시 하드코딩

→ 두 잠금 모두 true일 때만 탄 시스템 활성화
→ 심의 빌드: Lock 2 = false (컴파일 타임) → 관리자가 실수로 ON 해도 비활성
```

**플래그 변경 프로세스**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 플래그 토글 클릭 | 변경 영향 범위 표시 (영향 기능 목록) | 없음 |
| → `CRITICAL` 플래그 | **이중 확인**: 사유 입력 + 비밀번호 재입력 필수 | 없음 |
| → `FEATURE_MAINTENANCE` ON | 추가 입력: 점검 메시지 + 예상 종료 시간 | 없음 |
| "적용" 확인 | 1. Firebase Remote Config 즉시 반영 | Remote Config |
| | 2. 전체 접속 클라이언트에 WebSocket push | 클라이언트 갱신 |
| | 3. `admin_logs` 기록 (감사 추적 — 누가/언제/무엇을) | PostgreSQL |
| | 4. 전체 관리자에게 알림 | Notification |

**플래그 변경 이력**:

| 컬럼 | 타입 | 설명 |
|------|------|------|
| 변경 일시 | datetime | 변경 시각 |
| 플래그 | string | 플래그 이름 |
| 이전값 | boolean | OFF / ON |
| 변경값 | boolean | ON / OFF |
| 변경자 | string | 관리자 이름 |
| 사유 | text | 변경 사유 |

---

### ADM-022. 매칭 설정

| 항목 | 내용 |
|------|------|
| **진입 조건** | 사이드바 "게임 운영 > 매칭 설정" |
| **접근 권한** | Super Admin (수정), Admin (조회) |

**매칭 파라미터**:

| 파라미터 | 현재값 | 범위 | 설명 |
|---------|:-----:|------|------|
| 매칭 타임아웃 | 30초 | 15-60초 | 타임아웃 후 AI 봇 충원 |
| AI 봇 충원 활성화 | ON | ON/OFF | 타임아웃 시 봇 투입 여부 |
| 봇 충원 난이도 | Medium | Easy/Medium | 봇 투입 시 난이도 |
| ELO 초기 범위 | ±100 | ±50~±200 | 매칭 시작 ELO 범위 |
| ELO 확장 간격 | 10초 | 5-20초 | 범위 확장 주기 |
| ELO 확장 폭 | ±50 | ±20~±100 | 1회 확장당 추가 범위 |
| ELO 최대 범위 | ±500 | ±200~±1000 | 최대 허용 ELO 차이 |
| 동일 상대 재매칭 방지 | 3판 | 1-10 | 최근 N판 내 동일 상대 방지 |

**실시간 매칭 현황** (읽기 전용 모니터링):

| 항목 | 데이터 |
|------|------|
| 현재 대기열 | 대기 중인 유저 수 + ELO 분포 히스토그램 |
| 평균 대기 시간 | 실시간 이동 평균 (최근 100건) |
| 봇 충원율 | 최근 1시간 매치 중 봇 투입 비율 |
| 매칭 성공률 | 타임아웃 전 인간 매칭 성공 비율 |

---

## 4. 경제 관리 (Economy Management)

### ADM-030. 상점 아이템 관리

| 항목 | 내용 |
|------|------|
| **진입 조건** | 사이드바 "경제 관리 > 상점" |
| **접근 권한** | Super Admin (전체 CRUD), Admin (조회 + 가격 변경) |

#### 4.1 코인/젬 팩 관리

**상품 목록 테이블**:

| 컬럼 | 타입 | 설명 |
|------|------|------|
| 상품 ID | string | `pack_coin_5000` |
| 상품명 | string | "코인 5,000 팩" |
| 카테고리 | enum | 코인팩 / 젬팩 / 스타터팩 |
| 실제 가격 | number | ₩5,000 |
| 지급 재화 | string | 코인 5,000 + 보너스 500 |
| 보너스율 | % | 10% |
| 상태 | enum | 활성 / 비활성 / 예약 |
| 구매 제한 | string | 일 3회 / 없음 |
| 생성일 | datetime | |
| 최종 수정 | datetime | |

**상품 CRUD 프로세스**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| "새 상품 추가" 버튼 | 상품 등록 폼 모달 표시 | 없음 |
| 상품 정보 입력 + 저장 | 유효성 검증 → 상품 등록 | Firestore `shop_items/` 생성 |
| 상품 수정 | 수정 폼 + 변경 전후 diff 표시 | Firestore `shop_items/` 갱신 |
| 상품 비활성화 | 상점에서 미표시 (데이터 유지) | `status` → `inactive` |
| 상품 삭제 | 확인 다이얼로그 (구매 이력 있으면 비활성화 권고) | soft delete |

**구매 한도 모니터링**:

| 항목 | 설명 |
|------|------|
| **일일 한도** | ₩100,000 (규제 준수) |
| **월간 한도** | ₩500,000 (규제 준수) |
| 한도 변경 | Super Admin 전용 — 규제 검토 필수 경고 표시 |
| 한도 초과 시도 로그 | 유저별 초과 시도 횟수 + 시간 표시 |

#### 4.2 코스메틱 아이템 관리

**아이템 카테고리**:

| 카테고리 | 예시 | 획득 경로 |
|---------|------|---------|
| 카드 뒷면 스킨 | 한복 패턴, 별빛 패턴 | 상점 / 배틀패스 |
| 테이블 테마 | 전통 목재, 네온, 우주 | 상점 / 배틀패스 |
| 이모지 팩 | 기본 8종, 프리미엄 16종 | 상점 |
| 칭호 | "바둑이 마스터", "골프 달인" | 업적 / 배틀패스 |
| 프로필 프레임 | 골드, 다이아몬드, 시즌 한정 | 시즌 랭킹 / 배틀패스 |

**아이템 등록 폼**:

| 필드 | 타입 | 필수 | 설명 |
|------|------|:----:|------|
| 아이템 ID | auto | - | 자동 생성 |
| 아이템명 | text | ✅ | |
| 카테고리 | select | ✅ | 위 카테고리 중 선택 |
| 가격 (코인) | number | - | 코인 가격 |
| 가격 (젬) | number | - | 젬 가격 (둘 중 하나 필수) |
| 미리보기 이미지 | file | ✅ | 256×256 PNG |
| 에셋 번들 ID | text | ✅ | Unity 에셋 번들 참조 |
| 희귀도 | select | ✅ | Common / Rare / Epic / Legendary |
| 획득 경로 | multi-select | ✅ | 상점 / 배틀패스 / 업적 / 이벤트 |
| 시즌 한정 여부 | boolean | ✅ | 시즌 종료 시 구매 불가 처리 |
| 출시일 | datetime | - | 예약 출시 |

---

### ADM-031. 배틀패스 시즌 관리

| 항목 | 내용 |
|------|------|
| **진입 조건** | 사이드바 "경제 관리 > 배틀패스" |
| **접근 권한** | Super Admin (생성/수정), Admin (조회) |

#### 시즌 목록

| 컬럼 | 타입 | 설명 |
|------|------|------|
| 시즌 번호 | number | Season 1, 2, 3... |
| 시즌명 | string | "봄바람 시즌" |
| 시작일 | datetime | 시즌 시작 |
| 종료일 | datetime | 시즌 종료 |
| 상태 | enum | 예약 / 진행중 / 종료 |
| 프리미엄 가격 | number | ₩9,900 |
| 총 레벨 | number | 50 |
| 참여자 수 | number | 현재 참여 유저 수 |
| 프리미엄 구매 수 | number | 프리미엄 패스 구매 유저 수 |
| 전환율 | % | 프리미엄 구매 / 총 참여 |

#### 시즌 상세 — 보상 트랙 편집

**무료/프리미엄 트랙 병행 편집기**:

```
레벨 | BP 필요량 | 무료 보상              | 프리미엄 보상
─────┼─────────┼──────────────────────┼──────────────────────
  1  |   100   | 코인 200              | 코인 500
  2  |   200   | (없음)               | 카드 뒷면 스킨: 벚꽃
  3  |   300   | 코인 300              | 젬 50
  4  |   400   | (없음)               | 이모지: 봄꽃 세트
  5  |   500   | 칭호: "봄 탐험가"      | 테이블 테마: 벚꽃 정원
 ...
 50  |  5000   | 코인 5,000            | 프로필 프레임: 시즌 1 골드
```

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| "새 시즌 생성" | 시즌 생성 폼 (이름, 기간, 가격, 레벨 수) | 없음 |
| 보상 트랙 편집 | 레벨별 보상 아이템 드래그&드롭 배치 | 없음 (미저장) |
| 아이템 검색/추가 | 기존 코스메틱 아이템 풀에서 검색 + 배치 | 없음 |
| "시뮬레이션" 버튼 | 예상 BP 획득 곡선 + 평균 도달 레벨 시뮬 | 없음 |
| "저장" 버튼 | 검증 (모든 레벨 보상 설정 여부) → 저장 | Firestore `battle_pass/` |
| "시즌 시작" 버튼 | 확인 다이얼로그 → 시즌 활성화 | 상태 → `진행중` |
| "시즌 종료" 버튼 | 조기 종료 사유 입력 → 종료 처리 | 상태 → `종료` |

**시즌 종료 자동 처리**:

1. 미수령 보상 → 유저 메일함으로 자동 발송 (30일 보관)
2. 시즌 한정 아이템 → 상점에서 비활성화
3. 시즌 통계 스냅샷 생성 (참여율, 전환율, 레벨 분포)
4. 다음 시즌 자동 활성화 (예약된 경우)

---

### ADM-032. 프로모션/이벤트 관리

| 항목 | 내용 |
|------|------|
| **진입 조건** | 사이드바 "경제 관리 > 프로모션" |
| **접근 권한** | Super Admin (전체), Admin (생성/수정) |

**이벤트 유형**:

| 유형 | 설명 | 예시 |
|------|------|------|
| 할인 이벤트 | 상점 아이템 기간 한정 할인 | "신년 50% 할인" |
| 보너스 이벤트 | 코인팩 추가 보너스 | "구매 시 200% 보너스" |
| 출석 이벤트 | 특별 출석 보상 (기본 출석과 별도) | "14일 연속 출석 — 레전더리 스킨" |
| 게임 챌린지 | 특정 조건 달성 보상 | "골프 3회 달성 → 코인 10,000" |
| 컴백 이벤트 | 비활성 유저 복귀 보상 | "7일 미접속 복귀 → 코인 5,000" |

**이벤트 등록 폼**:

| 필드 | 타입 | 필수 | 설명 |
|------|------|:----:|------|
| 이벤트명 | text | ✅ | |
| 유형 | select | ✅ | 위 유형 중 선택 |
| 시작 일시 | datetime | ✅ | |
| 종료 일시 | datetime | ✅ | |
| 대상 유저 | select | ✅ | 전체 / 신규 / 복귀 / VIP / 커스텀 세그먼트 |
| 보상 내용 | compound | ✅ | 유형별 상이 (코인/아이템/할인율 등) |
| 노출 배너 | file | - | 이벤트 배너 이미지 |
| 푸시 알림 여부 | boolean | - | 이벤트 시작 시 푸시 발송 |

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 이벤트 생성 + 저장 | 유효성 검증 (기간 중복, 보상 설정) → 저장 | Firestore `events/` |
| 이벤트 활성화 | 예약 시간에 자동 활성화 또는 즉시 활성화 | 상태 → `active` |
| 이벤트 종료 | 수동 조기 종료 또는 예약 종료 시간에 자동 | 상태 → `ended` |
| 참여 현황 조회 | 참여자 수, 보상 지급량, 비용 집계 표시 | 없음 |

---

### ADM-033. 거래 로그

| 항목 | 내용 |
|------|------|
| **진입 조건** | 사이드바 "경제 관리 > 거래 로그" |
| **접근 권한** | 전 역할 (읽기 전용) |

**거래 로그 테이블**:

| 컬럼 | 타입 | 설명 |
|------|------|------|
| 거래 ID | string | `txn_20260227_12345` |
| 일시 | datetime | 거래 발생 시각 |
| 유저 | string (link) | UID + 닉네임 |
| 거래 유형 | enum | 구매 / 보상 / 운영지급 / 게임결과 / 환불 / 이벤트 |
| 항목 | string | 코인 / 젬 / 아이템명 |
| 변동량 | number | +5,000 / -200 |
| 변동 후 잔액 | number | 15,200 코인 |
| 출처 | string | 상점 / 배틀패스 / AI승리 / 관리자지급 |
| 관리자 | string | 운영지급인 경우 관리자 ID |

**필터**:
- 유저 UID/닉네임
- 거래 유형
- 날짜 범위
- 금액 범위 (대규모 거래 탐지)
- 출처

**이상 거래 감지 하이라이트**:

| 조건 | 표시 |
|------|------|
| 단일 거래 100,000 코인 이상 | 🟡 Yellow 하이라이트 |
| 1시간 내 10건 이상 거래 | 🟡 Yellow 하이라이트 |
| 1일 환불 3건 이상 | 🔴 Red 하이라이트 |
| 운영 지급 건 | 🔵 Blue 하이라이트 |

---

## 5. 콘텐츠 관리 (Content Management)

### ADM-040. 공지사항 관리

| 항목 | 내용 |
|------|------|
| **진입 조건** | 사이드바 "콘텐츠 > 공지사항" |
| **접근 권한** | Super Admin (전체), Admin (작성/수정) |

**공지 목록 테이블**:

| 컬럼 | 타입 | 설명 |
|------|------|------|
| ID | number | 자동 증가 |
| 제목 | string | 공지 제목 |
| 카테고리 | enum | 일반 / 업데이트 / 이벤트 / 점검 / 긴급 |
| 상태 | enum | 작성중 / 예약 / 게시 / 만료 |
| 상단 고정 | boolean | 고정 공지 여부 |
| 팝업 표시 | boolean | 앱 진입 시 팝업 모달 표시 |
| 게시 시작 | datetime | |
| 게시 종료 | datetime | 자동 만료 |
| 조회수 | number | |
| 작성자 | string | 관리자 이름 |

**공지 작성 에디터**:

| 필드 | 타입 | 필수 | 설명 |
|------|------|:----:|------|
| 제목 | text | ✅ | 최대 100자 |
| 카테고리 | select | ✅ | |
| 내용 | rich-text | ✅ | Markdown 에디터 (이미지 업로드 지원) |
| 게시 시작일 | datetime | ✅ | 예약 게시 가능 |
| 게시 종료일 | datetime | - | 미설정 시 수동 만료 |
| 상단 고정 | toggle | - | 최대 3건 |
| 팝업 표시 | toggle | - | 최대 1건 (1일 1회 노출) |

**유저 액션 & 시스템 반응**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 공지 작성 + 저장 | 미리보기 → 저장 (작성중 상태) | Firestore `notices/` |
| "게시" 버튼 | 즉시 게시 또는 예약 시간에 자동 게시 | 상태 → `게시` |
| "수정" 버튼 | 수정 에디터 표시 (수정 이력 자동 기록) | Firestore 갱신 |
| "만료" 버튼 | 수동 만료 처리 (게시 목록에서 제거) | 상태 → `만료` |
| "삭제" 버튼 | 확인 다이얼로그 → soft delete | `deletedAt` 기록 |

---

### ADM-041. 이벤트 배너 관리

| 항목 | 내용 |
|------|------|
| **진입 조건** | 사이드바 "콘텐츠 > 배너" |
| **접근 권한** | Super Admin (전체), Admin (생성/수정) |

**배너 슬롯**:

| 위치 | 최대 수 | 크기 | 순환 |
|------|:------:|------|------|
| 메인 로비 상단 배너 | 5개 | 720×320 px | 5초 자동 슬라이드 |
| 상점 상단 배너 | 3개 | 720×200 px | 수동 스와이프 |
| 팝업 배너 (앱 진입) | 1개 | 640×480 px | 1일 1회 |

**배너 등록 폼**:

| 필드 | 타입 | 필수 | 설명 |
|------|------|:----:|------|
| 배너명 | text | ✅ | 내부 관리용 이름 |
| 위치 | select | ✅ | 로비 / 상점 / 팝업 |
| 이미지 | file | ✅ | 위치별 규정 크기 |
| 링크 타입 | select | ✅ | 딥링크 / 외부URL / 공지사항 / 이벤트 / 없음 |
| 링크 대상 | text | - | `baduki://shop/pack_001` 또는 URL |
| 노출 순서 | number | ✅ | 낮을수록 먼저 |
| 게시 시작 | datetime | ✅ | |
| 게시 종료 | datetime | ✅ | |
| 대상 유저 | select | - | 전체 / 세그먼트 (기본: 전체) |

---

### ADM-042. 시즌 테마 관리

| 항목 | 내용 |
|------|------|
| **진입 조건** | 사이드바 "콘텐츠 > 시즌 테마" |
| **접근 권한** | Super Admin (전체) |

**시즌 테마 구성요소**:

| 요소 | 설명 | 에셋 형식 |
|------|------|---------|
| 로비 배경 | 메인 로비 배경 이미지/애니메이션 | 1920×1080 PNG or Lottie |
| 게임 테이블 기본 테마 | 시즌별 기본 테이블 스킨 | Unity Sprite Atlas |
| BGM | 시즌별 배경 음악 | .ogg (Unity AudioClip) |
| 로딩 화면 | 스플래시 시즌 변형 | 1080×1920 PNG |
| 시즌 아이콘 | 배틀패스/랭킹 아이콘 | 256×256 PNG |

**테마 변경 프로세스**:

| 유저 액션 | 시스템 반응 | 데이터 변경 |
|---------|-----------|-----------|
| 테마 등록 (에셋 업로드) | 에셋 유효성 검증 (크기, 포맷) | CDN 업로드 |
| 시즌 테마 연결 | 배틀패스 시즌에 테마 매핑 | Firestore `seasons/` |
| 테마 미리보기 | 웹 기반 미리보기 (모바일 시뮬레이터) | 없음 |
| 테마 적용 | 시즌 시작 시 자동 적용 (또는 즉시 적용) | Remote Config |

---

## 6. 관리자 API 엔드포인트

### 6.1 인증 (Admin Auth)

| Method | Endpoint | 설명 | 권한 |
|--------|---------|------|------|
| `POST` | `/admin/auth/login` | 관리자 로그인 (JWT 발급) | Public |
| `POST` | `/admin/auth/refresh` | 토큰 갱신 | Authenticated |
| `POST` | `/admin/auth/logout` | 로그아웃 (Refresh Token 무효화) | Authenticated |
| `GET` | `/admin/auth/me` | 현재 관리자 정보 | Authenticated |
| `PUT` | `/admin/auth/password` | 비밀번호 변경 | Authenticated |

**인증 플로우**:

```
[로그인]
POST /admin/auth/login { email, password }
→ 200 { accessToken (15분), refreshToken (7일) }
→ Redis에 refreshToken 저장 (세션 관리)

[토큰 갱신]
POST /admin/auth/refresh { refreshToken }
→ 200 { newAccessToken, newRefreshToken }
→ 이전 refreshToken 무효화 (Token Rotation)

[모든 API 요청]
Headers: Authorization: Bearer {accessToken}
→ JWT 디코드 → role 확인 → RBAC 미들웨어 통과
```

### 6.2 대시보드 (Dashboard)

| Method | Endpoint | 설명 | 권한 |
|--------|---------|------|------|
| `GET` | `/admin/dashboard/realtime` | 실시간 지표 (CCU, 게임 수, 서버 상태) | All |
| `GET` | `/admin/dashboard/kpi` | KPI 차트 데이터 (기간 파라미터) | All |
| `GET` | `/admin/dashboard/retention` | 리텐션 코호트 데이터 | All |
| `GET` | `/admin/dashboard/elo-distribution` | ELO 분포 히스토그램 | All |
| `GET` | `/admin/dashboard/errors` | 에러 로그 목록 (페이지네이션) | All |

**WebSocket 채널**:

| 채널 | 이벤트 | 데이터 | 갱신 주기 |
|------|------|------|---------|
| `dashboard:realtime` | `metrics_update` | CCU, 게임 수, 서버 상태 | 5초 |
| `dashboard:errors` | `new_error` | 에러 로그 1건 | 발생 즉시 |
| `dashboard:alerts` | `new_alert` | 알림 1건 | 발생 즉시 |

### 6.3 유저 관리 (User Management)

| Method | Endpoint | 설명 | 권한 |
|--------|---------|------|------|
| `GET` | `/admin/users` | 유저 목록/검색 | CS+ |
| `GET` | `/admin/users/:userId` | 유저 상세 | CS+ |
| `GET` | `/admin/users/:userId/games` | 매치 히스토리 | CS+ |
| `GET` | `/admin/users/:userId/transactions` | 구매 내역 | CS+ |
| `PUT` | `/admin/users/:userId/nickname` | 닉네임 강제 변경 | Admin+ |
| `PUT` | `/admin/users/:userId/elo` | ELO 강제 조정 | Super |
| `PUT` | `/admin/users/:userId/currency` | 코인/젬 지급/차감 | Admin+ |
| `POST` | `/admin/users/:userId/sanctions` | 제재 적용 | Admin+ |
| `DELETE` | `/admin/users/:userId/sanctions/:id` | 제재 해제 | Admin+ |
| `GET` | `/admin/users/:userId/sanctions` | 제재 이력 | CS+ |
| `POST` | `/admin/users/:userId/notes` | 메모 추가 | CS+ |
| `GET` | `/admin/users/:userId/notes` | 메모 목록 | CS+ |

**Request/Response 예시 — 유저 검색**:

```
GET /admin/users?nickname=바둑이&elo_min=1500&elo_max=2000&status=active&limit=20&cursor=abc123

Response 200:
{
  "users": [
    {
      "userId": "user_abc123",
      "nickname": "바둑이마스터",
      "elo": 1650,
      "level": 25,
      "coins": 15200,
      "gamesPlayed": 350,
      "winRate": 0.514,
      "createdAt": "2026-02-15T14:30:00+09:00",
      "lastLogin": "2026-02-27T09:15:00+09:00",
      "status": "active"
    }
  ],
  "nextCursor": "def456",
  "totalCount": 142
}
```

### 6.4 신고 관리 (Reports)

| Method | Endpoint | 설명 | 권한 |
|--------|---------|------|------|
| `GET` | `/admin/reports` | 신고 목록 (필터/페이지네이션) | CS+ |
| `GET` | `/admin/reports/:reportId` | 신고 상세 | CS+ |
| `PUT` | `/admin/reports/:reportId/assign` | 처리자 배정 | Admin+ |
| `PUT` | `/admin/reports/:reportId/resolve` | 처리 완료 | CS+ |
| `GET` | `/admin/reports/:reportId/game-log` | 관련 게임 로그 | CS+ |

### 6.5 게임 운영 (Game Operations)

| Method | Endpoint | 설명 | 권한 |
|--------|---------|------|------|
| `GET` | `/admin/config/blinds` | 블라인드 설정 조회 | Admin+ |
| `PUT` | `/admin/config/blinds` | 블라인드 설정 변경 | Super |
| `GET` | `/admin/config/ai` | AI 파라미터 조회 | Admin+ |
| `PUT` | `/admin/config/ai` | AI 파라미터 변경 | Super |
| `GET` | `/admin/config/rewards` | 리워드 테이블 조회 | Admin+ |
| `PUT` | `/admin/config/rewards` | 리워드 테이블 변경 | Super |
| `GET` | `/admin/config/elo` | ELO 설정 조회 | Admin+ |
| `PUT` | `/admin/config/elo` | ELO 설정 변경 | Super |
| `GET` | `/admin/config/matchmaking` | 매칭 설정 조회 | Admin+ |
| `PUT` | `/admin/config/matchmaking` | 매칭 설정 변경 | Super |
| `GET` | `/admin/config/flags` | 피처 플래그 목록 | Super |
| `PUT` | `/admin/config/flags/:flagName` | 피처 플래그 변경 | Super |
| `GET` | `/admin/config/flags/history` | 플래그 변경 이력 | Super |
| `GET` | `/admin/config/history` | 설정 변경 이력 전체 | Admin+ |
| `POST` | `/admin/config/rollback/:configId` | 설정 롤백 | Super |

**Request/Response 예시 — 피처 플래그 변경**:

```
PUT /admin/config/flags/FEATURE_TAN_SYSTEM
Headers: Authorization: Bearer {accessToken}
Body:
{
  "value": true,
  "reason": "GRAC 심의 완료 — 탄 시스템 활성화",
  "password": "admin_password_재인증"
}

Response 200:
{
  "flag": "FEATURE_TAN_SYSTEM",
  "previousValue": false,
  "newValue": true,
  "changedBy": "super_admin_01",
  "changedAt": "2026-02-27T15:00:00+09:00",
  "reason": "GRAC 심의 완료 — 탄 시스템 활성화",
  "propagated": true,
  "affectedClients": 1234
}
```

### 6.6 경제 관리 (Economy)

| Method | Endpoint | 설명 | 권한 |
|--------|---------|------|------|
| `GET` | `/admin/shop/items` | 상점 아이템 목록 | Admin+ |
| `POST` | `/admin/shop/items` | 상점 아이템 생성 | Super |
| `PUT` | `/admin/shop/items/:itemId` | 상점 아이템 수정 | Admin+ |
| `DELETE` | `/admin/shop/items/:itemId` | 상점 아이템 삭제 (soft) | Super |
| `GET` | `/admin/shop/cosmetics` | 코스메틱 아이템 목록 | Admin+ |
| `POST` | `/admin/shop/cosmetics` | 코스메틱 아이템 생성 | Super |
| `PUT` | `/admin/shop/cosmetics/:itemId` | 코스메틱 아이템 수정 | Admin+ |
| `GET` | `/admin/battlepass/seasons` | 배틀패스 시즌 목록 | Admin+ |
| `POST` | `/admin/battlepass/seasons` | 배틀패스 시즌 생성 | Super |
| `PUT` | `/admin/battlepass/seasons/:seasonId` | 시즌 수정 | Super |
| `PUT` | `/admin/battlepass/seasons/:seasonId/rewards` | 보상 트랙 수정 | Super |
| `POST` | `/admin/battlepass/seasons/:seasonId/activate` | 시즌 활성화 | Super |
| `POST` | `/admin/battlepass/seasons/:seasonId/end` | 시즌 종료 | Super |
| `GET` | `/admin/events` | 이벤트/프로모션 목록 | Admin+ |
| `POST` | `/admin/events` | 이벤트 생성 | Admin+ |
| `PUT` | `/admin/events/:eventId` | 이벤트 수정 | Admin+ |
| `POST` | `/admin/events/:eventId/activate` | 이벤트 활성화 | Admin+ |
| `GET` | `/admin/transactions` | 거래 로그 (필터/페이지네이션) | All |
| `GET` | `/admin/transactions/anomalies` | 이상 거래 목록 | Admin+ |

### 6.7 콘텐츠 관리 (Content)

| Method | Endpoint | 설명 | 권한 |
|--------|---------|------|------|
| `GET` | `/admin/notices` | 공지사항 목록 | All |
| `POST` | `/admin/notices` | 공지사항 작성 | Admin+ |
| `PUT` | `/admin/notices/:noticeId` | 공지사항 수정 | Admin+ |
| `DELETE` | `/admin/notices/:noticeId` | 공지사항 삭제 (soft) | Admin+ |
| `POST` | `/admin/notices/:noticeId/publish` | 공지사항 게시 | Admin+ |
| `GET` | `/admin/banners` | 배너 목록 | Admin+ |
| `POST` | `/admin/banners` | 배너 등록 | Admin+ |
| `PUT` | `/admin/banners/:bannerId` | 배너 수정 | Admin+ |
| `DELETE` | `/admin/banners/:bannerId` | 배너 삭제 | Admin+ |
| `GET` | `/admin/themes` | 시즌 테마 목록 | Super |
| `POST` | `/admin/themes` | 테마 등록 | Super |
| `PUT` | `/admin/themes/:themeId` | 테마 수정 | Super |
| `POST` | `/admin/themes/:themeId/apply` | 테마 즉시 적용 | Super |

### 6.8 시스템 관리 (System)

| Method | Endpoint | 설명 | 권한 |
|--------|---------|------|------|
| `GET` | `/admin/system/admins` | 관리자 계정 목록 | Super |
| `POST` | `/admin/system/admins` | 관리자 계정 생성 | Super |
| `PUT` | `/admin/system/admins/:adminId` | 관리자 역할 변경 | Super |
| `DELETE` | `/admin/system/admins/:adminId` | 관리자 비활성화 | Super |
| `GET` | `/admin/system/logs` | 관리자 활동 로그 (감사) | Super |
| `GET` | `/admin/system/logs/export` | 감사 로그 CSV 내보내기 | Super |
| `GET` | `/admin/system/health` | 시스템 헬스 체크 | All |
| `GET` | `/admin/system/metrics` | 서버 메트릭 (CPU, Memory, DB) | Super |

---

## 부록

### A. 관리자 활동 로그 (Audit Log) 스키마

모든 관리자 작업은 PostgreSQL `admin_logs` 테이블에 기록된다.

```json
{
  "logId": "log_20260227_001",
  "adminId": "admin_super01",
  "adminRole": "ROLE_SUPER",
  "action": "USER_SANCTION",
  "target": "user_abc123",
  "details": {
    "sanctionType": "suspend",
    "duration": "7d",
    "reason": "반복 욕설 사용"
  },
  "ipAddress": "192.168.1.100",
  "userAgent": "Mozilla/5.0...",
  "timestamp": "2026-02-27T09:15:00+09:00"
}
```

**감사 로그 보관**: 최소 2년 (법적 요건 충족)

### B. 관리자 데이터 구조

```json
admin_accounts: {
  "adminId": "admin_super01",
  "email": "admin@lowbaduki.com",
  "name": "홍길동",
  "role": "ROLE_SUPER",
  "status": "active",
  "passwordHash": "bcrypt...",
  "lastLogin": "2026-02-27T08:00:00+09:00",
  "loginHistory": [...],
  "createdAt": "2026-01-01T00:00:00+09:00",
  "createdBy": "system"
}
```

### C. RBAC 권한 매트릭스 (전체)

| 기능 | Super | Admin | CS | Analyst |
|------|:-----:|:-----:|:--:|:-------:|
| 대시보드 조회 | ✅ | ✅ | ✅ | ✅ |
| 유저 검색/조회 | ✅ | ✅ | ✅ | ✅ |
| 유저 정보 수정 | ✅ | ✅ | - | - |
| 계정 제재 (경고~정지) | ✅ | ✅ | - | - |
| 계정 제재 (영구밴) | ✅ | - | - | - |
| 코인/아이템 지급 | ✅ | ✅ (한도) | - | - |
| 신고 처리 | ✅ | ✅ | ✅ | - |
| 게임 밸런싱 조회 | ✅ | ✅ | - | ✅ |
| 게임 밸런싱 수정 | ✅ | - | - | - |
| 피처 플래그 | ✅ | - | - | - |
| 매칭 설정 조회 | ✅ | ✅ | - | ✅ |
| 매칭 설정 수정 | ✅ | - | - | - |
| 상점 아이템 CRUD | ✅ | ✅ (가격만) | - | - |
| 배틀패스 관리 | ✅ | - | - | - |
| 이벤트/프로모션 | ✅ | ✅ | - | - |
| 거래 로그 조회 | ✅ | ✅ | ✅ | ✅ |
| 공지사항 관리 | ✅ | ✅ | - | - |
| 배너 관리 | ✅ | ✅ | - | - |
| 시즌 테마 관리 | ✅ | - | - | - |
| 관리자 계정 관리 | ✅ | - | - | - |
| 감사 로그 조회 | ✅ | - | - | - |

### D. 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|---------|--------|
| 1.0 | 2026-02-27 | 초안 작성 (S4 관리자 상세 기획서) | Claude Opus 4.6 |
