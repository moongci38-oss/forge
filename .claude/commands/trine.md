---
description: SIGIL→Trine 전환 — 프로젝트명 입력 시 S4 완료 확인 + Handoff 문서 생성 + Trine 진입 가이드
argument-hint: <프로젝트명 (예: baduki)>
allowed-tools: Read, Write, Edit, Glob, Grep
---

당신은 SIGIL 파이프라인의 Trine 전환 전문가입니다.

## 대상 프로젝트
$ARGUMENTS

## 경로 해석

**반드시 `sigil-workspace.json`을 먼저 읽는다.** 워크스페이스 루트에서 이 파일을 찾아 `folderMap`으로 경로를 해석한다.

```
sigil-workspace.json의 folderMap 예시:
  product  → 02-product/projects (또는 사용자 설정 경로)
  design   → 05-design/projects
  handoff  → 10-operations/handoff-to-dev
  templates → 09-tools/templates
```

`sigil-workspace.json`이 없으면 → "sigil-workspace.json이 없습니다. `sigil-init`을 먼저 실행하세요." 안내 후 중단.

## 수행 절차

### 1단계: S4 Gate 통과 확인

1. `{folderMap.product}/{project}/gate-log.md` 읽기
2. S4 항목이 `✅ PASS`인지 확인
3. PASS가 아니면 → "S4가 아직 완료되지 않았습니다. SIGIL S4를 먼저 완료하세요." 안내 후 중단

### 2단계: S4 산출물 존재 확인

아래 파일이 모두 존재하는지 확인:

| 필수 산출물 | 경로 |
|-----------|------|
| 상세 기획서 (사이트맵 포함) | `{folderMap.product}/{project}/*-s4-detailed-plan.md` |
| 개발 계획 (로드맵+WBS+테스트전략 포함) | `{folderMap.product}/{project}/*-s4-development-plan.md` |
| UI/UX 기획서 | `{folderMap.design}/{project}/*-s4-uiux-spec.md` |

관리자 산출물이 있다면 추가 확인:
- `{folderMap.product}/{project}/*-s4-admin-detailed-plan.md`
- `{folderMap.design}/{project}/*-s4-admin-uiux-spec.md`

누락된 산출물이 있으면 목록을 표시하고 계속할지 사용자에게 확인.

### 3단계: Handoff 문서 생성

`{folderMap.handoff}/{project}/YYYY-MM-DD-sigil-handoff.md` 생성.

아래 구조로 작성:

```markdown
# {프로젝트명} — SIGIL → Trine Handoff

**생성일**: YYYY-MM-DD
**SIGIL 완료 Stage**: S4
**프로젝트 유형**: {유형 (게임/앱/웹)}

---

## 1. SIGIL 산출물 인덱스

| 산출물 | 경로 | 비고 |
|--------|------|------|
(S1~S4 산출물 전체 목록)

## 2. 기술 스택 요약

(S4 개발 계획에서 추출)

## 3. Trine 세션 로드맵

(S4 개발 계획의 Trine 세션 로드맵 요약)

## 4. 개발 환경 가이드

(S4 개발 계획에서 추출: 에디터, 빌드, 테스트 환경)

## 5. 핵심 아키텍처 결정 (ADR 요약)

(S4 개발 계획의 ADR 핵심 내용)

## 6. 우선순위 (Now/Next/Later)

(S4 로드맵에서 추출)

## 7. Trine 진입 체크리스트

- [ ] 개발 프로젝트 Git 저장소 생성/확인
- [ ] .specify/ 디렉토리 구조 생성
- [ ] constitution.md 작성
- [ ] Trine Session 1 Spec 작성 시작
```

### 4단계: Symlink 생성

`sigil-workspace.json`의 `projects.{project}` 설정을 읽어 개발 프로젝트에 symlink를 생성한다.

1. `devTarget` 경로 존재 확인
2. `{devTarget}/{symlinkBase}/` 디렉토리 생성
3. 모든 S3~S4 산출물 + todo.md + handoff.md에 대해 symlink 생성
   - 원본의 날짜 prefix를 제거한 이름으로 symlink
   - 예: `2026-03-03-s4-roadmap.md` → `s4-roadmap.md`

### 5단계: Trine 진입 안내

생성 완료 후 아래 메시지를 사용자에게 제공:

```
---
## Trine 진입 준비 완료

Handoff 문서: {folderMap.handoff}/{project}/YYYY-MM-DD-sigil-handoff.md
Symlink 생성: {devTarget}/{symlinkBase}/ (N개 파일)

### 다음 단계
1. 개발 프로젝트 환경으로 이동 (Trine 자동 발동)
2. Trine Session 1부터 순서대로 진행
3. 각 세션에서 Spec → Plan → 구현 → Walkthrough → PR 사이클 반복

### SIGIL 산출물 참조 방법
- S3 기획서 → Trine Phase 1.5 요구사항 분석 입력
- S4 기획 패키지 → Trine Phase 2 Spec 작성 입력
- S4 Trine 세션 로드맵 → 세션별 범위/산출물 가이드
---
```
