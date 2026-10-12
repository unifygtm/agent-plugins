---
name: outreach
description: Outreach with Unify, create email sequences, generate per-prospect copy previews, enroll prospects, and manage rep tasks (calls, LinkedIn touches, to-dos). Use when the user wants to email prospects, write outbound copy, start or edit a sequence, check what's in flight, or work their task queue.
---

# Outreach: sequences and tasks

Outreach briefs go through `run_agent` (see `agent-runs`). Sequences have a strict
safety lifecycle. Use its vocabulary precisely with both the agent and your user.

> **Deterministic alternative.** For inspecting and managing existing sequences,
> enrollments, and tasks without the agent, use the tools under
> [Public API tools](#public-api-tools). They act as the signed-in user.

## Sequence lifecycle (safety-critical)

1. **Scaffold**, the reusable structure: steps (emails, calls, LinkedIn touches),
   delays, and copy prompts. Creating a scaffold sends nothing.
2. **Preview**: per-prospect generated copy. Still sends nothing.
3. **Approved**: previews are ready to be enrolled.
4. **Enrolled**: prospects are in the sequence and email actually sends.

Never tell your user someone is "enrolled", "started", or that anything "sent"
before step 4. Default briefs should end at previews: "create previews for these
10 people and stop for my review."

## Writing sequence briefs

Include: who (people, by DataTable ID, List, or identities), the offer/value
proposition and any proof points, desired tone and sender voice, step count and
channel mix (2–4 steps typical: email + LinkedIn + call), cadence ("3 days
between steps"), and the sending mailbox if the user has a preference. The Unify
agent is the copywriter: give it real context (why now, what triggered this,
what the prospect cares about), not template text. If prospect context is thin,
it will pause and ask to enrich first; that gate is correct. Relay it.

Per-prospect copy edits ("make the email to Jane mention their Series B") edit
that preview only; scaffold edits propagate to everyone. Say which you mean.

## Checking state

"What sequences do we have?", "who replied?", "how is sequence X performing?",
"which previews are waiting on my approval?" are all valid briefs.

## Tasks

Reps' one-off manual to-dos: calls, LinkedIn profile views/connects/messages,
action items. Useful briefs:

- "What tasks are due today?" / "what's overdue for me this week?" (defaults to
  the signed-in user; name a teammate to scope differently).
- "Create a task to call Jane Doe at Acme on Friday" (self-assigned, manual types
  only).
- "Complete/skip my ready LinkedIn tasks for Acme." Email-reply tasks are
  completed by actually replying, not by marking done.

## Mailbox voice profile

Unify can analyze a mailbox's sent mail to build a **voice profile** that
shapes generated copy. Read it with
`load_mailbox_voice_profile({ connectedMailboxId })`, taking the ID from the
`MailboxVoiceProfileView` item in the run result's structured content. It
returns `{ voiceProfile }` and is read-only. "Mailbox voice profile is
unavailable." means the analysis has not produced a profile yet, or the mailbox
is not one of the user's own; don't poll on it.

## Public API tools

- **Sequences**: `list_sequences` (filter by `name` substring) /
  `retrieve_sequence`, `list_sequence_steps` / `retrieve_sequence_step`,
  `pause_sequence` / `resume_sequence` (affects every enrollment in the
  sequence), and `delete_sequence`. The step tools read the latest published
  version and return `sequence_not_published` for a sequence that was never
  published; pass `include_draft: true` to read the newest draft instead.
- **Enrollments**: `list_sequence_enrollments` (filter by `sequence_id`,
  `person_id`, `mailbox_id`, `status`, or update time) / `get_sequence_enrollment`,
  `pause_sequence_enrollment` / `resume_sequence_enrollment`, and
  `delete_sequence_enrollment`, which cancels the enrollment and stops its
  remaining steps.
- **`create_sequence_enrollment` sends.** It enrolls a person directly in a
  published sequence and skips the preview and approval steps above, so call it
  only after the user explicitly approves enrolling that person. It needs
  `sequence_id`, `person_id`, and `mailbox_emails` (1–10 sending mailbox
  addresses; one is chosen at enrollment). Pass `allowed_concurrent_sequence_ids`
  only for other active sequences the user reviewed. Agentic sequences reject API
  enrollment ("This sequence cannot be enrolled through the API."); enroll those
  with a `run_agent` brief instead.
- **Tasks**: `list_tasks` (filter by `status`, `assigned_user_id`, `person_id`,
  or `person_email`) / `retrieve_task`, `create_task`, `update_task` (assignee,
  priority, or due date), `complete_task`, and `delete_task`. For "my tasks",
  get the user's ID from `get_me` and pass it as `assigned_user_id`.
  `create_task` takes a `person_id`, optional `priority` and `due_at`, and a
  `type`: `ACTION_ITEM`, `PHONE_CALL`,
  `LINKEDIN_SEND_MESSAGE`, `LINKEDIN_SEND_CONNECTION_REQUEST`, and
  `LINKEDIN_VIEW_PROFILE` take an optional `note_content`; `EMAIL` takes
  `mailbox_email`, `subject`, and `content`, and the email sends from that
  mailbox when the task is completed. Completing an email task, or a task that
  belongs to a sequence step, can send or advance the sequence, so only call
  `complete_task` on tasks the user asked you to complete.
- Ask the user before `delete_sequence`, `delete_sequence_enrollment`,
  `delete_task`, or `pause_sequence`.
- Large exports of enrollments or tasks go through the REST API's bulk query
  jobs, which are not MCP tools. Page through the `list_*` tools with `cursor` /
  `limit` instead.
