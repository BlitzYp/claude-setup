# Updates everything: pulls this repo, updates marketplaces and plugins, re-fetches
# third-party skills, pushes any skill changes, then re-syncs this machine (Windows).
# Usage: powershell -ExecutionPolicy Bypass -File update.ps1
$ErrorActionPreference = 'Continue'
$repo = $PSScriptRoot

function Read-List($file) {
    Get-Content (Join-Path $repo $file) | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
}

Write-Host "== Pulling latest repo"
git -C $repo pull --ff-only

Write-Host "`n== Updating marketplaces"
claude plugin marketplace update

foreach ($p in Read-List 'plugins.txt') {
    Write-Host "`n== Updating plugin: $p"
    claude plugin update $p
}

if (Get-Command npx -ErrorAction SilentlyContinue) {
    foreach ($line in Read-List 'skill-sources.txt') {
        $src, $name = $line -split '\s+', 2
        Write-Host "`n== Refreshing skill: $name"
        npx -y skills add $src --full-depth --skill $name -g -a claude-code -y --copy
        $installed = Join-Path $env:USERPROFILE ".claude\skills\$name"
        if (Test-Path $installed) {
            $dst = Join-Path $repo "skills\$name"
            if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
            Copy-Item $installed $dst -Recurse
        }
    }

    git -C $repo add skills
    git -C $repo diff --cached --quiet
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n== Skill changes found, committing and pushing"
        git -C $repo commit -m "Update third-party skills"
        git -C $repo push
    } else {
        Write-Host "`n== Third-party skills already up to date"
    }
} else {
    Write-Host "`nnpx not found, skipping third-party skill refresh (install Node.js to enable it)."
}

Write-Host "`n== Syncing this machine"
& (Join-Path $repo 'setup.ps1')
