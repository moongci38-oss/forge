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

- 독립 병렬 작업 → **Subagent** (기본) | 에이전트 간 소통/비교 → **Agent Teams** (특수)
- 모델: Lead→Opus 4.6 | 구현/작성→Sonnet 4.6 | 탐색/검색→Haiku 4.5
- Worktree: 같은 파일 병렬 수정 시 `isolation: "worktree"` 사용

## PM 도구 / Notion (HIGH)

- **Notion Tasks = 유일한 Source of Truth** (todo.md는 초기 등록용만)
- Human override 우선: `last_edited_by=person`이면 AI가 덮어쓰기 금지
- 버그/기능 등록: **명시적 요청** 시에만. DB URL: `forge-workspace.json`의 `notionDBs`

## 커맨드 실행 모드 (HIGH)

- Forge 멀티 Phase 커맨드는 **쓰기 모드에서 실행** (내부 [STOP] 게이트가 승인 지점)
- Plan mode 감지 시 경고 출력 후 즉시 중단

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
