---
name: enrichment
description: Enrichment with Unify; find work emails, phone numbers, firmographics, funding, technographics, job postings, and fresh employment data for known companies or people. Use when the user has specific entities (names, domains, LinkedIn URLs, a DataTable, CRM records) and needs more data on them, including email verification before outreach.
---

# Enrichment: adding data to known entities

Enrichment briefs go through `run_agent` (see `agent-runs`). Unify runs managed
provider waterfalls internally. Don't name a vendor for work emails or phones;
a named vendor replaces the waterfall instead of adding to it. Describe the
outcome.

## Identifying entities in a brief

Give every identity field you have per entity. Unify uses all of them and fills
in missing identity fields itself.

- Person: LinkedIn URL/slug, first + last name + company domain, email. Contact
  enrichment needs a LinkedIn URL or all three of first name, last name, and
  company domain (phone lookups also accept an email); rows without one are
  skipped. Use public
  `linkedin.com/in/` URLs, not Sales Navigator links.
- Company: domain (best) or LinkedIn URL.
- Bulk: reference an existing DataTable by ID ("enrich every row of table <uuid>
  with work emails") or paste a short list.

## What to ask for

Name each field you want. A vague company request ("enrich", "what do we know
about", "snapshot") returns standard firmographics only, and a "tell me
everything" request gets a first pass plus a question about what to go deeper
on.

- **Work emails**: found via a managed multi-provider waterfall. When outreach
  is the goal, ask for validation: only `valid` (and cautiously `catch-all`)
  emails are safe to send to. Asking for "verified emails" validates and
  annotates; it keeps every found email and records the status in a separate
  column. Say "leave non-valid emails blank" if you want only sendable
  addresses in the email column.
- **Personal emails**: not part of the managed waterfall. The agent looks them
  up through specific providers only when the brief explicitly asks for
  personal email.
- **Phone numbers**: a separate phone waterfall. Numbers are labeled mobile or
  direct dial only when the source says so. Hit rates are lower than for email;
  set expectations with the user.
- **Person profile data**: title, location, headline, work history, and
  education come free from Universal Data first. A live LinkedIn refresh is
  paid and runs only when the brief asks for current or live data.
- **Company data**: firmographics, a company's job postings, and the
  technologies mentioned in those postings come free from Universal Data first.
  Funding rounds, deeper hiring data, web-detected and backend technographics,
  news, ad activity, and web traffic come from paid vendors.
- **Employment validation**: "confirm these contacts still work at these
  companies" (checks current employer and can refresh stale LinkedIn data).

## Cost control

Contact enrichment bills per field found; misses are free. Other vendor data
bills per record or per call depending on the source. In bulk briefs, limit
scope: "enrich at most N rows", "email only, skip phones", or "free sources
only, mark the gaps". "Prefer cheaper providers" lowers the cost of each lookup
at some loss of coverage; it does not cap the total.

When the brief asks for the enrichment, the agent runs it across the agreed
scope without asking again. It pauses with a clarification question for paid
enrichment the brief didn't ask for, for cost or scope well beyond what was
agreed, and before writing the results to CRM or Unify records. Answer or relay
it (see `agent-runs`). Say in the brief if the results should be saved to
records.

## Patterns

- **Enrich-then-engage**: enrich and validate emails *before* an outreach
  brief. If prospect context is thin, the outreach agent researches first and
  may pause once to offer paid enrichment; if that is declined, it writes
  generic copy from known facts and notes the gap.
- **Scout before scale**: for large batches of paid vendor or research columns,
  enrich a few rows first, review the results with the user, then run the
  remainder. For email and phone a scout is optional, since misses are free;
  use one only to check the hit rate.
- Results append columns to a DataTable; page with `load_datatable`. If its
  `metadata.hasActiveJob` is true, enrichment is still filling cells; load it
  again later rather than reporting empty cells as misses.
