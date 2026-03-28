#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# e2e-scaffold.sh - Bootstrap E2E pipeline for a new project
# =============================================================================
# Creates e2e-pipeline.json and hooks directory from template.
#
# Usage:
#   bash ${FORGE_ROOT:-$HOME/forge}/dev/scripts/e2e-scaffold.sh --project-root /path --name my-app
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../templates" && pwd)"
TEMPLATE_FILE="$TEMPLATE_DIR/e2e-pipeline-template.json"

# ── Args ──
PROJECT_ROOT=""
PROJECT_NAME=""

while [ $# -gt 0 ]; do
    case "$1" in
        --project-root) PROJECT_ROOT="$2"; shift 2 ;;
        --name)         PROJECT_NAME="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: $(basename "$0") --project-root <path> --name <app-name>"
            echo ""
            echo "Options:"
            echo "  --project-root  Target project directory"
            echo "  --name          Project name (used in config)"
            exit 0
            ;;
        *)  echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ -z "$PROJECT_ROOT" ]; then
    echo "Error: --project-root is required"
    exit 1
fi

if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="$(basename "$PROJECT_ROOT")"
fi

# ── Validate ──
if [ ! -d "$PROJECT_ROOT" ]; then
    echo "Error: Directory not found: $PROJECT_ROOT"
    exit 1
fi

if [ -f "$PROJECT_ROOT/e2e-pipeline.json" ]; then
    echo "Warning: e2e-pipeline.json already exists at $PROJECT_ROOT"
    echo "Skipping config generation."
else
    if [ ! -f "$TEMPLATE_FILE" ]; then
        echo "Error: Template not found: $TEMPLATE_FILE"
        exit 1
    fi

    # Generate config from template
    if command -v python3 > /dev/null 2>&1; then
        python3 -c "
import json
with open('$TEMPLATE_FILE') as f:
    data = json.load(f)
data['project']['name'] = '$PROJECT_NAME'
with open('$PROJECT_ROOT/e2e-pipeline.json', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
"
    else
        # Fallback: sed replacement
        sed "s/\"my-app\"/\"$PROJECT_NAME\"/" "$TEMPLATE_FILE" > "$PROJECT_ROOT/e2e-pipeline.json"
    fi

    echo "Created: $PROJECT_ROOT/e2e-pipeline.json"
fi

# ── Create hooks directory ──
HOOKS_DIR="$PROJECT_ROOT/scripts/e2e-hooks"
mkdir -p "$HOOKS_DIR"

if [ ! -f "$HOOKS_DIR/.gitkeep" ]; then
    touch "$HOOKS_DIR/.gitkeep"
    echo "Created: $HOOKS_DIR/.gitkeep"
fi

echo ""
echo "E2E scaffold complete for '$PROJECT_NAME'."
echo ""
echo "Next steps:"
echo "  1. Edit e2e-pipeline.json to match your project"
echo "  2. Add custom hooks in scripts/e2e-hooks/ (optional)"
echo "  3. Run: bash ${FORGE_ROOT:-$HOME/forge}/dev/scripts/e2e-runner.sh"
