# 장비 뽑기 연출 — 기존 문서 보완 계획서

> **작성일**: 2026-03-14
> **프로젝트**: GodBlade
> **작성 배경**: 장비뽑기연출기획서.pptx(Ver.0.1→Ver.0.2) + YouTube 참고 영상 분석 + 시스템 요구사항 체크 결과 기반

---

## 보완 대상 문서

| 문서 | 경로 |
|------|------|
| S3 GDD | `02-product/projects/godblade/2026-03-06-gacha-system-design.md` |
| S4 개발계획 | `02-product/projects/godblade/2026-03-06-gacha-development-plan.md` |
| 서버 Spec | `god_Sword/src/.specify/specs/gacha-pattern-system.spec.md` |
| 클라이언트 Spec (신규) | `god_Sword/src/.specify/specs/gacha-draw-animation.spec.md` |

---

## 보완 배경 (Why)

| 문서 | 보완 필요 이유 | 현재 상태 (2026-03-14) |
|------|-------------|---------------------|
| S3 GDD 섹션 8 | 연출 기획서(PPTX Ver.0.1) 내용 반영 | ✅ 2026-03-13 반영 완료 (8.0~8.10) |
| S4 개발계획 Phase 4 | 씬/스크립트/에셋 단위 태스크 분해 | ✅ 4-1~4-9 반영 완료 |
| S4 개발계획 Phase 4 | 기존 재활용 vs 신규 에셋 구분 | ⚠️ 섹션 3.3 추가 필요 |
| 서버 Spec Section 9 | 클라이언트 구현 명세 | ✅ 별도 스펙 생성으로 대응 |
| 클라이언트 Spec | Unity 구현 전용 스펙 부재 | ✅ gacha-draw-animation.spec.md 신규 생성 |
| Q&A 문서 | Q1~Q7 미결 (Phase 4 착수 전 선결 필요) | ⚠️ Human 작업 필요 |

---

## 실행 결과 요약

### 1. S4 개발계획 — 에셋 인벤토리 추가 (섹션 3.3)

#### 기존 재활용 가능 에셋

| 에셋 | 유형 | 용도 |
|------|------|------|
| ChangeSizeColor.cs | 스크립트 | 글로우 이펙트 (짝 맞추기 연출) |
| DelayActive.cs | 스크립트 | 이펙트 순서 제어 |
| ObjectMove.cs | 스크립트 | 카드 이동 애니메이션 |
| ef_CardBack_Circle.prefab | 프리팹 | 카드 뒷면 이펙트 |
| ef_Card_Charge.prefab | 프리팹 | 카드 충전/당첨 이펙트 |
| BuyGachaEvent.cs | 스크립트 | 서버 통신 이벤트 (gachaType 필드 확인 후 재사용) |
| EodUIGoodsShopGachaResultPopup.cs | 스크립트 | 결과 팝업 (재사용 또는 보완) |

#### 신규 제작 필요

| 에셋 | 유형 | 비고 |
|------|------|------|
| GachaDrawScene.unity | 씬 | Unity MCP (localhost:6400) 활용 |
| GachaCard.prefab | 프리팹 | NGUI 기반, TweenRotation Y축 180° |
| EodUIGachaDrawScene.cs | 스크립트 | FSM 메인 컨트롤러 (Idle→ChestOpen→CardLayout→WaitInput→CardFlip→MatchEffect→Result) |
| EodUIGachaCard.cs | 스크립트 | 카드 상태 관리 (대기/뒤집기/결과) |
| EodUIGachaCardLayout.cs | 스크립트 | 10장 UIGrid 배치 |
| EodUIGachaMatchEffect.cs | 스크립트 | 짝 맞추기 이펙트 로직 (ChangeSizeColor 재활용 + 번개 파티클) |
| 번개 파티클 Particle System | 이펙트 에셋 | 짝 매칭 번개 연출 × 1 |

### 2. 클라이언트 Spec 신규 생성

`/mnt/e/new_workspace/god_Sword/src/.specify/specs/gacha-draw-animation.spec.md`

포함 내용:
- Section 9: 신규 씬 구성, UI 컴포넌트 계층, 씬 전환 흐름
- Section 9.4: 클라이언트 ↔ 서버 연동 (BuyGachaEvent.cs 재사용)
- Section 9.5: NGUI 컴포넌트 사용 기준 (DOTween 사용 금지)
- Section 9.8: 성능 기준 (Android Mobile, FPS ≥ 30)

---

## Q&A 선결 항목 (Human 작업 필요)

`2026-03-13-gacha-animation-questions.md` Q1~Q7 답변 후 S3/S4 업데이트 필요.

| Q# | 우선순위 | 내용 | 영향 범위 |
|:--:|:-------:|------|----------|
| Q1 | **HIGH** ✅ | 꽝(전부 필러) 시 연출 방식 → **해결**: 연기 파티클 + "다음 기회에" 텍스트 (꽝화면참고스샷.png) | S3 섹션 8.4, Spec FR-15a~c |
| Q2 | **HIGH** ✅ | 짝 맞추기 이펙트 색상 = 별(성) 등급별 RGB (v0.2 확정) | S3 섹션 8.5, S4 G-4 |
| Q3 | MEDIUM | 필러 카드 그레이아웃 적용 여부 | S4 4-4, 클라이언트 Spec |
| Q4 | MEDIUM | "모두 열기" 시 짝 맞추기 연출 타이밍 | S4 4-4 |
| Q5 | MEDIUM | Row 소진 연출 포함 여부 | S4 4 태스크 추가 여부 |
| Q6 | LOW | 소프트 피티 특별 연출 여부 | S4 4-5 분기 추가 여부 |
| Q7 | LOW | 진행률 표시(37/N) 포함 여부 | S4 4 태스크 추가 여부 |

---

## 검증 기준

- [x] S4 개발계획 Phase 4에 재활용/신규 에셋 인벤토리가 명시되었는가
- [x] 클라이언트 Unity 구현 스펙 파일이 존재하는가
- [x] 서버 Spec Section 9 "해당 없음"이 클라이언트 스펙 참조로 안내되었는가
- [x] Q1 답변이 S3 섹션 8에 반영되었는가 → ✅ 2026-03-16 꽝화면참고스샷.png 기반 반영
- [x] Q2 답변이 S3 섹션 8에 반영되었는가 → ✅ 2026-03-17 v0.2 기획서 기반 반영 (별(성) 등급별 RGB)
- [x] Q3-Q7 답변이 S4 Phase 4 태스크에 확정/제거 처리되었는가 → ✅ 2026-03-16 전체 확정 반영

---

*Last Updated: 2026-03-17 — Q2 확정 반영 (v0.2 기획서: 별(성) 등급별 RGB), Q1~Q7 전체 확정 완료*
