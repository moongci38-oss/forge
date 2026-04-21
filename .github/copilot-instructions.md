# Forge AI System — Copilot Instructions

## 시스템 개요

이 레포는 **Forge** — AI 기반 통합 개발 파이프라인이다. Claude Code가 주 오케스트레이터이고, Copilot은 Claude Code 사용량 초과 시 백업으로 사용한다.

## 핵심 경로

| 역할 | 경로 |
|------|------|
| 산출물 루트 | `~/forge-outputs/` |
| 연구/분석 | `~/forge-outputs/01-research/` |
| 위키 | `~/forge-outputs/20-wiki/` |
| 에이전트 정의 | `.claude/agents/*.md` |
| 스킬 정의 | `~/.claude/skills/*/SKILL.md` |
| 커맨드 | `~/.claude/commands/*.md` |

## 프로젝트 목록

- **portfolio-admin / portfolio-blog**: Next.js + NestJS 웹
- **godblade**: Unity 게임 (`/mnt/e/new_workspace/god_Sword/src`)
- **pingame-server**: Colyseus + NestJS 다게임 서버
- **ai-doc-tool**: AI 문서 자동화 SaaS

## 에이전트 사용 방법 (Copilot)

`.claude/agents/` 안의 에이전트는 Copilot Ask 드롭다운에서 `@에이전트명`으로 호출:

| 에이전트 | 용도 |
|---------|------|
| `@yt-video-analyst` | YouTube 영상 분석 → `01-research/videos/analyses/` 저장 |
| `@article-analyst` | 웹 기사 분석 |
| `@spec-writer` | Spec 문서 작성 |
| `@fact-checker` | 주장 검증 |
| `@forge-pm-updater` | PM 문서 갱신 |
| `@yt-cross-analyst` | 여러 영상 교차 분석 |
| `@doc-writer` | 코드 문서화 |

## MCP 도구 (Copilot에서 사용 가능)

- `brave-search`: 웹 검색
- `notion`: Notion 페이지 생성/조회
- `nano-banana`: 이미지 생성 (Gemini)
- `context7`: 라이브러리 최신 문서 조회

## 산출물 저장 규칙

모든 분석/연구 결과는 반드시 `~/forge-outputs/` 하위에 저장.
- YouTube 분석: `01-research/videos/analyses/YYYY-MM-DD-{video_id}-analysis.md`
- 기사 분석: `01-research/articles/YYYY-MM-DD/`
- 위키 노트: `20-wiki/topics/`, `concepts/`, `tools/`, `people/`

## Copilot vs Claude Code 차이

Copilot에서는 다음이 제한됨:
- 서브에이전트 병렬 스폰 (Agent 도구 없음)
- Bash/터미널 실행
- PM2/시스템 명령

대신 파일 읽기/쓰기, 웹 검색, 코드 분석은 동일하게 가능.
