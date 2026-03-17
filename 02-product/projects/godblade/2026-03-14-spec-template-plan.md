# GodBlade 기존 문서 보강 + Spec 템플릿 보강 종합 계획

> **작성일**: 2026-03-14
> **프로젝트**: GodBlade
> **작성 배경**: 장비뽑기연출기획서.pptx(Ver.0.1) + YouTube 참고 영상 분석 + 클라이언트 연출 스토리보드(`gacha-client-story-board.md`)를 바탕으로, 기존 문서 4종 보강 + Spec 템플릿 보강/신규 생성

---

## Context

장비뽑기연출기획서.pptx(Ver.0.1) + YouTube 참고 영상 분석 + 클라이언트 연출 스토리보드를 바탕으로,ㅍ
기존에 작성된 GodBlade 가챠 관련 문서 4종과 범용 게임 Spec 템플릿을 보강하고,
GodBlade 전용 Spec 템플릿을 신규 생성하는 종합 계획.

---

## 스토리보드 핵심 내용 (`gacha-client-story-board.md`)

스토리보드에서 기존 기획서/개발계획서에 미반영된 신규 확인 사항:

### 마을 UI 개편 (기획서 4페이지)

| 위치 | 변경 후 | 비고 |
|------|--------|------|
| 좌측 하단 | 상점, 가방, 거래소(신규), 우편함 | 거래소는 버튼만 배치 (임의 이미지) |
| 우측 하단 | 뽑기(신규), 도전(신규) | — |
| 제외 | 스킬, 보석함, 조력자, 길드, 연금술, 제작, 아바타 | 기존 버튼 제거 |

### 뽑기 연출 플로우 (기획서 9~13페이지)

```
뽑기 상점 진입 (기존 상점 UI 사용)
  → 뽑기 버튼 클릭
  → 상자 개봉 연출 (패 깔리는 연출까지)
  → 카드 뒤집기 (수동 / 모두 열기)
  → 획득 결과
```

### 기존 문서에 미반영된 핵심 사항

| # | 신규 확인 사항 | 영향 문서 |
|:-:|-------------|---------|
| SB-1 | **마을 하단 UI 개편** — 좌측 하단(상점/가방/거래소/우편함) + 우측 하단(뽑기/도전), 기존 버튼 제거 | S3 기획서, S4 개발계획 |
| SB-2 | **뽑기 상점 진입 = 기존 상점 UI 사용** — 별도 상점 UI 신규 제작 불필요 | S4 Phase 4 |
| SB-3 | **상자 에셋 Fallback** — 개봉 연출 안될 시 Unity Asset Store 에셋 사용 (`Treasure Chest with Effects`) | S4 섹션 3.3 에셋 인벤토리 |
| SB-4 | **자동 조작 시 랜덤 순서** — "모두 열기"는 랜덤으로 하나씩 오픈 (순차가 아님) | S3 섹션 8.3, 클라이언트 Spec FR-09 |
| SB-5 | **짝 맞추기 트리거 시점** — "이미 뒤집어진 카드 중 동일 아이템 발견 시" 즉시 연출 (전체 공개 후가 아님) | S3 섹션 8.4, 클라이언트 Spec FR-11 |
| SB-6 | **"한번 더" 버튼 초기 숨김** — 카드 모두 열린 후에만 보이게 처리 | S3 섹션 8.7, 클라이언트 Spec FR-20 |
| SB-7 | **"모두 열기" → "상점 가기" 교체** — 모두 열린 후 버튼 교체 (동시 표시 아님) | 클라이언트 Spec FR-20 |

---

## 보강 대상 문서 6종

| # | 문서 | 경로 | 보강 유형 |
|:-:|------|------|:--------:|
| 1 | S3 기획서 (GDD) | `02-product/projects/godblade/2026-03-06-gacha-system-design.md` | 기존 보강 |
| 2 | S4 개발계획 | `02-product/projects/godblade/2026-03-06-gacha-development-plan.md` | 기존 보강 |
| 3 | Todo Tracker | `02-product/projects/godblade/2026-03-06-todo.md` | 기존 보강 |
| 4 | Gate Log | `02-product/projects/godblade/gate-log.md` | 기존 보강 |
| 5 | 범용 게임 Spec 템플릿 | `~/.claude/trine/templates/spec-template-game.md` | 기존 보강 |
| 6 | GodBlade 전용 Spec 템플릿 | `god_Sword/src/.specify/templates/spec-template-godblade.md` | **신규** |

---

## 1. S3 기획서 보강 (`gacha-system-design.md`)

### 현재 상태

- 섹션 8.0~8.10: 2026-03-13 연출 기획서 반영 완료
- Q1~Q7 미확정 주석이 곳곳에 산재

### 보강 항목

| # | 보강 내용 | 대상 섹션 | 근거 |
|:-:|---------|---------|------|
| 1-1 | Q&A 미확정 사항 통합 관리 섹션 추가 | 섹션 8.11 (신규) | Q1~Q7이 여러 섹션에 흩어져 있어 추적 어려움 |
| 1-2 | 영상 분석 레퍼런스 섹션 추가 | 섹션 8.12 (신규) | YouTube 참고 영상 분석 결과를 기획서에 공식 포함 |
| 1-3 | 등급별 이펙트 색상 테이블 구체화 | 섹션 8.5/8.6 | 영상 분석에서 도출된 등급별 색상 + 연출 강도 차등 |
| 1-4 | 카드 뒤집기 애니메이션 상세 타이밍 추가 | 섹션 8.3 | PPTX Ver.0.1의 카드 플립 시퀀스 (중간점 90° UISprite 교체) |
| 1-5 | 에셋 재활용/신규 참조 추가 | 섹션 8 하단 | S4 섹션 3.3 에셋 인벤토리 교차 참조 |
| 1-6 | **마을 하단 UI 개편 섹션 추가** | 신규 섹션 | SB-1: 좌측 하단(상점/가방/거래소/우편함) + 우측 하단(뽑기/도전), 기존 버튼 제거 |
| 1-7 | **자동 조작 시 랜덤 순서 명시** | 섹션 8.3 | SB-4: "모두 열기" 시 순차가 아닌 랜덤 순서로 카드 오픈 |
| 1-8 | **짝 맞추기 트리거 시점 명확화** | 섹션 8.4 | SB-5: 전체 공개 후가 아닌, 뒤집는 과정에서 동일 아이템 발견 시 즉시 연출 |
| 1-9 | **버튼 상태 전환 상세 명시** | 섹션 8.7 | SB-6/7: "한번 더" 초기 숨김→완료 후 표시, "모두 열기"→"상점 가기" 교체 |
| 1-10 | **상자 에셋 Fallback 기록** | 섹션 8.2 | SB-3: 상자 개봉 연출 안될 시 Asset Store 에셋 대안 |

---

## 2. S4 개발계획 보강 (`gacha-development-plan.md`)

### 현재 상태

- Phase 4 태스크 4-1~4-9: 2026-03-13 반영 완료
- 섹션 3.3 에셋 인벤토리: 2026-03-14 추가 완료
- NGUI UITweener 명시 + DOTween 사용 금지: 반영 완료

### 보강 항목

| # | 보강 내용 | 대상 섹션 | 근거 |
|:-:|---------|---------|------|
| 2-1 | Phase 4 태스크별 의존성 그래프 추가 | Phase 4 서두 | 4-1~4-9 간 선후 관계가 명시되지 않아 병렬/순차 판단 불가 |
| 2-2 | Phase 4 태스크별 예상 공수(SP) 추가 | Phase 4 테이블 | Trine 세션 계획에 필요 |
| 2-3 | Q&A 의존 태스크 표기 추가 | Phase 4 테이블 비고 | Q1~Q7 답변 전 착수 불가 태스크 명시 |
| 2-4 | 클라이언트 Spec 참조 링크 추가 | 섹션 1 또는 참조 | `gacha-draw-animation.spec.md` 교차 참조 |
| 2-5 | 영상 레퍼런스 분석 결과 반영 | Phase 4 비고 | 연출 구현 시 참고할 영상 분석 가이드 링크 |
| 2-6 | **마을 UI 개편 태스크 추가** | Phase 4 (신규 태스크) | SB-1: 좌측 하단(상점/가방/거래소/우편함) + 우측 하단(뽑기/도전), 기존 버튼 제거 |
| 2-7 | **상자 에셋 Fallback 에셋 인벤토리 반영** | 섹션 3.3 | SB-3: `Treasure Chest with Effects` (Asset Store) 대안 에셋 기록 |
| 2-8 | **자동 조작 랜덤 순서 반영** | Phase 4-4 비고 | SB-4: FSM WaitInput→CardFlip에서 랜덤 인덱스 선택 로직 |
| 2-9 | **짝 맞추기 실시간 트리거 반영** | Phase 4-5 비고 | SB-5: 카드 뒤집기 과정 중 즉시 짝 판정 (전체 공개 후 일괄이 아님) |

---

## 3. Todo Tracker 보강 (`todo.md`)

### 현재 상태

- Phase 4: 4-1~4-8 (8개 태스크) — 2026-03-06 초기 버전
- S4 개발계획은 4-1~4-9로 업데이트되었으나 todo는 미동기화

### 보강 항목

| # | 보강 내용 | 근거 |
|:-:|---------|------|
| 3-1 | Phase 4 태스크를 S4 개발계획 4-1~4-9와 동기화 | 2026-03-13 S4 업데이트 반영 |
| 3-2 | 클라이언트 Spec 참조 행 추가 (참조 문서 섹션) | `gacha-draw-animation.spec.md` 신규 생성 반영 |
| 3-3 | 에셋 인벤토리 참조 행 추가 (참조 문서 섹션) | S4 섹션 3.3 신규 추가 반영 |
| 3-4 | Q&A 문서 참조 행 추가 (참조 문서 섹션) | `2026-03-13-gacha-animation-questions.md` |
| 3-5 | 보완 계획서 참조 행 추가 (참조 문서 섹션) | `2026-03-14-gacha-animation-supplement-plan.md` |
| 3-6 | S4 Gate 상태 갱신 (⬜ → ✅) | gate-log.md에 이미 PASS 기록 (2026-03-06) |
| 3-7 | **스토리보드 참조 행 추가** (참조 문서 섹션) | `gacha-client-story-board.md` |
| 3-8 | **마을 UI 개편 태스크 행 추가** | SB-1: 스토리보드에서 확인된 신규 작업 |

---

## 4. Gate Log 보강 (`gate-log.md`)

### 현재 상태

- S1~S4 모두 기록 완료 (S1/S2 SKIP, S3/S4 PASS)
- 2026-03-13~14 보완 작업 이력 미반영

### 보강 항목

| # | 보강 내용 | 근거 |
|:-:|---------|------|
| 4-1 | S3 보완 이력 행 추가 | 2026-03-13 섹션 8.0~8.10 연출 기획 반영 |
| 4-2 | S4 보완 이력 행 추가 | 2026-03-14 섹션 3.3 에셋 인벤토리 + Phase 4 태스크 상세화 |
| 4-3 | 클라이언트 Spec 생성 이력 행 추가 | 2026-03-14 `gacha-draw-animation.spec.md` 신규 |
| 4-4 | Q&A 미결 사항 비고 추가 | Q1~Q7 답변 대기 상태 명시 |

---

## 5. 범용 게임 Spec 템플릿 보강 (`spec-template-game.md`)

### 현재 갭

| 섹션 | 현재 상태 | 갭 |
|------|---------|-----|
| Section 5 (데이터 모델) | 범용 C# 클래스만 | 게임 데이터 파이프라인(Data→DAO→Table→Store) 가이드 없음 |
| Section 6 (프로토콜) | DataPacking 범용적 | 직렬화 방식별 가이드 부족 |
| Section 9.2 (Prefab 계층) | 범용 트리 | UI 프레임워크(NGUI/uGUI) 분기 가이드 없음 |
| Section 9.9 (연출/이펙트) | DOTween 예시 하드코딩 | 프레임워크 중립적 표현 필요 |
| 없음 | — | 에셋 인벤토리 섹션 없음 |
| 없음 | — | 스코프 경계/Q&A 미확정 추적 섹션 없음 |
| 없음 | — | 리스크 및 완화 전략 섹션 없음 |
| Section 8 (서버 연동) | 기본 참조만 | Constitution 규칙 연결 가이드 없음 |

### 보강 항목

| # | 보강 내용 | 대상 | 변경 유형 |
|:-:|---------|------|:--------:|
| 5-1 | 에셋 인벤토리 섹션 추가 (기존 재활용 / 신규 제작) | 신규 섹션 | 추가 |
| 5-2 | 스코프 경계 + Q&A 미확정 사항 섹션 추가 | 신규 섹션 | 추가 |
| 5-3 | 리스크 및 완화 전략 섹션 추가 | 신규 섹션 | 추가 |
| 5-4 | Section 5에 게임 데이터 파이프라인 가이드 추가 | 5번 | 보강 |
| 5-5 | Section 6에 직렬화 방식별 가이드 추가 | 6번 | 보강 |
| 5-6 | Section 9.2에 UI 프레임워크 분기 작성 가이드 추가 | 9.2 | 보강 |
| 5-7 | Section 9.9에서 DOTween 하드코딩 제거 → 프레임워크 중립적 | 9.9 | 수정 |
| 5-8 | Section 8에 Constitution 규칙 참조 체크리스트 추가 | 8번 | 보강 |

---

## 6. GodBlade 전용 Spec 템플릿 신규 생성 (`spec-template-godblade.md`)

### 목적

보강된 `spec-template-game.md` 기반으로 GodBlade 프로젝트 고유 제약사항을 **사전 충전(pre-filled)**한 전용 템플릿.

### GodBlade 고유 제약사항 (Constitution 기반)

| 제약사항 | 출처 | 영향 |
|---------|------|------|
| NGUI 전용 (DOTween 미설치) | Constitution 2.2 | Section 9 전체: UITweener만 |
| Unity 2019.4.40f1 | Constitution 2.2 | 최신 Unity 기능 불가 |
| DataPacking 안티치트 | Constitution 5.x | 직렬화 필수 패턴 |
| EodUI 네이밍 규칙 | 코드 패턴 | `EodUI{기능명}.cs` |
| BuyXxxEvent.cs 이벤트 | 코드 패턴 | 서버 통신 Event 재사용 |
| Manager 싱글톤 | MUST-NOT-001 | 패턴 변경 금지 |
| GameDatascriptManager | Constitution 5.x | Data→DAO→Table→Store |
| Protocol 코드 범위 | Constitution 7.1 | 코드 할당 규칙 |

### 범용 → GodBlade 전용 변환 핵심

| 범용 | GodBlade 전용 | 사전 충전 내용 |
|------|-------------|-------------|
| Section 3.1 성능 | NFR 기본값 | FPS ≥30, 드로콜 <150, 씬전환 <3s |
| Section 3.2 보안 | DataPacking 필수 | 왕복 테스트 기본 포함 |
| Section 7 보안 | Constitution MUST 체크리스트 | MUST-001~005, MUST-NOT-001~003 |
| Section 9.0 (신규) | NGUI 제약사항 테이블 | 허용/금지 매트릭스 |
| Section 9.2 | NGUI UIRoot 기반 계층 | UIRoot→Panel→Grid/Sprite/Label |
| Section 9.3 | EodUI prefix | `EodUI{기능명}.cs` 강제 |
| Section 9.9 | UITweener 전용 | DOTween 사용 금지 명시 |
| Section 9.10 | Animator 범위 제한 | 캐릭터/3D 전용, UI에 금지 |

---

## 실행 순서

```
1. S3 기획서 보강 (10개 항목)
2. S4 개발계획 보강 (9개 항목)
3. Todo Tracker 보강 (8개 항목)
4. Gate Log 보강 (4개 항목)
5. spec-template-game.md 보강 (8개 항목)
6. spec-template-godblade.md 신규 생성
```

---

## 검증 기준

### 기존 문서 보강
- [ ] S3 기획서에 Q&A 통합 관리 섹션과 영상 레퍼런스가 추가되었는가
- [ ] S3 기획서에 마을 UI 개편, 자동 조작 랜덤 순서, 짝 맞추기 실시간 트리거가 반영되었는가
- [ ] S4 개발계획에 Phase 4 의존성 그래프와 예상 공수가 추가되었는가
- [ ] S4 개발계획에 마을 UI 개편 태스크, 상자 에셋 Fallback, 랜덤 순서가 반영되었는가
- [ ] Todo가 S4 개발계획과 동기화되고 스토리보드 참조가 추가되었는가
- [ ] Gate Log에 2026-03-13~14 보완 이력이 기록되었는가

### Spec 템플릿
- [ ] `spec-template-game.md`에 에셋 인벤토리, 스코프 경계, 리스크 섹션이 추가되었는가
- [ ] `spec-template-game.md`의 Section 9.9가 프레임워크 중립적으로 수정되었는가
- [ ] `spec-template-godblade.md`에 NGUI 제약사항이 Section 9.0에 명시되었는가
- [ ] `spec-template-godblade.md`에 Constitution MUST 규칙 체크리스트가 포함되었는가

---

## 관련 파일

| 파일 | 경로 | 역할 |
|------|------|------|
| S3 기획서 | `business/02-product/projects/godblade/2026-03-06-gacha-system-design.md` | 보강 대상 |
| S4 개발계획 | `business/02-product/projects/godblade/2026-03-06-gacha-development-plan.md` | 보강 대상 |
| Todo | `business/02-product/projects/godblade/2026-03-06-todo.md` | 보강 대상 |
| Gate Log | `business/02-product/projects/godblade/gate-log.md` | 보강 대상 |
| Q&A 질의서 | `business/02-product/projects/godblade/2026-03-13-gacha-animation-questions.md` | 참조 |
| 보완 계획서 | `business/02-product/projects/godblade/2026-03-14-gacha-animation-supplement-plan.md` | 참조 |
| 연출 기획서 | `business/02-product/projects/godblade/장비뽑기연출기획서.pptx` | 입력 |
| 범용 게임 Spec 템플릿 | `~/.claude/trine/templates/spec-template-game.md` | 보강 대상 |
| GodBlade 전용 템플릿 | `god_Sword/src/.specify/templates/spec-template-godblade.md` | 신규 |
| GodBlade Constitution | `god_Sword/src/.specify/constitution.md` | 참조 |
| 클라이언트 Spec | `god_Sword/src/.specify/specs/gacha-draw-animation.spec.md` | 참조 |
| **연출 스토리보드** | `business/02-product/projects/godblade/gacha-client-story-board.md` | **입력 (신규)** |

---

*Last Updated: 2026-03-14*
