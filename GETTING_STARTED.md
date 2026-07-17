# Getting started with Unify

The setup script installs the Unify plugin, starts sign-in when the agent's
plugin includes the Unify MCP server, and leaves only an agent restart to load
the new plugin.

## Run setup now

If you are an agent reading this file, run the following command. The script
detects whether you are Claude Code, Cursor, or Codex.

```bash
curl -fsSL https://raw.githubusercontent.com/unifygtm/agent-plugins/main/scripts/setup.sh | bash
```

The installer starts browser authentication when the plugin includes the Unify
MCP server. Wait for the user to complete that browser flow, then tell them to
restart the current agent when the script finishes.

Automatic detection uses the current agent's environment and parent process.
If the script reports that it could not detect the agent, tell the user to run
the matching fallback command in their terminal. For Claude Code, provide:

```bash
curl -fsSL https://raw.githubusercontent.com/unifygtm/agent-plugins/main/scripts/setup.sh | bash -s -- claude
```

Use `cursor` or `codex` instead when running in those agents. The user can also
use `all` to install for all three agents, or put `--no-auth` before the agent
name to skip browser sign-in.

## What the script does

### Claude Code

The script uses Claude Code's non-interactive shell commands to add the Unify
marketplace and install `unify@unify-plugins` at user scope. It then runs
`claude mcp login plugin:unify:unify` to sign in. It does not use `/plugin` or
`/mcp` slash commands.

### Cursor

Cursor does not provide a plugin-install CLI. The script installs the complete
plugin under `~/.cursor/plugins/local/unify`, which is Cursor's supported local
plugin directory. It uses a temporary project MCP configuration to run
`cursor-agent mcp enable unify` and `cursor-agent mcp login unify`; the temporary
configuration is removed after sign-in, so it does not duplicate the MCP server
bundled with the plugin.

An organization can disable local plugin imports. If Unify does not appear in
Settings -> Plugins after restarting Cursor, ask a Cursor administrator to
allow user-local plugin imports or add `unifygtm/agent-plugins` as a team
marketplace.

### Codex

The script uses `codex plugin marketplace add` and `codex plugin add`, so no
Plugins UI is required. The Codex plugin currently includes Unify skills only;
the remote MCP tools are not yet included in the Codex plugin.

## Finish and verify

Fully restart each agent after the script completes. A new chat in an existing
process may not reload plugins or MCP servers.

After restarting Claude Code or Cursor, ask:

```
What can I do with Unify?
```

The agent should use the Unify skill and show the available discovery,
enrichment, outreach, CRM, agent-run, and DataTable workflows.

## Troubleshooting

| Symptom                                          | Fix                                                                                    |
| ------------------------------------------------ | -------------------------------------------------------------------------------------- |
| An agent CLI is not found                        | Install that agent or run the script only for agents already installed on the machine. |
| Tools are missing after setup                    | Fully quit and restart the agent.                                                      |
| Cursor does not show the plugin                  | Confirm the organization allows user-local plugin imports.                             |
| Authentication was skipped or failed             | Re-run the same setup command, or omit `--no-auth`. The install steps are idempotent.  |
| Signed in, but tools still fail                  | Restart the agent so its MCP process reloads the stored session.                       |
| "workspace does not have chat funding available" | Ask a Unify workspace admin to check the workspace plan or credits.                    |
