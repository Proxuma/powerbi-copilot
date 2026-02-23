# Power BI Report Generator

Generate a complete HTML report from Power BI data. Output a single self-contained HTML file.

**Question:** $ARGUMENTS

**If no question is specified, ask the user what they want to analyze.**

---

## RULES — Read all of these before generating any output

1. **OUTPUT = one complete HTML file.** Not a summary. Not a description. Not bullet points. The actual, full, renderable HTML.
2. **Write EVERY section in full.** Never say "similar sections follow", "and so on", "etc.", or "repeat the pattern above." Write out every table row, every paragraph, every FAQ item.
3. **Use REAL data from your DAX queries.** Never fabricate numbers. If a query returns 15 rows, show 15 rows.
4. **Anonymize all names.** Clients become "Client A", "Client B". Resources become "Tech 1", "Tech 2". Never output real names.
5. **Minimum 500 lines of HTML.** A proper report is 800-1200 lines. If your output is under 500 lines, you summarized — go back and write the full report.
6. **CSS and JS blocks marked FROZEN must be copied character-for-character.** Do not modify, rearrange, add to, or remove any selector, property, value, or variable.
7. **Replace every {{PLACEHOLDER}} with real content.** Do not leave any {{PLACEHOLDER}} in the final output.
8. **Do not add any CSS or JS** beyond what is in the template. No extra `<style>` or `<script>` tags.
9. **Do not skip the DAX toggles.** Every data section needs a collapsible DAX query showing the exact query you ran.
10. **Generation time text must say "under fifteen minutes"** — not "two minutes", not "instantly".

---

## Step 1: Find Relevant Data (2-3 calls)

Extract 2-3 keywords from the business question and search the data model:

```
search_schema(search_term="keyword1")
search_schema(search_term="keyword2")
```

If the user has set default IDs in `config.json`, you can omit workspace_id/dataset_id.

**NEVER use `get_schema`** — it returns >10MB and will crash the session.

Review the results to identify which measures and columns to query.

---

## Step 2: Run DAX Queries (4-8 calls)

Build and execute DAX queries to collect data for the full report:

- **Summary KPIs** — totals, averages, counts (for Section 1.0)
- **Main breakdown** — ranked table by category/client/type (for Section 2.0)
- **Deep-dive** — top/bottom performers with detail columns (for Section 3.0)
- **Volume or distribution** — counts, rates, proportions (for Section 4.0)
- **Trends** — monthly or weekly over 3-6 periods (for Section 5.0)

```
execute_dax(dax_query="EVALUATE SUMMARIZECOLUMNS(...)")
```

Always use `TOPN()` or filters. Aim for 10-50 rows per query, not thousands.

---

## Step 3: Output the HTML

Copy the complete template below. Replace each `{{PLACEHOLDER}}` with content from your DAX results. Every placeholder has a comment next to it explaining what to fill in.

### Section structure inside the document:

| Section | Type | Content |
|---------|------|---------|
| 1.0 | Summary Metrics | 4 KPI cards (label, value, colored note) + DAX toggle |
| 2.0 | Primary data table | Ranked breakdown table + DAX toggle |
| 3.0 | Detail table | Deep-dive on a segment (top/bottom) + DAX toggle |
| 4.0 | Volume/distribution | Counts, rates, bars + DAX toggle |
| 5.0 | Trends | Monthly/weekly data over time + DAX toggle |
| 6.0 | Analysis | 3-5 narrative paragraphs with bold key numbers |
| 7.0 | Action Items | 3-5 numbered findings with priority icons |
| 8.0 | FAQ | 4-6 collapsible Q&A items |

### CSS classes for table cells:

| Class | Use for |
|-------|---------|
| `num` | Any number (right-aligned, bold) |
| `num-ok` | Good value (green) |
| `num-warn` | Caution value (amber) |
| `num-danger` | Bad value (red) |
| `client-name` | Client/entity name |
| `pct-badge pct-ok` | Green badge |
| `pct-badge pct-mid` | Amber badge |
| `pct-badge pct-bad` | Red badge |
| `pct-badge pct-none` | Gray badge |
| `pill pill-green` | Green status pill |
| `pill pill-blue` | Blue status pill |
| `pill pill-amber` | Amber status pill |
| `pill pill-red` | Red status pill |
| `pill pill-gray` | Gray status pill |

### KPI note colors:

| Class | Use for |
|-------|---------|
| `doc-kpi-note green` | Positive note (green text) |
| `doc-kpi-note red` | Negative note (red text) |
| `doc-kpi-note amber` | Warning note (amber text) |
| `doc-kpi-note muted` | Neutral note (gray text) |

### Finding icon types:

| Class | Use for |
|-------|---------|
| `doc-finding-icon critical` | Red — urgent action needed |
| `doc-finding-icon warning` | Amber — should address soon |
| `doc-finding-icon ok` | Green — positive recommendation |

### Writing style:

- Problem, data, action. Start with a business observation, cite the number, recommend what to do.
- Bold key numbers: `<strong>4.28 out of 5.0</strong>`
- Write like a direct colleague, not a BI tool. Have opinions. Be specific.
- No promotional language. No "robust", "seamless", "powerful", "comprehensive".
- Every claim must reference a specific number from your DAX query results.

---

## COMPLETE HTML TEMPLATE

**Copy everything below this line exactly. Replace only the `{{PLACEHOLDER}}` values.**

```html
<!-- Power BI Report: {{REPORT_TITLE}} -->
<!-- Generated by Proxuma Power BI Copilot -->

<!-- Google Fonts -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display:ital@0;1&family=JetBrains+Mono:wght@400;500;600&family=Open+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

<!-- ============================================================ -->
<!-- MORPH BAR CSS — OPTIONAL: Only needed when publishing to WordPress. -->
<!-- If NOT publishing to WordPress, delete this entire <style> block AND the morph bar <div> below. -->
<!-- ============================================================ -->
<!-- FROZEN CSS BLOCK 1 — DO NOT MODIFY -->
<style>
.prx-morph-bar{position:fixed;top:0;left:0;right:0;z-index:10000;height:50px;pointer-events:none;display:flex;align-items:center;padding:0 28px;overflow:hidden;}
.prx-morph-bar.active{pointer-events:all;}
.prx-morph-bg{position:absolute;inset:0;background:#115e58;opacity:0;transform:scaleY(0);transform-origin:top;transition:opacity 0.25s ease,transform 0.35s cubic-bezier(0.34,1.3,0.64,1);}
.prx-morph-bar.visible .prx-morph-bg{opacity:1;transform:scaleY(1);}
.prx-morph-bar:not(.visible) .prx-morph-bg{transition:opacity 0.2s ease,transform 0.2s ease;}
.prx-morph-inner{position:relative;z-index:1;max-width:1140px;margin:0 auto;width:100%;display:flex;align-items:center;gap:16px;}
.prx-morph-q{font-family:'Open Sans',-apple-system,sans-serif;font-style:italic;font-size:0.88rem;color:white;flex:1;min-width:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.prx-morph-q .w{display:inline-block;opacity:0;transform:translateY(-18px) scale(0.8);filter:blur(2px);transition:opacity 0.25s ease,transform 0.35s cubic-bezier(0.34,1.56,0.64,1),filter 0.25s ease;}
.prx-morph-bar.visible .prx-morph-q .w{opacity:1;transform:translateY(0) scale(1);filter:blur(0);}
.prx-morph-bar:not(.visible) .prx-morph-q .w{transition-duration:0.15s;transition-delay:0s !important;}
.prx-morph-extras{display:flex;align-items:center;gap:12px;flex-shrink:0;opacity:0;transition:opacity 0.25s ease;}
.prx-morph-bar.visible .prx-morph-extras{opacity:1;transition-delay:0.45s;}
.prx-morph-pill{background:rgba(255,255,255,0.1);border-radius:100px;padding:3px 10px;font-size:0.68rem;font-weight:600;color:rgba(255,255,255,0.7);white-space:nowrap;}
.prx-morph-back{color:#5eead4;text-decoration:none;font-size:0.78rem;font-weight:600;white-space:nowrap;display:flex;align-items:center;gap:4px;}
.prx-morph-back:hover{color:white;}
.prx-morph-back svg{width:12px;height:12px;}
@media(max-width:900px){.prx-morph-extras{display:none !important;}}
</style>

<!-- ============================================================ -->
<!-- MAIN REPORT CSS — FROZEN CSS BLOCK 2 — DO NOT MODIFY -->
<!-- ============================================================ -->
<style>
.prx-report *,.prx-report *::before,.prx-report *::after{box-sizing:border-box;margin:0;padding:0;}
.prx-report{font-family:'Open Sans',-apple-system,BlinkMacSystemFont,sans-serif;color:#333;line-height:1.7;max-width:1140px;margin:0 auto;padding:0 24px;-webkit-font-smoothing:antialiased;}
.prx-report .series-nav{display:flex;align-items:center;gap:8px;margin:32px 0 0;font-size:0.85rem;}
.prx-report .series-nav a{color:#2c3e50;text-decoration:none;font-weight:600;}
.prx-report .series-nav a:hover{text-decoration:underline;}
.prx-report .series-nav .sep{color:#94a3b8;}
.prx-report .series-nav .current{color:#64748b;}
.prx-report .search-hero{background-color:#e8f4fd;background-image:radial-gradient(circle,#b8dff5 1px,transparent 1px);background-size:24px 24px;border-radius:20px;padding:48px 52px 40px;margin:24px 0 0;position:relative;overflow:hidden;}
.prx-report .search-hero::before{content:'';position:absolute;inset:0;background:linear-gradient(160deg,rgba(232,244,253,0.93) 0%,rgba(210,235,250,0.9) 100%);border-radius:inherit;pointer-events:none;}
.prx-report .search-hero > *{position:relative;}
.prx-report .search-hero-deco{position:absolute;top:-40px;right:-40px;width:240px;height:240px;background:radial-gradient(circle,rgba(46,163,242,0.13) 0%,transparent 70%);border-radius:50%;pointer-events:none;}
.prx-report .search-hero-badge{display:inline-flex;align-items:center;gap:6px;background:rgba(46,163,242,0.12);color:#1a5276;border:1px solid rgba(46,163,242,0.35);border-radius:20px;font-size:0.7rem;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:5px 13px;margin-bottom:18px;}
.prx-report .search-hero-badge svg{width:12px;height:12px;stroke:currentColor;stroke-width:2.5;fill:none;}
.prx-report .search-hero-eyebrow{font-size:0.85rem;color:#64748b;margin-bottom:8px;font-weight:500;}
.prx-report .search-bar{display:flex;align-items:center;gap:12px;background:white;border-radius:40px;padding:13px 22px;box-shadow:0 4px 20px rgba(44,62,80,0.11),0 1px 4px rgba(44,62,80,0.06);max-width:620px;margin-bottom:24px;border:1px solid #e2e8f0;}
.prx-report .search-bar svg{width:20px;height:20px;stroke:#94a3b8;stroke-width:2;flex-shrink:0;fill:none;}
.prx-report .search-bar-text{font-size:0.95rem;color:#334155;flex:1;}
.prx-report .search-bar-cursor{display:inline-block;width:2px;height:1.1em;background:#2c3e50;margin-left:2px;vertical-align:text-bottom;animation:prx-blink 1.1s step-end infinite;}
@keyframes prx-blink{0%,100%{opacity:1;}50%{opacity:0;}}
.prx-report .search-hero h1{font-family:'Open Sans',sans-serif;font-weight:800;font-size:clamp(1.65rem,3.2vw,2.3rem);color:#2c3e50 !important;line-height:1.15;margin-bottom:14px;max-width:780px;}
.prx-report .search-hero-sub{font-size:1rem;color:#475569;margin-bottom:28px;max-width:640px;line-height:1.65;}
.prx-report .search-hero-sub strong{color:#2c3e50;}
.prx-report .search-hero-sources{display:flex;align-items:center;gap:8px;flex-wrap:wrap;}
.prx-report .search-hero-sources-label{font-size:0.78rem;color:#94a3b8;}
.prx-report .source-badge{display:inline-flex;align-items:center;gap:5px;background:white;border:1px solid #e2e8f0;border-radius:20px;padding:4px 12px;font-size:0.75rem;font-weight:600;color:#475569;box-shadow:0 1px 3px rgba(0,0,0,0.05);}
.prx-report .source-badge svg{width:12px;height:12px;fill:none;stroke:currentColor;stroke-width:2;}
.prx-report .pipeline-section{background:white;border-radius:0 0 20px 20px;border:1px solid #e2e8f0;border-top:none;padding:28px 52px 28px;margin-bottom:28px;}
.prx-report .pipeline-label{font-size:0.68rem;font-weight:700;letter-spacing:1.8px;text-transform:uppercase;color:#0f766e;margin-bottom:20px;display:flex;align-items:center;gap:8px;}
.prx-report .pipeline-label::after{content:'';flex:1;height:1px;background:#e2e8f0;}
.prx-report .pipeline-track{display:grid;grid-template-columns:1fr 28px 1fr 28px 1fr 28px 1fr;align-items:center;gap:0;margin-bottom:22px;}
.prx-report .pipeline-step{background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:18px 14px 16px;text-align:center;position:relative;}
.prx-report .pipeline-step.highlight{background:linear-gradient(135deg,#0f766e 0%,#115e58 100%) !important;border-color:#0f766e !important;}
.prx-report .pipeline-step-num{position:absolute;top:-9px;left:50%;transform:translateX(-50%);background:#0f766e;color:white;font-size:0.58rem;font-weight:800;width:18px;height:18px;border-radius:50%;display:flex;align-items:center;justify-content:center;}
.prx-report .pipeline-step-icon{width:40px;height:40px;margin:0 auto 10px;border-radius:10px;background:#eef2f7;border:1px solid #e2e8f0;display:flex;align-items:center;justify-content:center;}
.prx-report .pipeline-step-icon svg{width:20px;height:20px;stroke:#2c3e50;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
.prx-report .pipeline-step.highlight .pipeline-step-icon{background:rgba(255,255,255,0.12) !important;border-color:rgba(255,255,255,0.2) !important;}
.prx-report .pipeline-step.highlight .pipeline-step-icon svg{stroke:#5eead4 !important;}
.prx-report .pipeline-step-title{font-family:'Open Sans',sans-serif;font-size:0.8rem;font-weight:700;color:#2c3e50;margin-bottom:4px;line-height:1.2;}
.prx-report .pipeline-step.highlight .pipeline-step-title{color:white !important;}
.prx-report .pipeline-step-desc{font-size:0.7rem;color:#64748b;line-height:1.4;}
.prx-report .pipeline-step.highlight .pipeline-step-desc{color:rgba(255,255,255,0.7) !important;}
.prx-report .pipeline-arrow{text-align:center;display:flex;align-items:center;justify-content:center;}
.prx-report .pipeline-arrow svg{width:16px;height:16px;stroke:#0f766e;stroke-width:2.5;fill:none;stroke-linecap:round;stroke-linejoin:round;}
.prx-report .pipeline-badge{display:inline-flex;align-items:center;gap:4px;background:rgba(94,234,212,0.2);color:#5eead4;border:1px solid rgba(94,234,212,0.4);border-radius:20px;font-size:0.62rem;font-weight:700;padding:2px 8px;margin-top:7px;}
.prx-report .pipeline-footer{display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;padding-top:16px;border-top:1px solid #f1f5f9;}
.prx-report .pipeline-footer-text{font-size:0.85rem;color:#64748b;}
.prx-report .pipeline-footer-text strong{color:#2c3e50;}
.prx-report .pipeline-cta-link{display:inline-flex;align-items:center;gap:6px;background:linear-gradient(135deg,#10B981 0%,#059669 100%);color:white !important;text-decoration:none !important;border-radius:8px;padding:9px 18px;font-size:0.82rem;font-weight:600;white-space:nowrap;transition:transform 0.3s ease,box-shadow 0.3s ease;box-shadow:0 4px 14px rgba(16,185,129,0.3);position:relative;overflow:hidden;}
.prx-report .pipeline-cta-link::before{content:'';position:absolute;top:var(--mouse-y,50%);left:var(--mouse-x,50%);width:0;height:0;background:radial-gradient(circle,#1B5299 0%,#164487 40%,#123a70 100%);border-radius:50%;transform:translate(-50%,-50%);transition:width 0.7s cubic-bezier(0.25,0.46,0.45,0.94),height 0.7s cubic-bezier(0.25,0.46,0.45,0.94);z-index:1;}
.prx-report .pipeline-cta-link:hover::before{width:600px;height:600px;}
.prx-report .pipeline-cta-link:hover{transform:translateY(-3px) !important;box-shadow:0 8px 25px rgba(22,68,135,0.4) !important;}
.prx-report .pipeline-cta-link svg{width:13px;height:13px;stroke:currentColor;stroke-width:2.5;fill:none;stroke-linecap:round;stroke-linejoin:round;position:relative;z-index:10;}
.prx-report .report-overview{background:white;border:1px solid #e2e8f0;border-radius:16px;padding:36px 40px;margin-bottom:28px;}
.prx-report .overview-grid{display:grid;grid-template-columns:1fr 300px;gap:40px;align-items:start;}
.prx-report .overview-h2{font-family:'Open Sans',sans-serif;font-size:1.25rem;font-weight:700;color:#2c3e50 !important;margin-bottom:14px;line-height:1.3;}
.prx-report .overview-body{font-size:0.92rem;color:#334155;line-height:1.7;}
.prx-report .overview-body p{margin-bottom:0.9rem;}
.prx-report .overview-body strong{color:#2c3e50;}
.prx-report .overview-meta{background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:22px 22px;font-size:0.82rem;}
.prx-report .meta-row{display:flex;justify-content:space-between;align-items:baseline;padding:7px 0;border-bottom:1px solid #f1f5f9;gap:12px;}
.prx-report .meta-row:last-child{border-bottom:none;}
.prx-report .meta-label{color:#64748b;font-weight:500;white-space:nowrap;}
.prx-report .meta-value{color:#2c3e50;font-weight:600;text-align:right;}
.prx-report .value-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin:20px 0;}
.prx-report .value-card{background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;padding:16px 18px;border-top:3px solid #2c3e50;}
.prx-report .value-card.green{border-top-color:#10B981;}
.prx-report .value-card.amber{border-top-color:#f59e0b;}
.prx-report .value-card-title{font-family:'Open Sans',sans-serif;font-size:0.8rem;font-weight:700;color:#2c3e50;margin-bottom:5px;}
.prx-report .value-card-text{font-size:0.78rem;color:#64748b;line-height:1.5;}
.prx-report .metrics-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin:16px 0 0;}
.prx-report .metric-item{display:flex;align-items:flex-start;gap:8px;font-size:0.82rem;color:#475569;line-height:1.4;}
.prx-report .metric-check{color:#10B981;flex-shrink:0;margin-top:2px;}
.prx-report .metric-check svg{width:14px;height:14px;stroke:currentColor;stroke-width:2.5;fill:none;stroke-linecap:round;stroke-linejoin:round;}
.prx-report .proxuma-path{display:inline-flex;align-items:center;gap:6px;background:#eef2f7;border:1px solid #dde3ec;border-radius:6px;padding:6px 14px;font-size:0.78rem;font-family:'JetBrains Mono','Courier New',monospace;color:#2c3e50;margin-top:6px;font-weight:500;}
.prx-report .proxuma-path svg{width:12px;height:12px;stroke:#2c3e50;stroke-width:2;fill:none;opacity:0.6;}
.prx-report .report-frame-outer{background:linear-gradient(180deg,#0f766e 0%,#115e58 50%,#134e4a 100%);border-radius:12px;padding:50px;margin-bottom:0;}
.prx-report .doc{background:white;border-radius:4px;box-shadow:0 2px 20px rgba(0,0,0,0.12),0 0 0 1px rgba(0,0,0,0.04);position:relative;}
.prx-report .doc-header{padding:36px 48px 28px;border-bottom:3px solid #1B365D;display:flex;justify-content:space-between;align-items:flex-start;}
.prx-report .doc-logo{display:flex;align-items:center;margin-bottom:4px;}
.prx-report .doc-type{font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:1.5px;color:#94a3b8;}
.prx-report .doc-header-right{text-align:right;}
.prx-report .doc-header-right .doc-meta-row{font-size:0.74rem;color:#64748b;line-height:1.8;}
.prx-report .doc-header-right .doc-meta-row strong{color:#1B365D;font-weight:600;}
.prx-report .doc-title-block{padding:32px 48px 28px;border-bottom:1px solid #e2e8f0;}
.prx-report .doc-title{font-family:'DM Serif Display',Georgia,serif;font-size:1.7rem;color:#1B365D !important;line-height:1.25;margin-bottom:8px;}
.prx-report .doc-subtitle{font-size:0.88rem;color:#64748b;line-height:1.6;}
.prx-report .doc-body{padding:0 48px;}
.prx-report .doc-section{padding:28px 0;border-bottom:1px solid #f1f5f9;}
.prx-report .doc-section:last-child{border-bottom:none;}
.prx-report .doc-section-head{display:flex;align-items:baseline;gap:14px;margin-bottom:16px;}
.prx-report .doc-section-num{font-family:'Open Sans',sans-serif;font-weight:800;font-size:0.82rem;color:#0f766e;flex-shrink:0;}
.prx-report .doc-section-title{font-family:'Open Sans',sans-serif;font-weight:700;font-size:1rem;color:#1B365D !important;}
.prx-report .doc-section-sub{font-size:0.8rem;color:#64748b;margin-top:2px;}
.prx-report .doc-kpi-row{display:grid;grid-template-columns:repeat(4,1fr);gap:0;border:1px solid #e2e8f0;border-radius:6px;overflow:hidden;}
.prx-report .doc-kpi{padding:18px 20px;border-right:1px solid #e2e8f0;background:#fafbfc !important;}
.prx-report .doc-kpi:last-child{border-right:none;}
.prx-report .doc-kpi-label{font-size:0.66rem;font-weight:700;text-transform:uppercase;letter-spacing:0.6px;color:#94a3b8;margin-bottom:4px;}
.prx-report .doc-kpi-value{font-family:'Open Sans',sans-serif;font-size:1.6rem;font-weight:800;color:#1B365D !important;line-height:1.1;}
.prx-report .doc-kpi-note{font-size:0.72rem;margin-top:3px;}
.prx-report .doc-kpi-note.green{color:#10B981;}
.prx-report .doc-kpi-note.red{color:#ef4444;}
.prx-report .doc-kpi-note.amber{color:#f59e0b;}
.prx-report .doc-kpi-note.muted{color:#94a3b8;}
.prx-report .doc-dax-box{background:#f8fafc;border:1px solid #e2e8f0;border-radius:6px;padding:14px 18px;margin-top:16px;font-size:0.8rem;color:#475569;line-height:1.65;}
.prx-report .doc-dax-box strong{color:#1B365D;}
.prx-report table{width:100%;border-collapse:collapse;font-size:0.85rem;}
.prx-report th{text-align:left;padding:10px 12px;font-size:0.72rem;text-transform:uppercase;letter-spacing:0.4px;color:#64748b;background:#f8fafc !important;border-bottom:2px solid #e2e8f0;font-weight:600;}
.prx-report td{padding:10px 12px;border-bottom:1px solid #f1f5f9;vertical-align:middle;}
.prx-report tbody tr:hover td{background:#f8fafc !important;}
.prx-report .num{font-weight:700;font-family:'Open Sans',sans-serif;font-size:0.9rem;text-align:right;}
.prx-report .num-danger{color:#dc2626 !important;}
.prx-report .num-warn{color:#d97706 !important;}
.prx-report .num-ok{color:#16a34a !important;}
.prx-report .client-name{font-weight:600;color:#1B365D !important;white-space:nowrap;}
.prx-report .pct-badge{display:inline-block;padding:2px 8px;border-radius:4px;font-size:0.72rem;font-weight:600;}
.prx-report .pct-bad{background:#fee2e2 !important;color:#991b1b !important;}
.prx-report .pct-mid{background:#fef3c7 !important;color:#92400e !important;}
.prx-report .pct-ok{background:#d1fae5 !important;color:#065f46 !important;}
.prx-report .pct-none{background:#f1f5f9 !important;color:#64748b !important;}
.prx-report .pill{display:inline-block;padding:3px 10px;border-radius:10px;font-size:0.72rem;font-weight:600;white-space:nowrap;}
.prx-report .pill-blue{background:#dbeafe !important;color:#1e40af !important;}
.prx-report .pill-green{background:#d1fae5 !important;color:#065f46 !important;}
.prx-report .pill-amber{background:#fef3c7 !important;color:#92400e !important;}
.prx-report .pill-red{background:#fee2e2 !important;color:#991b1b !important;}
.prx-report .pill-gray{background:#f1f5f9 !important;color:#475569 !important;}
.prx-report .dax-toggle{background:#f8fafc;border:1px solid #e2e8f0;border-radius:6px;overflow:hidden;margin-top:16px;}
.prx-report .dax-toggle .dax-trigger{display:flex;align-items:center;gap:10px;padding:10px 14px;cursor:pointer;font-size:0.78rem;font-weight:600;color:#0f766e;background:#f1f5f9 !important;user-select:none;}
.prx-report .dax-chevron{width:16px;height:16px;flex-shrink:0;transition:transform 0.25s ease;}
.prx-report .dax-toggle.expanded .dax-chevron{transform:rotate(180deg);}
.prx-report .dax-content{max-height:0;overflow:hidden;transition:max-height 0.3s ease;}
.prx-report .dax-toggle.expanded .dax-content{max-height:600px;}
.prx-report .dax-content pre{padding:14px 16px;background:#0f172a !important;border-radius:0;}
.prx-report .dax-content code{font-family:'JetBrains Mono','Courier New',monospace;font-size:0.72rem;line-height:1.65;color:#e2e8f0 !important;background:transparent !important;}
.prx-report .dax-copy{display:block;margin:8px 16px 12px auto;border:none;border-radius:4px;padding:5px 14px;font-size:0.72rem;font-weight:600;cursor:pointer;font-family:inherit;transition:background 0.15s,color 0.15s;background:#14b8a6;color:white;}
.prx-report .dax-copy:hover{background:#0d9488;color:white;}
.prx-report .doc-finding{display:flex;gap:14px;padding:14px 0;border-bottom:1px solid #f1f5f9;}
.prx-report .doc-finding:last-child{border-bottom:none;}
.prx-report .doc-finding-icon{width:28px;height:28px;border-radius:6px;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:0.72rem;font-weight:800;color:white;margin-top:2px;}
.prx-report .doc-finding-icon.critical{background:#ef4444;}
.prx-report .doc-finding-icon.warning{background:#f59e0b;}
.prx-report .doc-finding-icon.ok{background:#10B981;}
.prx-report .doc-finding-body h4{font-size:1rem;font-weight:700;margin:0 0 4px 0;line-height:1.3;color:#0f172a;}
.prx-report .doc-finding-body p{font-size:0.85rem;color:#475569;line-height:1.7;margin:0;}
.prx-report .narrative{margin:8px 0;}
.prx-report .narrative p{font-size:0.9rem;line-height:1.8;color:#334155;margin-bottom:14px;}
.prx-report .narrative p:last-child{margin-bottom:0;}
.prx-report .narrative strong{color:#1B365D;}
.prx-report .doc-faq{border-top:1px solid #e2e8f0;}
.prx-report .doc-faq .faq-item{border-bottom:1px solid #e2e8f0;cursor:pointer;}
.prx-report .doc-faq .faq-q{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:14px 0;font-size:0.88rem;font-weight:600;color:#1B365D !important;}
.prx-report .doc-faq .faq-chevron{width:16px;height:16px;flex-shrink:0;transition:transform 0.25s ease;}
.prx-report .doc-faq .faq-item.open .faq-chevron{transform:rotate(180deg);}
.prx-report .doc-faq .faq-a{max-height:0;overflow:hidden;transition:max-height 0.3s ease;}
.prx-report .doc-faq .faq-item.open .faq-a{max-height:300px;}
.prx-report .doc-faq .faq-a p{font-size:0.84rem;line-height:1.7;color:#475569;padding-bottom:14px;}
.prx-report .doc-demo{margin:20px 0 0;padding:12px 16px;background:#fefce8 !important;border:1px solid #fde68a;border-radius:6px;font-size:0.8rem;color:#92400e;}
.prx-report .doc-demo strong{color:#78350f;}
.prx-report .doc-footer{margin-top:16px;padding:16px 48px;border-top:1px solid #e2e8f0;display:flex;justify-content:space-between;align-items:center;}
.prx-report .doc-footer span{font-size:0.68rem;color:#94a3b8;}
.prx-report .cta-block{background:linear-gradient(135deg,#E8F4FD 0%,#ffffff 100%);border-radius:16px;padding:40px 44px;text-align:center;margin-top:40px;margin-bottom:60px;}
.prx-report .cta-block h3{font-family:'Open Sans','Inter',sans-serif;font-weight:800;font-size:1.4rem;color:#1B365D !important;margin-bottom:10px;}
.prx-report .cta-block p{font-size:0.95rem;color:#475569;margin-bottom:22px;}
.prx-report .cta-btn{display:inline-flex;align-items:center;gap:8px;background:linear-gradient(135deg,#164487 0%,#1B5299 100%);color:white !important;text-decoration:none !important;border-radius:8px;padding:14px 28px;font-size:0.9rem;font-weight:700;margin:4px 6px;transition:transform 0.3s ease,box-shadow 0.3s ease;box-shadow:0 4px 14px rgba(22,68,135,0.3);position:relative;overflow:hidden;cursor:pointer;}
.prx-report .cta-btn span,.prx-report .cta-btn svg{position:relative;z-index:10;}
.prx-report .cta-btn::before{content:'';position:absolute;top:var(--mouse-y,50%);left:var(--mouse-x,50%);width:0;height:0;background:radial-gradient(circle,#00D9A5 0%,#00B386 40%,#009973 100%);border-radius:50%;transform:translate(-50%,-50%);transition:width 0.7s cubic-bezier(0.25,0.46,0.45,0.94),height 0.7s cubic-bezier(0.25,0.46,0.45,0.94);z-index:1;}
.prx-report .cta-btn:hover::before{width:600px;height:600px;}
.prx-report .cta-btn:hover{transform:translateY(-3px) !important;box-shadow:0 8px 25px rgba(0,217,165,0.4) !important;}
/* Theme isolation — prevents WordPress theme from overriding report styles */
.prx-report .doc-body h3{font-family:'Open Sans',sans-serif;font-size:1.1rem;font-weight:700;color:#0f172a;margin:18px 0 8px;line-height:1.3;}
.prx-report .doc-body h4{font-size:1rem;font-weight:700;margin:0 0 4px 0;line-height:1.3;color:#0f172a;}
.prx-report .doc-body h5{font-size:0.88rem;font-weight:700;margin:0 0 4px 0;line-height:1.3;color:#334155;}
.prx-report .doc-body table{width:100%;border-collapse:collapse;font-size:0.85rem;margin:12px 0;}
.prx-report .doc-body th{text-align:left;padding:10px 12px;font-size:0.72rem;text-transform:uppercase;letter-spacing:0.4px;color:#64748b;background:#f8fafc !important;border-bottom:2px solid #e2e8f0;font-weight:600;}
.prx-report .doc-body td{padding:10px 12px;border-bottom:1px solid #f1f5f9;vertical-align:middle;}
.prx-report .doc-body p{font-size:0.92rem;line-height:1.65;color:#334155;margin:8px 0;}
.prx-report .doc-body strong{color:#2c3e50;}
.prx-report .kpi-sub.green{color:#10B981;}
.prx-report .kpi-sub.amber{color:#f59e0b;}
.prx-report .kpi-sub.red{color:#ef4444;}
.prx-report .kpi-sub.muted{color:#94a3b8;}
/* Responsive */
@media(max-width:900px){.prx-report .report-frame-outer{padding:28px;}.prx-report .doc-kpi-row{grid-template-columns:repeat(2,1fr);}.prx-report .pipeline-track{grid-template-columns:1fr 1fr;}.prx-report .pipeline-arrow{display:none;}.prx-report .overview-grid{grid-template-columns:1fr;}.prx-report .value-grid{grid-template-columns:1fr 1fr;}.prx-report .metrics-grid{grid-template-columns:1fr 1fr;}.prx-report .doc-header{flex-direction:column;gap:12px;}.prx-report .doc-header-right{text-align:left;}}
@media(max-width:600px){.prx-report .report-frame-outer{padding:16px;}.prx-report .doc-kpi-row{grid-template-columns:1fr;}.prx-report .doc-body{padding:0 20px;}.prx-report .doc-header,.prx-report .doc-title-block,.prx-report .doc-demo{padding-left:20px;padding-right:20px;}.prx-report .doc-footer{padding-left:20px;padding-right:20px;}.prx-report .search-hero{padding:28px 20px 24px;border-radius:14px;}.prx-report .pipeline-section{padding:22px 20px;}.prx-report .report-overview{padding:24px 20px;}.prx-report .value-grid{grid-template-columns:1fr;}.prx-report .metrics-grid{grid-template-columns:1fr;}.prx-report .cta-block{padding:28px 24px;}}
@media print{.prx-report .cta-block{display:none;}.prx-report .dax-toggle{display:none;}.prx-report .dax-copy{display:none;}.prx-report .doc-section{break-inside:avoid;}.prx-morph-bar{display:none;}}
</style>

<!-- ============================================================ -->
<!-- MORPH BAR HTML — OPTIONAL: Only include when publishing to WordPress. -->
<!-- Delete this entire <div> if NOT publishing to WordPress. -->
<!-- ============================================================ -->
<div class="prx-morph-bar" id="prx-morph-bar">
    <div class="prx-morph-bg"></div>
    <div class="prx-morph-inner">
        <span class="prx-morph-q">
            <!-- {{MORPH_WORDS}}: Split the business question into individual words, each in a <span class="w"> with incrementing transition-delay (0ms, 35ms, 70ms, ...). Wrap first word in &ldquo; and last in &rdquo; -->
            <span class="w" style="transition-delay:0ms">&ldquo;What&rsquo;s</span>
            <span class="w" style="transition-delay:35ms"> our</span>
            <span class="w" style="transition-delay:70ms"> example</span>
            <span class="w" style="transition-delay:105ms"> question?&rdquo;</span>
        </span>
        <div class="prx-morph-extras">
            <!-- {{MORPH_PILLS}}: 1-2 short keyword pills relevant to the data source -->
            <span class="prx-morph-pill">Power BI</span>
            <a href="/powerbi/insights" class="prx-morph-back">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 5l-7 7 7 7"/></svg>
                All reports
            </a>
        </div>
    </div>
</div>

<!-- ============================================================ -->
<!-- REPORT CONTENT STARTS HERE -->
<!-- ============================================================ -->
<div class="prx-report">

<!-- SERIES NAV -->
<nav class="series-nav">
    <a href="/powerbi">Power BI</a>
    <span class="sep">&rsaquo;</span>
    <a href="/powerbi/insights">AI-Powered Reports</a>
    <span class="sep">&rsaquo;</span>
    <!-- {{TOPIC_NAME}}: Short topic name for breadcrumb, e.g. "SLA Performance", "Revenue Analysis" -->
    <span class="current">{{TOPIC_NAME}}</span>
</nav>

<!-- SEARCH HERO -->
<div class="search-hero">
    <div class="search-hero-deco"></div>
    <div class="search-hero-badge">
        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 17l-6.2 4.3 2.4-7.4L2 9.4h7.6z"/></svg>
        AI-Powered Report
    </div>
    <div class="search-hero-eyebrow">You searched for:</div>
    <div class="search-bar">
        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <!-- {{SEARCH_QUESTION}}: The original business question as a natural-language question -->
        <div class="search-bar-text">{{SEARCH_QUESTION}}<span class="search-bar-cursor"></span></div>
    </div>
    <!-- {{H1_TITLE}}: Report title including the tool name (e.g. "Autotask SLA Resolution Rate by Priority: Are You Meeting Your Targets?") -->
    <h1 id="prx-hero-h1">{{H1_TITLE}}</h1>
    <!-- {{SUBTITLE}}: 2-3 sentences. What the native tool does NOT show + what this report does + "Generated by AI in under fifteen minutes." -->
    <p class="search-hero-sub">{{SUBTITLE}}</p>
    <div class="search-hero-sources">
        <span class="search-hero-sources-label">Built from:</span>
        <!-- {{SOURCE_BADGES}}: 3-4 source badges. Use the pattern below for each data source. Set style="color:..." per badge. Common colors: #1E40AF (PSA/blue), #D97706 (amber), #2c3e50 (dark), #6b21a8 (purple/AI) -->
        <span class="source-badge" style="color:#1E40AF;">
            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 3v18"/></svg>
            Autotask PSA
        </span>
        <span class="source-badge" style="color:#2c3e50;">
            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M18 20V10M12 20V4M6 20v-6"/></svg>
            Proxuma Power BI
        </span>
        <span class="source-badge" style="color:#6b21a8;">
            <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 17l-6.2 4.3 2.4-7.4L2 9.4h7.6z"/></svg>
            AI via MCP
        </span>
    </div>
</div>

<!-- PIPELINE -->
<div class="pipeline-section">
    <div class="pipeline-label">How this report was made</div>
    <div class="pipeline-track">
        <div class="pipeline-step">
            <div class="pipeline-step-num">1</div>
            <!-- {{PIPELINE_SOURCE_ICON}}: SVG icon for the primary data source. Use a relevant icon from the set below:
                 Database: <svg viewBox="0 0 24 24"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg>
                 Tickets: <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                 Chart: <svg viewBox="0 0 24 24"><path d="M18 20V10M12 20V4M6 20v-6"/></svg>
                 Smile: <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg>
                 Clock: <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            -->
            <div class="pipeline-step-icon"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg></div>
            <!-- {{PIPELINE_SOURCE}}: Name of primary data source, e.g. "Autotask PSA", "SmileBack", "Datto RMM" -->
            <div class="pipeline-step-title">{{PIPELINE_SOURCE}}</div>
            <!-- {{PIPELINE_SOURCE_DESC}}: What data this source provides, e.g. "Tickets, SLAs, time entries, billing" -->
            <div class="pipeline-step-desc">{{PIPELINE_SOURCE_DESC}}</div>
        </div>
        <div class="pipeline-arrow"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg></div>
        <div class="pipeline-step">
            <div class="pipeline-step-num">2</div>
            <div class="pipeline-step-icon"><svg viewBox="0 0 24 24"><path d="M18 20V10M12 20V4M6 20v-6"/></svg></div>
            <div class="pipeline-step-title">Proxuma Power BI</div>
            <div class="pipeline-step-desc">Pre-built MSP semantic model, 50+ measures</div>
        </div>
        <div class="pipeline-arrow"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg></div>
        <div class="pipeline-step">
            <div class="pipeline-step-num">3</div>
            <div class="pipeline-step-icon"><svg viewBox="0 0 24 24"><path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 17l-6.2 4.3 2.4-7.4L2 9.4h7.6z"/></svg></div>
            <div class="pipeline-step-title">AI via MCP</div>
            <div class="pipeline-step-desc">Claude or ChatGPT writes DAX queries, executes them, formats output</div>
        </div>
        <div class="pipeline-arrow"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg></div>
        <div class="pipeline-step highlight">
            <div class="pipeline-step-num">4</div>
            <div class="pipeline-step-icon"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><polyline points="9 15 11 17 15 13"/></svg></div>
            <div class="pipeline-step-title">This Report</div>
            <div class="pipeline-step-desc">KPIs, breakdowns, trends, recommendations</div>
            <div class="pipeline-badge">
                <svg viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5" width="9" height="9" stroke-linecap="round" stroke-linejoin="round" fill="none"><polyline points="20 6 9 17 4 12"/></svg>
                Ready in &lt; 15 min
            </div>
        </div>
    </div>
    <div class="pipeline-footer">
        <!-- {{PIPELINE_FOOTER}}: "Want to run this report against your own <strong>[Source]</strong> data?" -->
        <div class="pipeline-footer-text">{{PIPELINE_FOOTER}}</div>
        <a href="/powerbi" class="pipeline-cta-link"><span style="position:relative;z-index:10;">Get Proxuma Power BI</span> <svg style="position:relative;z-index:10;" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg></a>
    </div>
</div>

<!-- REPORT OVERVIEW -->
<div class="report-overview">
    <div class="overview-grid">
        <div>
            <!-- {{OVERVIEW_H2}}: Descriptive heading for what this report covers -->
            <h2 class="overview-h2">{{OVERVIEW_H2}}</h2>
            <div class="overview-body">
                <!-- {{OVERVIEW_BODY}}: 3-4 paragraphs explaining:
                     1) What the native tool does NOT show
                     2) What this report does differently
                     3) Who should use it and when
                     Use <p> tags and <strong> for emphasis -->
                {{OVERVIEW_BODY}}
            </div>
            <div class="value-grid">
                <!-- VALUE CARD 1: green border-top -->
                <div class="value-card green">
                    <!-- {{VC1_TITLE}}: e.g. "Time saved" -->
                    <div class="value-card-title">{{VC1_TITLE}}</div>
                    <!-- {{VC1_TEXT}}: 1-2 sentences on the value, with specific numbers -->
                    <div class="value-card-text">{{VC1_TEXT}}</div>
                </div>
                <!-- VALUE CARD 2: default (navy) border-top -->
                <div class="value-card">
                    <div class="value-card-title">{{VC2_TITLE}}</div>
                    <div class="value-card-text">{{VC2_TEXT}}</div>
                </div>
                <!-- VALUE CARD 3: amber border-top -->
                <div class="value-card amber">
                    <div class="value-card-title">{{VC3_TITLE}}</div>
                    <div class="value-card-text">{{VC3_TEXT}}</div>
                </div>
            </div>
        </div>
        <div>
            <div class="overview-meta">
                <!-- {{META_CATEGORY}}: e.g. "SLA Reports", "Client Reports", "Financial Reports" -->
                <div class="meta-row"><span class="meta-label">Report category</span><span class="meta-value">{{META_CATEGORY}}</span></div>
                <!-- {{META_SOURCE}}: e.g. "Autotask PSA", "SmileBack &middot; Autotask PSA" -->
                <div class="meta-row"><span class="meta-label">Data source</span><span class="meta-value">{{META_SOURCE}}</span></div>
                <div class="meta-row"><span class="meta-label">PSA link</span><span class="meta-value">Autotask</span></div>
                <div class="meta-row"><span class="meta-label">Refresh</span><span class="meta-value">Real-time via Power BI</span></div>
                <div class="meta-row"><span class="meta-label">Generation time</span><span class="meta-value">Under 15 minutes</span></div>
                <div class="meta-row"><span class="meta-label">AI required</span><span class="meta-value">Claude, ChatGPT or Copilot</span></div>
                <!-- {{META_AUDIENCE}}: e.g. "Service Desk Lead, MSP Owner" -->
                <div class="meta-row"><span class="meta-label">Audience</span><span class="meta-value">{{META_AUDIENCE}}</span></div>
            </div>
            <div style="margin-top:16px;">
                <div style="font-size:0.75rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:#64748b;margin-bottom:8px;">Where to find this in Proxuma</div>
                <div class="proxuma-path">
                    <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                    <!-- {{PROXUMA_PATH}}: e.g. "Power BI &rsaquo; SLA &rsaquo; Resolution Rate" -->
                    {{PROXUMA_PATH}}
                </div>
                <div style="margin-top:14px;">
                    <a href="/powerbi" class="pipeline-cta-link">
                        <span style="position:relative;z-index:10;">Get this report for your MSP</span>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" width="13" height="13"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
                    </a>
                </div>
            </div>
        </div>
    </div>
    <div style="margin-top:28px;padding-top:24px;border-top:1px solid #f1f5f9;">
        <div style="font-size:0.75rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:#64748b;margin-bottom:12px;">What you can measure in this report</div>
        <div class="metrics-grid">
            <!-- {{METRICS_CHECKLIST}}: 9-12 metric items. Use this exact pattern for each:
                 <div class="metric-item"><span class="metric-check"><svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Description of the metric</div>
            -->
            {{METRICS_CHECKLIST}}
        </div>
    </div>
</div>

<!-- ============================================================ -->
<!-- TEAL FRAME + PRINTED DOCUMENT -->
<!-- ============================================================ -->
<div class="report-frame-outer" id="prx-frame-top">
<div class="doc">

  <!-- DOC HEADER — Proxuma letterhead -->
  <div class="doc-header">
    <div>
      <!-- FROZEN: Proxuma SVG logo — DO NOT MODIFY -->
      <div class="doc-logo">
        <svg id="Layer_1" style="width:140px;height:auto;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960.97 282.29"><defs><style>.cls-1{fill:#002c60;}.cls-2{fill:#00b7ff;}</style></defs><path class="cls-2" d="m216.45,16.34l-5.35-16.34-13.49,10.69c-23.28,18.52-40.13,43.4-48.71,72-3.48,11.59-5.48,23.41-6.02,35.26,7.41,1,14.52,2.96,21.2,5.75.76-7.97,2.31-15.93,4.66-23.74,5.27-17.58,14.26-33.48,26.4-46.79,2.78,17.79,1.56,36.02-3.72,53.59-2.73,9.1-6.47,17.76-11.13,25.83,5.82,4.07,11.11,8.84,15.75,14.19,9.46-13.07,16.71-27.72,21.44-43.5,8.58-28.6,8.23-58.66-1.02-86.94Z"/><path class="cls-2" d="m71.15,106.76c2.74,9.1,6.47,17.76,11.13,25.83-5.82,4.06-11.11,8.83-15.75,14.18-9.46-13.07-16.7-27.72-21.43-43.49-1.54-5.12-2.79-10.27-3.76-15.45,9.78.99,18.48-.04,25.51-1.7.82,6.93,2.26,13.82,4.3,20.62Z"/><path class="cls-2" d="m113.67,82.71c-5.01-16.71-12.85-32.15-23.12-45.79h0s-90.54,0-90.54,0c0,0,19.8,54.54,85.45,42.19h0c3.4,6.62,6.22,13.58,8.39,20.85,2.35,7.83,3.89,15.77,4.65,23.74,6.68-2.79,13.8-4.75,21.22-5.75-.54-11.84-2.56-23.67-6.03-35.25Z"/><path class="cls-1" d="m131.27,123.45c-43.78,0-79.4,35.62-79.4,79.4s35.62,79.44,79.4,79.44,79.44-35.64,79.44-79.44-35.64-79.4-79.44-79.4Zm.01,135.52c-30.93,0-56.1-25.17-56.1-56.12s25.17-56.09,56.1-56.09,56.11,25.16,56.11,56.09-25.17,56.12-56.11,56.12Z"/><circle class="cls-1" cx="131.29" cy="161.36" r="6.19"/><circle class="cls-1" cx="131.29" cy="244.38" r="6.19"/><path class="cls-1" d="m172.8,209.06c-3.42,0-6.19-2.77-6.19-6.19s2.77-6.19,6.19-6.19c3.42,0,6.19,2.77,6.19,6.19s-2.77,6.19-6.19,6.19Z"/><path class="cls-1" d="m89.78,209.06c-3.42,0-6.19-2.77-6.19-6.19,0-3.42,2.77-6.19,6.19-6.19s6.19,2.77,6.19,6.19c0,3.42-2.77,6.19-6.19,6.19Z"/><polygon class="cls-2" points="156.77 169.47 131.29 194.95 118.1 181.76 110.18 189.69 131.29 210.79 164.7 177.39 156.77 169.47"/><path class="cls-1" d="m319.51,165.06c6.21,3.43,11.07,8.28,14.61,14.53,3.53,6.26,5.3,13.47,5.3,21.65s-1.77,15.42-5.3,21.72c-3.53,6.31-8.4,11.18-14.61,14.61-6.21,3.43-13.25,5.15-21.12,5.15-10.9,0-19.53-3.63-25.88-10.9v39.21h-18.92v-110.2h18.01v10.6c3.13-3.83,6.99-6.71,11.58-8.63,4.59-1.92,9.66-2.88,15.21-2.88,7.87,0,14.91,1.72,21.12,5.15Zm-6.05,54.49c4.49-4.64,6.74-10.75,6.74-18.32s-2.25-13.67-6.74-18.32c-4.49-4.64-10.22-6.96-17.18-6.96-4.54,0-8.63,1.04-12.26,3.1-3.63,2.07-6.51,5.02-8.63,8.86-2.12,3.84-3.18,8.28-3.18,13.32s1.06,9.49,3.18,13.32c2.12,3.84,5,6.79,8.63,8.86,3.63,2.07,7.72,3.1,12.26,3.1,6.96,0,12.69-2.32,17.18-6.96Z"/><path class="cls-1" d="m401.17,159.91v18.01c-1.62-.3-3.08-.45-4.39-.45-7.37,0-13.12,2.15-17.26,6.43-4.14,4.29-6.21,10.47-6.21,18.54v39.21h-18.92v-80.83h18.01v11.81c5.45-8.48,15.04-12.72,28.76-12.72Z"/><path class="cls-1" d="m427.66,237.41c-6.56-3.53-11.68-8.45-15.36-14.76-3.68-6.31-5.52-13.45-5.52-21.42s1.84-15.09,5.52-21.34c3.68-6.26,8.8-11.15,15.36-14.68,6.56-3.53,13.93-5.3,22.1-5.3s15.69,1.77,22.25,5.3c6.56,3.53,11.68,8.43,15.36,14.68,3.68,6.26,5.52,13.37,5.52,21.34s-1.84,15.11-5.52,21.42c-3.68,6.31-8.81,11.23-15.36,14.76-6.56,3.53-13.98,5.3-22.25,5.3s-15.54-1.76-22.1-5.3Zm39.36-17.86c4.54-4.64,6.81-10.75,6.81-18.32s-2.27-13.67-6.81-18.32c-4.54-4.64-10.29-6.96-17.26-6.96s-12.69,2.32-17.18,6.96c-4.49,4.64-6.74,10.75-6.74,18.32s2.24,13.68,6.74,18.32c4.49,4.64,10.22,6.96,17.18,6.96s12.71-2.32,17.26-6.96Z"/><path class="cls-1" d="m556.78,241.65l-20.74-28-20.89,28h-20.89l31.49-41.02-30.12-39.81h21.04l19.83,26.49,19.83-26.49h20.44l-30.27,39.51,31.64,41.32h-21.34Z"/><path class="cls-1" d="m665.77,160.82v80.83h-18.01v-10.29c-3.03,3.63-6.81,6.43-11.35,8.4-4.54,1.97-9.44,2.95-14.68,2.95-10.8,0-19.3-3-25.51-9.01-6.21-6-9.31-14.91-9.31-26.72v-46.17h18.92v43.6c0,7.27,1.64,12.69,4.92,16.27,3.28,3.58,7.95,5.37,14,5.37,6.76,0,12.13-2.09,16.12-6.28,3.99-4.19,5.98-10.22,5.98-18.09v-40.87h18.92Z"/><path class="cls-1" d="m812.9,168.77c5.95,5.9,8.93,14.76,8.93,26.57v46.32h-18.92v-43.9c0-7.06-1.57-12.39-4.69-15.97-3.13-3.58-7.62-5.37-13.47-5.37-6.36,0-11.45,2.1-15.29,6.28-3.84,4.19-5.75,10.17-5.75,17.94v41.02h-18.92v-43.9c0-7.06-1.57-12.39-4.69-15.97-3.13-3.58-7.62-5.37-13.47-5.37-6.46,0-11.58,2.07-15.36,6.21-3.78,4.14-5.68,10.14-5.68,18.01v41.02h-18.92v-80.83h18.01v10.29c3.03-3.63,6.81-6.41,11.35-8.33,4.54-1.92,9.59-2.88,15.14-2.88,6.05,0,11.43,1.14,16.12,3.41,4.69,2.27,8.4,5.63,11.13,10.07,3.33-4.24,7.62-7.54,12.87-9.92,5.25-2.37,11.05-3.56,17.41-3.56,10.19,0,18.26,2.95,24.22,8.86Z"/><path class="cls-1" d="m920.98,160.82v80.83h-18.01v-10.44c-3.13,3.84-6.99,6.71-11.58,8.63-4.59,1.92-9.66,2.88-15.21,2.88-7.87,0-14.91-1.71-21.12-5.15-6.21-3.43-11.05-8.27-14.53-14.53-3.48-6.26-5.22-13.52-5.22-21.8s1.74-15.52,5.22-21.72c3.48-6.21,8.33-11.02,14.53-14.46,6.21-3.43,13.25-5.15,21.12-5.15,5.25,0,10.07.91,14.46,2.72,4.39,1.82,8.2,4.49,11.43,8.02v-9.84h18.92Zm-25.43,58.73c4.54-4.64,6.81-10.75,6.81-18.32s-2.27-13.67-6.81-18.32c-4.54-4.64-10.29-6.96-17.26-6.96s-12.69,2.32-17.18,6.96c-4.49,4.64-6.74,10.75-6.74,18.32s2.24,13.68,6.74,18.32c4.49,4.64,10.22,6.96,17.18,6.96s12.72-2.32,17.26-6.96Z"/><circle class="cls-2" cx="950.84" cy="232.58" r="10.13"/></svg>
      </div>
      <div class="doc-type">AI-Generated Power BI Report</div>
    </div>
    <div class="doc-header-right">
      <!-- {{DOC_DATE}}: e.g. "February 2026" -->
      <div class="doc-meta-row"><strong>Date:</strong> {{DOC_DATE}}</div>
      <!-- {{DOC_SOURCE}}: e.g. "Autotask PSA &middot; Power BI" -->
      <div class="doc-meta-row"><strong>Source:</strong> {{DOC_SOURCE}}</div>
      <!-- {{DOC_SCOPE}}: e.g. "All clients &middot; Last 12 months" -->
      <div class="doc-meta-row"><strong>Scope:</strong> {{DOC_SCOPE}}</div>
    </div>
  </div>

  <!-- DOC TITLE -->
  <div class="doc-title-block">
    <!-- {{DOC_TITLE}}: Main document title in DM Serif Display font. Can include <br> for line break -->
    <div class="doc-title">{{DOC_TITLE}}</div>
    <!-- {{DOC_SUBTITLE}}: 1-2 sentence subtitle. End with "Generated by AI via Proxuma Power BI MCP server." -->
    <p class="doc-subtitle">{{DOC_SUBTITLE}}</p>
  </div>

  <!-- DEMO NOTICE — Include this line exactly as shown -->
  <div class="doc-demo"><strong>Demo Report:</strong> This report uses synthetic data to demonstrate AI-generated insights from Proxuma Power BI. The structure, DAX queries, and analysis reflect real MSP data patterns.</div>

  <div class="doc-body">

    <!-- =========================================================== -->
    <!-- SECTION 1.0: Summary Metrics — Always 4 KPI cards -->
    <!-- =========================================================== -->
    <div class="doc-section">
      <div class="doc-section-head">
        <span class="doc-section-num">1.0</span>
        <span class="doc-section-title">Summary Metrics</span>
      </div>
      <div class="doc-kpi-row">
        <!-- KPI 1 -->
        <div class="doc-kpi">
          <!-- {{KPI1_LABEL}}: ALL-CAPS short label, e.g. "PORTFOLIO CSAT", "TOTAL TICKETS" -->
          <div class="doc-kpi-label">{{KPI1_LABEL}}</div>
          <!-- {{KPI1_VALUE}}: The number, e.g. "4.28", "1,847", "94.2%" -->
          <div class="doc-kpi-value">{{KPI1_VALUE}}</div>
          <!-- {{KPI1_NOTE}}: Context line. Add class green/red/amber/muted -->
          <div class="doc-kpi-note {{KPI1_COLOR}}">{{KPI1_NOTE}}</div>
        </div>
        <!-- KPI 2 -->
        <div class="doc-kpi">
          <div class="doc-kpi-label">{{KPI2_LABEL}}</div>
          <div class="doc-kpi-value">{{KPI2_VALUE}}</div>
          <div class="doc-kpi-note {{KPI2_COLOR}}">{{KPI2_NOTE}}</div>
        </div>
        <!-- KPI 3 -->
        <div class="doc-kpi">
          <div class="doc-kpi-label">{{KPI3_LABEL}}</div>
          <div class="doc-kpi-value">{{KPI3_VALUE}}</div>
          <div class="doc-kpi-note {{KPI3_COLOR}}">{{KPI3_NOTE}}</div>
        </div>
        <!-- KPI 4 -->
        <div class="doc-kpi">
          <div class="doc-kpi-label">{{KPI4_LABEL}}</div>
          <div class="doc-kpi-value">{{KPI4_VALUE}}</div>
          <div class="doc-kpi-note {{KPI4_COLOR}}">{{KPI4_NOTE}}</div>
        </div>
      </div>
      <!-- DAX TOGGLE for Section 1 -->
      <div class="dax-toggle" onclick="this.classList.toggle('expanded')">
        <div class="dax-trigger">
          <svg class="dax-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 9l-7 7-7-7"/></svg>
          <span>View DAX Query &mdash; Summary Metrics</span>
        </div>
        <div class="dax-content">
          <!-- {{DAX1_CODE}}: The exact DAX query you executed for summary KPIs -->
          <pre><code>{{DAX1_CODE}}</code></pre>
          <button class="dax-copy" onclick="event.stopPropagation();prxCopyDAX(this)">Copy Query</button>
        </div>
      </div>
      <!-- DAX explanation box — include in Section 1 only -->
      <div class="doc-dax-box" style="margin-top:12px;">
        <strong>What are these DAX queries?</strong> DAX (Data Analysis Expressions) is the formula language used by Power BI to query data. Each &ldquo;View DAX Query&rdquo; section shows the exact query the AI wrote and executed. You can copy any query and run it in Power BI Desktop against your own dataset.
      </div>
    </div>

    <!-- =========================================================== -->
    <!-- SECTION 2.0: Primary Data Table -->
    <!-- Write one <tr> per row from your DAX query. Do NOT summarize. -->
    <!-- =========================================================== -->
    <div class="doc-section">
      <div class="doc-section-head">
        <span class="doc-section-num">2.0</span>
        <!-- {{S2_TITLE}}: Section title, e.g. "SLA Resolution Rate by Priority — Ranked" -->
        <span class="doc-section-title">{{S2_TITLE}}</span>
      </div>
      <!-- {{S2_SUBTITLE}}: Optional one-line description -->
      <p class="doc-section-sub">{{S2_SUBTITLE}}</p>
      <div style="overflow-x:auto;margin-top:14px;">
        <table>
          <thead>
            <!-- {{S2_HEADERS}}: Table column headers. Use <th> for each. Add style="text-align:right" for numeric columns -->
            <tr>{{S2_HEADERS}}</tr>
          </thead>
          <tbody>
            <!-- {{S2_ROWS}}: One <tr> per row from DAX results. Example row:
                 <tr><td>1</td><td class="client-name">Client A</td><td class="num num-ok">94.2%</td><td><span class="pill pill-green">On Track</span></td></tr>
                 Write EVERY row. Do NOT skip any. -->
            {{S2_ROWS}}
          </tbody>
        </table>
      </div>
      <div class="dax-toggle" onclick="this.classList.toggle('expanded')">
        <div class="dax-trigger">
          <svg class="dax-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 9l-7 7-7-7"/></svg>
          <!-- {{S2_DAX_LABEL}}: e.g. "View DAX Query — SLA by Priority" -->
          <span>{{S2_DAX_LABEL}}</span>
        </div>
        <div class="dax-content">
          <pre><code>{{S2_DAX_CODE}}</code></pre>
          <button class="dax-copy" onclick="event.stopPropagation();prxCopyDAX(this)">Copy Query</button>
        </div>
      </div>
    </div>

    <!-- =========================================================== -->
    <!-- SECTION 3.0: Detail / Deep-dive Table -->
    <!-- Same structure as Section 2. Different data. Write every row. -->
    <!-- =========================================================== -->
    <div class="doc-section">
      <div class="doc-section-head">
        <span class="doc-section-num">3.0</span>
        <span class="doc-section-title">{{S3_TITLE}}</span>
      </div>
      <p class="doc-section-sub">{{S3_SUBTITLE}}</p>
      <div style="overflow-x:auto;margin-top:14px;">
        <table>
          <thead>
            <tr>{{S3_HEADERS}}</tr>
          </thead>
          <tbody>
            {{S3_ROWS}}
          </tbody>
        </table>
      </div>
      <div class="dax-toggle" onclick="this.classList.toggle('expanded')">
        <div class="dax-trigger">
          <svg class="dax-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 9l-7 7-7-7"/></svg>
          <span>{{S3_DAX_LABEL}}</span>
        </div>
        <div class="dax-content">
          <pre><code>{{S3_DAX_CODE}}</code></pre>
          <button class="dax-copy" onclick="event.stopPropagation();prxCopyDAX(this)">Copy Query</button>
        </div>
      </div>
    </div>

    <!-- =========================================================== -->
    <!-- SECTION 4.0: Volume / Distribution Table -->
    <!-- Same structure. Write every row. -->
    <!-- =========================================================== -->
    <div class="doc-section">
      <div class="doc-section-head">
        <span class="doc-section-num">4.0</span>
        <span class="doc-section-title">{{S4_TITLE}}</span>
      </div>
      <p class="doc-section-sub">{{S4_SUBTITLE}}</p>
      <div style="overflow-x:auto;margin-top:14px;">
        <table>
          <thead>
            <tr>{{S4_HEADERS}}</tr>
          </thead>
          <tbody>
            {{S4_ROWS}}
          </tbody>
        </table>
      </div>
      <div class="dax-toggle" onclick="this.classList.toggle('expanded')">
        <div class="dax-trigger">
          <svg class="dax-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 9l-7 7-7-7"/></svg>
          <span>{{S4_DAX_LABEL}}</span>
        </div>
        <div class="dax-content">
          <pre><code>{{S4_DAX_CODE}}</code></pre>
          <button class="dax-copy" onclick="event.stopPropagation();prxCopyDAX(this)">Copy Query</button>
        </div>
      </div>
    </div>

    <!-- =========================================================== -->
    <!-- SECTION 5.0: Trends Over Time -->
    <!-- Same structure. Write every row. -->
    <!-- =========================================================== -->
    <div class="doc-section">
      <div class="doc-section-head">
        <span class="doc-section-num">5.0</span>
        <span class="doc-section-title">{{S5_TITLE}}</span>
      </div>
      <p class="doc-section-sub">{{S5_SUBTITLE}}</p>
      <div style="overflow-x:auto;margin-top:14px;">
        <table>
          <thead>
            <tr>{{S5_HEADERS}}</tr>
          </thead>
          <tbody>
            {{S5_ROWS}}
          </tbody>
        </table>
      </div>
      <div class="dax-toggle" onclick="this.classList.toggle('expanded')">
        <div class="dax-trigger">
          <svg class="dax-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 9l-7 7-7-7"/></svg>
          <span>{{S5_DAX_LABEL}}</span>
        </div>
        <div class="dax-content">
          <pre><code>{{S5_DAX_CODE}}</code></pre>
          <button class="dax-copy" onclick="event.stopPropagation();prxCopyDAX(this)">Copy Query</button>
        </div>
      </div>
    </div>

    <!-- =========================================================== -->
    <!-- SECTION 6.0: Analysis (narrative) -->
    <!-- 3-5 paragraphs. Bold key numbers. Be specific and data-backed. -->
    <!-- =========================================================== -->
    <div class="doc-section">
      <div class="doc-section-head">
        <span class="doc-section-num">6.0</span>
        <span class="doc-section-title">Analysis</span>
      </div>
      <div class="narrative">
        <!-- {{ANALYSIS}}: 3-5 <p> tags with data-backed analysis.
             Use <strong> for key numbers. Reference specific rows/clients from the data.
             Example:
             <p>The portfolio average of <strong>94.2%</strong> masks a wide range...</p>
             <p><strong>Client T has the most urgent problem.</strong> Their rate of...</p>
        -->
        {{ANALYSIS}}
      </div>
    </div>

    <!-- =========================================================== -->
    <!-- SECTION 7.0: Action Items -->
    <!-- 3-5 numbered findings with priority icons -->
    <!-- =========================================================== -->
    <div class="doc-section">
      <div class="doc-section-head">
        <span class="doc-section-num">7.0</span>
        <span class="doc-section-title">What Should You Do With This Data?</span>
      </div>
      <p class="doc-section-sub">Priorities based on the findings above</p>
      <!-- {{FINDINGS}}: 3-5 findings using this exact pattern:
           <div class="doc-finding">
             <div class="doc-finding-icon critical">1</div>
             <div class="doc-finding-body">
               <h4>Action headline — specific and imperative</h4>
               <p>2-3 sentences explaining why this matters, referencing specific numbers from the data. Include a concrete next step.</p>
             </div>
           </div>
           Use "critical" for urgent (red), "warning" for important (amber), "ok" for positive (green).
           Number them sequentially: 1, 2, 3, 4, 5.
      -->
      {{FINDINGS}}
    </div>

    <!-- =========================================================== -->
    <!-- SECTION 8.0: FAQ -->
    <!-- 4-6 collapsible Q&A items -->
    <!-- =========================================================== -->
    <div class="doc-section">
      <div class="doc-section-head">
        <span class="doc-section-num">8.0</span>
        <span class="doc-section-title">Frequently Asked Questions</span>
      </div>
      <div class="doc-faq">
        <!-- {{FAQ_ITEMS}}: 4-6 FAQ items using this exact pattern:
             <div class="faq-item" onclick="this.classList.toggle('open')">
               <div class="faq-q"><span>The question text?</span><svg class="faq-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 9l-7 7-7-7"/></svg></div>
               <div class="faq-a"><p>The answer text. 2-4 sentences. Reference data sources and methods.</p></div>
             </div>
             Always include these two FAQ items at the end:
             - "Can I run this report filtered to a specific time period?" (answer: yes, add date filter to DAX)
             - "Can I run this report against my own data?" (answer: yes, connect Proxuma Power BI + AI via MCP, under fifteen minutes)
        -->
        {{FAQ_ITEMS}}
      </div>
    </div>

  </div><!-- /.doc-body -->

  <!-- DOC FOOTER -->
  <div class="doc-footer">
    <span>Proxuma Power BI &middot; AI-Generated Report &middot; proxuma.io/powerbi</span>
    <span>Generated in &lt; 15 minutes via MCP</span>
  </div>

</div><!-- /.doc -->
</div><!-- /.report-frame-outer -->

<!-- CTA BLOCK -->
<div class="cta-block">
    <!-- {{CTA_TITLE}}: e.g. "Generate this report from your own Autotask data" -->
    <h3>{{CTA_TITLE}}</h3>
    <!-- {{CTA_TEXT}}: 1 sentence about connecting Proxuma Power BI + AI -->
    <p>{{CTA_TEXT}}</p>
    <a href="/powerbi/insights" class="cta-btn" style="margin-right:8px;"><span>See more reports</span><svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="position:relative;z-index:10;"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"/></svg></a>
    <a href="/powerbi" class="cta-btn"><span>Get Proxuma Power BI</span><svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="position:relative;z-index:10;"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"/></svg></a>
</div>

</div><!-- /.prx-report -->

<!-- JSON-LD FAQ SCHEMA -->
<!-- {{JSON_LD}}: Build this from your FAQ items. Use the exact structure below. -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {{JSON_LD_QUESTIONS}}
  ]
}
</script>
<!-- Each JSON-LD question uses this format:
{
  "@type": "Question",
  "name": "The question text?",
  "acceptedAnswer": {
    "@type": "Answer",
    "text": "The answer text (plain text, no HTML)."
  }
}
Separate multiple questions with commas. -->

<!-- ============================================================ -->
<!-- FROZEN JS — DO NOT MODIFY THIS BLOCK -->
<!-- ============================================================ -->
<script>
function prxCopyDAX(btn){var c=btn.parentElement.querySelector('code');if(c){navigator.clipboard.writeText(c.textContent).then(function(){btn.textContent='Copied!';setTimeout(function(){btn.textContent='Copy Query'},1500)})}}
document.querySelectorAll('.prx-report .cta-btn,.prx-report .pipeline-cta-link').forEach(function(btn){btn.addEventListener('mousemove',function(e){var r=btn.getBoundingClientRect();btn.style.setProperty('--mouse-x',(e.clientX-r.left)+'px');btn.style.setProperty('--mouse-y',(e.clientY-r.top)+'px')})});
(function(){var morphBar=document.getElementById('prx-morph-bar');var siteHeader=document.querySelector('.c-header,.c-site__header');var frameTop=document.getElementById('prx-frame-top');if(!morphBar||!frameTop)return;function positionMorph(){if(siteHeader){morphBar.style.top=siteHeader.offsetHeight+'px'}}positionMorph();window.addEventListener('resize',positionMorph);var ticking=false;function onScroll(){if(!ticking){requestAnimationFrame(function(){var rect=frameTop.getBoundingClientRect();var hh=siteHeader?siteHeader.offsetHeight:0;if(rect.top<=hh){morphBar.classList.add('visible','active')}else{morphBar.classList.remove('visible','active')}ticking=false});ticking=true}}window.addEventListener('scroll',onScroll,{passive:true});onScroll()})();
</script>
```

**Save the output file to the current workspace directory.**
