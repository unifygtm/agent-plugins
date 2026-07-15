# Getting started with Unify

This guide installs the Unify plugin in your agent, connects the Unify MCP
server, signs you in, and verifies the tools work. The plugin is the same across
agents; only the install and sign-in steps differ.

**First, identify which agent you are running in**, then follow that section:

- **Claude Code**: Anthropic's CLI and IDE agent (uses `/plugin` and `/mcp` commands).
- **Cursor**: the Cursor editor (plugins under Customize, MCP under Settings).
- **Codex**: OpenAI's Codex agent (the `codex` CLI and Plugins UI).

## Claude Code

1. Install the plugin:

   ```
   /plugin marketplace add unifygtm/agent-plugins
   /plugin install unify@unify-plugins
   ```

   (or `claude plugin marketplace add unifygtm/agent-plugins && claude plugin install unify@unify-plugins`).

2. Connect and sign in: run `/mcp`, select the `unify` server, and choose
   **Authenticate**. A browser window opens; sign in with your Unify account and
   pick your workspace when prompted, then return to the agent.

3. Verify (see [Verify it works](#verify-it-works) below).

## Cursor

1. Install **Unify** from the plugin marketplace (Customize → Plugins). For local
   development, clone this repo into `~/.cursor/plugins/local/`.

2. Connect and sign in: open Settings → MCP, find `unify`, and click **Login**.
   Sign in with your Unify account and pick your workspace when prompted.

3. Verify (see [Verify it works](#verify-it-works) below).

## Codex

```
codex plugin marketplace add unifygtm/agent-plugins
```

Then install **unify** from the Plugins UI. The Codex plugin currently ships
**skills only**; the remote MCP server is not yet wired into it, so the Unify
agent tools are not available in Codex.

## Troubleshooting

| Symptom                                          | Fix                                                                                       |
| ------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| Tools missing entirely                           | Confirm the plugin installed, then restart the agent.                                     |
| Signed in, but tools still fail                  | Restart the agent session so it reconnects to the server.                                 |
| Auth errors after signing in                     | Sign in again, and be sure to select your Unify workspace when prompted.                  |
| "workspace does not have chat funding available" | Billing gate on your Unify workspace; ask a workspace admin to check the plan or credits. |
