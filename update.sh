#!/usr/bin/env bash
# Updates everything: pulls this repo, updates marketplaces and plugins, re-fetches
# third-party skills, pushes any skill changes, then re-syncs this machine (macOS/Linux).
# Usage: bash update.sh
repo="$(cd "$(dirname "$0")" && pwd)"

read_list() {
  grep -v '^[[:space:]]*#' "$repo/$1" | sed 's/[[:space:]]*$//' | grep -v '^$'
}

echo "== Pulling latest repo"
git -C "$repo" pull --ff-only

echo; echo "== Updating marketplaces"
claude plugin marketplace update

read_list plugins.txt | while read -r p; do
  echo; echo "== Updating plugin: $p"
  claude plugin update "$p"
done

if command -v npx >/dev/null 2>&1; then
  read_list skill-sources.txt | while read -r src name; do
    echo; echo "== Refreshing skill: $name"
    npx -y skills add "$src" --full-depth --skill "$name" -g -a claude-code -y --copy </dev/null
    if [ -d "$HOME/.claude/skills/$name" ]; then
      rm -rf "$repo/skills/$name"
      cp -R "$HOME/.claude/skills/$name" "$repo/skills/$name"
    fi
  done

  git -C "$repo" add skills
  if ! git -C "$repo" diff --cached --quiet; then
    echo; echo "== Skill changes found, committing and pushing"
    git -C "$repo" commit -m "Update third-party skills"
    git -C "$repo" push
  else
    echo; echo "== Third-party skills already up to date"
  fi
else
  echo; echo "npx not found, skipping third-party skill refresh (install Node.js to enable it)."
fi

echo; echo "== Syncing this machine"
bash "$repo/setup.sh"
