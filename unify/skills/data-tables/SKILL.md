---
name: data-tables
description: "Unify DataTables: page through the rows of result tables produced by Unify agent runs with load_datatable. Use when a run's final answer references a DataTable or table ID and you need the actual rows, columns, or metadata."
---

# Unify DataTables

DataTables are the durable artifact of list-building and enrichment runs. When
`read_agent_results` references a table, fetch it directly; don't start another
run just to see rows you already have.

> **Not the same as a List.** A DataTable is an **agent run** artifact, paged
> here with `load_datatable`. A List is a saved collection of Unify records,
> read with the public API tools `get_list` / `list_list_entries` (see `crm`).

## `load_datatable({ tableId, limit?, cursor? })`

- `tableId`: required; take it from the `DataTableView` item in the run
  result's structured content. The tool loads the table's current working
  version, so a table that later runs changed returns its latest rows.
- `limit`: rows per page, default 100, max 500.
- `cursor`: pass the previous page's `nextCursor` to continue.

Returns `{ metadata, columns, rows, nextCursor }`.

- `metadata`: `tableId`, `name`, `kind`, `versionId`, `currentWorkingVersionId`,
  `liveRowCount`, `hasActiveJob`, `activeJobKinds`, and timestamps.
- `columns`: column definitions; each row's `values` is keyed by column `key`.
- `rows`: each row has `id`, `values` (column key → JSON value), and, for
  AI-derived cells, `enrichmentMeta` with the reason and source URLs behind each
  value. Use it to answer "where did this value come from?"
- `nextCursor: null` means you have the last page.

## Paging pattern

1. First call with `tableId` (and a smaller `limit` if you only need a sample).
2. Loop while `nextCursor` is non-null, passing it as `cursor`.
3. For large tables, ask your user before pulling everything; summarize from the
   first page plus `metadata.liveRowCount` when that answers the question.

## Active jobs

`metadata.hasActiveJob: true` means jobs are still running on the table, so some
rows or cells may be missing or empty. `activeJobKinds` says which: `FILL` adds
rows (search tables), `MAP` fills cells on existing rows, and `RANK` selects
people from company rosters and writes them to the table. `ENRICH` is retired
and appears only on older tables. Tell the user the table is still filling, and
call `load_datatable` again later for the updated rows.

## Notes

- Tables are visible only to the user who owns them in the workspace; "DataTable
  not found" usually means a table from another user or session, not a bug.
- "Invalid DataTable cursor" → restart paging from the first page.
- To add data to an existing table (more columns, more rows), continue the run's
  thread (`run_agent({ prompt, threadId })`) or start a new brief that names the
  table ID, and describe the addition. Say whether to add columns to this table
  in place: for "find people at these companies" the agent otherwise creates a
  separate people table.
