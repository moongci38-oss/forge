# 로우 바둑이 (Low Baduki) — SIGIL → Trine Handoff

**생성일**: 2026-03-02
**SIGIL 완료 Stage**: S4 (✅ PASS)
**프로젝트 유형**: 게임 개발 (Unity)
**Gate Log**: `02-product/projects/baduki/gate-log.md`

---

## 1. SIGIL 산출물 인덱스

### S1 Research (2026-02-26)

| 산출물 | 경로 |
|--------|------|
| 통합 리서치 | `01-research/projects/baduki/2026-02-26-s1-integrated-research.md` |
| 리서치 요약 | `01-research/projects/baduki/2026-02-26-s1-research-summary.md` |
| 게임 규칙/메커니즘 | `01-research/projects/baduki/2026-02-26-s1-game-rules-mechanics.md` |
| 게임 규칙 심층 리서치 | `01-research/projects/baduki/2026-02-26-s1-game-rules-mechanics-research.md` |
| 기술 스택 분석 | `01-research/projects/baduki/2026-02-26-s1-tech-stack-analysis.md` |
| 법률/규제 | `01-research/projects/baduki/2026-02-26-s1-legal-regulatory.md` |
| 법률 핵심 정리 | `01-research/projects/baduki/2026-02-26-s1-legal-key-takeaways.md` |
| 플랫폼/관리자 도구 | `01-research/projects/baduki/2026-02-26-s1-platform-admin-tools.md` |

### S2 Concept (2026-02-27)

| 산출물 | 경로 |
|--------|------|
| 컨셉 문서 | `02-product/projects/baduki/2026-02-27-s2-concept.md` |

### S3 Design Document (2026-02-27)

| 산출물 | 경로 |
|--------|------|
| GDD (Markdown) | `02-product/projects/baduki/2026-02-27-s3-gdd.md` |
| GDD (PowerPoint) | `02-product/projects/baduki/2026-02-27-s3-gdd.pptx` |

### S4 Planning Package (2026-02-27 ~ 2026-03-02)

| 산출물 | 경로 |
|--------|------|
| 상세 기획서 (서비스) | `02-product/projects/baduki/2026-02-27-s4-detailed-plan.md` |
| 상세 기획서 (관리자) | `02-product/projects/baduki/2026-02-27-s4-admin-detailed-plan.md` |
| 사이트맵 (서비스) | `02-product/projects/baduki/2026-02-27-s4-sitemap.md` |
| 사이트맵 (관리자) | `02-product/projects/baduki/2026-02-27-s4-admin-sitemap.md` |
| 로드맵 (통합) | `02-product/projects/baduki/2026-02-27-s4-roadmap.md` |
| 개발 계획 (통합) | `02-product/projects/baduki/2026-02-27-s4-development-plan.md` |
| WBS (통합) | `02-product/projects/baduki/2026-02-27-s4-wbs.md` |
| UI/UX 기획서 (서비스) | `05-design/projects/baduki/2026-02-27-s4-uiux-spec.md` |
| UI/UX 기획서 (관리자) | `05-design/projects/baduki/2026-02-27-s4-admin-uiux-spec.md` |
| 테스트 전략서 (통합) | `02-product/projects/baduki/2026-02-27-s4-test-strategy.md` |

---

## 2. 기술 스택 요약

### 게임 클라이언트

| 레이어 | 기술 |
|--------|------|
| 엔진 | Unity 6.3 LTS (2D URP) |
| 언어 | C# (.NET 7+) |
| UI | UI Toolkit + TextMesh Pro |
| AI 추론 | Unity Inference Engine (ONNX) |
| 애니메이션 | DOTween |

### 네트워크

| Phase | 기술 |
|:-----:|------|
| 1 | Unity Netcode for GameObjects |
| 2+ | Photon Fusion |

### 백엔드

| 레이어 | 기술 |
|--------|------|
| 인증 | Firebase Authentication |
| DB | Firebase Firestore (게임) + PostgreSQL 16 (관리자) |
| 서버리스 | Firebase Cloud Functions (Node.js 18) |
| 분석 | Firebase Analytics + Crashlytics |
| 캐싱 | Redis 7.x (관리자) |

### 관리자 웹

| 레이어 | 기술 |
|--------|------|
| 프론트엔드 | React 18 + TypeScript + Tailwind CSS |
| 백엔드 | Node.js 20 + Express + Prisma |
| 실시간 | Socket.IO 4.x |
| 배포 | Docker + Nginx |

### CI/CD

| 도구 | 용도 |
|------|------|
| GitHub Actions | 자동 빌드/테스트/배포 |
| GameCI | Unity Android/iOS 빌드 |
| Firebase CLI | Cloud Functions/Firestore 배포 |

---

## 3. Trine 세션 로드맵

12개 Trine 세션. 총 82 스토리, 312 스토리 포인트.

| Session | 이름 | 분류 | SP | Phase | 의존성 |
|:-------:|------|:----:|:--:|:-----:|--------|
| 1 | 프로젝트 셋업 + 인증 | Standard | 30 | Now | — |
| 2 | 코어 게임 로직 | Multi-Spec | 34 | Now | S1 |
| 3 | AI 대전 (Easy/Medium) | Standard | 14 | Now | S2 |
| 4 | 게임 UI + 로비 | Multi-Spec | 27 | Now | S2 |
| 5 | 네트워크 멀티플레이 | Multi-Spec | 28 | Next | S2 |
| 6 | 경제/수익화 | Multi-Spec | 34 | Next | S5 |
| 7 | 탄 시스템 | Standard | 16 | Later | S6 |
| 8 | 소셜 시스템 | Standard | 13 | Next | S1 |
| 9 | 관리자 대시보드 + 유저 | Multi-Spec | 54 | Now~Next | S1 |
| 10 | 관리자 운영 + 경제 | Standard | 32 | Next | S9 |
| 11 | AI Hard + CFR | Standard | 13 | Next | S3 |
| 12 | 품질/인프라 | Standard | 17 | Next | 전체 |

### 세션 의존성 트리

```
S1 (셋업+인증)
├── S2 (코어 게임) → S3 (AI) → S11 (AI Hard)
│                  → S4 (UI)
│                  → S5 (네트워크) → S6 (경제) → S7 (탄 시스템)
├── S8 (소셜)
├── S9 (관리자 대시보드) → S10 (관리자 운영)
└── S12 (품질/인프라) ← 전체 기능 후
```

---

## 4. 개발 환경 가이드

### 필수 도구

| 도구 | 용도 |
|------|------|
| Unity Editor 6.3 LTS | 게임 개발 (2D URP 템플릿) |
| VS Code / Rider | C# 코드 편집 |
| Git + LFS | 버전 관리 (에셋 바이너리) |
| Firebase CLI | 클라우드 서비스 관리 |
| Node.js 20 LTS | 관리자 백엔드 |
| Docker | 관리자 서버 컨테이너화 |

### 빌드 타겟

| 플랫폼 | 최소 사양 | Phase |
|--------|---------|:-----:|
| Android | API 24 (7.0), 2GB RAM | 1 |
| iOS | iOS 14.0, iPhone 8 | 1 |
| PC | Windows 10, DirectX 11 | 3 |
| WebGL | Chrome 90+ | 3+ |

### Unity 에디터 설정

- Color Space: Linear
- Scripting Backend: IL2CPP
- Asset Serialization: Force Text (Git diff 가능)

---

## 5. 핵심 아키텍처 결정 (ADR 요약)

| ADR | 결정 | 핵심 근거 |
|-----|------|---------|
| ADR-001 | Unity 6.3 LTS | AI 3대 기능, 크로스플랫폼, LTS 2년 지원 |
| ADR-002 | Server-Authoritative | 부정행위 방지, 카드 정보 서버 관리 |
| ADR-003 | Firebase 백엔드 | Phase 1 비용 $0, 서버리스, Unity SDK |
| ADR-004 | 온디바이스 AI 추론 | 서버 비용 $0, 오프라인 가능, NPU 가속 |
| ADR-005 | React+Node.js 관리자 | 독립 개발/배포, PostgreSQL 복잡 쿼리 |
| ADR-006 | Photon Fusion 단계적 도입 | Phase 1 무료(Netcode) → Phase 2 전환 |
| ADR-007 | Firestore 문서 기반 | 1회 읽기 전체 프로필, 실시간 리스너 |

---

## 6. 우선순위 (Now/Next/Later)

### Now (Phase 1: 프로토타입 — 1~2개월)

핵심 게임 루프 검증 + 최소 운영 인프라. 프로토타입 유저 테스트 20명 목표.

- 코어 게임 로직 (카드 배분, 드로우, 베팅, 족보, 쇼다운)
- AI 대전 (Easy + Medium)
- 기본 UI (로비 + 게임 + 결과)
- 인터랙티브 튜토리얼
- 인증 (Google/Apple/게스트)
- 친구 대전
- 관리자: 유저 관리 + 실시간 모니터링 + 인증/RBAC

### Next (Phase 2: 소프트 런치 — 3~4개월)

멀티플레이 + 수익화. D1 40%+, D7 20%+, 유료 전환 3%+ 목표.

- 네트워크 멀티플레이 (ELO 매칭, 서버 권위)
- 경제/수익화 (코인/젬, 상점, 배틀패스, IAP, AdMob)
- 소셜 시스템 (친구, 이모지, 리더보드)
- 관리자: 게임 운영 + 경제 관리
- AI Hard + CFR 파이프라인
- 품질/인프라 (테스트, CI/CD, 모니터링)

### Later (Phase 3+: 정식 출시 이후)

- 탄 시스템 (GRAC 심의 통과 후 피처 플래그 ON)
- 시즌 시스템
- 클럽/길드
- PC/WebGL 빌드

---

## 7. Trine 진입 체크리스트

- [ ] Unity 프로젝트 Git 저장소 생성 (GitHub Private)
- [ ] `.specify/` 디렉토리 구조 생성
- [ ] `constitution.md` 작성 (프로젝트 헌법)
- [ ] Unity 6.3 LTS 설치 확인
- [ ] Firebase 프로젝트 생성 (Spark 무료 플랜)
- [ ] GitHub Actions + GameCI 기본 워크플로우 설정
- [ ] Git LFS 활성화 (.gitattributes)
- [ ] Trine Session 1 Spec 작성 시작

---

## 8. 의사결정 기록

| 일자 | 결정 | 근거 |
|------|------|------|
| 2026-03-02 | 국내 전용 서비스 확정 | 한국 국내 전용. 해외 진출 계획 철회 |

---

*Generated from SIGIL S1-S4 artifacts by `/trine` handoff process*
