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
2. **Hard filters** (exact, verifiable): industry, headcount range, geography,
   funding stage, tech stack, hiring status. Always state geography: Universal
   Data is global with no default, while some funding and SEO sources lean US
   when it is unstated.
3. **Semantic intent** (fuzzy, persona-level): "developer-tools buyers",
   "operators who own retention", natural-language titles. Unify's semantic search
   handles these well; don't flatten them into rigid title lists yourself.
4. **Target count** and **deliverable**: "return N results as a DataTable". The
   agent returns fewer results rather than padding with weak matches.
5. **Exclusions**: existing customers, competitors, records already in the CRM or
   a List ("exclude companies already in our Salesforce").
6. **What the list is for**: if it will feed a sequence, say so and name the
   titles or seniorities that are hard requirements. People matched only by
   semantic search need the user's approval before outreach. If current
   employment must be confirmed, say so; Universal Data freshness filters do
   not detect job changes.

## What Unify is good at (helps you scope)

- **Universal Data** (no vendor charge): identity, domain, LinkedIn, industry,
  geo, headcount and employee growth, titles, seniority and department, work
  history, education, job postings, new hires and promotions (for 1.1B+ people
  and 65M+ companies). Prefer briefs answerable here when budget matters.
- **Paid vendor signals** (credits per record, per call, or per filled field
  depending on the source): lookalike companies, hiring velocity and
  job-description detail, technographics, ecommerce/store data, local
  businesses (Google Maps/Yelp), funding and venture data, web traffic/SEO,
  social buying signals, open-web research.
- **Weak/absent**: company revenue (not in Universal Data; use headcount for
  company size where you can), live ad spend (modeled estimates only), emails
  and phones (a separate enrichment step; see `enrichment`). Seniority is a
  coarse taxonomy, so list it as a hard filter only when it really is one.

## Patterns

- **Scout before scale**: the agent already scouts a few rows before scaling.
  For big lists where the user needs to validate the criteria first, ask for
  5–10 results, then start a follow-up run for the full list.
- **Lookalikes**: "find companies similar to acme.com, stripe.com" is a first-class
  ask; 3–5 seed companies work best.
- **Existing-data first**: "which of our CRM accounts match X" is a discovery brief
  too. Unify can join CRM records with engagement and intent signals (website
  visits, product usage, sequence engagement, G2 intent, List membership)
  without a vendor charge; which signals exist depends on the workspace's plan
  and connections. Saved **Audiences** (company or person sets, with workspace
  exclusions applied) and **Segments** (saved company filters, such as
  territories) can be named in a brief.
- **Accounts already in the book**: the agent can read Book of Business intel and
  recommended prospects for one company or across the user's accounts.
- **Warm intros**: "who do we know at X" finds introduction paths inferred from
  shared work history, education, and common investors, not LinkedIn
  connections.
- **Rules of Engagement**: when the workspace has an active policy, the agent
  checks each company before searching for people there and reports accounts
  assigned to another rep.
- Results land in a DataTable; page it with `load_datatable` and present a readable
  sample, not the whole dump.
