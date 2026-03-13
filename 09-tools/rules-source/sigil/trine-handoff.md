---
title: "SIGIL → Trine 전환"
id: trine-handoff
impact: HIGH
scope: [sigil, trine]
tags: [handoff, transition, trine]
requires: [sigil-s4-planning]
section: sigil-pipeline
audience: dev
impactDescription: "Handoff 문서 미생성 시 Trine에서 S4 산출물 참조 경로 불명 → 기획-개발 단절. 기술 스택/ADR 미전달 시 재의사결정 필요"
enforcement: rigid
---

# SIGIL → Trine 전환 규칙

## 경로 해석 규칙

모든 경로는 워크스페이스 루트의 `sigil-workspace.json`에서 해석한다.

```
경로 해석: {folderMap.product}/{project}/ → 실제 경로 (예: 02-product/projects/portfolio-admin/)
```

> `sigil-workspace.json`이 없으면 **[STOP]** — `sigil-init` 실행을 안내한다.

## 전환 조건

Trine 진입은 아래 **모든 조건**을 충족해야 한다:

1. SIGIL S4 Gate가 `PASS` 또는 `AUTO`로 기록됨 (`gate-log.md`)
2. S4 필수 산출물 3종이 존재함
3. Todo Tracker가 존재함 (`{folderMap.product}/todo.md`)

## Handoff 문서 구조

S4 완료 시 자동 생성하는 Handoff 문서:

- **경로**: `{folderMap.handoff}/{project}/YYYY-MM-DD-sigil-handoff.md`
- **역할**: SIGIL(설계) → Trine(구현) 간 정보 전달 공식 문서
- **내용**: 산출물 인덱스, 기술 스택, 세션 로드맵, 개발 환경, ADR 요약, 우선순위

## SIGIL 산출물 → Trine 매핑

| SIGIL 산출물 | Trine 활용 시점 | 용도 |
|-------------|----------------|------|
| S1 리서치 | Phase 1 | 프로젝트 컨텍스트 이해 |
| S3 기획서 (PRD/GDD) | Phase 1.5 요구사항 분석 | 기능/비기능 요구사항 추출 |
| S4 상세 기획서 | Phase 2 Spec 작성 | 화면별 동작, 데이터 흐름, 사이트맵(페이지 계층/네비게이션) 참조 |
| S4 개발 계획 | Phase 1 세션 이해 + Phase 3 Check | 기술 스택, ADR, 세션 로드맵, WBS + 테스트 전략(피라미드/커버리지/도구) |
| S4 UI/UX 기획서 | Phase 2 Spec UI 섹션 | 와이어프레임, 인터랙션 참조 |

## 프로젝트 유형별 Trine 대상

| 프로젝트 유형 | Trine 대상 환경 | Spec 템플릿 | 비고 |
|-------------|---------------|-----------|------|
| 게임 (Unity) | GodBlade 또는 별도 Unity 프로젝트 | `spec-template-game.md` | C# 개발 |
| 웹 서비스 | Portfolio (Next.js + NestJS) | `spec-template-base.md` | TypeScript 개발 |
| 앱 개발 | 별도 앱 프로젝트 | `spec-template-base.md` | 프레임워크에 따라 |

### Spec 템플릿 자동 선택

`sigil-workspace.json`의 `projectType` 필드로 Spec 템플릿을 자동 선택한다:

| projectType | 템플릿 | Section 9 내용 |
|:-----------:|--------|---------------|
| `game` | `spec-template-game.md` | 씬 구조, Prefab 계층, FSM, Canvas UI, 해상도, 입력, 연출/이펙트, Animator |
| `web` (기본) | `spec-template-base.md` | 페이지/라우트, 컴포넌트, Props, 상태관리, 반응형, 접근성, SEO |

- `projectType` 미지정 시 기본값 `web` (기존 동작 유지)
- 게임 프로젝트는 서버 Spec을 경량화 (Section 8 → "서버 연동" 참조만)

### 게임 프로젝트 Trine 도구

| 도구 | 용도 | 활용 Phase |
|------|------|-----------|
| Unity MCP | Unity Editor 연동 (씬/프리팹/컴포넌트 조작) | Phase 3 구현 |
| Unity AI | Muse Chat, Muse Behavior AI | Phase 3 구현 |
| `/video-reference-guide` | 게임 연출 영상 → 구현 가이드 | S3 기획, Phase 2 Spec (9.9) |
| `/screenshot-analyze` | 게임 스크린샷 → UI/레이아웃 분석 | S3 기획, S4 UI/UX, Phase 2 Spec |
| `/game-logic-visualize` | FSM/확률/전투/경제 시각화+시뮬레이션 | S3 GDD, S4 상세기획, Phase 2 Spec |
| `/game-reference-collect` | 경쟁작 레퍼런스 통합 수집·분석 | S1 리서치, S3 GDD |
| `analyze-video.sh` | Gemini 프레임 분석 CLI | 스킬 내부 / 직접 호출 |
| `analyze-screenshot.sh` | Gemini Vision 이미지 분석 CLI | 스킬 내부 / 직접 호출 |

> 게임 프로젝트의 Unity MCP/AI 설정은 개발 프로젝트의 `.mcp.json`에 정의되어 있다.

### 게임 프로젝트 시각 자료 최소 기준

S4 기획 패키지에 포함해야 하는 게임 프로젝트의 시각 자료 최소 기준. `sigil-workspace.json`의 `projectScale` 필드로 차등 적용:

#### 규모 분류 기준

| 규모 | 기준 |
|------|------|
| **Small** | Trine 세션 3개 이하, 핵심 시스템 2개 이하 |
| **Large** | Trine 세션 4개 이상, 또는 핵심 시스템 3개 이상 |

> **핵심 시스템**: 게임 코어 루프에 직접 관여하는 시스템 (전투, 경제, 상태 관리, 보상 등). UI/설정 시스템은 포함하지 않음.

#### 규모별 시각 자료 최소 기준

| 항목 | Small | Large | 도구 |
|------|:-----:|:-----:|------|
| FSM 다이어그램 | 코어 루프 1개 | 핵심 시스템당 1개 | `/game-logic-visualize` |
| UI 목업 (Stitch) | 핵심 화면 1개 | 핵심 화면 3+개 | Stitch MCP |
| 레퍼런스 스크린샷 분석 | 경쟁작 1개 | 경쟁작 2+개 | `/screenshot-analyze` |
| 영상 레퍼런스 분석 | 선택 | 핵심 연출 1+개 | `/video-reference-guide` |

> **경쟁사 스크린샷 저장 경로**: `docs/assets/screenshot-refs/` (분석 결과 .md 포함). 원본 이미지는 `docs/assets/screenshot-refs/originals/`에 보관 권장.
| 밸런싱 시뮬레이터 | 선택 | 핵심 시스템 1+개 | `/game-logic-visualize` (playground) |
| 사이트 레퍼런스 수집 | 선택 | 경쟁작 사이트 2+개 | `/game-reference-collect` |

### 게임 S4 산출물별 시각 자료 기준

> `sigil-s4-planning.md` → "S4 산출물 시각 자료 기준 (프로젝트 유형별)" 테이블 참조

### 웹/앱 프로젝트 Trine 도구

| 도구 | 용도 | 활용 Phase |
|------|------|-----------|
| Stitch MCP | UI 목업 생성 (Desktop/Mobile) | S3 기획, S4 UI/UX, Phase 2 Spec |
| NanoBanana MCP | 히어로 이미지, 컨셉 일러스트, 아이콘 | S3 기획, S4 상세기획 |
| `/screenshot-analyze` | 경쟁사 UI 스크린샷 분석, 구현 검증 | S3 기획, S4 UI/UX, Phase 3 역비교 |
| Draw.io MCP | C4 아키텍처, 복잡한 플로우 (15+ 노드) | S4 개발 계획, Phase 2 Spec |
| Mermaid | 간단한 플로우/시퀀스 (≤15 노드) | S3 기획, S4 상세기획, Phase 2 Spec |
| Playwright CLI | 구현 결과 브라우저 스크린샷 캡처 | Phase 3 역비교 |

### 웹/앱 프로젝트 시각 자료 최소 기준

S4 기획 패키지에 포함해야 하는 웹/앱 프로젝트의 시각 자료 최소 기준. `sigil-workspace.json`의 `projectScale` 필드로 차등 적용:

#### 규모별 시각 자료 최소 기준

| 항목 | Small | Large | 도구 |
|------|:-----:|:-----:|------|
| UI 목업 (Stitch) | 핵심 화면 1개 | 핵심 화면 3+개 | Stitch MCP |
| 플로우 다이어그램 | 코어 플로우 1개 | 주요 플로우 전체 | Mermaid / Draw.io MCP |
| 경쟁사 UI 스크린샷 분석 | 경쟁작 1개 | 경쟁작 2+개 | `/screenshot-analyze` |
| 컨셉 일러스트/히어로 이미지 | 선택 | 핵심 페이지 1+개 | NanoBanana MCP |

> **경쟁사 스크린샷 저장 경로**: `docs/assets/screenshot-refs/` (분석 결과 .md 포함).
| 반응형 레이아웃 목업 | 선택 | Desktop+Mobile 각 1+개 | Stitch MCP (generate_variants) |
| 아키텍처 다이어그램 (C4) | 선택 | Level 1-2 필수 | Draw.io MCP |

### 웹/앱 S4 산출물별 시각 자료 기준

> `sigil-s4-planning.md` → "S4 산출물 시각 자료 기준 (프로젝트 유형별)" 테이블 참조

### 파이프라인 시각 도구 선택 가이드

```
시각 자료 유형 판별:
  동영상? → /video-reference-guide (무성) 또는 /yt (음성)
  스크린샷? → /screenshot-analyze
  로직/수치? → /game-logic-visualize
  레퍼런스 수집? → /game-reference-collect (위 3개 자동 라우팅)
  목업 생성? → Stitch MCP
  컨셉 아트? → NanoBanana MCP
  복잡한 다이어그램? → Draw.io MCP
  간단한 다이어그램? → Mermaid
```

### Trine Phase 3 구현↔레퍼런스 역비교

UI/연출 구현 완료 후, 구현 결과물을 S3/S4 레퍼런스와 비교하여 기획 의도 충족도를 검증한다. **모든 프로젝트 유형**에 적용.

> **게임 역비교 범위**: UI/HUD/메뉴 레이어에 한정한다. 타격감, FPS, 파티클, 사운드 등 런타임 품질은 역비교 범위 밖이다. FSM 로직 변경도 시각 역비교 범위 밖이다 — Unit/Integration 테스트로 검증한다.

```
Phase 3 구현 완료
  ↓
Check 3 (build/test/lint) PASS
  ↓
시각 역비교 (UI/화면 컴포넌트 신규/변경 시, 선택적)
  ├─ 게임: Unity Editor Play 모드 스크린샷 캡처 (UI/HUD 레이어만)
  ├─ 웹/앱: Playwright CLI 스크린샷 또는 수동 브라우저 캡처
  ├─ docs/assets/screenshot-refs/ 의 레퍼런스와 비교
  ├─ /screenshot-analyze 실행
  └─ 비교 결과를 Walkthrough에 포함
  ↓
Check 3.5 (Spec compliance)
```

**"선택적"인 이유**: UI/화면 컴포넌트 신규 생성 또는 변경 시에만 수행. 로직·API·DB만 변경 시 스킵.

**웹/앱 Playwright CLI 전제조건:**

| 항목 | 확인 방법 |
|------|---------|
| dev 서버 실행 여부 | `pnpm dev` / `npm run dev` 실행 확인 |
| URL/포트 | `http://localhost:{PORT}` (프로젝트별 상이) |
| 인증 필요 화면 | 테스트 계정 또는 `--bypass-csp` 옵션 확인 |
| 캡처 명령 | `npx playwright screenshot {URL} {output}.png` |

**프로젝트 유형별 스크린샷 캡처 방법:**

| 유형 | 캡처 방법 | 자동화 수준 |
|------|----------|:----------:|
| 게임 (Unity) | Unity Editor Play 모드 (UI/HUD 레이어만) | 수동 |
| 웹/앱 | Playwright CLI (`npx playwright screenshot`) | 자동화 가능 |
| 웹/앱 (대안) | 수동 브라우저 캡처 | 수동 |

## Symlink 기반 문서 연동 (Source of Truth: SIGIL 워크스페이스)

**SIGIL 워크스페이스가 모든 기획/계획 문서의 유일한 원본**이다. 개발 프로젝트는 symlink로 참조만 한다.

### 원칙

- 기획서/개발계획서 수정은 반드시 SIGIL 워크스페이스에서 SIGIL 파이프라인을 통해 수행
- 개발 프로젝트의 `{symlinkBase}/` 폴더에 symlink를 생성 (`sigil-workspace.json`의 프로젝트별 설정)
- symlink이므로 SIGIL 워크스페이스에서 수정하면 개발 프로젝트에 자동 반영

### Symlink 대상 (전체 SIGIL 산출물)

| symlink 이름 | 원본 경로 (folderMap 기준) |
|-------------|--------------------------|
| `handoff.md` | `{folderMap.handoff}/{project}/YYYY-MM-DD-sigil-handoff.md` |
| `s3-prd.md` (또는 `s3-gdd.md`) | `{folderMap.product}/{project}/YYYY-MM-DD-s3-prd.md` |
| `s4-detailed-plan.md` | `{folderMap.product}/{project}/YYYY-MM-DD-s4-detailed-plan.md` |
| `s4-development-plan.md` | `{folderMap.product}/{project}/YYYY-MM-DD-s4-development-plan.md` |
| `s4-uiux-spec.md` | `{folderMap.design}/{project}/YYYY-MM-DD-s4-uiux-spec.md` |
| `gate-log.md` | `{folderMap.product}/{project}/gate-log.md` |
| 관리자 산출물 (`s4-admin-*.md`) | 해당 원본 경로 (S3에 관리자 포함 시) |

### Symlink 생성 시점

- **신규 프로젝트**: Handoff 단계에서 개발 프로젝트 폴더 생성 + 전체 symlink 일괄 생성
- **기존 프로젝트**: S4 산출물 추가/변경 시 누락된 symlink만 추가

### Symlink 파일명 규칙

- 원본의 날짜 prefix(`YYYY-MM-DD-`)를 제거한 이름으로 symlink 생성
- 예: `2026-03-03-s4-detailed-plan.md` → symlink 이름 `s4-detailed-plan.md`

### symlinkBase 네이밍 규칙 (모든 프로젝트 공통)

개발 프로젝트 내 SIGIL 산출물은 도메인별로 분리한다:
- S3, S4, Handoff, Gate Log → `docs/planning/active/sigil/{도메인}/` (symlink)
- {도메인}: SIGIL 프로젝트의 기능 도메인 이름 (kebab-case)
- 동일 개발 프로젝트에 여러 SIGIL 프로젝트 → 도메인으로 구분
- sigil-workspace.json 등록 시 symlinkBase에 도메인 경로 포함 필수

### todo.md 통합 트래커 규칙 (모든 프로젝트 공통)

todo.md는 개발 프로젝트당 1개, sigil/ 루트에 실제 파일로 관리한다:
- 경로: `docs/planning/active/sigil/todo.md` (도메인 하위 아님)
- 유형: 실제 파일 (symlink 아님) — GitHub Actions 호환 필수
- 새 SIGIL 프로젝트 S4 Gate PASS 시 기존 todo.md에 Spec 행을 추가 (새 파일 생성 아님)
- 모든 SIGIL 프로젝트의 Trine Spec을 한 파일에서 통합 추적

### 개발 프로젝트 매핑 (`sigil-workspace.json`)

```json
"projects": {
  "my-project": {
    "devTarget": "/path/to/dev/project",
    "symlinkBase": "docs/planning/active/sigil/my-domain"
  }
}
```

- `devTarget`: 개발 프로젝트 절대 경로 (symlink 생성 대상)
- `symlinkBase`: 개발 프로젝트 내 symlink 디렉토리 (상대 경로, 도메인 포함)

## Handoff 후 워크플로우

```
SIGIL S4 완료
    ↓
Handoff 문서 자동 생성 ({folderMap.handoff}/{project}/)
    ↓
개발 프로젝트 {symlinkBase}/ 에 전체 symlink 생성
    ↓
Human이 개발 프로젝트 환경으로 이동
    ↓
Trine 자동 발동 (Implicit Entry: .specify/ 디렉토리 감지)
    ↓
Trine Session 1부터 순차 진행
    ├─ Spec 작성 (symlink된 S4 산출물 참조)
    ├─ Plan 작성
    ├─ 구현 + AI Check
    ├─ Walkthrough
    └─ PR (Merge 시 todo.md 자동 갱신)
```

## 관리자 산출물 포함 규칙

S3 기획서에 관리자 기능이 포함된 경우, Handoff 문서에 관리자 산출물도 포함:
- 관리자 상세 기획서
- 관리자 UI/UX 기획서

## Do

- S4 Gate PASS 후 Handoff 문서를 자동 생성한다
- 산출물 인덱스에 모든 S4 산출물 경로를 포함한다
- S3에 관리자 기능이 포함된 경우 관리자 산출물도 Handoff에 포함한다
- Handoff 문서에 Todo Tracker 경로를 포함한다
- Handoff 단계에서 개발 프로젝트에 전체 SIGIL 산출물 symlink를 생성한다
- 기획서/개발계획서 수정은 반드시 SIGIL 워크스페이스에서 SIGIL 파이프라인을 통해 수행한다

## Don't

- Handoff 문서 미생성으로 Trine에 진입하지 않는다
- 산출물 인덱스에 누락이 있는 상태로 Handoff를 완료하지 않는다
- Todo Tracker 미생성 상태로 Trine에 진입하지 않는다
- 개발 프로젝트에서 기획/계획 문서 원본을 직접 수정하지 않는다 (symlink이므로 SIGIL 워크스페이스에서 수정)
- symlink 없이 문서를 복사하여 개발 프로젝트에 배치하지 않는다
- `sigil-workspace.json` 없이 경로를 하드코딩하지 않는다
- symlinkBase를 도메인 없이 sigil/ 루트로 설정하지 않는다
- todo.md를 도메인 하위에 생성하지 않는다 (sigil/ 루트에 통합)
- todo.md를 symlink으로 생성하지 않는다 (실제 파일 필수)

## AI 행동 규칙

1. **`sigil-workspace.json`을 먼저 읽고 경로를 해석한다** — 없으면 [STOP]
2. S4 Gate PASS 확인 후 Handoff 문서를 자동 생성한다
3. Handoff 문서에 산출물 인덱스, 기술 스택, 세션 로드맵을 포함한다
4. `sigil-workspace.json`의 프로젝트 매핑으로 개발 프로젝트에 전체 symlink를 생성한다
5. Human에게 Trine 진입 안내를 제공한다 (개발 프로젝트 이동 시 Trine 자동 발동)
6. 기획/계획 문서 수정 요청 시 SIGIL 워크스페이스의 원본을 수정한다 (symlink 자동 반영)
7. 신규 프로젝트 등록 시 symlinkBase에 도메인 경로를 포함한다
8. S4 Gate PASS 시 기존 todo.md에 Spec 행을 추가한다 (새 파일 생성 아님)

## Iron Laws

- **IRON-1**: Handoff 문서 미생성 상태로 Trine에 진입하지 않는다
- **IRON-2**: gate-log.md에 S4 PASS 또는 AUTO 기록이 없으면 Trine 진입을 거부한다

## Rationalization Table

| 합리화 (Thought) | 현실 (Reality) |
|-------------------|---------------|
| "Handoff는 형식적이니 스킵해도 개발 가능하다" | Handoff 없이 Trine에 진입하면 S4 산출물 참조 경로가 불명확하여 기획-개발 단절이 발생한다 |
| "어차피 같은 사람이 하니까 문서 없어도 된다" | 1인이라도 세션 간 컨텍스트가 유실된다. Handoff는 세션 독립성을 보장하는 공식 문서다 |

## Red Flags

- "바로 코딩부터 시작하자..." → STOP. gate-log.md에서 S4 PASS를 확인한다
- "Handoff 문서는 나중에 만들면..." → STOP. Trine 진입 전 Handoff 자동 생성을 실행한다
