# Project Report Generator

Generate TWO professional HTML project reports with PDF export:
1. **External Report** - Customer-facing (no financial data, anonymized names)
2. **Internal Report** - MSP internal use (full financial data, anonymized names, profitability analysis)

## Usage
The user will specify which customer/project to generate a report for: $ARGUMENTS

**If no project is specified, ask the user which project they want a report for.**

---

## BRANDING: Default vs Custom

### Default Branding (Proxuma)
If no specific branding/style is mentioned, use **Proxuma branding** as defined in this document:
- Proxuma logo, colors, typography
- Header/footer templates as specified
- Taglines: "Because Time Matters", "Smarter Planning for MSPs"
- Website: proxuma.io

### Custom Branding Override
When the user specifies a different company style (e.g., "in the style of Acme Corp", "use ClientX branding", "white-label for CompanyY"), override these elements:

| Element | What to Replace |
|---------|-----------------|
| **Logo** | Replace Proxuma SVG with client's logo (fetch from their website if not provided) |
| **Colors** | Map client brand colors to CSS variables (see mapping table below) |
| **Company name** | Replace "Proxuma" throughout (footer, copyright, badge) |
| **Website URL** | Replace proxuma.io with client's website |
| **Taglines** | Replace "Because Time Matters" / "Smarter Planning for MSPs" with client's tagline (or remove if none) |
| **Document prefix** | Replace `PRX-` with client's prefix |

**CSS Variable Mapping for Custom Branding:**

Always map the client's brand palette to the CSS variable system. The template uses CSS custom properties so a single `:root` block controls the entire theme:

```css
:root {
    --navy-primary: [client primary color];     /* Headers, section labels, title bg */
    --proxuma-blue: [client secondary color];   /* Borders, footer accents */
    --navy-dark: [darker variant of primary];   /* Deep backgrounds */
    --blue-bright: [client accent color];       /* Links, CTAs, highlights */
    --blue-light: [lighter accent variant];     /* Secondary CTAs */
    --green-cta: [client CTA color];            /* Export button, action buttons */
    /* Keep functional colors unchanged: */
    --green-success: #10B981;                   /* Success states */
    --sky-background: [light tint of primary];  /* Table headers, alternating rows */
    --gray-50: #F8FAFC;                         /* Page background */
    --gray-600: #475569;                        /* Body text */
}
```

For Gantt bar colors, budget bar gradients, and pill badges: use `linear-gradient(135deg, primary, secondary)` with the client's palette. Semantic colors (green for success, amber for warning, red for danger) stay unchanged.

**What stays the same regardless of branding:**
- Overall layout structure (export bar, header, content sections, footer)
- Typography system (Montserrat headings, Inter body)
- Spacing system (8px base)
- Report sections and data presentation
- Internal/External report differentiation logic
- Gantt chart implementation
- DAX verification section (internal only)
- Name anonymization rules

## Resource Files
All supporting files are stored in `~/.claude/resources/projectreport/`:
- `template.html` - Complete HTML template with all styling (use as reference)
- `proxuma-logo.svg` - Official Proxuma logo SVG
- `Proxuma_Brand_Guidelines.docx` - Full brand guidelines document

## Instructions

### 1. Query Power BI Data

**CRITICAL: RAM OPTIMIZATION - AVOID SCHEMA OVERLOAD**

```
NEVER use mcp__powerbi__get_schema - it returns >10MB and crashes the system!
```

**Use these lightweight alternatives instead:**

| Need | Tool | Example |
|------|------|---------|
| Find specific measures/columns | `search_schema` | `search_schema(search_term="project")` |
| List all measure names | `list_measures` | `list_measures(workspace_id, dataset_id)` |
| Query actual data | `execute_dax` | `execute_dax(dataset_id, "EVALUATE ...")` |

**Connection Details:**
- Workspace ID: `1d365f6a-1dbb-4466-88e1-487f6836b452` (Proxuma Demo)
- Dataset ID: `fd823eb4-da85-449d-a175-d24bff86229f` (Proxuma - Data model - Template)

**Query Workflow (Low RAM):**
1. **First:** Use `search_schema` to find relevant columns/measures for "project", "task", "time"
2. **Then:** Build targeted DAX queries using only the fields you found
3. **Execute:** Run `execute_dax` with specific, filtered queries (use TOPN, filters)

**Key Tables:**
- `BI_Autotask_Projects` - Project details
- `BI_Autotask_Tasks` - Task breakdown by phase
- `BI_Autotask_Time_Entries` - Time entries by resource

**DAX Query Tips (Keep Results Small):**
- Always use `TOPN()` or `FILTER()` to limit results
- Select only needed columns, not entire tables
- Filter by project name early in the query
- Example:
```dax
EVALUATE
FILTER(
    SELECTCOLUMNS(
        'BI_Autotask_Projects',
        "Name", [ProjectName],
        "Client", [CompanyName],
        "Status", [Status]
    ),
    [Name] = "Project Name Here"
)
```

### 2. Generate BOTH Reports

You MUST generate two separate HTML files for every project:

---

## REPORT 1: External (Customer-Facing)

**Filename:** `Project_[ProjectName]_Report.html`

**Key Rules:**

**NAME & COMPANY ANONYMIZATION IS MANDATORY**

**Replace ALL person names, customer names, and project names with plausible anonymized versions.** The original names from the data MUST NOT appear anywhere in either report.

**Reference files:**
- `~/ClaudeCode/project-reports/anonymized_names_lookup.csv` - Ready-to-use anonymized names by category
- `~/ClaudeCode/project-reports/anonymized_names_reference.csv` - Naming patterns reference

### Person Names (Team Members, Project Leads, etc.)
Replace with common American first + last name combinations:
- Michael Johnson, Sarah Williams, David Anderson, Jennifer Miller
- Christopher Davis, Emily Wilson, Matthew Brown, Amanda Taylor
- James Peterson, Robert Collins, William Stevens, Thomas Mitchell

### Customer/Company Names
Use realistic business name patterns based on industry:

| Industry | Pattern Examples |
|----------|------------------|
| **Banks** | Riverside Bank, Summit State Bank, First Heritage Bank, Valley View Savings Bank |
| **Credit Unions** | Lakeside Credit Union, Heritage Federal Credit Union, Prairie Community CU |
| **Companies** | Precision Industries Inc., Northland Services LLC, Keystone Manufacturing |
| **Construction** | Eastbrook Construction, Ridgeline Builders, Ironwood Development |
| **Cities** | City of Westfield, City of Lakewood, City of Fairmont, City of Riverdale |
| **Healthcare** | Northside Medical Clinic, Family Health Associates, Regional Wellness Center |
| **Non-Profits** | Heritage Community Foundation, Discovery Science Museum, Lakeside YMCA |

### Project Names
Maintain the same structure but with anonymized company names:
- "Summit Bank QBR Q1 2025" (not the real bank name)
- "FIELD Deployment Project - (5) Replacement Laptops"
- "Client ONBOARDING: Keysuite (03/15/25)"
- "Networking - Switch Replacement"
- "Security - XDR Deployment"

### Anonymization Rules
1. Scan ALL data fields: Project names, Customer names, Person names, Assigned To, Last Activity By, etc.
2. Create a consistent mapping: same original name = same replacement throughout BOTH reports
3. Keep project TYPE/STRUCTURE intact - only replace identifiable names
4. QBR projects: Replace "[RealClient] QBR Q1" with "[AnonymizedClient] QBR Q1"
5. Field projects: Keep "FIELD Deployment Project - " prefix, anonymize any names within

**CRITICAL: BOTH REPORTS USE IDENTICAL ANONYMIZED NAMES**
- The External and Internal reports MUST use the **exact same** anonymized project name, company name, and person names
- Example: If External uses "Systems Migration Project" for "Harrison & Mitchell Law Partners", Internal uses those same names
- The ONLY differences between reports are: Internal has financials, DAX queries, and "INTERNAL USE ONLY" banner
- Never show original names in either report header, title, or content sections

**Before generating reports, identify ALL names and create your replacement mapping.**

- **DO NOT include any financial data:** No profit, costs, revenue, margins
- **DO NOT include resource utilization details**
- Focus on deliverables, timeline, and achievements

**Sections (top to bottom):**
1. Export Bar — fixed at top, navy bg, green/accent CTA "Exporteer als PDF" button
2. Header — Logo + meta (date, document number, period) separated by blue border
3. Demo Banner — yellow info bar if using demo data ("Voorbeeldrapport — Dit rapport is gegenereerd met demodata...")
4. Title Section — gradient background, project name, client name, status badge, details grid (projectnummer, PM, contactpersoon, go-live)
5. Metric Cards — 4-column grid: Voortgang (%), Budget (used/total), Doorlooptijd (days), Open risico's. With progress bars where applicable. First card uses `.highlight` style (gradient bg)
6. Key Deliverables — 2x2 grid with icon cards showing completed/in-progress deliverables
7. **Project Timeline (Gantt chart) — MANDATORY** — Pure CSS table-based Gantt with phase bars, today marker
8. Phase Summary Table — Budget per fase with status pills, budget/besteed/resterend columns, footer totals
9. Budget Bar Chart — visual bar chart showing besteed vs. budget per fase with colored bars (ok/warn/over)
10. Management Samenvatting — narrative summary of project status, 2-3 paragraphs
11. Resource Overzicht — table with resource, rol, deze periode, totaal besteed, budget, beschikbaar
12. Afgeronde Werkzaamheden — checklist with green checkmarks
13. Geplande Werkzaamheden — checklist with circle icons
14. Risico's en Aandachtspunten — table with #, risico, impact, kans, status (pills), maatregel
15. Beslispunten — numbered decision list with deadlines (decision-date badges)
16. Bevindingen — 2x2 grid with colored summary cards (.success, .warning, .info)
17. Next Report — info bar with calendar icon and date of next rapportage
18. Footer — Logo + tagline left, generated-by + website + copyright right
19. Proxuma Badge — subtle "Gegenereerd met Proxuma" link at bottom

---

## REPORT 2: Internal (MSP Use)

**Filename:** `INTERNAL_Project_[ProjectName]_Report.html`

**IMPORTANT: Use the SAME anonymized names as the External report!**
- Same anonymized project name in header/title
- Same anonymized company name
- Same anonymized person names
- The only differences: Internal includes financial data, DAX queries, and confidential banner

**Key Rules:**
- **USE IDENTICAL ANONYMIZED NAMES** - Same project name, company name, and person names as external report
- **Include ALL financial data** - Revenue, costs, profit, margins
- **Show resource utilization** - Hours per team member with costs
- **Add budget analysis** - Estimated vs actual hours, efficiency %
- **Include lessons learned** - What went well, areas for improvement
- **Include DAX Verification Section** - All queries used to generate the report data

**FULL ANONYMIZATION (BOTH REPORTS)**

Anonymize ALL identifiable information in BOTH reports using the patterns above:

1. **Person names** → American names (James Wilson, Sarah Collins, etc.)
2. **Customer/Company names** → Plausible business names matching industry (Riverside Bank, Summit Construction, etc.)
3. **Project names** → Keep structure, replace company names (e.g., "Riverside Bank QBR Q1 2025")

**Be consistent: same original name = same replacement across BOTH reports - including headers and titles!**

**Additional Sections (beyond external report):**
- Red "INTERNAL USE ONLY" banner at top
- "CONFIDENTIAL - INTERNAL" label in header
- Financial Overview (4 cards): Revenue, Cost, Profit, Margin %
  - Color code margin: Green >40%, Yellow 25-40%, Red <25%
- Budget Analysis (4 cards): Budgeted Hours, Actual Hours, Variance, Efficiency %
- Performance Indicators (traffic lights): Schedule, Budget, Margin
- **Project Timeline (Gantt chart) - MANDATORY**
- Resource Utilization Table: Team Member, Role, Hours, Est. Cost, % of Total
- Lessons Learned Section:
  - "What Went Well" (green checkmarks)
  - "Areas for Improvement" (orange warnings)
  - "Recommendations for Similar Projects" (blue arrows)
- **DAX Verification Section - MANDATORY** (see below)
- Footer with "CONFIDENTIAL - INTERNAL USE ONLY"

**Internal Report Styling:**
```css
--internal-red: #DC2626;
--internal-red-light: #FEE2E2;
--warning-yellow: #F59E0B;
```

---

## DAX VERIFICATION SECTION - MANDATORY (Internal Report Only)

**The internal report MUST include a collapsible section at the end showing ALL DAX queries used to generate the report data.** This allows verification in Power BI Desktop.

### DAX Section HTML Structure
```html
<div class="section-label"><span>DAX Queries - Data Verification</span></div>
<div class="dax-section">
    <p class="dax-intro">Copy these queries to Power BI Desktop (View → Performance Analyzer) to verify the data in this report.</p>

    <div class="dax-query">
        <div class="dax-header" onclick="this.parentElement.classList.toggle('expanded')">
            <span class="dax-title">1. Project Details</span>
            <span class="dax-toggle">▼</span>
        </div>
        <div class="dax-content">
            <pre><code>EVALUATE
TOPN(5, FILTER(
    SELECTCOLUMNS('BI_Autotask_Projects', ...),
    [StartDate] = ...
), [ActualHours], DESC)</code></pre>
            <button class="copy-btn" onclick="copyDAX(this)">Copy Query</button>
        </div>
    </div>

    <!-- Repeat for each query used -->
</div>
```

### DAX Section CSS
```css
.dax-section {
    background: #f8fafc;
    border: 1px solid #E2E8F0;
    border-radius: 12px;
    padding: var(--space-lg);
    margin-bottom: var(--space-2xl);
}

.dax-intro {
    font-size: 13px;
    color: var(--gray-600);
    margin-bottom: var(--space-lg);
}

.dax-query {
    background: white;
    border: 1px solid #E2E8F0;
    border-radius: 8px;
    margin-bottom: 12px;
    overflow: hidden;
}

.dax-header {
    padding: 12px 16px;
    background: var(--navy-primary);
    color: white;
    cursor: pointer;
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-family: 'Montserrat', sans-serif;
    font-size: 13px;
    font-weight: 600;
}

.dax-header:hover { background: #234B7A; }

.dax-toggle { transition: transform 0.2s; }
.dax-query.expanded .dax-toggle { transform: rotate(180deg); }

.dax-content {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s ease;
}

.dax-query.expanded .dax-content { max-height: 500px; }

.dax-content pre {
    background: #1e293b;
    color: #e2e8f0;
    padding: 16px;
    margin: 0;
    overflow-x: auto;
    font-family: 'Consolas', 'Monaco', monospace;
    font-size: 12px;
    line-height: 1.5;
}

.copy-btn {
    margin: 12px;
    padding: 8px 16px;
    background: var(--green-cta);
    color: var(--navy-primary);
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-weight: 600;
    font-size: 12px;
}

.copy-btn:hover { background: #00c49a; }
```

### DAX Section JavaScript
```javascript
function copyDAX(btn) {
    const code = btn.parentElement.querySelector('code').textContent;
    navigator.clipboard.writeText(code).then(() => {
        btn.textContent = 'Copied!';
        setTimeout(() => { btn.textContent = 'Copy Query'; }, 2000);
    });
}
```

### Required DAX Queries to Include
Include ALL queries actually used to generate the report:
1. **Project Details** - Main project info (name, client, lead, dates, financials)
2. **Task Breakdown** - Tasks by phase with hours
3. **Phase Summary** - Aggregated phase data
4. **Resource Utilization** - Time entries by resource
5. Any other queries used for specific metrics

**Each query should be the EXACT query that was executed**, so the user can run it in Power BI and verify the numbers match.

---

## GANTT CHART - MANDATORY IMPLEMENTATION

**The Gantt chart MUST be included in EVERY report.** Use this lightweight, pure CSS implementation:

### Gantt Structure (Pure CSS - No JS Libraries)
```html
<div class="section-label"><span>Project Timeline</span></div>
<div class="gantt-wrapper">
    <table class="gantt-table">
        <thead>
            <tr>
                <th class="gantt-task-col">Phase / Task</th>
                <th class="gantt-timeline-header" colspan="TOTAL_DAYS">
                    <div class="gantt-months">
                        <!-- Month headers spanning their days -->
                        <span style="grid-column: span 5;">Jan 2026</span>
                        <span style="grid-column: span 10;">Feb 2026</span>
                    </div>
                </th>
            </tr>
        </thead>
        <tbody>
            <!-- Phase Row -->
            <tr class="gantt-phase-row">
                <td class="gantt-task-cell">
                    <span class="phase-dot phase-1"></span>
                    <strong>Phase Name</strong>
                </td>
                <td class="gantt-timeline-cell" colspan="TOTAL_DAYS">
                    <div class="gantt-grid" style="--days: TOTAL_DAYS;">
                        <!-- Day grid lines rendered by CSS -->
                    </div>
                </td>
            </tr>
            <!-- Task Row -->
            <tr class="gantt-task-row">
                <td class="gantt-task-cell">
                    <span class="task-name">Task Name</span>
                    <span class="task-hours">8h</span>
                </td>
                <td class="gantt-timeline-cell" colspan="TOTAL_DAYS">
                    <div class="gantt-grid" style="--days: TOTAL_DAYS;">
                        <div class="gantt-bar phase-1" style="--start: 0; --duration: 3;">Task</div>
                    </div>
                </td>
            </tr>
        </tbody>
    </table>
</div>
```

### Gantt CSS (Lightweight, No JS)
```css
/* Gantt Chart - Lightweight Pure CSS */
.gantt-wrapper {
    overflow-x: auto;
    margin-bottom: var(--space-2xl);
    border: 1px solid #E2E8F0;
    border-radius: 12px;
}

.gantt-table {
    width: 100%;
    min-width: 800px;
    border-collapse: collapse;
    table-layout: fixed;
}

.gantt-task-col {
    width: 200px;
    min-width: 200px;
    background: var(--navy-primary);
    color: white;
    padding: 12px 16px;
    text-align: left;
    font-family: 'Montserrat', sans-serif;
    font-size: 13px;
    font-weight: 600;
}

.gantt-timeline-header {
    background: var(--navy-primary);
    color: white;
    padding: 8px;
    vertical-align: top;
}

.gantt-months {
    display: grid;
    grid-auto-flow: column;
    text-align: center;
    font-size: 12px;
    font-weight: 600;
}

.gantt-task-cell {
    padding: 10px 16px;
    border-bottom: 1px solid #E2E8F0;
    background: white;
    display: flex;
    align-items: center;
    gap: 8px;
    min-height: 44px;
}

.gantt-phase-row .gantt-task-cell {
    background: var(--sky-background);
}

.gantt-timeline-cell {
    padding: 0;
    border-bottom: 1px solid #E2E8F0;
    position: relative;
    height: 44px;
}

.gantt-grid {
    display: grid;
    grid-template-columns: repeat(var(--days), 1fr);
    height: 100%;
    position: relative;
    background: repeating-linear-gradient(
        90deg,
        transparent,
        transparent calc(100% / var(--days) - 1px),
        #E2E8F0 calc(100% / var(--days) - 1px),
        #E2E8F0 calc(100% / var(--days))
    );
}

.gantt-bar {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    height: 24px;
    border-radius: 4px;
    font-size: 11px;
    font-weight: 600;
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0 8px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    /* Position using CSS custom properties */
    left: calc((var(--start) / var(--days)) * 100%);
    width: calc((var(--duration) / var(--days)) * 100%);
    min-width: 40px;
}

.gantt-bar.phase-1 { background: linear-gradient(135deg, #8B5CF6, #7C3AED); }
.gantt-bar.phase-2 { background: linear-gradient(135deg, #2563EB, #1B365D); }
.gantt-bar.phase-3 { background: linear-gradient(135deg, #10B981, #059669); }
.gantt-bar.phase-4 { background: linear-gradient(135deg, #F59E0B, #D97706); }

.phase-dot {
    width: 10px;
    height: 10px;
    border-radius: 3px;
    flex-shrink: 0;
}
.phase-dot.phase-1 { background: #8B5CF6; }
.phase-dot.phase-2 { background: #2563EB; }
.phase-dot.phase-3 { background: #10B981; }
.phase-dot.phase-4 { background: #F59E0B; }

.task-name {
    flex: 1;
    font-size: 13px;
    color: var(--navy-primary);
}

.task-hours {
    font-size: 11px;
    font-weight: 600;
    color: #64748B;
    background: #F1F5F9;
    padding: 2px 8px;
    border-radius: 4px;
}

/* Print styles for Gantt */
@media print {
    .gantt-wrapper { overflow: visible; }
    .gantt-table { min-width: 0; }
    .gantt-bar { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
}
```

### Gantt Bar Positioning
Calculate bar position using these CSS custom properties:
- `--days`: Total number of days in the timeline
- `--start`: Day index where the task starts (0-based)
- `--duration`: Number of days the task spans

Example for a task starting day 3 and lasting 5 days over a 20-day timeline:
```html
<div class="gantt-bar phase-1" style="--start: 3; --duration: 5;">Task Name</div>
```
The parent `.gantt-grid` must have `style="--days: 20;"`.

---

## PDF Export - LIGHTWEIGHT APPROACH

**DO NOT use html2pdf.js** - it loads html2canvas which consumes excessive RAM (often 500MB+).

**Use native browser print instead:**

```html
<!-- Export button in header -->
<button class="export-btn" onclick="window.print()">Export as PDF</button>
```

```css
/* Comprehensive print styles */
@media print {
    * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }

    body { background: white; }

    .export-bar, .export-btn { display: none !important; }

    .page-wrapper { padding: 0; }

    .page {
        box-shadow: none;
        border-radius: 0;
        padding: 15mm;
        max-width: none;
    }

    /* Preserve colors */
    .title-section,
    .gantt-task-col,
    .gantt-timeline-header,
    .phase-table th,
    .metric-card.highlight,
    .status-badge,
    .gantt-bar {
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
    }

    /* Page breaks */
    .gantt-wrapper { page-break-inside: avoid; }
    .summary-section { page-break-inside: avoid; }
    .table-container { page-break-inside: avoid; }

    /* Remove hover effects */
    .metric-card:hover {
        transform: none;
        box-shadow: none;
    }
}
```

**User instruction:** When exporting, use browser's "Save as PDF" option in the print dialog. This is:
- Zero additional memory overhead
- No external libraries
- Better quality output
- Works offline

---

## MANDATORY HEADER & FOOTER TEMPLATES (Proxuma Default)

**These are the DEFAULT Proxuma templates. The structure MUST be exactly as specified - only dynamic values (date, document number, period) may change.**

**If custom branding is requested:** Replace logo, colors, company name, taglines, and website as specified in the "Branding: Default vs Custom" section above, but KEEP the same layout structure.

### Quick Reference: External vs Internal Differences

| Element | External Report | Internal Report |
|---------|-----------------|-----------------|
| Top banner | None | Red "INTERNAL USE ONLY - CONFIDENTIAL" |
| Export bar title | "Project Status Report Preview" | "Internal Project Report" + confidential label |
| Header border | 3px solid `--proxuma-blue` | 3px solid `--internal-red` |
| Document prefix | `PRX-RPT-` | `PRX-INT-` |
| Footer border | 2px solid `--proxuma-blue` | 2px solid `--internal-red` |
| Footer tagline | "Because Time Matters" | "CONFIDENTIAL - INTERNAL USE ONLY" |
| Page wrapper padding-top | 80px | 112px (accounts for banner) |

---

### EXTERNAL REPORT - Export Bar, Header & Footer

**Export Bar (fixed at top of viewport):**
```html
<div class="export-bar">
    <div class="export-bar-title">Project Status Report Preview</div>
    <button class="export-btn" onclick="window.print()">Export as PDF</button>
</div>
```

**Header (inside .page, before title section):**
```html
<header class="header">
    <div class="logo-container">
        <!-- PROXUMA LOGO SVG - EXACT AS SHOWN IN LOGO SECTION BELOW -->
        <svg viewBox="0 0 960.97 282.29" xmlns="http://www.w3.org/2000/svg" style="height: 48px; width: auto;">...</svg>
    </div>
    <div class="header-meta">
        <div><strong>Report Date:</strong> [CURRENT DATE]</div>
        <div><strong>Document:</strong> PRX-RPT-[YEAR]-[MONTH]-[PROJECT_ID]</div>
        <div><strong>Period:</strong> [START DATE] - [END DATE or Present]</div>
    </div>
</header>
```

**Footer (at end of .page, after all content sections):**
```html
<footer class="footer">
    <div class="footer-logo">
        <!-- PROXUMA LOGO SVG - height: 36px -->
        <svg viewBox="0 0 960.97 282.29" xmlns="http://www.w3.org/2000/svg" style="height: 36px; width: auto;">...</svg>
        <div class="footer-tagline">Because Time Matters</div>
    </div>
    <div class="footer-info">
        <div>Smarter Planning for MSPs</div>
        <div><a href="https://proxuma.io">www.proxuma.io</a></div>
        <div>&copy; [YEAR] Proxuma. All rights reserved.</div>
    </div>
</footer>
```

---

### INTERNAL REPORT - Banner, Export Bar, Header & Footer

**Internal Banner (fixed at very top, above export bar):**
```html
<div class="internal-banner">INTERNAL USE ONLY - CONFIDENTIAL</div>
```

**Export Bar (fixed below banner):**
```html
<div class="export-bar">
    <div class="export-bar-title">
        Internal Project Report
        <span class="confidential-label">CONFIDENTIAL - INTERNAL</span>
    </div>
    <button class="export-btn" onclick="window.print()">Export as PDF</button>
</div>
```

**Header (inside .page - note the RED border instead of blue):**
```html
<header class="header">
    <div class="logo-container">
        <!-- PROXUMA LOGO SVG - height: 48px -->
        <svg viewBox="0 0 960.97 282.29" xmlns="http://www.w3.org/2000/svg" style="height: 48px; width: auto;">...</svg>
    </div>
    <div class="header-meta">
        <div><strong>Report Date:</strong> [CURRENT DATE]</div>
        <div><strong>Document:</strong> PRX-INT-[YEAR]-[MONTH]-[PROJECT_ID]</div>
        <div><strong>Period:</strong> [START DATE] - [END DATE or Present]</div>
    </div>
</header>
```

**Footer (with confidential label):**
```html
<footer class="footer">
    <div class="footer-logo">
        <!-- PROXUMA LOGO SVG - height: 36px -->
        <svg viewBox="0 0 960.97 282.29" xmlns="http://www.w3.org/2000/svg" style="height: 36px; width: auto;">...</svg>
        <div class="footer-confidential">CONFIDENTIAL - INTERNAL USE ONLY</div>
    </div>
    <div class="footer-info">
        <div>Smarter Planning for MSPs</div>
        <div><a href="https://proxuma.io">www.proxuma.io</a></div>
        <div>&copy; [YEAR] Proxuma. All rights reserved.</div>
    </div>
</footer>
```

---

### MANDATORY CSS FOR HEADER & FOOTER

**These styles MUST be included exactly as shown:**

```css
/* Export Bar */
.export-bar {
    position: fixed;
    top: 0;  /* External: 0, Internal: 32px (below banner) */
    left: 0;
    right: 0;
    background: var(--navy-primary);
    padding: var(--space-md) var(--space-xl);
    display: flex;
    justify-content: space-between;
    align-items: center;
    z-index: 1000;
    box-shadow: 0 4px 15px rgba(0,0,0,0.15);
}

.export-bar-title {
    font-family: 'Montserrat', sans-serif;
    color: var(--white);
    font-size: 14px;
    font-weight: 600;
}

.export-btn {
    background: linear-gradient(135deg, var(--green-cta), #00B386);
    color: var(--white);
    border: none;
    padding: 12px 28px;
    border-radius: 8px;
    font-family: 'Montserrat', sans-serif;
    font-size: 14px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 4px 15px rgba(0, 217, 165, 0.3);
}

.export-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0, 217, 165, 0.4);
}

/* Internal Banner (Internal Report Only) */
.internal-banner {
    background: var(--internal-red);
    color: white;
    text-align: center;
    padding: 8px;
    font-family: 'Montserrat', sans-serif;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 2px;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 1001;
}

.confidential-label {
    background: var(--internal-red-light);
    color: var(--internal-red);
    padding: 4px 12px;
    border-radius: 4px;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 1px;
    margin-left: 12px;
}

/* Page Wrapper Padding */
.page-wrapper {
    padding-top: 80px;   /* External report */
    /* padding-top: 112px; -- Internal report (accounts for banner) */
    padding-bottom: var(--space-2xl);
}

/* Header */
.header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-bottom: var(--space-lg);
    border-bottom: 3px solid var(--proxuma-blue);  /* External: proxuma-blue */
    /* border-bottom: 3px solid var(--internal-red); -- Internal: internal-red */
    margin-bottom: var(--space-2xl);
}

.header-meta {
    text-align: right;
    font-size: 13px;
    color: var(--gray-600);
    line-height: 1.8;
}

.header-meta strong {
    color: var(--navy-primary);
    font-weight: 600;
}

/* Footer */
.footer {
    margin-top: 64px;
    padding-top: var(--space-lg);
    border-top: 2px solid var(--proxuma-blue);  /* External: proxuma-blue */
    /* border-top: 2px solid var(--internal-red); -- Internal: internal-red */
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.footer-logo {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: var(--space-xs);
}

.footer-tagline {
    font-family: 'Montserrat', sans-serif;
    font-size: 13px;
    font-weight: 600;
    color: var(--proxuma-blue);
    font-style: italic;
}

.footer-confidential {
    font-family: 'Montserrat', sans-serif;
    font-size: 11px;
    font-weight: 700;
    color: var(--internal-red);
    letter-spacing: 1px;
}

.footer-info {
    text-align: right;
    font-size: 12px;
    color: var(--gray-600);
    line-height: 1.8;
}

.footer-info a {
    color: var(--blue-bright);
    text-decoration: none;
    font-weight: 500;
}
```

---

### 3. Proxuma Brand Guidelines (Default - Override if Custom Branding Requested)

**Colors:**
```css
:root {
    --navy-primary: #1B365D;
    --proxuma-blue: #164487;
    --navy-dark: #002C60;
    --blue-bright: #2563EB;
    --green-cta: #00D9A5;
    --green-success: #10B981;
    --sky-background: #E8F4FD;
    --gray-50: #F8FAFC;
    --gray-600: #475569;
}
```

**Typography:**
- Headings: 'Montserrat', font-weight 600-800
- Body: 'Inter', font-weight 400-500
- Load from Google Fonts (with display=swap for performance)

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Montserrat:wght@600;700;800&display=swap" rel="stylesheet">
```

**Spacing (8px base):**
```css
--space-xs: 4px;
--space-sm: 8px;
--space-md: 16px;
--space-lg: 24px;
--space-xl: 32px;
--space-2xl: 48px;
```

---

### 4. Proxuma Logo SVG (Inline)
```html
<svg viewBox="0 0 960.97 282.29" xmlns="http://www.w3.org/2000/svg" style="height: 48px; width: auto;">
  <defs><style>.cls-1{fill:#002c60;}.cls-2{fill:#00b7ff;}</style></defs>
  <path class="cls-2" d="m216.45,16.34l-5.35-16.34-13.49,10.69c-23.28,18.52-40.13,43.4-48.71,72-3.48,11.59-5.48,23.41-6.02,35.26,7.41,1,14.52,2.96,21.2,5.75.76-7.97,2.31-15.93,4.66-23.74,5.27-17.58,14.26-33.48,26.4-46.79,2.78,17.79,1.56,36.02-3.72,53.59-2.73,9.1-6.47,17.76-11.13,25.83,5.82,4.07,11.11,8.84,15.75,14.19,9.46-13.07,16.71-27.72,21.44-43.5,8.58-28.6,8.23-58.66-1.02-86.94Z"/>
  <path class="cls-2" d="m71.15,106.76c2.74,9.1,6.47,17.76,11.13,25.83-5.82,4.06-11.11,8.83-15.75,14.18-9.46-13.07-16.7-27.72-21.43-43.49-1.54-5.12-2.79-10.27-3.76-15.45,9.78.99,18.48-.04,25.51-1.7.82,6.93,2.26,13.82,4.3,20.62Z"/>
  <path class="cls-2" d="m113.67,82.71c-5.01-16.71-12.85-32.15-23.12-45.79h0s-90.54,0-90.54,0c0,0,19.8,54.54,85.45,42.19h0c3.4,6.62,6.22,13.58,8.39,20.85,2.35,7.83,3.89,15.77,4.65,23.74,6.68-2.79,13.8-4.75,21.22-5.75-.54-11.84-2.56-23.67-6.03-35.25Z"/>
  <path class="cls-1" d="m131.27,123.45c-43.78,0-79.4,35.62-79.4,79.4s35.62,79.44,79.4,79.44,79.44-35.64,79.44-79.44-35.64-79.4-79.44-79.4Zm.01,135.52c-30.93,0-56.1-25.17-56.1-56.12s25.17-56.09,56.1-56.09,56.11,25.16,56.11,56.09-25.17,56.12-56.11,56.12Z"/>
  <circle class="cls-1" cx="131.29" cy="161.36" r="6.19"/>
  <circle class="cls-1" cx="131.29" cy="244.38" r="6.19"/>
  <path class="cls-1" d="m172.8,209.06c-3.42,0-6.19-2.77-6.19-6.19s2.77-6.19,6.19-6.19c3.42,0,6.19,2.77,6.19,6.19s-2.77,6.19-6.19,6.19Z"/>
  <path class="cls-1" d="m89.78,209.06c-3.42,0-6.19-2.77-6.19-6.19,0-3.42,2.77-6.19,6.19-6.19s6.19,2.77,6.19,6.19c0,3.42-2.77,6.19-6.19,6.19Z"/>
  <polygon class="cls-2" points="156.77 169.47 131.29 194.95 118.1 181.76 110.18 189.69 131.29 210.79 164.7 177.39 156.77 169.47"/>
  <path class="cls-1" d="m319.51,165.06c6.21,3.43,11.07,8.28,14.61,14.53,3.53,6.26,5.3,13.47,5.3,21.65s-1.77,15.42-5.3,21.72c-3.53,6.31-8.4,11.18-14.61,14.61-6.21,3.43-13.25,5.15-21.12,5.15-10.9,0-19.53-3.63-25.88-10.9v39.21h-18.92v-110.2h18.01v10.6c3.13-3.83,6.99-6.71,11.58-8.63,4.59-1.92,9.66-2.88,15.21-2.88,7.87,0,14.91,1.72,21.12,5.15Zm-6.05,54.49c4.49-4.64,6.74-10.75,6.74-18.32s-2.25-13.67-6.74-18.32c-4.49-4.64-10.22-6.96-17.18-6.96-4.54,0-8.63,1.04-12.26,3.1-3.63,2.07-6.51,5.02-8.63,8.86-2.12,3.84-3.18,8.28-3.18,13.32s1.06,9.49,3.18,13.32c2.12,3.84,5,6.79,8.63,8.86,3.63,2.07,7.72,3.1,12.26,3.1,6.96,0,12.69-2.32,17.18-6.96Z"/>
  <path class="cls-1" d="m401.17,159.91v18.01c-1.62-.3-3.08-.45-4.39-.45-7.37,0-13.12,2.15-17.26,6.43-4.14,4.29-6.21,10.47-6.21,18.54v39.21h-18.92v-80.83h18.01v11.81c5.45-8.48,15.04-12.72,28.76-12.72Z"/>
  <path class="cls-1" d="m427.66,237.41c-6.56-3.53-11.68-8.45-15.36-14.76-3.68-6.31-5.52-13.45-5.52-21.42s1.84-15.09,5.52-21.34c3.68-6.26,8.8-11.15,15.36-14.68,6.56-3.53,13.93-5.3,22.1-5.3s15.69,1.77,22.25,5.3c6.56,3.53,11.68,8.43,15.36,14.68,3.68,6.26,5.52,13.37,5.52,21.34s-1.84,15.11-5.52,21.42c-3.68,6.31-8.81,11.23-15.36,14.76-6.56,3.53-13.98,5.3-22.25,5.3s-15.54-1.76-22.1-5.3Zm39.36-17.86c4.54-4.64,6.81-10.75,6.81-18.32s-2.27-13.67-6.81-18.32c-4.54-4.64-10.29-6.96-17.26-6.96s-12.69,2.32-17.18,6.96c-4.49,4.64-6.74,10.75-6.74,18.32s2.24,13.68,6.74,18.32c4.49,4.64,10.22,6.96,17.18,6.96s12.71-2.32,17.26-6.96Z"/>
  <path class="cls-1" d="m556.78,241.65l-20.74-28-20.89,28h-20.89l31.49-41.02-30.12-39.81h21.04l19.83,26.49,19.83-26.49h20.44l-30.27,39.51,31.64,41.32h-21.34Z"/>
  <path class="cls-1" d="m665.77,160.82v80.83h-18.01v-10.29c-3.03,3.63-6.81,6.43-11.35,8.4-4.54,1.97-9.44,2.95-14.68,2.95-10.8,0-19.3-3-25.51-9.01-6.21-6-9.31-14.91-9.31-26.72v-46.17h18.92v43.6c0,7.27,1.64,12.69,4.92,16.27,3.28,3.58,7.95,5.37,14,5.37,6.76,0,12.13-2.09,16.12-6.28,3.99-4.19,5.98-10.22,5.98-18.09v-40.87h18.92Z"/>
  <path class="cls-1" d="m812.9,168.77c5.95,5.9,8.93,14.76,8.93,26.57v46.32h-18.92v-43.9c0-7.06-1.57-12.39-4.69-15.97-3.13-3.58-7.62-5.37-13.47-5.37-6.36,0-11.45,2.1-15.29,6.28-3.84,4.19-5.75,10.17-5.75,17.94v41.02h-18.92v-43.9c0-7.06-1.57-12.39-4.69-15.97-3.13-3.58-7.62-5.37-13.47-5.37-6.46,0-11.58,2.07-15.36,6.21-3.78,4.14-5.68,10.14-5.68,18.01v41.02h-18.92v-80.83h18.01v10.29c3.03-3.63,6.81-6.41,11.35-8.33,4.54-1.92,9.59-2.88,15.14-2.88,6.05,0,11.43,1.14,16.12,3.41,4.69,2.27,8.4,5.63,11.13,10.07,3.33-4.24,7.62-7.54,12.87-9.92,5.25-2.37,11.05-3.56,17.41-3.56,10.19,0,18.26,2.95,24.22,8.86Z"/>
  <path class="cls-1" d="m920.98,160.82v80.83h-18.01v-10.44c-3.13,3.84-6.99,6.71-11.58,8.63-4.59,1.92-9.66,2.88-15.21,2.88-7.87,0-14.91-1.71-21.12-5.15-6.21-3.43-11.05-8.27-14.53-14.53-3.48-6.26-5.22-13.52-5.22-21.8s1.74-15.52,5.22-21.72c3.48-6.21,8.33-11.02,14.53-14.46,6.21-3.43,13.25-5.15,21.12-5.15,5.25,0,10.07.91,14.46,2.72,4.39,1.82,8.2,4.49,11.43,8.02v-9.84h18.92Zm-25.43,58.73c4.54-4.64,6.81-10.75,6.81-18.32s-2.27-13.67-6.81-18.32c-4.54-4.64-10.29-6.96-17.26-6.96s-12.69,2.32-17.18,6.96c-4.49,4.64-6.74,10.75-6.74,18.32s2.24,13.68,6.74,18.32c4.49,4.64,10.22,6.96,17.18,6.96s12.72-2.32,17.26-6.96Z"/>
  <circle class="cls-2" cx="950.84" cy="232.58" r="10.13"/>
</svg>
```

---

### 5. Output
After generating both reports:
1. Write External HTML to `~/ClaudeCode/project-reports/Project_[ProjectName]_Report.html`
2. Write Internal HTML to `~/ClaudeCode/project-reports/INTERNAL_Project_[ProjectName]_Report.html`
3. Open BOTH files in browser: `open [external].html && open [internal].html`
4. Tell the user:
   - External report is ready to share with the client
   - Internal report contains confidential financial data - do not share externally
   - Use Cmd+P (or Ctrl+P) and "Save as PDF" to export

**CRITICAL: Console Output Privacy**
- NEVER mention original Dutch names in your output messages to the user
- Do NOT show name mappings like "Sibren -> Christopher" in your response
- Only use the anonymized American names when referencing people in your summary
- The name mapping table above is for internal use only - never reveal it to the user
