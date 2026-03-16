# VS Code Setup — Power BI Report with GitHub Copilot + Haiku

This guide shows you how to generate a Power BI report in VS Code using GitHub Copilot Agent Mode with Claude Haiku 4.5.

## Prerequisites

1. **VS Code** installed
2. **GitHub Copilot** subscription (with Agent Mode access)
3. **Power BI access** with a dataset already configured
4. **This repository cloned** to your machine

## One-Time Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/Proxuma/powerbi-copilot.git
cd powerbi-copilot
```

### Step 2: Run the Setup Script

**macOS/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

**Windows:**
```powershell
# Coming soon in v2
```

The setup script will:
1. Create `~/.powerbi-mcp/` directory
2. Copy the MCP server files
3. Create a default `config.json` template
4. Install required Python packages (if not present)
5. Add MCP server configuration to VS Code settings

### Step 3: Configure Your Power BI Connection

Edit `~/.powerbi-mcp/config.json`:

```json
{
  "default_workspace_id": "your-workspace-id-here",
  "default_dataset_id": "your-dataset-id-here",
  "pii_anonymization": true
}
```

**How to find these IDs:**

1. Go to https://app.powerbi.com
2. Open your workspace
3. Look at the URL: `https://app.powerbi.com/groups/{workspace-id}/...`
4. Click on a dataset → Settings
5. Look at the URL: `https://app.powerbi.com/groups/{workspace-id}/datasets/{dataset-id}/...`

**Or use the MCP tools to list them:**
- Open VS Code
- Open Copilot Chat (Ctrl+Shift+I / Cmd+Shift+I)
- Type: `#powerbireport` then in chat: "List my workspaces and datasets"

### Step 4: Authenticate with Power BI

Open VS Code and run:

```
#powerbireport
```

In the chat, type:
```
Authenticate with Power BI
```

This will open a browser window for you to log in to Power BI. The token will be cached in `~/.powerbi-mcp/token.json`.

### Step 5: Verify Setup

In VS Code Copilot Chat:

```
#powerbireport
```

Then type:
```
List all measures in my dataset
```

If you see a list of measures, setup is complete! ✅

---

## Generating a Report (Step-by-Step)

### Step 1: Open VS Code

Open VS Code in the `powerbi-copilot` repository folder:

```bash
cd /path/to/powerbi-copilot
code .
```

### Step 2: Open Copilot Chat

**Keyboard shortcut:**
- **macOS:** `Cmd+Shift+I`
- **Windows/Linux:** `Ctrl+Shift+I`

**Or:**
- Click the Copilot icon in the Activity Bar
- Select "Chat"

### Step 3: Invoke the Report Generator

In the Copilot Chat, type:

```
#powerbireport What is the average resolution time per client?
```

**Format:**
```
#powerbireport [your business question here]
```

**Example questions:**
- `#powerbireport Show me revenue won MTD, QTD, and YTD`
- `#powerbireport Which clients have the worst SLA compliance?`
- `#powerbireport What is the average ticket resolution time by priority?`
- `#powerbireport Show me billable hours by resource and client`

### Step 4: Copilot Executes the Workflow

Copilot + Haiku will automatically:

1. **Search the schema** for relevant measures/columns
   - Calls `search_schema(search_term="resolution time")`
   - Calls `search_schema(search_term="client")`
   - Calls `list_measures()`

2. **Run DAX queries** to fetch data
   - Executes 3-5 DAX queries via `execute_dax()`
   - Pulls top 20 rows for each analysis

3. **Read the template** from `templates/report-shell.html`
   - Copilot loads the frozen HTML/CSS structure

4. **Fill placeholders** with real data
   - Replaces all `★PLACEHOLDER★` markers
   - Fills in title, subtitle, metadata, etc.

5. **Write report sections**
   - 6-8 numbered sections (1.0–8.0)
   - KPI rows, data tables, findings
   - DAX query toggles with copy buttons
   - FAQ accordion at the end

6. **Output complete HTML**
   - 500-1500 lines of HTML
   - No `<!DOCTYPE>` wrapper (ready for WordPress)
   - All CSS/JS from template included

### Step 5: Save the Output

Copilot will save the report to the workspace directory:

```
powerbi-copilot/
└── Report_[Topic]_[Date].html
```

**Or** Copilot may show you the HTML in chat. If so:

1. Click "Insert at Cursor" to paste into a new file
2. Save as `Report_Name.html`

### Step 6: Preview in Browser

Open the HTML file in a browser:

```bash
# macOS
open Report_Name.html

# Linux
xdg-open Report_Name.html

# Windows
start Report_Name.html
```

**Or** drag the file into your browser.

### Step 7: Copy to WordPress (Optional)

If you're embedding in WordPress:

1. Open the HTML file in a text editor
2. Copy the ENTIRE contents (starts with `<link>`, ends with `</script>`)
3. In WordPress: Add a **Custom HTML** block
4. Paste the HTML
5. Publish

The report is fully self-contained — no external dependencies except Google Fonts.

---

## Generating a Dashboard (Step-by-Step)

Same process, but use `#powerbidashboard` instead:

```
#powerbidashboard Operations efficiency across clients
```

**Output:**
- Interactive dashboard mockup with page tabs
- Complete DAX measures (15-25) with copy buttons
- Step-by-step build instructions for Power BI Desktop
- Conditional formatting rules table
- Configuration tips

**File saved as:**
```
Dashboard_[Topic]_[Date].html
```

---

## Switching to Haiku Model

By default, Copilot Agent Mode uses GPT-4o. To use **Claude Haiku 4.5** instead:

### Option 1: Model Selector in Copilot Chat

1. Open Copilot Chat
2. Look for the model selector dropdown (usually at the bottom)
3. Select "Claude Haiku 4.5" or "Haiku"

### Option 2: VS Code Settings

Add to your `settings.json`:

```json
{
  "github.copilot.editor.enableAutoCompletions": true,
  "github.copilot.chat.model": "claude-haiku-4.5"
}
```

**Note:** Model availability depends on your GitHub Copilot plan. If Haiku is not available, GPT-4o mini or GPT-4o will work with the template-based prompts.

---

## Troubleshooting

### "MCP server not found"

**Solution:** Re-run the setup script:
```bash
cd powerbi-copilot
./setup.sh
```

Then restart VS Code.

### "No workspace_id provided"

**Solution:** Add defaults to `~/.powerbi-mcp/config.json`:

```json
{
  "default_workspace_id": "your-workspace-id",
  "default_dataset_id": "your-dataset-id"
}
```

### "Token expired"

**Solution:** Re-authenticate:
```
#powerbireport
```
Then in chat: "Authenticate with Power BI"

### Output is too short / summarized

**Solution:** This means the model didn't follow the template instructions. Try:

1. Make sure you're using Haiku or a small model
2. Check that `templates/report-shell.html` exists in your repo
3. Re-clone the repo if files are missing

### "Column 'xyz' not found"

**Solution:** The model fabricated a column name. This is a known issue with small models. Try:

1. Add more context to your question
2. Use the full table.column syntax in your question
3. Or use the dashboard builder instead (has stricter validation)

### Report has no CSS styling

**Solution:** The model added a `<!DOCTYPE>` wrapper. This strips the CSS when embedding in WordPress.

**Fix:**
1. Open the HTML file
2. Remove everything before `<link rel="preconnect">`
3. Remove any `<html>`, `<head>`, `<body>` tags
4. The file should start with `<link>` and end with `</script>`

---

## Tips for Better Reports

### Be Specific in Your Questions

❌ **Bad:** "Show me tickets"
✅ **Good:** "Show me average resolution time per client with SLA compliance percentage"

❌ **Bad:** "Revenue report"
✅ **Good:** "Show me revenue won MTD, QTD, and YTD by client with year-over-year comparison"

### Use the Measures Tab

After generating a report, open the HTML file and click the **DAX Measures** tab to see all the queries Copilot used. You can:
- Copy measures into Power BI Desktop
- Validate the DAX syntax
- Understand how metrics are calculated

### Anonymize Sensitive Data

PII anonymization is **enabled by default** in `config.json`. Client names become "Client A/B/C", resource names become "Tech 1/2/3".

To disable:
```json
{
  "pii_anonymization": false
}
```

### Save Output for Reuse

Copilot-generated reports can be saved and reused:

1. Save the HTML file with a descriptive name
2. Update placeholders manually if needed
3. Embed in WordPress, Notion, or your internal wiki

---

## Model Comparison

| Model | Speed | Cost | Quality | Template Adherence |
|-------|-------|------|---------|-------------------|
| **Claude Haiku 4.5** | ⚡⚡⚡ Fast | 💰 Cheap | ⭐⭐⭐⭐ Excellent | ✅ Yes (with template) |
| **GPT-4o mini** | ⚡⚡ Fast | 💰 Cheap | ⭐⭐⭐ Good | ✅ Yes (with template) |
| **GPT-4o** | ⚡ Moderate | 💰💰 Moderate | ⭐⭐⭐⭐⭐ Excellent | ✅ Yes |
| **Claude Opus 4.6** | ⚡ Slow | 💰💰💰 Expensive | ⭐⭐⭐⭐⭐ Excellent | ✅ Yes (no template needed) |

**Recommendation:** Use **Haiku** for fast, cheap reports with the template system. Use **Opus** for complex analysis where you need the highest quality.

---

## What's in the Template?

The template (`templates/report-shell.html`) includes:

- **353 lines** of pre-written HTML/CSS/JS
- All fonts, colors, spacing frozen
- Components: KPI cards, tables, charts, findings, FAQ
- Placeholders for content: `★TITLE★`, `★SUBTITLE★`, etc.
- Content zones: `★REPORT_CONTENT★` (where AI writes sections)

**Why this works:**
- Small models are good at copying and filling in blanks
- Small models are bad at writing CSS from scratch
- Template approach separates structure (frozen) from content (generated)

---

## Next Steps

- Try generating your first report: `#powerbireport [question]`
- Explore the dashboard builder: `#powerbidashboard [topic]`
- Check out `templates/` to see the frozen design
- Read `DELIVERABLES.md` for technical details

**Questions?** Open an issue: https://github.com/Proxuma/powerbi-copilot/issues
