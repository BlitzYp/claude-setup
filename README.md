# claude-setup

My Claude Code plugins and skills, so any machine can be brought in sync with one command.

| File | What it holds |
| --- | --- |
| `marketplaces.txt` | Plugin marketplaces to add |
| `plugins.txt` | Plugins to install (`plugin@marketplace`) |
| `skills/` | Skills, copied into `~/.claude/skills/` |
| `skill-sources.txt` | Skills in `skills/` that come from other repos (`<repo url> <skill name>`) |
| `setup.ps1` / `setup.sh` | Installs Claude Code if missing, then applies all of the above |
| `update.ps1` / `update.sh` | Updates plugins and third-party skills, pushes skill changes, then runs setup |
| `add-jitbit-mcp.ps1` / `add-jitbit-mcp.sh` | Adds the Jitbit MCP server, prompting for your token |

## Set up a new machine

**Windows (PowerShell):**

```powershell
git clone git@github.com:BlitzYp/claude-setup.git $HOME\claude-setup
powershell -ExecutionPolicy Bypass -File $HOME\claude-setup\setup.ps1
```

**macOS / Linux:**

```bash
git clone git@github.com:BlitzYp/claude-setup.git ~/claude-setup
bash ~/claude-setup/setup.sh
```

## Sync an existing machine

**Windows:**

```powershell
git -C $HOME\claude-setup pull
powershell -ExecutionPolicy Bypass -File $HOME\claude-setup\setup.ps1
```

**macOS / Linux:**

```bash
git -C ~/claude-setup pull && bash ~/claude-setup/setup.sh
```

Re-running is safe: anything already added or installed is left as is.

## Update everything

Pulls the repo, updates marketplaces and plugins to their latest versions, re-fetches the skills
in `skill-sources.txt` (commits and pushes if they changed), then syncs this machine.
The skill refresh needs Node.js (`npx`); without it that step is skipped.

**Windows:**

```powershell
powershell -ExecutionPolicy Bypass -File $HOME\claude-setup\update.ps1
```

**macOS / Linux:**

```bash
bash ~/claude-setup/update.sh
```

Restart Claude Code afterwards to load updated plugins.

## Jitbit MCP

The first time `setup` runs on a machine (including from `update`), it asks whether to add the
Jitbit MCP server and, if yes, asks you to paste your token. It only asks once per machine,
whichever way you answer (remembered in `~/.claude/.jitbit-mcp-asked`), and doesn't ask at all
if `jitbit` is already configured.

To add it later, or to replace the token:

**Windows:**

```powershell
powershell -ExecutionPolicy Bypass -File $HOME\claude-setup\add-jitbit-mcp.ps1
```

**macOS / Linux:**

```bash
bash ~/claude-setup/add-jitbit-mcp.sh
```

The server is added at user scope, so it works in every project. The token is stored in
`~/.claude.json` on that machine and is never committed to this repo.

## Adding something new

1. Add the line to `plugins.txt` (and its marketplace to `marketplaces.txt` if it's a new one), or drop a skill folder into `skills/`.
   For a skill from someone else's repo, also add `<repo url> <skill name>` to `skill-sources.txt` so `update` keeps it current.
2. Commit and push.
3. On other machines, run the sync commands above.
