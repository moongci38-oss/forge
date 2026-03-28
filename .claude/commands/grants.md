---
description: "지원사업 워크플로우 시작 — 기관/사업명을 입력하면 GR-1~6 파이프라인 실행"
argument-hint: <agency> <사업명>
allowed-tools: Read, Write, Bash, Glob, Grep, WebSearch, WebFetch
model: sonnet
---

# /grants — 정부지원사업 파이프라인

## 사용법
```
/grants {agency} {사업명}
/grants kocca AI콘텐츠제작지원
```

## 워크플로우

1. `forge-workspace.json`의 `folderMap.grants` 경로 확인
2. `~/forge-outputs/09-grants/{agency}/` 하위에 사업 폴더 존재 여부 확인
3. 사업 폴더가 없으면 새로 생성 (디렉토리 구조 스캐폴딩)
4. `_grant-info.md` 존재 여부로 현재 단계 판단:
   - 없음 → GR-1 (공고 분석) 시작
   - 있음 → `_grant-info.md`의 "현재 단계" 필드 기준 해당 Phase 진행

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

## 산출물 경로

`~/forge-outputs/09-grants/{agency}/{YYYY}-{사업명}/` 하위 각 Phase 폴더
