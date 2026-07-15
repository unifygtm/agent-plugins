---
name: unify
description: Unify; start here. Directory for working with Unify, the go-to-market platform for finding and engaging buyers. Maps every Unify skill, agent-runs (run any GTM task through the Unify agent and manage the poll/answer loop), data-tables (page through result rows), discovery (build company and people lists), enrichment (find emails, phones, firmographics), outreach (sequences, tasks, outbound copy), crm (Salesforce/HubSpot reads and writes). Read this first to answer "what can I do with Unify?"
---

# Unify

Unify is a go-to-market platform for sales reps: find companies and people, enrich
contact data, and engage prospects with email sequences and tasks, driven by
natural language.

## Interaction model

The Unify MCP server exposes a small tool set. Everything substantive is delegated
to Unify's hosted GTM agent, which has its own data sources, skills, and safety
gates; loader tools then read the artifacts a run references:

| Tool | Purpose |
|---|---|
| `run_agent` | Start the Unify agent on a natural-language task. Returns a `runId`. |
| `poll_agent` | Check a run: `PENDING`, `CLARIFICATION_NEEDED`, `READY`, `ERROR`. |
| `answer_question` | Answer clarifying questions and resume a paused run. |
| `read_agent_results` | Read a terminal run's answer. Its structured content carries the exact IDs the loaders below need. |
| `load_datatable` | Page through the rows of a DataTable version a run produced. |
| `load_list` | Metadata + member count for a List (no rows). |
| `load_mailbox_voice_profile` | Read-only state of a mailbox's voice-profile analysis. |
| `load_user_general_context` | Read an exact version of the user's saved company profile/context. |

You are the briefing layer: write clear task briefs, relay clarifying questions to
your user, and fetch results. Read `agent-runs` before your first run.

## Which skill for what

| You want to... | Skill |
|---|---|
| Install the plugin or fix auth | see `GETTING_STARTED.md` in the repo root |
| Run any Unify task and manage the run lifecycle | `agent-runs` |
| Build a list of companies or people | `discovery` |
| Find emails, phones, or company data for known entities | `enrichment` |
| Write and send outreach (sequences), manage rep tasks | `outreach` |
| Read or write Salesforce/HubSpot, save records, export lists | `crm` |
| Pull rows from a result table | `data-tables` |

## Vocabulary (use these terms in briefs and with users)

- **DataTable**: the durable artifact for any list-building or enrichment run; page it with `load_datatable`.
- **List**: a saved, named collection of records in the Unify app (distinct from a DataTable).
- **Sequence**: multi-step outreach. A **scaffold** is the reusable structure; a **preview** is generated per-prospect copy that does NOT send; email sends only after previews are approved and **enrolled**.
- **Persona**: a tenant-level set of job titles defining a buyer role.
- **Tasks**: one-off manual to-dos for a rep (calls, LinkedIn touches, action items).

## Cost model

Unify's proprietary **Universal Data** (1.1B+ people, 65M+ companies) and connected
**CRM** reads are free. Third-party data vendors charge credits per record returned.
The agent already minimizes spend, but state a budget in your brief when the user
cares ("cheapest sources only", "cap at 100 records", "up to N credits").

## Behavior

- Narrate briefly what you asked Unify to do and summarize outcomes; don't dump raw JSON.
- Runs are user- and workspace-scoped to the OAuth identity; you can only see runs and tables you created.
- Anything irreversible (sending email, CRM writes, deletes) happens only with explicit approval. Mirror that: never brief the agent to send or delete without your user asking.
