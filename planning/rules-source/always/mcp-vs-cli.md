---
title: "MCP vs CLI 도구 선택 기준"
id: mcp-vs-cli
impact: MEDIUM
scope: [always]
tags: [tools, mcp, cli, token-efficiency]
section: core
audience: all
impactDescription: "잘못된 도구 선택으로 토큰 낭비 또는 기능 부족 발생"
enforcement: flexible
---

# MCP vs CLI 도구 선택 기준

> 신규 외부 도구 도입 또는 기존 도구 전환 시 MCP/CLI 선택 판단 기준.
> 기존 결정 사례: Playwright MCP → CLI 전환 (토큰 4x 절감).

## 선택 매트릭스

| 기준 | MCP 선택 | CLI 선택 |
|------|---------|---------|
| 작업 복잡도 | 멀티스텝, 함수 직접 호출 필요 | 단일 명령, 단순 조회/실행 |
| 사용 빈도 | 세션당 1-2회 (도구 정의 고정 비용 감수) | 고빈도(일 10회+) |
| 이식성 | 에이전트 플랫폼 고정 | 여러 에이전트/환경에서 동작 필요 |
| 디버깅 | 에이전트 내 컨텍스트로 추적 | 터미널에서 단독 테스트 가능 |
| 연결 상태 | 항상 연결 유지 가능 | 인터넷 없이도 동작 가능 |

## 현재 도구 분류

| 도구 | 유형 | 선택 사유 |
|------|:----:|---------|
| Notion | MCP | DB CRUD, 멀티스텝 페이지 조작 |
| Draw.io | MCP | 다이어그램 생성 (복잡한 입출력) |
| NanoBanana | MCP | 이미지 생성/편집 (바이너리 처리) |
| Stitch | MCP | UI 목업 생성 (프로젝트 관리) |
| Ludo | MCP | 게임 에셋 생성 (API 전용) |
| Replicate | MCP | AI 모델 실행 (API 전용) |
| Magic UI | MCP | UI 컴포넌트 레지스트리 |
| Playwright | **CLI** | 스크린샷 캡처 (단일 명령, 토큰 4x 절감) |
| Gemini Vision | **CLI** | 이미지/영상 분석 (analyze-screenshot.sh, analyze-video.sh) |

### 혼합 도구 (CLI + MCP)

CLI와 MCP를 용도별로 분리하여 병행 사용하는 도구.

| 도구 | CLI 용도 | MCP 용도 |
|------|---------|---------|
| **Sentry** | `sentry-cli` — 릴리스 관리, 소스맵 업로드, CI/CD | MCP — 이슈 조회, 이벤트 분석, AI 근본원인(Seer) |
| **Lighthouse** | `lighthouse` — CI/배치 감사, JSON 리포트 생성 | MCP — 대화 내 인터랙티브 감사, 메트릭 탐색 |
| **Brave Search** | `curl` API — 스크립트/hook 내 빠른 검색 | MCP — 대화 내 인터랙티브 검색, 결과 구조화 |

**CLI + MCP 선택 기준:**
- 스크립트/자동화/CI → CLI
- 대화 내 인터랙티브 탐색 → MCP
- 배치 처리 (다건 반복) → CLI
- 단건 조회 + 후속 분석 → MCP

## AI 행동 규칙

1. 신규 외부 도구 도입 제안 시 위 매트릭스로 MCP/CLI를 먼저 판단한다
2. 고빈도 단순 작업에 MCP를 사용 중이면 CLI 전환을 검토한다
3. MCP Tool Search(레이지 로딩) 활성화 시 MCP 토큰 비용이 줄어든다는 점을 고려한다
