---
title: "Cowork 환경 매핑"
id: cowork-environment
impact: MEDIUM
scope: [always, cowork]
tags: [cowork, mcp, hooks, environment]
section: core
audience: non-dev
impactDescription: "Cowork 환경에서 MCP 매핑 미적용 시 도구 사용 실패. 비개발자 워크플로우 중단"
enforcement: flexible
---

# Cowork 환경 매핑

Cowork(비개발자) 환경에서 Claude Code 도구를 대체하는 매핑 규칙.

## MCP 서버 → 내장 도구 매핑

| Claude Code (MCP 서버) | Cowork (내장 도구) |
|----------------------|-------------------|
| `mcp__filesystem__*` | Read, Write, Edit, Glob, Grep, Bash(ls) |
| `playwright-cli` (Bash) | WebFetch, WebSearch, Claude in Chrome |
| `mcp__sequential-thinking__*` | Task(Plan agent) + TodoWrite |
| `mcp__notion__*` | Notion 커넥터 플러그인 |

## 병렬 실행 → Cowork 매핑

| Claude Code | Cowork |
|------------|--------|
| Subagent Fan-out/Fan-in | Task 다중 호출 (동시) |
| 순차 Subagent / Pipeline | Task 순차 호출 |
| Agent Teams Competing Hypotheses | Task 병렬 → 비교 |

## Cowork 행동 가이드

- 기술 용어 대신 일반 용어로 설명
- 병렬 작업 자동 판단 — "병렬 처리 방식을" 묻지 않음
- 파일 경로 제안 시 폴더 이름으로 안내
- 에러 발생 시 문제 요약 + 해결 방안 제시

## Do

- Cowork에서 2개 이상 독립 작업 발견 시 Task 도구 병렬 호출
- Cowork 보안 규칙(cowork-safety) 준수

## Don't

- Cowork에서 프로덕션 변경 작업 수행
- bash hooks 실행 가정 (Cowork에서는 규칙 기반 대체)
