# GodBlade 기존 시스템 분석 레퍼런스

> 기존 GodBlade 클라이언트 시스템 분석 결과를 기획단(forge) + 구현단(src) 양쪽에서 참조할 수 있도록 정리한 레퍼런스.
> 신규 기능 Spec 작성 시 "기존 시스템 재사용" 섹션에서 이 문서들을 참조한다.

---

## systems/ — 코드/로직 시스템 분석

| 파일 | 설명 | 분석일 | 상태 |
|------|------|:------:|:----:|
| [gacha-system.md](systems/gacha-system.md) | 가챠 시스템 (상점 UI, 결과 팝업, 아이템 로딩) | 2026-03-19 | 완료 |
| inventory-system.md | 인벤토리 (장비 장착, 분해, 강화) | — | 미작성 |
| shop-system.md | 상점 UI (패키지, 월정액, 재화) | — | 미작성 |
| scene-transition.md | 씬 전환 (EodSceneManager, TableEnum) | — | 미작성 |
| network-protocol.md | 네트워크 통신 (BuyGacha, 패킷 구조) | — | 미작성 |
| ui-common-patterns.md | UI 공통 패턴 (UITexture, Addressable, NGUI) | — | 미작성 |
| sound-system.md | 사운드 매니저 (BGM, Effect, UI) | — | 미작성 |
| grade-color-system.md | 등급/색상/배경 시스템 (ItemGradeColor, BackgroundGradeName) | — | 미작성 |

## assets/ — 에셋 카탈로그

| 파일 | 설명 | 분석일 | 상태 |
|------|------|:------:|:----:|
| [resource-path-map.md](assets/resource-path-map.md) | ResourcesBundle 전체 경로 맵 | 2026-03-20 | 완료 |
| [icon-catalog.md](assets/icon-catalog.md) | Icon 폴더별 에셋 목록 + 네이밍 규칙 | 2026-03-20 | 완료 |
| [ui-prefab-catalog.md](assets/ui-prefab-catalog.md) | UI 프리팹 목록 (Shop, Common, Inventory 등) | 2026-03-20 | 완료 |
| [sound-catalog.md](assets/sound-catalog.md) | Sound 에셋 목록 + 포맷 | 2026-03-20 | 완료 |
| effect-catalog.md | Effect/ParticleSystem 목록 | — | 미작성 |

## screenshots/ — Unity MCP 스크린샷

Unity MCP `EditorWindow_CaptureScreenshot`으로 촬영한 런타임 스크린샷.
네이밍: `{날짜}-{시스템명}-{설명}.png`

---

## 순환 체계: 분석 → 사용 → 반영 → 재사용

이 레퍼런스는 일회성 문서화가 아니다. **모든 추가/변경 작업에 적용**되는 순환 사이클이다.

```
┌─ 1. 분석 (Analyze) ──────────────────────────────────────────┐
│  작업 시작 전 관련 시스템/에셋을 분석하여 레퍼런스 생성/확인  │
└──────────────────────────┬────────────────────────────────────┘
                           ▼
┌─ 2. 사용 (Use) ──────────────────────────────────────────────┐
│  기획(SIGIL) / Spec(Phase 2) / 구현(Phase 3) 에서 참조       │
└──────────────────────────┬────────────────────────────────────┘
                           ▼
┌─ 3. 반영 (Reflect) ─────────────────────────────────────────┐
│  작업 완료 후 추가/변경된 결과물을 분석 문서에 반영           │
│  (신규 클래스, 프리팹, 에셋, 경로 → 해당 카탈로그 갱신)      │
└──────────────────────────┬────────────────────────────────────┘
                           ▼
┌─ 4. 재사용 (Reuse) ─────────────────────────────────────────┐
│  다음 작업에서 갱신된 레퍼런스를 자동으로 참조 → 1로 돌아감  │
└──────────────────────────────────────────────────────────────┘
```

**거버넌스 규칙**: `src/.claude/rules/system-analysis-cycle.md`에 AI 행동 규칙으로 강제.

---

## 분석 프로세스 가이드

### 신규 시스템 분석 워크플로우

```
1. Unity Editor에서 해당 기능 실행 (게임 플레이)
2. Unity MCP로 런타임 분석:
   - EditorWindow_CaptureScreenshot → screenshots/
   - ManageGameObject find → 활성 오브젝트 계층
   - RunCommand → 컴포넌트 상세 (UITexture, UILabel, 값 등)
3. 소스코드 정적 분석 (Grep/Read):
   - 핵심 클래스/메서드 식별
   - 호출 패턴 정리
4. 분석 결과를 systems/ 또는 assets/에 저장
5. Spec 작성 시 "기존 시스템 재사용" 섹션에 경로 참조
```

### 작업 완료 후 반영 워크플로우

```
1. 추가/변경된 클래스, 메서드 → systems/ 해당 문서에 추가
2. 추가/변경된 프리팹 → assets/ui-prefab-catalog.md 갱신
3. 추가/변경된 아이콘/이미지 → assets/icon-catalog.md, resource-path-map.md 갱신
4. 추가/변경된 사운드 → assets/sound-catalog.md 갱신
5. 신규 문서 생성 시 → README.md 인덱스에 추가
```

### 분석 문서 템플릿

```markdown
# {시스템명} 시스템 레퍼런스

> 분석일: YYYY-MM-DD | 분석 방법: Unity MCP 런타임 + 정적 분석
> 관련 Spec: {spec 경로}

## 1. 런타임 구조 (Unity MCP 실측)
## 2. 핵심 클래스/메서드
## 3. 호출 패턴 (복붙 가능한 코드)
## 4. 리소스 경로
## 5. 신규 기능 적용 가이드
## 6. 금지 사항
```

### Spec에서 참조하는 방법

Spec 문서의 "기존 시스템 재사용" 섹션에서 아래 형식으로 참조:

```markdown
> 런타임 실측 레퍼런스: `forge-outputs/project/godblade/systems/{시스템명}.md`
```

### 에셋 재사용 판단 흐름

```
신규 기능에 에셋 필요
  → assets/ 카탈로그에서 기존 에셋 검색
  → 있음: 재사용 (경로+네이밍 확인)
  → 없음: 신규 제작 필요
    → 기존 네이밍 규칙 준수 (icon-catalog.md 참조)
    → 기존 리소스 경로에 배치 (resource-path-map.md 참조)
```

### 에셋 유형별 기존 규격

| 유형 | 포맷 | 크기 | 경로 |
|------|------|------|------|
| 장비 아이콘 | .psd | 128x128 | `Icon/EquipItem/` |
| 소비 아이콘 | .psd | 128x128 | `Icon/Item/` |
| 등급 배경 | .psd | 150x196 | `Image/` |
| UI 프리팹 | .prefab | — | `UI/{카테고리}/` |
| 사운드 | .wav/.ogg | — | `Sound/{카테고리}/` |
| 이펙트 | .prefab | — | `Effect/{카테고리}/` |

---

*Last Updated: 2026-03-20*
