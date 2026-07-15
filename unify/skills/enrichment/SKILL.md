---
name: enrichment
description: Enrichment with Unify; find work emails, phone numbers, firmographics, funding, technographics, job postings, and fresh employment data for known companies or people. Use when the user has specific entities (names, domains, LinkedIn URLs, a DataTable, CRM records) and needs more data on them, including email verification before outreach.
---

# Enrichment: adding data to known entities

Enrichment briefs go through `run_agent` (see `agent-runs`). Unify runs managed
provider waterfalls internally. Never ask it to use a specific email vendor;
describe the outcome.

## Identifying entities in a brief

Give the strongest identity keys you have, per entity:

- Person: LinkedIn URL/slug, or first + last name + company domain, or email.
- Company: domain (best), or LinkedIn URL, or exact name + disambiguator.
- Bulk: reference an existing DataTable by ID ("enrich every row of table <uuid>
  with work emails") or paste a short list.

## What to ask for

- **Work emails**: found via a managed multi-provider waterfall and returned with
  validation status. Only `valid` (and cautiously `catch-all`) emails are safe to
  send to; ask for "verified emails" when outreach is the goal. Personal email
  coverage is not offered.
- **Phone numbers**: mobile/direct dials via a phone waterfall; lower hit rates
  than email. Set expectations with the user.
- **Company data**: firmographics come free from Universal Data first; funding
  rounds, job postings/hiring intent, technographics (web-detectable and
  backend/inferred), news, ad activity, web traffic come from paid vendors.
- **Employment validation**: "confirm these contacts still work at these
  companies" (checks current employer and can refresh stale LinkedIn data).

## Cost control

Contact-data and vendor enrichment cost credits per record. In bulk briefs, state
a cap: "cap credit spend at N", "email only, skip phones", or "free sources only,
mark the gaps". Expect the agent to pause with a clarification question when a
brief implies large spend; answer or relay it (see `agent-runs`).

## Patterns

- **Enrich-then-engage**: enrich and verify emails *before* any outreach brief;
  the Unify agent itself refuses to write outreach on thin prospect context.
- **Scout before scale**: for 100+ rows, enrich 5 first, review the hit rate with
  the user, then run the remainder.
- Results append columns to a DataTable; page with `load_datatable`.
