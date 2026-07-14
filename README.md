# The Joseph Group — AI Implementation

A set of tools built to demonstrate and quantify the value of AI adoption for a property management company — covering sales efficiency, drive-by field intelligence, and an AI-powered quoting system.

---

## What's in here

### `/calculator`
**`index.html`** — Interactive ROI calculator. Open in any browser. Two-stream model:
- **Stream 1** — Sales efficiency via HubSpot, Fathom, and Calendly. Quantifies admin time recovered and new mandates closed.
- **Stream 2** — Drive-by field intelligence via employee-owned iPhone, Otter.ai, and Zapier. Quantifies time saved and sales leads surfaced from property inspections.

All inputs are adjustable via sliders. No backend required — fully self-contained HTML.

### `/proposal`
- **`JosephGroup_AI_Proposal.pptx`** — Full presentation deck covering the three-tier AI strategy (Lean, Enterprise, Build/R&D Division), ROI summary, and compensation close.
- **`JosephGroup_ProjectScope.docx`** — Project scope document for the AI-powered quoting system. Three-phase build: price bible prototype → historical data intelligence layer → full quote generator.

### `/assets`
- **`linkedin-graphic.html`** — LinkedIn post graphic showing desktop and mobile views of the calculator. Open in Chrome and screenshot to export as image.

---

## The quoting system (in progress)

Being built on top of:
- **Supabase** (PostgreSQL) — price bible database and historical job record store
- **Claude / OpenAI API** — AI classification and quote generation
- **n8n** — workflow automation (site walkthrough → quote output)
- **Next.js** — frontend dashboard and PDF generation

The price bible connects to 10 years of historical job records to produce quotes that reflect real outcomes — not just flat rates.

---

## Stack

| Tool | Purpose |
|------|---------|
| HubSpot Starter | CRM, pipeline, deal tracking |
| Fathom | AI notetaker for sales calls |
| Calendly | Scheduling automation |
| Otter.ai | Drive-by voice transcription |
| Zapier | CRM routing and automation |
| Supabase | Owned database (price bible + history) |
| Claude API | AI intelligence layer |
| n8n | Owned workflow automation |
| Vercel | Hosting and deployment |

---

## Built by
Michael M. · AI & Technology Implementation · Spring 2026
