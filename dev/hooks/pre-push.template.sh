#!/usr/bin/env bash
# pre-push hook template — Trine Layer 1 static checks
# Deployed by forge-sync. Customize CHECKS array per project.
set -euo pipefail

# --- Configuration (project-specific) ---
# Override TRINE_HOOKS_DIR if scripts are symlinked elsewhere
TRINE_HOOKS_DIR="${TRINE_HOOKS_DIR:-$(dirname "$0")/../scripts/checks}"
SEARCH_DIR="${TRINE_SEARCH_DIR:-.}"

# Checks to run: "central:{script}" or "local:{script}"
# central = from Trine hooks/checks/ (deployed via forge-sync)
# local = from project scripts/checks/ (project-specific)
CHECKS=(
  "central:check-secrets.sh"
  "central:check-json-integrity.sh"
  # Add project-specific checks below:
  # "local:check-deps.sh"
  # "local:check-i18n.sh"
)

# --- Execution ---
STEP=0
TOTAL=${#CHECKS[@]}

for check in "${CHECKS[@]}"; do
  STEP=$((STEP + 1))
  TYPE="${check%%:*}"
  SCRIPT="${check##*:}"

  if [ "$TYPE" = "central" ]; then
    SCRIPT_PATH="$TRINE_HOOKS_DIR/$SCRIPT"
  else
    SCRIPT_PATH="$(dirname "$0")/../scripts/checks/$SCRIPT"
  fi

  if [ ! -f "$SCRIPT_PATH" ]; then
    echo "[WARN] [$STEP/$TOTAL] Script not found: $SCRIPT_PATH (skipping)"
    continue
  fi

  echo "[$STEP/$TOTAL] Running $SCRIPT..."
  bash "$SCRIPT_PATH" "$SEARCH_DIR"
done

echo "All pre-push checks passed."
