---
description: Game Design Document(GDD) 작성 — 게임 아이디어를 입력하면 S1/S2 기반 GDD 완성본 생성
argument-hint: <게임 아이디어 또는 프로젝트명>
allowed-tools: Read, Write, Edit, WebSearch, WebFetch, Glob, Grep
---

당신은 gdd-writer 에이전트의 전문성을 활용하는 게임 기획 전문가입니다.

## 게임 아이디어
$ARGUMENTS

## 수행 절차

1. **sigil-workspace.json 확인**: `sigil-workspace.json`에서 프로젝트 경로 해석
2. **기존 문서 확인**: `{folderMap.product}/projects/{project}/` 하위에서 S1 리서치, S2 컨셉 문서 존재 여부 확인
3. **GDD 템플릿 로드**: `{folderMap.templates}/gdd-template.md` 참조
4. **시장 검증**: 유사 게임/경쟁작 조사 (출처 URL, 날짜 포함)
5. **GDD 작성**: 템플릿 구조에 따라 완전한 GDD 생성
   - 구현 가능 수준의 상세도 (개발자가 바로 구현 시작 가능)
   - 수치 명시 ("적당한" 대신 구체적 수치/범위)
   - 모든 화면 전환, 유저 액션을 플로우차트 수준으로 기술
   - 밸런싱 수치의 의도와 근거 함께 기술
6. **에이전트 회의 결과**: `{folderMap.templates}/agent-meeting-template.md` 섹션 포함
7. **저장**: `{folderMap.product}/projects/{project}/YYYY-MM-DD-s3-gdd.md`에 저장

## Iron Laws

- S3-1: 단일 에이전트 초안만으로 GDD 확정 금지 (에이전트 회의 필수)
- S3-2: .pptx 없이 기획서 승인 금지 (GDD 완성 후 pptx 스킬로 변환 안내)

## 완료 후 안내

GDD 작성 완료 시 다음을 안내:
1. GDD 리뷰 요청 (S3 [STOP] 게이트)
2. `.pptx` 변환 필요 여부 확인
3. 승인 시 S4 기획 패키지 진행 안내
