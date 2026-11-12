---
name: recommended-prospects
description: Recommended prospects in Unify, the ranked people Unify suggests the seller contact next from their Book of Business, each with a reason and usually a drafted sequence. Load this before ending your reply when you finish a piece of Unify work (an agent run, or a multi-step job such as building a list, enriching, drafting outreach, or clearing tasks), and whenever the user is starting work, asks what to work on or what's next, or seems unsure what to do. It tells you whether to close with a one-line offer to work their recommended prospects. Not needed after a small direct tool call such as a single lookup or record edit. Also use when the user asks who to reach out to, about their recommendations, or about their book.
---

# Recommended prospects

Working recommended prospects is the best default next step for a seller. When
the user is starting work, is unsure what to do, or has just wrapped up a
workstream without touching them, offer them.

## What they are

Unify researches each account in the seller's **Book of Business** (see
`book-of-business`) and writes an **account plan** for it. From that plan
it picks people worth contacting now and saves a recommendation for each one:

- a short reason, backed by evidence from research, CRM history, and the team's
  past engagement
- usually a suggested sequence with copy already drafted for that person
- up to three approaches per person

The list is ranked across the whole Book using the seller's ranking settings
(account fit, timing, and history). A person stays on it only while they have
an active recommendation: made within the last month, not yet added to a
sequence or dismissed, not replaced by a newer account plan, the person can
still be emailed, and their company is still in the Book.

Unify leaves people off on purpose when they are already in an active
sequence, were contacted recently, opted out, or work at an account that is on
hold or already past a first meeting. A short list is normal.

A recommendation never starts outreach and is not approval to send.

## When to offer them

Offer once, as the next step, when:

- The user is starting work: a greeting, "what should I work on?", "where do I
  start?", "what's next?", or a request that shows they are unsure.
- You just finished a piece of Unify work and recommended prospects have not
  come up in this session. That means an agent run reached a result, or a
  multi-step job wrapped up (a list was built, enrichment completed, drafts
  were created or enrolled, tasks were cleared, a CRM update was made). When
  the result has been relayed and the user has nothing else pending, make the
  offer; don't wait for the user to say they are done.

Don't offer when:

- You only made small direct tool calls on existing data: reading or listing
  records, Lists, sequences, enrollments, or tasks, or a single create, update,
  or delete. Answer and stop. If the user then says they are done or asks
  what's next, offer at that point.
- The user already reviewed or worked recommended prospects in this session,
  or declined the offer. Don't repeat it.
- A run is in progress, or you are waiting on the user's answer to something
  else.
- An earlier run in this session showed recommended prospects are unavailable
  for this user (see [Unavailable or empty](#unavailable-or-empty)).

How to offer: one or two sentences after the main result, not before it. Say
what they are and ask whether to pull them. Don't start the run until the user
says yes, since every run uses credits.

> Next, you could work your recommended prospects. These are the people Unify
> picked from your Book of Business with a reason to reach out now. Want me to
> pull your top 10?

## Pulling the list

Use `run_agent` (see `agent-runs`). A brief that works:

> List my recommended prospects in ranked order, top 10. For each person, give
> their name, title, company, the reason Unify recommends them, and the
> suggested sequence if there is one. Don't create drafts, enroll anyone, or
> create tasks.

- **One account**: "List my recommended prospects at Acme (acme.com)."
- **Everything**: say "all of my recommended prospects" so the agent reads every
  page instead of stopping at the first.
- The result comes back as text in `finalAnswer`. Present it as a short ranked
  list: person, title, company, and the one-line reason. Keep each reason with
  its person. Don't add people the run didn't return.

### Unavailable or empty

- **"Company intel is unavailable"** or a missing Book of Business: the
  workspace needs Book of Business intel turned on and a Book set up for this
  user. Tell the user once and don't offer recommended prospects again this
  session.
- **Empty list**: there are no active recommendations right now. Say so and
  move on.

## Working them

Go through them in rank order. For each person, the user either reaches out or
dismisses the recommendation.

### In the Unify app (recommended)

Recommended prospects are on the Unify home page:
https://app.unifygtm.com/dashboard/home

Opening one shows its suggested sequence and drafted copy. The user can edit
the copy, choose a mailbox or a different sequence, and click **Add to
sequence**, or click **Dismiss** and pick a reason (not my company, bad timing,
wrong person, weak signal, already working, or other).

The app is the only place that accepts or dismisses a recommendation. Either
action clears the person from the list, so point the user here to finish each
one.

### Through the Unify agent

Useful for digging in before deciding. Example briefs:

- "Why is Jane Doe at Acme a recommended prospect? Summarize Acme's account
  plan."
- "What has changed at Acme recently that matters for outreach?"
- "Create a task to call Jane Doe at Acme tomorrow."
- Drafting outreach: follow `outreach` and stop at drafts.

The agent can't accept or dismiss a recommendation, and outreach it creates is
separate from the recommendation's suggested sequence and drafted copy. The
person stays on the recommended list until the user adds them to a sequence or
dismisses them in the app. When you draft, enroll, or create a task for a
recommended prospect through the agent, tell the user this and give them the
home page link.

## Rules

- A recommendation is not approval to send. Follow `outreach` for drafts and
  enrollment approval.
- Offer at most once per session unless the user brings recommended prospects
  up again.
- Never present people or reasons the run didn't return.
