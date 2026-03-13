# Power BI QBR Report Generator

Generate a comprehensive Quarterly Business Review (QBR) report for a specific client.

**Customer:** $ARGUMENTS

**If no customer name is specified, ask the user which customer to generate the QBR for.**

**IMPORTANT: Always ask the user before starting:**
> Which language should this QBR be in?
> 1. **English** — International version, resource names anonymized as Resource A, B, C...
> 2. **Nederlands** — Dutch version, resource names converted to Dutch names (Jan de Vries, Pieter Bakker, etc.)

Wait for the user's answer before proceeding. The language choice affects:
- All headings, labels, descriptions, insight text, and recommended actions
- Article introduction and narrative bridges
- Question showcase text
- Resource name style (English: Resource A/B/C, Dutch: realistic Dutch names)
- The filename suffix: `-en` or `-nl` (e.g., `proxuma-io-qbr-contoso-nl-post.html`)

## Dutch Language Guide

When generating the **Nederlands** version, use these translations:

| English | Nederlands |
|---------|-----------|
| Quarterly Business Review | Kwartaaloverzicht |
| Revenue | Omzet |
| Cost | Kosten |
| Profit | Winst |
| Profit Margin | Winstmarge |
| Total Tickets | Totaal Tickets |
| Open Tickets | Openstaande Tickets |
| SLA First Response | SLA Eerste Reactie |
| SLA Resolution | SLA Oplossing |
| Hours Worked | Gewerkte Uren |
| Hours Billed | Gefactureerde Uren |
| Avg Hours Per Ticket | Gem. Uren per Ticket |
| Configuration Items | Configuratie-items |
| Active | Actief |
| Inactive | Inactief |
| Warranty Expired | Garantie Verlopen |
| Contract Portfolio | Contractenportfolio |
| Asset & Device Inventory | Apparaten & Inventaris |
| Key Insights | Belangrijkste Inzichten |
| Recommended Actions | Aanbevolen Acties |
| Executive Financial Summary | Financieel Overzicht |
| Service Delivery Overview | Overzicht Dienstverlening |
| SLA Performance | SLA Prestaties |
| Top Ticket Categories | Top Ticketcategorieën |
| Resolution Efficiency | Oplossingsefficiëntie |
| Resource Investment | Investering in Personeel |
| Open Ticket Aging | Veroudering Openstaande Tickets |
| Portfolio Benchmark | Portfoliovergelijking |
| Recommended Actions for Next Quarter | Aanbevolen Acties voor Volgend Kwartaal |
| View DAX Query | Bekijk DAX Query |
| See more reports | Bekijk meer rapporten |
| Get started | Aan de slag |
| Demo Report: This report uses synthetic data... | Demorapport: Dit rapport gebruikt synthetische data... |
| The question we asked | De vraag die we stelden |
| Data source | Databron |
| Analysis date | Analysedatum |
| Scope | Bereik |
| Period: Trailing 12 months | Periode: Afgelopen 12 maanden |

### Dutch Resource Names (use these instead of Resource A/B/C)

Use realistic Dutch names for anonymized resources:
Jan de Vries, Pieter Bakker, Sanne Jansen, Marco Visser, Lisa van Dijk, Thijs de Groot, Eva Mulder, Bram Hendriks, Floor Smit, Ruben Vermeer

### Dutch Question Showcase Text
"Hoe presteert onze MSP voor deze klant — dienstverlening, financiële gezondheid, apparaatbeheer, en waar liggen de groeikansen?"

### Dutch Article Intro Tone
Write in professional but approachable Dutch. Use "u" (formal) for client-facing text. Bold key phrases in navy `#1B365D`.

### Dutch CTA Block
"Genereer dit soort kwartaaloverzichten uit uw eigen data" / "Verbind Proxuma's Power BI-integratie met uw Autotask PSA, en gebruik een MCP-compatibele AI om complete kwartaaloverzichten te genereren — in minuten, niet in uren."

## Purpose

This report is designed for MSP salespeople to bring to client meetings. It demonstrates:
1. Value delivered (SLA performance, ticket resolution)
2. Upsell opportunities (expired warranties, inactive contracts)
3. Security gaps (aging devices, out-of-warranty assets)
4. Financial analysis (revenue, cost, margin, portfolio comparison)
5. Recommended actions for next quarter

## Environment

| Resource | ID |
|----------|-----|
| Workspace (Proxuma Demo) | `1d365f6a-1dbb-4466-88e1-487f6836b452` |
| Dataset (Data model Template) | `fd823eb4-da85-449d-a175-d24bff86229f` |

## Memory Safety Rules

1. **NEVER** use `get_schema` — it returns >10MB and crashes the session
2. **ALWAYS** use `search_schema` with specific terms when needed
3. **LIMIT** DAX results with `TOPN()` or filters

---

## Step 1: Find the Customer

Search for the customer by name to get their `company_id`:

```
mcp__powerbi__execute_dax(
    dataset_id="fd823eb4-da85-449d-a175-d24bff86229f",
    dax_query="EVALUATE FILTER('BI_Autotask_Companies', SEARCH(\"<CUSTOMER_NAME>\", 'BI_Autotask_Companies'[company_name], 1, 0) > 0)"
)
```

If multiple results, ask the user which one. Store the `company_id` for all subsequent queries.

If no results, try partial matches or ask the user to check the name.

---

## Step 2: Execute All DAX Queries

Run these queries in parallel batches. Replace `<ID>` with the company_id found in Step 1.

### VERIFIED Column Names (DO NOT GUESS — these are confirmed correct)

| Table | Columns |
|-------|---------|
| `BI_Autotask_Companies` | `company_id`, `company_name` |
| `BI_Autotask_Tickets` | `ticket_id`, `ticket_type_name`, `ticket_category_name`, `status_name`, `priority_name`, `create_date`, `complete_datetime`, `first_response_met`, `resolution_met`, `first_hour_fix`, `first_day_resolution`, `ticket_age_days`, `ticket_age_category` |
| `BI_Autotask_Configuration_Items` | `configuration_item_category_name`, `is_active`, `warranty_expiration_date`, `company_id` |
| `BI_Autotask_Billing_Items` | `total_amount`, `our_cost`, `posted_date`, `company_id` |
| `BI_Autotask_Contracts` | `contract_name`, `contract_type_name`, `contract_status_name`, `company_id` |
| `BI_Autotask_Time_Entries` | `hours_worked` |

### VERIFIED Measure Names (DO NOT GUESS — these are confirmed correct)

| Measure | Notes |
|---------|-------|
| `[Revenue - Total]` | Total revenue |
| `[Cost - Total]` | Total cost |
| `[Profit - total]` | Revenue minus cost |
| `[Profit - total - percentage]` | Margin percentage |
| `[Company - Hours Worked]` | Total hours worked |
| `[Company - Billable Hours]` | Billable hours |
| `[Company - Hours Billed]` | Hours billed |
| `[Tickets - First Response Met %]` | SLA first response (NOT `SLA First Response Met %`) |
| `[Tickets - Resolution Met %]` | SLA resolution (NOT `SLA Resolution Met %`) |
| `[Tickets - Avg Hours Per Ticket]` | Average hours per ticket |

### Batch 1: Core KPIs (run in parallel)

**Query 1A — Client Financial & SLA KPIs:**
```dax
EVALUATE
ROW(
    "Revenue", CALCULATE([Revenue - Total], 'BI_Autotask_Companies'[company_id] = <ID>),
    "Cost", CALCULATE([Cost - Total], 'BI_Autotask_Companies'[company_id] = <ID>),
    "Profit", CALCULATE([Profit - total], 'BI_Autotask_Companies'[company_id] = <ID>),
    "Margin_Pct", CALCULATE([Profit - total - percentage], 'BI_Autotask_Companies'[company_id] = <ID>),
    "SLA_FR_Pct", CALCULATE([Tickets - First Response Met %], 'BI_Autotask_Companies'[company_id] = <ID>),
    "SLA_Res_Pct", CALCULATE([Tickets - Resolution Met %], 'BI_Autotask_Companies'[company_id] = <ID>),
    "Hours_Worked", CALCULATE([Company - Hours Worked], 'BI_Autotask_Companies'[company_id] = <ID>),
    "Hours_Billed", CALCULATE([Company - Hours Billed], 'BI_Autotask_Companies'[company_id] = <ID>),
    "Avg_Hours_Per_Ticket", CALCULATE([Tickets - Avg Hours Per Ticket], 'BI_Autotask_Companies'[company_id] = <ID>)
)
```

**Query 1B — Ticket & CI Summary:**
```dax
EVALUATE
ROW(
    "Total_Tickets", CALCULATE(COUNTROWS('BI_Autotask_Tickets'), 'BI_Autotask_Companies'[company_id] = <ID>),
    "Open_Tickets", CALCULATE(COUNTROWS(FILTER('BI_Autotask_Tickets', ISBLANK('BI_Autotask_Tickets'[complete_datetime]))), 'BI_Autotask_Companies'[company_id] = <ID>),
    "First_Hour_Fix", CALCULATE(COUNTROWS(FILTER('BI_Autotask_Tickets', 'BI_Autotask_Tickets'[first_hour_fix] = TRUE())), 'BI_Autotask_Companies'[company_id] = <ID>),
    "Total_CIs", CALCULATE(COUNTROWS('BI_Autotask_Configuration_Items'), 'BI_Autotask_Companies'[company_id] = <ID>),
    "Active_CIs", CALCULATE(COUNTROWS(FILTER('BI_Autotask_Configuration_Items', 'BI_Autotask_Configuration_Items'[is_active] = TRUE())), 'BI_Autotask_Companies'[company_id] = <ID>)
)
```

**Query 1C — Portfolio Benchmarks (all clients):**
```dax
EVALUATE
ROW(
    "Portfolio_Revenue", [Revenue - Total],
    "Portfolio_Margin", [Profit - total - percentage],
    "Portfolio_SLA_FR", [Tickets - First Response Met %],
    "Total_Companies", COUNTROWS(VALUES('BI_Autotask_Companies'[company_id])),
    "Total_Tickets", COUNTROWS('BI_Autotask_Tickets'),
    "Portfolio_Avg_Hours_Per_Ticket", [Tickets - Avg Hours Per Ticket]
)
```

### Batch 2: Detailed Breakdowns (run in parallel)

**Query 2A — Ticket Types:**
```dax
EVALUATE
ADDCOLUMNS(
    SUMMARIZE(
        FILTER('BI_Autotask_Tickets', RELATED('BI_Autotask_Companies'[company_id]) = <ID>),
        'BI_Autotask_Tickets'[ticket_type_name]
    ),
    "Count", CALCULATE(COUNTROWS('BI_Autotask_Tickets'), 'BI_Autotask_Companies'[company_id] = <ID>)
)
ORDER BY [Count] DESC
```

**Query 2B — Top 10 Ticket Categories:**
```dax
EVALUATE
TOPN(10,
    ADDCOLUMNS(
        SUMMARIZE(
            FILTER('BI_Autotask_Tickets', RELATED('BI_Autotask_Companies'[company_id]) = <ID>),
            'BI_Autotask_Tickets'[ticket_category_name]
        ),
        "Count", CALCULATE(COUNTROWS('BI_Autotask_Tickets'), 'BI_Autotask_Companies'[company_id] = <ID>)
    ),
    [Count], DESC
)
ORDER BY [Count] DESC
```

**Query 2C — Top 10 Resources (anonymized):**
```dax
EVALUATE
TOPN(10,
    ADDCOLUMNS(
        SUMMARIZE(
            FILTER('BI_Autotask_Time_Entries', RELATED('BI_Autotask_Companies'[company_id]) = <ID>),
            'BI_Autotask_Resources'[resource_name]
        ),
        "Hours_Worked", CALCULATE([Company - Hours Worked], 'BI_Autotask_Companies'[company_id] = <ID>),
        "Hours_Billed", CALCULATE([Company - Hours Billed], 'BI_Autotask_Companies'[company_id] = <ID>)
    ),
    [Hours_Worked], DESC
)
ORDER BY [Hours_Worked] DESC
```

**Query 2D — CI Categories (active only):**
```dax
EVALUATE
ADDCOLUMNS(
    SUMMARIZE(
        FILTER('BI_Autotask_Configuration_Items',
            RELATED('BI_Autotask_Companies'[company_id]) = <ID>
            && 'BI_Autotask_Configuration_Items'[is_active] = TRUE()),
        'BI_Autotask_Configuration_Items'[configuration_item_category_name]
    ),
    "Count", CALCULATE(
        COUNTROWS('BI_Autotask_Configuration_Items'),
        'BI_Autotask_Companies'[company_id] = <ID>,
        'BI_Autotask_Configuration_Items'[is_active] = TRUE()
    ),
    "Expired_Warranty", CALCULATE(
        COUNTROWS(FILTER('BI_Autotask_Configuration_Items',
            'BI_Autotask_Configuration_Items'[warranty_expiration_date] < TODAY())),
        'BI_Autotask_Companies'[company_id] = <ID>,
        'BI_Autotask_Configuration_Items'[is_active] = TRUE()
    )
)
ORDER BY [Count] DESC
```

### Batch 3: SLA & Contract Details (run in parallel)

**Query 3A — Priority Breakdown with SLA:**
```dax
EVALUATE
ADDCOLUMNS(
    SUMMARIZE(
        FILTER('BI_Autotask_Tickets', RELATED('BI_Autotask_Companies'[company_id]) = <ID>),
        'BI_Autotask_Tickets'[priority_name]
    ),
    "Count", CALCULATE(COUNTROWS('BI_Autotask_Tickets'), 'BI_Autotask_Companies'[company_id] = <ID>),
    "FR_Met_Pct", CALCULATE([Tickets - First Response Met %], 'BI_Autotask_Companies'[company_id] = <ID>),
    "Res_Met_Pct", CALCULATE([Tickets - Resolution Met %], 'BI_Autotask_Companies'[company_id] = <ID>)
)
ORDER BY [Count] DESC
```

**Query 3B — Contract Summary:**
```dax
EVALUATE
ADDCOLUMNS(
    SUMMARIZE(
        FILTER('BI_Autotask_Contracts', RELATED('BI_Autotask_Companies'[company_id]) = <ID>),
        'BI_Autotask_Contracts'[contract_name],
        'BI_Autotask_Contracts'[contract_type_name],
        'BI_Autotask_Contracts'[contract_status_name]
    ),
    "Revenue", CALCULATE([Revenue - Total], 'BI_Autotask_Companies'[company_id] = <ID>)
)
ORDER BY [Revenue] DESC
```

**Query 3C — Open Ticket Aging:**
```dax
EVALUATE
ADDCOLUMNS(
    SUMMARIZE(
        FILTER('BI_Autotask_Tickets',
            RELATED('BI_Autotask_Companies'[company_id]) = <ID>
            && ISBLANK('BI_Autotask_Tickets'[complete_datetime])),
        'BI_Autotask_Tickets'[ticket_age_category]
    ),
    "Count", CALCULATE(
        COUNTROWS(FILTER('BI_Autotask_Tickets', ISBLANK('BI_Autotask_Tickets'[complete_datetime]))),
        'BI_Autotask_Companies'[company_id] = <ID>
    )
)
ORDER BY [Count] DESC
```

---

## Step 3: Generate the HTML Report

Use the **Task tool with a background agent** to generate the full HTML report, since these reports are very large (2000+ lines).

### Report Structure (12+ sections, each with inline DAX)

The report MUST follow the `.prx-report` CSS framework from the reference template.

**Reference template:** `~/ClaudeCode/powerbi-reports/proxuma-io-qbr-client-review-post.html`
**CSS template:** `~/ClaudeCode/powerbi-reports/proxuma-io-security-status-post.html`

Read the reference template for the exact CSS framework and HTML component structure.

### Required Report Sections (in order)

1. **Series Navigation** — Breadcrumb: Power BI > AI-Powered Reports > QBR
2. **Demo Data Banner** — Yellow info bar
3. **Page Hero** — Navy gradient with "Quarterly Business Review: [Company Name]"
4. **Question Showcase** — Teal gradient with: "How is our MSP performing for [Company Name] — service delivery, financial health, device management, and where are the growth opportunities?"
5. **Article Introduction** — 2 paragraphs about QBR importance
6. **Report Banner** — Navy gradient with metadata (date, company_id, scope)
7. **KPI Cards** — Revenue, Margin %, SLA FR %, Open Tickets (with standalone inline DAX)
8. **Section 1: Executive Financial Summary** — Revenue/cost/margin table + portfolio comparison bar chart
9. **Section 2: Service Delivery Overview** — Ticket type distribution table
10. **Section 3: SLA Performance** — Priority breakdown with FR% and Resolution% per priority
11. **Section 4: Top Ticket Categories** — Top 10 categories bar chart
12. **Section 5: Resolution Efficiency** — Mini KPIs (avg hours/ticket, first hour fix rate, first day resolution) + comparison to portfolio
13. **Narrative Bridge** — 2 paragraphs interpreting the data
14. **Section 6: Resource Investment** — Top 10 resources table (ANONYMIZED as Resource A, B, C...)
15. **Section 7: Open Ticket Aging** — Aging distribution bar chart + open tickets by type
16. **Section 8: Asset & Device Inventory** — CI categories table with warranty status
17. **Section 9: Contract Portfolio** — Active/inactive contracts table with types
18. **Section 10: Portfolio Benchmark** — Side-by-side comparison client vs portfolio averages
19. **Narrative Bridge** — 2 paragraphs with recommendations
20. **Section 11: Key Insights** — 6 insight cards (mix of `.critical`, `.warning`, `.success`)
21. **Section 12: Recommended Actions** — Numbered action list for the salesperson
22. **CTA Block** — Links to `/powerbi/insights` and `/powerbi-self-onboarding/`

### Key Rules for HTML Generation

- All CSS scoped under `.prx-report` (WordPress-safe)
- **ANONYMIZE all resource names** — use "Resource A", "Resource B", etc. (public-facing report)
- **Each data section has its own collapsible inline DAX query** at the bottom
- KPI cards use `.inline-dax.standalone` class
- Use `!important` on backgrounds and colors for WordPress overrides
- Include `prxCopyDAX()` JavaScript function at the bottom
- No standalone header/footer (WordPress provides those)
- No Export PDF button
- Use `.pill` and `.pct-badge` for badges in tables
- Use `.patch-row` / `.patch-bar-wrapper` for bar charts
- The DAX shown in the report should use descriptive alias names (e.g., `[Total Revenue]`, `[SLA First Response Met %]`) for readability — these don't need to match the actual measure names exactly

### Insight Generation

Based on the data, generate 6 insight cards analyzing:
1. **Financial health** — margin vs portfolio, revenue trends
2. **Warranty/asset risk** — expired warranties, hardware refresh opportunities
3. **SLA performance** — strengths and weaknesses by priority
4. **Open ticket concerns** — aging tickets, stuck tickets
5. **Contract opportunities** — inactive contracts, reactivation potential
6. **Resource investment** — dedicated resources, billing efficiency

### Recommended Actions

Generate 5-7 specific, actionable recommendations based on the data findings. These should be written for a salesperson preparing for a QBR meeting.

### Humanizer (MANDATORY)

**All narrative text in the report MUST be humanized.** Before finalizing, apply the humanizer skill (`~/.claude/skills/humanizer/SKILL.md`) to all written prose: article intros, narrative bridges, insight card text, section descriptions, footnotes, question showcase subtitle, recommended actions, and CTA copy. Specifically:

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

## Step 4: Save and Deliver

1. Save to: `~/ClaudeCode/powerbi-reports/proxuma-io-qbr-[company-name-lowercase]-post.html`
2. Open in browser: `open ~/ClaudeCode/powerbi-reports/[filename].html`
3. Copy to clipboard: `cat ~/ClaudeCode/powerbi-reports/[filename].html | pbcopy`
4. Tell user: **"Copied to clipboard. Paste into WordPress Custom HTML block."**

---

## Error Handling

- If a DAX query fails, check column names against the verified list above
- If a measure is not found, use `search_schema` to find the correct name
- If a company has no data for certain sections (e.g., no CIs, no contracts), note it in the report as "No data available" rather than leaving empty sections
- If the report is too large for one Write call, split into chunks or use the background Task agent
