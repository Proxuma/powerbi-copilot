#!/usr/bin/env bash
set -euo pipefail

# Proxuma Power BI Copilot — Setup Script
# Installs dependencies, configures VS Code MCP, and sets up prompt files.
# macOS and Linux only.

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CACHE_DIR="$HOME/.powerbi-mcp"
SERVER_DIR="$REPO_DIR/server"

info()  { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!!]${NC} $1"; }
fail()  { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }
step()  { echo -e "\n${BOLD}$1${NC}"; }

echo ""
echo "  Proxuma Power BI Copilot — Setup"
echo "  ================================"
echo ""

# ─── Step 1: Check Python ─────────────────────────────────────────

step "1/6  Checking Python..."

PYTHON=""
for candidate in python3.12 python3.11 python3.10 python3; do
    if command -v "$candidate" &>/dev/null; then
        version=$("$candidate" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+')
        major=$(echo "$version" | cut -d. -f1)
        minor=$(echo "$version" | cut -d. -f2)
        if [ "$major" -eq 3 ] && [ "$minor" -ge 10 ]; then
            PYTHON="$candidate"
            break
        fi
    fi
done

if [ -z "$PYTHON" ]; then
    fail "Python 3.10+ is required. Install it from https://python.org/downloads/"
fi

PYTHON_PATH="$(command -v "$PYTHON")"
PYTHON_VERSION="$("$PYTHON" --version 2>&1)"
info "Found $PYTHON_VERSION at $PYTHON_PATH"

# ─── Step 2: Install Python dependencies ──────────────────────────

step "2/6  Installing Python dependencies..."

"$PYTHON" -m pip install --quiet --upgrade pip
"$PYTHON" -m pip install --quiet -r "$SERVER_DIR/requirements.txt"
info "Python packages installed"

# ─── Step 3: Download spaCy model ─────────────────────────────────

step "3/6  Downloading spaCy language model..."

if "$PYTHON" -c "import spacy; spacy.load('en_core_web_sm')" 2>/dev/null; then
    info "spaCy model en_core_web_sm already installed"
else
    "$PYTHON" -m spacy download en_core_web_sm --quiet
    info "spaCy model en_core_web_sm downloaded"
fi

# ─── Step 4: Create cache directory ───────────────────────────────

step "4/6  Setting up cache directory..."

mkdir -p "$CACHE_DIR"

if [ ! -f "$CACHE_DIR/config.json" ]; then
    cp "$SERVER_DIR/config.example.json" "$CACHE_DIR/config.json"
    info "Created $CACHE_DIR/config.json — edit this file to set your workspace/dataset IDs"
else
    info "$CACHE_DIR/config.json already exists"
fi

# ─── Step 5: Set up VS Code MCP configuration ────────────────────

step "5/6  Configuring VS Code MCP..."

VSCODE_DIR="$REPO_DIR/.vscode"
mkdir -p "$VSCODE_DIR"

cat > "$VSCODE_DIR/mcp.json" <<EOF
{
  "servers": {
    "powerbi": {
      "command": "$PYTHON_PATH",
      "args": ["$SERVER_DIR/server.py"],
      "env": {}
    }
  }
}
EOF

info "Created .vscode/mcp.json"

# ─── Step 6: Copy prompt files to .github/prompts ─────────────────

step "6/6  Setting up prompt files..."

PROMPTS_DIR="$REPO_DIR/.github/prompts"
mkdir -p "$PROMPTS_DIR"

cp "$REPO_DIR/prompts/powerbireport.prompt.md" "$PROMPTS_DIR/powerbireport.prompt.md"
cp "$REPO_DIR/prompts/powerbidashboard.prompt.md" "$PROMPTS_DIR/powerbidashboard.prompt.md"

info "Prompt files copied to .github/prompts/"

# ─── Done ─────────────────────────────────────────────────────────

echo ""
echo "  ================================"
echo -e "  ${GREEN}Setup complete!${NC}"
echo ""
echo "  Next steps:"
echo "  1. Open this folder in VS Code"
echo "  2. Edit $CACHE_DIR/config.json"
echo "     - Add your workspace ID and dataset ID"
echo "     - Find these in Power BI Service → Settings → About"
echo "  3. Open Copilot Chat (Ctrl+Shift+I / Cmd+Shift+I)"
echo "  4. Switch to Agent mode"
echo "  5. Type: #powerbireport what is my monthly revenue trend?"
echo "  6. On first use, a browser window opens for Azure login"
echo ""
echo "  For help: see docs/first-run.md and docs/troubleshooting.md"
echo ""
