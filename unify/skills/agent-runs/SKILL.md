---
name: agent-runs
description: Run Unify agent tasks with the core run_agent → poll_agent → answer_question → read_agent_results loop, or as an MCP task on clients that support tasks. Use before starting any Unify run - covers writing effective task briefs, task results, polling cadence, relaying clarification questions, reading results, cancelling or finding runs, and error recovery.
---

# Running the Unify agent

Every Unify task is one lifecycle: start, wait for the outcome, (maybe) answer
questions, read. On clients that support MCP tasks the client does the waiting
(section 2); otherwise you poll (sections 3 to 5).

## 1. Start: `run_agent({ prompt })`

Returns one of two results: a task, on clients that support MCP tasks (section
2), or `{ runId, threadId, threadLink }` immediately. Write the prompt as a
brief to a skilled GTM operator who cannot see your conversation. Include:

- **Entity type and deliverable**: companies or people; inline answer or a DataTable ("return the results as a DataTable" for anything more than a couple of records).
- **Hard filters vs. intent**: exact constraints (industry, headcount, geography, funding stage, titles) separately from fuzzy persona intent ("technical buyers of data-infrastructure tooling"). Always state geography; not every source defaults to the same region.
- **Scale**: target count ("20 companies", "2–3 contacts per company").
- **Budget**: if spend matters: "prefer free sources (Universal Data, CRM)", "at most N records", or "email only, skip phones".
- **Approval semantics** for outreach: whether to stop at drafts or the user has approved enrolling/sending. Never authorize sending unless your user explicitly did.

Pre-answer the obvious clarification dimensions above; the agent pauses to ask
when scope is ambiguous or expensive.

**Show `threadLink` as soon as the run starts.** For a task, the link is in
the server note the client shows you when the task starts. The run happens in the
background on Unify's side, so the link is what lets the user watch it live —
intermediate steps, tool calls, and partial results stream into that thread while
you poll. Send one short message right after `run_agent` returns that says the
run is underway and includes the **bare URL** on its own line (most terminals and
plain-text clients auto-linkify a raw URL; Markdown link syntax only renders
where Markdown is supported). This is the one user-facing message to send before
a terminal status — everything else about polling stays internal.

`threadId` identifies the thread the agent ran in. Pass it back as
`run_agent({ prompt, threadId })` for a follow-up task that should build on the
same context (same thread, same link) instead of starting cold. Only threads
started through `run_agent` by the same user can be continued, and a thread runs
one task at a time: wait for the previous run to reach a terminal status (or
cancel it) before continuing the thread.

## 2. Task results (clients that support MCP tasks)

On clients that support the MCP tasks extension, such as Claude Code in an
interactive session, `run_agent` returns a task instead of
`{ runId, threadId, threadLink }`. The client polls the task itself and hands
you its result as the tool result when the task ends.

- **At start**, the client shows you a note from the server with the run ID and
  `threadLink`. Send the user the link as described above. Do not call
  `poll_agent` or `read_agent_results` for this run while the task is running:
  the client is already waiting on it, and polling can reopen a question dialog
  the user dismissed.
- **Questions**: in an interactive session the client shows the agent's
  questions in a dialog, and the run continues once the user answers. Nothing
  else is needed.
- **The result** is one of:
  - The `read_agent_results` payload (`status` `READY` or `ERROR`,
    `finalAnswer`, `content`, `errorMessage`, `threadLink`). Handle it as in
    section 5.
  - `{ runId, status: "CLARIFICATION_NEEDED", questions }`: the questions were
    not answered in a dialog, because the user dismissed it or the client
    cannot show one. Answer them with `answer_question` as in section 4, then
    poll the resumed run with `poll_agent` and read it as in section 5.
- **Cancelled while waiting on questions**: the user can stop a task from the
  client. If the status message says the run is paused on questions and lists
  them, the run is still waiting: answer with `answer_question` and poll as
  above, or call `cancel_agent` if the user wants the run stopped. A task
  stopped while the run was working means the run was canceled.

Which result you get is decided per call, and a task that ended stays ended:
nothing more arrives for it after the run resumes. When `run_agent` returns
`{ runId, threadId, threadLink }`, or after you answer a task's questions, use
the loop in sections 3 to 5.

## 3. Poll: `poll_agent({ runId })`

Statuses: `PENDING` (keep polling), `CLARIFICATION_NEEDED`, `READY`, `ERROR`,
`NOT_FOUND` (no run with that ID for this user). Runs commonly take one to
several minutes; poll every ~10 seconds initially and back off toward ~30
seconds for long runs. Don't give up; complex list-building runs can run 10+
minutes.
Treat polling as internal tool work. Do not send user-facing messages that
merely announce polling attempts, waits, cadence changes, or unchanged `PENDING`
statuses. Beyond the initial "run started, here's the link" message, only message
the user when input is required, the run reaches a terminal state, or an
actionable blocker occurs.

## 4. Clarifications: `answer_question({ runId, answers })`

On clients that support MCP form elicitation, `poll_agent` may show the agent's
questions to the user in a dialog, resume the run with their answers, and
return `PENDING`. Nothing else is needed; keep polling.

`CLARIFICATION_NEEDED` means the user did not answer that way (the client has
no dialog support, or the user dismissed it). `poll_agent` returns `questions`
(up to 4, each with 2–4 options that have a `label` and `description`). Stop
polling, since another poll can re-open a dialog the user already dismissed,
and answer with `answer_question`. Rules:

- Answer every question in one call, in the same order, with `question` copied
  **exactly** as returned; the server rejects mismatches.
- `answer` may be an option label or free text.
- If your conversation already contains the answer, answer directly; otherwise
  present the questions and options to your user verbatim and relay their choices.
- Response is `{ runId, alreadyResuming }`; keep polling either way. If the call
  fails with a retryable message, retry with the same answers.
- If `poll_agent` itself fails with "Failed to resume the run with the user's
  answers", call `answer_question` with the answers quoted in that message.

## 5. Read: `read_agent_results({ runId })`

Only for `READY` or `ERROR` runs you polled with `poll_agent`. A task that
finishes with the run's outcome delivers this payload as its result, so do not
read that run again. Returns
`{ status, finalAnswer, content, errorMessage, threadLink }`.
`finalAnswer` is plain text. `content` is an array of typed items, and the
`resource` items carry the exact IDs the loader tools need. Take IDs from there
rather than parsing them out of the prose:

| `componentType`           | IDs                                     | Read with                                                       |
| ------------------------- | --------------------------------------- | --------------------------------------------------------------- |
| `DataTableView`           | `tableId`, `versionId`                  | `load_datatable({ tableId })`                                   |
| `MailboxVoiceProfileView` | `connectedMailboxId`                    | `load_mailbox_voice_profile`                                    |
| `UserGeneralContextView`  | `userGeneralContextId`, `versionId`     | `load_general_context({ generalContextId: userGeneralContextId, versionId })` |
| `SequenceView`            | `sequenceId`                            | `retrieve_sequence({ id })`, `list_sequence_steps({ id })`      |
| `SequenceEnrollmentsView` | `sequenceId`, `sequenceExecutionIds`    | `get_sequence_enrollment({ id })` per enrollment ID             |

Other `resource` items (Tasks tables, Audiences, exclusions) have no loader
tool; describe them from `finalAnswer` and point the user to the thread link.

Other item types:

- `text`: prose segments. A List the run created or found arrives as a `text`
  item reading "Open the List in Unify: <url>"; the List ID is the last path
  segment of that URL, for `get_list` / `list_list_entries`.
- `action` (`requiresUserInteraction: true`, with a `url`): something only the
  user can do in the Unify app, such as connecting a CRM or mailbox or changing
  CRM workspace settings. Show the URL and say what it is for.
- `content`: inline presentation such as charts or suggested next actions.
  Summarize it in your own words when it helps the user.

`threadLink` is the same clickable thread URL `run_agent` returned, and comes
back for both `READY` and `ERROR` runs. Present it again after relaying results
so the user can inspect the full thread, intermediate steps, and any generated
resources in the UI.

**The result is the response; the link is only supporting context.** Never send
only the thread link or make the user open it to learn the outcome. Lead with
the substantive `finalAnswer` (or a faithful summary when it is long), include
the useful records or resource details you loaded, and state errors plainly.
Put the link last in a short, visually de-emphasized footer such as:

> Run details: <threadLink>

Keep the bare URL visible so terminals and plain-text clients can auto-link it.
In clients known to support inline HTML, `<sub>Run details: <threadLink></sub>`
is also acceptable, but do not rely on font sizing or hide the URL behind
Markdown link text.

## 6. Cancel: `cancel_agent({ runId })`

Stops an in-flight run, including one paused on a clarification. Use it when
the user asks to stop, or when a brief turned out to be wrong and you are about
to start a corrected one. Returns `{ runId, outcome }`: `CANCELED`, or
`ALREADY_TERMINAL` when the run had already finished. Once cancellation
completes, `poll_agent` reports `ERROR` and `read_agent_results` returns an
`ERROR` result. Some runs are non-cancellable and return an error. Stopping a
task in the client cancels a working run but leaves a run that is waiting on
questions paused; call `cancel_agent` to stop that run.

## 7. Find runs: `list_agent_runs({ status?, limit?, cursor? })`

Lists the user's `run_agent` runs, newest first. Each entry has `runId`,
`threadId`, `threadLink`, `threadTitle`, `status`, and `startedAt`. Use it to
recover a run from an earlier session or to check what is still running.
`status` here is the raw run status (`PENDING`, `STREAMING`, `PAUSED`,
`COMPLETED`, `FAILED`, `CANCELED`), not the `poll_agent` status; filter on it to
narrow the list, then call `poll_agent` on an active run for its current state.
`limit` defaults to 50 (max 100); pass `nextCursor` as `cursor` for the next
page.

## Errors

- "The workspace does not have chat funding available" → billing gate; surface to the user.
- Rate-limit errors → wait and retry `run_agent` once; don't hammer.
- "Failed to start agent run." → retry `run_agent` once.
- "Agent thread not found." or "The provided thread cannot be reused by run_agent." → start a new thread by omitting `threadId`.
- `ERROR` status → read `errorMessage`, report it plainly; a fresh, more specific brief often succeeds where a vague one failed.
- Runs are visible only to the user who created them. Use `list_agent_runs` to find runIds from this user's earlier sessions; runs from other users are not accessible.
