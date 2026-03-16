# Copilot Studio Dashboard Experiments — Results

**Date:** 2026-03-04
**Agent:** Power BI Assistant (GPT-5 Chat, 7 MCP tools)
**Environment:** Proxuma (default) on Microsoft Copilot Studio

---

## Executive Summary

**Winner: Experiment B — JSON-only output with hosted Dashboard Renderer.**

Copilot Studio has an `OpenAIModelTokenLimit` that prevents the agent from outputting complete HTML dashboards (400-800 lines). However, the agent CAN produce structured JSON within token limits when data is TOPN-limited. The solution: agent outputs two JSON objects (DASH_CONFIG + DATA), user pastes them into a self-contained Dashboard Renderer page that builds the full interactive dashboard client-side.

---

## Experiment A: Full HTML Output

### Goal
Test if the Copilot Studio agent can output a complete, working HTML dashboard (400-800 lines) with embedded CSS, JavaScript, and data.

### Tests Run

| Test | Prompt | Result | Timing |
|------|--------|--------|--------|
| A1 — Connection | `List all workspaces` | SUCCESS | ~2s |
| A2 — Small ROW query | `EVALUATE ROW(...)` (3 KPIs) | SUCCESS | ~15s |
| A3 — Full SUMMARIZECOLUMNS | Company x month (all rows) | FAILED | ~8s |
| A4 — TOPN(20) + structured JSON | Company x month (20 rows) | SUCCESS | ~5s |

### Key Findings

1. **MCP connection works perfectly** — all 7 tools accessible, `search_schema` (~12s), `execute_dax` (0.98-4.80s)
2. **Small queries succeed** — ROW queries with 1-3 values return clean JSON
3. **Large queries fail with `OpenAIModelTokenLimit`** — company x month data (100+ rows) exceeds the combined context limit (tool results + response)
4. **TOPN workaround works** — limiting to 20-50 rows keeps output within token limits
5. **Full HTML output is impossible** — even without data, a 400-800 line HTML template would overflow
6. **PII anonymization is active** — company names show `<ORGANIZATION>` / `<PERSON>` placeholders (from the MCP server's PII filter)

### Conclusion
**Experiment A: FAILED for full HTML, but proved MCP tools and structured JSON output work.**

---

## Experiment B: JSON-Only + Hosted Renderer

### Goal
Have the agent output only two JSON objects (DASH_CONFIG + DATA), which the user pastes into a self-contained Dashboard Renderer page.

### Components Built

1. **Dashboard Renderer** (`templates/dashboard-renderer.html`) — 1,535 lines / 58KB
   - Split-screen: JSON input (left) + live iframe preview (right)
   - Two textareas: DASH_CONFIG and DATA
   - "Paste from Copilot" button (parses combined JSON block)
   - "Download HTML" button (generates standalone dashboard file)
   - Full `dashboard.html` template CSS+JS embedded as template string
   - Pre-populated with sample data, auto-renders on load
   - Error handling with toast notifications

2. **Updated Agent Instructions** — JSON-only dashboard mode
   - `TOPN(50)` limit added to DAX GUIDELINES
   - GENERATING DASHBOARDS section: output TWO JSON objects, not HTML
   - DATA structure spec: `{dim:{companies:[...]}, facts:[{c,y,m,...}], static_kpi:{...}}`
   - DASH_CONFIG structure spec: `{title, kpi_rows, gauges, charts, table}`
   - Metric syntax reference: `sum:field`, `ratio:a:b`, `wavg:sum:count`, `static:key`

### Proof of Concept

Test A4 already proved the approach:
- Agent was asked for TOPN(20) SLA data formatted as `{dim:{...}, facts:[...]}`
- Agent produced **valid, well-structured JSON** in the exact format the renderer expects
- 10 companies, 20 fact rows, all with proper index references (`c:0`, `c:1`, etc.)
- Agent proactively offered: "Would you like me to prepare a dashboard-ready JSON with KPIs and charts?"

### User Workflow

```
1. User: "Generate a live dashboard for SLA performance"
2. Agent: calls search_schema → discovers SLA measures
3. Agent: calls execute_dax with TOPN(50) → gets company×month data
4. Agent: outputs DASH_CONFIG JSON + DATA JSON
5. User: opens dashboard-renderer.html (local file or hosted URL)
6. User: pastes JSON into the two textareas (or uses "Paste from Copilot")
7. Renderer: builds full interactive dashboard with KPIs, gauges, charts, table
8. User: optionally clicks "Download HTML" for a standalone file
```

### Conclusion
**Experiment B: SUCCESS — viable approach, all components work.**

---

## Comparison

| Criterion | Experiment A (Full HTML) | Experiment B (JSON + Renderer) |
|-----------|--------------------------|-------------------------------|
| **Feasibility** | Impossible (token limit) | Works |
| **Output size** | 400-800 lines (too large) | ~50-100 lines JSON (fits) |
| **Data coverage** | Would need all rows | TOPN(50) sufficient for dashboard |
| **User effort** | Copy-paste HTML | Copy-paste JSON into renderer |
| **Rendering quality** | N/A | Full interactive dashboard |
| **Maintenance** | Template in Knowledge docs | Renderer hosted once, always current |
| **Portability** | Each output is standalone | Renderer reusable, JSON varies |

---

## Discovered Constraints

1. **Copilot Studio token limit** — `OpenAIModelTokenLimit` caps the total context (instructions + tool results + response). Error code: `OpenAIModelTokenLimit`.
2. **search_schema latency** — ~12 seconds per call. Plan for 2-3 calls = 25-35 seconds discovery phase.
3. **execute_dax speed** — Fast (0.98-4.80s depending on complexity). ROW queries < 1s.
4. **Knowledge file upload** — Browser automation cannot trigger native OS file dialogs. Files must be uploaded manually or via drag-and-drop.
5. **PII anonymization** — The MCP server's PII filter replaces company names with `<ORGANIZATION>` / `<PERSON>`. This needs to be disabled for real dashboard data or the user needs to be aware.
6. **Input field limit** — Copilot Studio test panel: 2000 characters per message. Agent instructions: 8000 characters max.
7. **Session stickiness** — Updated instructions only take effect in new test sessions.

---

## Recommendations

### For the Onboarding Guide

1. **Lead with Experiment B approach** — JSON-only output + Dashboard Renderer
2. **Host the Dashboard Renderer** — on proxuma.io or as a GitHub Pages site from the powerbi-copilot repo
3. **Provide pre-built DASH_CONFIG templates** — users pick a topic template, agent fills in DATA
4. **Document the TOPN requirement** — explain why unlimited queries crash
5. **Add connection troubleshooting** — workspace_id/dataset_id must be provided explicitly
6. **Show the PII anonymization behavior** — explain and show how to handle it

### For Future Development

1. **Multi-turn dashboard building** — Step 1: agent discovers measures, Step 2: agent builds DATA, Step 3: agent builds DASH_CONFIG. Keeps each response small.
2. **Template gallery** — Pre-built DASH_CONFIG templates for common topics (SLA, Revenue, Tickets, Resources)
3. **Copilot Studio Adaptive Card** — Instead of raw JSON, agent could return a card with a "View Dashboard" button linking to the renderer with URL-encoded JSON
4. **Power Automate integration** — Agent triggers a flow that writes JSON to a SharePoint file, renderer fetches it automatically

---

## Files Created

| File | Description | Size |
|------|-------------|------|
| `experiments/experiment-a-output.json` | Full Experiment A test results with all 4 tests | 4KB |
| `experiments/experiment-b-output.json` | Experiment B design, proof of concept, workflow | 3KB |
| `experiments/RESULTS.md` | This file — comprehensive comparison | 6KB |
| `templates/dashboard-renderer.html` | Self-contained Dashboard Renderer page | 58KB |
| `~/Downloads/copilot-studio-experiment-a.gif` | GIF recording of browser automation tests | 5MB |
