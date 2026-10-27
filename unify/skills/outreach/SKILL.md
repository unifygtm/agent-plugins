---
name: outreach
description: Outreach with Unify, create email sequences, generate per-prospect drafts, enroll prospects, and manage rep tasks (calls, LinkedIn touches, to-dos). Use when the user wants to email prospects, write outbound copy, start or edit a sequence, check what's in flight, or work their task queue.
---

# Outreach: sequences and tasks

Outreach briefs go through `run_agent` (see `agent-runs`). Sequences have a strict
safety lifecycle. Use its vocabulary precisely with both the agent and your user.

> **Deterministic alternative.** For inspecting and managing existing sequences,
> enrollments, and tasks without the agent, use the tools under
> [Public API tools](#public-api-tools). They act as the signed-in user.

## Sequence lifecycle (safety-critical)

A sequence is either **AI-personalized** (agentic: AI writes copy for each
person) or a **fixed template** (standard: the same copy with fields like name
and company filled in). The mode is chosen at creation and can't be switched
later, so state it in the brief.

1. **Sequence (template)**: the reusable steps (emails, calls, LinkedIn
   touches), delays, and drafting prompts. Creating or editing one sends
   nothing. A step **preview** is sample copy on the template, not anyone's
   email.
2. **Drafts** (AI-personalized sequences only): per-person generated copy.
   Nothing sends.
3. **Enrolled / started sending**: the person is in the sequence and email
   actually sends. In some workspaces drafts are first marked **approved**,
   which still sends nothing; in others the user selects drafts and enrolls
   them directly.

Adding people to an AI-personalized sequence always stops at drafts, even if
the brief says "send" or "start". Starting them takes a later message in the
same thread (`run_agent({ prompt, threadId })`) after the user has seen the
drafts and explicitly said to start sending; "looks good" is not enough.
Adding people to a fixed-template sequence starts it right away with no draft
step, so get the user's explicit OK first.

Never tell your user someone is "enrolled", "started", or that anything "sent"
before step 3. Default briefs should end at drafts: "create drafts for these 10
people in <sequence> and stop for my review."

## Writing sequence briefs

Include: who (people, by DataTable ID, List, or identities), the offer/value
proposition and any proof points, desired tone, the step count and order, the
channels (automatic or manual email, LinkedIn, calls), and the cadence. Fewer
steps are fine; say "you choose" if the user has no preference, otherwise the
agent asks one bundled question about structure. Name the sender if the user
has no connected mailbox of their own: a mailbox email address, a teammate's or
shared mailbox, or a mailbox group. Without one, the agent stops to have the
user connect a mailbox before writing copy.

The Unify agent is the copywriter, and it treats what the brief says as the
user's decisions. Give it real context (why now, what triggered this, what the
prospect cares about), and quote any wording the user approved so it is kept
as written. Describe personalization in words, not with `{{merge}}`
placeholders; AI-personalized sequences never use them.

If prospect context is thin, the agent tries free research first, then may
pause once for the group to name who is missing what and recommend paid
enrichment. If the user declines, it writes generic copy from known facts and
notes the gap. Relay that question. Naming people to add also lets the agent
find a missing work email and create or update their record, which can spend
credits.

Per-prospect copy edits ("make the email to Jane mention their Series B") edit
that person's draft only. A sequence edit is published right away and applied
to every pending draft; people already enrolled keep their copy unless the
brief asks to update them too. Sent steps can't be edited. Say which you mean.

**Rules of Engagement**: when the workspace has an active policy, enrollment
and task creation can be blocked per person. A soft block needs the user's
confirmation, which the agent asks for; an approval-required block needs a
different workspace admin to approve; a hard block can't be overridden. Relay
these to the user and never confirm on their behalf. Enrolling or creating a
task can also claim an unassigned account for the user.

## Checking state

"What sequences do we have?", "who replied?", "how is sequence X performing?",
"which drafts are waiting for my review?" are all valid briefs.

## Tasks

A rep's task queue holds sequence steps (calls, LinkedIn touches, emails,
replies) and one-off tasks. Useful briefs:

- "What tasks are due for me today?" / "what's overdue for me this week?" Say
  "my" to scope to the signed-in user; an unscoped question returns every task
  the user can see, which for an admin is the whole team. Name a teammate to
  scope to them.
- "Create a task to call Jane Doe at Acme on Friday." The agent creates one-off
  tasks assigned to the signed-in user: action items, calls, LinkedIn tasks, or
  an email task, which is saved as a draft for the user to send later.
- "Complete/skip my ready LinkedIn tasks for Acme." The agent can't complete
  email or reply-to-email tasks, since that means sending, but it can skip
  them; for reply tasks, say why (for example "already replied on LinkedIn").
- Changing a task's priority, due date, or assignee is admin-only. The agent
  doesn't snooze or delete tasks.

## Mailbox voice profile

Generated copy uses the requesting user's writing voice; name a teammate in the
brief to write in theirs. Unify builds the **voice profile** from a Gmail or
Outlook mailbox's sent mail. The run result includes a `MailboxVoiceProfileView`
item only when the brief explicitly asks to show or analyze the user's voice.
Read it with `load_mailbox_voice_profile({ connectedMailboxId })`, taking the ID
from that item. It returns `{ voiceProfile }` and is read-only. "Mailbox voice
profile is unavailable." means the analysis has not produced a profile yet, or
the mailbox is not one of the user's own; don't poll on it.

## Public API tools

- **Sequences**: `list_sequences` (filter by `name` substring) /
  `retrieve_sequence`, `list_sequence_steps` / `retrieve_sequence_step`,
  `pause_sequence` / `resume_sequence` (affects every enrollment in the
  sequence), and `delete_sequence`. A sequence's `type` is `STANDARD` (sends
  the copy written on its steps) or `AGENTIC` (generates copy per person at
  enrollment). The step tools read the latest published
  version and return `sequence_not_published` for a sequence that was never
  published; pass `include_draft: true` to read the newest draft instead.
- **Enrollments**: `list_sequence_enrollments` (filter by `sequence_id`,
  `person_id`, `mailbox_id`, `enrolled_by_play_id`, `status`, or update time) /
  `get_sequence_enrollment`, `pause_sequence_enrollment` /
  `resume_sequence_enrollment`, and `delete_sequence_enrollment`, which cancels
  the enrollment and stops its remaining steps. A draft waiting for approval is
  `IN_PROGRESS` with `is_draft_approval_pending: true`; the `DRAFT` status is
  deprecated and matches nothing.
- **`create_sequence_enrollment` can start sending.** Call it only after the
  user explicitly approves enrolling that person. It needs `sequence_id`,
  `person_id`, and `mailbox_emails` (1–10 sending mailbox addresses; one is
  chosen at enrollment). Pass `allowed_concurrent_sequence_ids` only for other
  active sequences the user reviewed. A forbidden error means the workspace's
  Rules of Engagement block this user from contacting the person. What it
  returns depends on the sequence `type`:
  - `STANDARD`: the enrollment itself. It starts right away with no draft or
    approval step.
  - `AGENTIC`: an enrollment generation, because copy is written for the person
    first. Poll `get_sequence_enrollment_generation({ id })` until `status` is
    `COMPLETED` and take its `enrollment_id`; `FAILED` comes with a
    `failure_reason` such as `PERSON_ALREADY_ENROLLED`,
    `RULES_OF_ENGAGEMENT_BLOCKED`, or `OUT_OF_CREDITS`. The enrollment then
    waits as a draft until approved. Leave `is_draft_approval_required` at its
    default `true` unless the user said to send without review.
- **Drafts and per-person copy**: `list_sequence_enrollment_steps({ id })`
  returns an enrollment's steps in order, with the current email copy on email
  steps; `get_sequence_enrollment_step({ id })` reads one step.
  `update_sequence_enrollment_step` edits an unsent email step's `subject`,
  `fallback_subject`, or HTML `body` for that one person. Subjects can change
  only on the first email of a thread (`is_root_message`). Pass the
  `version_id` you read so the edit fails with a conflict if the copy changed
  since; it also conflicts once the step has finished or the enrollment has
  ended. `approve_sequence_enrollment({ id })` starts sending a draft, so call
  it only for drafts the user approved.
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
  `delete_task`, `pause_sequence`, or `approve_sequence_enrollment`.
- Large exports of enrollments or tasks go through the REST API's bulk query
  jobs, which are not MCP tools. Page through the `list_*` tools with `cursor` /
  `limit` instead.
