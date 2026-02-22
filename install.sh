#!/usr/bin/env bash
set -euo pipefail

# Proxuma Power BI Copilot — One-liner Installer
# Usage: curl -sL proxuma.io/install | bash
# Enterprise: curl -sL proxuma.io/install | bash -s -- --workspace-id XXX --dataset-id YYY

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

REPO_URL="https://github.com/Proxuma/powerbi-copilot.git"
INSTALL_DIR="$HOME/powerbi-copilot"

echo ""
echo -e "${BOLD}  Proxuma Power BI Copilot — Installer${NC}"
echo ""

# Check git
if ! command -v git &>/dev/null; then
    echo -e "${RED}[FAIL]${NC} git is required. Install it first."
    exit 1
fi

# Clone or update
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${GREEN}[OK]${NC} Existing installation found at $INSTALL_DIR"
    cd "$INSTALL_DIR"
    git pull --quiet origin main 2>/dev/null || true
else
    echo "  Cloning repository..."
    git clone --quiet "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    echo -e "${GREEN}[OK]${NC} Cloned to $INSTALL_DIR"
fi

# Run setup with any passed-through arguments
echo ""
chmod +x setup.sh
exec ./setup.sh "$@"
