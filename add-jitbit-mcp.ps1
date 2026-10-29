# Adds the Jitbit MCP server to Claude Code for this user, prompting for the API token (Windows).
# Usage: powershell -ExecutionPolicy Bypass -File add-jitbit-mcp.ps1
$ErrorActionPreference = 'Continue'
$url = 'https://kanban.dobelemill.org/mcp'

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "Claude Code not found, run setup.ps1 first."
    exit 1
}

$secure = Read-Host "Paste your Jitbit token" -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
$token = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
$token = ($token -replace '^Bearer\s+', '') -replace '\s', ''
if (-not $token) {
    Write-Host "No token entered, Jitbit MCP not added."
    exit 1
}

# Replace any existing entry so re-running this updates the token.
claude mcp remove jitbit -s user *> $null
claude mcp add --scope user --transport http jitbit $url --header "Authorization: Bearer $token"
if ($LASTEXITCODE -eq 0) { Write-Host "Jitbit MCP added. Restart Claude Code to pick it up." }
