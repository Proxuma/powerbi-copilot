---
name: powerbidashboard
version: 2.0.0
description: |
  Generate a live dashboard from Power BI data. Outputs a single JSON object
  that the user pastes into the Dashboard Renderer at proxuma.io/powerbi/dashboards/renderer/
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
  - mcp__powerbi__search_schema
  - mcp__powerbi__execute_dax
  - mcp__powerbi__list_measures
  - mcp__powerbi__list_workspaces
  - mcp__powerbi__list_datasets
  - mcp__powerbi__list_fabric_items
---

# Live Dashboard Generator

Generate an interactive dashboard from Power BI data. **Topic:** $ARGUMENTS

If no topic given, ask the user what dashboard to build.

---

## Step 1 — Discover Data

Search for relevant measures and columns:
```
search_schema(workspace_id, dataset_id, search_term="keyword")
list_measures(workspace_id, dataset_id)
```

Then pull sample data:
```
execute_dax(dataset_id, dax_query="EVALUATE TOPN(5, 'TableName')")
```

**NEVER use `get_schema`** — crashes on large models (>10MB).

---

## Step 2 — Query Data

Build a SUMMARIZECOLUMNS query with **TOPN(50)** to get company × month data:

```dax
EVALUATE
TOPN(50,
  SUMMARIZECOLUMNS(
    'Company'[CompanyName],
    'Date'[Year], 'Date'[MonthNumber],
    "rev", [Total Revenue],
    "tickets", [Total Tickets],
    "hours", [Total Hours]
  ),
  'Date'[Year], DESC, 'Date'[MonthNumber], DESC
)
```

Adjust table/column/measure names to match the actual data model.

---

## Step 3 — Build Combined JSON

Output **ONE JSON object** with both `config` and `data`:

```json
{
  "config": {
    "title": "Dashboard Title",
    "subtitle": "One-line description",
    "sources": "Data source name",
    "filters": ["company", "time"],
    "kpi_rows": [
      [
        {"label": "KPI Name", "color": "teal", "metric": "sum:field", "format": "eur"},
        {"label": "KPI Name", "color": "blue", "metric": "sum:field", "format": "num"}
      ],
      [
        {"label": "KPI Name", "color": "amber", "metric": "ratio:a:b", "format": "pct"},
        {"label": "KPI Name", "color": "green", "metric": "wavg:sum:count", "format": "rating"}
      ]
    ],
    "gauges": [
      {"label": "Gauge", "metric": "ratio:a:b", "color": "#0f766e", "target": 0.85, "target_label": "Target: 85%", "max": 1}
    ],
    "charts": [
      {
        "title": "Chart Title", "badge": "Monthly",
        "series": [
          {"label": "Series A", "field": "field_a", "color": "#0f766e", "type": "bar", "bg": "rgba(15,118,110,0.7)"},
          {"label": "Series B", "field": "field_b", "color": "#1B365D", "type": "line"}
        ],
        "y_format": "eur"
      }
    ],
    "table": {
      "title": "Table Title", "mode": "company",
      "columns": [
        {"label": "#", "type": "rank"},
        {"label": "Name", "type": "name"},
        {"label": "Revenue", "field": "rev", "format": "eur"},
        {"label": "SLA %", "type": "derived", "calc": "met/total", "format": "pct"}
      ],
      "sort": "rev", "order": "desc", "limit": 15
    }
  },
  "data": {
    "refreshed": "2026-03-04T14:30:00Z",
    "dim": {
      "companies": ["Company A", "Company B", "Company C"]
    },
    "facts": [
      {"c": 0, "y": 2025, "m": 4, "rev": 45000, "tickets": 120, "hours": 350},
      {"c": 0, "y": 2025, "m": 5, "rev": 48000, "tickets": 115, "hours": 360}
    ],
    "static_kpi": {}
  }
}
```

---

## Schema Reference

### Metric types
| Syntax | Meaning | Example |
|--------|---------|---------|
| `sum:field` | Sum of field across facts | `sum:rev` |
| `ratio:a:b` | Sum(a) / Sum(b) | `ratio:met:total` |
| `wavg:sum:count` | Weighted average | `wavg:csat_sum:csat_n` |
| `static:key` | Value from static_kpi | `static:target` |

### Format types
| Format | Output | Example |
|--------|--------|---------|
| `eur` | Euro currency | €1.4M, €45K |
| `num` | Number | 3.171 |
| `pct` | Percentage (value 0-1) | 84.5% |
| `hrs` | Hours | 8422.0 h |
| `rating` | Rating out of 5 | 4.4/5 |

### KPI colors
`teal`, `blue`, `amber`, `green`, `red`, `purple`

### Chart types
`bar` (default), `line`

### Table column types
- `{"type": "rank"}` — auto-numbered #
- `{"type": "name"}` — company name from dim
- `{"field": "x", "format": "eur"}` — direct field
- `{"type": "derived", "calc": "a/b", "format": "pct"}` — computed

### Table modes
`company` (aggregate by company), `monthly` (one row per month), `raw` (no aggregation)

### Filters
`company`, `queue`, `resource`, `time`

---

## Step 4 — Output

1. Output the complete JSON as a single code block
2. Tell the user: **"Copy this JSON and paste it into the Dashboard Renderer at proxuma.io/powerbi/dashboards/renderer/"**
3. The renderer auto-detects the format and builds the dashboard instantly

### Rules
- Use **real** table/column/measure names from the data model
- TOPN(50) maximum per DAX query
- 4-8 KPIs in 2 rows of 2-4
- 1-4 gauges
- 1-2 charts
- Table with 5-8 columns
- `dim.companies` array must match the `c` index in facts (0-based)
- Each fact row needs: `c` (company index), `y` (year), `m` (month), plus metric fields

### Pre-built templates
If the topic matches a known template, read it from `templates/configs/` as a starting point for the config:
- `sla-performance.json` — SLA tracking
- `ticket-volume.json` — Ticket metrics
- `revenue-billing.json` — Revenue & billing
- `resource-utilization.json` — Resource utilization
- `csat-satisfaction.json` — Customer satisfaction
- `patch-compliance.json` — Patch compliance
- `endpoint-health.json` — Endpoint health
- `project-performance.json` — Project performance
