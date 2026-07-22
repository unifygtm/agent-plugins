# Getting started with Unify

The setup script installs the Unify plugin non-interactively, then hands you an
interactive sign-in command when the agent's plugin includes the Unify MCP
server, and leaves only an agent restart to load the new plugin.

## Run setup now

If you are a terminal based agent reading this file, run the following command. The script
detects whether you are Claude Code, Cursor, or Codex.

```bash
curl -fsSL https://raw.githubusercontent.com/unifygtm/agent-plugins/main/scripts/setup.sh | bash
```

Browser sign-in needs a real interactive terminal (TTY), which a piped
`curl … | bash` does not provide (stdin is the script, not a keyboard). So the
installer runs the install steps non-interactively and does not attempt to sign
in. When the plugin includes the Unify MCP server, tell the user to finish
sign-in through the agent itself: fully restart the agent, then run the agent's
MCP login flow (in Claude Code, the `/mcp` command) and complete the Unify
browser login there.

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
marketplace and install `unify@unify-plugins` at user scope. It does not use
`/plugin` slash command. Sign-in needs a real interactive terminal (TTY), so
the script signs in with `claude mcp login plugin:unify:unify` only when one is
present. When run without a TTY (for example, piped from `curl`), it skips
sign-in and tells the user to restart Claude Code and complete the login flow
with the `/mcp` command.

### Cursor

Cursor does not provide a plugin-install CLI. The script installs the complete
plugin under `~/.cursor/plugins/local/unify`, which is Cursor's supported local
plugin directory. When run in an interactive terminal it uses a temporary
project MCP configuration to run `cursor-agent mcp enable unify` and
`cursor-agent mcp login unify`; the temporary configuration is removed after
sign-in, so it does not duplicate the MCP server bundled with the plugin.
Without a TTY it skips sign-in and tells the user to restart Cursor and enable
and sign in to the Unify MCP server from Settings -> Plugins.

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

## Keeping Unify up to date

Re-running the setup command always pulls the latest plugin — when Unify is
already installed, the script refreshes the marketplace and updates the plugin
in place. To get updates automatically instead, enable auto-update on the
`unify-plugins` marketplace.

Third-party marketplaces like `unify-plugins` have auto-update **disabled** by
default, so you opt in one of two ways.

### Toggle it interactively (Claude Code)

```
/plugin
```

Open the **Marketplaces** tab, select **unify-plugins**, and choose **Enable
auto-update**. Claude Code then refreshes the catalog on startup and updates the
plugin in the background, prompting you to run `/reload-plugins` when it does.

### Declare it in settings.json

Add the marketplace with `autoUpdate` in your user settings
(`~/.claude/settings.json`) or a project's `.claude/settings.json` so the
preference is applied wherever the file is loaded:

```json
{
  "extraKnownMarketplaces": {
    "unify-plugins": {
      "source": {
        "source": "github",
        "repo": "unifygtm/agent-plugins"
      },
      "autoUpdate": true
    }
  }
}
```

To update manually at any time, run:

```bash
claude plugin marketplace update unify-plugins
claude plugin update unify@unify-plugins --scope user
```

then `/reload-plugins` (or fully restart the agent) to load the new code.

## Troubleshooting

| Symptom                                          | Fix                                                                                                   |
| ------------------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| An agent CLI is not found                        | Install that agent or run the script only for agents already installed on the machine.                |
| Tools are missing after setup                    | Fully quit and restart the agent.                                                                     |
| Cursor does not show the plugin                  | Confirm the organization allows user-local plugin imports.                                            |
| Authentication was skipped or failed             | Re-run the same setup command, or omit `--no-auth`. The install steps are idempotent.                 |
| Sign-in was skipped (no interactive terminal)    | Fully restart the agent, then complete the login flow inside it — in Claude Code, the `/mcp` command. |
| Signed in, but tools still fail                  | Restart the agent so its MCP process reloads the stored session.                                      |
| "workspace does not have chat funding available" | Ask a Unify workspace admin to check the workspace plan or credits.                                   |
