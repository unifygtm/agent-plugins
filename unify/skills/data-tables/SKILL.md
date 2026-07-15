---
name: data-tables
description: "Unify DataTables: page through the rows of result tables produced by Unify agent runs with load_datatable. Use when a run's final answer references a DataTable or table ID and you need the actual rows, columns, or metadata."
---

# Unify DataTables

DataTables are the durable artifact of list-building and enrichment runs. When
`read_agent_results` references a table, fetch it directly; don't start another
run just to see rows you already have.

## `load_datatable({ tableId, versionId, limit?, cursor? })`

- `tableId` + `versionId`: **both required**; take them from the DataTable
  reference in the run result's structured content. Loads pin an exact table
  version, so pages are consistent even if the table keeps changing.
- `limit`: rows per page, default 100.
- `cursor`: pass the previous page's `nextCursor` to continue; it is bound to
  the same table and version.

Returns `{ tableId, versionId, metadata, columns, rows, nextCursor }`. Each row
is a map of column key → JSON value. `nextCursor: null` means you have the last
page. `metadata.currentWorkingVersionId` tells you whether a newer working
version exists than the one you loaded.

## Paging pattern

1. First call with `tableId` + `versionId` (and a smaller `limit` if you only need a sample).
2. Loop while `nextCursor` is non-null, passing it as `cursor`.
3. For large tables, ask your user before pulling everything; summarize from the
   first page plus `metadata` row counts when that answers the question.

## Notes

- Tables are visible only to the user who owns them in the workspace; "DataTable
  not found" usually means a table from another user or session, not a bug.
  "DataTable version not found" means a stale `versionId`; re-read the run
  result (or ask the agent for the current version).
- "Invalid DataTable cursor" → restart paging from the first page.
- To add data to an existing table (more columns, more rows), start a new
  `run_agent` brief that names the table ID and describes the addition.
