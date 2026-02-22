# Troubleshooting

## Setup Issues

### `setup.sh` says Python 3.10+ is required but I have Python installed

The script checks for `python3.12`, `python3.11`, `python3.10`, and `python3` in that order. If none of these have version 3.10+, it fails.

Check your Python version:
```bash
python3 --version
```

If it's below 3.10, install a newer version:
- **macOS:** `brew install python@3.12`
- **Ubuntu/Debian:** `sudo apt install python3.12`

### pip install fails with permission errors

The script installs packages for the user running it. If you get permission errors:
```bash
python3 -m pip install --user -r server/requirements.txt
```

Or use a virtual environment:
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r server/requirements.txt
```

If using a venv, update `.vscode/mcp.json` to point to the venv Python:
```json
{
  "servers": {
    "powerbi": {
      "command": "/path/to/powerbi-copilot/.venv/bin/python3",
      "args": ["/path/to/powerbi-copilot/server/server.py"]
    }
  }
}
```

### spaCy model download fails

```bash
python3 -m spacy download en_core_web_sm
```

If that fails behind a corporate proxy:
```bash
pip install https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-3.7.1/en_core_web_sm-3.7.1-py3-none-any.whl
```

## Authentication Issues

### Browser doesn't open for login

The server uses `InteractiveBrowserCredential` which opens your default browser. If it doesn't open:

1. Check if you're running in a headless environment (SSH, Docker) — interactive login requires a GUI
2. Try clearing the cached auth: `rm ~/.powerbi-mcp/auth_record.json`
3. Restart VS Code and try again

### "AADSTS65001: The user or administrator has not consented"

Your Azure AD tenant requires admin consent for public client flows. Options:

1. Ask your Azure AD admin to grant consent
2. Register a custom Azure AD app:
   - Go to Azure Portal → Azure Active Directory → App registrations
   - New registration → "Power BI MCP" → Public client (mobile & desktop)
   - Add API permissions: Power BI Service → Delegated → Dataset.Read.All
   - Grant admin consent
   - Update server.py to use your app's client ID

### "Token expired" errors after weeks of inactivity

Delete the cached auth and re-authenticate:
```bash
rm ~/.powerbi-mcp/auth_record.json
```

The next tool call will trigger a fresh browser login.

## MCP Server Issues

### VS Code Copilot doesn't show the Power BI tools

1. Check that `.vscode/mcp.json` exists and has the correct paths
2. Make sure the Python path in `mcp.json` is absolute (not relative)
3. Reload VS Code: `Cmd+Shift+P` → "Developer: Reload Window"
4. Open the MCP panel: `Cmd+Shift+P` → "MCP: List Servers" — the "powerbi" server should be listed
5. Check the Output panel (MCP channel) for error messages

### Server crashes with MemoryError

You likely called `get_schema` on a large model. Use `search_schema` instead:
```
search_schema(search_term="revenue")
```

This returns only matching definitions instead of the full 10MB+ schema.

### DAX query returns "HTTP 400 Bad Request"

Common causes:
- Column or table name doesn't exist — use `search_schema` to verify names
- Missing quotes around column names with spaces: `'Table Name'[Column Name]`
- Incorrect DAX syntax — test the query in Power BI Desktop first

### "HTTP 403 Forbidden"

Your account doesn't have access to this workspace or dataset. Verify:
1. You can see the dataset in [Power BI Service](https://app.powerbi.com)
2. You have at least Viewer role on the workspace
3. The dataset allows XMLA endpoint connections (check workspace settings)

## Prompt File Issues

### Typing `#powerbireport` doesn't do anything in Copilot Chat

1. Make sure `.github/prompts/powerbireport.prompt.md` exists
2. In VS Code settings, enable: `chat.promptFiles: true`
3. You must be in **Agent mode** (not Ask mode) — click the mode selector in Copilot Chat
4. Reload VS Code after adding prompt files

### AI generates a short summary instead of a full report

This happens with smaller models (GPT-4o mini, Haiku). The prompts include anti-summarization guards, but smaller models sometimes ignore them.

Fixes:
- Switch to a more capable model (GPT-4o, Claude Sonnet/Opus)
- If the output is too short, reply: "That's a summary. Generate the FULL HTML report with all sections, all table rows, and all CSS. Minimum 800 lines."
- Break the request into steps: first "run the DAX queries", then "generate the HTML from those results"

### Report has fake/fabricated data

The AI should only use data from DAX queries. If it invents numbers:
- Check that the MCP server is actually running (tools should appear in Copilot)
- Make sure `config.json` has the correct workspace/dataset IDs
- Reply: "Use only the data from the DAX queries above. Do not fabricate any numbers."

## Configuration

### How do I add multiple workspaces?

Edit `~/.powerbi-mcp/config.json`:
```json
{
  "default_workspace_id": "primary-workspace-guid",
  "default_dataset_id": "primary-dataset-guid",
  "workspaces": {
    "Production": "guid-1",
    "Development": "guid-2",
    "Client ABC": "guid-3"
  }
}
```

The `default_workspace_id` and `default_dataset_id` are used when you don't specify IDs in your prompt. The `workspaces` map is for your own reference.

### How do I use this with Claude Desktop?

Add the server to `~/Library/Application Support/Claude/claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "powerbi": {
      "command": "/path/to/python3",
      "args": ["/path/to/powerbi-copilot/server/server.py"]
    }
  }
}
```

### How do I use this with Cursor?

Add the server in Cursor's MCP settings (Settings → MCP → Add Server):
- Name: `powerbi`
- Command: `/path/to/python3`
- Args: `/path/to/powerbi-copilot/server/server.py`
