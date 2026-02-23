# Power BI Report Generator

Generate a Power BI report as HTML. **Question:** $ARGUMENTS

If no question given, ask the user what to analyze.

---

## Step 1 — Get Data

Search the schema for relevant measures/columns:

```
search_schema(workspace_id, dataset_id, search_term="keyword from question")
```

Run 2-3 searches with different keywords. Then run DAX queries:

```
execute_dax(dataset_id, dax_query="EVALUATE TOPN(20, SUMMARIZECOLUMNS(...))")
```

**Rules for DAX:**
- Use `SUMMARIZECOLUMNS` + `TOPN` for grouped data
- Use `ROW` for single aggregates
- Always include a measure in every query (not just columns)
- Only use columns/measures that `search_schema` returned — never guess names
- Anonymize output: clients → "Client A/B/C", resources → "Tech 1/2/3"

---

## Step 2 — Build the Report

1. Read the file `templates/report-shell.html` from this repository
2. That file contains ALL the CSS and HTML structure — do not write your own
3. Copy the entire template as your starting point
4. Replace every `★PLACEHOLDER★` with real content from your data

---

## Step 3 — Fill the Placeholders

Replace these in the template (keep ALL surrounding HTML intact):

| Placeholder | What to put |
|---|---|
| `★TOPIC_NAME★` | Short topic name (e.g. "Employee Productivity") |
| `★SEARCH_QUESTION★` | The user's original question |
| `★H1_TITLE★` | Full report title |
| `★SUBTITLE★` | 1-2 sentence summary with `<strong>` on key stats |
| `★SOURCE_BADGES★` | 2-4 badges: `<span class="source-badge"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M..."/></svg> Label</span>` |
| `★PIPELINE_SOURCE★` | Data source name (e.g. "Autotask PSA") |
| `★PIPELINE_SOURCE_DESC★` | Short description of source |
| `★PIPELINE_FOOTER★` | Footer text with `<strong>` tags |
| `★OVERVIEW_H2★` | Report overview heading |
| `★OVERVIEW_BODY★` | 2-3 paragraphs of overview with `<p>` tags and `<strong>` |
| `★VC1_TITLE★` / `★VC1_TEXT★` | Value card 1: title and description |
| `★VC2_TITLE★` / `★VC2_TEXT★` | Value card 2 |
| `★VC3_TITLE★` / `★VC3_TEXT★` | Value card 3 |
| `★META_CATEGORY★` | Category (e.g. "Operational Efficiency") |
| `★META_SOURCE★` | Data source (e.g. "Autotask Tickets & Time Entries") |
| `★META_AUDIENCE★` | Target audience |
| `★PROXUMA_PATH★` | Path in Proxuma (e.g. "Reports › Productivity › Employee") |
| `★METRICS_CHECKLIST★` | 9-12 metric items (see component below) |
| `★DOC_DATE★` | Today's date |
| `★DOC_SOURCE★` | Data source |
| `★DOC_SCOPE★` | Scope (e.g. "All resources, last 12 months") |
| `★DOC_TITLE★` | Document title |
| `★DOC_SUBTITLE★` | Document subtitle |
| `★REPORT_CONTENT★` | **The main report body — see Step 4** |
| `★CTA_TITLE★` | CTA heading (e.g. "Want this for your MSP?") |
| `★CTA_TEXT★` | CTA description |

---

## Step 4 — Write the Report Content

The `★REPORT_CONTENT★` zone is where you write 6-8 sections of analysis. Use ONLY these components:

### Section wrapper
```html
<div class="doc-section">
  <div class="doc-section-head">
    <span class="doc-section-num">1.0</span>
    <span class="doc-section-title">Section Title</span>
  </div>
  <!-- content goes here -->
</div>
```

### KPI row (use for headline metrics)
```html
<div class="doc-kpi-row">
  <div class="doc-kpi">
    <div class="doc-kpi-label">LABEL</div>
    <div class="doc-kpi-value">1,234</div>
    <div class="doc-kpi-note green">▲ 12% vs prior</div>
  </div>
  <!-- repeat 3-4 KPIs -->
</div>
```
Note classes: `green` = good, `red` = bad, `amber` = warning, `muted` = neutral.

### Data table
```html
<table>
  <thead><tr><th>Column A</th><th>Column B</th><th>Value</th></tr></thead>
  <tbody>
    <tr><td class="client-name">Client A</td><td>Detail</td><td class="num">1,234</td></tr>
  </tbody>
</table>
```
Helper classes: `num` (right-aligned bold), `num-danger` (red), `num-warn` (amber), `num-ok` (green), `client-name` (bold navy), `pct-badge pct-ok/pct-mid/pct-bad/pct-none`.

### DAX toggle (required after every data section)
```html
<div class="dax-toggle">
  <div class="dax-trigger" onclick="this.parentElement.classList.toggle('expanded')">
    <svg class="dax-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
    View DAX Query
  </div>
  <div class="dax-content">
    <pre><code>EVALUATE
TOPN(20,
  SUMMARIZECOLUMNS(
    'Table'[Column],
    "Measure", [Measure Name]
  ),
  [Measure Name], DESC
)</code></pre>
    <button class="dax-copy" onclick="prxCopyDAX(this)">Copy Query</button>
  </div>
</div>
```

### Narrative text
```html
<div class="narrative">
  <p>Analysis paragraph with <strong>key findings</strong> highlighted.</p>
</div>
```

### Findings list
```html
<div class="doc-finding">
  <div class="doc-finding-icon critical">!</div>
  <div class="doc-finding-body">
    <h4>Finding Title</h4>
    <p>Description of the finding with specific numbers.</p>
  </div>
</div>
```
Icon classes: `critical` (red), `warning` (amber), `ok` (green).

### FAQ section (last section, numbered 8.0)
```html
<div class="doc-section">
  <div class="doc-section-head">
    <span class="doc-section-num">8.0</span>
    <span class="doc-section-title">Frequently Asked Questions</span>
  </div>
  <div class="doc-faq">
    <div class="faq-item" onclick="this.classList.toggle('open')">
      <div class="faq-q">Question text here?<svg class="faq-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg></div>
      <div class="faq-a"><p>Answer text here.</p></div>
    </div>
    <!-- 4-6 FAQ items -->
  </div>
</div>
```

---

## Step 5 — Output Rules

1. **Output the COMPLETE HTML** — the full template with all placeholders replaced
2. **No `<!DOCTYPE>`, no `<html>`, no `<body>` wrapper** — the template starts with `<link>` and ends with `</script>`
3. **No extra `<style>` or `<script>` tags** — everything you need is already in the template
4. **Every data section must have a DAX toggle** showing the actual query you ran
5. **Use real numbers from your DAX results** — never make up data
6. **Write 6-8 full sections** numbered 1.0 through 7.0 or 8.0, plus FAQ as the last section
7. **Minimum 500 lines total** — if shorter, you summarized. Go back and write more.
8. **Show all rows** — if a query returns 15 rows, the table has 15 rows
9. **Anonymize names** — clients → Client A/B/C, resources → Tech 1/2/3

### Metric checklist item format
```html
<div class="metric-item"><span class="metric-check"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Metric name</div>
```
