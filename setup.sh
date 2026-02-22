#!/usr/bin/env bash
set -euo pipefail

# Proxuma Power BI Copilot — Setup Script
# Installs dependencies, runs the setup wizard, and configures VS Code MCP.
# macOS and Linux.
#
# Usage:
#   ./setup.sh                                          # Interactive wizard
#   ./setup.sh --workspace-id XXX --dataset-id YYY      # Enterprise: pre-configured
#   ./setup.sh --config-url https://it.acme.com/config   # Enterprise: config from URL
#   ./setup.sh --skip-wizard                             # Manual: old behavior
#   ./setup.sh --silent --workspace-id X --dataset-id Y  # MDM/Intune (no prompts)
#   ./setup.sh --device-code                             # Headless (SSH)

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

# ─── Parse CLI flags ─────────────────────────────────────────────

SKIP_WIZARD=false
SILENT=false
DEVICE_CODE=false
WORKSPACE_ID=""
DATASET_ID=""
CONFIG_URL=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-wizard)  SKIP_WIZARD=true; shift ;;
        --silent)       SILENT=true; shift ;;
        --device-code)  DEVICE_CODE=true; shift ;;
        --workspace-id) WORKSPACE_ID="$2"; shift 2 ;;
        --dataset-id)   DATASET_ID="$2"; shift 2 ;;
        --config-url)   CONFIG_URL="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: ./setup.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --workspace-id GUID    Pre-configure workspace (skip picker)"
            echo "  --dataset-id GUID      Pre-configure dataset (skip picker)"
            echo "  --config-url URL       Download config from IT-hosted endpoint"
            echo "  --skip-wizard          Skip wizard, configure manually"
            echo "  --silent               No interactive prompts (requires IDs or URL)"
            echo "  --device-code          Use device code flow (headless/SSH)"
            echo "  -h, --help             Show this help"
            exit 0
            ;;
        *) fail "Unknown option: $1. Use --help for usage." ;;
    esac
done

echo ""
echo "  Proxuma Power BI Copilot — Setup"
echo "  ================================"
echo ""

# ─── Step 1: Check Python ─────────────────────────────────────────

step "1/8  Checking Python..."

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

step "2/8  Installing Python dependencies..."

"$PYTHON" -m pip install --quiet --upgrade pip
"$PYTHON" -m pip install --quiet -r "$SERVER_DIR/requirements.txt"
info "Python packages installed"

# ─── Step 3: Download spaCy model ─────────────────────────────────

step "3/8  Downloading spaCy language model..."

if "$PYTHON" -c "import spacy; spacy.load('en_core_web_sm')" 2>/dev/null; then
    info "spaCy model en_core_web_sm already installed"
else
    "$PYTHON" -m spacy download en_core_web_sm --quiet
    info "spaCy model en_core_web_sm downloaded"
fi

# ─── Step 4: Create cache directory ───────────────────────────────

step "4/8  Setting up cache directory..."

mkdir -p "$CACHE_DIR"
info "$CACHE_DIR ready"

# ─── Step 5: Set up VS Code MCP configuration ────────────────────

step "5/8  Configuring VS Code MCP..."

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

step "6/8  Setting up prompt files..."

PROMPTS_DIR="$REPO_DIR/.github/prompts"
mkdir -p "$PROMPTS_DIR"

cp "$REPO_DIR/prompts/powerbireport.prompt.md" "$PROMPTS_DIR/powerbireport.prompt.md"
cp "$REPO_DIR/prompts/powerbidashboard.prompt.md" "$PROMPTS_DIR/powerbidashboard.prompt.md"

info "Prompt files copied to .github/prompts/"

# ─── Step 7: Run setup wizard ─────────────────────────────────────

step "7/8  Connecting to Power BI..."

WIZARD_ARGS=()

if [ -n "$WORKSPACE_ID" ]; then
    WIZARD_ARGS+=(--workspace-id "$WORKSPACE_ID")
fi
if [ -n "$DATASET_ID" ]; then
    WIZARD_ARGS+=(--dataset-id "$DATASET_ID")
fi
if [ -n "$CONFIG_URL" ]; then
    WIZARD_ARGS+=(--config-url "$CONFIG_URL")
fi
if [ "$SILENT" = true ]; then
    WIZARD_ARGS+=(--silent)
fi
if [ "$DEVICE_CODE" = true ]; then
    WIZARD_ARGS+=(--device-code)
fi

if [ "$SKIP_WIZARD" = true ]; then
    # Old behavior: copy example config if not present
    if [ ! -f "$CACHE_DIR/config.json" ]; then
        cp "$SERVER_DIR/config.example.json" "$CACHE_DIR/config.json"
        warn "Created $CACHE_DIR/config.json — edit this file to set your workspace/dataset IDs"
    else
        info "$CACHE_DIR/config.json already exists"
    fi
    info "Wizard skipped (--skip-wizard)"
else
    "$PYTHON" "$SERVER_DIR/wizard.py" "${WIZARD_ARGS[@]}"
fi

# ─── Step 8: Verify ──────────────────────────────────────────────

step "8/8  Verifying setup..."

if [ -f "$CACHE_DIR/config.json" ]; then
    info "Config file exists at $CACHE_DIR/config.json"
else
    warn "No config file found — run the wizard or edit $CACHE_DIR/config.json manually"
fi

if [ -f "$CACHE_DIR/auth_record.json" ]; then
    info "Auth token cached"
else
    warn "No auth token — you'll be prompted to sign in on first use"
fi

# ─── Done ─────────────────────────────────────────────────────────

echo ""
echo "  ================================"
echo -e "  ${GREEN}Setup complete!${NC}"
echo ""
echo "  Next steps:"
echo "  1. Open this folder in VS Code"
echo "  2. Open Copilot Chat (Ctrl+Shift+I / Cmd+Shift+I)"
echo "  3. Switch to Agent mode and type:"
echo "     #powerbireport what is my monthly revenue trend?"
echo ""
echo "  For help: see docs/first-run.md and docs/troubleshooting.md"
echo ""
