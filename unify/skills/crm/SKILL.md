---
name: crm
description: CRM and record management with Unify, read Salesforce/HubSpot (owners, stages, deals, custom fields, "what's in my CRM"), write CRM records, upsert companies/people into Unify, and export to Lists. Use when the user asks about CRM data, wants records saved or updated, or wants a result set exported to a List or their CRM.
---

# CRM and records

CRM briefs go through `run_agent` (see `agent-runs`). Unify connects to Salesforce
and HubSpot and also keeps its own canonical company/person records and Lists.

> **Deterministic alternative.** If the user wants exact, repeatable reads/writes
> of their **Unify objects and records** — not a natural-language task — the
> public API exposes direct tools: `list_objects` / `get_object` and their
> attributes, `get_object_record` / `create_object_record` / `update_object_record`
> / `upsert_object_record` / `find_unique_object_record` / `delete_object_record`,
> and the async **Bulk API** for exporting or syncing many records at once (see
> `bulk-apis`). The agent briefs below remain the path for
> complex workflows and anything needing reasoning.

## Reads (free, live)

If the workspace has a connected CRM, briefs like these work directly:

- "Which of these accounts exist in our Salesforce, and who owns them?"
- "Open opportunities past stage 2 closing this quarter."
- "What picklist values does the deal-stage field have?"
- Joins with Unify signals are free too: "CRM accounts with website intent this
  month that have no open opportunity."

If the agent reports the CRM isn't connected or needs re-auth, direct the user to
the Unify app's connector settings.

## Writes (gated: confirm first)

CRM writes are available on Unify's Business plan and behave as
search-then-create-or-update (matching by domain, email, or record ID; the agent
handles dedupe). Rules:

- Only brief a CRM write your user explicitly requested, and echo back exactly
  what will be written before running it.
- Never brief a delete or archive without the user naming the specific records.
- Log activities too: "log this call/email against the contact in HubSpot."

## Unify records and Lists

- **Save to Unify**: "save these companies/people as Unify records." Companies
  need a domain; people need an email. The agent previews EXISTING/NEW/INVALID
  classifications before committing.
- **Lists**: named, saved collections in the Unify app. "Export this DataTable to
  a List called Q3 targets" (the export previews counts: new, already in list,
  duplicates, invalid) before committing. Say whether creating brand-new records
  is allowed or the export should only link existing ones. To verify a List after
  a run, call `load_list({ listId })` directly (ID from the run result's
  structured content). It returns name, owner, member count, and app URL, but
  intentionally not the members themselves.
- **Personas**: tenant-level title sets. "Update our 'economic buyer' persona to
  include VP Finance titles" is a valid brief; edits are versioned and reversible.
