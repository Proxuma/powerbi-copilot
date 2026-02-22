# First Run — Azure Login

When you use the Power BI MCP server for the first time, it needs to authenticate with your Microsoft account. Here's what happens and what you need.

## Prerequisites

- A Microsoft account with **Power BI Pro** or **Premium Per User** license
- The account must have access to at least one Power BI workspace with a dataset (semantic model)
- A web browser for the login flow

## What Happens on First Run

1. You invoke a tool (e.g., `list_workspaces` or run a prompt file)
2. The MCP server requests an Azure AD token
3. **A browser window opens automatically** with the Microsoft login page
4. You sign in with your Power BI account
5. You may see a permissions consent screen — click "Accept"
6. The browser shows "Authentication complete" — you can close it
7. The token is cached in `~/.powerbi-mcp/auth_record.json`
8. The tool call completes and returns data

## After First Login

Tokens are cached and refresh automatically. You won't need to log in again unless:
- You delete `~/.powerbi-mcp/auth_record.json`
- Your refresh token expires (typically 90 days of inactivity)
- Your admin revokes your session
- You change your password

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
