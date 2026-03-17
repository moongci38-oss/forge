# GodBlade 뽑기 시스템 — 상세개발계획서

> **작성일**: 2026-03-06
> **프로젝트**: GodBlade (Evil of Darkness)
> **SIGIL Stage**: S4 Planning Package (기능 추가 — Feature-scoped)
> **기반 문서**: S3 기획서 `2026-03-06-gacha-system-design.md`
> **최종 업데이트**: 2026-03-16 — Q&A 확정(Q1~Q7), Unity 6 기술 스택, G-1~G-10 클라이언트 태스크, 의존성 그래프 추가

---

## 0. 참조 문서

| 문서 | 경로 |
|------|------|
| **클라이언트 Spec** | `god_Sword/src/.specify/specs/gacha-draw-animation.spec.md` |
| **S3 기획서** | `business/02-product/projects/godblade/2026-03-06-gacha-system-design.md` |
| **영상 분석 레퍼런스** | `business/02-product/projects/godblade/docs/assets/video-refs/2026-03-15-gacha-card-flip-reference-analysis.md` |
| **연출 스토리보드** | `business/02-product/projects/godblade/gacha-client-story-board.md` |
| **이해도 리포트** | `god_Sword/src/docs/reviews/2026-03-06-gacha-workflow-understanding-report.md` |

---

## 1. 개발 범위 요약

이 문서는 **기존 GodBlade 프로젝트에 NewGachaPattern 기능을 추가**하는 상세 개발 계획이다. 전체 프로젝트 수준의 S4 패키지가 아닌, 이 기능에 한정된 구현 계획을 다룬다.

### 기술 스택 (2026-03-15 코드 분석 기준)

| 항목 | 버전/값 | 비고 |
|------|--------|------|
| Unity | 6000.3.10f1 LTS (Unity 6) | 기존 문서의 2019.4.40f1에서 변경 |
| UI 프레임워크 | NGUI + UITweener (기존) | 기존 코드는 UITweener 유지 |
| 신규 연출 라이브러리 | DOTween | 2026-03-15 도입 확정, 신규 코드에만 사용 |
| 렌더 파이프라인 | Built-in (Forward) | URP/HDRP 아님 |
| Unity AI | Muse Chat / Muse Behavior (Beta) | Editor 내부 플러그인 |

### 1.1 변경 영역

| 영역 | 변경 수준 | 설명 |
|------|:---------:|------|
| 서버 — 데이터 로딩 | **신규** | NewGachaPattern, NewGachaItemGroup DB 테이블 + Data/Table 클래스 |
| 서버 — 서비스 로직 | **분기 추가** | BuyGachaService에 NewGachaPattern 분기 |
| 서버 — 분해 알고리즘 | **신규** | Bounded Coin Change + 가중치 선택 |
| 서버 — 유저 상태 관리 | **신규** | NewGachaPatternAssignment DB 테이블 + CRUD |
| 서버 — 기동 검증 | **추가** | Pattern값 분해 가능 여부 + 아이템 풀 수량 검증 |
| 클라이언트 — UI/연출 | **변경** | 결과 팝업 10개 표시 + 보상/필러 구분 연출 |
| 클라이언트 — 데이터 | **신규** | EodDataNewGachaPattern, EodDataNewGachaItemGroup |
| 공통 — 프로토콜 | **없음** | BuyGacha.cs 변경 없음 |
| 기획 데이터 | **신규** | DB 테이블 3종 (NewGachaPattern + NewGachaItemGroup + NewGachaPatternAssignment) |

### 1.2 변경하지 않는 것

- BuyGacha.cs (Request/Response 구조)
- BuyGachaEvent.cs (클라이언트 이벤트)
- 기존 ShopGacha 뽑기 로직 (gachaType 분기로 격리)
- ItemGenerator.cs (참조만, 수정 없음)

---

## 2. 서버 구현 상세

### 2.1 데이터 클래스 (Data Layer)

#### EodDataNewGachaPattern.cs

```
위치: common/EodGameCommon/Data/ 또는 server 측 Data 폴더 (기존 패턴 따름)
참조: EodDataShopGacha.cs (DataPacking 패턴)
```

| 필드 | 타입 | DataPacking |
|------|------|:-----------:|
| GachaPriceCode | int | O |
| GachaPageGroup | int | O |
| GachaItemGroupCode | int | O |
| PatternCount | int | O | 이 Row의 유효 슬롯 수 (가변) |
| Pattern01~PatternN | int[] (PatternCount개) | O | DB 컬럼은 최대치만큼 정의, PatternCount까지만 유효 |

- DataPacking 안티해킹 패턴 적용 (기존 ShopGacha Data 클래스와 동일)
- DB에서 서버 기동 시 로드하여 메모리 캐싱 (기존 DataPacking 패턴 적용)

#### EodDataNewGachaItemGroup.cs

```
참조: EodDataShopGachaItemGroup.cs
```

| 필드 | 타입 | DataPacking |
|------|------|:-----------:|
| GachaItemPriceCode | int | O |
| ItemCode | int (EodGTC) | O |
| RequiredClass | eCharacterClass | O |

### 2.2 테이블 클래스 (Table Layer)

#### EodTableNewGachaPattern.cs

```
참조: 기존 Table 클래스 패턴
```

- `GetPattern(int gachaPriceCode, int gachaPageGroup, int gachaItemGroupCode)` → EodDataNewGachaPattern
- `GetUnclaimedRows(int gachaPriceCode, int gachaPageGroup)` → 목록 (서버 기동 시 로드)
- 복합키 `{GachaPriceCode}_{GachaPageGroup}_{GachaItemGroupCode}`로 Dictionary 인덱싱

#### EodTableNewGachaItemGroup.cs

- `GetItemsByPriceAndClass(int gachaItemPriceCode, eCharacterClass requiredClass)` → 후보 목록
- `GetItemsByClass(eCharacterClass requiredClass)` → 전체 후보 (일반 필러용)
- `GetHighGradeItemsByClass(eCharacterClass requiredClass, int minGrade)` → 고등급 후보 (NewGachaItemGroup.ItemCode == Item.GeneralTypeCode 조인 → Item.ItemGrade >= 7, 필러용)
- 이중 인덱스: `{GachaItemPriceCode}_{RequiredClass}` + `{RequiredClass}`

### 2.3 BuyGachaService 분기

```
기존 BuyGachaService.Process() 흐름:
  1. ShopGacha 데이터 조회 (productCode)
  2. CheckPayCost (비용 확인)
  3. PayCost (비용 차감)
  4. gachaType 분기 ← 여기에 NewPattern 추가
     ├─ 기존 타입: OpenLottoGachas (기존 로직 그대로)
     └─ NewPattern: ProcessNewGachaPattern() ← 신규 메서드
```

#### ProcessNewGachaPattern() 흐름

```
1. 유저의 현재 할당 Row 조회 (DB: NewGachaPatternAssignment)
   └─ 없으면: AllocateNewRow() → DB 원자적 선점
2. CurrentSlotIndex 위치의 Pattern값 읽기
3. 소프트 피티 체크
   └─ 연속 꽝 10회 + 현재 꽝 → 미사용 양수 슬롯 강제 교체
4. Pattern값 처리
   ├─ 0: ProcessLoss() → 필러 10개 선정 (고등급 1~2개 포함, item.grade 기반)
   └─ >0: ProcessWin() → 분해 → 쌍 아이템 + 필러 (고등급 1~2개 포함)
5. CurrentSlotIndex += 1, ConsecutiveLossCount 갱신
6. 전체 슬롯(PatternCount) 소진 확인 → 소진 시 Row 해제 (ClaimedByPlayerId = NULL)
7. Response 조립 (기존 BuyGacha.Response 구조 그대로)
```

### 2.4 분해 알고리즘 (DecompositionService)

별도 static 유틸리티 클래스로 분리한다.

```
위치: server/EodGameServer/Service/NewGachaDecompositionService.cs (또는 Utility/ 폴더)
```

#### 핵심 메서드

| 메서드 | 입력 | 출력 | 설명 |
|--------|------|------|------|
| `Decompose(int amount)` | 당첨금 총액 | `List<int[]>` (모든 유효 조합) | Bounded Coin Change 재귀 |
| `SelectCombo(List<int[]> combos, int gachaPriceCode)` | 조합 목록 + 가격대 | `int[]` (선택된 1개 조합) | 가중치 기반 선택 |
| `ValidateAmount(int amount)` | 금액 | `bool` | 분해 가능 여부 검증 |

#### 유효 단위 배열 (내림차순)

```csharp
static readonly int[] ValidUnits = {
    2500000, 1000000, 500000, 250000, 100000, 50000,
    25000, 10000, 5000, 2500, 1000, 500
};
```

#### 가중치 전략

| GachaPriceCode | 가중치 방향 | 구현 |
|:--------------:|:----------:|------|
| 100 | 다단위(풍성) | 단위 수가 많은 조합에 높은 가중치 (units^2) |
| 1000 | 균등 | 모든 조합 동일 가중치 |
| 10000 | 소수단위(희소) | 단위 수가 적은 조합에 높은 가중치 (1/units^2) |

대형 당첨(100,000+): 최고 단가 단위 포함 조합에 추가 가중치 x3

### 2.5 유저 상태 관리 (DB)

#### NewGachaPatternAssignment 테이블

```sql
CREATE TABLE NewGachaPatternAssignment (
    GachaPriceCode INT NOT NULL,
    GachaPageGroup INT NOT NULL,
    GachaItemGroupCode INT NOT NULL,
    ClaimedByPlayerId BIGINT NULL,
    CurrentSlotIndex INT NOT NULL DEFAULT 0,
    ConsecutiveLossCount INT NOT NULL DEFAULT 0,
    ClaimedAt DATETIME NULL,
    PRIMARY KEY (GachaPriceCode, GachaPageGroup, GachaItemGroupCode),
    INDEX idx_claimed (GachaPriceCode, ClaimedByPlayerId)
);
```

#### Row 할당 쿼리 (Optimistic Claim)

```sql
UPDATE NewGachaPatternAssignment
SET ClaimedByPlayerId = @playerId,
    CurrentSlotIndex = 0,
    ConsecutiveLossCount = 0,
    ClaimedAt = NOW()
WHERE GachaPriceCode = @priceCode
  AND GachaPageGroup = @pageGroup
  AND ClaimedByPlayerId IS NULL
ORDER BY RAND()
LIMIT 1;
```

#### Row 해제 쿼리 (전체 슬롯 소진 시)

```sql
UPDATE NewGachaPatternAssignment
SET ClaimedByPlayerId = NULL,
    CurrentSlotIndex = 0,
    ConsecutiveLossCount = 0,
    ClaimedAt = NULL
WHERE GachaPriceCode = @priceCode
  AND GachaPageGroup = @pageGroup
  AND GachaItemGroupCode = @itemGroupCode
  AND ClaimedByPlayerId = @playerId;
```

#### 유저별 할당 조회 쿼리

```sql
SELECT * FROM NewGachaPatternAssignment
WHERE ClaimedByPlayerId = @playerId
  AND GachaPriceCode = @priceCode;
```

### 2.6 서버 기동 시 검증

서버 시작 시 다음을 순차 검증한다:

| 검증 항목 | 실패 시 처리 |
|-----------|-------------|
| Pattern값 분해 가능 여부 (양수값 전부) | ERROR 로그 + 해당 슬롯 0 처리 |
| RequiredClass별 아이템 수 >= 10 | WARNING 로그 |
| GachaItemPriceCode별 + RequiredClass별 >= 5 | WARNING 로그 |
| 유효 GachaItemPriceCode 12개 목록 대조 | ERROR 로그 + 해당 항목 스킵 |

---

## 3. 클라이언트 변경 상세

### 3.1 데이터 클래스 (클라이언트)

| 클래스 | 참조 원본 | 비고 |
|--------|----------|------|
| EodDataNewGachaPattern | EodDataShopGacha | DataPacking 동일 적용 |
| EodDataNewGachaItemGroup | EodDataShopGachaItemGroup | DataPacking 동일 적용 |

추가 테이블은 모두 DB에서 관리한다. 기존 Datasheets XML 시스템(클라+서버 공유)과 분리되며, 서버가 DB에서 로드하여 운영한다. 클라이언트는 필요한 정보만 Response로 전달받는다.

### 3.2 UI/연출 변경

> 기반: 장비뽑기연출기획서.pptx (Ver.0.2) — 2026-03-17 반영

변경 대상 파일 (추정):
- `EodUIGoodsShopGachaResultPopup.cs` — 결과 팝업
- `EodUIGoodsShopItemGacha.cs` — 뽑기 아이템 UI
- **신규 씬**: 뽑기 전용 씬 (마을과 분리)
- **신규 UI**: 마을 UI 뽑기 진입 버튼

#### 변경 내용

| 항목 | 기존 | 변경 |
|------|------|------|
| 진입 동선 | 상점 내 탭 | **마을 UI에 뽑기 진입 버튼 추가** → 전용 씬 전환 |
| 뽑기 씬 | 기존 상점 UI 내 | **별도 전용 씬** (캐릭터 모델링 + 가격대별 상자 3종 + 전용 배경) |
| 상자 개봉 | 없음 | **보물상자 등장→개봉→카드 배치** 3단계 연출 |
| 카드 조작 | 자동 공개 | **수동(선택 뒤집기) + 자동("모두 열기")** 양방향 |
| 짝 맞추기 | 없음 | **번개→강조 회전→결과 확정** 3단계 쌍 매칭 연출 |
| 결과 아이템 수 | 가변 | **고정 10개** |
| 보상/표시 구분 | 없음 | `equipmentItems`/`worthes`와 `gachaResult` 비교로 구분 |
| 등급별 이펙트 | 없음 | **장비 별(성) 등급별 RGB 색상 차별화** (1-3성 흰색 255,255,255 / 4-6성 초록 146,208,80 / 7-9성 파랑 0,176,240 / 10-11성 빨강 204,0,0) |
| 가격대별 상자 | 없음 | 100: 나무상자 / 1000: 은상자 / 10000: 금상자 + 연출 차등 |
| 결과 화면 | 기존 팝업 | **획득 팝업 + "한번 더"/"돌아가기" 버튼 전환** |
| Row 소진 연출 | 없음 | "새로운 패턴 시작" 연출 (Q5 확정: Phase 4-7 유지) |
| 진행률 표시 | 없음 | **미구현 결정** (Q7 확정, Phase 4-8 제거) |

#### 보상/필러 구분 로직 (클라이언트)

```
gachaResult[10] 순회:
  if (equipmentItems 또는 worthes에 동일 ItemCode 존재)
    → 보상 아이템 (하이라이트 연출 + 등급별 이펙트)
  else
    → 필러 아이템 (축소/페이드, 그레이아웃 없음 — Q3 확정)
```

#### Unity 에셋 활용 가능성

- 보물상자 개봉: Unity Asset Store 에셋 적용 또는 자체 제작
- 파티클 이펙트: 등급별 색상 파라미터화 (Shader/Material 분기)
- 카드 뒤집기: DOTween Sequence (Y축 0→90° 0.3초 + UISprite 교체 + 90→180° 0.3초, 총 0.6초) — 영상 레퍼런스 분석 기준

#### DOTween 정책 (2026-03-15 변경)
- **기존 코드**: UITweener 유지 (변경 없음)
- **신규 코드**: DOTween 사용 (2026-03-15 도입 확정)
- 도입 근거: 카드 뒤집기, 짝 맞추기 등 복잡한 연출 시퀀스에 DOTween Sequence가 적합

### 3.3 Phase 4 에셋 인벤토리

#### 기존 재활용 가능 에셋

| 에셋 | 유형 | 용도 |
|------|------|------|
| `ChangeSizeColor.cs` | 스크립트 | 짝 맞추기 글로우 이펙트 색상/크기 변경 |
| `DelayActive.cs` | 스크립트 | 이펙트 순서 제어 (번개→글로우 시퀀스) |
| `ObjectMove.cs` | 스크립트 | 카드 이동 애니메이션 (상자→그리드 배치) |
| `ef_CardBack_Circle.prefab` | 프리팹 | 카드 뒷면 이펙트 |
| `ef_Card_Charge.prefab` | 프리팹 | 카드 충전/당첨 이펙트 |
| `BuyGachaEvent.cs` | 스크립트 | 서버 통신 이벤트 (gachaType 필드 확인 후 재사용) |
| `EodUIGoodsShopGachaResultPopup.cs` | 스크립트 | 결과 팝업 (재사용 또는 NewGachaPattern용 분기 추가) |

#### 신규 제작 필요

| 에셋 | 유형 | 비고 |
|------|------|------|
| `GachaDrawScene.unity` | 씬 | Unity MCP (localhost:6400) 활용 + 빌드 세팅 추가 |
| `GachaCard.prefab` | 프리팹 | NGUI UISprite + TweenRotation Y축 180°, 상태: 대기/뒤집기/결과 |
| `EodUIGachaDrawScene.cs` | 스크립트 | FSM 메인 컨트롤러 (Idle→ChestOpen→CardLayout→WaitInput→CardFlip→MatchEffect→Result) |
| `EodUIGachaCard.cs` | 스크립트 | 카드 상태 관리 + UISprite 교체 (애니메이션 중간점 90°) |
| `EodUIGachaCardLayout.cs` | 스크립트 | 10장 UIGrid 배치 (2열 × 5장) |
| `EodUIGachaMatchEffect.cs` | 스크립트 | 동일 ItemCode 2장 감지 → ChangeSizeColor 글로우 + 번개 파티클 |
| 번개 파티클 Particle System | 이펙트 에셋 | 짝 매칭 번개 연출 × 1 (`GraphicResource/Fx/EffectMake/` 하위 배치) |

> **NGUI 컴포넌트 기준**: UI 애니메이션은 DOTween(신규) + UITweener(기존 재활용) 사용. Animator는 캐릭터/3D 전용 — 카드 UI에 사용 금지.

#### Fallback 에셋 (SB-3)

| 에셋 | 출처 | 적용 조건 |
|------|------|---------|
| Treasure Chest with Effects | Unity Asset Store (https://assetstore.unity.com/packages/3d/props/treasure-chest-with-effects-263013) | 상자 개봉 연출 직접 제작이 어려운 경우 대안 |

---

## 4. 기획 데이터 준비

### 4.1 DB 테이블

추가되는 테이블은 모두 DB에서 관리한다 (기존 Datasheets XML 시스템과 별도).

| 테이블 | 컬럼 | 비고 |
|--------|------|------|
| NewGachaPattern | GachaPriceCode, GachaPageGroup, GachaItemGroupCode, PatternCount, Pattern01~N | 가격대별 다수 row, 슬롯 수 가변 |
| NewGachaItemGroup | GachaItemPriceCode, ItemCode, RequiredClass | 12개 가격대 x N개 아이템 |
| NewGachaPatternAssignment | 복합키 + ClaimedByPlayerId + CurrentSlotIndex + ... | 유저별 할당 상태 |

> **기존 Item 테이블**: Datasheets XML(`ItemInfo.xml`)로 관리 (클라+서버 공유). 필러 등급 조회 시 `NewGachaItemGroup.ItemCode == Item.GeneralTypeCode` 조인 → `Item.ItemGrade` 참조.

### 4.2 ShopGacha 기존 테이블에 NewPattern 상품 추가

| 필드 | 값 |
|------|-----|
| generalTypeCode | 신규 할당 |
| gachaType | NewPattern (새 enum) |
| priceType | 기존 재화 타입 |
| price | 100 / 1000 / 10000 |
| pullCount | 1 |
| gachaGradeGroupCode | 미사용 (0 또는 -1) |

### 4.3 DB 스키마

NewGachaPatternAssignment 테이블 (섹션 2.5 참조) — DB 마이그레이션 스크립트 작성 필요

---

## 5. Response 매핑 전략

### 5.1 매핑 규칙

기존 BuyGacha.Response 구조를 변경하지 않고, 필드 의미를 NewGachaPattern 컨텍스트에 맞게 재해석한다.

| 시나리오 | equipmentItems | worthes | gachaResult | bonus* |
|---------|:-:|:-:|:-:|:-:|
| 꽝 (0) | null | null | Worth[10] 필러 | null |
| 당첨 (장비만) | EquipmentItem[N] 쌍 | null | Worth[10] 전체 | null |
| 당첨 (재화만) | null | Worth[N] 쌍 | Worth[10] 전체 | null |
| 당첨 (혼합) | EquipmentItem[] | Worth[] | Worth[10] 전체 | null |

### 5.2 gachaResult 조립

```
gachaResult = new Worth[10];
position = 0;
foreach (쌍 아이템):
    gachaResult[position++] = Worth(itemCode, count=2);
foreach (필러 아이템):  // 고등급(item.grade 7~11) 1~2개 + 일반 나머지
    gachaResult[position++] = Worth(itemCode, count=1);
// 셔플하여 보상 위치를 랜덤화 (연출 서스펜스)
Shuffle(gachaResult);
```

---

## 6. 에러 처리 매트릭스

| 에러 코드 | 발생 시점 | 조건 | 비용 처리 | 클라이언트 반응 |
|-----------|----------|------|:---------:|:-------------:|
| GameDatascriptDataIsNotExist | Row 할당 | 유효하지 않은 GachaPriceCode | 미차감 | 에러 팝업 |
| GachaSystemError | 분해 | 분해 불가 금액 | 미차감 | 에러 팝업 |
| GachaRowExhausted | Row 할당 | 모든 row 할당 완료 | 미차감 | "일시적으로 이용 불가" |
| GachaItemPoolInsufficient | 아이템 선정 | RequiredClass 매칭 부족 | 미차감 | 에러 팝업 |
| (정상) 소프트 피티 불발 | 피티 발동 | 남은 양수 슬롯 없음 | 정상 차감 | 꽝 표시 |

**비용 미차감 원칙**: 에러 시 PayCost 이전에 검증하거나, PayCost 후 에러 시 보상 롤백.

---

## 7. 테스트 전략

### 7.1 단위 테스트 (서버)

| 대상 | 테스트 항목 | 우선순위 |
|------|-----------|:--------:|
| DecompositionService.Decompose | 500~2,500,000 범위 분해 정확성 | **P0** |
| DecompositionService.Decompose | 분해 불가 금액 → empty 반환 | **P0** |
| DecompositionService.Decompose | Safety Cap 200 도달 시 결과 반환 | P1 |
| DecompositionService.SelectCombo | 가격대별 가중치 분포 검증 | P1 |
| DecompositionService.ValidateAmount | 전체 유효 단위 조합 검증 | P1 |
| ProcessNewGachaPattern | 꽝 → 필러 10개 반환 | **P0** |
| ProcessNewGachaPattern | 당첨 → 분해 → 쌍+필러 = 10개 | **P0** |
| ProcessNewGachaPattern | 전체 슬롯(PatternCount) 소진 → Row 해제 | P1 |
| SoftPity | 연속 꽝 10회 → 당첨 보장 | **P0** |
| SoftPity | 당첨 후 카운터 리셋 | P1 |
| AllocateNewRow | Optimistic Claim 동시성 | P1 |
| 쌍 간 중복 금지 | 같은 뽑기에서 서로 다른 ItemCode | P1 |

### 7.2 통합 테스트

| 시나리오 | 검증 포인트 |
|---------|-----------|
| 전체 슬롯 소비 사이클 | 할당 → PatternCount회 소비 → 해제 → 재할당 |
| 가격대별 뽑기 | 100/1000/10000 각각 정상 동작 |
| 동시 접속 Row 할당 | 2+ 유저 동시 할당 시 중복 없음 |
| 꽝→당첨 전환 | 소프트 피티 정상 발동 |
| Response 호환성 | 기존 클라이언트가 NewPattern 응답을 정상 파싱 |

### 7.3 데이터 검증 테스트

| 항목 | 검증 |
|------|------|
| Pattern값 분해 가능성 | 전체 DB 데이터의 양수값 전수 검증 |
| 아이템 풀 충족 | RequiredClass별 >= 10개 |
| GachaItemPriceCode 유효성 | 12개 유효 단위 외 값 없음 |

---

## 8. 기술 의사결정 (ADR 요약)

### ADR-1: BuyGacha 프로토콜 재사용

- **결정**: 기존 BuyGacha Request/Response를 변경 없이 재사용
- **근거**: 클라이언트 수정 최소화, 기존 이벤트/네트워크 레이어 재활용
- **트레이드오프**: Response 필드의 의미가 gachaType에 따라 달라짐 (문서화 필수)

### ADR-2: 실시간 분해 vs 사전 계산

- **결정**: 실시간 재귀 열거 (서버 측)
- **근거**: Safety Cap 200으로 성능 보장, 데이터 변경 시 재계산 불필요
- **트레이드오프**: 서버 CPU 소비 (미미), 매 뽑기마다 계산 (캐싱으로 완화 가능)

### ADR-3: 순차 소비 (01→N)

- **결정**: 랜덤이 아닌 순차 소비
- **근거**: 구현 단순 (int 1개), 경험 커브 설계 가능, 역공학 리스크 없음
- **트레이드오프**: 기획자의 패턴 배치 부담 증가 (의도적 설계 필요)

### ADR-4: DB 원자적 선점 (Optimistic Claim)

- **결정**: `UPDATE ... WHERE ClaimedByPlayerId IS NULL LIMIT 1`
- **근거**: 기존 서버의 세션 기반 직렬화에 추가 안전망, 추가 락 불필요
- **트레이드오프**: 할당 쿼리 실패 시 재시도 필요 (드문 케이스)

---

## 9. 구현 순서 (권장)

```
Phase 1: 데이터 레이어 (독립 작업)
  ├─ 1-1. NewGachaPattern Data/Table/Loader 클래스
  ├─ 1-2. NewGachaItemGroup Data/Table/Loader 클래스
  ├─ 1-3. DB 마이그레이션 (NewGachaPatternAssignment)
  └─ 1-4. ShopGacha에 NewPattern enum + 상품 데이터 추가

Phase 2: 핵심 로직 (Phase 1 의존)
  ├─ 2-1. DecompositionService (분해 알고리즘 + 가중치 선택)
  ├─ 2-2. 서버 기동 검증 로직
  └─ 2-3. 분해 알고리즘 단위 테스트

Phase 3: 서비스 통합 (Phase 1+2 의존)
  ├─ 3-1. BuyGachaService에 NewPattern 분기 추가
  ├─ 3-2. ProcessNewGachaPattern 구현 (할당/소비/피티/응답)
  └─ 3-3. 통합 테스트

Phase 4: 클라이언트 (Phase 3 의존) — 연출 기획서 반영 확장

  ### Phase 4 태스크 의존성 그래프

  Wave 1 (서버, 독립 병렬):
    4-1 (서버 패턴 로직) ────────────────┐
    4-2 (분해 로직) ─────────────────────┤
    4-3 (Spec 작성) ─────────────────────┤

  Wave 2 (서버 완료 후):
    └─→ 4-6 (Row 소진 연출 서버) ────────┐
        4-7 (Row 소진 통합 테스트) ←──── 4-6

  Wave 3 (클라이언트, 서버 독립):
    G-1 (상자 개봉) ───┐
    G-2 (카드 배치) ───┤
    G-3 (카드 뒤집기)──┤  ← Wave 3 병렬 가능
    G-10 (마을 UI) ────┘

  Wave 4 (G-3 완료 후):
    └─→ G-4 (등급 이펙트) ────┐
        G-5 (짝 맞추기) ───────┤  ← Wave 4 병렬 가능
        G-6 (랜덤 오픈) ────────┤
        G-7/G-8 (버튼 교체) ────┘

  Wave 5 (Wave 4 완료 후):
    └─→ G-9 (스페셜 상자)

  Wave 6 (최종 통합):
    └─→ 4-8 (클라이언트 통합 테스트)
        4-9 (전체 E2E 테스트)

  ### Phase 4 서버 태스크 (기존)

  | 태스크 | 설명 | Wave | SP |
  |:------:|------|:----:|:--:|
  | 4-1 | 서버 패턴 로직 | Wave 1 | 3 |
  | 4-2 | 분해 로직 | Wave 1 | 2 |
  | 4-3 | Spec 작성 | Wave 1 | 1 |
  | 4-6 | Row 소진 연출 서버 | Wave 2 | 2 |
  | 4-7 | Row 소진 통합 테스트 | Wave 2 | 1 |
  | 4-8 | 클라이언트 통합 테스트 | Wave 6 | 2 |
  | 4-9 | 전체 E2E 테스트 | Wave 6 | 0 (4-8에 포함) |

  > **Q&A 확정 사항 (2026-03-17)**: Q1=꽝 연출 단순화(텍스트+효과음), **Q2=별(성) 등급별 RGB 이펙트(v0.2 확정: 1-3성 흰/4-6성 초록/7-9성 파랑/10-11성 빨강)**, Q3=필러 그레이아웃 없음, Q4=짝 즉시 연출 후 계속, Q5=Row 소진 연출 유지, Q6=스페셜 상자 이분 연출, **Q7=진행률 표시 미구현(Phase 4-8 제거)**

  ### Phase 4 클라이언트 연출 구현 태스크 (신규, G-1~G-10)

  | 태스크 | 설명 | Wave | SP | 근거 |
  |:------:|------|:----:|:--:|------|
  | G-1 | 상자 개봉 연출 (줌인+광원+플래시) | Wave 3 | 5 | G-1 기획서 갭 |
  | G-2 | 카드 10장 분출 → 2x5 그리드 배치 | Wave 3 | 5 | G-2 기획서 갭 |
  | G-3 | 카드 뒤집기 (Y축 90° 중간점 UISprite 교체, 총 0.6초) | Wave 3 | 3 | G-3, 영상 레퍼런스 (YouTube KKB...) |
  | G-4 | 등급별 이펙트 차등 (**별(성) 등급별 RGB**: 1-3성 흰색/4-6성 초록/7-9성 파랑/10-11성 빨강, Q2 v0.2 확정) | Wave 4 | 3 | G-4, Q2 확정 |
  | G-5 | 짝 맞추기 번개+글로우+진동 (카드 뒤집기 완료 시점마다 즉시 판정, SB-5+Q4 확정) | Wave 4 | 3 | G-5, Q3/Q4 확정 |
  | G-6 | "모두 열기" 랜덤 순서 오픈 (Fisher-Yates 셔플, SB-4 확정) | Wave 4 | 1 | G-6, SB-4 확정 |
  | G-7 | "모두 열기"→"상점 가기" 버튼 교체 (SB-7) | Wave 4 | 1 | G-7, SB-7 확정 |
  | G-8 | "한번 더" 버튼 초기 숨김→완료 후 표시 (SB-6) | Wave 4 | 1 | G-8, SB-6 확정 |
  | G-9 | 스페셜 상자 강화 연출 (일반 vs 스페셜 이분 binary, Q6 확정) | Wave 5 | 3 | G-9, Q6 확정 |
  | G-10 | 마을 하단 UI 개편 (좌측: 상점/가방/거래소/우편함/아바타/조력자, 우측: 뽑기/도전, SB-1 v0.2) | Wave 3 | 3 | G-10, SB-1 확정 |

  > G-3 카드 뒤집기 타이밍: 총 0.6초 (0→90° 0.3초 + 90→180° 0.3초). 영상 레퍼런스 `docs/assets/video-refs/2026-03-15-gacha-card-flip-reference-analysis.md` 참조.
  > G-5 짝 맞추기: 전체 공개 후 일괄 판정이 아닌 카드 뒤집기 완료 시마다 실시간 판정. 수동+자동("모두 열기") 모두 동일 적용.
  > G-6 자동 오픈: Q4 확정 — 짝 발견 즉시 연출 → 연출 후 계속 진행.
  > G-10 뽑기 상점 진입: 기존 상점 UI 재사용 (SB-2).

  **Phase 4 총 예상 공수: 38 SP**

  ├─ 4-1. 마을 UI 개편 (뽑기 진입 버튼 추가) — 3 SP → G-10으로 대체
  ├─ 4-2. 뽑기 전용 씬 신규 구성 (캐릭터 모델링 + 가격대별 상자 + 전용 배경)
  ├─ 4-3. 상자 개봉 연출 (등장→개봉→카드 배치, 에셋 적용) — G-1로 구체화
  ├─ 4-4. 카드 배치 + 수동/자동 조작 UI (10장 뒤집기 + "모두 열기" 버튼) — G-2/G-3으로 구체화
  ├─ 4-5. 짝 맞추기 연출 (번개→강조 회전→결과 확정 3단계) — G-5로 구체화
  ├─ 4-6. 등급별 이펙트 색상 시스템 (7성~11성, Shader/Material 파라미터화) — G-4로 구체화
  ├─ 4-7. Row 소진 연출 ("새로운 패턴 시작", Q5 확정)
  ├─ 4-8. 클라이언트 통합 테스트 — **진행률 표시(37/N) 미구현(Q7 확정으로 제거)**
  └─ 4-9. 클라이언트 데이터 클래스 (DataPacking)

Phase 5: QA & 데이터 (Phase 3+4 병렬 가능)
  ├─ 5-1. DB 데이터 작성 (기획)
  ├─ 5-2. 데이터 검증 테스트
  └─ 5-3. 전체 통합 QA
```

---

## 10. 참조 파일 인덱스

| 용도 | 경로 (GodBlade src 기준) |
|------|------------------------|
| BuyGacha 프로토콜 | `common/EodGameCommon/Protocol/Game/BuyGacha.cs` |
| BuyGachaService | `server/EodGameServer/Service/BuyGachaService.cs` |
| ItemGenerator (참조) | `server/EodGameServer/Generator/ItemGenerator.cs` |
| ShopGacha Data (참조) | `client/Assets/Scripts/GameDatascript/Data/EodDataShopGacha.cs` |
| ShopGachaItemGroup Data (참조) | `client/Assets/Scripts/GameDatascript/Data/EodDataShopGachaItemGroup.cs` |
| 뽑기 UI (참조) | `client/Assets/Scripts/UI/Shop/EodUIGoodsShopItemGacha.cs` |
| 결과 팝업 (참조) | `client/Assets/Scripts/UI/Shop/EodUIGoodsShopGachaResultPopup.cs` |
| S3 기획서 | `docs/planning/active/sigil/gacha-system-design.md` (symlink) |
| 이해도 리포트 | `docs/reviews/2026-03-06-gacha-workflow-understanding-report.md` |

### 데이터 관리 체계

| 구분 | 관리 방식 | 경로/도구 |
|------|----------|----------|
| 기존 테이블 (Item, ShopGacha 등) | Datasheets XML → 도구 변환 | `Godblade/Datasheets/*.xml` → `EodGameDatascriptGenerator` |
| 추가 테이블 (NewGachaPattern, NewGachaItemGroup, NewGachaPatternAssignment) | **DB 직접 관리** | 서버 기동 시 DB 로드 → 메모리 캐싱 |
| 필러 등급 조회 | DB → Datasheets 조인 | `NewGachaItemGroup.ItemCode == Item.GeneralTypeCode` → `Item.ItemGrade` |

### 개발 도구 (Godblade/Program/Tools/)

| 도구 | 용도 | NewGachaPattern 관련 |
|------|------|:-------------------:|
| **EodGameDatascriptGenerator** | XML Datasheet → SCSV/MySQL/XML + C# 소스 자동 생성 | 기존 테이블 참조 시 |
| **EodClassCreator** | DB 테이블 → C# 클래스 자동 생성 (Dapper) | DB 테이블 생성 후 Data 클래스 생성 후보 |
| **NameLoader** | Global DB 이름 데이터 로드 (운영 도구) | 무관 |
| EodTestClientCore/WinForm | 테스트 클라이언트 | 미사용 (빈 프로젝트) |

---

*Last Updated: 2026-03-17 — v0.2 반영: 짝 맞추기 이펙트 별(성) 등급별 RGB 확정(Q2), 기획서 버전 Ver.0.2, G-4 태스크 설명 업데이트*
