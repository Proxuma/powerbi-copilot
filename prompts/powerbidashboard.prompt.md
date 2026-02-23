# Power BI Dashboard Builder

Build an interactive dashboard mockup with full DAX measures and step-by-step build instructions. **Topic:** $ARGUMENTS

If no topic given, ask the user what dashboard to build.

---

## Step 1 — Explore the Data

Search for relevant measures and columns (run 2-3 searches):

```
search_schema(workspace_id, dataset_id, search_term="keyword")
list_measures(workspace_id, dataset_id)
```

**If user has set defaults in config.json, workspace_id/dataset_id can be omitted.**

Then pull sample data to understand tables:
```
execute_dax(dataset_id, dax_query="EVALUATE TOPN(5, 'TableName')")
```

**NEVER use `get_schema` — it returns >10MB and will crash.**

---

## Step 2 — Read the Template

Read `templates/dashboard-shell.html` from this repository. That file contains ALL the CSS, HTML structure, and JavaScript. Do NOT write your own.

---

## Step 3 — Plan the Dashboard

Design 4-6 dashboard pages:
- **Executive overview** with KPI cards
- **Breakdown/matrix** with conditional formatting
- **Trend analysis** (time series)
- **Detail/drill-through** page
- **Distribution** (who/what is over/under)

Write 15-25 DAX measures covering all metrics needed.

---

## Step 4 — Fill Placeholders

Copy the template and replace these (keep ALL surrounding HTML):

| Placeholder | What to put |
|---|---|
| `★DASHBOARD_TITLE★` | Full dashboard title |
| `★DASHBOARD_DESC★` | 1-2 sentence description |
| `★DASHBOARD_TOPIC★` | Short topic name |
| `★DASHBOARD_SOURCE★` | Data source (e.g. "Autotask PSA") |
| `★DASHBOARD_DATE★` | Today's date |
| `★PAGE_TAB_BUTTONS★` | Page tab buttons (see snippet) |
| `★DASHBOARD_PAGES★` | All dashboard pages (see snippet) |
| `★DAX_MEASURES★` | All DAX measures (see snippet) |
| `★BUILD_INSTRUCTIONS★` | Step-by-step build steps (see snippet) |
| `★COLOR_RULES★` | Color formatting table rows (see snippet) |
| `★TIPS_CONTENT★` | Configuration tips (see snippet) |

---

## Step 5 — Write Content Zones

### Page tab button snippet
```html
<button class="page-tab active" onclick="prxSwitchPage('page1')">Page Name</button>
<!-- repeat for each page, only first is active -->
```

### Dashboard page snippet
```html
<div class="page-content active" id="page1">
  <div class="kpi-grid">
    <div class="kpi-card teal">
      <div class="kpi-label">LABEL</div>
      <div class="kpi-value">1,234</div>
      <div class="kpi-delta positive">▲ 15% vs prior</div>
    </div>
    <!-- 4-6 KPI cards -->
  </div>
  <div class="visual-grid">
    <div class="visual">
      <div class="visual-title">Chart Title</div>
      <div class="bar-chart">
        <div class="bar-item">
          <div class="bar-label">Label</div>
          <div class="bar-track"><div class="bar-fill" style="width:75%">75%</div></div>
        </div>
        <!-- repeat bars -->
      </div>
    </div>
    <div class="visual">
      <div class="visual-title">Table Title</div>
      <table>
        <thead><tr><th>Col A</th><th>Col B</th><th>Value</th></tr></thead>
        <tbody>
          <tr><td>Item</td><td class="cell-green">90%</td><td class="num">1,234</td></tr>
          <!-- repeat rows, use cell-green/cell-amber/cell-red/cell-gray -->
        </tbody>
      </table>
    </div>
  </div>
</div>
<!-- Only first page has class="active", rest without -->
```

Card colors: `teal`, `blue`, `amber`, `green`, `red`, `purple`.
Bar colors: default (teal gradient), `blue`, `amber`, `green`, `red`.

### DAX measure snippet
```html
<div class="measure-block">
  <div class="measure-header">
    <div>
      <div class="measure-num">MEASURE 1</div>
      <div class="measure-name">Measure Name</div>
      <div class="measure-table">Create in: TableName</div>
    </div>
  </div>
  <div class="measure-desc">What this measure calculates.</div>
  <div class="measure-code">
    <button class="copy-btn" onclick="prxCopyMeasure(this)">Copy DAX</button>
    <pre><code>Measure Name =
CALCULATE(
    [Base Measure],
    FILTER(...)
)</code></pre>
  </div>
</div>
```

**WRITE ALL MEASURES.** If there are 20, write 20. Do NOT summarize.

### Build instruction snippet
```html
<div class="step-block">
  <div class="step-header">
    <div class="step-icon">0</div>
    <div class="step-title">Step Title</div>
  </div>
  <div class="step-content">
    <ol>
      <li>Open Power BI Desktop and connect to your dataset</li>
      <li>Click <strong>New measure</strong> in the <code>TableName</code> table</li>
      <li>Copy the DAX from the Measures tab and paste it</li>
      <li>Press Enter to create the measure</li>
    </ol>
  </div>
</div>
```

Step 0 = "Before You Build", then pages 1-N with visual instructions.

**WRITE INSTRUCTIONS FOR EVERY VISUAL.** Do NOT skip pages or summarize.

Example visual instruction:
```html
<li>Click the <strong>Matrix</strong> icon in Visualizations</li>
<li>Drag <code>column_name</code> into Rows</li>
<li>Drag <code>[Measure Name]</code> into Values</li>
<li>Click the paint roller (Format), expand <strong>Cell elements</strong></li>
<li>Toggle <strong>Background color</strong> to ON, click fx</li>
<li>Set Format by: <strong>Rules</strong></li>
<li>Add rule: If value >= 90, color <span style="color:#059669">#059669</span> (green)</li>
<li>Add rule: If value >= 70, color <span style="color:#f59e0b">#f59e0b</span> (amber)</li>
<li>Add rule: If value < 70, color <span style="color:#dc2626">#dc2626</span> (red)</li>
```

### Color rule row snippet
```html
<tr>
  <td>Matrix: Client Performance</td>
  <td>[SLA Met %]</td>
  <td>>= 90%</td>
  <td><div class="color-swatch" style="background:#059669"></div></td>
  <td>#059669</td>
</tr>
```

### Tip snippet
```html
<div class="tip-item">
  <div class="tip-title">Tip Title</div>
  <div class="tip-text">Tip description with specific advice.</div>
</div>
```

---

## Step 6 — Output Rules

1. **Output the COMPLETE HTML** — full template with ALL placeholders filled
2. **No `<!DOCTYPE>`, no `<html>`, no `<body>` wrapper** — template starts with `<link>` and ends with `</script>`
3. **No extra `<style>` or `<script>` tags** — everything is in the template
4. **Use real table/column names** from the data model — never guess
5. **Write ALL measures** (15-25 minimum) — no summarizing
6. **Write ALL build instructions** — every visual on every page gets step-by-step clicks
7. **Minimum 800 lines total** — proper dashboards are 1500-3000 lines
8. **Show all pages** — if you plan 5 pages, write 5 full pages
9. **Conditional formatting in tables** — use `cell-green`, `cell-amber`, `cell-red`, `cell-gray` classes

**Remember:** Small models skip instructions if you don't write them out fully. Write EVERY step.
