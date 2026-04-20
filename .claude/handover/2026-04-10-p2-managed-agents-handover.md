# Managed Agents P2 + Advisor 전략 인수인계 (2026-04-10)

> 세션 기간: 2026-04-09 ~ 2026-04-10
> 커버 범위: P0(Advisor 전략) + P1(Git 진단 스크립트) + P2(Managed Agents E2E)
> GitLab MR: https://git.lumir-ai.com/lumir/forge/-/merge_requests/6

---

## 1. 개요

| 항목 | 내용 |
|------|------|
| P0 Advisor 전략 | 스킬 7종 + 커맨드 2종 + 에이전트 4종 Opus→Sonnet 전환. 전략 판단 분기점 7개소에 Opus Advisor 패턴 삽입 (400~700 토큰/호출) |
| P1 Git 진단 | `forge-codebase-health.sh` 생성 — 핫파일/버그집중/기여자/월별속도/소방빈도 5진단, AI 커밋 필터 포함 |
| P2 Managed Agents | FastMCP 3.2.3 MCP 서버(14종 도구) + cloudflared 터널 + daily-system-review/weekly-research 에이전트 E2E 검증 완료 |

---

## 2. 파일맵

| 컴포넌트 | 경로 | 역할 |
|---------|------|------|
| MCP 서버 | `forge/shared/mcp/forge-tools-server.py` | FastMCP 3.2.3, port 8765, `/mcp` 엔드포인트, 14종 도구 |
| 에이전트 ID 저장 | `forge/shared/mcp/forge-agent-ids.json` | daily/weekly 에이전트 ID + 환경 ID |
| 서비스 관리 | `forge/shared/scripts/forge-mcp-service.sh` | tmux 기반 MCP+터널 서비스 (start/stop/restart/status/update-agents) |
| 에이전트 래퍼 | `forge/shared/scripts/run-managed-agent.py` | 세션 생성 + 스트리밍 + 완료 대기 |
| Git 진단 | `forge/shared/scripts/forge-codebase-health.sh` | 5진단 스크립트 |
| 터널 URL 캐시 | `/tmp/forge-mcp-tunnel-url.txt` | 현재 cloudflared URL (재시작마다 변경) |
| cloudflared 바이너리 | `~/.local/bin/cloudflared` | trycloudflare.com 터널 |

### MCP 서버 도구 14종

| 카테고리 | 도구 |
|---------|------|
| 파일 I/O | `read_file`, `write_file`, `list_files`, `append_file` |
| Git | `git_status`, `git_commit`, `git_log` |
| 실행 | `run_script` (whitelist 기반) |
| 검색 | `rag_search`, `web_search` (Brave API), `web_fetch` |
| 모니터링 | `run_health_check` |
| 알림 | `telegram_notify` |
| Notion | `notion_create_page` |

---

## 3. 실행 방법

```bash
# 서비스 상태 확인
~/forge/shared/scripts/forge-mcp-service.sh status

# 서비스 시작 (WSL 재시작 후 또는 최초 실행)
~/forge/shared/scripts/forge-mcp-service.sh start

# 서비스 재시작 (터널 URL 변경 필요 시 — 에이전트 MCP URL 자동 갱신 포함)
~/forge/shared/scripts/forge-mcp-service.sh restart

# 에이전트만 URL 갱신 (서버/터널은 유지)
~/forge/shared/scripts/forge-mcp-service.sh update-agents

# 에이전트 실행
python3 ~/forge/shared/scripts/run-managed-agent.py daily-system-review
python3 ~/forge/shared/scripts/run-managed-agent.py weekly-research [YYYY-MM-DD]

# Git 코드베이스 진단
~/forge/shared/scripts/forge-codebase-health.sh all              # 전체 프로젝트
~/forge/shared/scripts/forge-codebase-health.sh /path/to/repo   # 특정 프로젝트
~/forge/shared/scripts/forge-codebase-health.sh all --no-ai     # AI 커밋 제외
```

---

## 4. 에이전트 현황

| 에이전트 | Agent ID | 버전 | 환경 ID |
|---------|----------|------|---------|
| daily-system-review | `agent_011CZuxZ5KG6bFxctV9R2BpC` | v4 | `env_01NmVREmA4Vek1kzNqRUKQxw` |
| weekly-research | `agent_011CZv2SDDmnTGdhTZS1k7dn` | v2 | `env_01NmVREmA4Vek1kzNqRUKQxw` |

- ID 파일: `forge/shared/mcp/forge-agent-ids.json`
- weekly-research v2 변경 내용: `mcp__notion__notion-create-pages` → `notion_create_page` 도구명 수정

### Advisor 패턴 적용 현황

| 스킬/커맨드 | 판단 분기점 | Advisor 토큰 |
|-----------|-----------|-------------|
| /grants-write | Phase 2 기술 체계 논리 약점 검토 | 400~700 |
| /grants-review | 5축 통합 수정 우선순위 검증 | 500 |
| /system-audit | Wave 2 트레이드오프 분석 전 | 500 |
| /rd-plan | Phase 0 목차 배점 분포 적합성 | 400 |
| /pge | Evaluator 60~79점 경계 PASS/FAIL 2nd opinion | 400~600 |
| /autoplan | 3개 초안 종합 후 치명적 리스크 식별 | 500 |
| /sdd | Spec 작성 후 scope creep/설계 갭 검토 | 400 |

---

## 5. 알려진 제약

1. **cloudflared 임시 URL**: WSL 재시작마다 trycloudflare.com URL이 변경됨.
   → `forge-mcp-service.sh restart`로 터널 재시작 + 에이전트 MCP URL 자동 갱신.

2. **permission_policy always_allow 필수**: Managed Agents 기본값 `always_ask`는 MCP 도구 사용을 완전 차단함 (승인자 없어 영구 블로킹). 에이전트 등록/수정 시 반드시 `permission_policy: {type: always_allow}` 포함.

3. **BRAVE_API_KEY 따옴표 버그**: `forge/.env`에 `BRAVE_API_KEY="key..."` 형식으로 저장 시 따옴표가 값의 일부로 인식되어 Brave API 401 오류 발생. 따옴표 없이 `BRAVE_API_KEY=key...` 형식으로 저장 필요.

4. **FastMCP ≥ 3.2.3 transport**: SSE transport 미지원. `streamable-http`만 사용. MCP 클라이언트 URL: `http://localhost:8765/mcp` 또는 `https://{tunnel}/mcp`.

5. **SKILL.md 도구명 동기화**: 에이전트 system prompt(SKILL.md)의 도구명이 MCP 서버 실제 도구명과 불일치하면 `tool not found` 오류. 에이전트 재등록 전 `mcp list-tools`로 실제 도구명 확인 필수.

6. **Cloudflare 영구 터널 미완료**: `cloudflared tunnel login` 브라우저 auth가 완료되지 않아 임시 URL로 운영 중. 영구 터널 필요 시 다음 세션에서 브라우저 인증 완료 후 `cloudflared tunnel create forge-tools` 실행.

---

## 6. 다음 단계

| 우선순위 | 작업 | 비고 |
|---------|------|------|
| P1 | Cloudflare 영구 터널 완료 | `cloudflared tunnel login` → 브라우저 인증 → `tunnel create forge-tools` |
| P2 | `notion_create_page` E2E 검증 | weekly-research Wave 3 Notion 업로드 실제 확인 |
| P2 | audit 스킬 에이전트 등록 | 5축 감사 자동화 (강력 후보: audit-agentic, audit-harness, audit-context) |
| P3 | autoplan 강제 게이트 검증 | BLOCK 2개+ → [STOP] 에스컬레이션 실제 트리거 확인 |
