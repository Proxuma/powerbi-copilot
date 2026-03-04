# Live Dashboard Generator

Generate an interactive dashboard from Power BI data. **Topic:** $ARGUMENTS

If no topic given, ask the user what dashboard to build.

---

## Step 1 — Discover Data

Search for relevant measures and columns (run 2-3 searches):
```
search_schema(workspace_id, dataset_id, search_term="keyword")
list_measures(workspace_id, dataset_id)
```

Pull sample data to understand tables:
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
    "tickets", [Total Tickets]
  ),
  'Date'[Year], DESC, 'Date'[MonthNumber], DESC
)
```

Adjust table/column/measure names to match the actual data model.

---

## Step 3 — Build ONE Combined JSON

Output a **single JSON object** with both `config` (layout) and `data` (query results):

```json
{
  "config": {
    "title": "Dashboard Title",
    "subtitle": "One-line description",
    "sources": "Autotask PSA via Power BI",
    "filters": ["company", "time"],
    "kpi_rows": [
      [
        {"label": "Revenue", "color": "teal", "metric": "sum:rev", "format": "eur"},
        {"label": "Tickets", "color": "blue", "metric": "sum:t_cr", "format": "num"}
      ]
    ],
    "gauges": [
      {"label": "SLA", "metric": "ratio:met:total", "color": "#0f766e", "target": 0.85, "target_label": "Target: 85%", "max": 1}
    ],
    "charts": [
      {
        "title": "Trend", "badge": "Monthly",
        "series": [
          {"label": "Revenue", "field": "rev", "color": "#0f766e", "type": "bar", "bg": "rgba(15,118,110,0.7)"}
        ],
        "y_format": "eur"
      }
    ],
    "table": {
      "title": "By Company", "mode": "company",
      "columns": [
        {"label": "#", "type": "rank"},
        {"label": "Company", "type": "name"},
        {"label": "Revenue", "field": "rev", "format": "eur"}
      ],
      "sort": "rev", "order": "desc", "limit": 15
    }
  },
  "data": {
    "refreshed": "2026-03-04T14:30:00Z",
    "dim": { "companies": ["Company A", "Company B"] },
    "facts": [
      {"c": 0, "y": 2025, "m": 4, "rev": 45000, "t_cr": 120}
    ],
    "static_kpi": {}
  }
}
```

### Metric syntax
- `sum:field` — sum of field
- `ratio:a:b` — Sum(a) / Sum(b)
- `wavg:sum:count` — weighted average
- `static:key` — from static_kpi

### Formats
`eur` (€1.4M), `num` (3.171), `pct` (84.5%), `hrs` (8422.0 h), `rating` (4.4/5)

### KPI colors
`teal`, `blue`, `amber`, `green`, `red`, `purple`

### Table column types
- `{"type": "rank"}` — auto #
- `{"type": "name"}` — company from dim
- `{"field": "x", "format": "eur"}` — direct
- `{"type": "derived", "calc": "a/b", "format": "pct"}` — computed

---

## Step 4 — Output

1. Output the JSON as ONE code block
2. Tell the user: **"Copy this JSON and paste it into the Dashboard Renderer"**
3. Link: `proxuma.io/powerbi/dashboards/renderer/`

### Rules
- Real table/column/measure names only
- TOPN(50) max per query
- 4-8 KPIs, 1-4 gauges, 1-2 charts, 5-8 table columns
- `dim.companies` array must match `c` index in facts (0-based)
- Facts need: `c`, `y`, `m`, plus metric fields
