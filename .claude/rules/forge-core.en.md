# Forge Core Rules (Passive Summary, English experiment)

> Progressive loading: passive summary. Deep rules loaded per-task.
> Deep source: `planning/rules-source/always/` + `shared/cross-project/`
> If intent is ambiguous, infer the most useful action and proceed.
>
> NOTE: Experimental English distillation (2026-04-20). Korean original is `forge-core.md`. Benchmark outcome will determine adoption.

---

## Output paths (CRITICAL)

- `forge/` = system / `forge-outputs/` (`~/forge-outputs/`) = deliverables
- `forge-outputs/` is a sibling of `forge/`. Do not use CWD-relative paths.

## Security (CRITICAL)

- Never commit secrets. Do not expose `06-finance/`, `07-legal/`, `08-admin/`.
- Read-forbidden: `06-finance/`, `07-legal/`, `08-admin/insurance/`, `08-admin/freelancers/`, `.ssh/`, `.aws/`, `.env*`
- System paths protected: `forge/dev/`, `~/.claude/rules/`, `~/.claude/scripts/` — do not delete/move.
- MCP config: project `.mcp.json` | global `~/.claude.json > mcpServers` (`~/.claude/.mcp.json` NOT recognized).

## Install paths (CRITICAL)

- `FORGE_ROOT` env var default `~/forge`. Other paths require explicit export.

---

## Git (HIGH)

- Conventional Commits: feat/fix/docs/style/refactor/test/chore
- Branches: main(prod), feature/*, fix/*. Squash merge only, PR required.
- AI commit trailer: `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
- No direct commit to main, no force push, no `.env` commit, no `--no-verify`.

## Parallel execution (HIGH)

- Parallel tasks → **Agent Teams** (default) | simple search/single-file → **Subagent** (lightweight)
- Models: Lead→Opus 4.7 | Impl/Writing→Sonnet 4.6 | Search→Haiku 4.5
- Worktree: use `isolation: "worktree"` when parallel-editing the same file.

## PM / Notion (HIGH)

- **Notion Tasks = single source of truth** (todo.md is for initial registration only).
- Human override wins: if `last_edited_by=person`, AI must not overwrite.
- Bug/feature registration: only on **explicit request**. DB URL in `forge-workspace.json > notionDBs`.

## Command execution mode (HIGH)

- Forge multi-phase commands run in **write mode** (internal [STOP] gates are approval points).
- On Plan mode detection: emit warning and halt immediately.

## Context compaction triggers (HIGH)

- At **70% token consumption**: recommend `/compact` — intentional summary within cache TTL (5 min).
- At **90% token consumption**: enforce `/compact` — quality-degradation threshold.
- Prefer natural split points (Phase transition, Wave handoff) over hard limits.
- Before Wave 2–3 parallel review: run `/compact` to minimize sub-agent context pollution.

## Tacit knowledge surfacing (HIGH)

- Failure reasons, exception patterns, operational nuances are NOT visible in code/commits. Record them explicitly in: **handover docs** (failed attempts + why), **CLAUDE.md** (scope rules/constraints), **memory** (cross-session learning).
- "Why this method was chosen and why others were rejected" is the key — leaving only outputs causes next session to repeat the same failures.
- Palantir FSR principle: observe and codify operational logic outside the system (workflow exceptions, user preferences, environment constraints).

---

## Deep loading routing (MEDIUM — load when needed)

| Task | Deep file |
|------|----------|
| Security | `always/security.md` |
| Git | `always/git.md` |
| Parallel/Agent | `cross-project/agent-teams.md` |
| Notion/PM | `always/pm-tools.md` |
| File naming | `always/file-naming.md` |
| Research | `always/research-methodology.md` |
| Content quality | `always/content-quality.md` |
| Cowork | `always/cowork-environment.md` |
| MCP/CLI | `always/mcp-vs-cli.md` |
| Asset generation | `always/resource-generation.md` |
| Cross-project | `cross-project/cross-project-pipeline.md` |
| Skill creation | `cross-project/skill-creation.md` |
| Harness design | PGE decomposition, self-eval separation, explicit rubric — see `pipeline.md` §harness |
| Pipeline Phases | `forge/.claude/rules-on-demand/forge-planning.md` |
| Plan mode | `~/.claude/rules-on-demand/plan-mode.md` |
| Telegram remote control | `~/.claude/rules-on-demand/telegram-remote-control.md` |

Deep source: `planning/rules-source/{scope}/{filename}` or `shared/{scope}/{filename}`
