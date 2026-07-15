---
name: discovery
description: Discovery with Unify, building lists of companies or people from criteria - ICP filters, personas, lookalikes, hiring signals, technographics, local businesses, funding stage. Use when the user wants to find prospects, build a target-account or contact list, expand TAM, or ask "who should I sell to".
---

# Discovery: building lists

Discovery briefs go through `run_agent` (see `agent-runs` for the loop). The Unify
agent routes to sources itself; your job is a precise brief.

## Brief anatomy

State, in order:

1. **Entity type**: companies, people, or companies-then-people ("find 20 fintech
   companies, then 2–3 engineering leaders at each").
2. **Hard filters** (exact, verifiable): industry, headcount range, revenue,
   geography (defaults to US, always state it), funding stage, tech stack, hiring
   status.
3. **Semantic intent** (fuzzy, persona-level): "developer-tools buyers",
   "operators who own retention", natural-language titles. Unify's semantic search
   over its proprietary dataset handles these well; don't flatten them into rigid
   title lists yourself.
4. **Target count** and **deliverable**: "return N results as a DataTable".
5. **Exclusions**: existing customers, competitors, records already in the CRM or
   a List ("exclude companies already in our Salesforce").

## What Unify is good at (helps you scope)

- **Universal Data** (free, proprietary): identity, domain, LinkedIn, industry, geo,
  headcount, revenue, titles, work history, education (for 1.1B+ people and 65M+
  companies). Prefer briefs answerable here when budget matters.
- **Paid vendor signals** (credits per record): lookalike companies, hiring/job
  postings, technographics, ecommerce/store data, local businesses (Google
  Maps/Yelp), funding and venture data, web traffic/SEO, social buying signals.
- **Weak/absent**: normalized seniority levels, live ad spend detail; expect the
  agent to approximate or ask.

## Patterns

- **Scout before scale**: for big lists, first ask for 5–10 results to validate
  criteria with your user, then a follow-up run for the full list.
- **Lookalikes**: "find companies similar to acme.com, stripe.com" is a first-class
  ask.
- **Existing-data first**: "which of our CRM accounts match X" is a discovery brief
  too. Unify joins CRM with engagement/intent signals for free.
- Results land in a DataTable; page it with `load_datatable` and present a readable
  sample, not the whole dump.
