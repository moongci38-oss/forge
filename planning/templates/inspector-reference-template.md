# Inspector Reference Sheet — {PROJECT_NAME}

> AI가 UI/연출/이펙트 코드 작성 시 참조하는 검증된 Inspector 값 데이터베이스.
> Human이 에디터에서 교정한 값만 기록한다. AI 추정값은 기록하지 않는다.

## 사용법

1. AI가 Spec/코드 작성 시 이 시트에서 유사한 컴포넌트 값을 복사하여 시작
2. Human이 에디터에서 실행 후 교정값을 이 시트에 커밋
3. 교정 이력은 Git log로 추적

---

## 1. 캔버스/해상도 기준

| 항목 | 값 | 비고 |
|------|-----|------|
| Canvas Scaler | | (ConstantPixelSize / ScaleWithScreenSize / ConstantPhysicalSize) |
| Reference Resolution | | (예: 1920×1080) |
| Screen Match Mode | | (MatchWidthOrHeight 등) |
| Match | | (0=Width, 1=Height, 0.5=Both) |
| Safe Area 적용 | | (Yes/No) |

---

## 2. UI 컴포넌트 레퍼런스

### 템플릿

| 컴포넌트 | Anchor Preset | Pivot | Size (W×H) | Position (X,Y) | 비고 |
|---------|:------------:|:-----:|:----------:|:--------------:|------|
| {컴포넌트명} | | | | | |

---

## 3. 연출/애니메이션 레퍼런스

### 템플릿

| 연출명 | 타입 | Duration | Ease | From → To | Delay | 비고 |
|-------|------|:--------:|:----:|:---------:|:-----:|------|
| {연출명} | Scale/Fade/Move/Rotate | | | | | |

---

## 4. 파티클/이펙트 레퍼런스

### 템플릿

| 이펙트명 | Duration | Start Color | Start Size | Start Speed | Max Particles | 비고 |
|---------|:--------:|:-----------:|:----------:|:-----------:|:-------------:|------|
| {이펙트명} | | | | | | |

---

## 5. 폰트/텍스트 레퍼런스

| 용도 | Font | Size | Color (Hex) | Alignment | 비고 |
|------|------|:----:|:-----------:|:---------:|------|
| {용도} | | | | | |

---

## 6. 사운드 타이밍 레퍼런스

| 사운드명 | 트리거 시점 | Volume | Delay | 비고 |
|---------|:----------:|:------:|:-----:|------|
| {사운드명} | | | | |

---

## 교정 규칙

- **AI 추정값 기록 금지** — Human이 에디터에서 확인한 값만 기록
- **교정 시 커밋 메시지**: `docs: update inspector reference — {컴포넌트/연출명}`
- **삭제 대신 취소선** — 이전 값은 ~~취소선~~으로 보존 (히스토리)
- **등급/등급별 분기** — 같은 컴포넌트도 등급에 따라 값이 다르면 행 분리

---

*Template Version: 1.0 | Last Updated: {DATE}*
