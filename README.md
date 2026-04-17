# Forge — Unified AI Pipeline System

[한국어](README.ko.md)

> **From idea to production — AI Subagents automate the full Phase 1~12 pipeline.**

```
Planning:  Phase 1 Research → Phase 2 Concept → Phase 3 Design Doc → Phase 4 Planning Package
                                                                                ↓
                                                                   Phase 5 Handoff + Setup
                                                                                ↓
Dev:       Phase 6 Session → Phase 7 Spec → Phase 8 Implement → Phase 9~12 Deploy
```

## What is Forge?

Forge is a unified pipeline for **solo developers and small teams** to systematically go from ideation to deployment using AI agents.

- **Planning** (Phase 1~4): Research, concept validation, design docs, planning packages
- **Dev** (Phase 6~12): Spec-driven development with SDD+DDD+TDD
- **15 specialized AI agents**, **66 skills**, **15+ slash commands**
- **PGE Harness**: Planner-Generator-Evaluator structure eliminates self-evaluation bias
- **RAG system**: Hybrid vector+BM25 search across forge-outputs
- **Rules-as-Code**: Compilable rule system for automated pipeline governance
- **Notion as single source of truth** for task tracking
- **Telegram Remote Control**: Monitor and control sessions remotely

### Core Workflow

```
Spec → Notion Registration → Branch → In Progress → PR → Done
```

Every task — including hotfixes — requires a Spec document before branch creation. No exceptions.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- Node.js 18+

## Quick Start

```bash
# 1. Clone
git clone git@github.com:moongci38-oss/forge.git ~/forge
cd ~/forge

# 2. Workspace config
cp forge-workspace.example.json forge-workspace.json
# → Set project paths in forge-workspace.json

# 3. Environment variables
cp .env.example .env
# → Set API keys in .env

# 4. Register global MCP servers
bash shared/scripts/setup-mcp.sh
# → Registers 10 global MCP servers to ~/.claude.json (idempotent)

# 5. Install CLI tools (used alongside MCP)
bash shared/scripts/setup-cli.sh
# → Installs Lighthouse, Sentry CLI (for CI/batch)

# 6. Register learnings auto-load hook (one-time per machine)
node ~/.claude/scripts/forge-sync.mjs sync --target <project> --include-recommended
# → Then add to ~/.claude/settings.json SessionStart hooks:
# {
#   "type": "command",
#   "command": "bash /path/to/project/.claude/hooks/load-learnings.sh"
# }

# 7. Run Claude Code
claude
```

## Structure

```
forge/
├── pipeline.md              ← Unified pipeline (Phase 1~12)
├── planning/                ← Phase 1~4 planning pipeline
│   ├── rules-source/        ← Planning rule sources
│   ├── templates/           ← Planning templates (PRD, GDD, Spec)
│   └── prompts/             ← Planning method prompts
├── dev/                     ← Phase 6~12 dev + deploy pipeline
│   ├── rules/               ← Dev rules (deployed to projects)
│   ├── templates/           ← Dev templates
│   ├── scripts/             ← Dev scripts (forge-sync, etc.)
│   ├── schemas/             ← JSON schemas
│   └── github-spec-kit/     ← GitHub Actions workflows + scripts
├── shared/                  ← Shared between planning & dev
│   ├── docs/                ← Shared documentation
│   ├── scripts/             ← Management scripts (incl. rag/ for hybrid search)
│   └── cross-project/       ← Cross-project rules
├── .claude/                 ← Claude Code config (team-shared)
│   ├── agents/              ← AI agents (15)
│   ├── skills/              ← Skill packages (66)
│   ├── commands/            ← Slash commands
│   ├── hooks/               ← Security/automation hooks (7)
│   └── rules/               ← Compiled rules
├── forge-workspace.json
├── .env.example
└── CLAUDE.md
```

## Task Management

**Notion Tasks DB is the single source of truth.** `todo.md` is only used for initial bulk registration at S4 Gate PASS.

| Action | Trigger | Mechanism |
|--------|---------|-----------|
| Initial registration | S4 Gate PASS | `sync-notion-tasks.py register <todo-file>` |
| Mark in-progress | Branch creation | GitHub Actions → Notion API |
| Mark done | PR merge | GitHub Actions → Notion API |
| Manual registration | On request | AI via Notion MCP or direct Notion entry |

**Human Override:** If `last_edited_by` is a person and the status differs from expected, AI skips the update (PM-IRON-1).

## MCP Servers

`setup-mcp.sh` registers these global MCP servers:

| Server | Purpose | API Key |
|--------|---------|:-------:|
| Brave Search | Web search | `BRAVE_API_KEY` |
| NanoBanana | Gemini image generation | `GEMINI_API_KEY` |
| Replicate | AI model execution | `REPLICATE_API_TOKEN` |
| Stitch | UI mockup generation | `STITCH_API_KEY` |
| Ludo | Game asset generation | `LUDO_API_KEY` |
| Sentry | Error tracking | - |
| Notion | Notion integration | - |
| Lighthouse | Web performance audit | - |
| Draw.io | Diagram generation | - |
| Magic UI | UI components | - |

### Self-Hosted: `forge-tools` MCP Server

Forge also ships its own MCP server (`shared/mcp/forge-tools-server.py`, FastMCP 3.2.3) that exposes 14 tools covering file I/O, Git, RAG search, web search/fetch, Notion, Telegram, and health monitoring. It runs locally on `http://localhost:8765/mcp` and is exposed to cloud-hosted **Managed Agents** through a permanent Cloudflare tunnel at `https://manager-agent.lumir-ai.com/mcp`. See the [Managed Agents](#managed-agents-cloud-automation) section below for the full tool list, infrastructure, and operational constraints.

> Project-specific MCPs (sequential-thinking, hwpx, etc.) are managed in each project's `.mcp.json`.

## Managed Agents (Cloud Automation)

Anthropic-hosted agents that run autonomously — no Claude Code session required. Built on a FastMCP 3.2.3 server exposing 14 tools to cloud agents, proxied through a permanent Cloudflare endpoint.

**MCP Server:** `https://manager-agent.lumir-ai.com/mcp` (permanent, Cloudflare-proxied)

### Registered Agents

| Agent | Purpose |
|-------|---------|
| `daily-system-review` | Daily AI/Agentic field change detection → forge-outputs + git commit |
| `weekly-research` | Weekly research pipeline (Wave 0→1 parallel collection + analysis) |
| `system-audit` | Full ACHCE 5-axis system audit orchestrator |
| `audit-agentic` | Agentic AI capability audit (autonomy, tool use, multi-agent) |
| `audit-context` | Context engineering audit (RAG, memory, 7-layer) |
| `audit-harness` | AI harness engineering audit (guardrails, observability) |
| `audit-cost` | AI cost efficiency audit (token economics, routing) |
| `audit-human-ai` | Human-AI boundary audit (autonomy levels, escalation) |

Agent IDs and environment IDs are tracked in `shared/mcp/forge-agent-ids.json`.

### MCP Server Tools (14)

`shared/mcp/forge-tools-server.py` exposes these tools to managed agents over `streamable-http`:

| Category | Tools |
|----------|-------|
| File I/O | `read_file`, `write_file`, `list_files`, `append_file` |
| Git | `git_status`, `git_commit`, `git_log` |
| Execution | `run_script` (whitelist-gated) |
| Search | `rag_search`, `web_search` (Brave API), `web_fetch` |
| Monitoring | `run_health_check` |
| Notifications | `telegram_notify` |
| Notion | `notion_create_page` |

### Running Agents

```bash
# Run agent locally (streams output, waits for completion)
python3 shared/scripts/run-managed-agent.py daily-system-review [YYYY-MM-DD]
python3 shared/scripts/run-managed-agent.py weekly-research
python3 shared/scripts/run-managed-agent.py system-audit

# MCP service management (WSL local, tmux-backed)
shared/scripts/forge-mcp-service.sh start|stop|restart|status
shared/scripts/forge-mcp-service.sh update-agents   # refresh agent MCP URL only
```

### Telegram Command Server

`shared/scripts/telegram-command-server.py` runs on the remote server and lets you trigger agents from Telegram without opening Claude Code:

- `run <agent>` — trigger any registered agent remotely
- `status` — check server status
- `agents` — list available agents

### Infrastructure

- Remote server: `manager-agent.lumir-ai.com` (Ubuntu 22.04, 183.111.8.37)
- Nginx reverse proxy → port 8765 (FastMCP, `/mcp` endpoint)
- Telegram command server: `tmux forge-telegram` session
- MCP server: `tmux forge-mcp` session
- `PERMANENT_MCP_URL` in `.env` → agents keep the same URL across restarts

### Operational Constraints

1. **`permission_policy: always_allow` is mandatory** — the default `always_ask` blocks MCP tool use indefinitely (no approver in cloud runs).
2. **FastMCP ≥ 3.2.3 transport** — SSE unsupported; use `streamable-http` only. Client URL: `http://localhost:8765/mcp` or `https://manager-agent.lumir-ai.com/mcp`.
3. **Tool name sync** — agent system prompts (SKILL.md) must match actual MCP tool names exactly, or `tool not found` errors will occur. Verify with `mcp list-tools` before re-registering.
4. **`BRAVE_API_KEY` must be unquoted** in `.env` — quoted values are parsed literally and cause Brave API 401.

## CLI Scripts

```bash
# Pipeline
bash shared/scripts/forge.sh                    # Forge CLI
bash shared/scripts/forge-gate-check.sh         # Gate pass verification
bash shared/scripts/forge-validate-workspace.sh # Workspace validation

# Component management
bash shared/scripts/manage-rules.sh {list|validate|build|stats}
bash shared/scripts/manage-skills.sh {list|enable|disable|audit}
bash shared/scripts/manage-components.sh {list|enable|disable}
```

## Skills & Commands

### Planning Pipeline

| Skill | Description |
|-------|-------------|
| `/prd` | Write a PRD (app/web) |
| `/gdd` | Write a GDD (game) |
| `/sdd` | Write an SDD (service design) |
| `/research` | Start market research |
| `/lean-canvas` | Write a Lean Canvas |
| `/forge` | Planning → Dev handoff |
| `/forge-status` | Check pipeline status |
| `/forge-onboard` | New member onboarding |
| `/forge-router` | Auto-route dev requests to Forge Dev pipeline |
| `/forge-planning-router` | Auto-route planning requests to appropriate Forge stage |

### Development Quality

| Skill | Description |
|-------|-------------|
| `/pge` | Planner-Generator-Evaluator quality harness. Runs Planner+Generator in main context; isolates Evaluator as subagent to prevent self-evaluation bias |
| `/qa` | Auto-generate test scenarios per Spec and run find→fix→retest loop. Auto-triggered at Phase 8 Check 6.7 PASS |
| `/benchmark` | Compare feature branch vs develop performance before PR (bundle size, test time, API latency). Auto-triggered at Phase 9 |
| `/canary` | 15-minute health monitoring after staging integration (error rate, response time, memory). Auto-triggered at Phase 10 |
| `/investigate` | 4-stage structured root-cause analysis. Enforces symptom→analysis→hypothesis→verify→fix order |
| `/autoplan` | Sequential review from CEO (business) → Design (UX) → Engineering (tech) perspectives. Auto-triggered after Phase 3 agent meeting |
| `/forge-fix` | Automated bug fix pipeline |
| `/forge-check-ui` | UI quality verification |
| `/forge-check-traceability` | Spec-to-implementation traceability check |
| `/forge-resume` | Resume interrupted pipeline session |
| `/forge-rollback` | Rollback pipeline to previous phase |
| `/spec-compliance-checker` | Verify traceability between Spec and implementation (FR mapping, tests, API contract, data model). Auto-triggered at Check 3.5 |
| `/inspection-checklist` | Final pre-PR checklist covering build/test, Spec traceability, UI quality, code review, and security |
| `/writing-plans` | Transform spec into TDD-oriented task sequence with exact file paths and 2-5 min steps |
| `/concise-planning` | Generate a clear, atomic implementation checklist for a coding task |
| `/requirements-clarity` | Clarify ambiguous requirements via focused dialogue before implementation |
| `/kaizen` | Continuous improvement guidelines (Kaizen, Poka-Yoke, YAGNI-based scope control) |

### AI System Audit (5-Axis ACHCE)

| Skill | Description |
|-------|-------------|
| `/system-audit` | Full 5-axis ACHCE system audit (Agentic + Context + Harness + Cost + Human-AI) |
| `/audit-agentic` | Audit agentic AI capabilities: autonomy, tool use, multi-agent coordination, maturity level |
| `/audit-context` | Audit context engineering: RAG, memory, context window management, knowledge architecture |
| `/audit-harness` | Audit AI harness engineering: evaluation systems, guardrails, observability, reliability |
| `/audit-cost` | Audit AI cost efficiency: token economics, model routing, caching strategy, inference optimization |
| `/audit-human-ai` | Audit Human-AI boundary design: autonomy levels, escalation design, gate patterns, trust calibration |

### Research & Content

| Skill | Description |
|-------|-------------|
| `/daily-system-review` | Collect daily AI/Agentic field data across 6 tiers and compare with our system |
| `/daily-analyze` | Re-run analysis only (skip collection) when raw-data.json already exists for the date |
| `/weekly-research` | Weekly research pipeline: collect 3 output types in parallel via subagents |
| `/weekly-analyze` | Re-run analysis only for weekly research when raw-data.json already exists |
| `/yt` | Analyze YouTube video(s): transcript extraction, structured summary, Notion upload |
| `/yt-analyze` | Cross-compare multiple videos in a cluster for consensus/divergence insights |
| `/rag-search` | Hybrid vector+BM25 semantic search across forge-outputs documents |
| `/wiki-sync` | Karpathy 3-layer (Raw→Wiki→Meta) extraction workflow. Propose updates from Raw docs to Obsidian vault with Human-in-the-loop approval |
| `/learn` | Store and retrieve cross-session learnings in learnings.jsonl |
| `/clip` | Save and analyze links |
| `/content-creator` | Create SEO-optimized marketing content (blog, social, content calendar, brand voice) |
| `/cto-advisor` | CTO-level strategic guidance: tech debt analysis, team scaling, ADR templates, DORA metrics |
| `/product-manager-toolkit` | PM frameworks: RICE prioritization, interview NLP analysis, PRD templates, DORA metrics |

### Government Grants

Grant-writing skills run at **project scope** (not global) so each grant project can keep its own guidelines, templates, and tone. Scaffold them under `forge-outputs/09-grants/{project}/.claude/skills/` when starting a new grant.

| Command / Skill | Scope | Description |
|-----------------|-------|-------------|
| `/grants` | global (router) | Router command that dispatches to the project's local grants skill |
| `/grants-status` | global | Check grant task progress across projects |
| `/rd-plan` | global | R&D government grant business plan generation pipeline with diagram/chart auto-generation |
| `grants-write` (skill) | **project** | Orchestrate grant document writing via analyst→strategist→writer pipeline. Lives in `{project}/.claude/skills/grants-write/` |
| `grants-review` (skill) | **project** | 5-axis automated review: guidelines/data/evaluator/tone/direction. Lives in `{project}/.claude/skills/grants-review/` |

### Documents & Assets

| Skill | Description |
|-------|-------------|
| `/pptx` | Create, read, edit, or convert PowerPoint (.pptx) files |
| `/docx` | Create, read, edit, or convert Word (.docx) files |
| `/pdf` | Read, merge, split, rotate, watermark, OCR PDF files |
| `/xlsx` | Create, read, edit, clean spreadsheet files (.xlsx, .csv, .tsv) |
| `/hwp2pdf` | Convert HWP files to PDF (preserves images, tables, shapes) |
| `/generate-image` | AI image generation via NanoBanana/FLUX/Gemini/Replicate |
| `/sync-todo` | Sync todo.md tasks to Notion |
| `/meeting` | Structure meeting notes and extract key decisions → save to forge-outputs |

### Design & Frontend

| Skill | Description |
|-------|-------------|
| `/frontend-design` | Create distinctive, production-grade frontend interfaces (React, Tailwind, shadcn/ui) |
| `/web-artifacts-builder` | Build complex multi-component HTML artifacts with state management and routing |
| `/ux-audit` | 9-item UX quality audit (contrast, font, touch target, layout, nav, states, responsive, a11y). Auto-triggered at Check 3.6 |
| `/ux-copy` | UX writing: microcopy, error messages, button labels, empty states, tooltips, onboarding |
| `/react-best-practices` | React/Next.js performance optimization (57 rules across 8 categories) |
| `/theme-factory` | Apply or generate visual themes for slides, docs, HTML pages (10 presets) |
| `/screenshot-analyze` | Analyze game/web/app screenshots via Gemini Vision: UI structure, color palette, implementation guide |
| `/user-research` | Plan, conduct, and synthesize user research: interview guides, usability tests, survey design, research questions |
| `/research-synthesis` | Synthesize user research data (transcripts, surveys, NPS, support tickets) into themes, insights, and recommendations |
| `/design-system-management` | Manage design tokens, component libraries, and pattern documentation |
| `/design-handoff` | Create comprehensive developer handoff documentation from designs (implementation specs, measurements, behavior notes) |
| `/design-critique` | Evaluate designs for usability, visual hierarchy, consistency, and adherence to design principles |

### Game Development

| Skill | Description |
|-------|-------------|
| `/game-asset-generate` | Orchestrate large-scale game asset production (sprites, VFX, BG, 3D, UI, audio) via Library-First + Soul prompts |
| `/game-qa` | 3-layer game UI/animation QA: parameter verification, runtime capture, human-required items list |
| `/game-logic-visualize` | Visualize game logic (FSM, probability tables, combat formulas, skill trees) as Mermaid/Draw.io/HTML simulator |
| `/game-reference-collect` | Systematically collect and analyze competitor game visuals (video, screenshots, logic) |
| `/style-train` | Extract visual style from 5-10 assets → generate style-guide.md or orchestrate Replicate LoRA fine-tuning |
| `/soul-prompt-craft` | Assemble 12-element Soul-Injected image generation prompts, optimized per model (FLUX/Gemini/Replicate) |
| `/asset-critic` | Quantitatively evaluate AI-generated assets on 6-axis rubric (5-point scale) |
| `/video-reference-guide` | Analyze game video frames via Gemini → generate animation/effects implementation guide |

### Skill & Agent Management

| Skill | Description |
|-------|-------------|
| `/skill-creator` | Guide for creating or updating Claude Code skills |
| `/skill-autoresearch` | Automatically measure and improve skill quality pipeline |
| `/hook-creator` | Create and configure Claude Code hooks (PreToolUse, PostToolUse, SessionStart, etc.) |
| `/subagent-creator` | Create specialized Claude Code subagents with custom system prompts |
| `/slash-command-creator` | Guide for creating Claude Code slash commands |
| `/code-quality-rules` | Detect semantic code quality issues (logic, architecture, UX) that static hooks miss |
| `/library-search` | Search Prefab Visual Library for existing assets before generating new ones |

## Automation Hooks (7)

| Hook | Trigger | Role |
|------|---------|------|
| `block-env-edit.sh` | PreToolUse | Block edits to sensitive files |
| `load-learnings.sh` | SessionStart | Auto-load previous learnings |
| `log-bash-commands.sh` | PostToolUse | Log all Bash commands |
| `session-count-check.sh` | SessionStart | Warn on multi-session conflicts |
| `cleanup-zombie-sessions.sh` | SessionStart | Clean up zombie sessions |
| `claude-notify.sh` | Completion event | Notify on task completion |
| `telegram-remote-control.sh` | Telegram message | Remote session control via Telegram |

## Project Sync

Forge deploys rules, templates, workflows, and scripts to registered projects via `forge-sync.mjs`.

```bash
# Register a new project
node ~/.claude/scripts/forge-sync.mjs init /path/to/project --name my-project

# Sync all projects
node ~/.claude/scripts/forge-sync.mjs sync

# Check sync status
node ~/.claude/scripts/forge-sync.mjs status
```

## Customization

### Adding a project

Add to `forge-workspace.json`:

```json
{
  "projects": {
    "my-project": {
      "devTarget": "/path/to/dev-project",
      "symlinkBase": "docs/planning/active/forge"
    }
  }
}
```

### Customizing rules

```bash
vim planning/rules-source/always/my-rule.md
bash shared/scripts/manage-rules.sh build
```

## Public vs Private

| Scope | Status | Contents |
|-------|:------:|----------|
| **PUBLIC** | tracked | agents, skills, commands, hooks, rules, templates, scripts |
| **PRIVATE** | gitignored | forge-workspace.json, .mcp.json, .env, project outputs |

Outputs are managed in a separate private repo (`forge-outputs`).

## Optional Components

Some skills require additional installation beyond the base setup.

### RAG Search (`/rag-search`)

Hybrid vector+BM25 semantic search across forge-outputs documents. Requires OpenAI embeddings.
→ **[Full setup guide](shared/docs/2026-04-10-setup-rag.md)**

```bash
# 1. Install Python packages
pip install -r ~/forge/shared/scripts/rag/requirements.txt

# 2. (Optional) OCR support for scanned documents
sudo apt install tesseract-ocr tesseract-ocr-kor

# 3. Ensure OPENAI_API_KEY is set in ~/forge/.env
#    Used for text-embedding-3-small

# 4. Build index (run once, then re-run when documents change)
bash ~/forge/shared/scripts/rag/setup.sh ~/forge-outputs/09-grants

# Usage in Claude Code:
# /rag-search platform franchise strategy
```

> Re-run `setup.sh` whenever new documents are added to forge-outputs.

---

### OpenSpace (`/delegate-task`, `/skill-discovery`)

Skill self-evolution framework by HKUDS. Runs in the background — no manual intervention needed during normal use.
→ **[Full setup guide](shared/docs/2026-04-10-setup-openspace.md)**

```bash
# 1. Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Install Python 3.12
uv python install 3.12

# 3. Clone and install OpenSpace
cd ~
git clone https://github.com/HKUDS/OpenSpace.git
cd OpenSpace
uv venv --python 3.12 .venv
source .venv/bin/activate
uv pip install pydantic-settings==2.13.0
uv pip install -e .

# 4. Verify installation
python -c "import openspace; print('OK')"
openspace-mcp --help

# 5. Set API key
echo "ANTHROPIC_API_KEY=your-key-here" > ~/OpenSpace/openspace/.env
# Or copy from forge .env:
grep ANTHROPIC_API_KEY ~/forge/.env > ~/OpenSpace/openspace/.env

# 6. Add to ~/forge/.mcp.json
# {
#   "mcpServers": {
#     "openspace": {
#       "command": "/home/<username>/OpenSpace/.venv/bin/openspace-mcp",
#       "toolTimeout": 600,
#       "env": {
#         "OPENSPACE_HOST_SKILL_DIRS": "/home/<username>/forge/.claude/skills",
#         "OPENSPACE_WORKSPACE": "/home/<username>/OpenSpace"
#       }
#     }
#   }
# }

# 7. Copy host skills
cp -r ~/OpenSpace/openspace/host_skills/delegate-task/ ~/forge/.claude/skills/
cp -r ~/OpenSpace/openspace/host_skills/skill-discovery/ ~/forge/.claude/skills/

# 8. Restart Claude Code (/clear) — delegate-task and skill-discovery will appear
```

| Skill | Triggered by |
|-------|-------------|
| `delegate-task` | Manual or auto during complex tasks |
| `skill-discovery` | Automatic skill quality monitoring |

**Troubleshooting**

| Problem | Fix |
|---------|-----|
| `Python 3.12 not found` | Re-run `uv python install 3.12` |
| `pydantic_settings install failed` | Run `uv pip install pydantic-settings==2.13.0` first |
| RAG `OPENAI_API_KEY not set` | Check `~/forge/.env` |
| OpenSpace MCP not connecting | Run `/clear` to restart. Verify `.mcp.json` path |
| `openspace-mcp: command not found` | Run `source ~/OpenSpace/.venv/bin/activate` |

---

### Obsidian Knowledge Wiki (`/wiki-sync`)

Compounding personal knowledge base built on Andrej Karpathy's [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — Raw sources (research, video analyses, daily/weekly reports) are distilled by AI into a permanent Obsidian vault with Human-in-the-loop approval. Supports bidirectional sync (WSL ↔ Obsidian vault), automatic LightRAG re-indexing, and mobile access via Git.

**Architecture (3-layer):**

```
Raw (forge-outputs/01-research/) → Wiki (forge-vault/concepts,tools,topics,people/) → Meta (_meta/MOC.md, questions.md)
```

```bash
# 1. Install Obsidian (desktop)
#    https://obsidian.md  →  "Open folder as Vault"  →  select /mnt/e/forge-vault
#    (Linux/WSL users: any path works; vault lives at E:\forge-vault by default)

# 2. Clone the vault repo (public mirror on GitHub)
git clone git@github.com:moongci38-oss/forge-vault.git /mnt/e/forge-vault

# 3. Verify the mirror inside forge-outputs
ls ~/forge-outputs/20-wiki/
# → CLAUDE.md, README.md, concepts/, tools/, topics/, people/, _meta/

# 4. Start the sync watcher (bidirectional rsync + 30s debounced LightRAG re-index + 5min auto git push)
bash ~/forge/shared/scripts/wiki-sync.sh --watch
# Logs: /tmp/wiki-sync.log, /tmp/wiki-index.log, /tmp/wiki-push.log
# One-shot sync (no watcher): bash ~/forge/shared/scripts/wiki-sync.sh

# 5. (Optional) Register as systemd/tmux service for always-on sync
#    See shared/scripts/wiki-sync.sh header for watch-mode flags

# 6. Build LightRAG wiki index (first time)
python3 ~/forge/shared/scripts/lightrag-pilot.py index --context wiki

# 7. Query the wiki in natural language
python3 ~/forge/shared/scripts/lightrag-pilot.py query "하네스 엔지니어링이 뭐야" hybrid --context wiki
```

**Usage in Claude Code:**

```
/wiki-sync              # Scan new Raw docs → propose wiki updates → Human approves → apply + re-index
/rag-search --context wiki {query}   # Semantic search over wiki only
```

**Lint & health checks (monthly cron at 09:00 KST):**

```bash
python3 ~/forge/shared/scripts/wiki-sync-lint.py      # Count un-promoted Raw docs
python3 ~/forge/shared/scripts/wiki-health-lint.py    # Broken refs / orphan / stub report
```

| File | Role |
|------|------|
| `forge-outputs/20-wiki/README.md` | Vault overview + Karpathy 3-layer principles |
| `forge-outputs/20-wiki/CLAUDE.md` | Schema (AI maintenance rules, auto-loaded) |
| `forge-outputs/20-wiki/_meta/context.md` | Business context (Track A/B/C) — required for all note callouts |
| `forge-outputs/20-wiki/_meta/index.md` | Content catalog (all notes by category) |
| `~/forge/.claude/skills/wiki-sync/SKILL.md` | 5-step workflow (Scan → Read → Match → Propose → Apply) |
| `~/forge/shared/scripts/wiki-sync.sh` | Bidirectional rsync watcher (vault ↔ 20-wiki) |
| `~/forge/shared/scripts/wiki-build-index.py` | Content catalog builder |
| `~/forge/shared/scripts/wiki-fix-dangling-refs.py` | Repair broken `[[wikilinks]]` |

> Mobile: install Obsidian app → pull from https://github.com/moongci38-oss/forge-vault. Git plugin handles periodic auto-pull.

---

### hwpx Tools (HWP Form Fill)

Fill HWP form templates programmatically. Used for government grant forms.

```bash
# Install hwpx MCP server
pip install hwpx-mcp-server   # or follow project-specific install

# Add to ~/forge/.mcp.json:
# {
#   "mcpServers": {
#     "hwpx": {
#       "type": "stdio",
#       "command": "/home/<username>/.local/bin/hwpx-mcp-server",
#       "args": ["--stdio"]
#     }
#   }
# }
```

---

## Prefab Visual Library

```bash
git clone git@github.com:moongci38-oss/prefab-visual-library.git ~/prefab-visual-library
```

Referenced via `prefabLibraryRoot` in `forge-workspace.json`. Use `/library-search` to find existing assets before generating new ones.

## License

MIT
