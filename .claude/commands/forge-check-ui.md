---
description: Forge Dev Check 3.6 UI/UX 품질 검수 — 독립 실행
allowed-tools: Bash, Read, Grep, Glob, ToolSearch, mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_resize
model: sonnet
---

# /forge-check-ui — UI/UX 품질 게이트

Check 3.6 UI/UX 검증을 독립적으로 실행합니다.

## 실행

1. `ui-quality-gate.md` 프롬프트 로드
2. UI 관련 파일 변경 목록 확인
3. 정적 UI 검증 (디자인 토큰, alt 속성, AI 슬롭)
4. 이미지 품질 검증
5. 성능/접근성 감사 (MCP 가용 시)
6. 반응형 시각 검증 (Playwright MCP 가용 시)
7. 결과를 JSON 형식으로 반환

## 트리거 조건

`.tsx`, `.jsx`, `.vue`, `.css`, `.scss`, `.svg`, `.png` 등 UI 파일 변경 시.
