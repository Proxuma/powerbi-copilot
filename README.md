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

## Data Anonymization

All data that passes through the MCP server is automatically anonymized before it reaches the AI. Real names, emails, and other PII are replaced with consistent aliases (Client_A, Resource_1, etc.) that the AI uses in its output.

### How it works

1. **On first query**, the server loads all unique values from your configured sensitive columns (company names, resource names, contacts)
2. **Every response** passes through two anonymization layers:
   - **Deterministic lookup**: known entities get consistent aliases
   - **Presidio NLP**: catches unexpected PII in free-text fields
3. **After report generation**, restore real names locally:

```bash
# CLI
python -m server report.html -o report-real.html

# Or drag-and-drop mapping.json onto the report page
```

### Configuration

Edit `~/.powerbi-mcp/config.json`:

```json
{
  "anonymization": {
    "enabled": true,
    "sensitive_columns": {
      "client": ["'YourTable'[Company Name]"],
      "resource": ["'YourTable'[Full Name]"],
      "contact": ["'YourTable'[Contact Name]"]
    },
    "presidio_enabled": true
  }
}
```

The setup wizard (`python wizard.py`) auto-detects likely sensitive columns and lets you confirm.

### Audit Trail

Every session stores its mapping at `~/.powerbi-mcp/sessions/<id>/mapping.json`. This file never leaves your machine. Use it to:
- Verify exactly what was anonymized
- Restore real names in reports
- Provide compliance documentation

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

## Dashboard Renderer

The Dashboard Renderer is a self-contained HTML page where users paste JSON output from the AI agent to get a full interactive dashboard. The AI agent outputs two JSON objects (DASH_CONFIG + DATA), and the renderer builds the dashboard client-side.

### How it works

```
1. User asks: "Generate a dashboard for SLA performance"
2. AI agent queries Power BI via MCP tools
3. Agent outputs DASH_CONFIG + DATA as JSON (fits within token limits)
4. User opens the Dashboard Renderer
5. User pastes JSON → live dashboard with KPIs, sparklines, charts, and tables
6. Optional: download as standalone HTML file
```

### Pre-built Template Library

8 ready-to-use DASH_CONFIG templates in `templates/configs/`:

| Template | File | KPIs |
|----------|------|------|
| SLA Performance | `sla-performance.json` | FR SLA %, Resolution SLA %, Overdue |
| Ticket Volume | `ticket-volume.json` | Created, Resolved, Open, Backlog |
| Revenue & Billing | `revenue-billing.json` | Revenue, Hours, Avg Rate, Margin |
| Resource Utilization | `resource-utilization.json` | Billable %, Total Hours, Non-Billable |
| CSAT & Satisfaction | `csat-satisfaction.json` | Avg CSAT, Response Rate, Surveys |
| Patch Compliance | `patch-compliance.json` | Patched %, Critical, Overdue |
| Endpoint Health | `endpoint-health.json` | Online %, Alerts, Tickets |
| Project Performance | `project-performance.json` | Budget %, Actual Hours, Milestones |

## Hosting Options

Three tiers for hosting the Dashboard Renderer, from simplest to most integrated:

### Option A: Proxuma-Hosted (SaaS) — Free

The easiest path. Proxuma hosts the renderer, MSPs just paste JSON.

- **URL:** `proxuma.io/powerbi/dashboards/renderer/`
- **Template gallery:** `proxuma.io/powerbi/dashboards/` — pick a template, paste your data
- **Cost:** Free (included with Proxuma)
- **Setup:** None — just open the URL
- **Data privacy:** JSON is processed client-side only; no data sent to Proxuma servers

### Option B: Azure Static Web App (Customer Tenant) — Free

MSPs deploy their own renderer to their Azure tenant. Data never leaves their environment.

```bash
cd azure
./deploy-static.sh --name mycompany-dashboards
```

- **URL:** `https://mycompany-dashboards.azurestaticapps.net/dashboard-renderer.html`
- **Cost:** Free (Azure Static Web Apps Free tier — 100 GB bandwidth/month)
- **Setup:** 1 command, ~2 minutes
- **Benefits:** Custom domain, Azure AD auth possible, data stays in tenant
- **Files:** `azure/deploy-static.sh`, `azure/staticwebapp.config.json`

### Option C: Fabric / Power BI Embedded (Advanced)

For MSPs already on Microsoft Fabric who want native integration.

| Approach | Description | Complexity |
|----------|-------------|------------|
| SharePoint page | Embed the Azure Static Web App in an iframe on a SharePoint page | Low |
| Power BI paginated report | Embed dashboard HTML as a paginated report | Medium |
| Power BI custom visual | Custom visual that renders DASH_CONFIG/DATA JSON | High |

This is the most integrated option but requires Fabric capacity (F2+) or Power BI Premium.

### Pricing Comparison

| | Proxuma-Hosted | Azure Static Web App | Fabric Embedded |
|---|---|---|---|
| **Monthly cost** | Free | Free (100 GB/mo) | Fabric F2+ required |
| **Setup time** | 0 min | 2 min | 30+ min |
| **Custom domain** | No | Yes | N/A |
| **Azure AD auth** | No | Optional | Built-in |
| **Data in tenant** | Client-side only | Yes | Yes |

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
│   ├── dashboard-renderer.html    # Dashboard Renderer (v2)
│   ├── dashboard-shell.html       # Dashboard builder template
│   ├── report-shell.html          # Report template
│   ├── configs/                   # Pre-built DASH_CONFIG templates
│   │   ├── sla-performance.json
│   │   ├── ticket-volume.json
│   │   ├── revenue-billing.json
│   │   ├── resource-utilization.json
│   │   ├── csat-satisfaction.json
│   │   ├── patch-compliance.json
│   │   ├── endpoint-health.json
│   │   └── project-performance.json
│   ├── mcp.json             # VS Code MCP config template
│   └── settings.json        # VS Code settings template
├── azure/
│   ├── deploy.sh            # MCP server Azure Functions deployment
│   ├── deploy-static.sh     # Dashboard Renderer Static Web App deployment
│   ├── staticwebapp.config.json  # SWA route configuration
│   ├── host.json            # Azure Functions host config
│   └── requirements.txt     # Azure Functions Python deps
├── experiments/
│   └── RESULTS.md           # Copilot Studio experiment results
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
| Microsoft Copilot Studio | Supported (tested Mar 2026, JSON dashboard output) |
| GitHub Copilot (VS Code, Agent mode) | Supported |
| Claude Code (CLI) | Supported |
| Claude Desktop | Supported (add to `claude_desktop_config.json`) |
| Cursor | Supported (add to MCP settings) |
| ChatGPT (via MCP plugin) | Experimental |

## License

Proprietary. Access by invitation only.
