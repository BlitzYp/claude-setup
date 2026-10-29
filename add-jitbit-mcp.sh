#!/usr/bin/env bash
# Adds the Jitbit MCP server to Claude Code for this user, prompting for the API token (macOS/Linux).
# Usage: bash add-jitbit-mcp.sh
url="https://kanban.dobelemill.org/mcp"

if ! command -v claude >/dev/null 2>&1; then
  echo "Claude Code not found, run setup.sh first."
  exit 1
fi

read -rsp "Paste your Jitbit token: " token </dev/tty
echo
token="${token#Bearer }"
token="$(printf '%s' "$token" | tr -d '[:space:]')"
if [ -z "$token" ]; then
  echo "No token entered, Jitbit MCP not added."
  exit 1
fi

# Replace any existing entry so re-running this updates the token.
claude mcp remove jitbit -s user >/dev/null 2>&1
claude mcp add --scope user --transport http jitbit "$url" --header "Authorization: Bearer $token" &&
  echo "Jitbit MCP added. Restart Claude Code to pick it up."
