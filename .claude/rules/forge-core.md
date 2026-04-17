# Forge Core Rules (Passive Summary)

> 점진적 로딩: Passive 요약. 상세 규칙은 해당 작업 시 Deep 로딩.
> Deep 원본: `planning/rules-source/always/` + `shared/cross-project/`
> 의도가 불분명하면 가장 유용한 행동을 추론하고 진행한다.

---

## 산출물 경로 (CRITICAL)

- forge/ = 시스템 / forge-outputs/ (`~/forge-outputs/`) = 결과물
- `forge-outputs/`는 forge/의 **형제 폴더**. CWD 상대경로 사용 금지.

## 보안 (CRITICAL)

- 민감 정보 커밋 금지, 06-finance/07-legal/08-admin 외부 출력 금지, 하드코딩 시크릿 금지
- 읽기 금지: `06-finance/`, `07-legal/`, `08-admin/insurance/`, `08-admin/freelancers/`, `.ssh/`, `.aws/`, `.env*`
- 시스템 경로 보호: `forge/dev/`, `~/.claude/rules/`, `~/.claude/scripts/` 삭제/이동 금지
- MCP 설정: 프로젝트 `.mcp.json` | 전역 `~/.claude.json` 내 mcpServers (`~/.claude/.mcp.json` 인식 안 됨)

## 설치 경로 (CRITICAL)

- `FORGE_ROOT` 환경변수 기본값 `~/forge`. 다른 경로 시 명시 설정 필수.

---

## Git (HIGH)

- Conventional Commits: feat/fix/docs/style/refactor/test/chore
- 브랜치: main(프로덕션), feature/*, fix/*. Squash merge 전용, PR 필수
- AI 커밋: `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
- main 직접 커밋/force push 금지, .env 커밋 금지, --no-verify 금지

## 병렬 실행 (HIGH)

- 병렬 작업 → **Agent Teams** (기본) | 단순 탐색/검색/단일 파일 → **Subagent** (경량)
- 모델: Lead→Opus 4.7 | 구현/작성→Sonnet 4.6 | 탐색/검색→Haiku 4.5
- Worktree: 같은 파일 병렬 수정 시 `isolation: "worktree"` 사용

## PM 도구 / Notion (HIGH)

- **Notion Tasks = 유일한 Source of Truth** (todo.md는 초기 등록용만)
- Human override 우선: `last_edited_by=person`이면 AI가 덮어쓰기 금지
- 버그/기능 등록: **명시적 요청** 시에만. DB URL: `forge-workspace.json`의 `notionDBs`

## 커맨드 실행 모드 (HIGH)

- Forge 멀티 Phase 커맨드는 **쓰기 모드에서 실행** (내부 [STOP] 게이트가 승인 지점)
- Plan mode 감지 시 경고 출력 후 즉시 중단

## Context Compaction 트리거 (HIGH)

- **70% 토큰 소비 시** `/compact` 실행 권장 — 캐시 TTL(5분) 안에서 의도적 요약
- **90% 토큰 소비 시** `/compact` 강제 권장 — 품질 저하 임계
- 다음 Phase 진입 또는 Wave 전환 시점이 있으면 그 시점을 우선 (자연 분할점)
- Wave 2~3 병렬 리뷰 직전에 `/compact` 수행 시 sub-agent 컨텍스트 오염 최소화

## 암묵지 표면화 — Tacit Knowledge Surfacing (HIGH)

- 실패 사유, 예외 패턴, 운영 뉘앙스는 코드·커밋에 드러나지 않는다. 반드시 **handover 문서**(실패한 시도와 이유), **CLAUDE.md**(scope별 규칙·제약), **memory**(세션 간 학습)에 명시적으로 기록한다.
- "왜 이 방법을 택했고, 왜 다른 방법을 버렸는지"가 핵심 — 결과물만 남기면 다음 세션이 같은 실패를 반복한다.
- Palantir FSR 원칙 차용: 시스템 바깥의 운영 로직(워크플로우 예외, 사용자 선호, 환경 제약)을 관찰하고 코드화한다.

---

## Deep 로딩 라우팅 (MEDIUM — 필요 시 참조)

| 작업 | Deep 파일 |
|------|----------|
| 보안 | `always/security.md` |
| Git | `always/git.md` |
| 병렬/에이전트 | `cross-project/agent-teams.md` |
| Notion/PM | `always/pm-tools.md` |
| 파일명 | `always/file-naming.md` |
| 리서치 | `always/research-methodology.md` |
| 콘텐츠 | `always/content-quality.md` |
| Cowork | `always/cowork-environment.md` |
| MCP/CLI | `always/mcp-vs-cli.md` |
| 에셋 생성 | `always/resource-generation.md` |
| 크로스 프로젝트 | `cross-project/cross-project-pipeline.md` |
| 스킬 생성 | `cross-project/skill-creation.md` |
| 하네스 설계 | PGE 분해, 자기평가 분리, Rubric 명시 — `pipeline.md` §하네스 참조 |
| 파이프라인 Phase | `forge/.claude/rules-on-demand/forge-planning.md` |
| Plan mode 지침 | `~/.claude/rules-on-demand/plan-mode.md` |
| Telegram 원격제어 | `~/.claude/rules-on-demand/telegram-remote-control.md` |

Deep 원본: `planning/rules-source/{scope}/{filename}` 또는 `shared/{scope}/{filename}`
