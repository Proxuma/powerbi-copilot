# First Run — Setup Wizard & Azure Login

When you run the installer (`setup.sh` or `setup.ps1`), the setup wizard handles authentication and configuration automatically.

## Prerequisites

- A Microsoft account with **Power BI Pro** or **Premium Per User** license
- The account must have access to at least one Power BI workspace with a dataset (semantic model)
- A web browser for the login flow (or use `--device-code` for headless environments)

## What Happens During Setup

1. The installer checks Python, installs dependencies, and downloads the PII detection model
2. The **setup wizard** starts automatically:
   - A browser window opens with the Microsoft login page
   - You sign in with your Power BI account
   - You may see a permissions consent screen — click "Accept"
3. The wizard lists your Power BI workspaces — pick a number
4. The wizard lists datasets in that workspace — pick a number
5. Config is saved to `~/.powerbi-mcp/config.json` with your workspace and dataset IDs
6. Auth token is cached — no re-login needed

## After First Run

Tokens refresh automatically. You won't need to log in again unless:
- You delete `~/.powerbi-mcp/auth_record.json`
- Your refresh token expires (typically 90 days of inactivity)
- Your admin revokes your session
- You change your password

## Enterprise / Silent Setup

IT admins can skip the interactive wizard entirely:

```bash
# Pre-configured IDs (macOS/Linux)
./setup.sh --workspace-id "GUID" --dataset-id "GUID" --silent

# Pre-configured IDs (Windows)
.\setup.ps1 -WorkspaceId "GUID" -DatasetId "GUID" -Silent

# Config from IT-hosted endpoint
./setup.sh --config-url https://it.yourcompany.com/powerbi-mcp-config

# Headless environments (SSH, no browser)
./setup.sh --device-code --workspace-id "GUID" --dataset-id "GUID"
```

Environment variables (for MDM/GPO deployment, override config.json):
- `POWERBI_MCP_WORKSPACE_ID`
- `POWERBI_MCP_DATASET_ID`
- `POWERBI_MCP_CONFIG` (full JSON blob)

## What Permissions Are Requested

The server requests two scopes:
- `https://analysis.windows.net/powerbi/api/.default` — Read Power BI data, execute DAX queries
- `https://api.fabric.microsoft.com/.default` — Read semantic model definitions (schema)

These are read-only. The server cannot modify your Power BI content.

## No App Registration Needed

The server uses Azure's public client ID (the same one Power BI Desktop uses). You don't need to register an app in Azure AD or configure any tenant settings.

If your organization has disabled public client flows, ask your Azure AD admin to allow it, or register a custom app. See [troubleshooting.md](troubleshooting.md) for details.

## PII Protection

All data returned by the MCP server passes through Microsoft Presidio before reaching your AI assistant. Personal information (names, emails, phone numbers, etc.) is automatically replaced with placeholders like `<PERSON>`, `<EMAIL>`, etc.

This means your AI never sees raw PII from your Power BI data.

## Skipping the Wizard

If you prefer to configure manually (old behavior):

```bash
./setup.sh --skip-wizard
```

Then edit `~/.powerbi-mcp/config.json` and add your workspace/dataset IDs. You can find these in the Power BI Service URL:
```
https://app.powerbi.com/groups/{WORKSPACE_ID}/datasets/{DATASET_ID}
```
