#!/usr/bin/env bash

set -euo pipefail

REPOSITORY="unifygtm/agent-plugins"
PLUGIN="unify"
MARKETPLACE="unify-plugins"
MCP_SERVER="unify"
TEMP_DIR=""
PLUGIN_ROOT=""
AUTHENTICATE=1
TARGETS=()

cleanup() {
  if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

usage() {
  cat <<'EOF'
Install the Unify plugin for a supported coding agent.

Usage:
  ./scripts/setup.sh [--no-auth] [claude|cursor|codex|all] [...]

Examples:
  ./scripts/setup.sh
  curl -fsSL https://raw.githubusercontent.com/unifygtm/agent-plugins/main/scripts/setup.sh | bash -s -- claude
  curl -fsSL https://raw.githubusercontent.com/unifygtm/agent-plugins/main/scripts/setup.sh | bash -s -- all

With no agent argument, the installer detects the agent that launched it.
By default, the installer starts browser authentication for agents whose Unify
plugin includes the MCP server. Pass --no-auth to install without signing in.
EOF
}

log() {
  printf '\n==> %s\n' "$1"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'error: %s is not installed or is not on PATH\n' "$1" >&2
    exit 1
  fi
}

has_target() {
  local expected="$1"
  local target
  if [[ ${#TARGETS[@]} -eq 0 ]]; then
    return 1
  fi
  for target in "${TARGETS[@]}"; do
    [[ "$target" == "$expected" ]] && return 0
  done
  return 1
}

add_target() {
  if ! has_target "$1"; then
    TARGETS+=("$1")
  fi
}

detect_agent() {
  local pid process parent

  if [[ -n "${CLAUDE_CODE_ENTRYPOINT:-}" || -n "${CLAUDECODE:-}" ]]; then
    add_target claude
    return
  fi
  if [[ -n "${CURSOR_AGENT:-}" || -n "${CURSOR_TRACE_ID:-}" ]]; then
    add_target cursor
    return
  fi
  if [[ -n "${CODEX_THREAD_ID:-}" || -n "${CODEX_SANDBOX:-}" || -n "${CODEX_SANDBOX_NETWORK_DISABLED:-}" ]]; then
    add_target codex
    return
  fi

  if command -v ps >/dev/null 2>&1; then
    pid="$PPID"
    while [[ "$pid" =~ ^[0-9]+$ && "$pid" -gt 1 ]]; do
      process="$(ps -o comm= -p "$pid" 2>/dev/null || true) $(ps -o args= -p "$pid" 2>/dev/null || true)"
      case "$process" in
        *cursor-agent*|*Cursor.app*) add_target cursor; return ;;
        *claude*) add_target claude; return ;;
        *codex*) add_target codex; return ;;
      esac
      parent="$(ps -o ppid= -p "$pid" 2>/dev/null || true)"
      pid="${parent//[[:space:]]/}"
    done
  fi

  printf 'error: could not detect Claude Code, Cursor, or Codex\n' >&2
  printf 'Re-run with an explicit agent name, for example:\n' >&2
  printf '  curl -fsSL https://raw.githubusercontent.com/unifygtm/agent-plugins/main/scripts/setup.sh | bash -s -- claude\n' >&2
  exit 2
}

ensure_temp_dir() {
  if [[ -z "$TEMP_DIR" ]]; then
    TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/unify-agent-plugins.XXXXXX")"
  fi
}

prepare_plugin_root() {
  local repository_root=""
  local script_source="${BASH_SOURCE[0]:-}"
  if [[ -n "$script_source" ]]; then
    repository_root="$(cd "$(dirname "$script_source")/.." 2>/dev/null && pwd -P || true)"
  fi

  if [[ -n "$repository_root" && -f "$repository_root/unify/.cursor-plugin/plugin.json" ]]; then
    PLUGIN_ROOT="$repository_root/unify"
    return
  fi

  require_command git
  ensure_temp_dir
  if [[ ! -d "$TEMP_DIR/repository" ]]; then
    git clone --depth 1 "https://github.com/$REPOSITORY.git" "$TEMP_DIR/repository"
  fi
  PLUGIN_ROOT="$TEMP_DIR/repository/unify"
}

install_claude() {
  local marketplaces plugins
  require_command claude
  log "Installing Unify for Claude Code"

  marketplaces="$(claude plugin marketplace list --json 2>/dev/null || true)"
  if [[ "$marketplaces" != *"\"name\": \"$MARKETPLACE\""* ]]; then
    claude plugin marketplace add "$REPOSITORY" --scope user
  else
    claude plugin marketplace update "$MARKETPLACE"
  fi

  plugins="$(claude plugin list --json 2>/dev/null || true)"
  if [[ "$plugins" != *"\"id\": \"$PLUGIN@$MARKETPLACE\""* ]]; then
    claude plugin install "$PLUGIN@$MARKETPLACE" --scope user
  else
    claude plugin update "$PLUGIN@$MARKETPLACE" --scope user
  fi
}

authenticate_claude() {
  if [[ ! -t 0 ]]; then
    log "Skipping automatic sign-in for Claude Code (no interactive terminal)"
    printf 'The Unify plugin is installed. To finish sign-in:\n'
    printf '  1. Fully restart Claude Code.\n'
    printf '  2. Run the /mcp command and complete the Unify browser login flow.\n'
    return
  fi
  log "Signing in to Unify for Claude Code"
  claude mcp login "plugin:$PLUGIN:$MCP_SERVER"
}

install_cursor() {
  local source target target_parent staging
  prepare_plugin_root
  source="$PLUGIN_ROOT"
  target_parent="$HOME/.cursor/plugins/local"
  target="$target_parent/$PLUGIN"
  staging="$target_parent/.$PLUGIN.tmp.$$"

  log "Installing Unify for Cursor"
  mkdir -p "$target_parent"
  rm -rf "$staging"
  cp -R "$source" "$staging"
  rm -rf "$target"
  mv "$staging" "$target"
  printf 'Installed the Cursor plugin at %s.\n' "$target"
}

authenticate_cursor() {
  local auth_dir
  if [[ ! -t 0 ]]; then
    log "Skipping automatic sign-in for Cursor (no interactive terminal)"
    printf 'The Unify plugin is installed. To finish sign-in:\n'
    printf '  1. Fully restart Cursor.\n'
    printf '  2. Enable and sign in to the Unify MCP server from Settings -> Plugins (or the MCP panel).\n'
    return
  fi
  require_command cursor-agent
  ensure_temp_dir
  auth_dir="$TEMP_DIR/cursor-auth"
  mkdir -p "$auth_dir/.cursor"
  cp "$HOME/.cursor/plugins/local/$PLUGIN/mcp.json" "$auth_dir/.cursor/mcp.json"

  log "Signing in to Unify for Cursor"
  (
    cd "$auth_dir"
    cursor-agent mcp enable "$MCP_SERVER"
    cursor-agent mcp login "$MCP_SERVER"
  )
}

install_codex() {
  local marketplaces plugins
  require_command codex
  log "Installing Unify for Codex"

  marketplaces="$(codex plugin marketplace list --json 2>/dev/null || true)"
  if [[ "$marketplaces" != *"\"name\": \"$MARKETPLACE\""* ]]; then
    codex plugin marketplace add "$REPOSITORY"
  else
    codex plugin marketplace upgrade "$MARKETPLACE"
  fi

  plugins="$(codex plugin list --json 2>/dev/null || true)"
  if [[ "$plugins" != *"\"pluginId\": \"$PLUGIN@$MARKETPLACE\""* ]]; then
    codex plugin add "$PLUGIN@$MARKETPLACE"
  else
    printf 'Unify is already installed for Codex.\n'
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-auth)
      AUTHENTICATE=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    all)
      TARGETS=(claude cursor codex)
      ;;
    claude|cursor|codex)
      add_target "$1"
      ;;
    *)
      printf 'error: unsupported agent: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  detect_agent
fi

for target in "${TARGETS[@]}"; do
  case "$target" in
    claude) install_claude ;;
    cursor) install_cursor ;;
    codex) install_codex ;;
  esac
done

if [[ $AUTHENTICATE -eq 1 ]]; then
  has_target claude && authenticate_claude
  has_target cursor && authenticate_cursor
fi

log "Setup complete"
printf 'Restart each agent you installed Unify for so it loads the plugin and MCP connection.\n'
if has_target codex; then
  printf 'Codex currently receives the Unify skills only; MCP tools are not yet included in its plugin.\n'
fi
