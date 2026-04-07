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
- **13 specialized AI agents**, **40+ skills**, **15+ slash commands**
- **gstack automation**: 7 auto-trigger skills across the pipeline (/investigate, /qa, /benchmark, /canary, /learn, /autoplan)
- **RAG system**: Hybrid vector+BM25 search across forge-outputs
- **Rules-as-Code**: Compilable rule system for automated pipeline governance
- **Notion as single source of truth** for task tracking

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
git clone ssh://git@ssh.lumir-ai.com:32361/lumir/forge.git ~/forge
cd ~/forge

# 2. Workspace config
cp forge-workspace.example.json forge-workspace.json
# → Set project paths in forge-workspace.json

# 3. Environment variables
cp .env.example .env
# → Set API keys in .env

# 4. Register global MCP servers + create ~/.claude/forge symlink
bash shared/scripts/setup-mcp.sh
# → Registers 10 global MCP servers to ~/.claude.json (idempotent)
# → Creates ~/.claude/forge → ~/forge/dev symlink (idempotent)

# 5. Install CLI tools (used alongside MCP)
bash shared/scripts/setup-cli.sh
# → Installs Lighthouse, Sentry CLI (for CI/batch)

# 6. [WSL+Windows only] Sync Windows .claude symlinks (Admin PowerShell)
#    Skip this step if using WSL-only or native Linux.
#    Open PowerShell as Administrator, then run:
#
#    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#    & "\\wsl.localhost\Ubuntu-22.04\home\<your-wsl-username>\forge\.claude\scripts\setup-windows-symlinks.ps1"
#
#    → Creates symlinks in C:\Users\<you>\.claude\ pointing to WSL ~/.claude/
#    → agents, commands, rules, skills, prompts, forge all synced automatically

# 7. Register learnings auto-load hook (one-time per machine)
# → Sync hook file to project first:
node ~/.claude/scripts/forge-sync.mjs sync --target <project> --include-recommended
# → Then add to ~/.claude/settings.json SessionStart hooks:
# {
#   "type": "command",
#   "command": "bash /path/to/project/.claude/hooks/load-learnings.sh"
# }

# 8. Run Claude Code
claude
```

## Structure

```
forge/
├── pipeline.md         ← Unified pipeline (Phase 1~12)
├── planning/           ← Phase 1~4 planning pipeline
│   ├── rules-source/   ← Planning rule sources
│   ├── templates/      ← Planning templates (PRD, GDD, Spec)
│   └── prompts/        ← Planning method prompts
├── dev/                ← Phase 6~12 dev + deploy pipeline
│   ├── rules/          ← Dev rules (deployed to projects)
│   ├── templates/      ← Dev templates
│   ├── scripts/        ← Dev scripts (forge-sync, etc.)
│   ├── schemas/        ← JSON schemas
│   └── gitlab-spec-kit/← GitLab CI pipelines + scripts
├── shared/             ← Shared between planning & dev
│   ├── docs/           ← Shared documentation
│   ├── scripts/        ← Management scripts (incl. rag/ for hybrid search)
│   └── cross-project/  ← Cross-project rules
├── .claude/            ← Claude Code config (team-shared)
│   ├── agents/         ← AI agents (13)
│   ├── skills/         ← Skill packages (40+)
│   ├── commands/       ← Slash commands (10)
│   ├── hooks/          ← Security/automation hooks (6)
│   └── rules/          ← Compiled rules
├── forge-workspace.json
├── .env.example
└── CLAUDE.md
```

## Task Management

**Notion Tasks DB is the single source of truth.** `todo.md` is only used for initial bulk registration at S4 Gate PASS.

| Action | Trigger | Mechanism |
|--------|---------|-----------|
| Initial registration | S4 Gate PASS | `sync-notion-tasks.py register <todo-file>` |
| Mark in-progress | Branch creation | GitLab CI → Notion API |
| Mark done | PR merge | GitLab CI → Notion API |
| Manual registration | On request | AI via Notion MCP or direct Notion entry |

**Registration criteria:** Only tasks that require a Spec document and a branch are registered.

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

> Project-specific MCPs (DB, Unity, etc.) are managed in each project's `.mcp.json`.

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

## Slash Commands

| Command | Description |
|---------|-------------|
| `/prd` | Write a PRD (app/web) |
| `/gdd` | Write a GDD (game) |
| `/research` | Start market research |
| `/lean-canvas` | Write a Lean Canvas |
| `/forge` | Planning → Dev handoff |
| `/daily-system-review` | Daily AI system analysis |
| `/weekly-research` | Weekly research pipeline |
| `/yt` | YouTube video analysis |
| `/qa` | Auto QA verification loop |
| `/benchmark` | Pre-PR performance comparison |
| `/canary` | Post-deploy health monitoring |
| `/autoplan` | CEO→Design→Eng 3-perspective review |
| `/investigate` | Root cause analysis (4-stage) |
| `/learn` | Cross-session learning store |
| `/rag-search` | Semantic document search |

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

On `init`, a `.specify/config.json` is auto-generated with Notion DB configuration.

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
# Edit rule source
vim planning/rules-source/always/my-rule.md

# Build compiled rules
bash shared/scripts/manage-rules.sh build
```

## Public vs Private

| Scope | Status | Contents |
|-------|:------:|----------|
| **PUBLIC** | tracked | agents, skills, commands, hooks, rules, templates, scripts |
| **PRIVATE** | gitignored | forge-workspace.json, .mcp.json, .env, project outputs |

Outputs are managed in a separate private repo (`forge-outputs`).

## Prefab Visual Library

Clone the prefab library for asset reuse:

```bash
git clone git@github.com:moongci38-oss/prefab-visual-library.git ~/prefab-visual-library
```

Referenced via `prefabLibraryRoot` in `forge-workspace.json`. Use the `library-search` skill to find existing assets before generating new ones.

## License

MIT
