---
name: outreach
description: Outreach with Unify, create email sequences, generate per-prospect copy previews, approve and enroll prospects, and manage rep tasks (calls, LinkedIn touches, to-dos). Use when the user wants to email prospects, write outbound copy, start or edit a sequence, check what's in flight, or work their task queue. Nothing sends without explicit approval.
---

# Outreach: sequences and tasks

Outreach briefs go through `run_agent` (see `agent-runs`). Sequences have a strict
safety lifecycle. Use its vocabulary precisely with both the agent and your user.

## Sequence lifecycle (safety-critical)

1. **Scaffold**, the reusable structure: steps (emails, calls, LinkedIn touches),
   delays, and copy prompts. Creating a scaffold sends nothing.
2. **Preview**: per-prospect generated copy. Still sends nothing.
3. **Approved**: a human reviewed the previews.
4. **Enrolled**: prospects are in the sequence and email actually sends.

Never tell your user someone is "enrolled", "started", or that anything "sent"
before step 4. Never brief the agent to enroll/send unless your user explicitly
approved it; default briefs should end at previews: "create previews for these
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

## Mailbox readiness

Sending requires a connected mailbox. If the agent reports the mailbox isn't
ready or needs OAuth, direct the user to connect their mailbox in the Unify app,
then resume.

Unify can also analyze a mailbox's sent mail to build a **voice profile** that
shapes generated copy. When a run kicks that analysis off, check progress with
`load_mailbox_voice_profile({ connectedMailboxId })` (ID from the run result's
structured content), poll only while `isTerminal` is false; it's read-only.
