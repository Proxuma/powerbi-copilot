# Template-Based Prompts — Deliverables

## What Was Built

This PR implements a **template-based approach** for small AI models (Claude Haiku 4.5, GPT-4o, GPT-5 mini) that cannot follow long instruction prompts.

## Files Delivered

### 1. `templates/dashboard-shell.html` (196 lines)

**NEW FILE** — Pre-filled HTML template for Power BI dashboard builder pages.

**Structure:**
- Header with Proxuma logo, title, description, metadata
- 5-tab navigation: Dashboard Preview, DAX Measures, Build Instructions, Color Rules, Tips
- Complete CSS (compact single-line format, scoped under `.prx-dashboard`)
- Tab switching JavaScript
- Copy-to-clipboard JavaScript for DAX measures

**Content zones (marked with `★PLACEHOLDER★`):**
- `★DASHBOARD_TITLE★` — Full dashboard title
- `★DASHBOARD_DESC★` — 1-2 sentence description
- `★DASHBOARD_TOPIC★` — Short topic name
- `★DASHBOARD_SOURCE★` — Data source
- `★DASHBOARD_DATE★` — Today's date
- `★PAGE_TAB_BUTTONS★` — Page tab buttons
- `★DASHBOARD_PAGES★` — All dashboard pages with KPI cards, charts, tables
- `★DAX_MEASURES★` — All DAX measures with copy buttons
- `★BUILD_INSTRUCTIONS★` — Step-by-step build instructions
- `★COLOR_RULES★` — Color formatting table rows
- `★TIPS_CONTENT★` — Configuration tips

**Design tokens:**
- Font: Open Sans (headings + body)
- Code font: JetBrains Mono
- Colors: Teal `#0f766e`, Navy `#1B365D`, Blue `#164487`, Green `#00D9A5`
- KPI accent colors: Teal, Blue, Amber, Green, Red, Purple
- Chart palette: Teal (default), Blue, Amber, Green, Red

**Components included:**
- KPI cards (6 color variants)
- CSS-only bar charts
- Tables with conditional formatting (cell-green, cell-amber, cell-red, cell-gray)
- DAX measure blocks with copy buttons
- Step-by-step instruction blocks
- Color rule table
- Tip blocks

### 2. `prompts/powerbidashboard.prompt.md` (138 lines)

**REWRITTEN** — Compact prompt that references `templates/dashboard-shell.html`.

**Structure:**
- Step 1: Explore the data (search_schema + list_measures + execute_dax)
- Step 2: Read the template
- Step 3: Plan the dashboard (4-6 pages)
- Step 4: Fill placeholders
- Step 5: Write content zones (with component snippets)
- Step 6: Output rules

**Component snippets provided:**
- Page tab button snippet
- Dashboard page snippet (KPI grid + visual grid + tables)
- DAX measure snippet (with copy button)
- Build instruction snippet (step blocks with numbered lists)
- Color rule row snippet
- Tip snippet

**Key improvements:**
- Under 200 lines (small models lose track beyond this)
- Clear numbered steps
- Every HTML component given as copy-paste snippet
- Explicit "do NOT" rules (no DOCTYPE, no extra style/script, no summarizing)
- References template by relative path
- Minimum output requirement: 800 lines

### 3. `prompts/powerbireport.prompt.md` (192 lines)

**UPDATED** — Added clarification about config.json defaults.

**Change:**
- Added note: "If user has set defaults in `config.json`, workspace_id/dataset_id can be omitted."

This makes the syntax consistent between report and dashboard prompts.

## Design Philosophy

### Problem with Long Prompts

Small models (Haiku, GPT-4o, GPT-5 mini) given a 900-line prompt with inline CSS will:
1. Ignore all frozen CSS and write their own from scratch
2. Use wrong fonts (Inter instead of Open Sans), wrong colors, wrong classes
3. Summarize content instead of writing full output
4. Fabricate DAX measure names instead of using search_schema results
5. Wrap output in `<!DOCTYPE><html><body>` which breaks WordPress embedding

### Solution: Template-Based Approach

1. **Pre-filled template** with ALL CSS/JS/structure frozen
2. **Compact prompt** (~120-200 lines) that:
   - Tells model to READ the template first
   - Instructs model to COPY it entirely
   - Provides copy-paste snippets for every component
   - Gives explicit output rules

### Why This Works

- Small models are good at **following short, concrete instructions**
- Small models are good at **copying and filling in blanks**
- Small models are BAD at **remembering 900 lines of CSS while also writing content**
- Template approach separates concerns: CSS (frozen) vs. Content (generated)

## Template Rules

1. All CSS in a single `<style>` block, compact single-line format
2. All classes scoped under a root class (`.prx-report` or `.prx-dashboard`)
3. No external dependencies except Google Fonts CDN
4. No `<!DOCTYPE>`, `<html>`, or `<body>` — these are WordPress embeds
5. Placeholder format: `★NAME★` (star characters, not curly braces — more visible to small models)
6. Content zones marked with HTML comments: `<!-- ★★★ ZONE START ★★★ -->`

## Prompt Rules

1. Under 200 lines — small models lose track beyond this
2. Steps numbered clearly: Step 1, Step 2, etc.
3. Every HTML component the model might need is given as a copy-paste snippet
4. Explicit "do NOT" rules: no extra CSS, no DOCTYPE, no summarizing, no fabricating data
5. Reference the template file by relative path
6. Minimum output requirements stated clearly (e.g., "minimum 800 lines")

## MCP Tools Available

The Power BI MCP server provides these tools:

```
search_schema(workspace_id, dataset_id, search_term)  — search for columns/measures
list_measures(workspace_id, dataset_id)                — list all measure names
execute_dax(dataset_id, dax_query)                     — run a DAX query
list_workspaces()                                      — list available workspaces
list_datasets(workspace_id)                            — list datasets in workspace
```

If the user has configured defaults in `~/.powerbi-mcp/config.json`, workspace_id and dataset_id can be omitted.

## Git Workflow

- ✅ Created feature branch `feature/dashboard-template`
- ✅ Committed all changes with descriptive message
- ✅ Pushed to GitHub
- ✅ Created PR: https://github.com/Proxuma/powerbi-copilot/pull/3

## Next Steps (v2)

- [ ] Windows support (setup.sh currently Mac/Linux only)
- [ ] Inline golden standard template in prompt (avoid file read step)
- [ ] Test with GPT-4o mini / GPT-5 mini output quality
- [ ] Add example dashboard outputs to repo

## Compatibility

- ✅ VS Code Copilot Agent Mode
- ✅ Claude Code
- ✅ Claude Desktop
- ✅ Cursor

## Testing Recommendation

Test the dashboard builder with a small model (Haiku or GPT-4o mini):

```
#powerbidashboard Operations efficiency across clients
```

Expected behavior:
1. Model calls search_schema + list_measures
2. Model reads templates/dashboard-shell.html
3. Model copies the template
4. Model fills in all placeholders
5. Model writes complete content zones (800+ lines total)
6. Output has correct CSS classes, no DOCTYPE wrapper, all measures written out

Compare output quality against the old prompt (before this PR) to verify improvement.
