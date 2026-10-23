# claude-setup

My Claude Code plugins and skills, so any machine can be brought in sync with one command.

| File | What it holds |
| --- | --- |
| `marketplaces.txt` | Plugin marketplaces to add |
| `plugins.txt` | Plugins to install (`plugin@marketplace`) |
| `skills/` | My own skills, copied into `~/.claude/skills/` |
| `setup.ps1` / `setup.sh` | Installs Claude Code if missing, then applies all of the above |

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

## Adding something new

1. Add the line to `plugins.txt` (and its marketplace to `marketplaces.txt` if it's a new one), or drop a skill folder into `skills/`.
2. Commit and push.
3. On other machines, run the sync commands above.
