---
description: "지원사업 워크플로우 시작 — 기관/사업명을 입력하면 GR-1~6 파이프라인 실행"
argument-hint: <agency> <사업명>
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch, Agent, ToolSearch
model: sonnet
---
> **⚠️ 실행 모드 확인**: 이 커맨드는 쓰기 모드에서만 정상 동작합니다. Plan mode 감지 시 즉시 [STOP] — "Escape로 plan mode 해제 후 재실행하세요. 내부 [STOP] 게이트가 승인 지점입니다."

# /grants — 정부지원사업 파이프라인

**ARGUMENTS**: $ARGUMENTS

## Step 1: 인자 파싱 (즉시 실행)

$ARGUMENTS에서 첫 번째 토큰 = `{agency}`, 나머지 = `{사업명}`.

예: `kocca 콘진원-DHS플랫폼기술` → agency=`kocca`, 사업명=`콘진원-DHS플랫폼기술`

인자가 비어있으면 → 사용자에게 물어본다: "기관코드와 사업명을 입력해주세요. 예: /grants kocca AI콘텐츠제작지원"

## Step 2: 프로젝트 폴더 찾기

1. `FORGE_OUTPUTS` 경로 결정: `forge-workspace.json`의 `outputsRoot` 기준 → `~/forge-outputs`
2. `~/forge-outputs/09-grants/{agency}/` 하위에서 `*{사업명}*` 패턴으로 Glob 검색
3. 결과:
   - **매칭 1개** → 해당 폴더를 `$PROJECT_DIR`로 설정
   - **매칭 0개** → 새 폴더 생성: `{YYYY}-{사업명}/` + 디렉토리 스캐폴딩 후 GR-1 시작
   - **매칭 2개+** → 목록 표시 후 사용자에게 선택 요청

## Step 3: 현재 단계 판단 및 이어하기

`$PROJECT_DIR`이 결정되면:

1. `$PROJECT_DIR/INDEX.md` 존재 시 → Read하여 **현재 단계, 본문 상태, 다음 작업** 파악
2. INDEX.md 없고 `$PROJECT_DIR/_grant-info.md` 존재 시 → Read하여 "현재 단계" 필드 확인
3. 둘 다 없으면 → GR-1 (공고 분석) 시작

**판단 후 사용자에게 상태 요약 보고**:
```
📋 {사업명} 프로젝트 로딩 완료
- 경로: {$PROJECT_DIR}
- 현재 단계: {GR-X}
- 상태: {INDEX.md의 본문 상태}
- 다음 작업: {INDEX.md의 다음 작업}

이어서 진행할까요?
```

## Phase 흐름 (pipeline.md Part C 참조)

```
GR-1 공고 분석 [AUTO-PASS] → GR-2 전략 [STOP] → GR-3 서류 작성 [STOP]
→ GR-4 제출 패키지 [STOP] → GR-5 제출 [ASYNC] → GR-6 수행 관리
```

## GR-1 자동 실행 내용

공고문 파일(_source/)이 있으면 3개 Subagent 병렬 스폰:
- Subagent A: 공고문 파싱 → `_grant-info.md` 자동 생성
- Subagent B: 지원 자격 체크 → `00-research/eligibility-check.md`
- Subagent C: 과거 선정 사례 리서치 → `00-research/competition-analysis.md`

## GR-3 이어하기 (본문 작성 중인 경우)

INDEX.md에서 본문 상태가 "작업중"이면:
1. INDEX.md의 "최신 작업 문서" 섹션에서 본문 파일 경로 확인
2. 검수 리포트가 있으면 최신 리포트도 Read
3. 인수인계 문서가 있으면 Read
4. 상태 요약 후 [STOP] — 사용자 지시 대기

## 산출물 경로

`~/forge-outputs/09-grants/{agency}/{YYYY}-{사업명}/` 하위 각 Phase 폴더
