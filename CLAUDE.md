# Forge — Unified Planning + Dev Pipeline

> Phase 1~12 통합 파이프라인.
> `planning/` (Phase 1~4 기획) + `dev/` (Phase 6~12 개발) + `shared/` (공통 도구).

---

## Workspace Context

**소유자**: 1인 기업 운영자 (풀스택 개발자 겸 사업가)
**비전**: 백엔드 개발자 1명이 AI Subagent로 6개 약점 영역을 80% 이상 보완

### 멀티 프로젝트 워크스페이스

| 프로젝트 | 경로 | 설명 |
|---------|------|------|
| **Forge** | `./` | 통합 파이프라인 (현재) |
| **Forge Outputs** | `~/forge-outputs/` | 산출물 저장소 (private) |
| **Portfolio** | `~/mywsl_workspace/portfolio-project/` | Next.js + NestJS 웹 개발 |
| **GODBLADE** | `/mnt/e/new_workspace/god_Sword/src` | Unity 모바일 RPG (C#) |

---

## Output Preferences

- **문서**: Markdown 기본
- **언어**: 한국어 기본, 해외 대상 자료는 영어

## 사용 환경

| 환경 | 사용자 | 주요 작업 |
|------|--------|----------|
| **Claude Code (CLI)** | 개발자 | Subagent 병렬 실행, 스크립트 실행, Git 작업 |
| **Claude Desktop Cowork** | 비개발자 | 리서치, 문서 작성, 콘텐츠 기획 |

---

## Forge = 하네스 (Harness Engineering)

**Forge는 AI 에이전트를 위한 하네스다** — CLAUDE.md(컨텍스트) + hooks(자동화) + skills(도구) + eval loops(검증)의 4축으로 Claude가 일관되게 고품질 결과를 내도록 구조화한 실행 환경.

### 하네스 3축

| 축 | 구성 요소 | 목적 |
|----|---------|------|
| **Context** | CLAUDE.md, rules/, memory/ | 세션마다 일관된 지식 주입 |
| **Tool** | skills/, hooks/, MCP 서버 | 에이전트 행동 범위 정의 |
| **Evaluation** | Evaluator subagent, canary, benchmark | 자기 평가 편향(self-eval bias) 차단 |

### 핵심 원칙

- **성공은 침묵**: post-tool-use 훅은 성공 로그 억제, 실패만 통과 → 컨텍스트 오염(Context Rot) 방지
- **독립 Evaluator**: 동일 세션·동일 모델이 자기 작업을 평가하지 않는다 (별도 subagent 필수)
- **계획 강제 저장**: 세션 종료 시 계획은 소멸 → `Stop` 훅의 `session-plan-save.sh`가 파일로 강제 저장
