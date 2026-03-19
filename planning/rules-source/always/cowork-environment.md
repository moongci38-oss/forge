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

## 병렬 Task 실행 가이드

### 병렬 실행 가능 (독립 작업)

```
사용자: "시장조사 3개 해줘 — AI SaaS, 게임 시장, 콘텐츠 플랫폼"
→ Task 3개 동시 호출 (서로 의존성 없음)
```

```
사용자: "블로그 글 2개 써줘 — SEO 가이드랑 마케팅 트렌드"
→ Task 2개 동시 호출 (서로 다른 주제)
```

### 순차 실행 필요 (의존 작업)

```
사용자: "시장조사 하고, 그 결과로 기획서 써줘"
→ Task 1(시장조사) 완료 → Task 2(기획서) 순차 호출
```

### 판단 기준

| 질문 | Yes → 병렬 | No → 순차 |
|------|:--------:|:--------:|
| 각 작업이 서로의 결과 없이 시작 가능한가? | ✅ | |
| 한 작업의 출력이 다른 작업의 입력인가? | | ✅ |
| 같은 파일을 동시에 수정하는가? | | ✅ |

## Do

- Cowork에서 2개 이상 독립 작업 발견 시 Task 도구 병렬 호출
- 의존 관계가 있는 작업은 순차 호출
- Cowork 보안 규칙(cowork-safety) 준수

## Don't

- Cowork에서 프로덕션 변경 작업 수행
- bash hooks 실행 가정 (Cowork에서는 규칙 기반 대체)
