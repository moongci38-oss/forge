# 인수인계: PGE Rules 통합 + GodBlade 애니메이션 시스템 정리

**날짜**: 2026-04-07  
**작업 범위**: forge PGE SKILL.md + GodBlade reference/rules 문서

---

## 1. PGE SKILL.md 변경 (`~/forge/.claude/skills/pge/SKILL.md`)

### 핵심 변경

**문제**: PGE subagent는 main session의 `.claude/rules/` 파일을 자동 상속하지 않음.  
**해결**: 각 Phase에 rules 파일 직접 Read 단계 추가 + rules→reference 체이닝 방식 도입.

### Phase별 추가된 Rules 로딩

| Phase | 추가된 Rules 파일 |
|-------|-----------------|
| **Planner** | `system-analysis-cycle.md`, `pre-modification-analysis.md`, (UI 시) `forge-spec-visual-binding.md` |
| **Generator** | `pre-modification-analysis.md`, `verification-integration.md`, `forge-walkthrough.md`, (영상 시) `video-reference-workflow.md` |
| **Evaluator** | `verification-integration.md` |

### Reference 로딩 방식 변경

- **이전**: SKILL.md에 태스크 유형별 reference 파일 목록 표 관리
- **이후**: rules 파일이 reference 파일 포인터를 포함 → rules 읽으면 체이닝으로 reference 도달

| rules 파일 | 체이닝되는 reference 파일 |
|-----------|------------------------|
| `pre-modification-analysis.md` | `pre-modification-analysis-detail.md`, `key-file-map.md`, `code-snippets.md` |
| `video-reference-workflow.md` | `video-reference-workflow-detail.md` |
| `pge-game-evaluator-rubric.md` | `pge-game-evaluator-rubric-detail.md` |

### 중간 파일 경로 고정

모든 PGE 중간 파일은 `{project_root}/.claude/state/`에 저장.

| 파일 | 경로 |
|------|------|
| `PGE_SPEC.md` | `.claude/state/PGE_SPEC.md` |
| `PGE_SELF_CHECK.md` | `.claude/state/PGE_SELF_CHECK.md` |
| `PGE_QA_RESULT.md` | `.claude/state/PGE_QA_RESULT.md` |
| `PGE_QA_REPORT.md` | `.claude/state/PGE_QA_REPORT.md` |

---

## 2. GodBlade Reference 파일 변경 (`.claude/reference/`)

### `key-file-map.md`

- 가챠 결과 파일 2종 추가:
  - `EodUIGoodsShopGachaResultPopup.cs` (코루틴+Animator 방식)
  - `EodUIGoodsShopGachaResultIcon.cs` (코루틴+Animator 방식)
- **애니메이션 방식** 컬럼 추가 — 파일별 방식 명시

### `code-snippets.md`

- 헤더에 파일별 애니메이션 방식 표 추가
- DOTween / 코루틴+Animator / UITweener 3갈래 명시
- 방식 혼용 금지 규칙 추가

### `pre-modification-analysis-detail.md`

- 상단에 프로젝트 애니메이션 시스템 표 추가
- Step 2를 방식별(DOTween / 코루틴 / UITweener) 분기로 분리

### `pge-game-evaluator-rubric-detail.md`

- B섹션(애니메이션 정밀도)을 3갈래로 분리:
  - DOTween 방식: SetLink + Kill() 체크
  - 코루틴+Animator 방식: StopCoroutine 정리 체크
  - UITweener 방식: ResetToBeginning 체크
- D-2(OnDisable 정리)도 방식별 요구사항 분리

---

## 3. GodBlade Rules 파일 변경 (`.claude/rules/`)

### `pre-modification-analysis.md`

- reference 파일 링크 추가: `key-file-map.md`, `code-snippets.md`
- Step 0 추가: 수정 전 `key-file-map.md`에서 파일 목록 + 쌍 수정 패턴 확인

---

## 4. GodBlade 애니메이션 시스템 정리

**핵심**: 파일마다 애니메이션 방식이 다름. 혼용 금지.

| 파일 | 방식 | 키워드 |
|------|------|--------|
| `EodUIGachaDrawScene.cs`, `EodUIGachaEffect.cs`, `EodUIGachaCard.cs` | **DOTween** | `DOTween.Sequence()`, `SetLink`, `DOScale` |
| `EodUIGoodsShopGachaResultPopup.cs`, `EodUIGoodsShopGachaResultIcon.cs` | **코루틴+Animator** | `StartCoroutine`, `WaitForSeconds`, `SetTrigger` |
| 나머지 레거시 UI | **UITweener** | `TweenScale.PlayForward()`, `ResetToBeginning()` |

---

## 5. Git 브랜치 규칙 (신규 메모리 저장)

- `feat/xxx` 브랜치 있으면 해당 브랜치에 push → 완료 후 develop 머지
- 브랜치 없으면 develop에서 직접 작업
- 배포 흐름: `develop → staging → main`
- **main 직접 작업 절대 금지** (모든 repo)

---

## 다음 세션 재개 시

- GodBlade 가챠 서버 실행 후 Unity에서 가챠 실행 테스트 필요 (project_gacha_session_resume.md 참조)
- PGE 사용 시 각 Phase 프롬프트에 `{project_root}` 경로 명시 필수
