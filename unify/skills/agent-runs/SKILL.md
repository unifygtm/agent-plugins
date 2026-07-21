---
name: agent-runs
description: Run Unify agent tasks with the core run_agent → poll_agent → answer_question → read_agent_results loop. Use before starting any Unify run - covers writing effective task briefs, polling cadence, relaying clarification questions, reading results, and error recovery.
---

# Running the Unify agent

Every Unify task is one lifecycle: start, poll, (maybe) answer questions, read.

## 1. Start: `run_agent({ prompt })`

Returns `{ runId }` immediately. Write the prompt as a brief to a skilled GTM
operator who cannot see your conversation. Include:

- **Entity type and deliverable**: companies or people; inline answer or a DataTable ("return the results as a DataTable" for anything more than a couple of records).
- **Hard filters vs. intent**: exact constraints (industry, headcount, geography, funding stage, titles) separately from fuzzy persona intent ("technical buyers of data-infrastructure tooling"). Geography defaults to US, so say otherwise explicitly.
- **Scale**: target count ("20 companies", "2–3 contacts per company").
- **Budget**: if spend matters: "prefer free sources (Universal Data, CRM)" or "cap credit spend at N".
- **Approval semantics** for outreach: whether to stop at previews or the user has approved enrolling/sending. Never authorize sending unless your user explicitly did.

Pre-answer the obvious clarification dimensions above; the agent pauses to ask
when scope is ambiguous or expensive.

## 2. Poll: `poll_agent({ runId })`

Statuses: `PENDING` (keep polling), `CLARIFICATION_NEEDED`, `READY`, `ERROR`,
`NOT_FOUND`. Runs commonly take one to several minutes; poll every ~10 seconds
initially and back off toward ~30 seconds for long runs. Don't give up; complex
list-building runs can run 10+ minutes.
Treat polling as internal tool work. Do not send user-facing messages that
merely announce polling attempts, waits, cadence changes, or unchanged `PENDING`
statuses. Only message the user when input is required, the run reaches a
terminal state, or an actionable blocker occurs.

## 3. Clarifications: `answer_question({ runId, answers })`

On `CLARIFICATION_NEEDED`, `poll_agent` returns `questions` (up to 4, each with
2–4 options). Rules:

- Answer every question in one call, in the same order, with `question` copied
  **exactly** as returned; the server rejects mismatches.
- `answer` may be an option label or free text.
- If your conversation already contains the answer, answer directly; otherwise
  present the questions and options to your user verbatim and relay their choices.
- Response is `{ runId, alreadyResuming }`; keep polling either way. If the call
  fails with a retryable message, retry with the same answers.

## 4. Read: `read_agent_results({ runId })`

Only for `READY` or `ERROR` runs. Returns `{ status, finalAnswer, errorMessage }`.
`finalAnswer` is plain text. The result's **structured content** carries typed
resource references with the exact IDs the loader tools require. A DataTable
reference includes `tableId` + `versionId` (both needed by `load_datatable`), a
List reference includes its `listId` (for `load_list`), and so on. Take IDs from
there rather than parsing them out of the prose.

## Errors

- "workspace does not have chat funding available" → billing gate; surface to the user.
- Rate-limit errors → wait and retry `run_agent` once; don't hammer.
- `ERROR` status → read `errorMessage`, report it plainly; a fresh, more specific brief often succeeds where a vague one failed.
- Runs are visible only to the user who created them; don't ask about runIds from other sessions or users.
