# Power BI Report Generator

Generate a beautiful, WordPress-ready HTML report for Power BI data analysis.

**Business Question:** $ARGUMENTS

**If no question is specified, ask the user what they want to analyze.**

## Protected Pages — NEVER TOUCH

The pages below are **NOT Power BI reports**. They are hand-crafted editorial content with their own CSS class (`.prx-mcp`), their own layout, and their own design. They exist under the same parent pages as reports but are a completely different category.

**HARD RULES:**
- NEVER overwrite, regenerate, update, or include these pages in ANY bulk operation
- NEVER pass these IDs to `push_via_tempfile()`, `$wpdb->update()`, or any deploy script
- NEVER treat them as reports — they are editorial explainer pages
- If iterating over child pages of parent 3299 or 3495, ALWAYS filter these IDs out FIRST
- `deploy_reports_lib.py` has a `PROTECTED_PAGE_IDS` set that blocks pushes programmatically

| Page ID | Type | Title | Slug | Parent |
|---------|------|-------|------|--------|
| 3401 | Editorial | AI Privacy & Compliance Guide | `ai-privacy-compliance-guide` | 3299 (EN) |
| 5655 | Editorial | AI Privacy & Compliance Gids | `ai-privacy-compliance-guide` | 3495 (NL) |
| 3389 | Editorial | Power BI MCP Server | `power-bi-mcp-server` | 3299 (EN) |
| 4887 | Editorial | Wat is een MCP-server? | `power-bi-mcp-server` | 3495 (NL) |

**Also protected (gallery/index pages — never overwrite with report content):**

| Page ID | Type | Title | Parent |
|---------|------|-------|--------|
| 3299 | Gallery | AI-Powered Reports (EN index) | — |
| 3495 | Gallery | AI-Gegenereerde Rapporten (NL index) | — |

**History:** Page 3401 was corrupted on Mar 3, 2026 by a bulk update that didn't skip editorial pages. It was restored Mar 8 from the Feb 11 original. This must never happen again.

## Instructions

Follow this exact workflow:

### Step 1: Extract Keywords
Extract 2-3 key business terms from the question (e.g., "phase", "budget", "efficiency", "variance", "revenue", "license", "profitability").

### Step 2: Search for Relevant Measures
For each keyword, use `search_schema` to find relevant measures:

```
mcp__powerbi__search_schema(
    workspace_id="1d365f6a-1dbb-4466-88e1-487f6836b452",
    dataset_id="fd823eb4-da85-449d-a175-d24bff86229f",
    search_term="<keyword>"
)
```

Also run `list_measures` to see all available measures:
```
mcp__powerbi__list_measures(
    workspace_id="1d365f6a-1dbb-4466-88e1-487f6836b452",
    dataset_id="fd823eb4-da85-449d-a175-d24bff86229f"
)
```

**NEVER use `get_schema`** - it can return >10MB and crash the session.

### Step 3: Build and Execute DAX Queries
Based on the measures found, construct targeted DAX queries:

```
mcp__powerbi__execute_dax(
    dataset_id="fd823eb4-da85-449d-a175-d24bff86229f",
    dax_query="EVALUATE SUMMARIZECOLUMNS(...)"
)
```

Run 4-8 separate DAX queries to collect enough data for a comprehensive report (KPIs, breakdowns by client/category, trends, comparisons).

### Step 4: Read the CSS Template (COPY-EXACT)
Read the **locked CSS template** and copy its ENTIRE `<style>` block byte-for-byte into your report:

**CSS template (ONLY source of truth for CSS):**
`~/ClaudeCode/powerbi-reports/templates/teal-frame-css.html`

**CRITICAL RULES:**
- Copy the `<style>` block from the template VERBATIM. Do not rewrite, optimize, reorder, or "improve" any CSS.
- Do NOT add CSS inside SVG `<defs><style>` tags. The Proxuma logo SVG has its own `<style>` — leave it alone.
- If you need custom CSS for report-specific visualizations (e.g., bar charts, ring charts), add it in a SEPARATE `<style>` block AFTER the template CSS, scoped under `.prx-report`.
- Never inline the template CSS from memory. Always read the file and copy.

**HTML structure reference (for the teal frame document section):**
`~/ClaudeCode/powerbi-reports/GOLDEN-STANDARD.html` (lines 404-943)

**Additional content examples (for data layout ideas only, NOT for CSS):**
- `~/ClaudeCode/powerbi-reports/proxuma-io-documentation-roi-post.html`
- `~/ClaudeCode/powerbi-reports/proxuma-io-client-profitability-post.html`

### Step 5: Determine Data Sources
Identify which systems/tools were queried. **Every table referenced in any DAX query MUST have a corresponding badge.** Cross-check your DAX queries against this mapping before generating the report.

Use these badge labels:
- **PSA** — Autotask PSA (tickets, contracts, companies, time entries, billing). Tables: `BI_Autotask_Tickets`, `BI_Autotask_Contracts`, `BI_Autotask_Companies`, `BI_Autotask_Time_Entries`, `BI_Autotask_Billing_Items`, `BI_Autotask_Projects`, `BI_Autotask_Configuration_Items`, `BI_Autotask_Contract_Service_Units`
- **RMM** — Datto RMM (devices, alerts, patch status, AV status). Tables: `BI_Datto_*`
- **Backup** — N-able/Datto Backup (backup jobs, success rates, storage). Tables: `BI_Backup_*`
- **M365** — Microsoft 365 (licenses, subscriptions, users, usage). Tables: `BI_M365_*`
- **IT Glue** — IT Glue (documentation, configurations, passwords). Tables: `BI_ITGlue_*`
- **SmileBack** — SmileBack CSAT (customer satisfaction surveys, ratings). Tables: `BI_SmileBack_*`

**Badge CSS classes:** `badge-psa`, `badge-rmm`, `badge-backup`, `badge-m365`, `badge-itglue`, `badge-smileback`

**Badge colors (add to CSS if not in reference template):**
```css
.prx-report .badge-psa { background: #DBEAFE; color: #1E40AF; border-color: #1D4ED8; }
.prx-report .badge-rmm { background: #FDE68A; color: #78350F; border-color: #B45309; }
.prx-report .badge-backup { background: #FECACA; color: #7F1D1D; border-color: #DC2626; }
.prx-report .badge-m365 { background: #E9D5FF; color: #581C87; border-color: #7C3AED; }
.prx-report .badge-itglue { background: #A7F3D0; color: #064E3B; border-color: #059669; }
.prx-report .badge-smileback { background: #FEF3C7; color: #713F12; border-color: #D97706; }
```

### Step 6: Generate the Complete HTML Report
Build the self-contained HTML file following the exact structure below. The output must work as a single paste into a WordPress Custom HTML block.

## Default Environment

| Resource | ID |
|----------|-----|
| Workspace (Proxuma Demo) | `1d365f6a-1dbb-4466-88e1-487f6836b452` |
| Dataset (Data model Template) | `fd823eb4-da85-449d-a175-d24bff86229f` |

## Output

1. Save the **teal-frame only** HTML to `~/ClaudeCode/powerbi-reports/proxuma-io-[slug]-post.html`
   - The teal frame is ONLY the `<div class="prx-report">...</div>` content — no morph bar, no search hero, no CTA
2. **Deploy to WordPress** using `deploy_report()` from `batch_generate.py`:
   ```python
   import sys, os
   sys.path.insert(0, os.path.expanduser('~/ClaudeCode/powerbi-reports'))
   from batch_generate import deploy_report
   deploy_report('proxuma-io-[slug]-post.html', PAGE_ID, slug='[slug]', search_query='[question]', title='[Title]', badges=['psa'], lang='en')
   ```
   This automatically: wraps with chrome (morph bar, search hero, pipeline, overview, CTA, series nav), injects related reports with BreadcrumbList JSON-LD, and pushes to WordPress via `$wpdb->update()`.
3. **Repeat for NL version**: Generate the Dutch teal-frame HTML, save as `proxuma-io-[nl-slug]-post.html`, and deploy with `lang='nl'`.
4. **Add a gallery card** to `~/ClaudeCode/powerbi-reports/proxuma-io-insights-gallery.html` — insert a new `<a class="report-card">` card inside the `.reports-grid` div (before its closing `</div>`), following the exact format of existing cards.
5. Open the report in browser to verify
6. Tell user: "Published EN + NL reports with chrome wrapper, related reports, and BreadcrumbList schema."

**If no page ID exists yet**, ask the user for the EN and NL WordPress page IDs before deploying.

---

## Teal Frame Output Format

The AI generates ONLY the teal-frame document. The chrome wrapper (morph bar, search hero, pipeline, overview, CTA, series nav, related reports, JS) is added automatically by `deploy_report()` during deployment.

**Do NOT include** morph bar CSS/HTML, search hero, CTA block, or any `<script>` tags in the teal-frame file. Those are injected by `wrap_with_chrome()` in `deploy_reports_lib.py`.

The teal-frame HTML file contains only:

```html
<div class="prx-report">
<!-- CSS block from teal-frame-css.html goes here (copy verbatim) -->
<!-- Then any report-specific chart CSS in a SEPARATE <style> block -->

<div class="report-frame-outer">
<div class="doc">
  <!-- doc-header, doc-title-block, doc-demo, doc-body, doc-footer -->
</div>
</div>
</div>

<script type="application/ld+json">
{ "@context": "https://schema.org", "@type": "FAQPage", ... }
</script>
<script>
function prxCopyDAX(btn){...}
</script>
```

---

## Report Structure — V5 "Printed Document" Format

The report consists of TWO layers:

1. **Teal frame document** (the report content) — generated by the AI, saved as the HTML file
2. **Chrome wrapper** (morph bar, search hero, pipeline, overview, CTA, related reports) — added by `deploy_report()` via `wrap_with_chrome()` + `inject_related_reports()` when pushing to WordPress

The AI generates ONLY the teal frame document. The chrome wrapper is added automatically by `deploy_report()` from `batch_generate.py`.

### Architecture

```
<style>morph bar CSS + chrome CSS</style>           ← wrap_with_chrome() adds
<div class="prx-morph-bar">...</div>                ← wrap_with_chrome() adds

<div class="prx-report" id="prx-frame-top">
  <style>template CSS</style>                       ← from teal-frame-css.html (in teal frame)
  <nav class="series-nav">...</nav>                 ← wrap_with_chrome() injects
  <div class="search-hero">...</div>                ← wrap_with_chrome() injects
  <div class="pipeline-section">...</div>           ← wrap_with_chrome() injects
  <div class="overview-section">...</div>           ← wrap_with_chrome() injects

  <div class="report-frame-outer">                  ← AI generates from here
    <div class="doc">
      .doc-header
      .doc-title-block
      .doc-demo
      .doc-body > .doc-section (numbered)
      .doc-footer
    </div>
  </div>                                            ← AI generates to here

  <div class="related-reports">...</div>            ← inject_related_reports() adds
  <div class="cta-block">...</div>                  ← wrap_with_chrome() injects
</div>

<script>morph JS + copy JS</script>                 ← wrap_with_chrome() adds
<script type="application/ld+json">BreadcrumbList</script>  ← inject_related_reports() adds
```

**No real client/resource names — always anonymize to "Client A", "Client B", etc.**

### Reference implementation

`~/ClaudeCode/powerbi-reports/generate-test-reports.py` — working generator with chart helpers, `wrap_report()`, and 12 report functions. Copy patterns from this file.

---

### Teal Frame Document Structure

The AI generates the content inside `.report-frame-outer`. This is what goes into the HTML file.

#### Document header
```html
<div class="prx-report">
<!-- CSS block from teal-frame-css.html goes here (copy verbatim) -->

<div class="report-frame-outer">
<div class="doc">
  <div class="doc-header">
    <div>
      <div class="doc-logo">
        <!-- Proxuma SVG logo — copy from GOLDEN-STANDARD.html -->
      </div>
      <div class="doc-type">AI-Generated Power BI Report</div>
    </div>
    <div class="doc-header-right">
      <div class="doc-meta-row"><strong>Date:</strong> March 2026</div>
      <div class="doc-meta-row"><strong>Source:</strong> Autotask PSA &middot; Power BI</div>
      <div class="doc-meta-row"><strong>Scope:</strong> [e.g., "67,521 tickets &middot; All clients"]</div>
    </div>
  </div>
```

#### Title block + demo banner
```html
  <div class="doc-title-block">
    <div class="doc-title">[Report Title]</div>
    <p class="doc-subtitle">[1-2 sentence subtitle describing what was analyzed and key finding]</p>
  </div>

  <div class="doc-demo"><strong>Demo Report:</strong> This report uses synthetic data to demonstrate AI-generated insights from Proxuma Power BI. The structure, DAX queries, and analysis reflect real MSP data patterns.</div>
```

#### Document body (numbered sections)
```html
  <div class="doc-body">
    <!-- Sections 1.0 through 8.0 go here -->
  </div>
```

#### Document footer
```html
  <div class="doc-footer">
    <span>Proxuma Power BI &middot; AI-Generated Report &middot; proxuma.io/powerbi</span>
    <span>Generated in &lt; 15 minutes via MCP &middot; March 2026</span>
  </div>
</div>
</div>
</div>
```

#### JSON-LD FAQ + Copy JS (after closing `.prx-report`)
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type":"Question","name":"[Q1]","acceptedAnswer":{"@type":"Answer","text":"[A1]"}},
    {"@type":"Question","name":"[Q2]","acceptedAnswer":{"@type":"Answer","text":"[A2]"}}
  ]
}
</script>
<script>
function prxCopyDAX(btn){var c=btn.parentElement.querySelector('code');if(c){navigator.clipboard.writeText(c.textContent).then(function(){btn.textContent='Copied!';setTimeout(function(){btn.textContent='Copy Query'},1500)})}}
</script>
```

---

### Section Components (inside `.doc-body`)

#### Numbered section
Every data section follows this pattern:
```html
    <div class="doc-section">
      <div class="doc-section-head">
        <span class="doc-section-num">1.0</span>
        <span class="doc-section-title">[Section Title]</span>
      </div>
      <p class="doc-section-sub">[1-sentence description of what this section shows]</p>

      <!-- DATA: KPIs, charts, tables -->

      <!-- DAX TOGGLE (required per section, at the bottom) -->
      <div class="dax-toggle" onclick="this.classList.toggle('expanded')">
        <div class="dax-trigger">
          <svg class="dax-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 9l-7 7-7-7"/></svg>
          <span>View DAX Query &mdash; [Description]</span>
        </div>
        <div class="dax-content">
          <pre><code>EVALUATE ...</code></pre>
          <button class="dax-copy" onclick="event.stopPropagation();prxCopyDAX(this)">Copy Query</button>
        </div>
      </div>
    </div>
```

Number sections sequentially: 1.0, 2.0, 3.0, etc. through 8.0. The last numbered section (typically 9.0) is always the FAQ.

#### DAX explanation box (after section 1.0 only)
```html
      <div class="doc-dax-box" style="margin-top:12px;">
        <strong>What are these DAX queries?</strong> DAX (Data Analysis Expressions) is the formula language Power BI uses to query data. Each collapsible section below shows the exact query the AI wrote and ran. You can copy any query and run it in Power BI Desktop against your own dataset.
      </div>
```

#### KPI row (inside any section)
```html
      <div class="doc-kpi-row">
        <div class="doc-kpi">
          <div class="doc-kpi-label">METRIC NAME</div>
          <div class="doc-kpi-value">67,521</div>
          <div class="doc-kpi-note green">98.8% completion rate</div>
        </div>
        <!-- 2-4 more doc-kpi divs -->
      </div>
```

Note colors: `green`, `red`, `amber`, `muted` (gray).

#### Findings/insights (inside any section, typically the last data section)
```html
      <div class="doc-finding critical">
        <h4>1. [Numbered, actionable insight title]</h4>
        <p>[2-3 sentences with specific data points and recommended actions. Bold key numbers.]</p>
      </div>
      <div class="doc-finding warning">
        <h4>2. [Next insight]</h4>
        <p>[Details]</p>
      </div>
      <div class="doc-finding success">
        <h4>3. [Positive insight or opportunity]</h4>
        <p>[Details]</p>
      </div>
```

Use `.critical` (red left border), `.warning` (amber), `.success` (green).

#### FAQ section (always the last numbered section)
```html
    <div class="doc-section">
      <div class="doc-section-head">
        <span class="doc-section-num">9.0</span>
        <span class="doc-section-title">Frequently Asked Questions</span>
      </div>
      <div class="doc-faq">
        <div class="faq-item" onclick="this.classList.toggle('open')">
          <div class="faq-q"><span>[Question text]</span><svg class="faq-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 9l-7 7-7-7"/></svg></div>
          <div class="faq-a"><p>[Answer text]</p></div>
        </div>
        <!-- 5-7 FAQ items -->
      </div>
    </div>
```

---

### Data Visualizations (inside sections)

**Available chart types:**
- **Donut charts** — Pure SVG rings showing percentages. Use `.chart-row` to lay out multiple donuts side by side.
- **Horizontal bar charts** — `.hbar-chart` > `.hbar-row` > `.hbar-label` + `.hbar-track` > `.hbar-fill.[color]` + `.hbar-val`
- **Comparison bars** — `.cbar-chart` > `.cbar-group` > `.cbar-group-label` + `.cbar-pair` > `.cbar-bar` (side-by-side pairs with legend)
- **Segmented bars** — `.seg-chart` > `.seg-row` > `.seg-label` + `.seg-track` > `.seg-piece` (stacked segments with legend)
- **Line charts** — Pure SVG with grid, axes, polyline paths, dots, and value labels. Use `.line-chart-wrap` > `<svg>`.
- **Tables** — `<table>` with `.num`, `.num-ok`, `.num-danger`, `.num-warn`, `.client-name`, `.pill-*`, `.pct-badge` classes
- **Two/three-column grids** — `.two-col` / `.three-col` for side-by-side comparisons
- **Italic footnotes** — `<p style="font-size:0.82rem; color:#64748b; margin-top:16px; font-style:italic;">` after tables for editorial commentary

#### Donut chart HTML pattern
```html
<div class="chart-row">
  <div class="donut-chart lg">
    <svg width="170" height="170" viewBox="0 0 170 170">
      <circle class="donut-bg" cx="85" cy="85" r="55"/>
      <!-- stroke-dasharray = (percentage/100) * 2πr, remainder = 2πr - filled -->
      <!-- 2πr for r=55 = 345.58. So 80% = 276.46, remainder = 69.12 -->
      <circle class="donut-fg green" cx="85" cy="85" r="55" stroke-dasharray="276.46 69.12"/>
      <text class="donut-value" x="85" y="79">80.0%</text>
      <text class="donut-sublabel" x="85" y="101">Target: 85%</text>
    </svg>
    <div class="donut-label">Metric Name</div>
  </div>
  <!-- more donut-chart divs -->
</div>
```
Color variants: `.green`, `.red`, `.amber`, `.teal`, `.blue`, `.purple`, `.slate`, `.navy`. Use `.lg` for large (170px) or omit for small (140px, use r=55 cx/cy=70).

#### Horizontal bar chart HTML pattern
```html
<div class="hbar-chart">
  <div class="hbar-row">
    <div class="hbar-label">Category</div>
    <div class="hbar-track"><div class="hbar-fill teal" style="width:72%"><span class="hbar-val">72%</span></div></div>
    <div class="hbar-note">1,234</div>
  </div>
</div>
```

#### Comparison bar HTML pattern
```html
<div class="cbar-chart">
  <div class="cbar-group">
    <div class="cbar-group-label">Category</div>
    <div class="cbar-pair">
      <div class="cbar-bar" style="width:72%;background:#3b82f6"><span>72%</span></div>
      <div class="cbar-bar" style="width:85%;background:#0f766e"><span>85%</span></div>
    </div>
  </div>
  <div class="cbar-legend"><span><span class="cbar-swatch" style="background:#3b82f6"></span>Metric A</span><span><span class="cbar-swatch" style="background:#0f766e"></span>Metric B</span></div>
</div>
```

#### Line chart HTML pattern
```html
<div class="line-chart-wrap"><svg viewBox="0 0 520 200">
  <!-- Grid lines -->
  <line class="line-grid" x1="45" y1="170" x2="500" y2="170"/>
  <text class="line-y-label" x="40" y="173">0</text>
  <!-- More grid lines at y=140, 110, 80, 50, 20 -->
  <line class="line-axis" x1="45" y1="170" x2="500" y2="170"/>
  <!-- X-axis labels -->
  <text class="line-label" x="45" y="195">Jan</text>
  <!-- Data line -->
  <polyline class="line-path teal" points="45,120 136,95 227,80 318,65 409,70 500,55"/>
  <!-- Dots + value labels -->
  <circle class="line-dot teal" cx="45" cy="120"/>
  <text class="line-val" x="45" y="110">42</text>
</svg></div>
<div class="line-legend"><span><span class="line-legend-dot" style="background:#0f766e"></span>Series A</span></div>
```
Calculate Y positions: `y = 170 - ((value - min) / (max - min)) * 150`. X positions evenly spaced from 45 to 500.

#### Chart CSS (add to report `<style>` block after base CSS)
```css
/* === DONUT CHARTS === */
.prx-report .chart-row{display:flex;gap:32px;justify-content:center;flex-wrap:wrap;margin:20px 0 8px;}
.prx-report .chart-row.left{justify-content:flex-start;gap:40px;padding-left:4px;}
.prx-report .donut-chart{display:flex;flex-direction:column;align-items:center;gap:6px;}
.prx-report .donut-chart.lg svg{width:170px;height:170px;}
.prx-report .donut-chart svg{transform:rotate(-90deg);}
.prx-report .donut-bg{fill:none;stroke:#e2e8f0;stroke-width:10;}
.prx-report .donut-fg{fill:none;stroke-width:10;stroke-linecap:round;}
.prx-report .donut-fg.green{stroke:#10B981;}.prx-report .donut-fg.red{stroke:#ef4444;}.prx-report .donut-fg.amber{stroke:#f59e0b;}.prx-report .donut-fg.teal{stroke:#0f766e;}.prx-report .donut-fg.blue{stroke:#3b82f6;}.prx-report .donut-fg.purple{stroke:#8b5cf6;}.prx-report .donut-fg.slate{stroke:#64748b;}.prx-report .donut-fg.navy{stroke:#1B365D;}
.prx-report .donut-value{font-family:'Open Sans',sans-serif;font-size:1.1rem;font-weight:800;fill:#1B365D;transform:rotate(90deg);dominant-baseline:central;text-anchor:middle;}
.prx-report .donut-chart.lg .donut-value{font-size:1.4rem;}
.prx-report .donut-sublabel{font-family:'Open Sans',sans-serif;font-size:0.58rem;font-weight:600;fill:#94a3b8;transform:rotate(90deg);dominant-baseline:central;text-anchor:middle;}
.prx-report .donut-label{font-size:0.72rem;font-weight:600;color:#64748b;text-align:center;max-width:120px;line-height:1.3;}

/* === HORIZONTAL BAR CHART === */
.prx-report .hbar-chart{margin:18px 0 8px;}
.prx-report .hbar-row{display:flex;align-items:center;gap:10px;margin-bottom:8px;}
.prx-report .hbar-row:last-child{margin-bottom:0;}
.prx-report .hbar-label{font-size:0.76rem;font-weight:600;color:#1B365D;width:120px;flex-shrink:0;text-align:right;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.prx-report .hbar-track{flex:1;height:22px;background:#f1f5f9;border-radius:3px;position:relative;overflow:hidden;}
.prx-report .hbar-fill{height:100%;border-radius:3px;display:flex;align-items:center;padding-left:8px;min-width:2px;}
.prx-report .hbar-fill.teal{background:#0f766e;}.prx-report .hbar-fill.blue{background:#3b82f6;}.prx-report .hbar-fill.navy{background:#1B365D;}.prx-report .hbar-fill.green{background:#10B981;}.prx-report .hbar-fill.amber{background:#f59e0b;}.prx-report .hbar-fill.red{background:#ef4444;}.prx-report .hbar-fill.purple{background:#8b5cf6;}.prx-report .hbar-fill.slate{background:#94a3b8;}
.prx-report .hbar-val{font-size:0.68rem;font-weight:700;color:white;white-space:nowrap;}
.prx-report .hbar-val.outside{color:#475569;position:absolute;right:-50px;top:50%;transform:translateY(-50%);}
.prx-report .hbar-note{font-size:0.68rem;color:#94a3b8;width:60px;flex-shrink:0;text-align:left;}

/* === COMPARISON BAR === */
.prx-report .cbar-chart{margin:18px 0 8px;}
.prx-report .cbar-group{margin-bottom:14px;}.prx-report .cbar-group:last-child{margin-bottom:0;}
.prx-report .cbar-group-label{font-size:0.74rem;font-weight:700;color:#1B365D;margin-bottom:5px;}
.prx-report .cbar-pair{display:flex;gap:6px;align-items:center;}
.prx-report .cbar-bar{height:16px;border-radius:3px;display:flex;align-items:center;padding:0 8px;min-width:2px;}
.prx-report .cbar-bar span{font-size:0.64rem;font-weight:700;color:white;white-space:nowrap;}
.prx-report .cbar-legend{display:flex;gap:16px;margin-top:10px;font-size:0.7rem;color:#64748b;}
.prx-report .cbar-swatch{display:inline-block;width:10px;height:10px;border-radius:2px;margin-right:4px;vertical-align:middle;}

/* === SEGMENTED BAR === */
.prx-report .seg-chart{margin:18px 0 8px;}
.prx-report .seg-row{display:flex;align-items:center;gap:10px;margin-bottom:10px;}.prx-report .seg-row:last-child{margin-bottom:0;}
.prx-report .seg-label{font-size:0.74rem;font-weight:600;color:#1B365D;width:100px;flex-shrink:0;text-align:right;}
.prx-report .seg-track{flex:1;height:22px;display:flex;border-radius:3px;overflow:hidden;}
.prx-report .seg-piece{height:100%;display:flex;align-items:center;justify-content:center;min-width:1px;}
.prx-report .seg-piece span{font-size:0.6rem;font-weight:700;color:white;white-space:nowrap;}
.prx-report .seg-legend{display:flex;gap:14px;flex-wrap:wrap;margin-top:10px;font-size:0.7rem;color:#64748b;}
.prx-report .seg-swatch{display:inline-block;width:10px;height:10px;border-radius:2px;margin-right:4px;vertical-align:middle;}

/* === LINE CHARTS === */
.prx-report .line-chart-wrap{margin:20px 0 8px;overflow-x:auto;}
.prx-report .line-chart-wrap svg{display:block;width:100%;max-width:560px;margin:0 auto;}
.prx-report .line-grid{stroke:#e2e8f0;stroke-width:0.5;}
.prx-report .line-axis{stroke:#cbd5e1;stroke-width:1;}
.prx-report .line-path{fill:none;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round;}
.prx-report .line-path.teal{stroke:#0f766e;}.prx-report .line-path.blue{stroke:#3b82f6;}.prx-report .line-path.red{stroke:#ef4444;}.prx-report .line-path.amber{stroke:#f59e0b;}.prx-report .line-path.navy{stroke:#1B365D;}
.prx-report .line-area{opacity:0.08;}.prx-report .line-area.teal{fill:#0f766e;}.prx-report .line-area.blue{fill:#3b82f6;}
.prx-report .line-dot{r:4;stroke:white;stroke-width:2;}
.prx-report .line-dot.teal{fill:#0f766e;}.prx-report .line-dot.blue{fill:#3b82f6;}.prx-report .line-dot.red{fill:#ef4444;}.prx-report .line-dot.amber{fill:#f59e0b;}.prx-report .line-dot.navy{fill:#1B365D;}
.prx-report .line-val{font-family:'Open Sans',sans-serif;font-size:8px;font-weight:700;fill:#475569;text-anchor:middle;}
.prx-report .line-label{font-family:'Open Sans',sans-serif;font-size:10px;fill:#64748b;text-anchor:middle;}
.prx-report .line-y-label{font-family:'Open Sans',sans-serif;font-size:9px;fill:#94a3b8;text-anchor:end;}
.prx-report .line-legend{display:flex;gap:18px;justify-content:center;margin-top:8px;font-size:0.72rem;color:#475569;}
.prx-report .line-legend-dot{display:inline-block;width:10px;height:10px;border-radius:50%;margin-right:5px;vertical-align:middle;}
```

**When to use each chart type:**
- **Donut**: Single KPI as percentage (SLA compliance, utilization, completion rate). Use `.lg` for hero metrics, small for secondary.
- **Horizontal bar**: Ranked categories (queues, priorities, resources). Good for 4-10 items.
- **Comparison bar**: Two metrics side by side per category (first response vs resolution SLA).
- **Segmented bar**: Composition breakdown (ticket types per queue, status distribution).
- **Line chart**: Trends over time (monthly volumes, SLA trends, 6-12 data points).
- **Tables**: Detailed multi-column data with sortable impression. Best when exact numbers matter.

---

### Chrome Components (added by deploy-reports.py, NOT by the AI)

These elements are injected automatically during WordPress deployment. Listed here for reference only.

#### Series Navigation (injected before teal frame)
```html
<nav class="series-nav">
    <a href="/powerbi">Power BI</a>
    <span class="sep">&rsaquo;</span>
    <a href="/powerbi/insights">AI-Powered Reports</a>
    <span class="sep">&rsaquo;</span>
    <span class="current">[Topic Name]</span>
</nav>
```

#### Search Hero (injected before teal frame)
```html
<div class="search-hero">
    <div class="search-hero-deco"></div>
    <span class="search-hero-badge">
        <svg viewBox="0 0 24 24"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
        AI-GENERATED REPORT
    </span>
    <div class="search-bar">
        <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <span class="search-bar-text">[question]<span class="search-bar-cursor"></span></span>
    </div>
    <h1>[SEO-optimized Title]</h1>
    <p class="search-hero-sub">[Meta description text]</p>
</div>
```

#### CTA Block (injected after teal frame)
```html
<div class="cta-block">
    <h3>Generate reports like this from your own data</h3>
    <p>Connect Proxuma's Power BI integration, then use any MCP-compatible AI to ask questions and generate custom reports &mdash; in minutes, not days.</p>
    <a href="/powerbi/insights" class="cta-btn" style="margin-right:12px;">See more reports</a>
    <a href="https://proxuma.io/powerbi-self-onboarding/" class="cta-btn">Get started</a>
</div>
```

### Deprecated Classes (DO NOT USE)

These old V4 classes are replaced by V5 equivalents:

| Old (V4) | New (V5) | Notes |
|----------|----------|-------|
| `.page-hero` | `.search-hero` | Search bar + badge replaces navy gradient |
| `.question-showcase` | (removed) | Question now in morph bar + search bar |
| `.report-banner` | `.doc-header` + `.doc-title-block` | Letterhead format |
| `.section-card` | `.doc-section` | Numbered sections in document |
| `.inline-dax` | `.dax-toggle` | Different HTML structure |
| `.kpi-grid` + `.kpi-card` | `.doc-kpi-row` + `.doc-kpi` | Inside sections |
| `.insight` | `.doc-finding` | Same severity classes |
| `.article-intro` | (removed) | No editorial prose between sections |
| `.demo-banner` | `.doc-demo` | Inside the document |

---

## Writing Style

- **Problem-solution-action.** Every report starts with a relatable business problem, presents data that answers it, then gives specific actions.
- **Conversational but professional.** Write like a smart colleague presenting findings, not a generic BI tool.
- **Bold key phrases** in doc-subtitle and doc-finding text using `<strong>` (inherits navy `#2c3e50`).
- **Use real numbers** from the DAX queries. Never fabricate data.
- **Anonymize all client/resource names** to "Client A", "Client B", etc. in the public-facing report. Never expose real company or person names.
- **Em dashes** (`&mdash;`) not hyphens for parenthetical clauses.
- **Euro signs** (`&euro;`) for currency when relevant, or `$` for USD.
- **Section descriptions** are always 1 sentence, descriptive, in `.doc-section-sub`.
- **Finding cards** are numbered ("1. ...", "2. ...") and contain specific data-backed recommendations.
- **Footnotes** below tables provide editorial interpretation of the data in italic gray text.

### Humanizer (MANDATORY)

**All narrative text in the report MUST be humanized.** Before finalizing, apply the humanizer skill (`~/.claude/skills/humanizer/SKILL.md`) to all written prose: doc-subtitle, doc-finding text, doc-section-sub descriptions, footnotes, and FAQ answers. Specifically:

- No significance inflation ("pivotal", "crucial", "vital", "testament", "underscores")
- No promotional language ("groundbreaking", "vibrant", "stunning", "nestled")
- No AI vocabulary ("delve", "landscape", "tapestry", "foster", "leverage", "garner")
- No copula avoidance — use "is"/"are"/"has" instead of "serves as"/"stands as"/"boasts"
- No superficial -ing phrases ("highlighting", "underscoring", "showcasing", "reflecting")
- No negative parallelisms ("It's not just X; it's Y")
- No rule-of-three padding ("innovation, collaboration, and excellence")
- No false ranges ("from X to Y, from A to B")
- No excessive hedging or filler phrases
- No generic positive conclusions ("the future looks bright")
- Vary sentence length and structure naturally
- Use specific numbers and concrete details over vague claims
- Write like a real person who looked at the data, not like a report generator

---

## SEO Optimization

Every report should be optimized for search engines. Before generating the report:

1. **Check the content planner** at `~/ClaudeCode/autotask-content-planner.html` for matching keywords
2. **doc-title**: Include the primary keyword (tool name like "Autotask", "IT Glue", "M365") + "MSP" where natural
3. **doc-section-title headings**: Include secondary keywords — never generic headings like "Overview" or "Analysis"
4. **doc-subtitle**: Naturally weave in 2-3 target keyword phrases in bold (`<strong>`)
5. **Breadcrumb**: Match the doc-title topic name
6. **doc-finding h4 titles**: Include relevant keywords
7. **FAQ questions**: Target long-tail search queries MSP owners would ask

---

## Search Bar Question (CRITICAL)

The search bar in the search hero MUST contain a **real conversational question ending with a question mark**. This is the `search_query` field in report_builder.py config.

**CORRECT:** `what's our average CSAT rating across all clients?`
**CORRECT:** `how much time does each engineer spend per ticket?`
**CORRECT:** `which clients are most likely to churn and how much revenue is at risk?`

**WRONG:** `average CSAT rating` (not a question)
**WRONG:** `capacity variance planned vs actual hours` (just a topic description)
**WRONG:** `billing item analysis revenue by type and client` (keyword dump)

The question should be lowercase, casual, and match what an MSP owner would actually type into a search bar. Always end with `?`.

---

## Memory Safety Rules

1. **NEVER** use `get_schema` - it returns the full model (>10MB)
2. **ALWAYS** use `search_schema` with specific terms
3. **LIMIT** DAX results with `TOPN()` or filters
4. Keep searches focused - max 3-5 search terms per question
5. Run 4-8 DAX queries to get enough data for 4-7 sections

---

## Verified Power BI Column Names

Use these exact column names in DAX queries (verified Feb 2026):

| Column | Table | Notes |
|--------|-------|-------|
| `priority_name` | `BI_Autotask_Tickets` | NOT `priority` |
| `queue_name` | `BI_Autotask_Tickets` | NOT `queueName` |
| `ticket_type_name` | `BI_Autotask_Tickets` | NOT `ticketType` |
| `company_name` | `BI_Autotask_Tickets` | Client name |
| `status_name` | `BI_Autotask_Tickets` | e.g. "Complete" |
| `ticket_id` | `BI_Autotask_Tickets` | Primary key |
| `resolution_duration_hours` | `BI_Autotask_Tickets` | Float |
| `first_response_met` | `BI_Autotask_Tickets` | Int64 (0/1), filter with `+ 0 = 1` |
| `resolution_met` | `BI_Autotask_Tickets` | Int64 (0/1), filter with `+ 0 = 1` |
| `resolved_due_age_days` | `BI_Autotask_Tickets` | > 0 means overdue (no `is_sla_overdue` column) |
| `create_date` | `BI_Autotask_Tickets` | DateTime |
| `manufacturer_product_name` | `BI_Autotask_Configuration_Items` | Microsoft Part Number |

---

## Dual-Language Output

Every `/powerbireport` invocation creates BOTH English and Dutch versions.

- **EN:** `/powerbi/insights/[slug]` (parent page 3299)
- **NL:** `/nl-powerbi/ai-gegenereerde-rapporten/[nl-slug]` (parent page 3495)

### Dutch Translation Guidelines

- Use "je/jij" (NOT "u/uw") for second person
- Apply `/dutch-msp` code-switching (English tech terms in Dutch prose)
- Apply `/humanizer` anti-slop checks
- `doc-type`: "AI-gegenereerd Power BI Rapport"
- `doc-demo`: "Demorapport: Dit rapport gebruikt synthetische data..."
- `doc-footer`: "Proxuma Power BI &middot; AI-gegenereerd Rapport"
- DAX toggle: "Bekijk DAX Query" / "Kopieer Query"
- FAQ section title: "Veelgestelde Vragen"
- CTA: "Genereer rapporten als deze vanuit je eigen data"

### Dutch Name Replacement (NL reports only)

NL reports replace American demo names (from Power BI's synthetic dataset) with Dutch equivalents. This happens in two stages in `batch_generate.py`:

1. **`dutchify_results(results)`** — Replaces names in raw DAX query result dicts *before* any truncation. Called right after DAX queries return, before building value_cards and sections. This is the primary mechanism that ensures bar chart labels (`[:25]`), KPI cards (`[:18]`), and other truncated values show Dutch names correctly.

2. **`dutchify_names(html)`** — String-replaces names in the final HTML as a safety net for any narrative text or values that bypassed `dutchify_results()`.

Name mappings (`NL_COMPANY_NAMES` and `NL_RESOURCE_NAMES` dicts) are defined at the top of `batch_generate.py`. If the Power BI demo dataset changes and new company/resource names appear, add them to these dicts before regenerating NL reports.

### Dutch Title Case Rules

Capitalize: nouns (Dutch and English) + first word after colon.
Lowercase: verbs, pronouns, prepositions, articles, adjectives.

**Correct:** `Ticketverdeling per Categorie & Issuetype: Welke Problemen Lost je MSP Eigenlijk Op?`
**Wrong:** `Ticketverdeling Per Categorie & Issuetype: Welke Problemen Lost Je Msp Eigenlijk Op?`

---

## Deployment Workflow

### Single report (via /powerbireport)
After generating the teal-frame HTML, deploy using Python:
```python
import sys, os
sys.path.insert(0, os.path.expanduser('~/ClaudeCode/powerbi-reports'))
from batch_generate import deploy_report
# EN
deploy_report('proxuma-io-[slug]-post.html', EN_PAGE_ID, slug='[slug]', search_query='[question]', title='[Title]', badges=['psa'], lang='en')
# NL
deploy_report('proxuma-io-[nl-slug]-post.html', NL_PAGE_ID, slug='[nl-slug]', search_query='[nl-question]', title='[NL Title]', badges=['psa'], lang='nl')
```

### Batch regeneration
```bash
cd ~/ClaudeCode/powerbi-reports
python3 batch_generate.py          # All EN reports
python3 batch_generate_nl.py       # All NL reports
```

### What `deploy_report()` does:
1. Reads teal-frame HTML from disk
2. Wraps with chrome via `wrap_with_chrome()` (morph bar, search hero, pipeline, overview, CTA, series nav, JS)
3. Injects related reports + BreadcrumbList JSON-LD via `inject_related_reports()`
4. SCPs wrapped HTML to server as temp file
5. Updates via `$wpdb->update()` (NEVER `wp_update_post()`)
6. Flushes cache: `wp cache flush && wp sg purge`

### WordPress push rules

- **NEVER** use `wp_update_post()` or `wp post update` — they run `wp_kses_post()` which strips all `<style>` and `<script>` tags
- **ALWAYS** use `$wpdb->update()` directly via a PHP script
- **ALWAYS** flush cache after: `wp cache flush && wp sg purge`

### Page ID mappings (test reports)

| Report | EN Page | NL Page |
|--------|---------|---------|
| SLA Compliance | 3990 | 4070 |
| Priority Distribution | 4004 | 4083 |
| Queue Performance | 4001 | 4080 |
| First Hour Fix | 4006 | 4082 |
| Ticket Volume | 3999 | 4077 |

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `~/.claude/commands/powerbireport.md` | This spec (the skill definition) |
| `~/ClaudeCode/powerbi-reports/GOLDEN-STANDARD.html` | Live reference from page 3956 (CSAT) |
| `~/ClaudeCode/powerbi-reports/templates/teal-frame-css.html` | Locked CSS template (copy verbatim) |
| `~/ClaudeCode/powerbi-reports/batch_generate.py` | EN batch generator + `deploy_report()` function |
| `~/ClaudeCode/powerbi-reports/batch_generate_nl.py` | NL batch generator (reuses `deploy_report()`) |
| `~/ClaudeCode/powerbi-reports/deploy_reports_lib.py` | `wrap_with_chrome()`, `push_via_tempfile()`, chrome CSS |
| `~/ClaudeCode/powerbi-reports/add-related-reports.py` | `inject_related_reports()`, `build_registry()` |
| `~/ClaudeCode/powerbi-reports/report_builder.py` | Chart helpers: `donut_row`, `hbar_chart`, `line_chart_svg` |
| `~/ClaudeCode/powerbi-reports/generate-test-reports.py` | Legacy test generator (12 report functions) |
