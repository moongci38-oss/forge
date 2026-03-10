# SIGIL — AI Business Workspace Instructions

> **Strategy & Idea Generation Intelligent Loop**
> 1인 기업 전체 업무를 위한 AI 워크스페이스. 아이디어에서 개발 준비 완료까지 4-Stage 파이프라인으로 리서치 → 컨셉 → 기획서 → 기획 패키지를 생성한다.

---

## Workspace Context

**소유자**: 1인 기업 운영자 (풀스택 개발자 겸 사업가)
**비전**: 백엔드 개발자 1명이 AI Agent Teams로 6개 약점 영역(시장조사, 기획, 디자인, 마케팅, 콘텐츠, 운영)을 80% 이상 보완

### 사용 환경

| 환경 | 사용자 | 주요 작업 |
|------|--------|----------|
| **Claude Code (CLI)** | 개발자 | Agent Teams, 스크립트 실행, Git 작업 |
| **Claude Desktop Cowork** | 비개발자 | 리서치, 문서 작성, 콘텐츠 기획 |

> Cowork 환경 상세(MCP 매핑, Hooks 대체, 보안)는 `.claude/rules/business-core.md` 참조.

### 멀티 프로젝트 워크스페이스

| 프로젝트 | 경로 | 설명 |
|---------|------|------|
| **SIGIL (Business)** | `./` | 비즈니스/기획 문서 (현재 워크스페이스) |
| **Portfolio** | `sigil-workspace.json` 참조 | Next.js + NestJS 웹 개발 |
| **GODBLADE** | `sigil-workspace.json` 참조 | Unity 게임 프로젝트 (C#) |

---

## 3-Track Folder Structure

```
A. 제품 사업 (01~05, 10)  → 수익 활동 (시장조사, 기획, 마케팅, 콘텐츠, 디자인, 운영)
B. 회사 경영 (06~08)      → 민감 영역 (재무, 법무, 경영관리) — AI 접근 금지
C. 시스템 (09-tools)      → AI 워크스페이스 운영 도구
```

### Directory Layout

```
sigil/
├── .claude/                        # Claude Code configuration
│   ├── agents/                     # AI agent definitions (9 active + 6 archived)
│   ├── skills/                     # Skill packages (9 active + 10 archived)
│   ├── commands/                   # Slash commands (8 active + 16 archived)
│   ├── hooks/                      # Event hooks (6 hooks)
│   ├── rules/                      # Compiled rules (auto-generated, loaded at session start)
│   └── settings.json               # Claude Code settings (Agent Teams, hooks, plugins)
│
├── 01-research/                    # Track A: Research
│   ├── projects/                   # [gitignored] Project-specific research outputs
│   └── videos/                     # YouTube analysis config
│
├── 02-product/                     # Track A: Product planning
│   └── projects/                   # [gitignored] PRD/GDD/concept deliverables
│
├── 03-marketing/                   # Track A: Marketing
│   └── projects/                   # [gitignored] Campaign/SEO/ads deliverables
│
├── 04-content/                     # Track A: Content
│   └── projects/                   # [gitignored] Blog/newsletter/social deliverables
│
├── 05-design/                      # Track A: Design
│   └── projects/                   # [gitignored] UI/brand/mockup deliverables
│
├── 08-admin/                       # Track B: Administration (restricted)
│
├── 09-tools/                       # Track C: System tools
│   ├── rules-source/               # Rule source files (Frontmatter, build input)
│   │   ├── always/                 # Always-active rules (security, git, naming, research)
│   │   ├── sigil/                  # SIGIL pipeline rules (S1-S4, governance, handoff)
│   │   ├── cross-project/          # Cross-project rules (agent-teams, pipeline)
│   │   ├── cowork/                 # Cowork environment rules
│   │   └── trine/                  # Trine integration rules
│   ├── templates/                  # SIGIL templates (GDD, PRD, DoD, test strategy, etc.)
│   ├── components-library/         # Agent/skill archive
│   ├── skills-library/             # External skill library
│   ├── prompts/                    # Prompt templates
│   └── docs/                       # Internal documentation
│
├── 10-operations/                  # Track A: Operations & handoff
│   ├── handoff-to-dev/             # SIGIL → Dev project deliverables
│   ├── handoff-from-dev/           # Dev → SIGIL feedback
│   └── shared-assets/              # Shared assets (branding, glossary)
│
├── scripts/                        # Automation scripts
│   ├── sigil.sh                    # SIGIL CLI (main entry point)
│   ├── manage-rules.sh             # Rules-as-Code build system
│   ├── manage-skills.sh            # Skill lifecycle management
│   ├── manage-components.sh        # Component lifecycle management
│   ├── sigil-gate-check.sh         # Stage gate verification
│   ├── sigil-wave2-trace.sh        # S4 Wave 2 traceability
│   ├── sigil-validate-workspace.sh # Workspace validation
│   ├── sigil-metrics.sh            # Pipeline metrics
│   ├── sigil-research-index.sh     # Research index
│   ├── sigil-adr-index.sh          # ADR index
│   ├── deploy-symlinks.sh          # Symlink deployment to dev projects
│   ├── verify-all.sh               # Full workspace verification
│   ├── mcp-health-check.sh         # MCP server status check
│   ├── weekly-report/              # Weekly research automation (GitHub Actions)
│   ├── yt-analyzer/                # YouTube analysis pipeline
│   └── daily-system-review/        # Daily system review automation
│
├── docs/guides/                    # Setup guides (PUBLIC)
├── CLAUDE.md                       # This file — workspace instructions
├── sigil-workspace.example.json    # Workspace config template
├── .mcp.json.example               # MCP server config template
└── .env.example                    # Environment variable template
```

### Public vs Private

| Category | Git Status | Content |
|----------|:----------:|---------|
| **PUBLIC** | tracked | agents, skills, commands, hooks, rules, templates, scripts, guides |
| **PRIVATE** | gitignored | project outputs (research, PRD/GDD, design, marketing, content) |

Personal config (`sigil-workspace.json`, `.mcp.json`, `.env`) is gitignored. Copy from `.example` files.

---

## SIGIL Pipeline

```
S1 Research → S2 Concept → S3 Design Document → S4 Planning Package → Trine (development)
     ↓             ↓              ↓                      ↓
  [STOP]        [STOP]         [STOP]                 [STOP]
  리서치 리뷰    비전 승인       기획서 승인              개발 진입
```

### Stages

| Stage | Trigger | Key Agents | Deliverables |
|:-----:|---------|------------|--------------|
| **S1** Research | `/research` | research-coordinator, academic-researcher, fact-checker | Integrated research report |
| **S2** Concept | `/lean-canvas` | — | Lean Canvas + Go/No-Go score (80+ = Go) |
| **S3** Design Doc | `/prd` or `/gdd` | 2-3 competing agents (회의) | .md + .pptx (both required) |
| **S4** Planning | pipeline-orchestrator | technical-writer, cto-advisor, ux-researcher | 4 deliverables (see below) |

### S4 Deliverables

| # | Document | Content |
|:-:|----------|---------|
| 1 | `s4-detailed-plan.md` | Screen-level behavior + data flow + sitemap |
| 2 | `s4-development-plan.md` | Tech stack + architecture + ADR + session roadmap + WBS |
| 3 | `s4-uiux-spec.md` | Wireframes + component specs + interaction patterns |
| 4 | `s4-test-strategy.md` | Test hierarchy/tools/coverage targets |

### Pipeline Flexibility

- **Soft dependencies** (skippable): S1→S2, S2→S3 (if existing materials exist)
- **Hard dependencies** (must maintain order): S3→S4→Trine

### Path Resolution

All output paths are resolved from `sigil-workspace.json` `folderMap`:
```
{folderMap.product}/{project}/ → e.g., 02-product/projects/my-app/
{folderMap.research}/{project}/ → e.g., 01-research/projects/my-app/
```

---

## Components

### Agents (9 active)

| Agent | Role | Model Tier |
|-------|------|:----------:|
| `pipeline-orchestrator` | Pipeline S1→S4 orchestration + multi-project parallel | Opus |
| `research-coordinator` | S1 research orchestration (Fan-out/Fan-in) | Opus |
| `academic-researcher` | Scholarly sources, peer-reviewed papers, citations | Haiku |
| `fact-checker` | Fact verification, source credibility assessment | Haiku |
| `gdd-writer` | Game Design Document authoring | Sonnet |
| `technical-writer` | S4 planning package authoring (4 deliverables) | Sonnet |
| `cto-advisor` | S4 technical review (architecture, ADR) | Sonnet |
| `ux-researcher` | S4 UX verification (wireframes, interaction) | Sonnet |
| `yt-video-analyst` | YouTube transcript analysis | Sonnet |

### Skills (9 active)

| Skill | Purpose |
|-------|---------|
| `content-creator` | SEO-optimized marketing content |
| `cto-advisor` | Technical leadership, architecture guidance |
| `frontend-design` | Production-grade frontend UI design |
| `playwright-cli` | Browser automation (testing, screenshots) |
| `product-manager-toolkit` | RICE prioritization, customer interviews, sprints |
| `requirements-clarity` | Ambiguous requirements Q&A resolution |
| `nestjs-expert` | NestJS backend best practices |
| `nextjs-best-practices` | Next.js frontend best practices |
| `postgres-best-practices` | PostgreSQL database best practices |

### Slash Commands (8 active)

| Command | Description |
|---------|-------------|
| `/prd` | Write PRD (web/app projects) |
| `/gdd` | Write GDD (game projects) |
| `/research` | Start market research workflow |
| `/lean-canvas` | Create Lean Canvas business model |
| `/generate-image` | AI image generation (NanoBanana MCP) |
| `/yt` | YouTube video transcript extraction + analysis |
| `/yt-analyze` | YouTube transcript analysis only |
| `/trine` | SIGIL → Trine handoff |

### Hooks (6)

| Hook | Trigger | Function |
|------|---------|----------|
| `session-context.sh` | SessionStart | Inject workspace context |
| `block-sensitive-files.sh` | PreToolUse (Edit/Write) | Block access to sensitive folders (06~08) |
| `block-sensitive-bash.sh` | PreToolUse (Bash) | Block sensitive path commands |
| `require-date-prefix.sh` | PreToolUse (Edit/Write) | Enforce date prefix on filenames |
| `no-force-push.sh` | PreToolUse (Bash) | Block `git push --force` |
| `auto-build-rules.sh` | PostToolUse (Edit/Write) | Auto-build rules when source modified |

---

## Rules-as-Code System

Rules are authored in `09-tools/rules-source/` with frontmatter metadata, then compiled to `.claude/rules/` for session loading.

| Source Scope | Files | Compiled To |
|-------------|-------|-------------|
| `always/` | security, git, file-naming, research, cowork-env (6 files) | `business-core.md` |
| `sigil/` | governance, S1-S4, structure, outputs, handoff (9 files) | `sigil-compiled.md` |
| `cross-project/` | agent-teams, cross-project-pipeline (2 files) | `business-core.md` |
| `cowork/` | cowork-safety (1 file) | `business-core.md` |
| `trine/` | (reference only, deployed to dev projects) | — |

### Rule Management CLI

```bash
bash scripts/manage-rules.sh list          # List all rules
bash scripts/manage-rules.sh validate      # Validate rule sources
bash scripts/manage-rules.sh build         # Compile rules-source → .claude/rules/
bash scripts/manage-rules.sh stats         # Token statistics
```

---

## Component Management

```bash
# Skills
bash scripts/manage-skills.sh list                    # List all skills
bash scripts/manage-skills.sh enable <skill-name>     # Enable a skill
bash scripts/manage-skills.sh disable <skill-name>    # Disable (move to _archive)
bash scripts/manage-skills.sh audit                   # Audit skill health

# Agents & Commands
bash scripts/manage-components.sh list                # List components
bash scripts/manage-components.sh enable <name>       # Enable component
bash scripts/manage-components.sh disable <name>      # Disable (move to _archive)
bash scripts/manage-components.sh token-estimate      # Estimate token usage
```

---

## MCP Servers & Plugins

### MCP Servers

| Server | Scope | Purpose |
|--------|:-----:|---------|
| **filesystem** | project | Workspace file access |
| **Sequential Thinking** | project | Complex strategic planning |
| **Notion** | project | Notion page/DB integration (PM tool) |
| **NanoBanana** | user | Google Gemini AI image generation/editing |
| **Stitch** | user | AI UI mockup generation |
| **Lighthouse** | user | Web performance/accessibility audit |
| **A11y** | user | Accessibility checks |

### Enabled Plugins

| Plugin | Marketplace | Purpose |
|--------|------------|---------|
| **product-management** | knowledge-work-plugins | Planning, PRD, roadmap |
| **marketing** | knowledge-work-plugins | Campaigns, content, SEO |
| **data** | knowledge-work-plugins | Data analysis, dashboards |
| **playground** | claude-plugins-official | Visual exploration (SIGIL) |
| **code-review** | claude-plugins-official | PR code review |
| **security-guidance** | claude-plugins-official | Security guidance |
| **superpowers** | claude-plugins-official | Workflow skills |

---

## Agent Teams

Enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in `.claude/settings.json`.

### Orchestration Patterns

| Pattern | When | Example |
|---------|------|---------|
| **Fan-out/Fan-in** | Independent parallel tasks | S1 research (market/tech/legal parallel) |
| **Pipeline** | Sequential dependencies | S1→S2→S3→S4 |
| **Competing Hypotheses** | Finding optimal solution | S3 agent meeting |
| **Watchdog** | Safety-critical changes | Large deployments |

### Model Hierarchy (60-70% cost reduction)

| Role | Model | Purpose |
|------|-------|---------|
| Lead (orchestrator) | Opus 4.6 | Judgment, synthesis, meeting arbiter |
| Document authoring | Sonnet 4.6 | Reports, analysis, deliverables |
| Search/exploration | Haiku 4.5 | Fact-checking, trend collection |

---

## CI/CD

### GitHub Actions

| Workflow | Schedule | Purpose |
|----------|----------|---------|
| Weekly Research Report | Monday 00:00 UTC | Auto-generate weekly research → Notion upload → git commit |

---

## Golden Rules

### Do's
- Include sources (URL, date) in all research outputs
- Write in Korean by default; use English for technical terms (병기)
- Prioritize Agent Teams for parallelizable work
- Resolve all paths from `sigil-workspace.json` `folderMap`
- Use date prefix format: `YYYY-MM-DD-{description}.{ext}`

### Don'ts
- **Never** access Track B folders (06-finance, 07-legal, 08-admin/insurance, 08-admin/freelancers)
- **Never** commit `.env`, credentials, API keys, or Track B data
- **Never** modify skill/component library originals directly (use management scripts)
- **Never** assert unverified market data as fact
- **Never** use `git push --force` on main/master
- **Never** skip `--no-verify` (pre-commit hooks must run)
- **Never** delete/overwrite `~/.claude/trine/`, `~/.claude/rules/`, `~/.claude/scripts/`

---

## Git Conventions

- **Branch strategy**: `main` (production), `feature/*` (new features), `fix/*` (bug fixes)
- **Commit format**: Conventional Commits (`feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:`)
- **Merge strategy**: Squash merge only, PR required
- **AI co-authoring**: Add `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>` to AI-generated commits

---

## SIGIL → Trine Integration

S4 completion triggers automatic handoff to development projects:

```
SIGIL S4 Gate PASS → Handoff doc auto-generated → Symlinks to dev project → Trine auto-activates
```

Handoff creates symlinks in the dev project's `{symlinkBase}/` directory (configured in `sigil-workspace.json`).
Source of truth is always the SIGIL workspace — dev projects reference via symlink only.

---

## Output Preferences

- **Documents**: Markdown default
- **Language**: Korean default; English for international materials
- **File naming**: `YYYY-MM-DD-{description}.{ext}`
- **Project outputs**: `{folder}/projects/{project}/YYYY-MM-DD-s{N}-{topic}.md`

---

## Quick Reference: Key Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | This file — workspace instructions |
| `.claude/settings.json` | Claude Code settings (env, hooks, plugins) |
| `.claude/rules/*.md` | Compiled rules (auto-loaded at session start) |
| `sigil-workspace.json` | Workspace config (paths, project mappings) — **read first** |
| `.mcp.json` | MCP server configuration |
| `.env` | Environment variables (API keys) |
| `09-tools/rules-source/` | Rule source files (edit here, then build) |
| `09-tools/templates/` | SIGIL templates (GDD, PRD, DoD, test strategy, UI/UX spec) |

---

*Last Updated: 2026-03-10 (Comprehensive update — full component inventory, directory layout, pipeline details, CI/CD)*
