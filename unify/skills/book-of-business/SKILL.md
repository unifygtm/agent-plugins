---
name: book-of-business
description: Book of Business in Unify, the set of accounts a seller works, and what the Unify agent can do with it - list, count, and filter the user's accounts, read and refresh saved account intel and account plans, and claim or release accounts. Use when the user says "my book", "my accounts", or "my territory", asks about an account's intel or plan, or before working recommended prospects, which come from the Book.
---

# Book of Business

A seller's **Book of Business** is the set of accounts they work in Unify. It
is the scope for account intel and for recommended prospects (see
`recommended-prospects`). Book work goes through `run_agent` (see
`agent-runs`); there are no direct Book tools.

## What it is

- Membership comes from the workspace's account policy (an assignment field
  synced from the CRM, minus excluded companies) or from accounts the seller
  added by hand in the app.
- It is a Unify scope, not the CRM owner field. "Accounts in my Book" and
  "accounts I own in Salesforce" can differ. Say "my Book of Business" in a
  brief when you mean the Book, and "accounts I own in the CRM" when you mean
  ownership.
- The agent only works with the signed-in user's own Book.

## What the agent can do

- **List, count, and filter**: "How many accounts are in my Book of Business?",
  "Which accounts in my Book have a closed-lost deal in the last year?", "Show
  my Book accounts with website visits this week as a DataTable." Book
  membership can be combined with CRM facts and Unify signals.
- **Read account intel**: Unify saves research and an account plan for each
  Book account, covering fit, timing, engagement history, the people who
  matter, and outreach angles. "Summarize the intel and account plan for Acme."
  Intel is a saved artifact, not live research, so ask for follow-up research
  when the user wants something newer.
- **Refresh intel**: only when the user asks to update it. A refresh writes a
  new version in the background and can be refused when intel is turned off
  or the workspace limit is reached.
- **Recommended prospects**: the ranked people to contact next across the
  Book. See `recommended-prospects`.
- **Claim or release an account**: in workspaces with Rules of Engagement, the
  user can claim an unassigned account, which moves it into their Book, or
  give one up. The agent asks for confirmation and can be blocked by policy;
  relay that and never confirm on the user's behalf. Enrolling a person or
  creating a task can also claim their account.

## When there is no Book

- **Not set up**: the agent says so. For a loose "my accounts" request it may
  fall back to CRM ownership and state that assumption; pass the assumption on
  to the user. Account intel and recommended prospects need a Book.
- **Unavailable**: the Book could not be read. That does not mean it is empty.
  Report the limitation and don't substitute CRM ownership.

The agent does not add accounts to a Book directly or set one up as part of a
read. Membership changes through claiming, the workspace's account policy, or
the Unify app.
