# Syncs Claude Code plugins and personal skills from this repo onto this machine (Windows).
# Usage: powershell -ExecutionPolicy Bypass -File setup.ps1
$ErrorActionPreference = 'Continue'
$repo = $PSScriptRoot

function Read-List($file) {
    Get-Content (Join-Path $repo $file) | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
}

# Install Claude Code if it's missing.
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "Claude Code not found, installing..."
    Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
    $bin = Join-Path $env:USERPROFILE '.local\bin'
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (($userPath -split ';') -notcontains $bin) {
        [Environment]::SetEnvironmentVariable('Path', ($userPath.TrimEnd(';') + ';' + $bin), 'User')
    }
    $env:Path += ";$bin"
}

foreach ($m in Read-List 'marketplaces.txt') {
    Write-Host "`n== Marketplace: $m"
    claude plugin marketplace add $m
}

foreach ($p in Read-List 'plugins.txt') {
    Write-Host "`n== Plugin: $p"
    claude plugin install $p
}

# Copy personal skills (each a folder with a SKILL.md) into ~/.claude/skills.
$skillsSrc = Join-Path $repo 'skills'
$skillsDst = Join-Path $env:USERPROFILE '.claude\skills'
Get-ChildItem $skillsSrc -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "`n== Skill: $($_.Name)"
    New-Item -ItemType Directory -Force $skillsDst | Out-Null
    Copy-Item $_.FullName $skillsDst -Recurse -Force
}

Write-Host "`nDone. Restart Claude Code to pick up the changes."
