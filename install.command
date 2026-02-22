#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  Proxuma Power BI Copilot — Installer (macOS / Linux)
#
#  macOS: Double-click this file in Finder.
#  Linux: Run `bash install.command` or `chmod +x install.command && ./install.command`
#
#  This script checks prerequisites, installs everything automatically,
#  and opens VS Code when done. If something is missing, it opens the
#  download page and waits for you to install it.
# ═══════════════════════════════════════════════════════════════════════
set -uo pipefail

# ── Colors ──
BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── Paths ──
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CACHE_DIR="$HOME/.powerbi-mcp"
SERVER_DIR="$REPO_DIR/server"

# ── Detect OS ──
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
elif [[ "$OSTYPE" == "linux"* ]]; then
    OS="linux"
fi

# ── Helpers ──
ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
err()  { echo -e "  ${RED}✗${NC} $1"; }
step() { echo -e "\n${BOLD}  $1${NC}"; }
pause_for() {
    echo ""
    echo -e "  ${YELLOW}$1${NC}"
    echo ""
    read -rp "  Press Enter when ready..." _
}
open_url() {
    if [ "$OS" = "mac" ]; then
        open "$1" 2>/dev/null
    elif command -v xdg-open &>/dev/null; then
        xdg-open "$1" 2>/dev/null
    else
        echo "  Open this URL manually: $1"
    fi
}

# ── Banner ──
clear
echo ""
echo -e "${BOLD}  ╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}  ║                                                  ║${NC}"
echo -e "${BOLD}  ║   Proxuma Power BI Copilot                       ║${NC}"
echo -e "${BOLD}  ║                                                  ║${NC}"
echo -e "${BOLD}  ║${NC}   ${DIM}Your data stays on your tenant.${NC}${BOLD}                ║${NC}"
echo -e "${BOLD}  ║${NC}   ${DIM}Your AI stays on your machine.${NC}${BOLD}                 ║${NC}"
echo -e "${BOLD}  ║                                                  ║${NC}"
echo -e "${BOLD}  ╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${DIM}This installer checks your system, installs dependencies,${NC}"
echo -e "  ${DIM}and configures everything. Takes about 5 minutes.${NC}"

# ═════════════════════════════════════════════════════════════════════
#  1. Python 3.10+
# ═════════════════════════════════════════════════════════════════════
step "1/8  Checking Python 3.10+..."

find_python() {
    for candidate in python3.12 python3.11 python3.10 python3; do
        if command -v "$candidate" &>/dev/null; then
            local version
            version=$("$candidate" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
            local major minor
            major=$(echo "$version" | cut -d. -f1)
            minor=$(echo "$version" | cut -d. -f2)
            if [ "$major" -eq 3 ] 2>/dev/null && [ "$minor" -ge 10 ] 2>/dev/null; then
                echo "$candidate"
                return 0
            fi
        fi
    done
    return 1
}

PYTHON=""
PYTHON=$(find_python) || true

if [ -z "$PYTHON" ]; then
    err "Python 3.10+ not found on your system"
    echo ""
    if [ "$OS" = "mac" ]; then
        echo "  Opening the Python download page..."
        open_url "https://www.python.org/downloads/macos/"
        echo ""
        echo -e "  ${BOLD}Download and install Python 3.12 from the page that just opened.${NC}"
        echo "  Run the .pkg installer and follow the steps."
    else
        echo "  Install Python 3.10+ using your package manager:"
        echo ""
        echo -e "  ${CYAN}Ubuntu/Debian:${NC}  sudo apt install python3.12"
        echo -e "  ${CYAN}Fedora:${NC}         sudo dnf install python3.12"
        echo -e "  ${CYAN}Arch:${NC}           sudo pacman -S python"
        echo ""
        echo "  Or download from: https://www.python.org/downloads/"
        open_url "https://www.python.org/downloads/"
    fi
    pause_for "Install Python 3.10+, then come back here."

    # Re-check
    PYTHON=$(find_python) || true
    if [ -z "$PYTHON" ]; then
        err "Python still not found. Please install Python 3.10+ and run this installer again."
        echo ""
        read -rp "  Press Enter to close..." _
        exit 1
    fi
fi

PYTHON_PATH="$(command -v "$PYTHON")"
PYTHON_VERSION="$("$PYTHON" --version 2>&1)"
ok "Found $PYTHON_VERSION at $PYTHON_PATH"

# ═════════════════════════════════════════════════════════════════════
#  2. VS Code
# ═════════════════════════════════════════════════════════════════════
step "2/8  Checking VS Code..."

VSCODE_FOUND=false
if [ "$OS" = "mac" ] && [ -d "/Applications/Visual Studio Code.app" ]; then
    VSCODE_FOUND=true
elif command -v code &>/dev/null; then
    VSCODE_FOUND=true
fi

if [ "$VSCODE_FOUND" = true ]; then
    ok "VS Code found"
else
    err "VS Code not found"
    echo ""
    echo "  Opening the VS Code download page..."
    open_url "https://code.visualstudio.com/download"
    echo ""
    echo -e "  ${BOLD}Download and install VS Code from the page that just opened.${NC}"
    if [ "$OS" = "mac" ]; then
        echo "  Drag the app to your Applications folder."
    fi
    pause_for "Install VS Code, then come back here."

    # Re-check
    if [ "$OS" = "mac" ] && [ -d "/Applications/Visual Studio Code.app" ]; then
        VSCODE_FOUND=true
    elif command -v code &>/dev/null; then
        VSCODE_FOUND=true
    fi

    if [ "$VSCODE_FOUND" = true ]; then
        ok "VS Code found"
    else
        warn "VS Code not detected yet — continuing anyway."
        warn "You can install it later and open this folder in VS Code."
    fi
fi

# ═════════════════════════════════════════════════════════════════════
#  3. Git
# ═════════════════════════════════════════════════════════════════════
step "3/8  Checking Git..."

if command -v git &>/dev/null; then
    ok "Git found: $(git --version 2>&1 | head -1)"
else
    if [ "$OS" = "mac" ]; then
        warn "Git not found — installing Xcode Command Line Tools..."
        echo ""
        echo "  A system dialog should appear asking to install developer tools."
        echo "  Click 'Install' and wait for it to finish."
        xcode-select --install 2>/dev/null || true
        pause_for "Complete the Xcode Command Line Tools installation."
    else
        warn "Git not found"
        echo "  Install Git using your package manager:"
        echo ""
        echo -e "  ${CYAN}Ubuntu/Debian:${NC}  sudo apt install git"
        echo -e "  ${CYAN}Fedora:${NC}         sudo dnf install git"
        pause_for "Install Git, then come back here."
    fi

    if command -v git &>/dev/null; then
        ok "Git found: $(git --version 2>&1 | head -1)"
    else
        warn "Git not detected — continuing anyway."
    fi
fi

# ═════════════════════════════════════════════════════════════════════
#  4. Python dependencies
# ═════════════════════════════════════════════════════════════════════
step "4/8  Installing Python dependencies..."
echo -e "  ${DIM}This may take a minute on first run...${NC}"

"$PYTHON" -m pip install --quiet --upgrade pip 2>/dev/null || true
if "$PYTHON" -m pip install --quiet -r "$SERVER_DIR/requirements.txt" 2>/dev/null; then
    ok "Python packages installed (mcp, azure-identity, presidio, spacy)"
else
    # Try with --user flag if system pip fails
    warn "Retrying with --user flag..."
    "$PYTHON" -m pip install --quiet --user -r "$SERVER_DIR/requirements.txt"
    ok "Python packages installed (user mode)"
fi

# ═════════════════════════════════════════════════════════════════════
#  5. spaCy language model (for PII detection)
# ═════════════════════════════════════════════════════════════════════
step "5/8  Downloading PII detection model..."

if "$PYTHON" -c "import spacy; spacy.load('en_core_web_sm')" 2>/dev/null; then
    ok "spaCy en_core_web_sm already installed"
else
    if "$PYTHON" -m spacy download en_core_web_sm --quiet 2>/dev/null; then
        ok "spaCy en_core_web_sm downloaded"
    else
        "$PYTHON" -m spacy download en_core_web_sm
        ok "spaCy en_core_web_sm downloaded"
    fi
fi

# ═════════════════════════════════════════════════════════════════════
#  6. Configuration
# ═════════════════════════════════════════════════════════════════════
step "6/8  Setting up configuration..."

mkdir -p "$CACHE_DIR"

if [ ! -f "$CACHE_DIR/config.json" ]; then
    cp "$SERVER_DIR/config.example.json" "$CACHE_DIR/config.json"
    ok "Created config at $CACHE_DIR/config.json"
else
    ok "Config already exists at $CACHE_DIR/config.json"
fi

# ═════════════════════════════════════════════════════════════════════
#  7. VS Code MCP + prompt files + settings
# ═════════════════════════════════════════════════════════════════════
step "7/8  Configuring VS Code..."

# MCP server registration
VSCODE_DIR="$REPO_DIR/.vscode"
mkdir -p "$VSCODE_DIR"

cat > "$VSCODE_DIR/mcp.json" <<MCPEOF
{
  "servers": {
    "powerbi": {
      "command": "$PYTHON_PATH",
      "args": ["$SERVER_DIR/server.py"],
      "env": {}
    }
  }
}
MCPEOF
ok "Created .vscode/mcp.json"

# VS Code settings (Agent mode, prompt files, MCP)
if [ ! -f "$VSCODE_DIR/settings.json" ]; then
    cat > "$VSCODE_DIR/settings.json" <<SETEOF
{
  "chat.agent.enabled": true,
  "chat.promptFiles": true,
  "chat.mcp.enabled": true
}
SETEOF
    ok "Created .vscode/settings.json (Agent mode enabled)"
else
    ok ".vscode/settings.json already exists"
fi

# Prompt files
PROMPTS_DIR="$REPO_DIR/.github/prompts"
mkdir -p "$PROMPTS_DIR"
cp "$REPO_DIR/prompts/powerbireport.prompt.md" "$PROMPTS_DIR/" 2>/dev/null || true
cp "$REPO_DIR/prompts/powerbidashboard.prompt.md" "$PROMPTS_DIR/" 2>/dev/null || true
ok "Prompt files installed to .github/prompts/"

# ═════════════════════════════════════════════════════════════════════
#  8. GitHub Copilot extension
# ═════════════════════════════════════════════════════════════════════
step "8/8  Installing GitHub Copilot extension..."

COPILOT_INSTALLED=false
if [ "$VSCODE_FOUND" = true ] && command -v code &>/dev/null; then
    if code --install-extension GitHub.copilot --force 2>/dev/null; then
        ok "GitHub Copilot extension installed"
        COPILOT_INSTALLED=true
    else
        warn "Could not install Copilot automatically"
    fi
    code --install-extension GitHub.copilot-chat --force 2>/dev/null && ok "GitHub Copilot Chat extension installed" || true
elif [ "$VSCODE_FOUND" = true ]; then
    # VS Code exists but 'code' CLI not in PATH (common on macOS)
    warn "VS Code found but 'code' command not in PATH"
    echo "  Open VS Code → Cmd+Shift+P → 'Shell Command: Install code command in PATH'"
    echo "  Then install Copilot from the Extensions marketplace."
else
    warn "Skipped — VS Code not installed yet"
    echo "  Install the GitHub Copilot extension from the VS Code marketplace after installing VS Code."
fi

# ═════════════════════════════════════════════════════════════════════
#  Done!
# ═════════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}  ╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}  ║                                                  ║${NC}"
echo -e "${BOLD}  ║   ${GREEN}✓  Setup complete!${NC}${BOLD}                             ║${NC}"
echo -e "${BOLD}  ║                                                  ║${NC}"
echo -e "${BOLD}  ╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Two things left to do:${NC}"
echo ""
echo -e "  ${BOLD}1.${NC} Add your Power BI workspace and dataset IDs"
echo ""
echo -e "     Open ${CYAN}$CACHE_DIR/config.json${NC} and fill in:"
echo -e "     ${DIM}• default_workspace_id  — from the Power BI URL${NC}"
echo -e "     ${DIM}• default_dataset_id    — from the Power BI URL${NC}"
echo ""
echo -e "     ${DIM}How to find them: open app.powerbi.com, go to your workspace,${NC}"
echo -e "     ${DIM}click a dataset. The IDs are in the browser URL bar.${NC}"
echo ""
echo -e "  ${BOLD}2.${NC} Open this folder in VS Code and try it"
echo ""
echo -e "     Open Copilot Chat → switch to ${BOLD}Agent mode${NC} → type:"
echo -e "     ${CYAN}#powerbireport what is my monthly revenue trend?${NC}"
echo ""
echo -e "     ${DIM}The first time, a browser window opens for Microsoft login.${NC}"
echo -e "     ${DIM}After that, you're authenticated automatically.${NC}"

# Open VS Code with this project
if [ "$VSCODE_FOUND" = true ]; then
    echo ""
    echo -e "  ${DIM}Opening VS Code with this project...${NC}"
    if command -v code &>/dev/null; then
        code "$REPO_DIR" 2>/dev/null &
    elif [ "$OS" = "mac" ]; then
        open -a "Visual Studio Code" "$REPO_DIR" 2>/dev/null &
    fi
fi

# Open config.json for editing
echo -e "  ${DIM}Opening config.json for editing...${NC}"
if [ "$OS" = "mac" ]; then
    open "$CACHE_DIR/config.json" 2>/dev/null &
else
    if command -v xdg-open &>/dev/null; then
        xdg-open "$CACHE_DIR/config.json" 2>/dev/null &
    fi
fi

echo ""
echo -e "  ${DIM}Questions? hello@proxuma.io${NC}"
echo -e "  ${DIM}Full guide: open product-page.html in your browser${NC}"
echo ""
read -rp "  Press Enter to close..." _
