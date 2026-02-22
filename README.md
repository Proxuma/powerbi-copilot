# Proxuma Power BI Copilot

Generate AI-powered reports and dashboard builders directly from your Power BI data using GitHub Copilot, Claude, or ChatGPT.

This package connects your AI assistant to Power BI via MCP (Model Context Protocol). You ask a business question, the AI queries your data model, and outputs a complete HTML report or dashboard builder with real numbers.

## What's included

| Component | Description |
|-----------|-------------|
| **MCP Server** | Python server that connects AI tools to Power BI and Microsoft Fabric APIs |
| **Report Prompt** | Generates standalone HTML reports with KPIs, data tables, analysis, and actionable findings |
| **Dashboard Prompt** | Generates interactive dashboard mockups with step-by-step Power BI build instructions |
| **PII Anonymization** | All data passes through Microsoft Presidio before reaching the AI — names, emails, and other PII are automatically masked |
| **Setup Wizard** | Auto-discovers workspaces and datasets — no manual GUID hunting |

## Requirements

- **Python 3.10+**
- **Power BI Pro or Premium Per User license** (for API access)
- **VS Code** with GitHub Copilot (Agent mode) or another MCP-compatible AI tool

No Azure app registration needed. The server uses Azure's public client ID for authentication.

## Quick Start

### One-liner install (macOS / Linux)

```bash
curl -sL proxuma.io/install | bash
```

### One-liner install (Windows PowerShell)

```powershell
irm proxuma.io/install.ps1 | iex
```

### Manual install

```bash
# 1. Clone the repo
git clone https://github.com/Proxuma/powerbi-copilot.git
cd powerbi-copilot

# 2. Run the installer — it installs deps and launches the setup wizard
./setup.sh          # macOS/Linux
.\setup.ps1         # Windows PowerShell

# 3. The wizard opens your browser for Microsoft sign-in,
#    then lets you pick your workspace and dataset.
#    Config is written automatically.

# 4. Open in VS Code, start Copilot Chat (Agent mode), type:
#powerbireport what is my monthly revenue trend?
```

That's it. No config files to edit, no GUIDs to hunt for.

## Enterprise Deployment

For IT admins deploying to multiple machines via MDM (Intune, JAMF, GPO):

```bash
# Pre-configured (skip interactive wizard)
./setup.sh --workspace-id "GUID" --dataset-id "GUID" --silent

# Config from IT-hosted endpoint
./setup.sh --config-url https://it.yourcompany.com/powerbi-mcp-config

# Headless / SSH environments
./setup.sh --device-code --workspace-id "GUID" --dataset-id "GUID"
```

Windows (Intune):
```powershell
.\setup.ps1 -WorkspaceId "GUID" -DatasetId "GUID" -Silent
```

Environment variables (override config.json — set via GPO/Intune):
- `POWERBI_MCP_WORKSPACE_ID` — default workspace
- `POWERBI_MCP_DATASET_ID` — default dataset
- `POWERBI_MCP_CONFIG` — full JSON config blob

## Available MCP Tools

Once the server is running, your AI assistant has access to these tools:

| Tool | Description |
|------|-------------|
| `list_workspaces` | List all Power BI workspaces you have access to |
| `list_datasets` | List all datasets in a workspace |
| `execute_dax` | Run a DAX query and get results |
| `search_schema` | Search for specific measures, columns, or tables (recommended) |
| `list_measures` | List all measure names in a dataset |
| `list_fabric_items` | List all items in a Fabric workspace |
| `get_schema` | Get the full schema (caution: can be >10MB) |

## Prompt Files

### `#powerbireport`
Generates a self-contained HTML report from your Power BI data. The output includes:
- Summary KPIs
- Data tables with real query results
- Collapsible DAX queries (copy-paste into Power BI Desktop)
- Analysis narrative
- Actionable findings
- FAQ section

### `#powerbidashboard`
Generates an interactive dashboard mockup with build instructions. The output includes:
- Visual preview with page tabs and sample data
- 15-25 DAX measures with copy buttons
- Step-by-step build instructions (written for beginners)
- Conditional formatting color rules

## Project Structure

```
powerbi-copilot/
├── server/
│   ├── server.py            # MCP server
│   ├── auth.py              # Shared authentication module
│   ├── wizard.py            # Setup wizard (auto-discovery)
│   ├── requirements.txt     # Python dependencies
│   └── config.example.json  # Example configuration
├── prompts/
│   ├── powerbireport.prompt.md    # Report generator prompt
│   └── powerbidashboard.prompt.md # Dashboard builder prompt
├── templates/
│   ├── mcp.json             # VS Code MCP config template
│   └── settings.json        # VS Code settings template
├── docs/
│   ├── first-run.md         # First-time setup & auth
│   └── troubleshooting.md   # Common issues & fixes
├── setup.sh                 # macOS/Linux installer
├── setup.ps1                # Windows PowerShell installer
├── install.sh               # One-liner web installer (macOS/Linux)
├── install.ps1              # Windows full installer
└── README.md
```

## How Authentication Works

The server uses Azure AD's public client flow — the same one Power BI Desktop uses. No app registration required.

1. The setup wizard (or first MCP tool call) opens a browser for Microsoft login
2. You sign in with your Power BI account
3. Tokens are cached in `~/.powerbi-mcp/`
4. Subsequent runs: no login needed (tokens refresh automatically)

The cached tokens are only stored on your machine. The MCP server never sends credentials to any third party.

## Compatibility

| AI Tool | Status |
|---------|--------|
| GitHub Copilot (VS Code, Agent mode) | Supported |
| Claude Code (CLI) | Supported |
| Claude Desktop | Supported (add to `claude_desktop_config.json`) |
| Cursor | Supported (add to MCP settings) |
| ChatGPT (via MCP plugin) | Experimental |

## License

Proprietary. Access by invitation only.
