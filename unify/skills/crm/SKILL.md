---
name: crm
description: CRM and record management with Unify, read Salesforce/HubSpot (owners, stages, deals, custom fields, "what's in my CRM"), write CRM records, upsert companies/people into Unify, and export to Lists. Use when the user asks about CRM data, wants records saved or updated, or wants a result set exported to a List or their CRM.
---

# CRM and records

CRM briefs go through `run_agent` (see `agent-runs`). Unify connects to Salesforce
and HubSpot and also keeps its own canonical company/person records and Lists.

> **Deterministic alternative.** If the user wants exact, repeatable reads/writes
> of their **Unify objects, records, and Lists** (not Salesforce or HubSpot
> directly, and not a natural-language task), use the tools under
> [Public API tools](#public-api-tools). The agent briefs remain the path for
> CRM reads and writes, complex workflows, and anything needing reasoning.

## Reads (live)

CRM reads need a connected CRM on Unify's Pro plan (read-only) or Business plan
(read/write). With one connected, briefs like these work directly, and pure CRM
questions run live against the CRM:

- "Which of these accounts exist in our Salesforce, and who owns them?"
- "Open opportunities past stage 2 closing this quarter."
- "What picklist values does the deal-stage field have?"
- Joins with Unify signals: "CRM accounts with website intent this month that
  have no open opportunity." Which signals exist depends on the plan; website
  intent needs Business.

Include domains when asking whether companies exist in the CRM; the agent does
not treat a failed name match as proof a company is missing.

## Writes

CRM writes need the Business plan, a workspace setting that allows CRM writes
from chat, and permission on the connected CRM account; they run as that CRM
user. Writes search first, then create or update: companies match by domain,
people by email, and logged tasks and emails by subject and related records.
People land as Contacts or Leads depending on the workspace's integration
settings. Rules:

- The agent writes every value it has for a record. If only some fields should
  change, say exactly which.
- Search-first reduces duplicates but does not rule them out across separate
  runs, so don't resend a write brief just to retry; check the result first.
- Log activities too: "log this call/email against the contact in HubSpot." An
  activity needs a person to attach to.
- Deleting a Salesforce record or archiving a HubSpot object needs the user's
  explicit confirmation naming that record. Relay the agent's confirmation
  question rather than pre-authorizing it in the brief.
- HubSpot segments: the agent adds records only to manual or snapshot segments
  (not dynamic ones), and creates a new segment only when asked.

## Unify records and Lists

- **Save to Unify**: "save these companies/people as Unify records" commits
  right away and creates missing records. Companies need a domain; people need
  an email. To review first, ask the agent to preview which records are
  existing, new, duplicate, or invalid and to wait for an OK before saving.
- **Lists**: named, saved collections in the Unify app. "Export this DataTable to
  a List called Q3 targets." The agent checks counts (new, already in list,
  duplicates, invalid) and commits in the same run; ask for a preview only if
  the user wants to review first. Say whether creating brand-new records is
  allowed or the export should only link existing ones. Rows without a domain
  (companies) or email (people) come back invalid. The run result links
  the List; check it afterwards with `get_list` and `list_list_entries` (see
  `agent-runs` for getting the List ID).
- **Personas**: tenant-level title sets. "Update our 'economic buyer' persona to
  include VP Finance titles" is a valid brief; edits are versioned and reversible.

## Public API tools

- **Schema**: `list_objects` / `get_object` / `create_object` / `update_object`
  / `delete_object`; `list_object_attributes` / `get_object_attribute` /
  `create_object_attribute` / `update_object_attribute` /
  `delete_object_attribute`; and for `SELECT` / `MULTI_SELECT` attributes,
  `list_object_attribute_options` / `get_object_attribute_option` /
  `create_object_attribute_option` / `update_object_attribute_option` /
  `delete_object_attribute_option`. Objects and attributes are addressed by API
  name (`object_name`, `attribute_name`). Set `is_required` / `is_unique` when
  creating an attribute: `update_object_attribute` can only remove them (pass
  `false`), and custom attributes on standard objects cannot be required.
- **Records**: `get_object_record` / `create_object_record` /
  `update_object_record` / `delete_object_record` by record ID;
  `find_unique_object_record` to look one up by attribute values (returns `null`
  data on no match); `upsert_object_record` to create-or-update by a `match` on
  unique attributes. `create_object_record` returns a conflict when a unique
  value already exists, so prefer upsert for records that may exist. Writes take
  an optional `validation_mode`: `strict` (reject invalid or unknown attributes)
  or `ignore_invalid` (drop unknown attributes and invalid optional values).
- **Lists**: `list_lists` / `get_list` / `create_list` / `update_list` /
  `delete_list`; `list_list_entries` / `get_list_entry` / `add_list_entries` /
  `remove_list_entries`. A List holds records of one object, fixed at creation.
  Add or remove up to 100 records per call, by `{ id }` or by `{ match }` on
  unique attribute values. `add_list_entries` succeeds even when individual
  records cannot be added, so check each record's `status` (`added`,
  `already_in_list`, `record_not_found`, `object_mismatch`) and the summary
  counts. Removing entries or deleting a List does not delete the records.
- Ask the user before any `delete_*` call, and before changing an object's or
  attribute's definition, since those affect every record and user in the
  workspace.
- Large exports go through the REST API's bulk query jobs, which are not MCP
  tools. Page through `list_lists` and `list_list_entries` with `cursor` /
  `limit` instead.
