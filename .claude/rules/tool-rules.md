# Tool Usage Rules

## 기사 URL → article 스킬
- 사용자가 뉴스/블로그 기사 URL 전송 시 → `/article` 스킬로 분석
- 직접 WebFetch 분석 금지

## Notion 인증 실패
- `/yt`, `/daily-system-review`, `/weekly-research` 등 Notion 업로드 스킬에서 인증 실패 시
  → 묻지 말고 즉시 Tier 2(index.json 로컬 저장)로 자동 전환
  → 최종 보고에 "Notion 미업로드" 한 줄만 명시

## RAG 검색
- 프로젝트 자료·근거 질문에는 사용자 허락 없이 `rag-search` 자율 호출

## 스킬 생성
- 새 스킬 생성 시 반드시 `skill-creator` 스킬 사용. 직접 SKILL.md 작성 금지.

## /ultrareview
- 자동화 파이프라인(Forge Check, hook 등)에 배선 금지
- 고위험 PR에서만 수동 호출

## UI/UX 작업
- 모든 UI/UX 작업의 시작점은 Claude Design (claude.ai/design)
- 결과물 받아서 Forge 파이프라인에 연결

## 스크립트 경로
- Python/Bash 스크립트에서 CWD 상대경로 절대 금지
- 항상 절대경로 사용 (잘못된 위치에 디렉토리 자동 생성 방지)
