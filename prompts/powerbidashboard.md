# Live Dashboard Generator (Copilot Studio)

Generate a fully interactive HTML dashboard from Power BI data. **Topic:** $ARGUMENTS

If no topic given, ask: "What dashboard would you like me to build? (e.g., SLA performance, ticket operations, resource utilization, client profitability)"

---

## CRITICAL RULES — READ THESE FIRST

1. **OUTPUT THE COMPLETE HTML** — every line, no summarizing, no truncation
2. **Use `search_schema` to discover measures** — NEVER hardcode measure names
3. **NEVER use `get_schema`** — it returns >10MB and will crash
4. **Write ALL data, ALL config, ALL HTML** — minimum 200 lines of output
5. **Do not add `<!DOCTYPE>`, `<html>`, or `<body>` wrappers** — output starts with `<link>` and ends with `</script>`

---

## Step 1 — Discover the Data Model

Run 2-4 searches to find relevant measures and understand the data:

```
search_schema(search_term="keyword_related_to_topic")
search_schema(search_term="second_keyword")
list_measures()
```

From the results, identify:
- **Measures** you can use in DAX (e.g., `[Revenue - Total]`, `[Tickets - Count - Created]`)
- **Tables** that contain the dimension columns (companies, dates, resources, etc.)
- **Column names** for GROUP BY operations (e.g., `BI_Autotask_Companies[company_name]`)

Then pull a small sample to confirm table/column names:
```
execute_dax(dax_query="EVALUATE TOPN(3, 'TableName')")
```

---

## Step 2 — Design the Dashboard

Plan 8 KPI cards (2 rows of 4), 4-5 gauges, 4 charts (2×2), and a company breakdown table.

**KPI design rules:**
- Row 1: high-level financial or primary metrics
- Row 2: operational or secondary metrics
- Each KPI needs: label, color, metric definition, format, optional sub-metric

**Chart design rules:**
- Chart 1: main trend (line or bar+line combo, 12 months)
- Chart 2: volume comparison (bars, e.g., created vs resolved)
- Chart 3: secondary metric trend
- Chart 4: satisfaction or quality trend

**Gauge design rules:**
- 4-5 percentage or ratio metrics with targets
- Always include at least one SLA-type gauge if data supports it

---

## Step 3 — Pull the Data

Write DAX queries that pull **granular company × month** fact data. This is critical — the dashboard does client-side filtering, so it needs dimensional data, not pre-aggregated totals.

**Required queries:**

### A. Company × Month financial/time data:
```
execute_dax(dax_query="EVALUATE ADDCOLUMNS( FILTER( SUMMARIZE( MainTable, CompanyTable[company_name], DateTable[year], DateTable[month] ), DateTable[year] >= YEAR(TODAY()) - 1 ), \"Metric1\", [Measure 1], \"Metric2\", [Measure 2] ) ORDER BY CompanyTable[company_name], DateTable[year], DateTable[month]")
```

### B. Company × Month ticket/operational data (if relevant):
```
execute_dax(dax_query="EVALUATE SUMMARIZECOLUMNS( TicketTable[company_name], DateTable[year], DateTable[month], FILTER(ALL(DateTable[year]), DateTable[year] >= YEAR(TODAY()) - 1), \"Created\", [Tickets - Count - Created], \"Resolved\", [Tickets - Count - Resolved] ) ORDER BY TicketTable[company_name], DateTable[year], DateTable[month]")
```

### C. Resource × Month data (if relevant):
```
execute_dax(dax_query="EVALUATE ADDCOLUMNS( FILTER( SUMMARIZE( TimeTable, TimeTable[resource_name], DateTable[year], DateTable[month] ), DateTable[year] >= YEAR(TODAY()) - 1 ), \"Hours\", [Total], \"Revenue\", [Revenue - Total] ) ORDER BY TimeTable[resource_name], DateTable[year], DateTable[month]")
```

### D. Static KPIs (non-filterable, from different data sources):
```
execute_dax(dax_query="EVALUATE ROW(\"KPI1\", [Measure1], \"KPI2\", [Measure2])")
```

**IMPORTANT:** Use the actual table names, column names, and measure names discovered in Step 1. Do not guess.

---

## Step 4 — Build the DATA Object

Transform DAX results into the star-schema structure:

```json
{
  "refreshed": "2026-01-15T12:00:00Z",
  "dim": {
    "companies": ["Company A", "Company B", ...],
    "resources": ["Resource 1", "Resource 2", ...],
    "queues": ["Queue 1", "Queue 2", ...]
  },
  "facts": [
    {"c": 0, "y": 2025, "m": 1, "rev": 12345, "cost": 8000, "profit": 4345, "hrs": 50, "bill": 40, "t_cr": 15, "t_res": 12, ...},
    ...
  ],
  "facts_resource": [
    {"r": 0, "y": 2025, "m": 1, "hrs": 80, "bill": 65, "rev": 5000, "cost": 3000},
    ...
  ],
  "facts_queue": [
    {"q": 0, "y": 2025, "m": 1, "t_cr": 20, "t_res": 18},
    ...
  ],
  "static_kpi": {
    "pipeline_count": 45,
    "backup_success": 0.97,
    ...
  }
}
```

**Rules:**
- `c`, `r`, `q` are integer indices into the dimension arrays
- `y` = year, `m` = month (1-12)
- All metric fields are numeric (decimals OK)
- Use short field names (e.g., `rev`, `cost`, `hrs`, `bill`, `t_cr`, `t_res`)
- Include ALL rows from the DAX results — do not summarize

---

## Step 5 — Build the DASH_CONFIG Object

The DASH_CONFIG tells the template engine what to render.

```json
{
  "title": "Dashboard Title",
  "subtitle": "One-line description of what this dashboard shows",
  "sources": "Autotask PSA + N-able RMM",
  "filters": ["company", "queue", "resource", "time"],

  "kpi_rows": [
    [
      {"label": "Revenue", "color": "teal", "metric": "sum:rev", "format": "eur",
       "sub_metric": "ratio:profit:rev", "sub_format": "pct", "sub_prefix": "Margin "},
      {"label": "Profit", "color": "green", "metric": "sum:profit", "format": "eur"},
      {"label": "Pipeline", "color": "blue", "metric": "static:pipeline_total", "format": "eur",
       "sub_metric": "static:pipeline_count", "sub_format": "num", "sub_suffix": " deals"},
      {"label": "Avg Deal", "color": "purple", "metric": "static:avg_deal", "format": "eur"}
    ],
    [
      {"label": "Open Tickets", "color": "amber", "metric": "static:open_tickets", "format": "num"},
      {"label": "CSAT Score", "color": "teal", "metric": "wavg:csat_sum:csat_n", "format": "rating"},
      {"label": "Closure Rate", "color": "green", "metric": "ratio:t_res:t_cr", "format": "pct"},
      {"label": "Resources", "color": "blue", "metric": "static:resources_active", "format": "num"}
    ]
  ],

  "gauges": [
    {"label": "First Response SLA", "metric": "ratio:fr_met:t_cr", "color": "#0f766e", "target": 0.85, "target_label": "Target: 85%", "max": 1},
    {"label": "Resolution SLA", "metric": "ratio:res_met:t_cr", "color": "#16a34a", "target": 0.90, "target_label": "Target: 90%", "max": 1},
    {"label": "First Hour Fix", "metric": "ratio:fhf:t_cr", "color": "#f59e0b", "target": 0.25, "target_label": "Target: 25%", "max": 1},
    {"label": "Avg Hours/Ticket", "metric": "ratio:hrs:t_cr", "color": "#3b82f6", "format": "hrs", "target_label": "Lower is better", "max": 5},
    {"label": "Backup Success", "metric": "static:backup_success", "color": "#0f766e", "target": 0.95, "target_label": "Target: 95%", "max": 1}
  ],

  "charts": [
    {
      "title": "Revenue & Profit Trend", "badge": "Monthly",
      "series": [
        {"label": "Revenue", "field": "rev", "color": "#0f766e", "type": "bar", "bg": "rgba(15,118,110,0.7)"},
        {"label": "Profit", "field": "profit", "color": "#14b8a6", "type": "line"}
      ],
      "y_format": "eur"
    },
    {
      "title": "Tickets Created vs Resolved", "badge": "Monthly",
      "series": [
        {"label": "Created", "field": "t_cr", "color": "#f59e0b", "type": "bar", "bg": "rgba(245,158,11,0.7)"},
        {"label": "Resolved", "field": "t_res", "color": "#22c55e", "type": "bar", "bg": "rgba(34,197,94,0.7)"}
      ],
      "y_format": "num"
    },
    {
      "title": "Hours: Billable vs Total", "badge": "Monthly",
      "series": [
        {"label": "Total", "field": "hrs", "color": "#3b82f6", "type": "bar", "bg": "rgba(59,130,246,0.7)"},
        {"label": "Billable", "field": "bill", "color": "#0f766e", "type": "bar", "bg": "rgba(15,118,110,0.7)"}
      ],
      "y_format": "hrs"
    },
    {
      "title": "CSAT Score Trend", "badge": "Monthly",
      "series": [
        {"label": "CSAT", "compute": "ratio", "numerator": "csat_sum", "denominator": "csat_n", "color": "#0f766e", "type": "line", "tooltip_format": "rating"}
      ],
      "y_format": "rating", "y_min": 0, "y_max": 5
    }
  ],

  "table": {
    "title": "Top Companies by Revenue",
    "columns": [
      {"label": "#", "type": "rank"},
      {"label": "Company", "type": "name"},
      {"label": "Revenue", "field": "rev", "format": "eur"},
      {"label": "Hours", "field": "hrs", "format": "num"},
      {"label": "Tickets", "field": "t_cr", "format": "num"},
      {"label": "Rev/Hour", "type": "derived", "calc": "rev/hrs", "format": "eur"}
    ],
    "sort": "rev", "order": "desc", "limit": 15
  }
}
```

### Metric definition syntax:
| Syntax | Example | Meaning |
|--------|---------|---------|
| `sum:field` | `sum:rev` | Sum the `rev` field across all filtered facts |
| `ratio:a:b` | `ratio:profit:rev` | sum(profit) / sum(rev) |
| `wavg:sum:count` | `wavg:csat_sum:csat_n` | Weighted average: sum(csat_sum) / sum(csat_n) |
| `static:key` | `static:pipeline_total` | Read from DATA.static_kpi |

### KPI colors:
`teal`, `blue`, `amber`, `green`, `red`, `purple`

### Format codes:
| Code | Output | Example |
|------|--------|---------|
| `eur` | €12.3K or €1.2M | Currency |
| `pct` | 85.2% | Percentage (input 0-1) |
| `pct0` | 85% | Percentage, no decimals |
| `num` | 1,234 | Number |
| `hrs` | 50.2 h | Hours |
| `rating` | 4.6/5 | Rating |

---

## Step 6 — Assemble the Final HTML

Read the template from `templates/dashboard.html` in this repository. Copy it EXACTLY and replace these two placeholders:

| Placeholder | Replace with |
|-------------|--------------|
| `{{DASHBOARD_CONFIG}}` | Your DASH_CONFIG JSON object from Step 5 |
| `{{DATA_JSON}}` | Your DATA object from Step 4 |
| `{{GENERATED_DATE}}` | Today's date (YYYY-MM-DD) |

**COPY THE ENTIRE TEMPLATE** including all CSS, HTML structure, and JavaScript. Do not rewrite any of the template code. Only replace the placeholders.

---

## Step 7 — Output Rules (MANDATORY)

1. **Output the COMPLETE HTML** — the full template with both JSON blocks filled in
2. **No `<!DOCTYPE>`, no `<html>`, no `<body>`** — output starts with `<!-- Proxuma Live Dashboard Template` and ends with `</script>`
3. **Include ALL data rows** from DAX — never summarize or skip rows
4. **Include ALL KPI configs** — all 8 cards, all gauges, all 4 charts, full table config
5. **Minimum output: 300 lines** — a proper dashboard with real data is 400-800 lines
6. **Use real measure/table/column names** from Step 1 — never guess or use placeholder names
7. **Test your JSON** — make sure both DASH_CONFIG and DATA are valid JSON (no trailing commas, no comments)

### Anti-summarization guard
Do NOT write "... (remaining data omitted)" or "... (see full data)" or similar. Write EVERY data point. The dashboard needs all data to render correctly. If you truncate the data, the charts will be empty and KPIs will show zeros.

---

## Example: Operations Overview

For reference, here is how the Operations Overview dashboard uses these patterns:

**Data queries:** Company×month with revenue, cost, profit, hours, billable hours, tickets created/resolved, CSAT, SLA percentages. Resource×month with hours and revenue. Queue×month with tickets. Static KPIs for pipeline, backup, resources.

**Fact fields:** `rev`, `cost`, `profit`, `hrs`, `bill`, `t_cr`, `t_res`, `csat_sum`, `csat_n`, `fr_met`, `res_met`, `fhf`, `sdr`

**Filters:** company, queue, resource, time — all cross-filter the same fact table.

Adapt this pattern to the user's requested topic. Choose relevant measures and design KPIs, gauges, and charts that tell the story of that topic area.
