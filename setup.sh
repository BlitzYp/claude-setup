#!/usr/bin/env bash
# Syncs Claude Code plugins and personal skills from this repo onto this machine (macOS/Linux).
# Usage: bash setup.sh
repo="$(cd "$(dirname "$0")" && pwd)"

read_list() {
  grep -v '^[[:space:]]*#' "$repo/$1" | sed 's/[[:space:]]*$//' | grep -v '^$'
}

# Install Claude Code if it's missing.
if ! command -v claude >/dev/null 2>&1; then
  echo "Claude Code not found, installing..."
  curl -fsSL https://claude.ai/install.sh | bash
  export PATH="$HOME/.local/bin:$PATH"
fi

read_list marketplaces.txt | while read -r m; do
  echo; echo "== Marketplace: $m"
  claude plugin marketplace add "$m"
done

read_list plugins.txt | while read -r p; do
  echo; echo "== Plugin: $p"
  claude plugin install "$p"
done

# Copy personal skills (each a folder with a SKILL.md) into ~/.claude/skills.
if [ -d "$repo/skills" ]; then
  mkdir -p "$HOME/.claude/skills"
  for d in "$repo"/skills/*/; do
    [ -d "$d" ] || continue
    echo; echo "== Skill: $(basename "$d")"
    cp -R "$d" "$HOME/.claude/skills/"
  done
fi

# Offer the Jitbit MCP once per machine. Either answer is remembered; run add-jitbit-mcp.sh to add it later.
asked="$HOME/.claude/.jitbit-mcp-asked"
if [ ! -e "$asked" ] && [ -t 0 ] && ! claude mcp get jitbit >/dev/null 2>&1; then
  echo; echo "== Jitbit MCP"
  read -rp "Add the Jitbit MCP server? [y/N] " answer
  mkdir -p "$HOME/.claude" && touch "$asked"
  case "$answer" in
    [yY]*) bash "$repo/add-jitbit-mcp.sh" ;;
    *) echo "Skipped. Run add-jitbit-mcp.sh if you want it later." ;;
  esac
fi

echo; echo "Done. Restart Claude Code to pick up the changes."
