---
name: bulk-apis
description: "Unify Bulk API: extract large datasets from your own Unify data with asynchronous query jobs. Covers object records, sequence enrollments, enrollment steps, tasks, and events via the create-job → poll → paginate-results loop, plus incremental (changed-since) sync. Use when the user wants to export, sync, or pull many rows deterministically from the Unify public API."
---

# Unify Bulk API (query jobs)

The Bulk API extracts large volumes of a workspace's **own Unify data** through
asynchronous _query jobs_: you create a job, poll it to completion, then page
through its results. It is part of Unify's deterministic **public API** — a
direct REST surface exposed as MCP tools — and is distinct from the hosted GTM
agent (`run_agent`). Reach for it when the user wants a faithful, repeatable
export or sync of records they already have.

**Bulk API vs. the agent vs. DataTables:**

| Want                                                                   | Use                                                                                                                 |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Export/sync every matching row from your Unify data, deterministically | **Bulk API** (this skill)                                                                                           |
| Find, research, enrich, or build a new list from criteria              | `run_agent` (see `agent-runs`)                                                                                      |
| Read rows a run already produced                                       | `load_datatable` (see `data-tables`)                                                                                |
| Read/write a handful of records synchronously                          | public-API record tools (`get_object_record`, `upsert_object_record`, `list_sequence_enrollments`, `list_tasks`, …) |

## The job lifecycle

Every bulk resource follows the same three-step loop:

1. **Create** — `create_<resource>_query_job(...)`. Returns
   `{ job_id, status: "IN_PROGRESS", expires_at }` immediately. The query runs
   server-side.
2. **Poll** — `get_<resource>_query_job({ job_id })`. Returns
   `{ job_id, status, total_rows, error_code, created_at, expires_at, canceled_at }`.
   Loop while `status` is `IN_PROGRESS`.
3. **Read results** — `get_<resource>_query_job_results({ job_id, page, page_size })`
   once `status` is `FINISHED`. Paginated; see below.

`status` is one of `IN_PROGRESS`, `FINISHED`, `FAILED`, `EXPIRED`, `CANCELED`.
Only `FINISHED` has results; on `FAILED` report `error_code`, on `EXPIRED` the
job aged out (re-create it), on `CANCELED` it was cancelled.

Treat polling as internal tool work — don't post user-facing messages for each
unchanged `IN_PROGRESS` check. Poll every few seconds and back off for large
jobs; only message the user on a terminal state or an actionable blocker.

Jobs expire at `expires_at`; fetch results before then or re-create the job.

## Reading results (pagination)

`get_<resource>_query_job_results` returns
`{ total, page, page_size, data }`:

- `page` is 1-based; `page_size` defaults per resource, **max 2,000** for these
  JSON responses.
- `total` is the full row count; loop `page` from 1 until `page * page_size >= total`.
- For very large exports, confirm with the user before pulling every page;
  summarize from page 1 plus `total` when that answers the question.

## Resources and their tools

| Resource             | Create                                      | Poll                                     | Results                                          | List jobs                                  | Cancel                                      |
| -------------------- | ------------------------------------------- | ---------------------------------------- | ------------------------------------------------ | ------------------------------------------ | ------------------------------------------- |
| Object records       | `create_object_record_query_job`            | `get_object_record_query_job`            | `get_object_record_query_job_results`            | `list_object_record_query_jobs`            | —                                           |
| Sequence enrollments | `create_sequence_enrollment_query_job`      | `get_sequence_enrollment_query_job`      | `get_sequence_enrollment_query_job_results`      | `list_sequence_enrollment_query_jobs`      | —                                           |
| Enrollment steps     | `create_sequence_enrollment_step_query_job` | `get_sequence_enrollment_step_query_job` | `get_sequence_enrollment_step_query_job_results` | `list_sequence_enrollment_step_query_jobs` | `cancel_sequence_enrollment_step_query_job` |
| Tasks                | `create_task_query_job`                     | `get_task_query_job`                     | `get_task_query_job_results`                     | `list_task_query_jobs`                     | —                                           |
| Events               | `create_event_query_job`                    | `get_event_query_job`                    | `get_event_query_job_results`                    | `list_event_query_jobs`                    | —                                           |

- `list_<resource>_query_jobs({ cursor, limit, status })` enumerates recent jobs
  (e.g. to resume or clean up); `limit` max 100, filter by job `status`.
- Only enrollment-step jobs currently expose a `cancel` tool. For the rest, let
  a job finish or expire.

## Query shapes

**Object records** are the richest case. Create with an `object_name` and a
`query`:

```
create_object_record_query_job({
  object_name: "company",
  query: {
    select: { name: true, domain: true, owner: { select: { email: true } } },
    where:  { industry: { equals: "Software" } },
    sort_by: { field: "updated_at", direction: "ASCENDING" },
    metadata: { updated_at: { gt: "2026-07-01T00:00:00Z" } }
  }
})
```

- `select` is **required**: each key is an attribute API name; `true` returns it,
  `{ select: … }` expands a single-reference attribute (nested **max 3 levels**,
  root included).
- `where` filters by attribute: `{ attr: { equals: value } }`, and nests through
  single-reference attributes.
- `metadata` filters on record `created_at` / `updated_at`; `sort_by` orders by
  `id` / `created_at` / `updated_at`.
- In **results**, `attributes` is _sparse_: a selected attribute whose value is
  null is omitted entirely, so a missing key means null — not "unselected".
  Timestamps have millisecond precision.

**Enrollments, enrollment steps, tasks, events** create with a single `filter`
object (no `object_name`, no `select`) describing which rows to return.

## Incremental (changed-since) sync

For object records, pair a `metadata` timestamp filter with the matching
`sort_by` to page through everything changed since a checkpoint:

1. First sync: `sort_by: { field: "updated_at", direction: "ASCENDING" }`, no
   lower bound (or from your epoch). Record the max `updated_at` you saw.
2. Next sync: `metadata: { updated_at: { gt: <last checkpoint> } }` with the
   same `sort_by`. Advance the checkpoint each run.

Use `gt`/`gte`/`lt`/`lte` for open-ended "changed since" cutoffs or closed
windows; at most one lower and one upper bound per filter.
