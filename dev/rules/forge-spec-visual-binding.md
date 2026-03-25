# Spec 비주얼 바인딩 룰 (Spec-Visual Binding)

> UI/연출/에셋이 포함된 기능의 Spec 작성 시, 기획서·시안·영상 분석·디자인 가이드를 **구체적 수치로 변환하여 FR에 직접 바인딩**한다.
> 추상적 서술로 인한 구현 괴리를 방지하는 강제 규칙.

## 배경 (Why)

디자인 가이드/시안이 시안 생성 단계에서만 참조되고 Spec·구현 단계에서 끊기면, 구현물이 기획 의도와 크게 괴리된다.

```
[문제] 끊어진 흐름:
  디자인 가이드 → 시안 생성 (참조됨)
                      ↓
                Spec 작성 (미참조) → 추상적 서술 → 구현 괴리

[해결] 연결된 흐름:
  디자인 가이드 ──→ 시안 생성
        ↓                ↓
    Spec 작성 ←── 시안+가이드 1:1 바인딩 (구체적 수치)
        ↓
    코드 구현 ←── Spec의 디자인 토큰/파라미터 직접 참조
```

## 적용 범위

UI/연출/에셋이 포함된 모든 Spec에 적용한다.

| Spec 유형 | 적용 |
|----------|:----:|
| UI 신규 화면 (가챠, 상점, 인벤토리 등) | **필수** |
| 연출/애니메이션 (DOTween, ParticleSystem 등) | **필수** |
| AI 에셋 생성이 필요한 기능 | **필수** |
| 서버 전용 (프로토콜, DAO 등) | 해당 없음 |

---

## A. 디자인 가이드 → Spec 연결

### A-1. 디자인 가이드 참조 필수

시안 생성에 사용된 디자인 가이드(컬러 팔레트, 타이포그래피, 간격 규칙, 컴포넌트 스타일)가 있으면 Spec에 반드시 참조 경로와 적용 항목을 기재한다.

```markdown
## 디자인 가이드 참조
| 가이드 | 경로 | 적용 항목 |
|--------|------|----------|
| GodBlade UI Style Guide | `forge-outputs/.../style-guide.md` | 컬러 팔레트, 버튼 스타일 |
| 가챠 아트 디렉션 | `_assets/art-direction-brief.md` | 카드 디자인, 이펙트 스타일 |
```

### A-2. 디자인 토큰 추출

디자인 가이드에서 구현에 필요한 구체적 수치를 Spec의 **"디자인 토큰"** 섹션으로 추출한다.

```markdown
## 디자인 토큰
| 토큰 | 값 | 출처 |
|------|-----|------|
| color-grade-1-3 | RGB(255,255,255) | 기획서 S12 |
| color-grade-4-6 | RGB(146,208,80) | 기획서 S12 |
| card-back-border | 금색 #C8A23C | 시안 p2-02 분석 |
| card-flip-duration | 0.6s (0.3+0.3) | 영상 분석 0:15 |
| font-item-name | 16px, ShrinkContent | v0.2 S10 |
```

### A-3. 디자인 가이드 부재 시

디자인 가이드 문서가 없으면 시안 이미지를 분석(`/screenshot-analyze`)하여 컬러/레이아웃/스타일 규칙을 추출하고 Spec에 명시한다.

---

## B. 기획서 ↔ Spec 1:1 바인딩

### B-1. 기획서 슬라이드 매핑 필수

각 FR에 기획서 슬라이드 번호와 해당 슬라이드의 **구체적 요소**를 명시한다.

```markdown
| FR-ID | 기능 | 기획서 | 기획서 요소 |
|:-----:|------|:------:|-----------|
| FR-06 | 카드 뒷면 | v0.2 S9 | 금색 테두리+파란 보석+방사형 금선 |
| FR-12 | 번개 이펙트 | v0.2 S11, S12 | 등급별 색상 번개, RGB 4단계 |
```

### B-2. 시안 이미지 바인딩 필수

`_assets/` 시안 이미지가 있으면 각 FR에 이미지 경로와 **"이 이미지의 어떤 요소가 이 FR을 정의하는지"**를 기술한다.

```markdown
| FR-ID | 시안 이미지 | 참조 요소 |
|:-----:|-----------|----------|
| FR-06 | `_assets/p2-02-card-grid.png` | 카드 뒷면 디자인: 금색 장식 프레임, 중앙 다이아몬드 |
| FR-12 | `_assets/p3-03-effect-blue.png` | 7-9성 번개: 파란 번개볼트 + 파란 글로우 |
```

---

## C. 비주얼 명세 구체화

### C-1. 추상적 서술 금지

| 금지 (추상적) | 필수 (구체적) |
|-------------|-------------|
| "금색 톤" | RGB(200,162,60), 스프라이트 `box_02`, color=(0.78,0.63,0.23,1) |
| "화려한 이펙트" | 파티클 30개, 수명 0.5초, StartColor=등급RGB, StartSize=0.3 |
| "적절한 크기" | width=140, height=180, depth=50 |
| "부드러운 애니메이션" | DOTween EaseOutSine, duration=0.3s, delay=0.1s |
| "기존 UI와 동일" | `EodUIInventory.CreateSlot()` 패턴 재사용 (line 234-280) |

### C-2. 영상 분석 → 구현 파라미터 변환

영상 분석의 타임스탬프를 DOTween/UITweener 파라미터로 변환하여 Spec에 포함한다.

### C-EXT. 분석 도구 → Element Task Doc 자동 변환 규칙

> 분석 도구 호출 시 Element Task Doc 작성 중이면 "Task Doc 모드"를 자동 적용한다.

**분석 도구 → Task Doc 섹션 매핑:**

| 분석 도구 | Task Doc 모드 출력 | 대상 섹션 |
|----------|-------------------|----------|
| `/video-reference-guide` | 타임라인 + 트윈 파라미터 테이블 | Section 3, 4, 16 |
| `/screenshot-analyze` | Prefab 계층 + 디자인 토큰 테이블 | Section 7, 10, 16 |
| PPTX 스킬 (Spec 바인딩 모드) | 슬라이드별 시각 요소 매핑 | Spec B-1, B-2, A-2 |

**에셋 생성 시 Element Task Doc 참조:**

| 도구 | 참조 대상 | 주입 위치 |
|------|----------|----------|
| `/game-asset-generate` | Section 17 에셋 목록 | Step 2-EXT 생성 대상 설정 |
| `/soul-prompt-craft` | Section 10 디자인 토큰 | slot [6] palette (style-guide보다 우선) |

```markdown
## 애니메이션 파라미터
| 연출 | 영상 타임 | DOTween 파라미터 |
|------|---------|----------------|
| 상자 등장 | 0:10~0:12 | DOScale(0→1.2, 0.5s, EaseOutBack) |
| 카드 플립 | 0:15~0:17 | DOLocalRotate Y 0→90(0.3s, InOutSine) → 90→180(0.3s) |
| 번개 | 0:32~0:38 | DOFade 0→1→0(0.1s × 3회) + DOScale(1→1.5, 0.5s) |
```

---

## D. 에셋 파이프라인

### D-1. 에셋 생성 명세 섹션 필수

AI 생성이 필요한 에셋은 아래 형식으로 Spec에 포함한다.

```markdown
## 에셋 생성 명세
| 에셋 | 크기 | 스타일 레퍼런스 | 디자인 토큰 | 생성 프롬프트 요약 |
|------|------|---------------|-----------|----------------|
| 카드 뒷면 | 512x768 | `_assets/p2-02` | card-back-border | 금색 장식 프레임+파란 보석+방사형 금선, 중세 판타지 |
```

### D-2. 스타일 레퍼런스 체인

에셋 생성 시 디자인 가이드 → 시안 이미지 → soul prompt 순으로 스타일이 전달되도록 체인을 구성한다.

---

## D-EXT. Element Task Doc 분리 기준 (Split Criteria)

> Spec 9.5(UI 상태) / 9.9(연출/이펙트)의 개별 요소가 아래 기준에 해당하면 별도 Element Task Doc으로 분리한다.

### 분리 판정 기준

| 기준 | Simple (Spec 내 유지) | Complex (Task Doc 분리) |
|------|---------------------|----------------------|
| 파라미터 수 | 5개 이하 | 6개+ |
| 분기 조건 | 없음 (단일 경로) | 등급/상태별 분기 있음 |
| 파티클+사운드 동기화 | 없음 | 있음 |
| 타임라인 스텝 | 3 이하 | 4 스텝+ |
| UI 상태 수 | 2 이하 (표시/숨김) | 3+ (로딩/에러/빈/활성/비활성) |

> **하나라도** Complex에 해당하면 분리를 검토한다. 판정이 모호하면:
> - 밀접하게 결합된 요소 → 같은 Task Doc에 묶는다
> - 독립적이지만 단순한 요소 → Spec 내 유지
> - AI가 판정을 제안하되, Human이 최종 승인한다

### 문서 체계

```
Feature Spec (spec-template-game.md)
  ├── Section 9.5 UI 상태 — Simple 요소 직접 정의 + Complex 요소 링크
  ├── Section 9.9 연출/이펙트 — Simple 요소 직접 정의 + Complex 요소 링크
  └── Element Task Doc (element-task-template-game.md)
        └── .specify/element-tasks/{spec-name}/{element-name}.md
```

### 참조 문서

| 문서 | 경로 | 역할 |
|------|------|------|
| Element Task Doc 템플릿 | `forge/dev/templates/element-task-template-game.md` | 요소별 상세 명세 작성용 |
| 구현 가이드 | `forge/shared/docs/forge-direction-ui-implementation-guide.md` | Unity 구현 패턴 참조 |

---

## E. 검증 게이트

### E-1. Spec 비주얼 검증 (Phase 2 승인 전)

Spec 승인([GATE 1]) 전에 다음을 확인한다:

| 체크 항목 | 방법 |
|----------|------|
| 모든 UI FR에 기획서 슬라이드 번호가 매핑되었는가? | 매핑 테이블 확인 |
| 모든 시안 이미지가 FR에 바인딩되었는가? | 바인딩 테이블 확인 |
| 추상적 서술이 없는가? ("금색 톤" 등) | Spec 텍스트 검색 |
| 디자인 토큰이 추출되었는가? | 토큰 테이블 확인 |
| 영상 분석이 구현 파라미터로 변환되었는가? | 파라미터 테이블 확인 |
| 에셋 생성 명세가 있는가? (AI 에셋 필요 시) | 에셋 테이블 확인 |
| Complex 판정 요소에 Element Task Doc이 작성되었는가? | Spec 9.5.6 / 9.9.9 분리 기준표 확인 |
| Element Task Doc이 상위 Spec을 정확히 참조하는가? | Task Doc Section 1.3 참조 경로 확인 |
| `_assets/` 시안이 있는 FR의 Element Task Doc에 시안 바인딩(16-1)이 작성되었는가? | 시안 바인딩 테이블 확인 |
| 시안 바인딩의 모든 값이 `(확정)` 태그인가? | `(추정)` 잔존 여부 확인 |

---

## AI 에이전트 행동 규칙

1. UI/연출 기능의 Spec 작성 시 이 룰을 **자동 적용**한다
2. 기획서(pptx/pdf)가 있으면 슬라이드를 읽고 FR에 매핑한다
3. `_assets/` 시안이 있으면 이미지를 분석하고 FR에 바인딩한다
4. 디자인 가이드가 있으면 토큰을 추출한다. 없으면 시안에서 역추출한다
5. 추상적 서술을 발견하면 구체적 수치로 변환한다
6. Spec 승인 전 E-1 검증 게이트를 실행한다
7. Spec 9.5/9.9 작성 시 각 요소의 복잡도를 D-EXT 기준으로 판정하고, Complex 요소는 Element Task Doc 분리를 제안한다
8. Element Task Doc 작성 시 `element-task-template-game.md` 템플릿을 사용하고, 상위 Spec 경로(Section 1.3)를 반드시 기재한다
9. Element Task Doc 작성 중 분석 도구(`/video-reference-guide`, `/screenshot-analyze`) 호출 시 **Task Doc 모드를 자동 적용**한다 (C-EXT 참조)
10. 에셋 생성(`/game-asset-generate`, `/soul-prompt-craft`) 시 해당 기능의 Element Task Doc이 있으면 **Section 10(디자인 토큰)과 Section 17(에셋 목록)을 참조**한다
11. `_assets/` 시안이 존재하는 기능의 Element Task Doc 작성 시, **Section 16-1 시안 바인딩을 필수로 작성**한다
12. 시안 분석 시 `/screenshot-analyze --mockup` 모드를 사용하여 **확정값으로 추출**한다 (추정값 금지)

---

*Last Updated: 2026-03-25*
