# ═══════════════════════════════════════════════════════════════════════
#  Proxuma Power BI Copilot — Installer (Windows)
#
#  Double-click install.bat to run this script.
#  Or run directly: powershell -ExecutionPolicy Bypass -File install.ps1
#
#  This script checks prerequisites, installs everything automatically,
#  runs the setup wizard, and opens VS Code when done.
#
#  Enterprise flags:
#    -WorkspaceId "GUID"     Pre-configure workspace
#    -DatasetId "GUID"       Pre-configure dataset
#    -ConfigUrl "URL"        Download config from IT endpoint
#    -Silent                 No prompts (MDM/Intune)
#    -DeviceCode             Headless auth (no browser)
#    -SkipWizard             Manual config (old behavior)
# ═══════════════════════════════════════════════════════════════════════

param(
    [string]$WorkspaceId,
    [string]$DatasetId,
    [string]$ConfigUrl,
    [switch]$Silent,
    [switch]$DeviceCode,
    [switch]$SkipWizard
)

$ErrorActionPreference = "Continue"

# ── Paths ──
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ServerDir = Join-Path $RepoDir "server"
$CacheDir = Join-Path $env:USERPROFILE ".powerbi-mcp"

# ── Helpers ──
function Ok($msg)   { Write-Host "  $([char]0x2713) $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "  ! $msg" -ForegroundColor Yellow }
function Err($msg)  { Write-Host "  x $msg" -ForegroundColor Red }
function Step($msg) { Write-Host "`n  $msg" -ForegroundColor Cyan }
function PauseFor($msg) {
    if (-not $Silent) {
        Write-Host ""
        Write-Host "  $msg" -ForegroundColor Yellow
        Write-Host ""
        Read-Host "  Press Enter when ready"
    }
}

# ── Banner ──
if (-not $Silent) { Clear-Host }
Write-Host ""
Write-Host "  +====================================================+" -ForegroundColor White
Write-Host "  |                                                    |" -ForegroundColor White
Write-Host "  |   Proxuma Power BI Copilot                         |" -ForegroundColor White
Write-Host "  |                                                    |" -ForegroundColor White
Write-Host "  |   Your data stays on your tenant.                  |" -ForegroundColor DarkGray
Write-Host "  |   Your AI stays on your machine.                   |" -ForegroundColor DarkGray
Write-Host "  |                                                    |" -ForegroundColor White
Write-Host "  +====================================================+" -ForegroundColor White
Write-Host ""
if (-not $Silent) {
    Write-Host "  This installer checks your system, installs dependencies," -ForegroundColor DarkGray
    Write-Host "  and configures everything. Takes about 5 minutes." -ForegroundColor DarkGray
}

# ═════════════════════════════════════════════════════════════════════
#  1. Python 3.10+
# ═════════════════════════════════════════════════════════════════════
Step "1/8  Checking Python 3.10+..."

function Find-Python {
    foreach ($candidate in @("python3", "python", "py -3")) {
        try {
            # Handle "py -3" which is two arguments
            if ($candidate -eq "py -3") {
                $ver = & py -3 --version 2>&1
                $exe = "py"
            } else {
                $ver = & $candidate --version 2>&1
                $exe = $candidate
            }
            if ($ver -match "Python (\d+)\.(\d+)") {
                $major = [int]$Matches[1]
                $minor = [int]$Matches[2]
                if ($major -eq 3 -and $minor -ge 10) {
                    return $exe
                }
            }
        } catch {}
    }
    return $null
}

$Python = Find-Python
$WingetAvailable = $false
try { if (Get-Command winget -ErrorAction SilentlyContinue) { $WingetAvailable = $true } } catch {}

if (-not $Python) {
    Err "Python 3.10+ not found on your system"
    Write-Host ""

    if ($WingetAvailable) {
        Write-Host "  Installing Python via winget..." -ForegroundColor White
        winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements 2>$null
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $Python = Find-Python
    }

    if (-not $Python) {
        Write-Host "  Opening the Python download page..." -ForegroundColor White
        Start-Process "https://www.python.org/downloads/windows/"
        Write-Host ""
        Write-Host "  IMPORTANT: Check 'Add Python to PATH' during installation!" -ForegroundColor Yellow
        Write-Host "  This checkbox appears on the very first screen of the installer." -ForegroundColor DarkGray
        PauseFor "Install Python 3.10+, then come back here."

        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $Python = Find-Python
    }

    if (-not $Python) {
        Err "Python still not found. Please install Python 3.10+ and run this installer again."
        Write-Host "  Make sure 'Add Python to PATH' was checked during installation." -ForegroundColor DarkGray
        Write-Host ""
        if (-not $Silent) { Read-Host "  Press Enter to close" }
        exit 1
    }
}

# Resolve full path
if ($Python -eq "py") {
    $PythonPath = (Get-Command py).Source
    $PythonVersion = & py -3 --version 2>&1
    $PythonArgs = @("-3")
} else {
    $PythonPath = (Get-Command $Python).Source
    $PythonVersion = & $Python --version 2>&1
    $PythonArgs = @()
}
Ok "Found $PythonVersion at $PythonPath"

function Invoke-Python {
    param([string[]]$Arguments)
    if ($Python -eq "py") {
        & py -3 @Arguments
    } else {
        & $Python @Arguments
    }
}

# ═════════════════════════════════════════════════════════════════════
#  2. VS Code
# ═════════════════════════════════════════════════════════════════════
Step "2/8  Checking VS Code..."

$VSCodeFound = $false
$VSCodePaths = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
    "$env:ProgramFiles\Microsoft VS Code\Code.exe",
    "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
)
foreach ($p in $VSCodePaths) {
    if (Test-Path $p) { $VSCodeFound = $true; break }
}
try { if (Get-Command code -ErrorAction SilentlyContinue) { $VSCodeFound = $true } } catch {}

if ($VSCodeFound) {
    Ok "VS Code found"
} else {
    Err "VS Code not found"
    Write-Host ""

    $Installed = $false
    if ($WingetAvailable) {
        Write-Host "  Installing VS Code via winget..." -ForegroundColor White
        winget install -e --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
            Ok "VS Code installed via winget"
            $Installed = $true
            $VSCodeFound = $true
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        }
    }

    if (-not $Installed) {
        Write-Host "  Opening the VS Code download page..." -ForegroundColor White
        Start-Process "https://code.visualstudio.com/download"
        Write-Host ""
        Write-Host "  Download and install VS Code." -ForegroundColor White
        PauseFor "Install VS Code, then come back here."

        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        foreach ($p in $VSCodePaths) {
            if (Test-Path $p) { $VSCodeFound = $true; break }
        }
        try { if (Get-Command code -ErrorAction SilentlyContinue) { $VSCodeFound = $true } } catch {}
    }

    if ($VSCodeFound) {
        Ok "VS Code found"
    } else {
        Warn "VS Code not detected yet - continuing anyway."
        Warn "You can install it later and open this folder in VS Code."
    }
}

# ═════════════════════════════════════════════════════════════════════
#  3. Git
# ═════════════════════════════════════════════════════════════════════
Step "3/8  Checking Git..."

$GitFound = $false
try { if (Get-Command git -ErrorAction SilentlyContinue) { $GitFound = $true } } catch {}

if ($GitFound) {
    Ok "Git found: $(git --version 2>&1)"
} else {
    Warn "Git not found"

    $Installed = $false
    if ($WingetAvailable) {
        Write-Host "  Installing Git via winget..." -ForegroundColor White
        winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
            Ok "Git installed via winget"
            $Installed = $true
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        }
    }

    if (-not $Installed) {
        Write-Host "  Opening the Git download page..." -ForegroundColor White
        Start-Process "https://git-scm.com/downloads/win"
        PauseFor "Install Git, then come back here."
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    try {
        if (Get-Command git -ErrorAction SilentlyContinue) {
            Ok "Git found: $(git --version 2>&1)"
        } else {
            Warn "Git not detected - continuing anyway."
        }
    } catch {
        Warn "Git not detected - continuing anyway."
    }
}

# ═════════════════════════════════════════════════════════════════════
#  4. Python dependencies
# ═════════════════════════════════════════════════════════════════════
Step "4/8  Installing Python dependencies..."
Write-Host "  This may take a minute on first run..." -ForegroundColor DarkGray

Invoke-Python @("-m", "pip", "install", "--quiet", "--upgrade", "pip") 2>$null

$reqFile = Join-Path $ServerDir "requirements.txt"
try {
    Invoke-Python @("-m", "pip", "install", "--quiet", "-r", $reqFile)
    Ok "Python packages installed (mcp, azure-identity, presidio, spacy)"
} catch {
    Warn "Retrying with --user flag..."
    Invoke-Python @("-m", "pip", "install", "--quiet", "--user", "-r", $reqFile)
    Ok "Python packages installed (user mode)"
}

# ═════════════════════════════════════════════════════════════════════
#  5. spaCy language model
# ═════════════════════════════════════════════════════════════════════
Step "5/8  Downloading PII detection model..."

$SpacyInstalled = $false
try {
    Invoke-Python @("-c", "import spacy; spacy.load('en_core_web_sm')") 2>$null
    if ($LASTEXITCODE -eq 0) { $SpacyInstalled = $true }
} catch {}

if ($SpacyInstalled) {
    Ok "spaCy en_core_web_sm already installed"
} else {
    Invoke-Python @("-m", "spacy", "download", "en_core_web_sm", "--quiet")
    Ok "spaCy en_core_web_sm downloaded"
}

# ═════════════════════════════════════════════════════════════════════
#  6. VS Code MCP + prompt files + settings
# ═════════════════════════════════════════════════════════════════════
Step "6/8  Configuring VS Code..."

# Cache directory
if (-not (Test-Path $CacheDir)) {
    New-Item -ItemType Directory -Force -Path $CacheDir | Out-Null
}

# MCP server registration
$VSCodeDir = Join-Path $RepoDir ".vscode"
if (-not (Test-Path $VSCodeDir)) {
    New-Item -ItemType Directory -Force -Path $VSCodeDir | Out-Null
}

$ServerPyPath = (Join-Path $ServerDir "server.py")
if ($Python -eq "py") {
    $PythonExe = (Get-Command py).Source
} else {
    $PythonExe = $PythonPath
}

$mcpConfig = @{
    servers = @{
        powerbi = @{
            command = $PythonExe
            args = @($ServerPyPath)
            env = @{}
        }
    }
} | ConvertTo-Json -Depth 4

$mcpConfig | Set-Content (Join-Path $VSCodeDir "mcp.json") -Encoding UTF8
Ok "Created .vscode/mcp.json"

# VS Code settings
$SettingsPath = Join-Path $VSCodeDir "settings.json"
if (-not (Test-Path $SettingsPath)) {
    @"
{
  "chat.agent.enabled": true,
  "chat.promptFiles": true,
  "chat.mcp.enabled": true
}
"@ | Set-Content $SettingsPath -Encoding UTF8
    Ok "Created .vscode/settings.json (Agent mode enabled)"
} else {
    Ok ".vscode/settings.json already exists"
}

# Prompt files
$PromptsDir = Join-Path $RepoDir ".github\prompts"
if (-not (Test-Path $PromptsDir)) {
    New-Item -ItemType Directory -Force -Path $PromptsDir | Out-Null
}
Copy-Item (Join-Path $RepoDir "prompts\powerbireport.prompt.md") $PromptsDir -Force 2>$null
Copy-Item (Join-Path $RepoDir "prompts\powerbidashboard.prompt.md") $PromptsDir -Force 2>$null
Ok "Prompt files installed to .github\prompts\"

# ═════════════════════════════════════════════════════════════════════
#  7. Configuration — set up Power BI connection
# ═════════════════════════════════════════════════════════════════════
Step "7/8  Setting up configuration..."

$ConfigPath = Join-Path $CacheDir "config.json"

# If enterprise flags provided, write config directly
if ($WorkspaceId -or $DatasetId -or $ConfigUrl) {
    if ($ConfigUrl) {
        # Download config from IT endpoint
        try {
            Invoke-WebRequest -Uri $ConfigUrl -OutFile $ConfigPath -UseBasicParsing
            Ok "Downloaded config from $ConfigUrl"
        } catch {
            Warn "Could not download config from $ConfigUrl"
        }
    }

    if ($WorkspaceId -or $DatasetId) {
        # Create or update config with provided IDs
        $config = @{}
        if (Test-Path $ConfigPath) {
            try { $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json -AsHashtable } catch { $config = @{} }
        }
        if ($WorkspaceId) { $config["default_workspace_id"] = $WorkspaceId }
        if ($DatasetId) { $config["default_dataset_id"] = $DatasetId }
        if (-not $config.ContainsKey("workspaces")) { $config["workspaces"] = @{} }
        if (-not $config.ContainsKey("datasets")) { $config["datasets"] = @{} }
        $config | ConvertTo-Json -Depth 4 | Set-Content $ConfigPath -Encoding UTF8
        Ok "Config created with provided workspace/dataset IDs"
    }
} else {
    # Standard install: copy example config
    if (-not (Test-Path $ConfigPath)) {
        Copy-Item (Join-Path $ServerDir "config.example.json") $ConfigPath
        Ok "Created $ConfigPath"
        Warn "Edit this file to add your workspace and dataset IDs"
    } else {
        Ok "Config already exists at $ConfigPath"
    }
}

# ═════════════════════════════════════════════════════════════════════
#  8. GitHub Copilot extension
# ═════════════════════════════════════════════════════════════════════
Step "8/8  Installing GitHub Copilot extension..."

$CodeAvailable = $false
try { if (Get-Command code -ErrorAction SilentlyContinue) { $CodeAvailable = $true } } catch {}

if ($VSCodeFound -and $CodeAvailable) {
    try {
        code --install-extension GitHub.copilot --force 2>$null
        Ok "GitHub Copilot extension installed"
    } catch {
        Warn "Could not install Copilot automatically"
    }
    try { code --install-extension GitHub.copilot-chat --force 2>$null; Ok "GitHub Copilot Chat extension installed" } catch {}
} elseif ($VSCodeFound) {
    Warn "VS Code found but 'code' command not in PATH"
    Write-Host "  Open VS Code, then install GitHub Copilot from the Extensions marketplace." -ForegroundColor DarkGray
} else {
    Warn "Skipped - VS Code not installed yet"
    Write-Host "  Install the GitHub Copilot extension after installing VS Code." -ForegroundColor DarkGray
}

# ═════════════════════════════════════════════════════════════════════
#  Done!
# ═════════════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  +====================================================+" -ForegroundColor White
Write-Host "  |                                                    |" -ForegroundColor White
Write-Host "  |   $([char]0x2713) Setup complete!                              |" -ForegroundColor Green
Write-Host "  |                                                    |" -ForegroundColor White
Write-Host "  +====================================================+" -ForegroundColor White
Write-Host ""
Write-Host "  Two things left to do:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Add your Power BI workspace and dataset IDs" -ForegroundColor White
Write-Host ""
Write-Host "     Open $ConfigPath and fill in:" -ForegroundColor Cyan
Write-Host "     - default_workspace_id  - from the Power BI URL" -ForegroundColor DarkGray
Write-Host "     - default_dataset_id    - from the Power BI URL" -ForegroundColor DarkGray
Write-Host ""
Write-Host "     How to find them: open app.powerbi.com, go to your workspace," -ForegroundColor DarkGray
Write-Host "     click a dataset. The IDs are in the browser URL bar." -ForegroundColor DarkGray
Write-Host ""
Write-Host "  2. Open this folder in VS Code and try it" -ForegroundColor White
Write-Host ""
Write-Host "     Open Copilot Chat -> switch to Agent mode -> type:" -ForegroundColor DarkGray
Write-Host "     #powerbireport what is my monthly revenue trend?" -ForegroundColor Cyan
Write-Host ""
Write-Host "     The first time, a browser window opens for Microsoft login." -ForegroundColor DarkGray
Write-Host "     After that, you're authenticated automatically." -ForegroundColor DarkGray

# Open VS Code with this project
if ($VSCodeFound -and $CodeAvailable) {
    Write-Host ""
    Write-Host "  Opening VS Code..." -ForegroundColor DarkGray
    try { code $RepoDir 2>$null } catch {}
}

# Open config.json for editing
if (-not $Silent) {
    Write-Host "  Opening config.json for editing..." -ForegroundColor DarkGray
    try { notepad $ConfigPath } catch {}
}

Write-Host ""
Write-Host "  Questions? hello@proxuma.io" -ForegroundColor DarkGray
Write-Host "  Full guide: open product-page.html in your browser" -ForegroundColor DarkGray
Write-Host ""
