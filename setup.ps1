#Requires -Version 5.1
<#
.SYNOPSIS
    Proxuma Power BI Copilot — Windows Setup Script

.DESCRIPTION
    Installs dependencies, runs the setup wizard, and configures VS Code MCP.

.PARAMETER WorkspaceId
    Pre-configure workspace GUID (skip interactive picker)

.PARAMETER DatasetId
    Pre-configure dataset GUID (skip interactive picker)

.PARAMETER ConfigUrl
    Download config from IT-hosted endpoint

.PARAMETER SkipWizard
    Skip wizard, configure manually

.PARAMETER Silent
    No interactive prompts (requires IDs or URL)

.PARAMETER DeviceCode
    Use device code flow (headless/SSH environments)

.EXAMPLE
    .\setup.ps1
    .\setup.ps1 -WorkspaceId "xxx" -DatasetId "yyy"
    .\setup.ps1 -ConfigUrl "https://it.acme.com/config"
    .\setup.ps1 -SkipWizard
    .\setup.ps1 -Silent -WorkspaceId "xxx" -DatasetId "yyy"
#>

param(
    [string]$WorkspaceId,
    [string]$DatasetId,
    [string]$ConfigUrl,
    [switch]$SkipWizard,
    [switch]$Silent,
    [switch]$DeviceCode
)

$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CacheDir = Join-Path $env:USERPROFILE ".powerbi-mcp"
$ServerDir = Join-Path $RepoDir "server"

function Write-OK($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[!!] $msg" -ForegroundColor Yellow }
function Write-Fail($msg) { Write-Host "[FAIL] $msg" -ForegroundColor Red; exit 1 }
function Write-Step($msg) { Write-Host "`n$msg" -ForegroundColor White -NoNewline; Write-Host "" }

Write-Host ""
Write-Host "  Proxuma Power BI Copilot - Setup"
Write-Host "  ================================"
Write-Host ""

# --- Step 1: Check Python ---

Write-Step "1/8  Checking Python..."

$Python = $null
foreach ($candidate in @("python3.12", "python3.11", "python3.10", "python3", "python")) {
    try {
        $ver = & $candidate --version 2>&1
        if ($ver -match "Python (\d+)\.(\d+)") {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            if ($major -eq 3 -and $minor -ge 10) {
                $Python = $candidate
                break
            }
        }
    } catch { }
}

if (-not $Python) {
    Write-Fail "Python 3.10+ is required. Install from https://python.org/downloads/"
}

$PythonPath = (Get-Command $Python).Source
$PythonVersion = & $Python --version 2>&1
Write-OK "Found $PythonVersion at $PythonPath"

# --- Step 2: Install Python dependencies ---

Write-Step "2/8  Installing Python dependencies..."

& $Python -m pip install --quiet --upgrade pip
& $Python -m pip install --quiet -r (Join-Path $ServerDir "requirements.txt")
Write-OK "Python packages installed"

# --- Step 3: Download spaCy model ---

Write-Step "3/8  Downloading spaCy language model..."

$spacyCheck = & $Python -c "import spacy; spacy.load('en_core_web_sm')" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-OK "spaCy model en_core_web_sm already installed"
} else {
    & $Python -m spacy download en_core_web_sm --quiet
    Write-OK "spaCy model en_core_web_sm downloaded"
}

# --- Step 4: Create cache directory ---

Write-Step "4/8  Setting up cache directory..."

if (-not (Test-Path $CacheDir)) {
    New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
}
Write-OK "$CacheDir ready"

# --- Step 5: Set up VS Code MCP configuration ---

Write-Step "5/8  Configuring VS Code MCP..."

$VscodeDir = Join-Path $RepoDir ".vscode"
if (-not (Test-Path $VscodeDir)) {
    New-Item -ItemType Directory -Path $VscodeDir -Force | Out-Null
}

$serverPy = Join-Path $ServerDir "server.py"
$mcpConfig = @{
    servers = @{
        powerbi = @{
            command = $PythonPath
            args = @($serverPy)
            env = @{}
        }
    }
} | ConvertTo-Json -Depth 4

Set-Content -Path (Join-Path $VscodeDir "mcp.json") -Value $mcpConfig -Encoding UTF8
Write-OK "Created .vscode\mcp.json"

# --- Step 6: Copy prompt files ---

Write-Step "6/8  Setting up prompt files..."

$PromptsDir = Join-Path $RepoDir ".github\prompts"
if (-not (Test-Path $PromptsDir)) {
    New-Item -ItemType Directory -Path $PromptsDir -Force | Out-Null
}

Copy-Item (Join-Path $RepoDir "prompts\powerbireport.prompt.md") (Join-Path $PromptsDir "powerbireport.prompt.md") -Force
Copy-Item (Join-Path $RepoDir "prompts\powerbidashboard.prompt.md") (Join-Path $PromptsDir "powerbidashboard.prompt.md") -Force
Write-OK "Prompt files copied to .github\prompts\"

# --- Step 7: Run setup wizard ---

Write-Step "7/8  Connecting to Power BI..."

$wizardArgs = @()

if ($WorkspaceId) { $wizardArgs += "--workspace-id", $WorkspaceId }
if ($DatasetId) { $wizardArgs += "--dataset-id", $DatasetId }
if ($ConfigUrl) { $wizardArgs += "--config-url", $ConfigUrl }
if ($Silent) { $wizardArgs += "--silent" }
if ($DeviceCode) { $wizardArgs += "--device-code" }

if ($SkipWizard) {
    $configFile = Join-Path $CacheDir "config.json"
    if (-not (Test-Path $configFile)) {
        Copy-Item (Join-Path $ServerDir "config.example.json") $configFile
        Write-Warn "Created $configFile - edit this file to set your workspace/dataset IDs"
    } else {
        Write-OK "$configFile already exists"
    }
    Write-OK "Wizard skipped (-SkipWizard)"
} else {
    $wizardPy = Join-Path $ServerDir "wizard.py"
    & $Python $wizardPy @wizardArgs
}

# --- Step 8: Verify ---

Write-Step "8/8  Verifying setup..."

$configFile = Join-Path $CacheDir "config.json"
if (Test-Path $configFile) {
    Write-OK "Config file exists at $configFile"
} else {
    Write-Warn "No config file found - run the wizard or edit $configFile manually"
}

$authFile = Join-Path $CacheDir "auth_record.json"
if (Test-Path $authFile) {
    Write-OK "Auth token cached"
} else {
    Write-Warn "No auth token - you'll be prompted to sign in on first use"
}

# --- Done ---

Write-Host ""
Write-Host "  ================================"
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  Next steps:"
Write-Host "  1. Open this folder in VS Code"
Write-Host "  2. Open Copilot Chat (Ctrl+Shift+I)"
Write-Host "  3. Switch to Agent mode and type:"
Write-Host "     #powerbireport what is my monthly revenue trend?"
Write-Host ""
Write-Host "  For help: see docs\first-run.md and docs\troubleshooting.md"
Write-Host ""
